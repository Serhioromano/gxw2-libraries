# Changelog

## V3 — 2026-08-13

- **Naming:** All functions now use the `F_` prefix consistently in code:
  - `F_MIN_TO_TIME` (was `MIN_TO_TIME`)
  - `F_SEC_TO_TCO_50` (was `SEC_TO_TCO_50`)
  - `F_SEC_TO_TIME` (was `SEC_TO_TIME`)
  - `F_TCO_50_TO_100MS` (was `TCO_50_TO_100MS`)
  - `F_TCO_50_TO_MIN` (was `TCO_50_TO_MIN`)
  - `F_TCO_50_TO_MS` (was `TCO_50_TO_MS`)
  - `F_TCO_50_TO_SEC` (was `TCO_50_TO_SEC`)
  - `FB_TCO_50_BLINK` now calls `F_TCO_50_DIFF` (was `TCO_50_DIFF`)
- **Bugfix:** `F_TCO_50_TO_SEC` wrote its result to `TCO_50_TO_MIN` (copy-paste error). It now assigns to `F_TCO_50_TO_SEC`.
- **CSV:** All variables renamed to Hungarian-prefixed camelCase and documented:
  - Function inputs: `MINUTES` → `iMinutes`, `SECS`/`SECONDS` → `iSeconds`, `TICKER` → `dwTicker`; `F_TCO_50_DIFF` inputs `Current`/`TICKER` → `dwStart`/`dwCurrent` (argument order `(start, current)`, result `current - start`).
  - `FB_TCO_50_BLINK`: `IN` → `xIn`, `TIMELOW` → `dwTimeLow`, `TIMEHIGH` → `dwTimeHigh`, `Q` → `xQ`, `INM` → `xInMem`, `tStart` → `dwStart`, `tTotal` → `dwTotal`.
  - Fixed wrong label classes: `F_MIN_TO_TIME` and `F_SEC_TO_TIME` inputs were `VAR`, now `VAR_INPUT`.
  - Removed the stale `TCO_INT_50 global variable` comment from `F_TCO_50_DIFF`.
  - Added comments to every row of `GVL_TCO.csv` and to all FB/function/program CSV files.
- **Code simplification:** `F_TCO_50_TO_SEC`, `F_TCO_50_TO_MIN`, `F_TCO_50_TO_100MS` no longer use `DDIV` + temporary array + `SEL`; they use native DINT division (`DWORD_TO_DINT(dwTicker) / n`). The temporary `ARRAY [0..1] OF DINT` local was removed from the CSVs. `F_TCO_50_TO_MS` uses native DINT multiplication.
- **Return types (set in the GX Works 2 POU properties, not visible in CSV):** `F_TCO_50_TO_SEC`, `F_TCO_50_TO_MIN`, `F_TCO_50_TO_100MS` return INT; `F_TCO_50_TO_MS` returns DINT; `F_TCO_50_DIFF` returns DWORD; `F_MIN_TO_TCO_50`/`F_SEC_TO_TCO_50` return DWORD; `F_MIN_TO_TIME`/`F_SEC_TO_TIME` return TIME. `F_TCO_50_TO_100MS` now returns INT consistently with the documented family contract.
- **Test program:** `PRG_TEST_TCO_50` rewritten to reference the current API (`FB_TCO_50_BLINK`, `F_TCO_50_*`). Removed references to the deleted `DTCO_*` functions, the `TCO_INT_50` global and the `TCO_50_TON128` FB.
- **Left unchanged:** `FB_TCO10` is a broken legacy function block (reads `D8010` = current scan time in 0.1 ms units, not a 10 ms ticker). It is superseded by `PRG_TCO_TICKER_10` + `TCO_DINT_10` and was left untouched by maintainer decision — do not rely on it.
