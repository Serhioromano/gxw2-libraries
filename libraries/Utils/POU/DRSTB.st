(* Reset bit BN (0-based) in DWORD IN, return modified. Returns DWORD. *)
tmp := 2#1111_1111_1111_1111_1111_1111_1111_1110;
BN2 := LIMIT(0, BN, 31);
ROL(TRUE, BN2, tmp);
DRSTB := IN AND tmp;
