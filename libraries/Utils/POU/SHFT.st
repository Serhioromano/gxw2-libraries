(* Shift IDX by SHIFTER within 0..MAX (wrap). Returns INT. *)
SHFT := SHIFTER + IDX;
IF SHFT > MAX THEN
	SHFT := SHFT - (MAX+1);	
END_IF;
