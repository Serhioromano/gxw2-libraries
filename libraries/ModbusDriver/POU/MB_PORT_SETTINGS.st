temp := DSRB(temp, 0, TRUE); 
temp := DSRB(temp, 13, TRUE);
temp := DSRB(temp, 14, TRUE);
temp := DSRB(temp, 15, TRUE);

IF Parity = 1 THEN (* ODD *)
	temp := DSRB(temp, 1, TRUE);
END_IF;

IF Parity = 2 THEN (* EVEN *)
	temp := DSRB(temp, 1, TRUE);
	temp := DSRB(temp, 2, TRUE);
END_IF;

IF StopBit = 1 THEN
	temp := DSRB(temp, 3, TRUE);
END_IF;

CASE Baudrate OF
0:
	temp := DSRB(temp, 6, TRUE);
1:
	temp := DSRB(temp, 4, TRUE);
	temp := DSRB(temp, 6, TRUE);
2:
	temp := DSRB(temp, 5, TRUE);
	temp := DSRB(temp, 6, TRUE);
3:
	temp := DSRB(temp, 4, TRUE);
	temp := DSRB(temp, 5, TRUE);
	temp := DSRB(temp, 6, TRUE);
4:
	temp := DSRB(temp, 7, TRUE);
5:
	temp := DSRB(temp, 4, TRUE);
	temp := DSRB(temp, 7, TRUE);
6:
	temp := DSRB(temp, 5, TRUE);
	temp := DSRB(temp, 7, TRUE);
7:
	temp := DSRB(temp, 4, TRUE);
	temp := DSRB(temp, 5, TRUE);
	temp := DSRB(temp, 7, TRUE);
8:
	temp := DSRB(temp, 6, TRUE);
	temp := DSRB(temp, 7, TRUE);
END_CASE;

MB_PORT_SETTINGS := temp;
