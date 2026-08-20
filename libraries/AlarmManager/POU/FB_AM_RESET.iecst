fbTPReset(IN := MEP(IN), PT := T#500ms);
IF fbTPReset.Q OR AutoReset > 0 THEN
	FOR iCount := 0 TO c_AM_ALARMS_NUM DO
		ALARM := AM_ALARMS[iCount];
		IF
			ALARM.Alarm
			AND ALARM.Latch
			AND NOT ALARM.State
		THEN
			AM_ALARMS[iCount].Alarm := NOT (
				fbTPReset.Q
				OR
				(
					ALARM.autoReset
					AND AutoReset > 0 
					AND F_TCO_50_DIFF(ALARM.TimerStart, TCO_DINT_50) 
						>= INT_TO_DWORD(AutoReset * 20)
						
				)
			);
		END_IF;
	END_FOR;
END_IF;
RST(MEF(fbTPReset.Q), IN);
