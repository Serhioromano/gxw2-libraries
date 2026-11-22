(*
  FB_AM_BUZZER - Buzzer request for alarms tagged with xBuzzer.

  Counts the alarms that are currently registered (Alarm = TRUE) and
  flagged for buzzer activation (Buzzer = TRUE). Q is latched ON when
  this count increases compared with the previous scan, i.e. a new
  buzzing alarm has just appeared. Q stays ON until the Reset input
  (operator silence button) acknowledges it.

  I/O:
    Reset  (IN_OUT, BOOL) - TRUE silences the buzzer; the FB clears it
                            itself so it behaves as a one-scan pulse.
    Q      (OUTPUT, BOOL) - TRUE = buzzer requested (latched until Reset).
    AC     (OUTPUT, INT)  - Current number of buzzing alarms (>= 0).

  Internals:
    iCount - FOR loop index over the alarm array (0..c_AM_ALARMS_NUM).
    ACM    - Buzzer count from the previous scan (edge memory for Q).
*)

(* Restart the count before scanning the alarm array *)
AC := 0;

(*
  Count every alarm that is registered AND tagged for buzzer activation.
  INC increments AC by 1 for each slot where both flags are TRUE.
*)
FOR iCount := 0 TO c_AM_ALARMS_NUM DO
	INC(AM_ALARMS[iCount].Alarm AND AM_ALARMS[iCount].Buzzer, AC);
END_FOR;

(* Latch Q ON when the buzzing-alarm count rose since the last scan *)
SET(AC > ACM, Q);

(* Acknowledge: operator reset (silence) clears the latched output *)
RST(Reset, Q);

(*
  Self-clear Reset so it acts as an edge-triggered pulse; a held reset
  would otherwise keep Q permanently silent.
*)
RST(Reset, Reset);

(* Remember the current count for the next scan (edge detection) *)
ACM := AC;