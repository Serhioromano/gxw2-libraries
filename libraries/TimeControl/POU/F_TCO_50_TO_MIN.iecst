(* Convert 50 ms ticker count to minutes: ticks / 1200.
   DDIV works on the raw DWORD value, keeping the full ticker range. *)
DDIV(TRUE, dwTicker, 1200, dwQuot);
F_TCO_50_TO_MIN := DWORD_TO_INT(dwQuot[0]);
