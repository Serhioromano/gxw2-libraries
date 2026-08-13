TP1(IN := MEP(IN), PT := T#500ms);
IF TP1.Q THEN
	FOR iCount := 0 TO AM_EVENTS_NUM DO
		IF 
			AM_EVENTS[iCount].Event
			AND NOT AM_EVENTS[iCount].State
		THEN
			AM_EVENTS[iCount].Event := FALSE;
		END_IF;
	END_FOR;
END_IF;
RST(MEF(TP1.Q), IN);

