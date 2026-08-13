# AlarmManager — Developer Notes

## Overview

AlarmManager is a Structured Text library for Mitsubishi FX series PLCs (GX Works 2) that provides alarm and event management: registration, filtering, packing, buzzer control, and HMI integration.

## File Structure

```
POU/
├── AM.csv                 — Global variables and constants (severity levels, arrays, counters, pack targets)
├── AM_ALARM.csv           — AM_ALARM struct definition (latch, lock, buzzer, alarm, state, delay, severity, process, timerStart)
├── AM_EVENT.csv           — AM_EVENT struct definition (state, stateM, event)
├── AM_INIT.st / .csv      — Initialise a single alarm's properties; called once at startup
├── AM_SET.st / .csv       — Evaluate and register an alarm condition; called every scan
├── AM_ISON.st / .csv      — Function: check if a specific alarm is active
├── AM_ORISON.st / .csv    — OR-combine multiple alarm states into an accumulator
├── AM_RESET.st / .csv     — Reset all alarms; holds reset pulse for 1 second
├── AM_IS_BLOCK.st / .csv  — Check for blocking (lock=TRUE) alarms, optionally filtered
├── AM_HAS_ALARMS.st / .csv— Check for any registered alarm, optionally filtered
├── AM_BUZZER.st / .csv    — Check for buzzer-tagged alarms; emits pulse on count increase
├── AM_EV.st / .csv        — Create/register an event with optional latch
├── AM_EVENT.st / .csv     — AM_EVENT struct variable definitions
├── AM_EVENT_RESET.st / .csv— Reset all latched events; holds pulse for 1 second
├── AM_PACK_ALARMS.st / .csv — Pack alarm bits into D/R registers
├── AM_PACK_EVENTS.st / .csv — Pack event bits into D/R registers
├── AM_DELAY_OUT.st / .csv  — Helper: delay output using TimeControl
├── AM_MOVE_TO_M.st / .csv  — Helper: BMOV wrapper for HMI bit-register transfer
```

## Global Variables (AM.csv)

| Variable | Purpose |
|---|---|
| `AM_ERROR` (const 3) | Severity constant for Error-level alarms |
| `AM_WARNING` (const 2) | Severity constant for Warning-level alarms |
| `AM_INFO` (const 1) | Severity constant for Info/Message-level alarms |
| `AM_ALARMS` | Global array `[0..127]` of `AM_ALARM` structs |
| `AM_EVENTS` | Global array `[0..127]` of `AM_EVENT` structs |
| `AM_ALARMS_NUM` | Count of initialized alarms; controls scan range |
| `AM_EVENTS_NUM` | Count of initialized events; controls scan range |
| `AM_PACK_D` (const 0) | Pack target: D registers |
| `AM_PACK_R` (const 1) | Pack target: R registers |

## Conventions

- All POUs follow `AM_<NAME>` naming with ALL-CAPS prefix
- FB instances use CamelCase with `fb` prefix: `fbAMInit : AM_INIT`
- Startup logic in `AM_INIT` uses `M8002` pulse — set in program/task settings, not guarded in code
- Comments in English
- Every POU produces `.st` (code) + `.csv` (variables) files
- CSV files are UTF-16LE encoded for GX Works 2 compatibility
- Requires TimeControl V2 library for delay functionality
- Consumes ~1,400 D registers and ~2,000 M registers from auto-assigned range
