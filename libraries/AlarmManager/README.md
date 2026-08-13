# AlarmManager — Developer Notes

## Overview

AlarmManager is a Structured Text library for Mitsubishi FX series PLCs (GX Works 2) that provides alarm and event management: registration, filtering, packing, buzzer control, and HMI integration.

## File Structure

```
POU/
├── GVL_AM.csv             — Global variables and constants (severity levels, arrays, counters, pack targets)
├── ST_AM_ALARM.csv        — AM_ALARM struct definition (latch, lock, buzzer, alarm, state, delay, severity, process, timerStart)
├── ST_AM_EVENT.csv        — AM_EVENT struct definition (state, stateM, event)
├── FB_AM_INIT.st / .csv   — Initialise a single alarm's properties; called once at startup
├── FB_AM_SET.st / .csv    — Evaluate and register an alarm condition; called every scan
├── F_AM_ISON.st / .csv    — Function: check if a specific alarm is active
├── FB_AM_ORISON.st / .csv — Function Block: OR-combine multiple alarm states into an accumulator
├── FB_AM_RESET.st / .csv  — Reset all alarms; holds reset pulse for 1 second
├── FB_AM_IS_BLOCK.st / .csv — Check for blocking (lock=TRUE) alarms, optionally filtered
├── FB_AM_HAS_ALARMS.st / .csv — Check for any registered alarm, optionally filtered
├── FB_AM_BUZZER.st / .csv — Check for buzzer-tagged alarms; emits pulse on count increase
├── FB_AM_EV.st / .csv     — Create/register an event with optional latch
├── FB_AM_EVENT_RESET.st / .csv — Reset all latched events; holds pulse for 1 second
├── FB_AM_PACK_ALARMS.st / .csv — Pack alarm bits into D/R registers
├── FB_AM_PACK_EVENTS.st / .csv — Pack event bits into D/R registers
├── F_AM_DELAY_OUT.st / .csv — Function: delay output using TimeControl
├── F_AM_MOVE_TO_M.st / .csv — Function: BMOV wrapper for HMI bit-register transfer
```

## Global Variables (GVL_AM.csv)

| Variable | Purpose |
|---|---|
| `c_AM_ERROR` (const 3) | Severity constant for Error-level alarms |
| `c_AM_WARNING` (const 2) | Severity constant for Warning-level alarms |
| `c_AM_INFO` (const 1) | Severity constant for Info/Message-level alarms |
| `AM_ALARMS` | Global array `[0..127]` of `AM_ALARM` structs |
| `AM_EVENTS` | Global array `[0..127]` of `AM_EVENT` structs |
| `AM_ALARMS_NUM` | Count of initialized alarms; controls scan range |
| `AM_EVENTS_NUM` | Count of initialized events; controls scan range |
| `c_AM_PACK_D` (const 0) | Pack target: D registers |
| `c_AM_PACK_R` (const 1) | Pack target: R registers |

## POU Naming

| Prefix | Type | Files |
|---|---|---|
| `F_` | Function | F_AM_DELAY_OUT, F_AM_ISON, F_AM_MOVE_TO_M |
| `FB_` | Function Block | FB_AM_BUZZER, FB_AM_EV, FB_AM_EVENT_RESET, FB_AM_HAS_ALARMS, FB_AM_INIT, FB_AM_IS_BLOCK, FB_AM_ORISON, FB_AM_PACK_ALARMS, FB_AM_PACK_EVENTS, FB_AM_RESET, FB_AM_SET |
| `ST_` | Structure | ST_AM_ALARM, ST_AM_EVENT |
| `GVL_` | Global Variable List | GVL_AM |

## Conventions

- FB instances use CamelCase with `fb` prefix: `fbAMInit : FB_AM_INIT`
- F instances use bare call: `result := F_AM_DELAY_OUT(...)`
- Startup logic in `FB_AM_INIT` uses `M8002` pulse — set in program/task settings, not guarded in code
- Comments in English
- Every POU produces `.st` (code) + `.csv` (variables) files
- CSV files are UTF-16LE encoded for GX Works 2 compatibility
- Requires TimeControl V2 library for delay functionality
- Consumes ~1,400 D registers and ~2,000 M registers from auto-assigned range
