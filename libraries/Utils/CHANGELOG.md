# Changelog

## V9 — 2026-11-06

- **Moved out — EtherNet/IP is not a Utils feature:** `EIP_INIT`, `EIP_INIT_REMOTE`, `EIP_DI`, `EIP_DO`, `EIP_DO_SET`, `EIP_AI`, `EIP_AO`, `EIP_AO_SET` and the `EIP_REMOTE1`…`EIP_REMOTE4` constants now live in the **ModbusDriver** library, together with `MB_*_INIT_TCP` and the Modbus TCP channels — one library owns everything that configures the L02 Ethernet port. Utils keeps `L02_SET_IP` and the `IP_*` constants (IP addresses), and no Utils POU references `EIP_*`.
- **Test program (`PRG_UTL_TEST`):** the L02 / EtherNet/IP calls are gone — the whole Ethernet setup is exercised in `ModbusDriver/POU/PRG_MB_TEST.iecst`. `PRG_UTL_TEST` keeps the computational POUs only (`F_*`, `FB_*`, `F_MBMOV`); the `xSaveIp`, `xEipInit`, `xEipRemote`, `xSetIp`, `xDi1`, `xDo1`, `iAi1`, `iAo1`, `xDoSet`, `iAoSet` labels were removed from `PRG_UTL_TEST.csv` and are declared in `PRG_MB_TEST.csv` instead.
- **Documentation (`Utils.md`):** removed the **EtherNet/IP Scanner Configuration** chapter and the **Remote I/O Access** section together with their summary-table rows; the abstract now points to `ModbusDriver` for EtherNet/IP. The Utils manual covers `L02_SET_IP` and the `IP_*` constants only.
- **Documentation (`AGENT.md`):** removed the `EIP_*` POUs, their API rows, the `EIP_REMOTE*` constants and the EtherNet/IP gotchas; the `IP_REMOTE1`…`IP_REMOTE4` row notes that the coupler selectors live in ModbusDriver.
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
