(*
  MB_PROCESS_50 - Modbus channel scheduler (50 ms cycle).
  MB_CHANNELS and c_MB_CHANNELS_NUM are declared by the application
  in its global label list; the library references them directly.
 *)
(* Default output: no channel timed out this scan *)
mb_Timeout := -1;

(* If we disable block, go to to step 0 *)
MOVP(NOT mb_xEnable, 0, imbStep);
MOVP(mb_xEnable, 0, imbStep);

(* Set defaults *)
MOV(MB_TIMEOUT_COUNT = 0, 2, MB_TIMEOUT_COUNT);
MOV(MB_SUSPEND_RETRY = 0, 80, MB_SUSPEND_RETRY);
MOV(MB_TIMEOUT_TIME = 0, 4, MB_TIMEOUT_TIME);

IF MEP(mb_xEnable) THEN
	FOR iIndex := 0 TO c_MB_CHANNELS_NUM DO
			IF MB_CHANNELS[iIndex].iNum > 0 THEN
				MB_CHANNELS[iIndex].iTimeOut := 0;
				MB_CHANNELS[iIndex].tStart := 0;
			END_IF;
	END_FOR;
END_IF;

CHANNEL := MB_CHANNELS[iCount];

(* Delay before start communication *)
fbTON1(IN := mb_xEnable, PT := T#3s);
(* Whatchdog timer *)
fbTON2(IN := imbStep = 10 OR imbStep = 30, PT := INT_TO_TIME(MB_TIMEOUT_TIME * 50));
MOV(fbTON2.Q, iCount, mb_Timeout);
SET(mb_Timeout >= 0, xNextChannel);
MOV(mb_Timeout >= 0, 20, imbStep);
INC(mb_Timeout >= 0, CHANNEL.iTimeOut);
IF imbStep = 20 THEN fbTON2(IN := FALSE); END_IF;

CASE imbStep OF
	0: (* BOOT DELAY ON START *)
		MOV(fbTON1.Q AND MB_CHANNELS[0].iDDevNum > 0, 1, imbStep);

	1:	(* Set defaults *)
		FOR iIndex := 0 TO c_MB_CHANNELS_NUM DO
			IF MB_CHANNELS[iIndex].iNum > 0 THEN
				MB_CHANNELS[iIndex].tStart := TCO_DINT_50;
				MOV(MB_CHANNELS[iIndex].iRF = 0, H3, MB_CHANNELS[iIndex].iRF);
				MOV(MB_CHANNELS[iIndex].iWF = 0, H6, MB_CHANNELS[iIndex].iWF);
				MOV((MB_CHANNELS[iIndex].iNum = 0), 1, MB_CHANNELS[iIndex].iNum);
				MB_CHANNELS[iIndex].isRegister := (
					MB_CHANNELS[iIndex].iWF = H6 OR MB_CHANNELS[iIndex].iWF = H10
					OR MB_CHANNELS[iIndex].iRF = H3 OR MB_CHANNELS[iIndex].iRF = H4
				);

				(* Reset devices to 0 *)
				Z3 := MB_CHANNELS[iIndex].iDDevNum;
				FOR iCount := 0 TO (MB_CHANNELS[iIndex ].iNum - 1) DO
					Z3 := MB_CHANNELS[iIndex ].iDDevNum + iCount;
					Z4 := Z3 + MB_CHANNELS[iIndex ].iNum;
					D0Z3 := 0;
					D0Z4 := 0;
				END_FOR;
			END_IF;
		END_FOR;
		lastIndex := -1;
		iCount := 0;
		xAlloWrite := FALSE;
		imbStep := 20;

	20: (* PREPARE *)
		CHANNEL.xDone := FALSE;

		IF xAlloWrite
			AND CHANNEL.xEnabled = TRUE
			AND (CHANNEL.iWR = MB_READ_WRITE OR CHANNEL.iWR = MB_WRITE)
			AND (
				(
					CHANNEL.iTimeOut >= MB_TIMEOUT_COUNT
					AND DWORD_TO_INT(F_TCO_50_DIFF(CHANNEL.tStart, TCO_DINT_50)) >= MB_SUSPEND_RETRY
				)
				OR
				(
					CHANNEL.iTimeOut < MB_TIMEOUT_COUNT
					AND
					(
						CHANNEL.xWriteOnChange = TRUE
						OR
						(
							CHANNEL.xWriteOnChange = FALSE
							AND CHANNEL.tCycle > 0
							AND DWORD_TO_INT(F_TCO_50_DIFF(CHANNEL.tStart, TCO_DINT_50)) >= CHANNEL.tCycle
						)
					)
				)
				OR
				(
					CHANNEL.xWriteOnce AND NOT CHANNEL.xWriteOnceM
				)
			)
		THEN
			IF CHANNEL.xWriteOnce AND NOT CHANNEL.xWriteOnceM THEN
				setFunc := CHANNEL.iWF;
				IF CHANNEL.isRegister AND CHANNEL.iNum > 1 THEN
					setFunc := H10;
				END_IF;
				IF NOT CHANNEL.isRegister AND CHANNEL.iNum > 1 THEN
					setFunc := HF;
				END_IF;

				setReg := CHANNEL.iReg;
				setZ := CHANNEL.iDDevNum;
				setNum := CHANNEL.iNum;
				MOV(setFunc <> H10 AND setFunc <> HF, 0, setNum);
				imbStep := 10;
			ELSE
				FOR iIndex := 0 TO (CHANNEL.iNum - 1) DO
					Z5 := CHANNEL.iDDevNum + iIndex;
					Z6 := Z5 + CHANNEL.iNum;

					(* If device was changed *)
					IF (
						(CHANNEL.isRegister = TRUE AND D0Z5 <> D0Z6)
						OR
						(CHANNEL.isRegister = FALSE AND M0Z5 <> M0Z6)
					)
					(* It was NOT a device we updated previouse cycle *)
					AND iIndex > lastIndex THEN
						(* We only support H5, Hf, H6 and H10 function to write. H6 by default *)
						setFunc := CHANNEL.iWF;
						setReg := CHANNEL.iReg;

						IF CHANNEL.iWF = H10 OR CHANNEL.iWF = HF THEN
							setZ := CHANNEL.iDDevNum;
							setNum := CHANNEL.iNum;
						(* Function H6 *)
						ELSE
							setZ := CHANNEL.iDDevNum + iIndex;
							setNum := 0;
							iAddToReg := iIndex;
						END_IF;

						lastIndex := iIndex;
						imbStep := 10;
					END_IF;
				END_FOR;
			END_IF;
		END_IF;
		CHANNEL.xWriteOnceM := CHANNEL.xWriteOnce;

		(* If we do not have any WRITE task lets read *)
		IF imbStep = 20
			AND CHANNEL.xEnabled = TRUE
			AND (CHANNEL.iWR = MB_READ_WRITE OR CHANNEL.iWR = MB_READ)
			AND (
				(* In a suspend mode read every MB_SUSPEND_RETRY *)
				(
					CHANNEL.tCycle > 0
					AND CHANNEL.iTimeOut >= MB_TIMEOUT_COUNT
					AND DWORD_TO_INT(F_TCO_50_DIFF(CHANNEL.tStart, TCO_DINT_50)) >= MB_SUSPEND_RETRY
				)
				OR
				(* In a normal mode read every tCycle *)
				(
					CHANNEL.tCycle > 0
					AND CHANNEL.iTimeOut < MB_TIMEOUT_COUNT
					AND DWORD_TO_INT(F_TCO_50_DIFF(CHANNEL.tStart, TCO_DINT_50)) >= CHANNEL.tCycle
				)
				OR
				(* Manual read once *)
				(
					CHANNEL.xReadOnce AND NOT CHANNEL.xReadOnceM
				)
			)
		THEN
			setFunc := CHANNEL.iRF;
			setZ := CHANNEL.iDDevNum;
			setNum := CHANNEL.iNum;
			setReg := CHANNEL.iReg;

			imbStep := 10;
		END_IF;
		CHANNEL.xReadOnceM := CHANNEL.xReadOnce;

		(* Reset first ADPRW call *)
		RST(imbStep = 10, xProcess);
		MOV(imbStep = 10, CHANNEL.iPort, D8397);
		MOV(imbStep = 10, CHANNEL.iPort, D8126);
		MOV(imbStep = 10 AND NOT CHANNEL.isRegister, 30, imbStep);

		(* Multi-item H6/H5 write finished on a write-only channel: there is no                                             
		read to refresh tStart, so close the cycle here. Read-write/read                                                  
		channels keep their tStart and let the next read update it. *)                                                    
        IF imbStep = 20 AND lastIndex >= 0 
			AND (CHANNEL.iWR = MB_WRITE OR CHANNEL.tCycle = 0) 
		THEN
           CHANNEL.tStart := TCO_DINT_50;                           
        END_IF;    
		(* If after checking there is nothing to read or write, check another channel *)
		SET(imbStep = 20, xNextChannel);

	10: (* Process registers *)
		Z5 := setZ;
		Z7 := mb_iBuffer;

		(* If we write then move our value to the buffer *)
		BMOV(setFunc = H6, D0Z5, 1, D0Z7);
		BMOV(setFunc = H10, D0Z5, setNum, D0Z7);

		ADDP(iAddToReg > 0, CHANNEL.iReg, INT_TO_WORD(iAddToReg), setReg);
		iAddToReg := 0;

		(* Work with registeres *)
		ADPRW(
			xProcess AND mb_Timeout = -1,
			CHANNEL.iDev, (* Device adress *)
			setFunc, (* Function to read *)
			setReg, (* Register address *)
			setNum, (* How many registers to read *)
			D0Z7 (* Where to store *)
		);

		IF (M8029) THEN
			(* If it was H6 function we updated 1 register *)
			IF setNum = 0 THEN setNum := 1; END_IF;
			(* Reset the timeout counter on successful poll *)
			CHANNEL.iTimeOut := 0;

			Z6 := Z5 + CHANNEL.iNum;

			(* If we write then move our value to the buffer *)
			BMOV((setFunc = H6 OR setFunc = H10), D0Z5, setNum, D0Z6);
			(* If we read *)
			IF setFunc = H3 OR setFunc = H4 THEN
				(* Check if the values had changed while we were deading them
				and if YES then we will not update those. *)

				xHadChanged := FALSE;
				FOR iIndex := 0 TO (setNum - 1) DO
					Z3 := CHANNEL.iDDevNum + iIndex;
					Z4 := CHANNEL.iDDevNum + CHANNEL.iNum + iIndex;
					SET(CHANNEL.iWR <> MB_READ AND D0Z3 <> D0Z4, xHadChanged);
				END_FOR;

				Z5 := setZ;
				Z6 := Z5 + CHANNEL.iNum;
				(* Write from buffer to store and then to control value *)
				BMOV(NOT xHadChanged, D0Z7, setNum, D0Z5);
				BMOV(NOT xHadChanged, D0Z5, setNum, D0Z6);
			END_IF;
			(* Save values *)
			RST(TRUE, M8029);
			CHANNEL.xDone := TRUE;
			imbStep := 20;

			(* The only condition we do not go to the next channel *)
			IF NOT (CHANNEL.iNum > 1 AND setFunc = H6) THEN
				CHANNEL.tStart := TCO_DINT_50;
				xNextChannel := TRUE;
			END_IF;
		END_IF;
		(* First ADPRW call is a reset *)
		xProcess := TRUE;
	30: (* process bits *)
		Z5 := setZ;
		Z7 := mb_iBuffer;

		MOV(setFunc = H5 AND M0Z5, HFF00, D0Z7);
		MOV(setFunc = H5 AND NOT M0Z5, H0000, D0Z7);

		(* Work with coils *)
		ADPRW(
			xProcess AND mb_Timeout = -1,
			CHANNEL.iDev,
			setFunc,
			setReg,
			setNum,
			D0Z7
		);

		IF (M8029) THEN
			(* If it was H6 function we updated 1 register *)
			IF setNum = 0 THEN setNum := 1; END_IF;
			(* Reset the timeout counter on successful poll *)
			CHANNEL.iTimeOut := 0;

			(* If we write then move our value to the buffer *)
			xBit := MBMOV(setFunc = H5 OR setFunc = HF, setZ, setNum, setZ + CHANNEL.iNum);

			(* If we read *)
			IF setFunc = H1 OR setFunc = H2 THEN
				(* Check if the values had changed while we were deading them
				and if YES then we will not update those. *)

				xHadChanged := FALSE;
				FOR iIndex := 0 TO (setNum - 1) DO
					Z3 := CHANNEL.iDDevNum + iIndex ;
					Z4 := CHANNEL.iDDevNum + CHANNEL.iNum + iIndex;
					SET(CHANNEL.iWR <> MB_READ AND M0Z3 <> M0Z4, xHadChanged);
				END_FOR;

				IF NOT xHadChanged THEN
					FOR iIndex := 0 TO CHANNEL.iNum - 1 DO
						Z5 := setZ + iIndex;
						Z6 := Z5 + CHANNEL.iNum;

						iRegsInBIts := SEL(iIndex > 16, 0, (iIndex / 16));
						iBit := iIndex - (iRegsInBIts * 16);
						Z4 := mb_iBuffer + iRegsInBIts;

						M0Z5 := ISBON(D0Z4, iBit);
						M0Z6 := ISBON(D0Z4, iBit);
					END_FOR;
				END_IF;
			END_IF;
			(* Save values *)
			RST(TRUE, M8029);
			CHANNEL.xDone := TRUE;
			imbStep := 20;

			(* The only condition we do not go to the next channel *)
			IF NOT (CHANNEL.iNum > 1 AND setFunc = H5) THEN
				CHANNEL.tStart := TCO_DINT_50;
				xNextChannel := TRUE;
			END_IF;
		END_IF;

		(* First ADPRW call is a reset *)
		xProcess := TRUE;

END_CASE;

MB_CHANNELS[iCount] := CHANNEL;

(* If switch to next channel mpve index *)
IF xNextChannel THEN
	xNextChannel := FALSE;
	IF (iCount = c_MB_CHANNELS_NUM) THEN
		iCount := 0;
	ELSE
		IF MB_CHANNELS[iCount + 1].iNum > 0 THEN
			iCount := iCount + 1;
		ELSE
			iCount := 0;
		END_IF;
	END_IF;
	(* If we change channel, we went though all registers in channel *)
	lastIndex := - 1;
	(* If we are in channel 0 we whent through all channels at least once and can start writing *)
	SET((iCount = 0), xAlloWrite);
END_IF;
