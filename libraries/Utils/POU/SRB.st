(* Set/reset bit iBN in WORD IN by xState. Returns WORD. *)
iBN2 := LIMIT(K0, iBN, K15);
IF xState THEN
	tmp := 2#0000_0000_0000_0001;
	ROL(TRUE, iBN2, tmp);
	SRB := IN OR tmp;
ELSE
	tmp := 2#1111_1111_1111_1110;
	ROL(TRUE, iBN2, tmp);
	SRB := IN AND tmp;
END_IF;
