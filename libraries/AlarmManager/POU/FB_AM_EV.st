AM_EVENTS[EventNum].State := EventState;
IF (NOT EventLatch) OR (EventLatch AND AM_EVENTS[EventNum].State AND NOT AM_EVENTS[EventNum].StateM) THEN
	AM_EVENTS[EventNum].Event := TRUE;
END_IF;
AM_EVENTS[EventNum].StateM := AM_EVENTS[EventNum].State;

IF (NOT EventLatch AND NOT AM_EVENTS[EventNum].State) THEN
	AM_EVENTS[EventNum].Event := FALSE;
END_IF;


