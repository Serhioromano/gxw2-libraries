(* Convert 50 ms ticker count to seconds: ticks / 20.
   DDIV works on the raw DWORD value, keeping the full ticker range. *)
DDIV(TRUE, dwTicker, 20, dwQuot);
F_TCO_50_TO_SEC := DWORD_TO_INT(dwQuot);
