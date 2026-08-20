(* Check if bit BN (0-based) in DWORD IN is ON. Returns BOOL. *)
BN2 := LIMIT(K0, BN, K31);
DBON(TRUE, IN, BN2, tmp);
DISBON := tmp;
