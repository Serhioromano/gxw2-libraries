IF MEP(xWriteMB) THEN
	MB_CHANNELS[2].xWriteOnce := TRUE;	
	MB_CHANNELS[3].xWriteOnce := TRUE;	
	MB_CHANNELS[4].xWriteOnce := TRUE;	
	MB_CHANNELS[5].xWriteOnce := TRUE;	
	xWrite1 := FALSE;
	xWrite2 := FALSE;
	xWrite3 := FALSE;
	xWrite4 := FALSE;
END_IF;

IF MB_CHANNELS[2].xDone OR AM_ALARMS[48].Alarm THEN
   MB_CHANNELS[2].xReadOnce := FALSE;
   xRead1 := TRUE;
END_IF;

IF MB_CHANNELS[3].xDone OR AM_ALARMS[49].Alarm THEN
   MB_CHANNELS[3].xReadOnce := FALSE;
   xRead2 := TRUE;
END_IF;

IF MB_CHANNELS[4].xDone OR AM_ALARMS[50].Alarm THEN
   MB_CHANNELS[4].xReadOnce := FALSE;
   xRead3 := TRUE;
END_IF;

IF MB_CHANNELS[5].xDone OR AM_ALARMS[51].Alarm THEN
   MB_CHANNELS[5].xReadOnce := FALSE;
   xRead4 := TRUE;
END_IF; 

RST(xReadMB AND xRead1 AND xRead2 AND xRead3 AND xRead4, xReadMB);


RST(xWriteMB 
	AND (xWrite1 OR AM_ALARMS[48].Alarm)
	AND (xWrite2 OR AM_ALARMS[49].Alarm)
	AND (xWrite3 OR AM_ALARMS[50].Alarm)
	AND (xWrite4 OR AM_ALARMS[51].Alarm), 
	xWriteMB
);
