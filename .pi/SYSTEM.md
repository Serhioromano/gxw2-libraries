# Coolmay GX Works 2 Libraries

Reusable Structured Text (ST) libraries for Mitsubishi FX series PLCs (FX3U, FX3G, FX3S, FX5U) in GX Works 2.

## Library Structure

Every library lives under `libraries/<LibraryName>/` and follows the same layout:

```
libraries/
├── AlarmManager/
│   ├── AlarmManager.md      # End-user documentation
│   ├── AlarmManager.pdf     # PDF documentation
│   ├── AlarmManager.sul     # GX Works 2 library file
│   ├── CHANGELOG.md
│   ├── README.md
│   └── POU/                 # Source code (.st + .csv files)
├── ModbusDriver/
│   ├── ModbusDriver.md
│   ├── ModbusDriver.pdf
│   ├── ModbusDriver.sul
│   ├── CHANGELOG.md
│   ├── README.md
│   └── POU/                 # Source code (.st + .csv files)
├── TimeControl/
│   ├── TimeControl.md
│   ├── TimeControl.pdf
│   ├── TimeControl.sul
│   ├── CHANGELOG.md
│   ├── README.md
│   └── POU/
└── Utils/
    ├── Utils.md
    ├── Utils.pdf
    ├── Utils.sul
    ├── CHANGELOG.md
    ├── README.md
    └── POU/
```

| File / Folder | Purpose |
|---|---|
| `POU/` | Source code — `.st` (Structured Text) and `.csv` (GX Works 2 Label Editor) files |
| `<LibraryName>.md` | End-user documentation who use this library |
| `<LibraryName>.pdf` | Documentation in PDF format |
| `<LibraryName>.sul` | Compiled GX Works 2 library file |
| `README.md` | Notes for AI agent who edit library files |
| `CHANGELOG.md` | Version history |

## Conventions

- **Platform:** Mitsubishi FX series in GX Works 2 only.
- **Languages:** Structured Text (ST) with GX Works 2 CSV Label Editor files.
- **POU naming prefixes:**
  - `F_` — Functions
  - `FB_` — Function blocks
  - `ST_` — Structures
  - `GVL_` — Global variable lists
  - `PRG_` — Programs
  - All prefixes are ALL-CAPS, e.g. `FB_<Name>`, `F_<Name>`.
- **FB instances:** CamelCase with prefix — `fbMotor : FB_MOTOR`.
- **Every POU produces two files:** `<POU>.st` (code) + `<POU>.csv` (variables).
- **Device addresses:** X, Y, M, D, T, C, Z, V, R (Mitsubishi only).
- **Startup logic:** Place in `PRG_INIT` with execution condition M8002 set in program/task settings — do not guard with M8002 in code.

## Key Skills

- `gxw2-st` — GX Works 2 ST code generation, FX instruction catalog, CSV variable formats, common rules.
