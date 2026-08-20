(* Increment iCur within 0..iMax (wrap) when xIn is TRUE. Returns INT. *)
F_INCN := iCur;
IF xIn THEN
	F_INCN := iCur + 1;
	IF F_INCN > iMax THEN
		F_INCN := 0;
	END_IF;
END_IF;
