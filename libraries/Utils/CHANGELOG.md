# Changelog

## V5 — 2026-08-20

- **Documentation:** Rewrote `Utils.md` to follow the library documentation structure (title, abstract, prerequisites, terminology, architectural description, summary table, per-POU detail sections, conceptual sections).
- **Added:** Documented the previously missing functions `F_LIMIT`, `F_FLT10`, `F_MBMOV` and `F_VALVE_POS`, and completed the `F_DSCALE` section (it was previously listed only by name).
- **Documentation:** Updated every POU name and variable table to the V4 `F_`/`FB_` prefixed names and Hungarian-prefixed camelCase variables; updated all examples accordingly (positional arguments for functions, named arguments for FBs).
- **Documentation:** Fixed the `F_SCALE_NL` graph image reference (`./img/2023-12-17_15-40-23.png`).

## V4 — 2026-08-20

- **Renamed:** All POU source files now follow the standard prefix convention (`F_` for functions, `FB_` for function blocks):
  - Functions: `ISBON` → `F_ISBON`, `DISBON` → `F_DISBON`, `SETB` → `F_SETB`, `DSETB` → `F_DSETB`, `RSTB` → `F_RSTB`, `DRSTB` → `F_DRSTB`, `SRB` → `F_SRB`, `DSRB` → `F_DSRB`, `LIMIT` → `F_LIMIT`, `SCALE` → `F_SCALE`, `SCALE_NL` → `F_SCALE_NL`, `INCN` → `F_INCN`, `SHFT` → `F_SHFT`, `WORK_LEFT` → `F_WORK_LEFT`, `WORK_LEFT_TIME` → `F_WORK_LEFT_TIME`, `VALVE_POS` → `F_VALVE_POS`, `FLT10` → `F_FLT10`, `MBMOV` → `F_MBMOV`, `L02_SET_IP` → `F_L02_SET_IP`.
  - Function blocks: `HYST` → `FB_HYST`, `HYST_COOL` → `FB_HYST_COOL`, `SCALE_AI` → `FB_SCALE_AI`, `L02_SCALE_AI` → `FB_L02_SCALE_AI`, `VALVE_3P` → `FB_VALVE_3P`.
- **Variables:** Renamed all FB/FUN inputs, outputs and locals to Hungarian-prefixed camelCase and updated every `.iecst` body to match (`IN` → `dwIn`/`wIn`, `BN` → `iBN`, `tmp` → `dwTmp`/`wTmp`/`xTmp`, `MAX`/`MIN` → `iMax`/`iMin`, `Q` → `xQ`, `ValueOut` → `iValueOut`, `ENABLE` → `xEnable`, `TOTAL_TIME` → `tTotalTime`, `fbTPZero` → `fbTpZero`, `tTimeStart` → `dwTimeStart`, `diTemp` → `dwTemp`, etc.).
- **Comments:** Added descriptive English comments to every variable in all POU CSV files (`F_*.csv`, `FB_*.csv`). Replaced the corrupted (mojibake) comments in `FB_L02_SCALE_AI.iecst` with English.
- **Added:** `F_DSCALE` — the DINT version of `F_SCALE` (scales a DINT value between two DINT ranges). Inputs: `diVal`, `diInLow`, `diInHigh`, `diOutLow`, `diOutHigh`; returns DINT.
- **Code:** Fixed internal cross-references to use prefixed names (`LIMIT` → `F_LIMIT`, `SCALE` → `F_SCALE`, `VALVE_POS` → `F_VALVE_POS`). `F_WORK_LEFT_TIME` and `F_VALVE_POS` now call `F_DSCALE` instead of the previously unresolved `DSCALE`.
- **Test program:** Added `PRG_UTL_TEST` — a smoke test that calls every function and function block of the library with representative inputs; results are stored in auto-assigned labels for the device monitor. Function calls use positional arguments; FB calls use named arguments.

## V3 — 2026-06-01

- **Added:** `INCN` and `SHFT` functions.
