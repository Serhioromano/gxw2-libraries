(* VFD 1 *)
(* Уставка *)
MB_CHANNELS[2].xEnabled := xPump1Enable;
MB_CHANNELS[2].iNum := 1;
MB_CHANNELS[2].iDev := 10;
MB_CHANNELS[2].iPort := MB_PORT_2;
MB_CHANNELS[2].iDDevNum := 450;
MB_CHANNELS[2].iReg := HF901;
MB_CHANNELS[2].iRF := H3;
MB_CHANNELS[2].iWR := MB_READ_WRITE;
MB_CHANNELS[2].tCycle := 0;

(* Верхний предел *)
MB_CHANNELS[3].xEnabled := xPump1Enable;
MB_CHANNELS[3].iNum := 1;
MB_CHANNELS[3].iDev := 10;
MB_CHANNELS[3].iPort := MB_PORT_2;
MB_CHANNELS[3].iDDevNum := 450;
MB_CHANNELS[3].iReg := HA103;
MB_CHANNELS[3].iRF := H3;
MB_CHANNELS[3].iWR := MB_READ_WRITE;
MB_CHANNELS[3].tCycle := 0;

(* VFD 2 *)
(* Уставка *)
MB_CHANNELS[4].xEnabled := xPump2Enable;
MB_CHANNELS[4].iNum := 1;
MB_CHANNELS[4].iDev := 11;
MB_CHANNELS[4].iPort := MB_PORT_2;
MB_CHANNELS[4].iDDevNum := 450;
MB_CHANNELS[4].iReg := HF901;
MB_CHANNELS[4].iRF := H3;
MB_CHANNELS[4].iWR := MB_READ_WRITE;
MB_CHANNELS[4].tCycle := 0;

(* Верхний предел *)
MB_CHANNELS[5].xEnabled := xPump2Enable;
MB_CHANNELS[5].iNum := 1;
MB_CHANNELS[5].iDev := 1;
MB_CHANNELS[5].iPort := MB_PORT_2;
MB_CHANNELS[5].iDDevNum := 450;
MB_CHANNELS[5].iReg := HA103;
MB_CHANNELS[5].iRF := H3;
MB_CHANNELS[5].iWR := MB_READ_WRITE;
MB_CHANNELS[5].tCycle := 0;
