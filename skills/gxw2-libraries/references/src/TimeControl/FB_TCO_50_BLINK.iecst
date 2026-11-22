(* Blink timer driven by the global 50 ms ticker TCO_DINT_50.
   Starts with the LOW phase; Q turns OFF when xIn is FALSE. *)
IF xIn THEN
	DMOV(NOT xInMem, TCO_DINT_50, dwStart);
	CASE iStep OF
		1: (* HIGH phase *)
			dwTotal := F_TCO_50_DIFF(dwStart, TCO_DINT_50);
			DMOV(dwTotal >= dwTimeHigh, TCO_DINT_50, dwStart);
			MOV(dwTotal >= dwTimeHigh, 0, iStep);
		0: (* LOW phase *)
			dwTotal := F_TCO_50_DIFF(dwStart, TCO_DINT_50);
			DMOV(dwTotal >= dwTimeLow, TCO_DINT_50, dwStart);
			MOV(dwTotal >= dwTimeLow, 1, iStep);
	END_CASE;
ELSE
	iStep := 0;
END_IF;

xQ := iStep = 1 AND xIn;
xInMem := xIn;
