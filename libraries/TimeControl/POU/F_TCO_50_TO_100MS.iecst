(* Convert 50 ms ticker count to 100 ms units: ticks / 2.
   DDIV works on the raw DWORD value, keeping the full ticker range. *)
DDIV(TRUE, dwTicker, 2, dwQuot);
F_TCO_50_TO_100MS := DWORD_TO_DINT(dwQuot[0]);
