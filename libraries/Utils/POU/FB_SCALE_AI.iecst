(* Select channel: clamp iAINum 0..16 into index register Z3 *)
Z3    := LIMITATION(0, iAINum, 16);
iTemp := D8030Z3;

(* Configure sensor type, filter count and filter time *)
MOV(M8002, iSType, R23940Z3);
MOV(M8002, LIMITATION(2, SEL(iFilterNum = 0, iFilterNum, 100), 20000), R23600Z3);
MOV(M8002, LIMITATION(2, iFilterTime, 60), D8020Z3);

xErrLimit  := FALSE;
xErrWire   := FALSE;
xErrMinMax := FALSE;

(* Detect wire break, bad limits and min=max on scalable types *)
SET(iTemp = 32760, xErrWire);
SET((iMin >= iMax), xErrLimit);
SET(((iSType = STYPE_0_10V OR iSType = STYPE_0_20MA OR iSType = STYPE_4_20MA) AND iMin = iMax AND iMin = 0), xErrMinMax);

(* Output scaled value, 0 on error *)
iValueOut := SEL(
	(xErrMinMax OR xErrLimit OR xErrWire),
	SEL(
		(iSType = STYPE_0_10V OR iSType = STYPE_0_20MA OR iSType = STYPE_4_20MA),
		iTemp,
		F_SCALE(iTemp, 0, 4000, iMin, iMax)
	) + iCorrection,
	0
);
