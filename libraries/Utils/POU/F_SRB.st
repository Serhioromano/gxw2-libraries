(* Set/reset bit iBN in WORD wIn by xState. Returns WORD. *)
iBN2 := F_LIMIT(K0, iBN, K15);
IF xState THEN
	wTmp := 2#0000_0000_0000_0001;
	ROL(TRUE, iBN2, wTmp);
	F_SRB := wIn OR wTmp;
ELSE
	wTmp := 2#1111_1111_1111_1110;
	ROL(TRUE, iBN2, wTmp);
	F_SRB := wIn AND wTmp;
END_IF;
