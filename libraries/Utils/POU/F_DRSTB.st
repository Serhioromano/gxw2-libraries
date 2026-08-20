(* Reset bit iBN (0-based) in DWORD dwIn, return modified. Returns DWORD. *)
dwTmp := 2#1111_1111_1111_1111_1111_1111_1111_1110;
iBN2 := F_LIMIT(0, iBN, 31);
ROL(TRUE, iBN2, dwTmp);
F_DRSTB := dwIn AND dwTmp;
