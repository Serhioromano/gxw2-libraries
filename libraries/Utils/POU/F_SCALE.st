(* Scale iVal from iInLow..iInHigh to iOutLow..iOutHigh. Returns INT. *)
iValue := SEL(iInLow <= iInHigh, LIMITATION(iInHigh, iVal, iInLow), LIMITATION(iInLow, iVal, iInHigh));

rNumber := (INT_TO_REAL(iOutHigh) - INT_TO_REAL(iOutLow)) / (INT_TO_REAL(iInHigh) - INT_TO_REAL(iInLow));
F_SCALE := REAL_TO_INT((INT_TO_REAL(iValue) * rNumber) + INT_TO_REAL(iOutLow) - (rNumber * INT_TO_REAL(iInLow)));

F_SCALE := SEL(iOutLow <= iOutHigh, LIMITATION(iOutHigh, F_SCALE, iOutLow), LIMITATION(iOutLow, F_SCALE, iOutHigh));
