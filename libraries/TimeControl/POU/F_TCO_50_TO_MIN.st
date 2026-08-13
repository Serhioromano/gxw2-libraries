(* Convert 50 ms ticker count to minutes: ticks / 1200 *)
F_TCO_50_TO_MIN := DINT_TO_INT(DWORD_TO_DINT(dwTicker) / 1200);
