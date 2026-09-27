---
name: gxw2-libraries
description: >
  Routes GX Works 2 Structured Text tasks to the relevant Coolmay library
  documentation. Use alongside gxw2-st when a task involves alarms or events,
  Modbus RTU, time measurement or tickers, or reusable PLC helpers such as
  scaling, bit operations, hysteresis and valve control.
---

# Coolmay Library Documentation

When working with `gxw2-st`, check whether the task needs one of these libraries.
Read the matching manual **before** choosing library functions or writing code.
If several needs apply, read each relevant manual; otherwise skip these references.

| Need | Read |
|---|---|
| Register, filter, latch or display alarms and events | [AlarmManager](references/AlarmManager.md) |
| Modbus RTU communication on Coolmay RS485 ports | [ModbusDriver](references/ModbusDriver.md) |
| Time measurement, 50 ms / 10 ms tickers or time conversion | [TimeControl](references/TimeControl.md) |
| Bit operations, scaling, hysteresis, analog inputs or valve control | [Utils](references/Utils.md) |

Use the selected manuals for API details, requirements and examples. Use `gxw2-st`
for ST syntax and CSV label generation. The manuals and their referenced images
are included with this skill.
