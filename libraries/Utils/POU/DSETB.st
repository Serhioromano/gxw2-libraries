(* Set bit BN (0-based) in DWORD IN, return modified. Returns DWORD. *)
BN2 := LIMITATION(K0, BN, K31);
tmp := 2#0000_0000_0000_0000_0000_0000_0000_0001;
DROL(TRUE, BN2, tmp);
DSETB := IN OR tmp;