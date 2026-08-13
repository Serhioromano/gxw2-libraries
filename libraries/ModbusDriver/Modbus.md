# Modbus RTU Driver V7 — Library for Coolmay FX3G PLC

## Abstract

The Modbus RTU Driver enables a Coolmay FX3G PLC to operate as a Modbus RTU master or slave on the two auxiliary RS485 ports (port 2 and port 3). Version V7 changes the channel-storage model: the `MB_CHANNELS` array and the `c_MB_CHANNELS_NUM` capacity constant are no longer declared by the library. The application declares them in its own global label list, sized to the number of channels it actually uses, and `MB_PROCESS_50` cycles through that array.

## Terminology

- **Register** — A contiguous region of memory within the Modbus address space.

---

## Prerequisites

The following libraries must be installed in the project prior to using this driver:

- `Utils.sul`
- `TimeControl.sul`

> [!IMPORTANT]
>
> - The TimeControl V2 library must be installed and the `TCO_TICKER_50` ticker must be configured. This ticker advances at **50 ms** intervals and is required by the `MB_PROCESS_50` function block.
> - This library is compatible with **GX Works 2 v1.91** and later. Updates are available from the `coolmay/soft` directory.

The application must declare the Modbus channel storage in its project's global label list before using `MB_PROCESS_50`:

- `c_MB_CHANNELS_NUM` — `VAR_GLOBAL_CONSTANT` (`INT`), the upper bound (last valid index) of the channel array.
- `MB_CHANNELS` — `VAR_GLOBAL` (`ARRAY [0..c_MB_CHANNELS_NUM] OF MB_REG_50`), the channel array itself.

---

## Architectural Description

This library enables a Coolmay FX3G PLC to operate as a **Modbus Slave** or a **Modbus Master** (on the secondary and tertiary RS485 ports — ports 2 and 3, respectively) for reading from and writing to Modbus RTU devices. It provides a low-overhead interface for configuring and managing Modbus communication channels.

The Modbus channels are described in a user-declared global array `MB_CHANNELS` of type `MB_REG_50`. The library does not fix the channel count: the application declares the array and the `c_MB_CHANNELS_NUM` upper bound in its global label list, and `MB_PROCESS_50` cycles through exactly that many channels. This keeps the automatically-assigned device usage proportional to the number of channels actually configured.

Coolmay PLC/HMI integrated units are equipped with two RS485 ports: port 2 is exposed on the terminal connector, and port 3 is exposed on the DB9 connector. L02-series PLCs also provide two RS485 ports, both on terminal connectors.

---

## Function Blocks and Functions

| Name | Type | Description |
|------|------|-------------|
| `MB_PORT_SETTINGS` | Function | Build the serial-port bit-field (parity, stop bits, baud rate). |
| `MB_MASTER_INIT_PORT2` | Function | Initialise the Modbus master on port 2. |
| `MB_MASTER_INIT_PORT3` | Function | Initialise the Modbus master on port 3. |
| `MB_SLAVE_INIT_PORT2` | Function | Initialise the Modbus slave on port 2. |
| `MB_SLAVE_INIT_PORT3` | Function | Initialise the Modbus slave on port 3. |
| `MTB_SLAVE_PORT2` | Function | Reconfigure port 2 for the Mitsubishi protocol. |
| `MTB_SLAVE_PORT3` | Function | Reconfigure port 3 for the Mitsubishi protocol. |
| `MB_PROCESS_50` | Function Block | Cycle through channels and issue `ADPRW` read/write requests. |

---

## Global Constants and Variables

### Access Modes

| Constant | Value | Description |
|----------|-------|-------------|
| `MB_READ_WRITE` | `0` | Read and write. |
| `MB_READ` | `1` | Read only. |
| `MB_WRITE` | `2` | Write only. |

### Serial Port Settings

| Constant | Value | Description |
|----------|-------|-------------|
| `MB_DL_7` | `0` | 7 data bits. |
| `MB_DL_8` | `1` | 8 data bits. |
| `MB_PARITY_NONE` | `0` | No parity. |
| `MB_PARITY_ODD` | `1` | Odd parity. |
| `MB_PARITY_EVEN` | `2` | Even parity. |
| `MB_STOPBIT_1` | `0` | 1 stop bit. |
| `MB_STOPBIT_2` | `1` | 2 stop bits. |
| `MB_BPS_600` | `0` | 600 bps. |
| `MB_BPS_1200` | `1` | 1200 bps. |
| `MB_BPS_2400` | `2` | 2400 bps. |
| `MB_BPS_4800` | `3` | 4800 bps. |
| `MB_BPS_9600` | `4` | 9600 bps. |
| `MB_BPS_19200` | `5` | 19200 bps. |
| `MB_BPS_38400` | `6` | 38400 bps. |
| `MB_BPS_57600` | `7` | 57600 bps. |
| `MB_BPS_115200` | `8` | 115200 bps. |

