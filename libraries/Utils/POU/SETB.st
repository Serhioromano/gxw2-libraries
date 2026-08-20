(* Set bit BN (0-based) in WORD IN, return modified. Returns WORD. *)
BN2 := LIMIT(0,BN,15);
tmp := 2#0000_0000_0000_0001;
ROL(TRUE, BN2, tmp);
SETB := IN OR tmp;
