(* Check if bit iBN (0-based) in DWORD dwIn is ON. Returns BOOL. *)
iBN2 := F_LIMIT(K0, iBN, K31);
DBON(TRUE, dwIn, iBN2, xTmp);
F_DISBON := xTmp;
