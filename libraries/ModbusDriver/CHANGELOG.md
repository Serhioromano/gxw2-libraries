# Changelog

## V7 — 2026-08-13

- **Storage model:** Channel storage is no longer reserved by the library. Removed `MB_CHANNELS` from `GVL_MB.csv`. The application must now declare the `MB_CHANNELS` array and the compile-time capacity constant `c_MB_CHANNELS_NUM` (upper bound, last valid index) in its project's global label list, sized to its requirements — the library references them directly.
- **Code:** `MB_PROCESS_50.st` now cycles through `c_MB_CHANNELS_NUM` instead of a hardcoded `29`: the two initialisation `FOR iIndex := 0 TO 29 DO` loops and the next-channel wrap `IF (iCount = 29) THEN` now use `c_MB_CHANNELS_NUM`. Added a header comment explaining the user-declared dependency.
- **CSV:** Updated the `iCount` comment in `MB_PROCESS_50.csv` to reference `c_MB_CHANNELS_NUM`.
- **Test program:** Added `GVL_MB_TEST.csv` declaring `c_MB_CHANNELS_NUM := 2` and `MB_CHANNELS : ARRAY [0..2] OF MB_REG_50` for `PRG_MB_TEST`.
- **Documentation:** Updated `Modbus.md` (prerequisites, architectural description, `MB_PROCESS_50` section, complete example) and `README.md` (user requirements).

## V6 — 2026-08-13

- **Comments:** Added descriptive English comments to every variable in all POU CSV files (`GVL_MB.csv`, `MB_MASTER_INIT_PORT2.csv`, `MB_MASTER_INIT_PORT3.csv`, `MB_PORT_SETTINGS.csv`, `MB_PROCESS_50.csv`, `MB_SLAVE_INIT_PORT2.csv`, `MB_SLAVE_INIT_PORT3.csv`, `MTB_SLAVE_PORT2.csv`, `MTB_SLAVE_PORT3.csv`, `PRG_MB_TEST.csv`, `ST_MB_REG_50.csv`). Corrected typos in existing comments (`Whatchgog`, `incriments`, `suspention`, `adderss`, `addesss`, `memmory`, `rised ende`). No variable names, types, or logic changed.
- **Documentation:** Added `README.md` (developer notes). Documented the previously undocumented `MTB_SLAVE_PORT2` / `MTB_SLAVE_PORT3` port-reconfiguration functions and added a consolidated global-constants table to `Modbus.md`.

## V5 — 2025-04-09

- **Added:** `xWriteOnce` property for channels.

## V4 — 2025-04-09

- **Added:** Automatic clearing of all registers allocated for data storage prior to the first read cycle.
- **Added:** `xDone` property for channels. Emits a pulse upon completion of one read/write cycle.

## V3 — 2025-02-28

- **Fixed:** Bug in which the connection was not restored after a timeout. (Reported by Alex_315.)

## V2 — 2024-12-12

- **Changed:** The `iReg` property of a channel now accepts `Word[Unsigned]` / `Bit String[16-bit]` types, enabling register addresses greater than 32,000.
- **Added:** Port constants `MB_PORT_2`, `MB_PORT_3`, `MB_PORT_CAN`, and `MB_PORT_TCP` for the `iPort` channel property.

## V1 — 2024-09-29

- **Changed:** Device area for data storage switched from `R` to `D` registers, because certain HMI panels (e.g., the OP320 series) do not expose `R` registers over the Modbus protocol.

## V0 — 2024-09-22

- Initial release.
