(* Move iNum words from iSrc to iDst on xEnable. Returns BOOL. *)
IF xEnable THEN
	FOR iCount := 0 TO iNum - 1 DO
		Z3 := iSrc + iCount;
		Z4 := iDst + iCount;
		M0Z4 := M0Z3;
	END_FOR;
END_IF;
