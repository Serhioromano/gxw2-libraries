(*
  MB_PROCESS_50 - Modbus channel scheduler (50 ms cycle).
  MB_CHANNELS and c_MB_CHANNELS_NUM are declared by the application
  in its global label list; the library references them directly.
*)
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

(* Delay before start communication *)
fbTON1(IN := mb_xEnable, PT := T#3s);
(* Whatchdog timer *)
fbTON2(IN := imbStep = 10 OR imbStep = 30, PT := INT_TO_TIME(MB_TIMEOUT_TIME * 50));
MOV(fbTON2.Q, MB_CHANNELS[iCount].iDev, mb_Timeout);
SET(mb_Timeout > 0, xNextChannel);
MOV(mb_Timeout > 0, 20, imbStep);
INC(mb_Timeout > 0, MB_CHANNELS[iCount].iTimeOut);
IF imbStep = 20 THEN fbTON2(IN := FALSE); END_IF;

CASE imbStep OF
	0:  (* BOOT DELAY ON START *)
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
		mb_Timeout := 0;
		MB_CHANNELS[iCount].xDone := FALSE;

		IF xAlloWrite
			AND MB_CHANNELS[iCount].xEnabled = TRUE
			AND (MB_CHANNELS[iCount].iWR = MB_READ_WRITE OR MB_CHANNELS[iCount].iWR = MB_WRITE)
			AND (
				(
					MB_CHANNELS[iCount].iTimeOut >= MB_TIMEOUT_COUNT
					AND DWORD_TO_INT(TCO_50_DIFF(MB_CHANNELS[iCount].tStart, TCO_DINT_50)) >= MB_SUSPEND_RETRY
				)
				OR
				(
					MB_CHANNELS[iCount].iTimeOut < MB_TIMEOUT_COUNT
					AND
					(
						MB_CHANNELS[iCount].xWriteOnChange = TRUE
						OR
						(
							MB_CHANNELS[iCount].xWriteOnChange = FALSE
							AND MB_CHANNELS[iCount].tCycle > 0
							AND DWORD_TO_INT(TCO_50_DIFF(MB_CHANNELS[iCount].tStart, TCO_DINT_50)) >= MB_CHANNELS[iCount].tCycle
						)
					)
				)
				OR
				(
					MB_CHANNELS[iCount].xWriteOnce AND NOT MB_CHANNELS[iCount].xWriteOnceM
				)
			)
		THEN
			IF MB_CHANNELS[iCount].xWriteOnce AND NOT MB_CHANNELS[iCount].xWriteOnceM THEN
				setFunc := MB_CHANNELS[iCount].iWF;
				IF MB_CHANNELS[iCount].isRegister AND MB_CHANNELS[iCount].iNum > 1 THEN
					setFunc := H10;
				END_IF;
				IF NOT MB_CHANNELS[iCount].isRegister AND MB_CHANNELS[iCount].iNum > 1 THEN
					setFunc := HF;
				END_IF;

				setReg := MB_CHANNELS[iCount].iReg;
				setZ   := MB_CHANNELS[iCount].iDDevNum;
				setNum := MB_CHANNELS[iCount].iNum;
				MOV(setFunc <> H10 AND setFunc <> HF, 0, setNum);
				imbStep := 10;
			ELSE
				FOR iIndex := 0 TO (MB_CHANNELS[iCount].iNum - 1) DO
					Z5 := MB_CHANNELS[iCount].iDDevNum + iIndex;
					Z6 := Z5 + MB_CHANNELS[iCount].iNum;
	
					(* If device was changed *)
					IF (
						(MB_CHANNELS[iCount].isRegister = TRUE AND D0Z5 <> D0Z6)
						OR
						(MB_CHANNELS[iCount].isRegister = FALSE AND M0Z5 <> M0Z6)
					)
					(* It was NOT a device we updated previouse cycle *)
					AND iIndex > lastIndex THEN
						(* We only support H5, Hf, H6 and H10 function to write. H6 by default *)
						setFunc := MB_CHANNELS[iCount].iWF;
						setReg := MB_CHANNELS[iCount].iReg;
						
						IF MB_CHANNELS[iCount].iWF = H10 OR MB_CHANNELS[iCount].iWF = HF THEN
							setZ   := MB_CHANNELS[iCount].iDDevNum;
							setNum := MB_CHANNELS[iCount].iNum;
						(* Function H6 *)
						ELSE
							setZ   := MB_CHANNELS[iCount].iDDevNum + iIndex;
							setNum := 0;
							iAddToReg := iIndex;
							(* ADDP(TRUE, MB_CHANNELS[iCount].iReg, INT_TO_WORD(), setReg);
							setReg := MB_CHANNELS[iCount].iReg + INT_TO_WORD(iIndex);*)
						END_IF;
	
						lastIndex := iIndex;
						imbStep := 10;
					END_IF;
				END_FOR;			
			END_IF;
		END_IF;
		MB_CHANNELS[iCount].xWriteOnceM := MB_CHANNELS[iCount].xWriteOnce;

		(* If we do not have any WRITE task lets read *)
		IF imbStep = 20
			AND MB_CHANNELS[iCount].xEnabled = TRUE
			AND (MB_CHANNELS[iCount].iWR = MB_READ_WRITE OR MB_CHANNELS[iCount].iWR = MB_READ)
			AND (
				(* In a suspend mode read every MB_SUSPEND_RETRY *)
				(
					MB_CHANNELS[iCount].tCycle > 0
					AND MB_CHANNELS[iCount].iTimeOut >= MB_TIMEOUT_COUNT
					AND DWORD_TO_INT(TCO_50_DIFF(MB_CHANNELS[iCount].tStart, TCO_DINT_50)) >= MB_SUSPEND_RETRY
				)
				OR
				(* In a normal mode read every tCycle *)
				(
					MB_CHANNELS[iCount].tCycle > 0
					AND MB_CHANNELS[iCount].iTimeOut < MB_TIMEOUT_COUNT
					AND DWORD_TO_INT(TCO_50_DIFF(MB_CHANNELS[iCount].tStart, TCO_DINT_50)) >= MB_CHANNELS[iCount].tCycle
				)
				OR
				(* Manual read once *)
				(
					MB_CHANNELS[iCount].xReadOnce AND NOT MB_CHANNELS[iCount].xReadOnceM
				)
			)
		THEN
			setFunc := MB_CHANNELS[iCount].iRF;
			setZ    := MB_CHANNELS[iCount].iDDevNum;
			setNum  := MB_CHANNELS[iCount].iNum;
			setReg  := MB_CHANNELS[iCount].iReg;

			imbStep := 10;
		END_IF;
		MB_CHANNELS[iCount].xReadOnceM := MB_CHANNELS[iCount].xReadOnce;

		(* Reset first ADPRW call *)
		RST(imbStep = 10, xProcess);
		MOV(imbStep = 10, MB_CHANNELS[iCount].iPort, D8397);
		MOV(imbStep = 10, MB_CHANNELS[iCount].iPort, D8126);

		(* If after checking there is nothing to read or write, check another channel *)
		SET(imbStep = 20, xNextChannel);
		MOV(imbStep = 10 AND NOT MB_CHANNELS[iCount].isRegister, 30, imbStep);

	10: (* Process registers *)
		Z5 := setZ;
		Z7 := mb_iBuffer;

		(* If we write then move our value to the buffer *)
		BMOV(setFunc = H6, D0Z5, 1, D0Z7);
		BMOV(setFunc = H10, D0Z5, setNum, D0Z7);

		ADDP(iAddToReg > 0, MB_CHANNELS[iCount].iReg, INT_TO_WORD(iAddToReg), setReg);
		iAddToReg := 0;
		
		(* Work with registeres *)
		ADPRW(
			xProcess AND mb_Timeout = 0,
			MB_CHANNELS[iCount].iDev, (* Device adress *)
			setFunc, (* Function to read *)
			setReg, (* Register address *)
			setNum, (* How many registers to read *)
			D0Z7 (* Where to store *)
		);

		IF (M8029) THEN
			(* If it was H6 function we updated 1 register *)
			IF setNum = 0 THEN setNum := 1; END_IF;
			(* If prewiosly was timed out, reset *)
			MOV(MB_CHANNELS[iCount].iTimeOut > 0, 0, MB_CHANNELS[iCount].iTimeOut);

			Z6 := Z5 + MB_CHANNELS[iCount].iNum;

			(* If we write then move our value to the buffer *)
			BMOV((setFunc = H6 OR setFunc = H10), D0Z5, setNum, D0Z6);
			(* If we read *)
			IF setFunc = H3 OR setFunc = H4 THEN
				(* Check if the values had changed while we were deading them
				and if YES then we will not update those. *)

				xHadChanged := FALSE;
				FOR iIndex := 0 TO (setNum - 1) DO
					Z3 := MB_CHANNELS[iCount].iDDevNum + iIndex ;
					Z4 := MB_CHANNELS[iCount].iDDevNum + MB_CHANNELS[iCount].iNum + iIndex;
					SET(MB_CHANNELS[iCount].iWR <> MB_READ AND D0Z3 <> D0Z4, xHadChanged);
				END_FOR;

				Z5 := setZ;
				Z6 := Z5 + MB_CHANNELS[iCount].iNum;
				(* Write from buffer to store and then to control value *)
				BMOV(NOT xHadChanged, D0Z7, setNum, D0Z5);
				BMOV(NOT xHadChanged, D0Z5, setNum, D0Z6);
			END_IF;
			(* Save values *)
			RST(TRUE, M8029);
			MB_CHANNELS[iCount].xDone := TRUE;
			imbStep := 20;

			(* The only condition we do not go to the next channel *)
			IF NOT (MB_CHANNELS[iCount].iNum > 1 AND setFunc = H6) THEN
				MB_CHANNELS[iCount].tStart := TCO_DINT_50;
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
			xProcess AND mb_Timeout = 0,
			MB_CHANNELS[iCount].iDev,
			setFunc,
			setReg,
			setNum,
			D0Z7
		);

		IF (M8029) THEN
			(* If it was H6 function we updated 1 register *)
			IF setNum = 0 THEN setNum := 1; END_IF;
			(* If prewiosly was timed out, reset *)
			MOV(MB_CHANNELS[iCount].iTimeOut > 0, 0, MB_CHANNELS[iCount].iTimeOut);

			(* If we write then move our value to the buffer *)
			xBit := MBMOV(setFunc = H5 OR setFunc = HF, setZ, setNum, setZ + MB_CHANNELS[iCount].iNum);

			(* If we read *)
			IF setFunc = H1 OR setFunc = H2 THEN
				(* Check if the values had changed while we were deading them
				and if YES then we will not update those. *)

				xHadChanged := FALSE;
				FOR iIndex := 0 TO (setNum - 1) DO
					Z3 := MB_CHANNELS[iCount].iDDevNum + iIndex ;
					Z4 := MB_CHANNELS[iCount].iDDevNum + MB_CHANNELS[iCount].iNum + iIndex;
					SET(MB_CHANNELS[iCount].iWR <> MB_READ AND M0Z3 <> M0Z4, xHadChanged);
				END_FOR;

				IF NOT xHadChanged THEN
					FOR iIndex := 0 TO MB_CHANNELS[iCount].iNum - 1 DO
						Z5 := setZ + iIndex;
						Z6 := Z5 + MB_CHANNELS[iCount].iNum;

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
			MB_CHANNELS[iCount].xDone := TRUE;
			imbStep := 20;

			(* The only condition we do not go to the next channel *)
			IF NOT (MB_CHANNELS[iCount].iNum > 1 AND setFunc = H5) THEN
				MB_CHANNELS[iCount].tStart := TCO_DINT_50;
				xNextChannel := TRUE;
			END_IF;
		END_IF;

		(* First ADPRW call is a reset *)
		xProcess := TRUE;

END_CASE;


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
	lastIndex := -1;
	(* If we are in channel 0 we whent through all channels at least once and can start writing *)
	SET((iCount = 0), xAlloWrite);
END_IF;
