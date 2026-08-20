(* Set/reset bit iBN in DWORD dwIn by xState. Returns DWORD. *)
iBN2 := LIMITATION(0, iBN, 31);
IF xState THEN
	dwTmp := 2#0000_0000_0000_0000_0000_0000_0000_0001;
	DROL(TRUE, iBN2, dwTmp);
	F_DSRB := dwIn OR dwTmp;
ELSE
	dwTmp := 2#1111_1111_1111_1111_1111_1111_1111_1110;
	DROL(TRUE, iBN2, dwTmp);
	F_DSRB := dwIn AND dwTmp;
END_IF;
