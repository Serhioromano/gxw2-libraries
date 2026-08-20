(* Move IN_NUM words from IN_SRC to IN_DST on ENABLE. Returns BOOL. *)
IF ENABLE THEN
	FOR iCount := 0 TO IN_NUM - 1 DO
		Z3 := IN_SRC + iCount;
		Z4 := IN_DST + iCount;
		M0Z4 := M0Z3;
	END_FOR;
END_IF;
