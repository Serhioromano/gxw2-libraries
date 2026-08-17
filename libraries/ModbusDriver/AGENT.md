# ModbusDriver — Developer Notes

## Overview

ModbusDriver is a Structured Text library for Mitsubishi FX series PLCs (GX Works 2) that implements Modbus RTU master and slave communication on the two auxiliary RS485 ports (port 2 and port 3). It provides port-initialisation functions, a bit-field builder for the serial-port configuration registers, and a channel-processing function block that cycles through a configurable array of Modbus channels and issues `ADPRW` requests. The channel array and its size are **not** part of the library — the application declares them in its own global label list (see User Requirements below).

## File Structure

```
POU/
├── GVL_MB.csv                     — Global constants (access modes, parity, stop bits, baud rates, ports) and timeout globals
├── GVL_MB_TEST.csv                — Test-project globals: channel storage (MB_CHANNELS + c_MB_CHANNELS_NUM) and demo value labels (g_iAutoReg*, g_iDemandReg*, g_xCoil*)
├── ST_MB_REG_50.csv               — MB_REG_50 struct definition (per-channel configuration)
├── MB_PORT_SETTINGS.st / .csv     — Function: build the D8120/D8400 port bit-field from parity/stop/baud inputs
├── MB_MASTER_INIT_PORT2.st / .csv — Function: initialise Modbus master on port 2
├── MB_MASTER_INIT_PORT3.st / .csv — Function: initialise Modbus master on port 3
├── MB_SLAVE_INIT_PORT2.st / .csv  — Function: initialise Modbus slave on port 2
├── MB_SLAVE_INIT_PORT3.st / .csv  — Function: initialise Modbus slave on port 3
├── MTB_SLAVE_PORT2.st / .csv      — Function: switch port 2 back to Mitsubishi protocol (38400/7/E/1)
├── MTB_SLAVE_PORT3.st / .csv      — Function: switch port 3 back to Mitsubishi protocol (38400/7/E/1)
├── MB_PROCESS_50.st / .csv        — Function Block: cycle through the application-declared MB_CHANNELS and issue ADPRW read/write requests
└── PRG_MB_TEST.st / .csv          — Test/example program exercising the driver
```

## Public API

| POU | Type | Purpose |
|---|---|---|
| `MB_PORT_SETTINGS` | Function | Build the serial-port bit-field (parity, stop bits, baud rate) |
| `MB_MASTER_INIT_PORT2` | Function | Initialise Modbus master on port 2 |
| `MB_MASTER_INIT_PORT3` | Function | Initialise Modbus master on port 3 |
| `MB_SLAVE_INIT_PORT2` | Function | Initialise Modbus slave on port 2 |
| `MB_SLAVE_INIT_PORT3` | Function | Initialise Modbus slave on port 3 |
| `MTB_SLAVE_PORT2` | Function | Reconfigure port 2 for Mitsubishi protocol |
| `MTB_SLAVE_PORT3` | Function | Reconfigure port 3 for Mitsubishi protocol |
| `MB_PROCESS_50` | Function Block | Cycle through channels and issue ADPRW requests |
| `MB_REG_50` | Structure | Per-channel configuration (declared in `ST_MB_REG_50.csv`) |

## Global Variables (GVL_MB.csv)

### Constants

| Constant | Value | Purpose |
|---|---|---|
| `MB_READ_WRITE` | 0 | Access mode — read and write |
| `MB_READ` | 1 | Access mode — read only |
| `MB_WRITE` | 2 | Access mode — write only |
| `MB_DL_7` | 0 | 7 data bits |
| `MB_DL_8` | 1 | 8 data bits |
| `MB_PARITY_NONE` | 0 | No parity |
| `MB_PARITY_ODD` | 1 | Odd parity |
| `MB_PARITY_EVEN` | 2 | Even parity |
| `MB_STOPBIT_1` | 0 | 1 stop bit |
| `MB_STOPBIT_2` | 1 | 2 stop bits |
| `MB_BPS_600` … `MB_BPS_115200` | 0 … 8 | Baud-rate selectors (600/1200/2400/4800/9600/19200/38400/57600/115200 bps) |
| `MB_PORT_2` | 0 | RS485 port 2 (terminal connector) |
| `MB_PORT_3` | 1 | RS485 port 3 (DB9 connector) |
| `MB_PORT_CAN` | 2 | CAN port |
| `MB_PORT_TCP` | 3 | Ethernet TCP port |

### Variables

