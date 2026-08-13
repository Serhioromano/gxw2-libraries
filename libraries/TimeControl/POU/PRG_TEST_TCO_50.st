(* Test program for the TimeControl library. *)
fbBlink(xIn := TRUE, dwTimeLow := 40, dwTimeHigh := 40, xQ := xbit1);
fbBlink2(xIn := TRUE, dwTimeLow := 60, dwTimeHigh := 60, xQ := xbit2);

ii1 := F_TCO_50_TO_SEC(TCO_DINT_50);
ii2 := F_TCO_50_TO_100MS(TCO_DINT_50);
ii3 := F_TCO_50_TO_MIN(TCO_DINT_50);
di1 := F_TCO_50_TO_MS(TCO_DINT_50);

dui1 := F_SEC_TO_TCO_50(50);
dui2 := F_MIN_TO_TCO_50(10);

dwDiff := F_TCO_50_DIFF(dwStart, TCO_DINT_50);

t1 := F_SEC_TO_TIME(60);
t2 := F_MIN_TO_TIME(1);
