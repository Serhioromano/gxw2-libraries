ALARM := AM_ALARMS[iNum];
ALARM.State := xState;

DMOV(
	ALARM.State
	AND NOT ALARM.Alarm
	AND NOT ALARM.StateM
	AND ALARM.Delay > 0, 
	TCO_DINT_50, 
	ALARM.TimerStart
);

SET(
	NOT ALARM.Alarm
	AND ALARM.State
	AND AM_DELAY_OUT(
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

AM_ALARMS[iNum] := ALARM;
