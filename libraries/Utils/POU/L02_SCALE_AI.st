(* 1. Select channel: clamp iAINum 0..50 into index register Z3 *)
Z3 := LIMITATION(0, iAINum, 50);

(* 2. Write sensor type to the channel configuration register *)
MOV(M8002, iSType, R23500Z3);

(* 3. Read raw value from the channel register *)
iTemp := R23700Z3;

(* 4. Scale scalable types, otherwise return raw value *)
iValueOut := SEL(
    (iSType = STYPE_0_10V OR iSType = STYPE_0_20MA OR iSType = STYPE_4_20MA),
    iTemp,
    SEL(
        iMin = iMax,
        F_SCALE(iTemp, 0, 32000, iMin, iMax),
        iMin
    )
) + iCorrection;
