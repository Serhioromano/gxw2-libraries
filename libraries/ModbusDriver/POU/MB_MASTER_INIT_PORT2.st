IF MEP(xInit) THEN
	temp:= DSETB(PortSettings, 13);
	temp:= DSETB(temp, 14);
	temp:= DSETB(temp, 15);
	DMOV(TRUE, temp, D8120);;
	D8121 := 0; (* Address station *)
	D8126 := 0; (* ADPRW command *)
	D8397 := 0;  (* Use PORT2 for ADPRW *)
	M8196 := TRUE;
	M8125 := TRUE;
END_IF;
MB_MASTER_INIT_PORT2 := xInit;
