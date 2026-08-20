(* Non-linear scale PV through points at DSTART. Returns INT. *)
Z5 := DSTART;
D0Z5 := PN;

FOR iCount := 1 TO PN DO
	j := PN - iCount;
	Z5 := DSTART + j;
	IF (PV >= D0Z5) THEN
		Z6 := Z5 + 1;
		Z4 := Z5 + PN;
		Z7 := Z6 + PN;
		SCALE_NL := SCALE(PV, D0Z5, D0Z6, D0Z4, D0Z7);
		EXIT;
	END_IF;
END_FOR;
(*
Z3 := DSTART + PN + 1;
Z4 := Z3 + PN - 1;
SCALE_NL := SCALE_NL;
*)