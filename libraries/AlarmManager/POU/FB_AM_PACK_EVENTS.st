iRegisters := c_AM_EVENTS_NUM / 16;

iTCounter := 0;
FOR iCount := 0 TO iRegisters DO
	Z5 := DNUM + iCount;
	wTemp := 0;
	FOR iCount2 := 0 TO 15 DO
		IF iTCounter > c_AM_EVENTS_NUM THEN
			EXIT; (* all events already packed; leave remaining bits zero *)
		END_IF;
		wTemp := SRB(wTemp, iCount2, AM_EVENTS[iTCounter].Event);
		INC(TRUE, iTCounter);
	END_FOR;
	
	IF PD = c_AM_PACK_D THEN
		D0Z5 := wTemp;
	ELSE
		R0Z5 := wTemp;
	END_IF;
END_FOR;
