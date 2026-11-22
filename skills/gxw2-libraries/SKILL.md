---
name: gxw2-libraries
description: >
  Routes GX Works 2 Structured Text tasks to the relevant Coolmay library
  documentation, with the library source code bundled as a fallback reference.
  Use alongside gxw2-st when a task involves alarms or events, Modbus RTU over
  RS485 or Modbus TCP over the L02 Ethernet port, time measurement or tickers,
  or reusable PLC helpers such as scaling, bit operations, hysteresis and valve
  control.
---

# Coolmay Library Documentation

When working with `gxw2-st`, check whether the task needs one of these libraries.
Read the matching manual **before** choosing library functions or writing code.
If several needs apply, read each relevant manual; otherwise skip these references.

| Need | Read |
|---|---|
| Register, filter, latch or display alarms and events | [AlarmManager](references/AlarmManager.md) |
| Modbus RTU on Coolmay RS485 ports or Modbus TCP on the L02 Ethernet port | [ModbusDriver](references/ModbusDriver.md) |
| Time measurement, 50 ms / 10 ms tickers or time conversion | [TimeControl](references/TimeControl.md) |
| Bit operations, scaling, hysteresis, analog inputs or valve control | [Utils](references/Utils.md) |

Use the selected manuals for API details, requirements and examples. Use `gxw2-st`
for ST syntax and CSV label generation. The manuals and their referenced images
are included with this skill.

## Manuals first, source code as a fallback

The manuals in `references/` are the primary and normative reference. Read the
matching manual before choosing functions or writing code, and take the public
API, parameters, requirements and examples from it.

The library sources are bundled for the cases a manual cannot settle:

| Path | Content |
|---|---|
| `references/src/INDEX.md` | Every POU of every library with its kind and one-line purpose |
| `references/src/<Library>/<POU>.iecst` | The Structured Text implementation |
| `references/src/<Library>/<POU>.csv` | The GX Works 2 label list: inputs, outputs, in/out and local variables with declared types and comments (UTF-8 copy of the UTF-16 original) |

Open a source file only when:

- the manual does not document a parameter, default or edge case;
- behaviour under a specific condition (overflow, clamping, reset, first scan,
  degenerate range) is unclear;
- the exact device side effects or internal variable types matter;
- the task is to modify, extend or debug the library itself;
- a complete working usage example is needed — read the `PRG_*_TEST` program.

Start from `references/src/INDEX.md` to find the file, then read the `.iecst` for
logic and the `.csv` for types. Prefer these files over guessing.

Do not copy implementation details into application code or invent API that only
exists in the source. If the source and the manual disagree, the manual is the
contract for users: follow the manual and mention the discrepancy instead of
silently using the source behaviour.
