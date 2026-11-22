(* Set bit iBN (0-based) in WORD wIn, return modified. Returns WORD. *)
iBN2 := F_LIMIT(0, iBN, 15);
wTmp := 2#0000_0000_0000_0001;
ROL(TRUE, iBN2, wTmp);
F_SETB := wIn OR wTmp;
