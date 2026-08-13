# AlarmManager — Developer Notes

## Overview

AlarmManager is a Structured Text library for Mitsubishi FX series PLCs (GX Works 2) that provides alarm and event management: registration, filtering, packing, buzzer control, and HMI integration.

The library does not reserve alarm/event storage. The application declares the storage arrays and the capacity constants in its project's global label list, sized to its actual requirements (see User Requirements below).

## File Structure

```
POU/
├── GVL_AM.csv             — Global constants (severity levels, pack targets); alarm/event storage is declared by the application (see User Requirements)
├── ST_AM_ALARM.csv        — AM_ALARM struct definition (latch, lock, buzzer, alarm, state, delay, severity, process, timerStart)
├── ST_AM_EVENT.csv        — AM_EVENT struct definition (state, stateM, event)
├── FB_AM_INIT.st / .csv   — Initialise a single alarm's properties; called once at startup
├── FB_AM_SET.st / .csv    — Evaluate and register an alarm condition; called every scan
├── FB_AM_ORISON.st / .csv — Function Block: OR-combine multiple alarm states into an accumulator
├── FB_AM_RESET.st / .csv  — Reset all alarms; holds reset pulse for 1 second
├── FB_AM_IS_BLOCK.st / .csv — Check for blocking (lock=TRUE) alarms, optionally filtered
├── FB_AM_HAS_ALARMS.st / .csv — Check for any registered alarm, optionally filtered
├── FB_AM_BUZZER.st / .csv — Check for buzzer-tagged alarms; emits pulse on count increase
├── FB_AM_EV.st / .csv     — Create/register an event with optional latch
├── FB_AM_EVENT_RESET.st / .csv — Reset all latched events; holds pulse for 1 second
├── FB_AM_PACK_ALARMS.st / .csv — Pack alarm bits into D/R registers or M devices
├── FB_AM_PACK_EVENTS.st / .csv — Pack event bits into D/R registers or M devices
├── F_AM_DELAY_OUT.st / .csv — Function: delay output using TimeControl
├── F_AM_MOVE_TO_M.st / .csv — Function: BMOV wrapper for HMI bit-register transfer
├── GVL_AM_TEST.csv        — Test-project global labels: user-declared storage (arrays + capacity constants) for PRG_AM_TEST
└── PRG_AM_TEST.st / .csv  — Test program: smoke test that compiles and runs every library FB
```

## Global Variables (GVL_AM.csv)

The library GVL declares constants only. Alarm/event storage is **not** part of the library — see User Requirements below.

| Variable | Purpose |
|---|---|
| `c_AM_ERROR` (const 3) | Severity constant for Error-level alarms |
| `c_AM_WARNING` (const 2) | Severity constant for Warning-level alarms |
| `c_AM_INFO` (const 1) | Severity constant for Info/Message-level alarms |
| `c_AM_PACK_D` (const 0) | Pack target: D registers |
| `c_AM_PACK_R` (const 1) | Pack target: R registers |
| `c_AM_PACK_M` (const 2) | Pack target: M devices (one bit per alarm/event) |

## User Requirements (declared by the application)

The application must declare the storage in its project's global label list, sized to its needs. The library code references these labels directly; without them the project does not compile.

| Label | Class | Type |
|---|---|---|
| `c_AM_ALARMS_NUM` | `VAR_GLOBAL_CONSTANT` | INT — upper bound of `AM_ALARMS` (max 127) |
| `c_AM_EVENTS_NUM` | `VAR_GLOBAL_CONSTANT` | INT — upper bound of `AM_EVENTS` (max 127) |
| `AM_ALARMS` | `VAR_GLOBAL` | `ARRAY [0..c_AM_ALARMS_NUM] OF AM_ALARM` |
| `AM_EVENTS` | `VAR_GLOBAL` | `ARRAY [0..c_AM_EVENTS_NUM] OF AM_EVENT` |

The scan loops use `c_AM_ALARMS_NUM` / `c_AM_EVENTS_NUM` as the upper bound. `FB_AM_PACK_ALARMS` / `FB_AM_PACK_EVENTS` pack the alarm/event bits into 16-bit registers and stop automatically as soon as all slots have been packed; any array length is supported (the last register may be partially filled, remaining bits stay `0`). With `PD := c_AM_PACK_M` each alarm/event bit is written to its own `M` device (`M(DNUM + n)` for ID `n`) instead of `D`/`R` registers.

## Test Program (PRG_AM_TEST)

`PRG_AM_TEST` is a compile-and-run smoke test that registers three alarms and four events and exercises every FB of the library (init, set, is-on, or-is-on, reset, has-alarms, is-block, buzzer, pack, event, event-reset, event-pack). It belongs to the `compiler` project and requires the storage declared in `GVL_AM_TEST.csv`. All test labels are auto-assigned by the compiler (no explicit device bindings); force the condition inputs (`xCondAlarm0..2`, `xCondEvent0..3`, `xReset`, `xEventReset`) and watch the result labels in the device monitor. Alarm states are packed to `R6000`/`D6000`/`M6000`; event states are packed to `D6100` and directly to `M6100..M6105` (`PD := c_AM_PACK_M`).

## POU Naming

| Prefix | Type | Files |
|---|---|---|
| `F_` | Function | F_AM_DELAY_OUT, F_AM_MOVE_TO_M |
| `FB_` | Function Block | FB_AM_BUZZER, FB_AM_EV, FB_AM_EVENT_RESET, FB_AM_HAS_ALARMS, FB_AM_INIT, FB_AM_IS_BLOCK, FB_AM_ORISON, FB_AM_PACK_ALARMS, FB_AM_PACK_EVENTS, FB_AM_RESET, FB_AM_SET |
| `ST_` | Structure | ST_AM_ALARM, ST_AM_EVENT |
| `GVL_` | Global Variable List | GVL_AM |

## Conventions

- FB instances use CamelCase with `fb` prefix: `fbAMInit : FB_AM_INIT`
- F instances use bare call: `result := F_AM_DELAY_OUT(...)`
- Startup logic in `FB_AM_INIT` uses `M8002` pulse — set in program/task settings, not guarded in code
- Storage arrays (`AM_ALARMS`, `AM_EVENTS`) and capacity constants (`c_AM_ALARMS_NUM`, `c_AM_EVENTS_NUM`) are user requirements declared in the project's global label list — not part of `GVL_AM.csv`
- Comments in English
- Every POU produces `.st` (code) + `.csv` (variables) files
- CSV files are UTF-16LE encoded for GX Works 2 compatibility
- Every variable in every POU CSV carries a descriptive English comment (derived from the ST code and AlarmManager.md); keep them in sync when editing code
- Requires TimeControl V2 library for delay functionality
- Consumes ~1,400 D registers and ~2,000 M registers from the auto-assigned range in the maximum configuration (128 alarms + 128 events); less with smaller user-declared arrays
