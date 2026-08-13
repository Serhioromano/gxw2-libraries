# Changelog

## V1.6 — 2026-08-13

- **Comments:** Added descriptive English comments to every variable in all POU CSV files (`GVL_MB.csv`, `MB_MASTER_INIT_PORT2.csv`, `MB_MASTER_INIT_PORT3.csv`, `MB_PORT_SETTINGS.csv`, `MB_PROCESS_50.csv`, `MB_SLAVE_INIT_PORT2.csv`, `MB_SLAVE_INIT_PORT3.csv`, `MTB_SLAVE_PORT2.csv`, `MTB_SLAVE_PORT3.csv`, `PRG_MB_TEST.csv`, `ST_MB_REG_50.csv`). Corrected typos in existing comments (`Whatchgog`, `incriments`, `suspention`, `adderss`, `addesss`, `memmory`, `rised ende`). No variable names, types, or logic changed.
- **Documentation:** Added `README.md` (developer notes). Documented the previously undocumented `MTB_SLAVE_PORT2` / `MTB_SLAVE_PORT3` port-reconfiguration functions and added a consolidated global-constants table to `Modbus.md`.

## V1.5 — 2025-04-09

- **Added:** `xWriteOnce` property for channels.

## V1.4 — 2025-04-09

- **Added:** Automatic clearing of all registers allocated for data storage prior to the first read cycle.
- **Added:** `xDone` property for channels. Emits a pulse upon completion of one read/write cycle.

## V1.3 — 2025-02-28

- **Fixed:** Bug in which the connection was not restored after a timeout. (Reported by Alex_315.)

## V1.2 — 2024-12-12

- **Changed:** The `iReg` property of a channel now accepts `Word[Unsigned]` / `Bit String[16-bit]` types, enabling register addresses greater than 32,000.
- **Added:** Port constants `MB_PORT_2`, `MB_PORT_3`, `MB_PORT_CAN`, and `MB_PORT_TCP` for the `iPort` channel property.

## V1.1 — 2024-09-29

- **Changed:** Device area for data storage switched from `R` to `D` registers, because certain HMI panels (e.g., the OP320 series) do not expose `R` registers over the Modbus protocol.

## V1.0 — 2024-09-22

- Initial release.
