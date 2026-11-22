(* Convert 50 ms ticker count to TIME (milliseconds): ticks * 50.
   DMUL works on the raw DWORD value, keeping the full ticker range. *)
DMUL(TRUE, dwTicker, 50, dwQuot);
F_TCO_50_TO_TIME := DWORD_TO_TIME(dwQuot[0]);
