(* Write L02 IP settings (Init, wts, IP1..IP4). Returns BOOL. *)
IF Init THEN
	Z5 := wts;
	R0Z5 := 0;
	tmp := IP1;
	ROL(TRUE, 8, tmp);
	R0Z5 := tmp OR IP2;
	
	Z5 := wts + 1;
	R0Z5 := 0;
	tmp := IP3;
	ROL(TRUE, 8, tmp);
	R0Z5 := tmp OR IP4;
END_IF;
