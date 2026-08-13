# Changelog

## V204 — 2026-01-14

- **Renamed:** All POU source files now follow the standard prefix convention: `FB_` for function blocks, `F_` for functions. Files renamed: `AM_INIT` → `FB_AM_INIT`, `AM_SET` → `FB_AM_SET`, `AM_ISON` → `F_AM_ISON`, `AM_ORISON` → `FB_AM_ORISON`, `AM_RESET` → `FB_AM_RESET`, `AM_IS_BLOCK` → `FB_AM_IS_BLOCK`, `AM_HAS_ALARMS` → `FB_AM_HAS_ALARMS`, `AM_BUZZER` → `FB_AM_BUZZER`, `AM_EV` → `FB_AM_EV`, `AM_EVENT_RESET` → `FB_AM_EVENT_RESET`, `AM_PACK_ALARMS` → `FB_AM_PACK_ALARMS`, `AM_PACK_EVENTS` → `FB_AM_PACK_EVENTS`, `AM_DELAY_OUT` → `F_AM_DELAY_OUT`, `AM_MOVE_TO_M` → `F_AM_MOVE_TO_M`. Structure files renamed: `AM_ALARM.csv` → `ST_AM_ALARM.csv`, `AM_EVENT.csv` → `ST_AM_EVENT.csv`. GVL renamed: `AM.csv` → `GVL_AM.csv`.
- **Cross-references:** Updated all internal POU calls to use prefixed names (`AM_ISON` → `F_AM_ISON`, `AM_DELAY_OUT` → `F_AM_DELAY_OUT`).
- **Documentation:** README.md and AlarmManager.md updated to reflect new naming.

## V203 — 2026-01-13

- **Renamed:** All global constants prefixed with `c_` (with underscore): `AM_ERROR` → `c_AM_ERROR`, `AM_WARNING` → `c_AM_WARNING`, `AM_INFO` → `c_AM_INFO`, `AM_PACK_D` → `c_AM_PACK_D`, `AM_PACK_R` → `c_AM_PACK_R`. Updated in `AM.csv` and all references in `AlarmManager.md`.
- **Documentation:** Added comments to all global variables in `AM.csv` (severity constants, alarm/event arrays, count variables, and pack target constants).
