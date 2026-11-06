# ModbusDriver — Developer Notes

## Overview

ModbusDriver is a Structured Text library for Mitsubishi FX series PLCs (GX Works 2) that implements Modbus RTU master and slave communication on the two auxiliary RS485 ports (port 2 and port 3). On L02-series PLCs the same channel model also drives the built-in Ethernet port as a Modbus TCP master (client) when a channel's `iPort` is `MB_PORT_TCP`. The library also configures that port as an **EtherNet/IP scanner** (`EIP_INIT`, `EIP_INIT_REMOTE`) and gives typed, bounds-checked access to the remote coupler I/O (`EIP_DI`, `EIP_DO`, `EIP_DO_SET`, `EIP_AI`, `EIP_AO`, `EIP_AO_SET`). It provides port-initialisation functions, a bit-field builder for the serial-port configuration registers, and a channel-processing function block that cycles through a configurable array of Modbus channels and issues `ADPRW` requests. The channel array and its size are **not** part of the library — the application declares them in its own global label list (see User Requirements below).

## File Structure

```
POU/
├── GVL_MB.csv                     — Global constants (access modes, clear modes, parity, stop bits, baud rates, ports, EIP coupler selectors)
├── GVL_MB_TEST.csv                — Test-project globals: channel storage (MB_CHANNELS + c_MB_CHANNELS_NUM) and demo value labels (g_iAutoReg*, g_iDemandReg*, g_xCoil*)
├── ST_MB_REG_50.csv               — MB_REG_50 struct definition (per-channel configuration)
├── MB_PORT_SETTINGS.iecst / .csv     — Function: build the D8120/D8400 port bit-field from parity/stop/baud inputs
├── MB_MASTER_INIT_PORT2.iecst / .csv — Function: initialise Modbus master on port 2
├── MB_MASTER_INIT_PORT3.iecst / .csv — Function: initialise Modbus master on port 3
├── MB_SLAVE_INIT_PORT2.iecst / .csv  — Function: initialise Modbus slave on port 2
├── MB_SLAVE_INIT_PORT3.iecst / .csv  — Function: initialise Modbus slave on port 3
├── MB_SLAVE_INIT_TCP.iecst / .csv    — Function: switch the L02 Ethernet port to Modbus TCP slave (server)
├── MB_MASTER_INIT_TCP.iecst / .csv   — Function: configure the L02 Ethernet port as Modbus TCP master (client)
├── EIP_INIT.iecst / .csv             — Function: select EtherNet/IP and set the number of remote couplers (D8395/D8325)
├── EIP_INIT_REMOTE.iecst / .csv      — Function: write the DI/DO/AI/AO sizes of one remote EIP coupler (DI/DO bytes, AI/AO words; arguments are points)
├── EIP_DI.iecst / .csv               — Function: read one remote digital input point (returns BOOL)
├── EIP_DO.iecst / .csv               — Function: read one remote digital output point (returns BOOL)
├── EIP_DO_SET.iecst / .csv           — Function: write one remote digital output point (returns BOOL)
├── EIP_AI.iecst / .csv               — Function: read one remote analog input point (returns INT)
├── EIP_AO.iecst / .csv               — Function: read one remote analog output point (returns INT)
├── EIP_AO_SET.iecst / .csv           — Function: write one remote analog output point (returns INT)
├── MTB_SLAVE_PORT2.iecst / .csv      — Function: switch port 2 back to Mitsubishi protocol (38400/7/E/1)
├── MTB_SLAVE_PORT3.iecst / .csv      — Function: switch port 3 back to Mitsubishi protocol (38400/7/E/1)
├── MB_PROCESS_50.iecst / .csv        — Function Block: cycle through the application-declared MB_CHANNELS and issue ADPRW read/write requests
└── PRG_MB_TEST.iecst / .csv          — Test/example program exercising the driver
```

## Public API

