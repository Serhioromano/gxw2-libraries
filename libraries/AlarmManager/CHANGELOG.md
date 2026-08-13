# Changelog

## V212 — 2026-08-13

- **Comments:** Added a header (POU purpose and I/O mapping) and inline comments to `FB_AM_BUZZER.st` explaining the count scan, the edge latch on `Q`, and the one-scan `Reset` pulse. No logic changed.
- **CSV:** Corrected the `Q` output comment in `FB_AM_BUZZER.csv` — `Q` is latched until `Reset`, not a single pulse.
- **Documentation:** Fixed the `FB_AM_BUZZER` description and example in `AlarmManager.md` (`Q` latches until `Reset`; ST call uses `:=` for the output) and the `FB_AM_BUZZER` summary line in `README.md`.

## V211 — 2026-08-13

- **Removed:** The `F_AM_MOVE_TO_M` function (files `F_AM_MOVE_TO_M.st` / `.csv` deleted). It wrapped the `BMOV` instruction to copy packed `D` data to `M` bits; since V209 the pack blocks (`FB_AM_PACK_ALARMS`, `FB_AM_PACK_EVENTS`) write directly to the `M` area with `PD := c_AM_PACK_M`, so the helper is no longer needed. Applications that still pack to `D` registers can use the raw `BMOV` instruction (see the HMI Compatibility Note in `FB_AM_PACK_ALARMS`).
- **Documentation:** Removed the `F_AM_MOVE_TO_M` summary-table row and detail section from `AlarmManager.md`; removed it from the file structure and POU naming list in `README.md`.

## V210 — 2026-08-13

- **Test program:** Extended `PRG_AM_TEST` with event examples. The smoke test now registers four events (IDs 0..3) under manual test inputs: two high-level events (`EventLatch := FALSE`), one latched positive-edge event (`EventLatch := TRUE`), and one positive-edge event. It exercises `FB_AM_EV`, `FB_AM_EVENT_RESET` (manual `xEventReset` input) and `FB_AM_PACK_EVENTS`, packing event states to `D6100` and directly to `M6100..M6105` via `PD := c_AM_PACK_M`. Unused event slots 4..5 are read back to demonstrate that they stay `0`.
- **CSV:** Added the event FB instances, condition/reset inputs, and packed read-back labels to `PRG_AM_TEST.csv`; updated the `c_AM_EVENTS_NUM` comment in `GVL_AM_TEST.csv` (events are now exercised by the smoke test).
- **Documentation:** Updated `AlarmManager.md` (abstract, test-program section) and `README.md`.

## V209 — 2026-08-13

- **Feature:** `FB_AM_PACK_ALARMS` and `FB_AM_PACK_EVENTS` can now pack directly into `M` bit devices. New global constant `c_AM_PACK_M` (value `2`) in `GVL_AM.csv`; passing `PD := c_AM_PACK_M` writes each alarm/event state to its own `M` bit (`M(DNUM + n)` for ID `n`) instead of `D`/`R` registers. The `D`/`R` write branch was changed from `ELSE` to `ELSIF` so an unrecognised `PD` value writes nothing.
- **Code:** In `PD := c_AM_PACK_M` mode the pack blocks write each bit directly to its `M` device in a single `WHILE` loop; they no longer assemble the packed word (`wTemp` / `SRB`) and no longer update the debug array `arTW` — those remain in `D`/`R` mode only, where `arTW` still holds the packed register words for monitoring.
- **CSV:** Added `c_AM_PACK_M` to `GVL_AM.csv`; updated the `PD` comments in `FB_AM_PACK_ALARMS.csv` and `FB_AM_PACK_EVENTS.csv`.
- **Documentation:** Updated `AlarmManager.md` (pack sections, HMI compatibility note, abstract) and `README.md`.

## V208 — 2026-08-13

- **Code:** `FB_AM_PACK_ALARMS.st` and `FB_AM_PACK_EVENTS.st` now guard the inner packing loop. Before reading `AM_ALARMS[iTCounter]` / `AM_EVENTS[iTCounter]` the code checks `iTCounter` against `c_AM_ALARMS_NUM` / `c_AM_EVENTS_NUM` and exits the loop as soon as all alarms/events have been packed (remaining bits of the last register stay `0`). This removes the previous requirement that the array length be a multiple of 16 and guarantees array access never exceeds the declared upper bound, so packing is safe for any user-declared array length.
- **Documentation:** Updated the `FB_AM_PACK_ALARMS` / `FB_AM_PACK_EVENTS` sections of `AlarmManager.md` (removed the multiple-of-16 constraint notes), the test-program note, and `README.md`.

## V207 — 2026-08-13

- **Removed:** The `F_AM_ISON` function (files `F_AM_ISON.st` / `.csv` deleted). The state of a single alarm is now read directly from the global array: `AM_ALARMS[iNum].Alarm`.
- **Code:** `FB_AM_ORISON.st` now ORs `AM_ALARMS[iNum].Alarm` directly instead of calling `F_AM_ISON` (function blocks may access global variables; functions may not, which was the only reason the function existed).
- **Test program:** `PRG_AM_TEST.st` reads alarm states via direct array access and no longer lists `F_AM_ISON` in the header comment.
- **Documentation:** Removed the `F_AM_ISON` section and the summary-table row from `AlarmManager.md`; updated the `FB_AM_ORISON` description and `README.md`.

