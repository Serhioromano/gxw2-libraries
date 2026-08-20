(* Increment CUR within 0..MAX (wrap) when IN is TRUE. Returns INT. *)
INCN := CUR;
IF IN THEN
	INCN := CUR + 1;
	IF INCN > MAX THEN
		INCN := 0;
	END_IF;
END_IF;
