iEN := LIMITATION(0, EventNum, c_AM_EVENTS_NUM);

EVENT := AM_EVENTS[iEN];

EVENT.State := EventState;
SET(EVENT.State, EVENT.Event);
RST(EVENT.Event
	AND NOT EventLatch
	AND NOT EventState, 
	EVENT.Event
);

AM_EVENTS[iEN] := EVENT;