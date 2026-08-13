(*
  PRG_MB_TEST - Modbus RTU driver test program.

  Configures three channels and exercises the channel scheduler:
  - Channel 0: register, automatic read/write (device 1, port 2).
  - Channel 1: register, read-only, on demand (device 2, port 3).
  - Channel 2: coils, read/write (device 3, port 2).

  Channel storage (MB_CHANNELS, c_MB_CHANNELS_NUM) and the demo value
  labels g_iAutoReg*, g_iDemandReg, g_xCoil are declared in
  GVL_MB_TEST.csv.
*)

(* Enable interrupts - required by the ADPRW communication instruction. *)
EI(TRUE);

(* Build the serial-port bit-field (9600 baud, 8 data bits, no parity, 1 stop bit). *)
dwPortSettings := MB_PORT_SETTINGS(MB_PARITY_NONE, MB_STOPBIT_1, MB_BPS_9600);

(* Initialise the Modbus master on ports 2 and 3.
   M8013 = 1 s clock: re-triggers the initialisation every second so the
   port settings survive the startup overwrite. *)
M0 := MB_MASTER_INIT_PORT2(M8013, dwPortSettings);
M0 := MB_MASTER_INIT_PORT3(M8013, dwPortSettings);

(* One-time channel configuration. *)
IF M8002 THEN
    (* Timeout tuning. *)
    MB_TIMEOUT_COUNT := 2;
    MB_SUSPEND_RETRY := 80;
    MB_TIMEOUT_TIME := 4;

    (* Channel 0 - register, automatic read/write (device 1, port 2). *)
    MB_CHANNELS[0].xEnabled := TRUE;
    MB_CHANNELS[0].iDDevNum := 600;      (* D600 - value buffer *)
    MB_CHANNELS[0].iNum := 3;
    MB_CHANNELS[0].iReg := K16384;
    MB_CHANNELS[0].iRF := H3;            (* read holding registers *)
    MB_CHANNELS[0].iWF := H6;            (* write single register *)
    MB_CHANNELS[0].iDev := H1;
    MB_CHANNELS[0].tCycle := 20;         (* 20 x 50 ms = 1 s *)
    MB_CHANNELS[0].iWR := MB_READ_WRITE;
    MB_CHANNELS[0].iPort := MB_PORT_2;
    MB_CHANNELS[0].xWriteOnChange := TRUE;

    (* Channel 1 - register, read-only, on demand (device 2, port 3). *)
    MB_CHANNELS[1].xEnabled := TRUE;
    MB_CHANNELS[1].iDDevNum := 610;      (* D610 - value buffer *)
    MB_CHANNELS[1].iNum := 3;
    MB_CHANNELS[1].iReg := K16385;
    MB_CHANNELS[1].iRF := H3;            (* read holding registers *)
    MB_CHANNELS[1].iWF := H6;            (* unused - channel is read-only *)
    MB_CHANNELS[1].iDev := H2;
    MB_CHANNELS[1].tCycle := 0;          (* manual only *)
    MB_CHANNELS[1].iWR := MB_READ;
    MB_CHANNELS[1].iPort := MB_PORT_3;

    (* Channel 2 - coils, read/write (device 3, port 2). *)
    MB_CHANNELS[2].xEnabled := TRUE;
    MB_CHANNELS[2].iDDevNum := 500;      (* M500 - coil channel uses M space *)
    MB_CHANNELS[2].iNum := 8;
    MB_CHANNELS[2].iReg := K0;
    MB_CHANNELS[2].iRF := H1;            (* read coils *)
    MB_CHANNELS[2].iWF := H5;            (* write single coil *)
    MB_CHANNELS[2].iDev := H3;
    MB_CHANNELS[2].tCycle := 10;         (* 10 x 50 ms = 500 ms *)
    MB_CHANNELS[2].iWR := MB_READ_WRITE;
    MB_CHANNELS[2].iPort := MB_PORT_2;
    MB_CHANNELS[2].xWriteOnChange := TRUE;
END_IF;

(* Channel scheduler - call every scan. *)
fbMbProcess(mb_xEnable := TRUE, mb_iBuffer := 200);

(* On-demand read of channel 1 (register, read-only). *)
IF M1 THEN
    MB_CHANNELS[1].xReadOnce := TRUE;
    IF MB_CHANNELS[1].xDone THEN
        M1 := FALSE;
        MB_CHANNELS[1].xReadOnce := FALSE;
    END_IF;
END_IF;

(* Demo: write a value to channel 0 - written immediately (xWriteOnChange). *)
IF M2 THEN
    g_iAutoReg0 := 1234;
    M2 := FALSE;
END_IF;

(* Demo: toggle a coil on channel 2 - written immediately (xWriteOnChange). *)
IF M3 THEN
    g_xCoil0 := NOT g_xCoil0;
    M3 := FALSE;
END_IF;