| POU | Type | Purpose |
|---|---|---|
| `MB_PORT_SETTINGS` | Function | Build the serial-port bit-field (parity, stop bits, baud rate) |
| `MB_MASTER_INIT_PORT2` | Function | Initialise Modbus master on port 2 |
| `MB_MASTER_INIT_PORT3` | Function | Initialise Modbus master on port 3 |
| `MB_SLAVE_INIT_PORT2` | Function | Initialise Modbus slave on port 2 |
| `MB_SLAVE_INIT_PORT3` | Function | Initialise Modbus slave on port 3 |
| `MB_SLAVE_INIT_TCP` | Function | Switch the L02 Ethernet port to Modbus TCP slave (server) mode |
| `MB_MASTER_INIT_TCP` | Function | Configure the L02 Ethernet port as Modbus TCP master (client) |
| `EIP_INIT` | Function | Select EtherNet/IP on the L02 port and set the number of remote couplers (`D8395 := 0`, `D8325`) |
| `EIP_INIT_REMOTE` | Function | Write the DI/DO/AI/AO sizes of one remote EtherNet/IP coupler (DI/DO bytes, AI/AO words; arguments are points) |
| `EIP_DI` / `EIP_DO` | Function | Read one remote digital input / output point (`BOOL`) |
| `EIP_DO_SET` | Function | Write one remote digital output point, returns the value written |
| `EIP_AI` / `EIP_AO` | Function | Read one remote analog input / output word (`INT`) |
| `EIP_AO_SET` | Function | Write one remote analog output word, returns the value written |
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
| `MB_CLEAR_NONE` | 0 | Startup clear mode — clear nothing (default) |
| `MB_CLEAR_ALL` | 1 | Startup clear mode — clear values and change-tracking buffer |
| `MB_CLEAR_BUFFER` | 2 | Startup clear mode — clear change-tracking buffer only |
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
| `EIP_REMOTE1` … `EIP_REMOTE4` | 1 … 4 | EtherNet/IP coupler selectors for `EIP_INIT_REMOTE` and the `EIP_*` accessors (not R addresses) |

> `EIP_REMOTE1`…`EIP_REMOTE4` are **not** `IP_REMOTE1`…`IP_REMOTE4` from the Utils `GVL_UTL`: those are the `R` register bases (`23830`…`23860`) that `L02_SET_IP` writes the remote IP addresses into. Keep both sets.

