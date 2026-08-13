# Changelog

## V8 — 2026-08-13

- **Fixed compile error C9172:** the test-program TIME labels `t1`, `t2`, `t3` collided with the timer device names `T1`–`T3` (GX Works 2 rejects labels that are a lowercased device name). Renamed to `tSec`, `tMin`, `tTicker` in `PRG_TEST_TCO_50.st` / `.csv`.
- **Converters aligned:** all `F_TCO_50_TO_*` converters now convert the 32-bit `dwQuot` result with the `DWORD_TO_*` conversions (`DWORD_TO_INT` for SEC/100MS/MIN, `DWORD_TO_DINT` for MS, `DWORD_TO_TIME` for TIME) instead of indexed `dwQuot[0]` access — consistent with the `DWORD_TO_INT(dwQuot)` / `DWORD_TO_TIME(dwQuot)` form used in `F_TCO_50_TO_SEC` / `F_TCO_50_TO_TIME`.

## V7 — 2026-08-13

- **Test program:** `PRG_TEST_TCO_50` now covers every POU of the library: all 11 conversion/difference functions and both function blocks (`FB_TCO_50_BLINK`, `FB_TCO10`). The blink FB durations are fed from the DWORD converter outputs (`F_SEC_TO_TCO_50`/`F_MIN_TO_TCO_50`) instead of raw literals, so the FB input types are exercised correctly; `F_TCO_50_DIFF` is tested with a `MEP`-triggered save point; `FB_TCO10` is tested with a reset input and both DINT outputs. New CSV labels: `xCapture`, `fbTco10`, `xResetTco`, `diMs10`, `di01ms10`.
- **Documentation:** updated the test-program entry in `README.md`.

## V6 — 2026-08-13

- **Fixed (breaking, code only):** `F_TCO_50_TO_SEC`, `F_TCO_50_TO_100MS`, `F_TCO_50_TO_MIN`, `F_TCO_50_TO_MS`, `F_TCO_50_TO_TIME` no longer use native ST operators (`+`, `/`) or `DWORD_TO_DINT` conversion on the ticker. Native operators do not work on `DWORD` in GX Works 2 ST, and converting the `DWORD` ticker to `DINT` corrupts values above 2³¹ (loses half the range). The converters now use the 32-bit arithmetic instructions on the raw `DWORD` value: `DDIV` for the division converters (SEC/100MS/MIN) and `DMUL` for the multiplication converters (MS/TIME). `F_TCO_50_DIFF` already used `DSUB` and is unchanged.
- **CSV:** each converter again declares the `dwQuot` temporary (`ARRAY [0..1] OF DINT`) that holds the 32-bit instruction result; the input `dwTicker` (DWORD) is unchanged.
- **Behavior:** the computation now stays correct for the full `DWORD` ticker range (~6.8 years at 50 ms). The output range limits are unchanged (they come from the documented return types: SEC/100MS/MIN → INT, MS → DINT, TIME → TIME).
- **Documentation:** updated the arithmetic notes in `README.md` and `TimeControl.md`.

## V5 — 2026-08-13

- **Fixed:** `FB_TCO10` rewritten. It is now an elapsed-time accumulator based on `D8010` (current scan time in 0.1 ms units) with a `xReset` BOOL input that holds the accumulator at 0 while TRUE, a `diMs` DINT output (elapsed time in milliseconds, `diTicks / 10`) and a `di01ms` DINT output (elapsed time in raw 0.1 ms units). The old body (`iCounter := D8010 + iCounter`) accumulated into a 16-bit INT with no reset and no typed output; the CSV gained `xReset`, `diMs`, `di01ms` and the `wScan`/`diTicks` locals.
- **Caveat:** the FB measures elapsed time by summing the scan time each scan — it approximates wall-clock time and misses time spent in interrupt tasks. It is an alternative to the interrupt-driven `PRG_TCO_TICKER_10`/`TCO_DINT_10` ticker for projects without interrupt tasks.
- **Documentation:** added `FB_TCO10` to the summary table and a detail section in `TimeControl.md`; updated the file-structure entry in `README.md`.

## V4 — 2026-08-13

- **Feature:** Added `F_MIN_TO_SEC` — converts minutes to seconds; returns INT. Formula: `iMinutes * 60` (computed in DINT, converted to INT). Input: `iMinutes` (INT).
- **Feature:** Added `F_TCO_50_TO_TIME` — converts a 50 ms ticker value to `TIME` (milliseconds); returns TIME. Formula: `dwTicker * 50`. Input: `dwTicker` (DWORD).
- **Test program:** `PRG_TEST_TCO_50` now also exercises `F_TCO_50_TO_TIME` (`t3`) and `F_MIN_TO_SEC` (`ii4`); the CSV gained the `t3` TIME and `ii4` INT labels.
- **Documentation:** Added both functions to the summary table and detail sections of `TimeControl.md`; updated the file structure in `README.md`.

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