### Ports

| Constant | Value | Physical port |
|----------|-------|---------------|
| `MB_PORT_2` | `0` | RS485 port 2 — terminal connector (A, B) |
| `MB_PORT_3` | `1` | RS485 port 3 — DB9 connector (A1, B1) |
| `MB_PORT_CAN` | `2` | CAN port (H, L) |
| `MB_PORT_TCP` | `3` | Ethernet TCP port |

### Timeout Tuning

| Variable | Type | Description |
|----------|------|-------------|
| `MB_TIMEOUT_COUNT` | INT | Consecutive timeouts before a channel is suspended. Default: `2`. |
| `MB_SUSPEND_RETRY` | INT | Suspended-channel retry interval, in 50 ms units. Default: `80` (4 s). |
| `MB_TIMEOUT_TIME` | INT | Timeout duration, in 50 ms units. Default: `4` (200 ms). |

---

## `MB_PORT_SETTINGS` (Function)

Returns a correctly formatted bit-field value for initialising a port as either Master or Slave.

| Variable   | Scope  | Type                   | Description                                                                                                                    |
| ---------- | ------ | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `Parity`   | INPUT  | `Word[Signed]`         | One of: `MB_PARITY_NONE`, `MB_PARITY_ODD`, `MB_PARITY_EVEN`.                                                                  |
| `StopBit`  | INPUT  | `Word[Signed]`         | One of: `MB_STOPBIT_1`, `MB_STOPBIT_2`.                                                                                       |
| `Baudrate` | INPUT  | `Word[Signed]`         | One of: `MB_BPS_600`, `MB_BPS_1200`, `MB_BPS_2400`, `MB_BPS_4800`, `MB_BPS_9600`, `MB_BPS_19200`, `MB_BPS_38400`, `MB_BPS_57600`, `MB_BPS_115200`. |

Declare a local variable of type `Double Word [Unsigned]` (e.g., `PortSettings`), then invoke the function:

```iecst
PortSettings := MB_PORT_SETTINGS(MB_PARITY_NONE, MB_STOPBIT_1, MB_BPS_9600);
```

---

## Modbus Slave

### `MB_SLAVE_INIT_PORT2`, `MB_SLAVE_INIT_PORT3`

These functions initialise the Modbus slave on port 2 or port 3 of the PLC, respectively.

| Variable       | Scope  | Type                    | Description                                                                              |
| -------------- | ------ | ----------------------- | ---------------------------------------------------------------------------------------- |
| `xInit`        | INPUT  | `Bit`                   | Initialisation command. The slave is (re-)initialised on every rising edge.              |
| `iAddress`     | INPUT  | `Word[Signed]`          | Modbus network address assigned to this PLC.                                              |
| `PortSettings` | INPUT  | `Double Word[Signed]`   | Return value of the `MB_PORT_SETTINGS` function.                                          |

#### Example

The following snippet configures a slave with address 1 on port 2:

```iecst
PortSettings := MB_PORT_SETTINGS(MB_PARITY_NONE, MB_STOPBIT_1, MB_BPS_9600);
M0 := MB_SLAVE_INIT_PORT2(TRUE, 1, PortSettings);
```

No further configuration is necessary for the PLC to function as a slave on port 2. The same pattern applies to port 3. The variable `M0` is not referenced elsewhere in the program — it exists solely to satisfy the syntactic requirement that a function call used as a statement must have a left-hand side assignment.

---

## Modbus Master

### `MB_MASTER_INIT_PORT2`, `MB_MASTER_INIT_PORT3`

These functions initialise the Modbus Master on port 2 (terminal connector) or port 3 (DB9 connector), respectively.

| Variable       | Scope  | Type                    | Description                                                                              |
| -------------- | ------ | ----------------------- | ---------------------------------------------------------------------------------------- |
| `xInit`        | INPUT  | `Bit`                   | Initialisation command. The master is (re-)initialised on every rising edge.             |
| `PortSettings` | INPUT  | `Double Word[Signed]`   | Return value of the `MB_PORT_SETTINGS` function.                                          |

#### Example

```iecst
PortSettings := MB_PORT_SETTINGS(MB_PARITY_NONE, MB_STOPBIT_1, MB_BPS_9600);
M0 := MB_MASTER_INIT_PORT2(TRUE, PortSettings);
```