| Variable | Type | Purpose |
|---|---|---|
| `MB_TIMEOUT_COUNT` | INT | Consecutive timeouts before a channel is suspended |
| `MB_SUSPEND_RETRY` | INT | Suspended-channel retry interval (50 ms units) |
| `MB_TIMEOUT_TIME` | INT | Timeout duration (50 ms units) |

## User Requirements (declared by the application)

The application must declare the channel storage in its own global label list, sized to its needs. The library code references these labels directly; without them the project does not compile.

| Label | Class | Type |
|---|---|---|
| `c_MB_CHANNELS_NUM` | `VAR_GLOBAL_CONSTANT` | INT — upper bound (last index) of `MB_CHANNELS` |
| `MB_CHANNELS` | `VAR_GLOBAL` | `ARRAY [0..c_MB_CHANNELS_NUM] OF MB_REG_50` |

`c_MB_CHANNELS_NUM` is the **last valid index**, so the array holds `c_MB_CHANNELS_NUM + 1` channels. For 30 channels set `c_MB_CHANNELS_NUM := 29`. Keep the literal array bound in sync with `c_MB_CHANNELS_NUM`.

## Conventions & Gotchas

- The port-initialisation and settings POUs are **functions** that return their result through the function name. In GX Works 2 a function call used as a statement requires a left-hand side, so callers assign the result to a dummy bit: `M0 := MB_MASTER_INIT_PORT2(TRUE, PortSettings);`.
- Naming deviates from the standard `F_`/`FB_` prefix convention (legacy): `MB_PROCESS_50` is a function block (declare an instance `fbMbProcess : MB_PROCESS_50`); all other top-level POUs are functions. Do not rename the public names without regenerating `Modbus.sul` and updating every caller.
- Requires the **TimeControl** library: `MB_PROCESS_50` uses `TCO_DINT_50` and `TCO_50_DIFF` for 50 ms scheduling. `TCO_TICKER_50` must run in an interrupt task.
- `MB_PROCESS_50` must be called every scan (or at least faster than the shortest `tCycle`). A startup `fbTON1` delay of 3 s gates the first request.
- `mb_Timeout` is an `INT` output that reports the 0-based index (`iCount`) of the channel that timed out, held for one scan; it is `-1` when no channel has timed out. The watchdog block sets it via `MOV(fbTON2.Q, iCount, mb_Timeout)`, the per-scan default `mb_Timeout := -1` is set at the top of the POU, and the guard conditions use `mb_Timeout >= 0` / `mb_Timeout = -1` (not `> 0` / `= 0`).
- `iTimeOut` (per-channel, library-managed) is the consecutive-timeout counter. It is incremented in the watchdog block when a request times out and reset to `0` (`MB_CHANNELS[iCount].iTimeOut := 0;`) on every successful `ADPRW` completion (both register and coil paths).
- Channel storage: each channel reserves **2 × `iNum`** devices in the `D` (register) or `M` (coil) area — half for values, half for change tracking. Allocate `iDDevNum` so consecutive channels do not overlap (see `Modbus.md`).
- `MB_CHANNELS` and `c_MB_CHANNELS_NUM` are user requirements — declared by the application, not the library. Configure the channel fields once at startup (typically under `M8002`).
- The initialisation functions write Coolmay/Mitsubishi special registers directly (`D8120`, `D8400`, `D8126`, `D8397`, `M8125`, `M8192`, `M8196`, …). These are port-configuration registers — do not rename or re-map them.
- CSV files are UTF-16LE + BOM, tab-separated, every cell quoted, LF line endings; `.st` files use CRLF.

## Test Program (PRG_MB_TEST)

`PRG_MB_TEST` is a compile-and-run example that covers all three channel kinds. It enables interrupts, builds a port bit-field via `MB_PORT_SETTINGS`, and initialises the master on ports 2 and 3 (re-triggered every second by the `M8013` clock). Under the `M8002` pulse it sets the timeout globals and configures three channels:

- **Channel 0** — register, automatic read/write (device 1, port 2, `tCycle = 20`).
- **Channel 1** — register, read-only, on demand (device 2, port 3, `tCycle = 0`, read via `xReadOnce`).
- **Channel 2** — coils, read/write (device 3, port 2, `tCycle = 10`).

It calls `fbMbProcess` every scan and demonstrates an on-demand read (channel 1) and write-on-change (channels 0 and 2). Channel storage (`MB_CHANNELS`, `c_MB_CHANNELS_NUM`) and the demo value labels (`g_iAutoReg*`, `g_iDemandReg*`, `g_xCoil*`) are declared in `GVL_MB_TEST.csv`.
