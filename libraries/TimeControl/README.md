# TimeControl — Developer Notes

## Overview

TimeControl is a Structured Text library for Mitsubishi FX series PLCs (GX Works 2) that provides ticker-based time measurement. It replaces the CoDeSys `TIME()` function with two interrupt-driven global tickers (`TCO_DINT_50`, `TCO_DINT_10`) plus conversion functions and a blink function block.

## File Structure

```
POU/
├── GVL_TCO.csv                — Global tickers TCO_DINT_50 / TCO_DINT_10 (DWORD, no device binding; incremented by the ticker programs)
├── FB_TCO_50_BLINK.st / .csv  — Blink FB: toggles the output between LOW/HIGH phases using the 50 ms ticker
├── F_MIN_TO_TCO_50.st / .csv  — Convert minutes → 50 ms tick count (DWORD)
├── F_MIN_TO_TIME.st / .csv    — Convert minutes → TIME (ms)
├── F_SEC_TO_TCO_50.st / .csv  — Convert seconds → 50 ms tick count (DWORD)
├── F_SEC_TO_TIME.st / .csv    — Convert seconds → TIME (ms)
├── F_TCO_50_DIFF.st / .csv    — Elapsed ticks between a saved and the current ticker (wrap-safe DWORD subtraction via DSUB)
├── F_TCO_50_TO_100MS.st / .csv — Tick count → 100 ms units (INT)
├── F_TCO_50_TO_MIN.st / .csv  — Tick count → minutes (INT)
├── F_TCO_50_TO_MS.st / .csv   — Tick count → milliseconds (DINT)
├── F_TCO_50_TO_SEC.st / .csv  — Tick count → seconds (INT)
├── PRG_TCO_TICKER_10.st / .csv — Increments TCO_DINT_10; run in an interrupt task (event I610)
├── PRG_TCO_TICKER_50.st / .csv — Increments TCO_DINT_50; run in an interrupt task (event I750)
├── FB_TCO10.st / .csv         — ⚠ BROKEN LEGACY: reads D8010 (current scan time, 0.1 ms units), NOT a 10 ms ticker. Superseded by PRG_TCO_TICKER_10 + TCO_DINT_10. Left untouched by maintainer decision — do not rely on it; consider deleting it on the next rebuild.
└── PRG_TEST_TCO_50.st / .csv  — Test program exercising all functions and the blink FB
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
- CSV files are UTF-16 LE + BOM, tab-separated, every cell quoted, LF line endings. `.st` files use CRLF.
- Conversion functions use native DINT arithmetic (`DWORD_TO_DINT(dwTicker) / n`) — no `DDIV`/`SEL`/temporary arrays.
- `F_TCO_50_DIFF` intentionally keeps the `DSUB` instruction: raw 32-bit subtraction stays wrap-safe for elapsed-time measurement. Do not replace it with `DINT` subtraction (that would break wrap-around arithmetic).
- Return types are set in the GX Works 2 POU properties (not visible in the CSV): SEC/100MS/MIN → INT, MS → DINT, DIFF → DWORD, MIN_TO_TCO_50/SEC_TO_TCO_50 → DWORD, MIN_TO_TIME/SEC_TO_TIME → TIME.
- INT range limits (documented in `TimeControl.md`): 100 ms units overflow after ~55 min, seconds after ~9.1 h, minutes after ~22.7 days. Use `F_TCO_50_TO_MS` (DINT) or `F_TCO_50_DIFF` for long measurements.
- Ticker programs must run in interrupt tasks (I750 = 50 ms, I610 = 10 ms) and `EI(TRUE)` must be called once at startup to enable interrupts.
- `FB_TCO10` must not be used (broken; see above).
