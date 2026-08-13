(* 10 ms ticker: run this program in an interrupt task (event I610).
   Increments the global ticker TCO_DINT_10 once per task scan. *)
DINC(TRUE, TCO_DINT_10);