Timeout tuning (`mb_iTimeoutCount`, `mb_iSuspendRetry`, `mb_iTimeoutTime`) and startup clearing (`mb_iClearOnStart`) are no longer global variables — they are inputs of `MB_PROCESS_50`. The block keeps local copies named `MB_TIMEOUT_COUNT`, `MB_SUSPEND_RETRY`, and `MB_TIMEOUT_TIME` that receive the input value (or the default when the input is `0`).

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
- Requires the **Utils** library: the init/settings functions use `F_DSETB` / `F_DSRB`, and `MB_PROCESS_50` uses `F_MBMOV` / `F_ISBON`.
- `MB_PROCESS_50` must be called every scan (or at least faster than the shortest `tCycle`). A startup `fbTON1` delay of 3 s gates the first request.
- `mb_iTimeout` is an `INT` output that reports the 0-based index (`iChannelID`) of the channel that timed out, held for one scan; it is `-1` when no channel has timed out. The watchdog block (`fbWatchdogTimer`, evaluated **after** the request handling) sets it via `MOV(fbWatchdogTimer.Q, iChannelID, mb_iTimeout)`, the per-scan default `mb_iTimeout := -1` is set at the top of the POU, and the guard conditions use `mb_iTimeout >= 0` / `mb_iTimeout = -1` (not `> 0` / `= 0`).
- `iTimeOut` (per-channel, library-managed) is the consecutive-timeout counter. It is incremented in the watchdog block (`fbWatchdogTimer`, evaluated **after** the `CASE` so a request completed in the same scan wins over a timeout) when a request times out and reset to `0` (`CHANNEL.iTimeOut := 0;`) on every successful `ADPRW` completion (both register and coil paths).
- Timeout tuning is supplied as `MB_PROCESS_50` inputs (`mb_iTimeoutCount`, `mb_iSuspendRetry`, `mb_iTimeoutTime`). The local `VAR` copies `MB_TIMEOUT_COUNT`, `MB_SUSPEND_RETRY`, `MB_TIMEOUT_TIME` hold the effective values — the input is copied in and, when `0`, the default (`2` / `80` / `4`) is applied. Startup clearing is controlled by `mb_iClearOnStart` with the `MB_CLEAR_ALL` / `MB_CLEAR_BUFFER` / `MB_CLEAR_NONE` constants.
- `iChannelID` is the dedicated current-channel index. Step `1` resets `iChannelID` to `0` and reloads `CHANNEL := MB_CHANNELS[iChannelID]` so the bottom `MB_CHANNELS[iChannelID] := CHANNEL` store always targets the same channel it loaded. This fixes a bug where re-enabling the block mid-run copied a stale channel snapshot into `MB_CHANNELS[0]`. The init-step device zeroing uses a `FOR iCount := 0 TO (iNum - 1)` loop that writes `D0Z3 := 0` / `D0Z4 := 0`. Do not replace it with `FMOV` — in GX Works 2 the `FMOV` transfer-count operand `n` must be a constant, and `iNum` is a channel variable (the compiler rejects it with `C2021`).
- Channel storage: each channel reserves **2 × `iNum`** devices in the `D` (register) or `M` (coil) area — half for values, half for change tracking. Allocate `iDDevNum` so consecutive channels do not overlap (see `Modbus.md`).
- Read-result protection: when a read (`H1`–`H4`) completes, `MB_PROCESS_50` discards the result if the value buffer differs from the change-tracking buffer (a local write happened while the read was in flight). This protection is applied only when the scheduler will actually write that change — `xWriteOnChange = TRUE`, `tCycle > 0`, or a pending `xWriteOnce`. On a manual-only channel (`tCycle = 0`, `xWriteOnChange = FALSE`) with no `xWriteOnce` pending, a completed read resynchronises the change-tracking buffer instead, so a stale difference (e.g. a value register cleared by hand) cannot block `xReadOnce` forever.
- `MB_CHANNELS` and `c_MB_CHANNELS_NUM` are user requirements — declared by the application, not the library. Configure the channel fields once at startup (typically under `M8002`).
- The initialisation functions write Coolmay/Mitsubishi special registers directly (`D8120`, `D8400`, `D8126`, `D8397`, `M8125`, `M8192`, `M8196`, …). These are port-configuration registers — do not rename or re-map them.
- Modbus TCP (L02 Ethernet): a channel with `iPort := MB_PORT_TCP` (`3`) is driven through the L02 built-in Ethernet port. `MB_PROCESS_50` already writes `CHANNEL.iPort` into `D8397` at the start of every request (`D8397 = 3` is what the L02 firmware needs for `ADPRW` over Modbus TCP), so the application must not write `D8397` itself. The application configures the network: `D8395` (`4` = Modbus TCP master/client, `3` = Modbus TCP server/slave; `0`/`5` = EtherNet/IP, `1`/`2` = Modbus UDP), `D8325` (number of remote servers, `1`–`4`), `R23812` (TCP port, default `502`), `M8197` (set by `L02_SET_IP` on every write while its `xInit` input is `TRUE`; the relay resets itself, so the application never writes it and no `ELSE`/release branch exists — the body is level-triggered on purpose, see the Utils `AGENT.md`), `L02_SET_IP` + `IP_*` constants from Utils (IP registers `R23800`/`R23802`/`R23807`/`R23830`/`R23840`/`R23850`/`R23860`). For the server role the library provides `MB_SLAVE_INIT_TCP(xInit, iTcpPort)`: on the rising edge of `xInit` it writes `R23812` (when `iTcpPort > 0`) and sets `D8395 := 3`; it is edge-triggered like the RS485 init functions, so re-trigger it from `M8013` in the same way. For the master role `MB_MASTER_INIT_TCP(xInit, iTcpPort, iServers)` writes `R23812`, `D8325` (`iServers` clamped to `1`–`4`) and `D8395 := 4` while `xInit` is `TRUE`; it does **not** touch `M8197`, so the values are applied by the `L02_SET_IP` call that follows it in the same scan — document the call order as master-init first, IP writes last. Neither function touches `MB_CHANNELS`, so no channel entry is needed for either role. No `MB_CHANNELS` entry and no `MB_PROCESS_50` call are involved in the server role. Status: `M8193` network ready, `M8395` connection flag, `M8062` Modbus timeout, `M8063` IP conflict, `R23815`/`R23816` TX/RX packet counters. For a TCP channel `iDev` is the remote server index (`1`–`4`, matching `IP_REMOTE1`…`IP_REMOTE4`), not an RS485 station address; `iNum` is unaffected. `MB_PORT_SETTINGS`, `MB_MASTER_INIT_PORT2`/`PORT3` are not used for TCP channels (no serial settings), and `MB_MASTER_INIT_*`/`M8013` re-triggering is unnecessary. Platform requirement: L02-series PLC with the built-in Ethernet interface (`M8193`); RS485-only models cannot use `MB_PORT_TCP`.
- EtherNet/IP scanner (`EIP_*`, this library): `EIP_INIT(xInit, iModules)` writes `D8395 := 0` and clamps `iModules` to `1`–`4` into `D8325` while `xInit` is `TRUE`; it returns `xInit` and never touches `M8197` — the configuration is applied by the `L02_SET_IP` call (Utils) of the same scan, so the call order is `EIP_INIT` → `EIP_INIT_REMOTE` (×4) → `L02_SET_IP` (IP addresses). Pass a one-scan trigger (`M8002`, `MEP` of an HMI pulse); never `TRUE`. Do not write `D8325`/`D8395` from the application while it is used.
- `D8395` is a single protocol selector for the port: `0` = EtherNet/IP scanner, `3` = Modbus TCP server, `4` = Modbus TCP client. The EtherNet/IP scanner and the Modbus TCP roles are mutually exclusive — whichever POU runs last in a scan wins, so configure only one role per project. `PRG_MB_TEST` deliberately calls both (compile coverage only).
- `EIP_INIT_REMOTE(iRemote, iDI, iDO, iAI, iAO)` has **no** trigger input and writes on every call — place it in `PRG_INIT` (M8002 execution condition) or gate the call with a one-scan pulse. Its body is an explicit `CASE iRemote OF` with integer labels `1`–`4` (named CASE labels are not allowed in GX Works 2) and literal R registers — `R23834`/`R23844`/`R23854`/`R23864` (DI), `R23835`/…/`R23865` (AI), `R23836`/…/`R23866` (DO), `R23837`/…/`R23867` (AO). Keep it that way: no address arithmetic and no index-register (`Z5`/`R0Z5`) access, so a reader sees which device is written without looking up constants. `iRemote` outside `1`–`4` writes nothing. **The register order is DI, AI, DO, AO** — AI precedes DO, unlike the argument order `iDI, iDO, iAI, iAO`. Do not "fix" this: it is the PLC register layout.
- `EIP_INIT_REMOTE` takes **points**, but the coupler registers mix units: DI/DO hold **bytes**, AI/AO hold **words** — `R23834 := (LIMITATION(0, iDI, 512) + 7) / 8;` (8 DI bits per byte, rounded up), `R23836 := (LIMITATION(0, iDO, 512) + 7) / 8;` (DO), `R23835 := LIMITATION(0, iAI, 50);` (AI point = word, written as-is), `R23837 := LIMITATION(0, iAO, 50);` (AO). Do not remove the `+7)/8` conversion on DI/DO — raw point counts make the scanner reserve 8× the bit area; do not add a `* 2` on AI/AO — those registers are word counts, not byte counts. Registers therefore receive `0`–`64` (DI/DO bytes) and `0`–`50` (AI/AO words).
- `EIP_INIT_REMOTE` clamps counts (in points, before the conversion) to the L02 expansion capacity — DI and DO to `0`–`512`, AI and AO to `0`–`50` (`LIMITATION`). The PLC accepts **512 DI + 512 DO** and **50 AI + 50 AO in total** across all couplers; the per-register clamp does not verify the sum, so keep the sum inside the limits by hand.
- `EIP_DI` / `EIP_DO` / `EIP_DO_SET` / `EIP_AI` / `EIP_AO` / `EIP_AO_SET` are the remote I/O accessors: `iRemote` = `EIP_REMOTE1`…`EIP_REMOTE4` (`1`–`4`), `iNum` is **0-based** inside the coupler. Two functions per data type exist because a GX Works 2 function has one fixed return type and cannot be both a `BOOL` and an `INT` accessor. The device is computed as `base + (iRemote - 1) * step + iNum` through the index registers `Z0` (bit areas) and `Z1` (word areas), read/written as `M0Z0` / `R0Z1`. Map: DI `M5000` +200/coupler, DO `M6000` +200, AI `R23100` +50, AO `R23300` +50. Arguments are clamped with `LIMITATION` (`iRemote` 1–4, `iNum` 0–199 for DI/DO, 0–49 for AI/AO) rather than rejected — a call always accesses the nearest valid point, which keeps a mis-indexed write inside the remote I/O area. Do not use `Z0`/`Z1` for application indexing and do not rely on their contents across these calls. The per-coupler block reserves 200 DI / 200 DO / 50 AI / 50 AO while the total capacity is 512/512/50/50, so with three or four couplers the reserved slots exceed capacity.
- Keep `Modbus.md` user-facing: it documents *how to use* the library, not how it works internally. Do not describe the port-selector register write, `ADPRW`/`M8029` handling, watchdog evaluation order, scratch-buffer indexing or the library-managed `MB_REG_50` fields (`tStart`, `iTimeOut`, `isRegister`, `xReadOnceM`, `xWriteOnceM`) there — those belong in this file. IP addresses are documented through `L02_SET_IP` / the `IP_*` constants only; the raw `R2380x` / `R2383x`-`R2386x` registers are Utils implementation detail.
- CSV files are UTF-16LE + BOM, tab-separated, every cell quoted, LF line endings; `.iecst` files use CRLF.

