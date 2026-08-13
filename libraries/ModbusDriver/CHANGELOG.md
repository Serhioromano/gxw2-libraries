# Changelog

## V7 — 2026-08-13

- **Storage model:** Channel storage is no longer reserved by the library. Removed `MB_CHANNELS` from `GVL_MB.csv`. The application must now declare the `MB_CHANNELS` array and the compile-time capacity constant `c_MB_CHANNELS_NUM` (upper bound, last valid index) in its project's global label list, sized to its requirements — the library references them directly.
- **Code:** `MB_PROCESS_50.st` now cycles through `c_MB_CHANNELS_NUM` instead of a hardcoded `29`: the two initialisation `FOR iIndex := 0 TO 29 DO` loops and the next-channel wrap `IF (iCount = 29) THEN` now use `c_MB_CHANNELS_NUM`. Added a header comment explaining the user-declared dependency.
- **CSV:** Updated the `iCount` comment in `MB_PROCESS_50.csv` to reference `c_MB_CHANNELS_NUM`.
- **Test program:** Added `GVL_MB_TEST.csv` declaring `c_MB_CHANNELS_NUM := 2` and `MB_CHANNELS : ARRAY [0..2] OF MB_REG_50` for `PRG_MB_TEST`.
- **Test program (revision):** Rewrote `PRG_MB_TEST` to cover all three channel kinds — register automatic read/write (channel 0), register on-demand read-only (channel 1), coils read/write (channel 2). Renamed locals (`Port` → `dwPortSettings`), replaced the undeclared `reg1`–`reg4` with declared global value labels (`g_iAutoReg*`, `g_iDemandReg*`, `g_xCoil*`) in `GVL_MB_TEST.csv`, re-trigger master initialisation with `M8013`, and removed the redundant hard-coded `Port := 2#…` line.
- **Documentation:** Updated `Modbus.md` (prerequisites, architectural description, `MB_PROCESS_50` section, complete example) and `README.md` (user requirements).
- **Documentation (revision):** Rewrote and corrected `Modbus.md`. Fixed the port-numbering contradiction between the "Ports" and "Supported Ports" tables (port 2 = terminal, port 3 = DB9). Corrected `mb_iBuffer` (always `D` space) and `mb_Timeout` (returns the slave `iDev`) descriptions. Normalised type names to IEC (`BOOL`/`INT`/`WORD`/`DWORD`), corrected `PortSettings` from signed to unsigned, and normalised the structure type name to `MB_REG_50` (the `ST_MB_REG_50` string is only the source-file name). Documented the full `MB_REG_50` structure (user-configurable vs library-managed fields), the fixed 8-data-bit behaviour of `MB_PORT_SETTINGS`, and that `xWriteOnce`/`xWriteOnChange` require `iWR = MB_READ_WRITE` or `MB_WRITE`. Fixed the Complete Example (channel 2 now `MB_READ_WRITE`, added `fbMbProcess`/`PortSettings` declarations, moved the alternative write-confirmation into its own block). No code changes.
- **Documentation:** Added an initialisation-timing note to `MB_MASTER_INIT_PORT2/3` (cross-referenced from the slave functions): the functions are edge-triggered, so constant re-initialisation is not required, but a first-scan-only (`M8002`) trigger may not persist because the port settings can be overwritten during startup. Recommended re-triggering with the 1 s clock `M8013`; updated the examples and the Complete Example accordingly.

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
