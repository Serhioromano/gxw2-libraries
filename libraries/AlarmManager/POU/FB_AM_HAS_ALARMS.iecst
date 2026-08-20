AC := 0;
FOR iCount := 0 TO c_AM_ALARMS_NUM DO
	INC(
		(AM_ALARMS[iCount].Sevirity = iSeverity OR iSeverity = 0) 
		AND 
		(AM_ALARMS[iCount].Process = iProcessNum OR iProcessNum = 0)
		AND AM_ALARMS[iCount].Alarm, 
		AC
	);
END_FOR;
Q := AC > 0;