- Edge-detection convention — two kinds of init POU, do not mix them up:
  - **Edge inside the POU** (`IF MEP(xInit) THEN`): `MB_MASTER_INIT_PORT2`/`PORT3`, `MB_SLAVE_INIT_PORT2`/`PORT3`, `MB_SLAVE_INIT_TCP`, `MTB_SLAVE_PORT2`/`PORT3`. The caller passes a plain bit and may re-trigger it from `M8013`.
  - **Edge at the call site** (`IF xInit THEN`, no internal `MEP`): `L02_SET_IP` (Utils) and `MB_MASTER_INIT_TCP`. The caller passes a one-scan pulse: `M8002`, `MEP(xSaveIp)`, or `MEP(xApplyIp)` at the call. Reason: `MEP` keeps one edge detector per instruction and a function body is compiled once, so an internal `MEP` would execute only the first call after the edge and silently skip the remaining settings written in the same scan.

## Test Program (PRG_MB_TEST)

`PRG_MB_TEST` is a compile-and-run example that covers all three channel kinds. It enables interrupts, builds a port bit-field via `MB_PORT_SETTINGS`, and calls every Modbus POU — `MB_MASTER_INIT_PORT2`/`PORT3`, `MB_SLAVE_INIT_PORT2`/`PORT3`, `MB_SLAVE_INIT_TCP`, `MB_MASTER_INIT_TCP` and `MTB_SLAVE_PORT2`/`PORT3` — so a compile exercises every function and block (re-triggered every second by the `M8013` clock). The port-initialisation calls intentionally overlap on the same ports (master + slave + Mitsubishi protocol) and do not make logical sense together; they exist for compile/debug coverage only. Under the `M8002` pulse it configures three channels (timeout and clear-on-start tuning are passed to `fbMbProcess`):

