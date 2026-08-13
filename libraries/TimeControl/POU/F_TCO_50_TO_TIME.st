(* Convert 50 ms ticker count to TIME (milliseconds): ticks * 50 *)
F_TCO_50_TO_TIME := DINT_TO_TIME(DWORD_TO_DINT(dwTicker) * 50);
