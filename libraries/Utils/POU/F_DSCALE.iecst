(* Scale diVal from diInLow..diInHigh to diOutLow..diOutHigh. Returns DINT. *)
IF diInLow = diInHigh THEN
	rTemp := DINT_TO_REAL(diOutLow);
ELSE
	rTemp := DINT_TO_REAL(diOutHigh - diOutLow) / DINT_TO_REAL(diInHigh - diInLow) *
		DINT_TO_REAL(LIMITATION(diInLow, diVal, diInHigh) - diInLow) + DINT_TO_REAL(diOutLow);
END_IF;
F_DSCALE := LIMITATION(diOutLow, REAL_TO_DINT(rTemp), diOutHigh);
