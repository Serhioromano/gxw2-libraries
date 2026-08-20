(* Non-linear scale iPv through points at iDStart. Returns INT. *)
Z5 := iDStart;
D0Z5 := iPN;

FOR iCount := 1 TO iPN DO
	iJ := iPN - iCount;
	Z5 := iDStart + iJ;
	IF (iPV >= D0Z5) THEN
		Z6 := Z5 + 1;
		Z4 := Z5 + iPN;
		Z7 := Z6 + iPN;
		F_SCALE_NL := F_SCALE(iPV, D0Z5, D0Z6, D0Z4, D0Z7);
		EXIT;
	END_IF;
END_FOR;
(*
Z3 := iDStart + iPN + 1;
Z4 := Z3 + iPN - 1;
F_SCALE_NL := F_SCALE_NL;
*)
