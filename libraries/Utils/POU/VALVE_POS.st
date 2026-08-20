(* Current valve position % from CT elapsed of TT. Returns INT. *)
VALVE_POS := DINT_TO_INT(DSCALE(TIME_TO_DINT(CT), 0, TIME_TO_DINT(TT), 0, 1000));