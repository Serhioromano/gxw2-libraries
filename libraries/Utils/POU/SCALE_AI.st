Z3    := LIMITATION(0,AINum,16);
iTemp := D8030Z3;

MOV(M8002, SType, R23940Z3);
MOV(M8002, LIMITATION(2, SEL(FilterNum = 0, FilterNum, 100), 20000), R23600Z3);
MOV(M8002, LIMITATION(2, FilterTime, 60), D8020Z3);

ErrLimit  := FALSE;
ErrWire   := FALSE;
ErrMinMax := FALSE;

SET(iTemp = 32760, ErrWire);
SET((Min >= Max), ErrLimit);
SET(((SType = STYPE_0_10V OR SType = STYPE_0_20MA OR SType = STYPE_4_20MA) AND Min = Max AND Min = 0), ErrMinMax);

ValueOut := SEL(
	(ErrMinMax OR ErrLimit OR ErrWire), 
	SEL(
		(SType = STYPE_0_10V OR SType = STYPE_0_20MA OR SType = STYPE_4_20MA), 
		iTemp, 
		SCALE(iTemp,0,4000,Min,Max)
	) + Correction,
	0
);
