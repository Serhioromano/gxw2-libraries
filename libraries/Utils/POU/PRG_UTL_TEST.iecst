(*
  Utils library smoke test.

  Calls every function (F_*) and function block (FB_*) of the Utils library
  with representative test inputs. Results are stored in auto-assigned labels
  so they can be watched in the device monitor.

  Functions exercised:
    F_ISBON / F_DISBON / F_SETB / F_DSETB / F_RSTB / F_DRSTB / F_SRB / F_DSRB
    F_LIMIT / F_SCALE / F_SCALE_NL / F_INCN / F_SHFT
    F_WORK_LEFT / F_WORK_LEFT_TIME / F_VALVE_POS / F_FLT10
    F_L02_SET_IP / F_MBMOV

  Function blocks exercised:
    FB_HYST / FB_HYST_COOL / FB_SCALE_AI / FB_L02_SCALE_AI / FB_VALVE_3P

  Notes:
    - FB_VALVE_3P uses the TCO_DINT_50 ticker and therefore requires the
      TimeControl library with its TCO timer setup.
    - F_L02_SET_IP, F_MBMOV and F_SCALE_NL write to R / D devices.
    - Force the xSaveIp / xValveEnable inputs and watch the result labels.
*)

(* --- Bit check / bit manipulation functions --- *)
xIsOnWord  := F_ISBON(16#0004, 2);
xIsOnDword := F_DISBON(16#00000004, 2);

wSetWord  := F_SETB(16#0000, 3);
dwSetWord := F_DSETB(16#00000000, 3);

wRstWord  := F_RSTB(16#000F, 2);
dwRstWord := F_DRSTB(16#0000000F, 2);

wSrbWord  := F_SRB(16#0000, 5, TRUE);
dwSrbWord := F_DSRB(16#00000000, 5, TRUE);

(* --- Value / index functions --- *)
iLimit     := F_LIMIT(100, 150, 0);
iScale     := F_SCALE(50, 0, 100, 0, 1000);
iScaleNl   := F_SCALE_NL(2, 100, 50);  (* writes D100..D103 *)

iIncrement := F_INCN(TRUE, 2, 5);
iShift     := F_SHFT(2, 4, 5);

(* --- Progress / time functions --- *)
iWorkLeft     := F_WORK_LEFT(25, 100);
iWorkLeftTime := F_WORK_LEFT_TIME(T#25s, T#100s);
iValvePos     := F_VALVE_POS(T#5s, T#10s);

(* --- Filter function (returns REAL) --- *)
rFlt10 := F_FLT10(123);

(* --- Setup / command functions (device side effects) --- *)
(* Writes IP 192.168.0.100 to R23807/R23808 while xSaveIp is TRUE *)
xSetIp := F_L02_SET_IP(xSaveIp, IP_PLC_IP, 16#00C0, 16#00A8, 16#0000, 16#0064);

(* Copies 4 words D100..D103 to D200..D203 every scan *)
xMbmov := F_MBMOV(TRUE, 100, 4, 200);

(* --- Function blocks --- *)
(* Heating regulator: turns off when iPV < iSV *)
fbHyst(xIn := TRUE, iSV := 250, iPV := 200, iDV := 5, xQ := xHystQ);

(* Cooling regulator: turns off when iPV > iSV *)
fbHystCool(xIn := TRUE, iSV := 250, iPV := 200, iDV := 5, xQ := xHystCoolQ);

(* Analog input scaling (host PLC, D8030 area) *)
fbScaleAI(iAINum := 0, iSType := STYPE_4_20MA, iMin := 0, iMax := 160,
    iFilterTime := 10, iFilterNum := 100, iCorrection := 0,
    iValueOut := iScaleAIValue, xErrWire := xScaleAIWire,
    xErrLimit := xScaleAILimit, xErrMinMax := xScaleAIMinMax);

(* Analog input scaling (L02 modules, R23700 area) *)
fbL02ScaleAI(iAINum := 0, iSType := STYPE_4_20MA, iMin := 0, iMax := 160,
    iCorrection := 0, iValueOut := iL02ScaleAIValue);

(* 3-position valve control with position feedback *)
fbValve3P(xEnable := xValveEnable, iSV := 500, iDlt := 20,
    tTotalTime := T#10s, tLuftTime := T#500ms,
    xCloseOnDisable := TRUE, xIsOpened := FALSE, xIsClosed := FALSE,
    xOpen := xValveOpen, xClose := xValveClose);