---

## Port Reconfiguration (Mitsubishi Protocol)

### `MTB_SLAVE_PORT2`, `MTB_SLAVE_PORT3`

These functions reconfigure port 2 or port 3 to the Mitsubishi proprietary protocol (not Modbus RTU), set the station address to `1`, and set the serial format to 38400 baud, 7 data bits, even parity, 1 stop bit. They are used to switch a port back from Modbus RTU to the Mitsubishi protocol.

| Variable | Scope | Type | Description |
|----------|-------|------|-------------|
| `xInit` | INPUT | `Bit` | Reconfiguration command. The port is reconfigured on every rising edge. |

#### Example

```iecst
M0 := MTB_SLAVE_PORT2(TRUE);
```

---

### `MB_PROCESS_50` (Function Block)

This function block orchestrates all read and write operations across the configured channels.

> **Prerequisite:** The TimeControl V5.0 library must be installed and `TCO_TICKER_50` must be configured. This ticker advances at 50 ms intervals and drives the internal scheduling of channel operations.

| Variable       | Scope  | Type            | Description                                                                                                                                                                                  |
| -------------- | ------ | --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `mb_xEnable`   | INPUT  | `Bit`           | Enables channel processing.                                                                                                                                                                  |
| `mb_iBuffer`   | INPUT  | `Word[Signed]`  | Base device number for the buffer area. For register channels, `D{mb_iBuffer}` is used as the first buffer device; for coil channels, `M{mb_iBuffer}` is used. The buffer consumes as many devices as the `iNum` value of the largest channel. |
| `mb_Timeout`   | OUTPUT | `Word[Signed]`  | Device address of the channel that timed out.                                                                                                                                                 |

#### The `MB_REG_50` Structure

The application declares a global array `MB_CHANNELS` of type `MB_REG_50`, together with a global constant `c_MB_CHANNELS_NUM` that holds the array's upper bound (last valid index). The library references both labels directly — it does not declare them. `MB_PROCESS_50` cycles through channels `0` to `c_MB_CHANNELS_NUM`, so the number of channels is fully under application control (e.g. `c_MB_CHANNELS_NUM := 2` for 3 channels, `:= 29` for 30 channels). Each channel may read or write up to 125 registers. The array must be configured once, typically on PLC startup under the `M8002` initialisation pulse flag.

The following table lists the fields of the `MB_REG_50` structure:

| Variable          | Type                                 | Description                                                                                                                                                                 |
| ----------------- | ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `iDDevNum`        | `Word[Signed]`                       | Base device number for the result buffer. See § `iDDevNum` for allocation rules.                                                                                           |
| `iNum`            | `Word[Signed]`                       | Number of registers or coils to read or write. Default: `1`.                                                                                                                |
| `iReg`            | `Word[Unsigned]` / `Bit String[16]`  | Starting Modbus register address (decimal).                                                                                                                                |
| `iRF`             | `Word[Unsigned]` / `Bit String[16]`  | Modbus read function code. Default: `H3`.                                                                                                                                   |
| `iWF`             | `Word[Unsigned]` / `Bit String[16]`  | Modbus write function code. Default: `H6`.                                                                                                                                  |
| `iDev`            | `Word[Unsigned]` / `Bit String[16]`  | Modbus slave device address.                                                                                                                                                |
| `tCycle`          | `Word[Signed]`                       | Cycle interval for automatic reads/writes, in units of 50 ms. E.g., `20` = 1 second. Set to `0` for manual-only operation via `xReadOnce` / `xWriteOnce`.                  |
| `iWR`             | `Word[Signed]`                       | Read/write mode. Default: `MB_READ_WRITE`. May be set to `MB_READ` or `MB_WRITE`.                                                                                          |
| `iPort`           | `Word[Signed]`                       | Communication port identifier. See § Supported Ports.                                                                                                                       |
| `xDone`           | `Bit`                                | Channel cycle-completion flag. Primarily useful for channels operating in manual mode (`tCycle = 0`).                                                                       |
| `xEnabled`        | `Bit`                                | When `FALSE`, the channel is excluded from processing.                                                                                                                      |
| `xReadOnce`       | `Bit`                                | On a rising edge (`FALSE` → `TRUE`), triggers a single read of this channel. For manual-only reads, set `tCycle` to `0`.                                                   |
| `xWriteOnce`      | `Bit`                                | On a rising edge (`FALSE` → `TRUE`), triggers a single write of this channel. For manual-only writes, set `tCycle` to `0`.                                                 |
| `xWriteOnChange`  | `Bit`                                | When `TRUE`, changed values are written to the slave immediately upon detection. When `FALSE`, writes occur only when the `tCycle` interval elapses.                        |

