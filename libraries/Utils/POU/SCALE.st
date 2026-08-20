(* Scale Val from inLow..inHigh to outLow..outHigh. Returns INT. *)
Value := SEL(inLow <= inHigh, LIMITATION(inHigh, Val, inLow), LIMITATION(inLow, Val, inHigh));

number := (INT_TO_REAL(outHigh) - INT_TO_REAL(outLow)) / (INT_TO_REAL(inHigh) - INT_TO_REAL(inLow));
SCALE := REAL_TO_INT((INT_TO_REAL(Value) * number) + INT_TO_REAL(outLow) - (number * INT_TO_REAL(inLow)));

SCALE := SEL(outLow <= outHigh, LIMITATION(outHigh, SCALE, outLow), LIMITATION(outLow, SCALE, outHigh));
