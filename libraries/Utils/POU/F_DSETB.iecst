(* Set bit iBN (0-based) in DWORD dwIn, return modified. Returns DWORD. *)
iBN2 := LIMITATION(K0, iBN, K31);
dwTmp := 2#0000_0000_0000_0000_0000_0000_0000_0001;
DROL(TRUE, iBN2, dwTmp);
F_DSETB := dwIn OR dwTmp;
