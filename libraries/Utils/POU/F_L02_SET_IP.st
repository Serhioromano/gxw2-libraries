(* Write L02 IP settings (xInit, iWts, wIp1..wIp4). Returns BOOL. *)
IF xInit THEN
	Z5 := iWts;
	R0Z5 := 0;
	wTmp := wIp1;
	ROL(TRUE, 8, wTmp);
	R0Z5 := wTmp OR wIp2;

	Z5 := iWts + 1;
	R0Z5 := 0;
	wTmp := wIp3;
	ROL(TRUE, 8, wTmp);
	R0Z5 := wTmp OR wIp4;
END_IF;
