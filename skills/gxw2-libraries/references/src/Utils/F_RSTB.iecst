(* Reset bit iBN (0-based) in WORD wIn, return modified. Returns WORD. *)
iBN2 := F_LIMIT(K0, iBN, K15);
wTmp := 2#1111_1111_1111_1110;
ROL(TRUE, iBN2, wTmp);
F_RSTB := wIn AND wTmp;
