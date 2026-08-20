(* Heating on/off regulator with hysteresis. Turns off when iPV < iSV. *)
SET(iPV < iSV - iDV, xOut);
RST(iPV > iSV + iDV, xOut);
xQ := xOut AND xIn;
