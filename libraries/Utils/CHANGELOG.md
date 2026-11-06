# Changelog

## V9 — 2026-11-06

- **Added (`EIP_INIT.iecst` / `.csv`):** New function that selects EtherNet/IP on the L02 built-in Ethernet port. Inputs: `xInit` (BOOL, level-triggered configuration trigger — pass a one-scan pulse such as `M8002` or `MEP(xApplyIp)`) and `iModules` (INT, number of remote couplers, clamped to `1`–`4` and written to `D8325`). The body sets `D8395 := 0` (EtherNet/IP) and returns `xInit`. It deliberately does not touch `M8197`: the values are applied by the `L02_SET_IP` call that follows it in the same scan.
- **Added (`EIP_INIT_REMOTE.iecst` / `.csv`):** New function that writes the point configuration of one remote EIP coupler. Inputs: `iRemote` (INT, `EIP_REMOTE1`…`EIP_REMOTE4` = `1`–`4`), `iDI`, `iDO`, `iAI`, `iAO` (INT, point counts, clamped per capacity — see below). The body is an explicit `CASE iRemote OF` with integer labels `1`–`4` and the R registers written literally — no address arithmetic, no index register — so the destination devices are readable in the source: `R23834`/`R23844`/`R23854`/`R23864` (DI), `R23835`/…/`R23865` (AI), `R23836`/…/`R23866` (DO), `R23837`/…/`R23867` (AO) — the register order is DI, AI, DO, AO. Values of `iRemote` outside `1`–`4` write nothing. Counts are clamped to the L02 expansion capacity — `0`–`512` for DI and DO, `0`–`50` for AI and AO (512 DI/512 DO and 50 AI/50 AO in total across all couplers; the sum is not verified by the function). The function has no trigger input and writes on every call, so it belongs in `PRG_INIT` or behind a one-scan pulse. It performs no return assignment (always `FALSE`), like `L02_SET_IP` and `F_MBMOV`.
- **Added (`GVL_UTL.csv`):** `EIP_REMOTE1`…`EIP_REMOTE4` global constants (`1`–`4`) as the coupler selector for `EIP_INIT_REMOTE`. They are distinct from `IP_REMOTE1`…`IP_REMOTE4`, which stay the `R` register base addresses (`23830`…`23860`).
- **Test program (`PRG_UTL_TEST`):** added `EIP_INIT(xSaveIp, 2)` and `EIP_INIT_REMOTE(EIP_REMOTE1, 8, 8, 4, 2)`; the header comment now lists the new functions and their device side effects.
- **Documentation (`Utils.md`):** added an **EtherNet/IP Scanner Configuration** chapter — `D8395`/`D8325` usage, the coupler block layout with the DI/AI/DO/AO register offsets, call order (`EIP_INIT` → `EIP_INIT_REMOTE` → `L02_SET_IP`), parameter tables and examples for both functions — plus the summary-table entries; the title is now V9.
- **Build:** Regenerate `Utils.sul` in GX Works 2 and regenerate `Utils.pdf` from `Utils.md` to propagate the change into the compiled library and documentation PDF.

## V8 — 2026-11-04

- **Changed (`L02_SET_IP.iecst`):** The function now applies the IP settings itself. The `ELSE` branch that released `M8197` was removed because `M8197` is self-resetting in the PLC: while `xInit` is `TRUE` the R-register pair is written and `M8197` is set, which applies the new addresses and restarts the L02 interface. `M8197` is never cleared by the function or the application. Callers no longer need the separate `M8197 := M8002 OR MEP(xSaveIp);` line.
- **Kept level-triggered on purpose:** an intermediate working copy used `IF MEP(xInit) THEN`. It was reverted to `IF xInit THEN` because `MEP` keeps one edge detector per instruction and a function body exists once, so all `L02_SET_IP` calls would share it — a scan would execute only the *first* call after the rising edge and silently skip the mask/gateway/remote writes made in the same scan. Do not reintroduce `MEP` here.
- **Usage requirement:** pass a trigger bit that is `TRUE` for one scan only (`M8002`, or `MEP` of an HMI pulse such as `xApplyIp := M8002 OR MEP(xSaveIp);`) and give all settings of one configuration the same trigger, so they are written and applied in a single scan. Never tie `xInit` to `TRUE` — the interface would restart on every scan. The existing `PRG_UTL_TEST` call pattern (`xSaveIp` manual bit) satisfies this.
- **Documentation (`Utils.md`):** Rewrote the `L02_SET_IP` section — the self-resetting `M8197` apply, the one-scan `xInit` trigger rule, and the example rewritten to write IP, gateway and mask in one scan with decimal octets (`192, 168, 1, 100` instead of `16#00C0, …`); updated the summary table entry.
- **Documentation (`AGENT.md`):** Recorded that `L02_SET_IP` sets the self-resetting `M8197`, why its body must stay level-triggered, and documented the `PRG_UTL_TEST` side effect.
- **Build:** Regenerate `Utils.sul` in GX Works 2 and regenerate `Utils.pdf` from `Utils.md` to propagate the change into the compiled library and documentation PDF.

