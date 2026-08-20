# TimeControl — Developer Notes

## Overview

TimeControl is a Structured Text library for Mitsubishi FX series PLCs (GX Works 2) that provides ticker-based time measurement. It replaces the CoDeSys `TIME()` function with two interrupt-driven global tickers (`TCO_DINT_50`, `TCO_DINT_10`) plus conversion functions and a blink function block.

## File Structure

```
POU/
├── GVL_TCO.csv                — Global tickers TCO_DINT_50 / TCO_DINT_10 (DWORD, no device binding; incremented by the ticker programs)
├── FB_TCO_50_BLINK.iecst / .csv  — Blink FB: toggles the output between LOW/HIGH phases using the 50 ms ticker
├── F_MIN_TO_TCO_50.iecst / .csv  — Convert minutes → 50 ms tick count (DWORD)
├── F_MIN_TO_SEC.iecst / .csv    — Convert minutes → seconds (INT)
├── F_MIN_TO_TIME.iecst / .csv    — Convert minutes → TIME (ms)
├── F_SEC_TO_TCO_50.iecst / .csv  — Convert seconds → 50 ms tick count (DWORD)
├── F_SEC_TO_TIME.iecst / .csv    — Convert seconds → TIME (ms)
├── F_TCO_50_DIFF.iecst / .csv    — Elapsed ticks between a saved and the current ticker (wrap-safe DWORD subtraction via DSUB)
├── F_TCO_50_TO_100MS.iecst / .csv — Tick count → 100 ms units (INT)
├── F_TCO_50_TO_MIN.iecst / .csv  — Tick count → minutes (INT)
├── F_TCO_50_TO_MS.iecst / .csv   — Tick count → milliseconds (DINT)
├── F_TCO_50_TO_SEC.iecst / .csv  — Tick count → seconds (INT)
├── F_TCO_50_TO_TIME.iecst / .csv — Tick count → TIME (ms)
├── PRG_TCO_TICKER_10.iecst / .csv — Increments TCO_DINT_10; run in an interrupt task (event I610)
├── PRG_TCO_TICKER_50.iecst / .csv — Increments TCO_DINT_50; run in an interrupt task (event I750)
├── FB_TCO10.iecst / .csv         — Elapsed-time accumulator (0.1 ms resolution) from D8010 scan time: xReset input, diMs (ms) and di01ms (raw 0.1 ms) DINT outputs
└── PRG_TEST_TCO_50.iecst / .csv  — Test program exercising every function and both FBs (FB_TCO_50_BLINK, FB_TCO10)
```

## Global Variables (GVL_TCO.csv)

| Variable | Type | Purpose |
|---|---|---|
| `TCO_DINT_50` | DWORD | 50 ms ticker count since PLC start (~3.4 years to the signed limit) |
| `TCO_DINT_10` | DWORD | 10 ms ticker count since PLC start |

The ticker names are the library's public API — do not rename them without updating every POU, the test program and `TimeControl.md`.

## Conventions & Gotchas

- All functions use the `F_` prefix in code; the FB type is `FB_TCO_50_BLINK`, instances are declared in CamelCase (`fbBlink : FB_TCO_50_BLINK`).
- Variable names use Hungarian prefixes: `i` INT, `di` DINT, `w` WORD, `dw` DWORD, `x` BOOL, `t` TIME.
- CSV files are UTF-16 LE + BOM, tab-separated, every cell quoted, LF line endings. `.iecst` files use CRLF.
- The `F_TCO_50_TO_*` converters keep the ticker as a raw `DWORD` and do their arithmetic with the 32-bit instructions (`DDIV` for division, `DMUL` for multiplication, `DSUB` for difference). Native ST operators (`+`, `/`, `*`) do not work on `DWORD` in GX Works 2, and converting the ticker to `DINT` would lose half the range. The 32-bit result is held in the `dwQuot` local (`ARRAY [0..1] OF DINT`).
- `F_TCO_50_DIFF` intentionally keeps the `DSUB` instruction: raw 32-bit subtraction stays wrap-safe for elapsed-time measurement. Do not replace it with `DINT` subtraction (that would break wrap-around arithmetic).
- Return types are set in the GX Works 2 POU properties (not visible in the CSV): SEC/100MS/MIN → INT, MS → DINT, TIME → TIME, DIFF → DWORD, MIN_TO_TCO_50/SEC_TO_TCO_50 → DWORD, MIN_TO_TIME/SEC_TO_TIME → TIME, MIN_TO_SEC → INT. The INT/DINT output limits are documented in `TimeControl.md`; the internal arithmetic itself is correct for the full `DWORD` ticker range (~6.8 years at 50 ms).
- INT range limits (documented in `TimeControl.md`): 100 ms units overflow after ~55 min, seconds after ~9.1 h, minutes after ~22.7 days. Use `F_TCO_50_TO_MS` (DINT) or `F_TCO_50_DIFF` for long measurements.
- Ticker programs must run in interrupt tasks (I750 = 50 ms, I610 = 10 ms) and `EI(TRUE)` must be called once at startup to enable interrupts.
- `FB_TCO10` measures elapsed time by summing `D8010` (current scan time in 0.1 ms units) every scan — it approximates wall-clock time and misses time spent in interrupt tasks. Use it only in projects without interrupt tasks; the interrupt-driven ticker (`PRG_TCO_TICKER_10`/`TCO_DINT_10`) is more accurate.
