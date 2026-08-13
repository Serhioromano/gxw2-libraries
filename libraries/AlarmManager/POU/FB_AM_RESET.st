fbTPReset(IN := MEP(IN), PT := T#500ms);
IF fbTPReset.Q THEN
	FOR iCount := 0 TO c_AM_ALARMS_NUM DO
		IF 
			AM_ALARMS[iCount].Alarm 
			AND AM_ALARMS[iCount].Latch
			AND NOT AM_ALARMS[iCount].State
		THEN
			AM_ALARMS[iCount].Alarm := FALSE;
		END_IF;
	END_FOR;
END_IF;
RST(MEF(fbTPReset.Q), IN);
