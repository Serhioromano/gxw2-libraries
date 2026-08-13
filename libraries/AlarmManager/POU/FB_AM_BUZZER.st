AC := 0;
FOR iCount := 0 TO c_AM_ALARMS_NUM DO
	INC(AM_ALARMS[iCount].Alarm AND AM_ALARMS[iCount].Buzzer, AC);
END_FOR;
SET(AC > ACM, Q);
RST(Reset, Q);
RST(Reset, Reset);
ACM := AC;