(* Test program for the TimeControl library: exercises every function and FB. *)

(* Ticker conversions *)
ii1 := F_TCO_50_TO_SEC(TCO_DINT_50);
ii2 := F_TCO_50_TO_100MS(TCO_DINT_50);
ii3 := F_TCO_50_TO_MIN(TCO_DINT_50);
di1 := F_TCO_50_TO_MS(TCO_DINT_50);
t3 := F_TCO_50_TO_TIME(TCO_DINT_50);

(* Duration conversions *)
dui1 := F_SEC_TO_TCO_50(50);
dui2 := F_MIN_TO_TCO_50(10);
ii4 := F_MIN_TO_SEC(5);
t1 := F_SEC_TO_TIME(60);
t2 := F_MIN_TO_TIME(1);

(* Elapsed-time difference *)
IF MEP(xCapture) THEN
    dwStart := TCO_DINT_50;
END_IF;
dwDiff := F_TCO_50_DIFF(dwStart, TCO_DINT_50);

(* Function blocks *)
fbBlink(xIn := TRUE, dwTimeLow := dui1, dwTimeHigh := dui1, xQ := xbit1);
fbBlink2(xIn := TRUE, dwTimeLow := dui2, dwTimeHigh := dui2, xQ := xbit2);

fbTco10(xReset := xResetTco, diMs := diMs10, di01ms := di01ms10);
