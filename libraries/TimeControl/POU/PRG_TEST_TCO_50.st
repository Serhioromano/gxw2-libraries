EI(TRUE);

fbBlink(IN := TRUE, TIMELOW := 40, TIMEHIGH := 40, Q := xbit1);
fbDBlink(IN := TRUE, TIMELOW := 60, TIMEHIGH := 60, Q := xbit2);
fbTON128(NUM := 0, IN := xbit3, PT := 40, MEM := FALSE, Q := xbit4, ET := dui3);
fbTON128(NUM := 1, IN := xbit3, PT := 80, MEM := FALSE, Q := xbit5, ET := dui4);


di1 := DTCO_50_TO_SEC(TCO_DINT_50);
di2 := DTCO_50_TO_100MS(TCO_DINT_50);
di3 := DTCO_50_TO_MIN(TCO_DINT_50);

ii1 := TCO_50_TO_SEC(TCO_INT_50);
ii2 := TCO_50_TO_100MS(TCO_INT_50);
ii3 := TCO_50_TO_MIN(TCO_INT_50);

ui1 := SEC_TO_TCO_50(50);
dui1 := DSEC_TO_TCO_50(50);

dui2 := DMIN_TO_TCO_50(10);