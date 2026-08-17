MOV(giMBAddress = 0, 16, giMBAddress);
MOV(giMBSpeed = 0, 4, giMBSpeed);

fbAmInit.iSeverity := c_AM_ERROR;
fbAmInit.iProcess := 1;

(* Alarms *)
(* Перегрев шкафа *)
fbAmInit(iNum := 0, xLatch := 0, xBuzzer := 0, xLock := 0, iDelay := 0);
(* РКФ *)
fbAmInit(iNum := 1, xLatch := 0, xBuzzer := 1, xLock := 1, iDelay := 0);
(* Авария горелки *)
fbAmInit(iNum := 2, xLatch := 0, xBuzzer := 1, xLock := 1, iDelay := 0);
(* Общекотельное оборудование не в норме *)
fbAmInit(iNum := 3, xLatch := 0, xBuzzer := 1, xLock := 1, iDelay := 0);
(* Давление воды *)
fbAmInit(iNum := 4, xLatch := 1, xBuzzer := 1, xLock := 1, iDelay := 0);
(* Открытие клапана пара *)
fbAmInit(iNum := 5, xLatch := 1, xBuzzer := 1, xLock := 0, iDelay := 0);
(* Закрытие клапана пара *)
fbAmInit(iNum := 6, xLatch := 1, xBuzzer := 1, xLock := 0, iDelay := 0);
(* Повышено солесодержание *)
fbAmInit(iNum := 7, xLatch := 0, xBuzzer := 1, xLock := 0, iDelay := 0);
(* LCR  НАУ *)
fbAmInit(iNum := 8, xLatch := 1, xBuzzer := 1, xLock := 1, iDelay := 0);
(* LCR ВАУ *)
fbAmInit(iNum := 9, xLatch := 1, xBuzzer := 1, xLock := 1, iDelay := 0);
(* Аварийное давление пара *)
fbAmInit(iNum := 10, xLatch := 1, xBuzzer := 1, xLock := 1, iDelay := 0);
(* Нет настроек давления подпитки *)
fbAmInit(iNum := 11, xLatch := 0, xBuzzer := 1, xLock := 1, iDelay := 0);
(* НАУ *)
fbAmInit(iNum := 12, xLatch := 1, xBuzzer := 1, xLock := 1, iDelay := 0);
(* ВАУ *)
fbAmInit(iNum := 13, xLatch := 1, xBuzzer := 1, xLock := 1, iDelay := 0);

(* Sensor wire out *)
fbAmInit(iNum := 14, xLatch := 0, xBuzzer := 1, xLock := 1, iDelay := 20);
fbAmInit(iNum := 15, xLatch := 0, xBuzzer := 1, xLock := 1, iDelay := 20);
fbAmInit(iNum := 16, xLatch := 0, xBuzzer := 1, xLock := 1, iDelay := 20);
(* Main valve open close *)
fbAmInit(iNum := 17, xLatch := 1, xBuzzer := 1, xLock := 0, iDelay := 0);
fbAmInit(iNum := 18, xLatch := 1, xBuzzer := 1, xLock := 0, iDelay := 0);

(* Sensor wire out *)
fbAmInit(iNum := 19, xLatch := 0, xBuzzer := 1, xLock := 1, iDelay := 20);

(* LCR and BCR *)
fbAmInit(iNum := 20, xLatch := 0, xBuzzer := 1, xLock := 0, iDelay := 0);
fbAmInit(iNum := 21, iDelay := 0);
fbAmInit(iNum := 22, iDelay := 0);
fbAmInit(iNum := 23, iDelay := 0);
fbAmInit(iNum := 24, iDelay := 0);
fbAmInit(iNum := 25, iDelay := 0);
fbAmInit(iNum := 26, iDelay := 0);
fbAmInit(iNum := 27, iDelay := 0);
fbAmInit(iNum := 28, iDelay := 0);
fbAmInit(iNum := 29, iDelay := 0);
fbAmInit(iNum := 30, iDelay := 0);
fbAmInit(iNum := 31, iDelay := 0);
fbAmInit(iNum := 32, iDelay := 0);
fbAmInit(iNum := 33, iDelay := 0);
fbAmInit(iNum := 34, iDelay := 0);
fbAmInit(iNum := 35, iDelay := 0);
fbAmInit(iNum := 36, iDelay := 0);
fbAmInit(iNum := 37, iDelay := 0);
fbAmInit(iNum := 38, iDelay := 0);
fbAmInit(iNum := 39, iDelay := 0);
fbAmInit(iNum := 40, iDelay := 0);
fbAmInit(iNum := 41, iDelay := 0);
fbAmInit(iNum := 42, iDelay := 0);


(* Ошибка клапана нижней продувки *)
fbAmInit(iNum := 43, iDelay := 300);

(* Ошибки Пч насосов 1 и 2 *)
fbAmInit(iNum := 44, iDelay := 0);
fbAmInit(iNum := 45, iDelay := 0);


(* LCR *)
MB_CHANNELS[0].xEnabled := TRUE;
MB_CHANNELS[0].iNum := 16;
MB_CHANNELS[0].iDev := 5;
MB_CHANNELS[0].iPort := MB_PORT_2;
MB_CHANNELS[0].iDDevNum := 300;
MB_CHANNELS[0].iReg := 0;
MB_CHANNELS[0].iRF := H4;
MB_CHANNELS[0].iWR := MB_READ;
MB_CHANNELS[0].tCycle := 20;

(* BCR *)
MB_CHANNELS[1].xEnabled := TRUE;
MB_CHANNELS[1].iNum := 16;
MB_CHANNELS[1].iDev := 5;
MB_CHANNELS[1].iPort := MB_PORT_2;
MB_CHANNELS[1].iDDevNum := 400;
MB_CHANNELS[1].iReg := 100;
MB_CHANNELS[1].iRF := H4;
MB_CHANNELS[1].iWR := MB_READ;
MB_CHANNELS[1].tCycle := 20;
