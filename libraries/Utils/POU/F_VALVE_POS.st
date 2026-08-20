(* Current valve position % from tCt elapsed of tTt. Returns INT. *)
F_VALVE_POS := DINT_TO_INT(DSCALE(TIME_TO_DINT(tCt), 0, TIME_TO_DINT(tTt), 0, 1000));
