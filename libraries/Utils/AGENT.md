# Utils — Developer Notes

## Overview

Utils is a Structured Text library for Coolmay FX3G PLCs (GX Works 2) providing general-purpose utility functions and function blocks: bit-level WORD/DWORD manipulation, linear and non-linear scaling, on/off hysteresis regulators, index rotation/shifting, progress calculation, 3-position valve control, analog-input scaling (host PLC and L02 modules), L02 IP configuration, and block memory move.

## File Structure

```
POU/
├── GVL_UTL.csv                  — Global constants: IP_* register addresses and STYPE_* sensor-type selectors
├── F_ISBON.st / .csv            — Function: test a bit in a WORD (returns BOOL)
├── F_DISBON.st / .csv           — Function: test a bit in a DWORD (returns BOOL)
├── F_SETB.st / .csv             — Function: set a bit in a WORD, return modified WORD
├── F_DSETB.st / .csv            — Function: set a bit in a DWORD, return modified DWORD
├── F_RSTB.st / .csv             — Function: reset a bit in a WORD, return modified WORD
├── F_DRSTB.st / .csv            — Function: reset a bit in a DWORD, return modified DWORD
├── F_SRB.st / .csv              — Function: set/reset a bit in a WORD by xState
├── F_DSRB.st / .csv             — Function: set/reset a bit in a DWORD by xState
├── F_LIMIT.st / .csv            — Function: clamp an INT to [iMin..iMax]
├── F_SCALE.st / .csv            — Function: linear scale an INT between two INT ranges
├── F_DSCALE.st / .csv           — Function: linear scale a DINT between two DINT ranges
├── F_SCALE_NL.st / .csv         — Function: non-linear scale through a D-register point table
├── F_INCN.st / .csv             — Function: increment an index 0..iMax with wrap
├── F_SHFT.st / .csv             — Function: shift an index within 0..iMax
├── F_WORK_LEFT.st / .csv        — Function: progress 100..0 from elapsed/total (INT)
├── F_WORK_LEFT_TIME.st / .csv   — Function: progress 100..0 from elapsed/total (TIME)
├── F_VALVE_POS.st / .csv        — Function: valve position % from elapsed/total TIME
├── F_FLT10.st / .csv            — Function: divide an INT by 10 (returns REAL)
├── F_L02_SET_IP.st / .csv       — Function: write L02 IP settings (returns BOOL)
├── F_MBMOV.st / .csv            — Function: block-move N words between devices (returns BOOL)
├── FB_HYST.st / .csv            — Function Block: heating on/off regulator with hysteresis
├── FB_HYST_COOL.st / .csv       — Function Block: cooling on/off regulator with hysteresis
├── FB_SCALE_AI.st / .csv        — Function Block: scale a host-PLC analog input (D8030 area)
├── FB_L02_SCALE_AI.st / .csv    — Function Block: scale an L02-module analog input (R23700 area)
├── FB_VALVE_3P.st / .csv        — Function Block: 3-position valve control with position feedback
└── PRG_UTL_TEST.st / .csv       — Test program exercising every POU
```

## Public API

### Bit functions (WORD / DWORD)

| POU | Returns | Purpose |
|---|---|---|
| `F_ISBON` | BOOL | Test bit `iBN` in WORD `wIn` |
| `F_DISBON` | BOOL | Test bit `iBN` in DWORD `dwIn` |
| `F_SETB` | WORD | Set bit `iBN` in WORD `wIn`, return modified |
| `F_DSETB` | DWORD | Set bit `iBN` in DWORD `dwIn`, return modified |
| `F_RSTB` | WORD | Reset bit `iBN` in WORD `wIn`, return modified |
| `F_DRSTB` | DWORD | Reset bit `iBN` in DWORD `dwIn`, return modified |
| `F_SRB` | WORD | Set/reset bit `iBN` in WORD `wIn` by `xState` |
| `F_DSRB` | DWORD | Set/reset bit `iBN` in DWORD `dwIn` by `xState` |

### Value / index functions

| POU | Returns | Purpose |
|---|---|---|
| `F_LIMIT` | INT | Clamp `iIn` to `[iMin..iMax]` |
| `F_SCALE` | INT | Linear scale `iVal` from `iInLow..iInHigh` to `iOutLow..iOutHigh` |
| `F_DSCALE` | DINT | Linear scale `diVal` from `diInLow..diInHigh` to `diOutLow..diOutHigh` |
| `F_SCALE_NL` | INT | Non-linear scale `iPV` through a point table at `iDStart` |
| `F_INCN` | INT | Increment `iCur` within `0..iMax` (wrap) when `xIn` |
| `F_SHFT` | INT | Shift `iIdx` by `iShifter` within `0..iMax` |

### Progress / time functions