## V206 — 2026-08-13

- **Storage model:** Alarm/event storage is no longer reserved by the library. Removed `AM_ALARMS`, `AM_EVENTS`, `AM_ALARMS_NUM`, `AM_EVENTS_NUM` from `GVL_AM.csv`. The application must now declare these in its project's global label list, sized to its requirements: the arrays `AM_ALARMS` / `AM_EVENTS` and the compile-time capacity constants `c_AM_ALARMS_NUM` / `c_AM_EVENTS_NUM` (with the `c_` prefix, per the V203 convention).
- **Code:** Event scan loops in `FB_AM_EVENT_RESET.st` and `FB_AM_PACK_EVENTS.st` now use `c_AM_EVENTS_NUM` (was `AM_EVENTS_NUM`) for symmetry with the alarm constants.
- **F_AM_ISON:** Fixed the return assignment: `F_AM_ISON := ALMS[iNum].Alarm;` (the function name was missing the `F_` prefix).
- **CSV comments:** Updated range/array comments in `FB_AM_INIT.csv`, `FB_AM_SET.csv`, `FB_AM_EV.csv`, `FB_AM_PACK_EVENTS.csv`, `F_AM_ISON.csv` to reference the capacity constants.
- **Documentation:** Rewrote the Prerequisites section of `AlarmManager.md` (user-declared storage requirements), updated affected FB sections, and updated `README.md`.
- **Test program:** Reworked `PRG_AM_TEST` so it compiles and runs against the V206 library: storage moved from program-local rows into the new global list `GVL_AM_TEST.csv` (`VAR_GLOBAL` / `VAR_GLOBAL_CONSTANT`), stale names updated (`FB_AM_RST` → `FB_AM_RESET`, `FB_AM_PACK` → `FB_AM_PACK_ALARMS`, `AM_WARNING`/`AM_ERROR` → `c_AM_*`), alarm array sized to 16 slots (`c_AM_ALARMS_NUM = 15`) so `FB_AM_PACK_ALARMS` stays in bounds, `BMOV` count corrected from 8 to 1, raw devices replaced with commented auto-assigned labels (no explicit device bindings), and `fbAMOsIsOn` renamed to `fbAMOrIsOn`.

## V205 — 2026-08-13

- **Comments:** Added descriptive English comments to every variable in all POU CSV files (`FB_AM_*.csv`, `F_AM_*.csv`, `ST_AM_*.csv`, `GVL_AM.csv`). Comments were derived from the ST code and the AlarmManager documentation; no variable names, types, or logic changed.

## V204 — 2026-01-14

- **Renamed:** All POU source files now follow the standard prefix convention: `FB_` for function blocks, `F_` for functions. Files renamed: `AM_INIT` → `FB_AM_INIT`, `AM_SET` → `FB_AM_SET`, `AM_ISON` → `F_AM_ISON`, `AM_ORISON` → `FB_AM_ORISON`, `AM_RESET` → `FB_AM_RESET`, `AM_IS_BLOCK` → `FB_AM_IS_BLOCK`, `AM_HAS_ALARMS` → `FB_AM_HAS_ALARMS`, `AM_BUZZER` → `FB_AM_BUZZER`, `AM_EV` → `FB_AM_EV`, `AM_EVENT_RESET` → `FB_AM_EVENT_RESET`, `AM_PACK_ALARMS` → `FB_AM_PACK_ALARMS`, `AM_PACK_EVENTS` → `FB_AM_PACK_EVENTS`, `AM_DELAY_OUT` → `F_AM_DELAY_OUT`, `AM_MOVE_TO_M` → `F_AM_MOVE_TO_M`. Structure files renamed: `AM_ALARM.csv` → `ST_AM_ALARM.csv`, `AM_EVENT.csv` → `ST_AM_EVENT.csv`. GVL renamed: `AM.csv` → `GVL_AM.csv`.
- **Cross-references:** Updated all internal POU calls to use prefixed names (`AM_ISON` → `F_AM_ISON`, `AM_DELAY_OUT` → `F_AM_DELAY_OUT`).
- **Documentation:** README.md and AlarmManager.md updated to reflect new naming.

## V203 — 2026-01-13

- **Renamed:** All global constants prefixed with `c_` (with underscore): `AM_ERROR` → `c_AM_ERROR`, `AM_WARNING` → `c_AM_WARNING`, `AM_INFO` → `c_AM_INFO`, `AM_PACK_D` → `c_AM_PACK_D`, `AM_PACK_R` → `c_AM_PACK_R`. Updated in `AM.csv` and all references in `AlarmManager.md`.
- **Documentation:** Added comments to all global variables in `AM.csv` (severity constants, alarm/event arrays, count variables, and pack target constants).
