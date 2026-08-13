IF IN THEN
	DMOV((NOT INM), TCO_DINT_50, tStart);
	CASE iStep OF
		1: (* HIGH *)
			tTotal := TCO_50_DIFF(tStart, TCO_DINT_50);
			DMOV(tTotal >= TIMEHIGH, TCO_DINT_50, tStart);
			MOV(tTotal >= TIMEHIGH, 0, iStep);
		0: (* LOW *)
			tTotal := TCO_50_DIFF(tStart, TCO_DINT_50);
			DMOV(tTotal >= TIMELOW , TCO_DINT_50, tStart);
			MOV(tTotal >= TIMELOW , 1, iStep);
	END_CASE;
ELSE
	iStep := 0;
END_IF;

Q := iStep = 1 AND IN;
INM := IN;