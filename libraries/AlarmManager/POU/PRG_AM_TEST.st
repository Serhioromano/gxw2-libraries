(*
  AlarmManager smoke test (V206).

  Registers three alarms (IDs 0..2) under manual test inputs and exercises
  every alarm function block of the library:
    FB_AM_INIT / FB_AM_SET / FB_AM_ORISON / FB_AM_RESET
    FB_AM_HAS_ALARMS / FB_AM_IS_BLOCK / FB_AM_BUZZER / FB_AM_PACK_ALARMS

  Storage (AM_ALARMS, AM_EVENTS) and capacity constants
  (c_AM_ALARMS_NUM, c_AM_EVENTS_NUM) are declared globally in GVL_AM_TEST
  per the user-defined storage model. All test labels are auto-assigned by
  the compiler; force the condition inputs and watch the result labels in
  the device monitor.
*)

(* One-time alarm configuration on the initial pulse *)
IF M8002 THEN
    fbAMInit(iNum := 0, iSeverity := c_AM_WARNING, iProcess := 1, iDelay := 10,
        xLatch := FALSE, xBuzzer := TRUE, xLock := FALSE);
    fbAMInit(iNum := 1, iSeverity := c_AM_ERROR, iProcess := 1, iDelay := 0,
        xLatch := TRUE, xBuzzer := TRUE, xLock := TRUE);
    fbAMInit(iNum := 2, iSeverity := c_AM_ERROR, iProcess := 2, iDelay := 3,
        xLatch := TRUE, xBuzzer := FALSE, xLock := TRUE);
END_IF;

(* Evaluate the three alarm conditions every scan *)
fbAMSet(iNum := 0, xState := xCondAlarm0);
fbAMSet(iNum := 1, xState := xCondAlarm1);
fbAMSet(iNum := 2, xState := xCondAlarm2);

(* Single-alarm state queries - direct array access *)
xIsOn0 := AM_ALARMS[0].Alarm;
xIsOn1 := AM_ALARMS[1].Alarm;
xIsOn2 := AM_ALARMS[2].Alarm;

(* OR-combined query: alarm 0 OR alarm 2 *)
xOrIsOn := FALSE;
fbAMOrIsOn(iNum := 0, Q := xOrIsOn);
fbAMOrIsOn(iNum := 2, Q := xOrIsOn);

(* One-second reset window, driven by the manual reset input *)
fbAMReset(IN := xReset);

(* Filtered presence queries: count and flag per process / severity *)
fbHasAlarm(iProcessNum := 0, iSeverity := 0, AC := iCntAll, Q := xHasAll);
fbHasAlarm(iProcessNum := 1, iSeverity := 0, AC := iCntProc1, Q := xHasProc1);
fbHasAlarm(iProcessNum := 0, iSeverity := c_AM_ERROR, AC := iCntErr, Q := xHasErr);
fbHasAlarm(iProcessNum := 2, iSeverity := c_AM_ERROR, AC := iCntProc2Err, Q := xHasProc2Err);

(* Blocking-alarm queries *)
fbIsBlock(iProcessNum := 0, iSeverity := 0, AC := iBlkAll, Q := xBlkAll);
fbIsBlock(iProcessNum := 2, iSeverity := 0, AC := iBlkProc2, Q := xBlkProc2);

(* Buzzer query *)
fbBuzzer(Reset := xBuzzerReset, Q := xBuzzer, AC := iBuzzerCnt);

(* Pack alarm states into R and D register blocks starting at 6000 *)
fbAmPack(DNUM := 6000, PD := c_AM_PACK_R);
iPackR := R6000;

fbAmPack(DNUM := 6000, PD := c_AM_PACK_D);
iPackD := D6000;

(* Copy the packed word to M bits for HMI-style bit reads *)
BMOV(TRUE, D6000, 1, K4M6000);

xPacked0 := M6000;
xPacked1 := M6001;
xPacked2 := M6002;