- **Channel 0** — register, automatic read/write (device 1, port 2, `tCycle = 20`).
- **Channel 1** — register, read-only, on demand (device 2, port 3, `tCycle = 0`, read via `xReadOnce`).
- **Channel 2** — coils, read/write (device 3, port 2, `tCycle = 10`).

It calls `fbMbProcess` every scan and demonstrates an on-demand read (channel 1) and write-on-change (channels 0 and 2). Channel storage (`MB_CHANNELS`, `c_MB_CHANNELS_NUM`) is declared in `GVL_MB_TEST.csv` — that is the only project-side label list the program needs. The demo writes target the device buffers directly (`D600 := 1234;`, `M500 := NOT M500;`) instead of the `g_iAutoReg*` / `g_xCoil*` alias labels, because those aliases are a monitoring convenience and referencing them made the whole program fail to compile (C1028) whenever that optional list was missing or stale. `GVL_MB_TEST.csv` still declares them (device-assigned to the same `D600`/`D610`/`M500` areas).

`PRG_MB_TEST` also hosts the **L02 Ethernet / EtherNet/IP setup** — the `EIP_*` functions of this library plus `L02_SET_IP` from Utils: `EIP_INIT(M8002, 2)` (`D8395 := 0`, `D8325 := 2`), `EIP_INIT_REMOTE(EIP_REMOTE1, 8, 8, 4, 2)` (points → `R23834 = 1` byte, `R23836 = 1` byte, `R23835 = 4` words, `R23837 = 2` words) and `L02_SET_IP(M8002, IP_PLC_IP, 192, 168, 0, 100)` (writes `R23807`/`R23808`, sets `M8197`), followed by one call of each remote-I/O accessor (`EIP_DI`, `EIP_DO`, `EIP_AI`, `EIP_AO`, `EIP_DO_SET`, `EIP_AO_SET` → `M5000`, `M6205`, `R23102`, `R23400`). Rationale: the L02 Ethernet port belongs to the Modbus TCP/RTU test program, not to the Utils smoke test, so all Ethernet setup sits in one place. Compiling `PRG_MB_TEST` therefore requires the **Utils** library and its `IP_PLC_IP` constant (for `L02_SET_IP`) — a cross-library dependency of the *test program only*; the `EIP_REMOTE*` selectors come from this library's `GVL_MB`. The Utils and ModbusDriver `EIP_*` functions are separated by ownership of the L02 port: IP addresses → Utils, EtherNet/IP scanner and remote I/O → this library. Two deliberate overlaps, documented in the program header: the Modbus TCP initialisation overwrites `D8395` in the same scan (the modes are mutually exclusive), and `EIP_DO_SET`/`EIP_AO_SET` drive real remote outputs.
