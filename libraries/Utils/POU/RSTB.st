(* Reset bit BN (0-based) in WORD IN, return modified. Returns WORD. *)
BN2 := LIMIT(K0, BN, K15);
tmp := 2#1111_1111_1111_1110;
ROL(TRUE, BN2, tmp);
RSTB := IN AND tmp;