##### Supported Read/Write Functions

| Code | Mnemonic                 |
| ---- | ------------------------ |
| `H1` | Read Coils               |
| `H2` | Read Discrete Inputs     |
| `H3` | Read Holding Registers   |
| `H4` | Read Input Registers     |
| `H5` | Write Single Coil        |
| `H6` | Write Single Register    |
| `HF` | Write Multiple Coils     |
| `H10`| Write Multiple Registers |

##### Supported Ports

| Constant       | Physical Port             |
| -------------- | ------------------------- |
| `MB_PORT_2`    | RS485 Port 1 (A, B)       |
| `MB_PORT_3`    | RS485 Port 2 (A1, B1)     |
| `MB_PORT_CAN`  | CAN Port (H, L)           |
| `MB_PORT_TCP`  | Ethernet port             |

---

#### `iDDevNum` — Buffer Allocation

Each channel reserves **twice** the number of devices specified by `iNum`. Half of the allocation holds the actual register or coil values; the other half is used internally for change tracking.

If `iNum = 1` and `iDDevNum = 200`:
- `D200` stores the value.
- `D201` is reserved for internal use.

If `iNum = 5`:
- `D200`–`D204` store the values.
- `D205`–`D209` are reserved for internal use.

> **Caution:** Failure to account for the internal buffer when assigning `iDDevNum` values across consecutive channels will result in data corruption.

Consider the following **incorrect** configuration:

```iecst
MB_CHANNELS[0].iDDevNum := 600;
MB_CHANNELS[0].iNum := 3;

MB_CHANNELS[1].iDDevNum := 603;
MB_CHANNELS[1].iNum := 1;
```

Channel 0 consumes devices `D600` through `D605` (3 values + 3 internal). The first free device is therefore `D606` — not `D603`. Assigning `iDDevNum := 603` to channel 1 causes its buffer to overlap with the internal area of channel 0, producing undefined behaviour.

The **correct** allocation is:

```iecst
MB_CHANNELS[0].iDDevNum := 600;
MB_CHANNELS[0].iNum := 3;

MB_CHANNELS[1].iDDevNum := 606;
MB_CHANNELS[1].iNum := 1;
```

---

#### `iWF` — Write Function Selection

Two write-function codes are available for registers:

- **`H6` (Write Single Register):** When assigned to a multi-register channel, only the register whose value changed is written in a dedicated request.
- **`H10` (Write Multiple Registers):** When assigned to a multi-register channel, a change to any register within the group triggers a single request that updates the entire group.

**Guidance:**
- For double-word values spanning multiple registers → use `H10`.
- For multiple independent single-register variables on the same channel → use `H6`.
- For a single-register channel → use `H6`.

The same principle applies to coil channels: use `H5` (Write Single Coil), even when the channel spans multiple coils.

---

#### Complete Example

Before configuring channels, declare the storage in the project's global label list. The following declares three channels (indices `0`–`2`):

| Label | Class | Type / Value |
|-------|-------|--------------|
| `c_MB_CHANNELS_NUM` | `VAR_GLOBAL_CONSTANT` | `INT` = `2` |
| `MB_CHANNELS` | `VAR_GLOBAL` | `ARRAY [0..2] OF MB_REG_50` |

