# ModbusDriver — Developer Notes

## Overview

ModbusDriver is a Structured Text library for Mitsubishi FX series PLCs (GX Works 2) that implements Modbus RTU master and slave communication on the two auxiliary RS485 ports (port 2 and port 3). It provides port-initialisation functions, a bit-field builder for the serial-port configuration registers, and a channel-processing function block that cycles through a configurable array of Modbus channels and issues `ADPRW` requests.

## File Structure

```
POU/
├── GVL_MB.csv                     — Global constants (access modes, parity, stop bits, baud rates, ports) and the MB_CHANNELS array
├── ST_MB_REG_50.csv               — MB_REG_50 struct definition (per-channel configuration)
├── MB_PORT_SETTINGS.st / .csv     — Function: build the D8120/D8400 port bit-field from parity/stop/baud inputs
├── MB_MASTER_INIT_PORT2.st / .csv — Function: initialise Modbus master on port 2
├── MB_MASTER_INIT_PORT3.st / .csv — Function: initialise Modbus master on port 3
├── MB_SLAVE_INIT_PORT2.st / .csv  — Function: initialise Modbus slave on port 2
├── MB_SLAVE_INIT_PORT3.st / .csv  — Function: initialise Modbus slave on port 3
├── MTB_SLAVE_PORT2.st / .csv      — Function: switch port 2 back to Mitsubishi protocol (38400/7/E/1)
├── MTB_SLAVE_PORT3.st / .csv      — Function: switch port 3 back to Mitsubishi protocol (38400/7/E/1)
├── MB_PROCESS_50.st / .csv        — Function Block: cycle through MB_CHANNELS and issue ADPRW read/write requests
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
| `MB_CHANNELS` | `ARRAY [0..29] OF MB_REG_50` | Channel configuration array — 30 channels |

## Conventions & Gotchas

- The port-initialisation and settings POUs are **functions** that return their result through the function name. In GX Works 2 a function call used as a statement requires a left-hand side, so callers assign the result to a dummy bit: `M0 := MB_MASTER_INIT_PORT2(TRUE, PortSettings);`.
- Naming deviates from the standard `F_`/`FB_` prefix convention (legacy): `MB_PROCESS_50` is a function block (declare an instance `fbMbProcess : MB_PROCESS_50`); all other top-level POUs are functions. Do not rename the public names without regenerating `Modbus.sul` and updating every caller.
- Requires the **TimeControl** library: `MB_PROCESS_50` uses `TCO_DINT_50` and `TCO_50_DIFF` for 50 ms scheduling. `TCO_TICKER_50` must run in an interrupt task.
- `MB_PROCESS_50` must be called every scan (or at least faster than the shortest `tCycle`). A startup `fbTON1` delay of 3 s gates the first request.
- Channel storage: each channel reserves **2 × `iNum`** devices in the `D` (register) or `M` (coil) area — half for values, half for change tracking. Allocate `iDDevNum` so consecutive channels do not overlap (see `Modbus.md`).
- `MB_CHANNELS` is declared globally by the library; configure it once at startup (typically under `M8002`).
- The initialisation functions write Coolmay/Mitsubishi special registers directly (`D8120`, `D8400`, `D8126`, `D8397`, `M8125`, `M8192`, `M8196`, …). These are port-configuration registers — do not rename or re-map them.
- CSV files are UTF-16LE + BOM, tab-separated, every cell quoted, LF line endings; `.st` files use CRLF.

## Test Program (PRG_MB_TEST)

`PRG_MB_TEST` is a compile-and-run example: it enables interrupts, builds a port bit-field via `MB_PORT_SETTINGS`, initialises the master on port 2 under the `M8002`/`M1` pulse, configures channel 0 (read/write of 6 holding registers from device 1), sets the timeout globals, and calls `fbMbProcess` every scan. It also copies four test registers (`reg1`–`reg4`) into local labels for monitoring.