| POU | Returns | Purpose |
|---|---|---|
| `F_WORK_LEFT` | INT | Progress `100..0` from `iEt` of `iTw` |
| `F_WORK_LEFT_TIME` | INT | Progress `100..0` from `tEt` of `tTw` |
| `F_VALVE_POS` | INT | Valve position `0..1000` from `tCt` of `tTt` |

### Other functions

| POU | Returns | Purpose |
|---|---|---|
| `F_FLT10` | REAL | Divide `iIn` by 10 |
| `F_L02_SET_IP` | BOOL | Write L02 IP settings (`iWts` = `IP_*` constant, octets `wIp1..wIp4`) |
| `F_MBMOV` | BOOL | Move `iNum` words from device `iSrc` to device `iDst` |

### Function blocks

| POU | Purpose |
|---|---|
| `FB_HYST` | Heating on/off regulator (turns off when `iPV < iSV`) |
| `FB_HYST_COOL` | Cooling on/off regulator (turns off when `iPV > iSV`) |
| `FB_SCALE_AI` | Scale host-PLC analog input (`D8030` area) to engineering units |
| `FB_L02_SCALE_AI` | Scale L02-module analog input (`R23700` area) to engineering units |
| `FB_VALVE_3P` | 3-position valve control with position feedback |

## Global Variables (GVL_UTL.csv)

Constants only — no device-bound variables.

| Constant | Value | Purpose |
|---|---|---|
| `IP_PLC_IP` | 23807 | R-register address of the PLC IP |
| `IP_PLC_GATEWAY` | 23800 | R-register address of the gateway |
| `IP_PLC_MASK` | 23802 | R-register address of the subnet mask |
| `IP_REMOTE1`..`IP_REMOTE4` | 23830 / 23840 / 23850 / 23860 | R-register addresses of remote EIP couplers |
| `STYPE_0_10V` | 0 | Analog sensor type: 0-10 V |
| `STYPE_0_20MA` | 0 | Analog sensor type: 0-20 mA |
| `STYPE_4_20MA` | 1 | Analog sensor type: 4-20 mA |
| `STYPE_PT100` / `STYPE_PT1000` | 0 / 0 | Analog sensor type: PT100 / PT1000 |
| `STYPE_TC_K` / `_E` / `_T` / `_S` / `_J` | 0 / 5 / 7 / 9 / 11 | Analog sensor type: thermocouples |
| `STYPE_NTC` / `STYPE_NTC10K` | 0 / 3 | Analog sensor type: NTC thermistors |

## Conventions & Gotchas

- `F_` = function, `FB_` = function block, `PRG_` = program. FB instances use CamelCase `fb` prefix (`fbHyst : FB_HYST`).
- Variable names use Hungarian prefixes: `x` BOOL, `i` INT, `di` DINT, `w` WORD, `dw` DWORD, `r` REAL, `t` TIME, `fb` FB instance.
- CSV files are UTF-16 LE + BOM, tab-separated, every cell quoted, LF line endings; `.st` files use CRLF. Comments in English.
- Functions are called positionally (`result := F_SCALE(50, 0, 100, 0, 1000);`); FBs are called with named arguments (`fbHyst(xIn := …, iSV := …)`). `PRG_UTL_TEST` enforces this style.
- `F_MBMOV` and `F_L02_SET_IP` are "command" functions with no return assignment — they always return the default (`FALSE`). Call them for their device side effects, not for a result.
- `F_FLT10` returns `REAL` (body is `INT_TO_REAL(iIn) / 10.0`) — set the return type to REAL in the GX Works 2 POU properties.
- `F_SCALE_NL`, `F_L02_SET_IP`, `F_MBMOV`, `FB_SCALE_AI`, `FB_L02_SCALE_AI`, `FB_VALVE_3P` use direct device / index-register access (`Z3`/`Z5`, `D0Z5`, `R0Z5`, `M0Z4`, `D8030Z3`, `R23500Z3`, `R23700Z3`, …). Do not rename those device references — they are not labels.
- `FB_VALVE_3P` requires the **TimeControl** library (`TCO_DINT_50` ticker).
- Return types are set in the GX Works 2 POU properties (not visible in the CSV). See the Public API table.
- **Known issue:** `L02_SET_IP` and `L02_SCALE_AI` are currently unprefixed in the working copy (should be `F_L02_SET_IP` / `FB_L02_SCALE_AI`). Rename them back and update `PRG_UTL_TEST` accordingly.

## Test Program (PRG_UTL_TEST)

`PRG_UTL_TEST` is a compile-and-run smoke test that calls every function and function block with representative inputs; results are stored in auto-assigned labels for the device monitor. Function calls use positional arguments, FB calls use named arguments. Manual inputs: `xSaveIp` (triggers `F_L02_SET_IP`), `xValveEnable` (enables `FB_VALVE_3P`). Device side effects: `F_L02_SET_IP` writes IP 192.168.0.100 to `R23807/R23808`, `F_MBMOV` copies `D100..D103` → `D200..D203`, `F_SCALE_NL` writes `D100..D103`.
