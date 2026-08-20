(* Clamp IN to range MIN..MAX. Returns INT. *)
LIMIT := IN;
MOV(IN > MAX, MAX, LIMIT);
MOV(IN < MIN, MIN, LIMIT);