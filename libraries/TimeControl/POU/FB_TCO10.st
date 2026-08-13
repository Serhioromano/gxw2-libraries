(* Elapsed-time accumulator with 0.1 ms resolution based on D8010
   (current scan time in 0.1 ms units). Call every scan.
   While xReset is TRUE the accumulator is held at 0. *)
MOV(TRUE, D8010, wScan);
IF xReset THEN
    diTicks := 0;
ELSE
    diTicks := diTicks + WORD_TO_DINT(wScan);
END_IF;

diMs := diTicks / 10;
di01ms := diTicks;
