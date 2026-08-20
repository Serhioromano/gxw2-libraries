IF MEP(xInit) THEN
	DMOV(TRUE, PortSettings, D8400);;
	D8401 := H11; (* Modbus RTU slave *)
	D8414 := iAddress; (* Address station *)
	D8126 := 1;
	D8397 := 1;
	M8192 := TRUE;
	D8411 := K10; (* Message to message delay 10ms *)
END_IF;
MB_SLAVE_INIT_PORT3 := TRUE;