```iecst
IF M8002 THEN

    (* Number of consecutive timeouts before a channel is suspended. Default: 2 *)
    MB_TIMEOUT_COUNT := 2;
    (* Suspended-channel retry interval, in 50 ms units. Default: 80 (4 seconds) *)
    MB_SUSPEND_RETRY := 80;
    (* Timeout duration, in 50 ms units. Default: 4 (200 ms) *)
    MB_TIMEOUT_TIME := 4;

    PortSettings := MB_PORT_SETTINGS(MB_PARITY_NONE, MB_STOPBIT_1, MB_BPS_9600);
    (* Multi-master mode is available on both ports for L02-series PLCs *)
    M0 := MB_MASTER_INIT_PORT2(TRUE, PortSettings);
    M0 := MB_MASTER_INIT_PORT3(TRUE, PortSettings);


    MB_CHANNELS[0].xEnabled := TRUE;
    MB_CHANNELS[0].iDDevNum := 600;
    MB_CHANNELS[0].iNum := 3;
    MB_CHANNELS[0].iReg := K16384;
    MB_CHANNELS[0].iRF := H3;
    MB_CHANNELS[0].iWF := H6;
    MB_CHANNELS[0].iDev := H1;
    MB_CHANNELS[0].tCycle := 20; (* 20 × 50 ms = 1 000 ms = 1 second *)
    MB_CHANNELS[0].xWriteOnChange := TRUE;
    MB_CHANNELS[0].iWR := MB_READ_WRITE;
    MB_CHANNELS[0].iPort := MB_PORT_2;


    (* Minimal setup — connects to a device via Port 3 *)
    MB_CHANNELS[1].xEnabled := TRUE;
    MB_CHANNELS[1].iDDevNum := 610;
    MB_CHANNELS[1].iReg := K16385;
    MB_CHANNELS[1].iDev := K16;
    MB_CHANNELS[1].tCycle := 4;
    MB_CHANNELS[1].iWR := MB_READ;
    MB_CHANNELS[1].iPort := MB_PORT_3;

    (* Manual-cycle read/write of a 3-register group *)
    MB_CHANNELS[2].xEnabled := TRUE;
    MB_CHANNELS[2].iNum := 3;
    MB_CHANNELS[2].iDev := 1;
    MB_CHANNELS[2].iPort := MB_PORT_3;
    MB_CHANNELS[2].iDDevNum := 10;
    MB_CHANNELS[2].iReg := H1000;
    MB_CHANNELS[2].iRF := H3;
    MB_CHANNELS[2].iWR := MB_READ;
    MB_CHANNELS[2].tCycle := 0;
END_IF;

fbMbProcess(mb_xEnable := TRUE, mb_iBuffer := 100);

(* Manually read channel 2 once *)
IF M1 THEN
    MB_CHANNELS[2].xReadOnce := TRUE;
    IF MB_CHANNELS[2].xDone = TRUE THEN
        M1 := FALSE;
        MB_CHANNELS[2].xReadOnce := FALSE;
    END_IF;
END_IF;

(* Manually write channel 2 once *)
IF M2 THEN
    D10 := 100;
    D11 := 100;
    D12 := 100;
    MB_CHANNELS[2].xWriteOnce := TRUE;
    IF MB_CHANNELS[2].xDone = TRUE THEN
        M2 := FALSE;
        MB_CHANNELS[2].xWriteOnce := FALSE;
    END_IF;
END_IF;

(* Alternative write-confirmation technique:
   when manually writing channel 2 once *)
IF M2 THEN
    D10 := 200;
    D11 := 200;
    D12 := 200;
    MB_CHANNELS[2].xWriteOnce := TRUE;
    IF D10 = D13 AND D11 = D14 AND D12 = D15 THEN
        M2 := FALSE;
        MB_CHANNELS[2].xWriteOnce := FALSE;
    END_IF;
END_IF;
```

**Post-configuration behaviour:**
- `D600`, `D601`, and `D602` hold the three register values read from device address 1, refreshed every second. If any value changes locally, the slave is updated immediately (`xWriteOnChange := TRUE`).
- `D610` holds the single register value read from device address 16. Since this channel is configured as read-only (`MB_READ`), any local modification to `D610` will be overwritten by the next read cycle (every 200 ms).

---

### Alternative Write Confirmation

The expression `IF D10 = D13 AND D11 = D14 AND D12 = D15 THEN` implements a buffer-comparison strategy for verifying write completion.

As described in § `iDDevNum`, each channel reserves twice the number of devices specified by `iNum`. With `iDDevNum := 10` and `iNum := 3`:

- `D10`–`D12` hold the actual register values.
- `D13`–`D15` serve as the change-tracking buffer.

Upon a successful write, the library updates the buffer to match the newly written values. Therefore, equality between the value registers and their corresponding buffer registers confirms that the write has completed.

This technique is particularly useful when employing `xWriteOnChange` (rather than `xWriteOnce`) with a multi-register channel and write function `H6`. If, for example, two registers within a ten-register channel are modified, `H6` writes each one individually, setting `xDone` once per successful write. Counting two distinct `xDone` pulses can rapidly become unwieldy. In contrast, a single comparison of the form `IF D10 = D13 AND D11 = D14 AND …` confirms that all changed registers have been successfully propagated to the slave in a single check.

---

## Timeout and Suspension Mechanism

The library implements a channel-suspension policy for fault tolerance. If a channel fails to receive a response for `MB_TIMEOUT_COUNT` consecutive attempts, it is flagged as **suspended**. Once suspended, the channel is polled at a reduced rate — once every `MB_SUSPEND_RETRY` interval. As soon as a valid response is received, the suspension flag is cleared and the channel resumes its normal cycle interval as defined by `MB_CHANNELS[*].tCycle`.