## V7 — 2026-08-22

- **Added:** `F_NEG` — negates an `INT` by multiplying it by `-1`; input `iIn`, returns `INT`. `F_NEG(-32768)` returns `-32768` because that value has no positive counterpart.
- **Added:** `F_DNEG` — the `DINT` counterpart of `F_NEG`; input `diIn`, returns `DINT`. `F_DNEG(-2147483648)` returns `-2147483648` for the same reason.
- **Test program:** `PRG_UTL_TEST` now exercises both functions (`iNeg` = `F_NEG(125)` → `-125`, `diDNeg` = `F_DNEG(-150000)` → `150000`) and lists them in its header.
- **Documentation:** added `F_NEG` / `F_DNEG` sections to `Utils.md` (parameter tables, examples, return-type and overflow notes), extended the summary table and the abstract, and updated `AGENT.md`.

## V6 — 2026-08-21

- **`F_SCALE`:** added a sixth input `xNoLimit` (BOOL). `FALSE` — the input and the result are clamped to their ranges (previous behaviour); `TRUE` — no clamping at all, values outside the ranges are extrapolated linearly. The parameter is appended after `iOutHigh`, so the meaning of the first five positional arguments is unchanged.
- **`F_SCALE`:** added a guard for a degenerate input range (`iInHigh = iInLow`). Previously the scale factor divided by zero and raised a PLC operation error; the function now returns `iOutLow`.
- **`F_SCALE.iecst` / `F_SCALE.csv`:** documented both modes in the header comment; the CSV entry for `xNoLimit` was declared as `INT` (and spelled `xNolimit`) while the body used it as a `BOOL` selector — corrected to `BOOL` / `xNoLimit`; removed the unused `rTemp` local.
- **Call sites:** every caller now passes the new flag explicitly — `F_WORK_LEFT`, `F_SCALE_NL`, `FB_SCALE_AI`, `L02_SCALE_AI` pass `FALSE` (unchanged behaviour); `PRG_UTL_TEST` gained a second call with `xNoLimit = TRUE` (`iScaleNoLimit`, `150` extrapolated to `1500`).
- **`F_DSCALE`:** rebuilt to the same structure as `F_SCALE`. Added the sixth input `xNoLimit` (BOOL) with the same meaning; added the degenerate-range guard (previously returned the output low limit through the clamp expression); the input and output clamps now use the correct `LIMITATION(MN, IN, MX)` order for both ascending and descending ranges; the scale factor is computed from `DINT_TO_REAL` conversions of each limit instead of a `DINT` subtraction, so large ranges no longer wrap; the unused `rTemp` local was replaced by `rNumber` and `diValue`.
- **Call sites:** `F_WORK_LEFT_TIME` and `F_VALVE_POS` pass the new `F_DSCALE` flag explicitly (`FALSE`, unchanged behaviour); `PRG_UTL_TEST` gained two `F_DSCALE` calls (`diDScale` clamped, `diDScaleNoLimit` extrapolated), so the smoke test now covers both scaling functions in both modes.
- **`F_SCALE`:** degenerate-range guard now exits with `RETURN` instead of wrapping the body in `ELSE`.
- **Documentation:** rewrote the `F_DSCALE` section of `Utils.md` (parameter table with `xNoLimit`, clamping versus extrapolation, descending ranges, degenerate input range, `REAL` 24-bit mantissa limitation, `DINT` overflow warning) and updated the scaling overview, summary tables and `AGENT.md`.
- **Verification:** both scaling functions were desk-tested against an independent reference model — 20 hand-checked `DINT` cases plus 200 000 randomised realistic-range combinations with no deviation, and `xNoLimit = FALSE` reproduces the previous `F_DSCALE` results within one count (the previous version also mishandled descending ranges).
- **Documentation:** rewrote the `F_SCALE` section of `Utils.md` (parameter table with `xNoLimit`, clamping versus extrapolation, truncation, descending ranges, degenerate input range, `INT` overflow warning) and updated the summary tables and `AGENT.md`.
- **Verification:** the algorithm was desk-tested against an independent reference model — 24 hand-checked cases plus 300 000 randomised range/value combinations; `xNoLimit = FALSE` reproduces the V5 results exactly.

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
