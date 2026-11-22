(*
b0 Data length 0: 7 bits 1: 8 bits
b1 b2 Parity (b2,b1) 00: None; 01: Odd; 11: Even
b3 Stop bit 0:1 bit 1: 2 bits
b4 b5 b6 b7 Baud rate (b7,b6,b5,b4)
(0100):600bps (0101):1200bps (0110):2400bps
(0111):4800bps (1000):9600bps (1001):19200bps
(1010):38400bps (1011):57600bps (1101):115200bps
b8 Set 0
b9 b10 b11 b12 Set 0
b13 Set 1
b14 Set 1
b15 Set 0
*)

IF MEP(xInit) THEN
	M8196 := FALSE; (* mitsubishi protocol *)
	M8125 := FALSE; (* Mitsubishi  protocol *)
	D8120 := 2#0110_0000_1010_0110; (* 38400/7/E/1 *)
	D8121 := 1;
END_IF;
MTB_SLAVE_PORT2 := TRUE;