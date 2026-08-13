(* Convert 50 ms ticker count to 100 ms units: ticks / 2 *)
F_TCO_50_TO_100MS := DINT_TO_INT(DWORD_TO_DINT(dwTicker) / 2);
