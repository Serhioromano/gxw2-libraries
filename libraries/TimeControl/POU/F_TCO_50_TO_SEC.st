(* Convert 50 ms ticker count to seconds: ticks / 20 *)
F_TCO_50_TO_SEC := DINT_TO_INT(DWORD_TO_DINT(dwTicker) / 20);
