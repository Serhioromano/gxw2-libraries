---
name: lib-doc
description: Generate and maintain IEC 61131-3 PLC library documentation for Coolmay FX3G PLC projects (GX Works 2). Trigger when asked to create, update, or review library docs under libraries/<Name>/<Name>.md. Covers AlarmManager, ModbusDriver, and any future Coolmay library.
---

# Library Documentation Writer

Generate and maintain IEC 61131-3 PLC library documentation for Coolmay FX3G PLC projects (GX Works 2). Each library lives under `libraries/<LibraryName>/` and its documentation is `libraries/<LibraryName>/<LibraryName>.md`.

## File Location

The documentation file **must** be placed at:

```
libraries/<LibraryName>/<LibraryName>.md
```

All relative paths inside the document (images, links) are resolved relative to this file's directory.

---

## Document Structure

Every library documentation file follows this exact section order. Sections marked **(optional)** may be omitted when not applicable.

```
1.  Title
2.  Abstract
3.  Prerequisites (optional)
4.  Roadmap (optional)
5.  Terminology (optional)
6.  Architectural Description
7.  Function Blocks and Functions  — summary table
8.  Per-FB/Function detail sections
9.  Conceptual sections (Events, Data Structures, etc.) (optional)
```

Sections are separated by a horizontal rule: `---`

---

### 1. Title

```markdown
# LibraryName VXXX — Library for Coolmay FX3G PLC
```

- Use the exact library name (e.g. `AlarmManager`, `ModbusDriver`).
- Include the version identifier (`V203`, `V100`, etc.) that matches the code.
- Always end with `— Library for Coolmay FX3G PLC`.

---

### 2. Abstract

A single paragraph (or two) describing:
- What the library does.
- The current version's key change(s) compared to the previous version.
- Any trade-offs the user should know about (e.g. memory vs. features).

Write in formal, precise prose. No marketing language.

---

### 3. Prerequisites *(optional)*

Numbered list of things the user must configure or install **before** using the library.

Each item:
- States the requirement clearly.
- Includes the exact device/register counts if applicable.
- References an image when a GX Works 2 settings dialog is involved.

Example:
```markdown
1. The library consumes **1,400** devices from the `D` register area and **2,000** devices from the `M` register area. The allocation limits in GX Works 2 project settings must be increased accordingly.

    ![Device Allocation Settings](./screenshot-filename.png)
```

---

### 4. Roadmap *(optional)*

Bullet list of planned but unimplemented features. One short sentence per item.

---

### 5. Terminology *(optional)*

Bullet list defining domain-specific terms used throughout the document.

Format: `**Term** — Definition sentence.`

---

### 6. Architectural Description

A narrative explanation of:
- The problem the library solves.
- How it separates concerns (alarm logic vs. business logic, etc.).
- The recommended workflow (initialisation → registration → querying).
- Any hard limits (max alarms, max events, step-count constraints).

Use a numbered list for multi-step workflows.

---

### 7. Function Blocks and Functions — Summary Table

A single Markdown table listing every public FB and function:

| Name | Type | Description |
|------|------|-------------|
| `FB_INIT` | Function Block | Initialise ... |
| `fb_read` | Function | Read ... |

- `Type` is either `Function Block` or `Function`.
- `Description` is one concise sentence.

---

### 8. Per-FB/Function Detail Sections

Every FB and function from the summary table gets its own subsection.

#### Heading

Use H3 (`### `) with the exact name:

```markdown
### `AM_INIT`
```

#### Description

One paragraph explaining what the FB/function does, when to call it, and any timing constraints (e.g. "must be called once at startup under `M8002`", "must be called every scan").

#### Variable Table

| Variable | Scope | Type | Description |
|----------|-------|------|-------------|
| `iNum` | INPUT | INT | Alarm identifier. Range: `0` to `127`. |
| `Q` | OUTPUT | Bit | Result flag. |

- `Scope`: `INPUT`, `OUTPUT`, `IN_OUT`, or (for functions that read globals) note the constraint.
- `Type`: IEC 61131-3 type (`INT`, `Bit`, `BOOL`, `DINT`, etc.).
- `Description`: What the variable does, including valid ranges and units.

#### Sub-properties *(when applicable)*

If a parameter has sub-options (e.g. `iSeverity` with named constants), use H4/H5 sub-headings:

```markdown
##### `iSeverity`

Description text with bullet list of values.

- `0` — Not set
- `1` — Message (`AM_INFO`)
```

#### Example

Every FB/function must have at least one code example in IEC ST:

````markdown
Declare the function block instance in the local label section of the POU:

```iecst
VAR
    fbAMInit: AM_INIT;
END_VAR
```

In the POU body, invoke the block once under the initialisation pulse:

```iecst
IF M8002 THEN
    fbAMINIT(iNum := 0, iSeverity := AM_WARNING, iDelay := 2,
        xLock := TRUE, xLatch := FALSE, xBuzzer := TRUE);
END_IF;
```
````

Rules for examples:
- Use the `iecst` fenced code block language.
- Show both the `VAR` declaration and the invocation.
- Include realistic variable names and comments.
- When a FB has multiple usage patterns, show them as **Case 1**, **Case 2**, etc.

#### Notes / Caveats

If a FB/function has important caveats, use a blockquote:

```markdown
> **Note:** Explanation of the caveat.
```

---

### 9. Conceptual Sections *(optional)*

Some libraries need standalone conceptual sections (e.g. "Events", "Data Structures", "Communication Protocol"). Place these after all FB/function detail sections.

Follow the same pattern: description → variable tables → examples → notes.

---

## Image Referencing Rules

- Store images in the same directory as the `.md` file.
- Use descriptive filenames with timestamps: `YYYY-MM-DD_HH-MM-SS.png`.
- Every image must have an `alt` attribute that describes what the screenshot shows.
- Reference images with relative paths: `![Alt text](./filename.png)`.

---

## Writing Style

- **Tone:** Formal, technical, precise. No marketing language, no filler.
- **Voice:** Third person. Avoid "you should" — prefer "it is recommended to".
- **Code blocks:** Always use `iecst` for IEC 61131-3 Structured Text.
- **Inline code:** Use backticks for all variable names, FB names, register names (`D8030`, `M8002`, `AM_INIT`).
- **Bold:** Use for emphasis on numeric values and key terms on first mention.
- **Lists:** Numbered for procedural steps, bulleted for unordered items.
- **Sections:** Separated by `---` (horizontal rule).

---

## When Updating Documentation

1. Read the existing `.md` file first.
2. Read the corresponding `.st` source files in `POU/` to verify variable names, types, and logic.
3. Update `CHANGELOG.md` with the new version entry.
4. Update the Abstract if the library's behaviour has materially changed.
5. Add or modify FB/Function detail sections as needed.
6. Preserve existing examples unless the API has changed — then update them.
