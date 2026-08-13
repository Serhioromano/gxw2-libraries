IF MEP(xInit) THEN
	temp:= DSETB(PortSettings, 13);
	temp:= DSETB(temp, 14);
	temp:= DSETB(temp, 15);
	DMOV(TRUE, temp, D8400);
	D8414 := 255; (* Address station *)
	D8126 := 1; (* ADPRW command *)
	D8397 := 1;  (* Use PORT3 for ADPRW *)
	M8192 := TRUE;
	D8401 := H1; (* Modbus master *)
END_IF;
MB_MASTER_INIT_PORT3 := xInit;