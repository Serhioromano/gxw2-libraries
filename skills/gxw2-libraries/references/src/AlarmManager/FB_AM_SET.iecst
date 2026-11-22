iAN := LIMITATION(0, iNum, c_AM_ALARMS_NUM);

ALARM := AM_ALARMS[iAN];
ALARM.State := xState;

DMOV(
	ALARM.State
	AND NOT ALARM.Alarm
	AND NOT ALARM.StateM, 
	TCO_DINT_50, 
	ALARM.TimerStart
);

SET(
	NOT ALARM.Alarm
	AND ALARM.State
	AND F_AM_DELAY_OUT(
		ALARM.TimerStart, 
		TCO_DINT_50, 
		ALARM.Delay
	),
	ALARM.Alarm
);

RST(
	ALARM.Alarm
	AND NOT ALARM.Latch
	AND NOT ALARM.State,
	ALARM.Alarm
);

ALARM.StateM := ALARM.State;

AM_ALARMS[iAN] := ALARM;
