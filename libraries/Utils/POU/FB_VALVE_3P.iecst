(* Time for walve to travel from open to close on position reset *)
fbTpZero(IN := (iSteps = 2 OR iSteps = 6), PT := tTotalTime);

(* Curent valve position measured from 0-1000 *)
iCurValvePos := F_VALVE_POS(tTimePos, tTotalTime);

(* If regulation is turned off but we are regulating *)
MOV(NOT xEnable AND iSteps = 3, 1, iSteps);

CASE iSteps OF
0: (* init *)
    iSteps := 6;
    xOpen := FALSE;
    xClose := FALSE;

1: (* Wait *)
    IF xEnable THEN
        iSteps := 3;
        (* If we just started valve work with xEnable
        and our curent position is not 0, then start
        valve position reset *)
        IF tTimePos > T#0s THEN
            iSteps := 2;
        END_IF;
    END_IF;
    (* If we are not enabled and not closed and set close on off,
    reset valve position *)
    MOV(xCloseOnDisable AND NOT xEnable AND tTimePos > T#0s, 6, iSteps);

2: (* Start position reset *)
    xOpen := FALSE;
    xClose := TRUE;
    (* Close valve time it takes to go from open to close *)
    IF NOT fbTpZero.Q OR xIsClosed THEN
        iSteps := 3;
        xClose := FALSE;
        (* Reset position current position *)
        tTimePos := T#0s;
    END_IF;

3: (* Watch *)
    xOpen := FALSE;
    xClose := FALSE;

    (* iSV from PID 0-1000 *)
    IF iSV <> iCurValvePos THEN
        iGoToPos := iSV;

        dwTimeStart := TCO_DINT_50;
        iLuftAdjust := F_VALVE_POS(tLuftTime, tTotalTime);
        (* If task have changes from current position
        bigger that delta *)
        IF
            (* Task is bigger than current position including delta *)
            iSV > iCurValvePos + iDlt
            (* Valve fully opened already *)
            AND NOT xIsOpened
        THEN
            (* This is open operation. If last operation
            was close, we add luft *)
            IF xLastOpen = FALSE THEN
                iGoToPos := iGoToPos + iLuftAdjust;
            END_IF;
            iSteps := 4;
        END_IF;

        IF iSV < iCurValvePos - iDlt AND NOT xIsClosed THEN
            (* This is close operation. If last operation
            was open, we add luft *)
            IF xLastOpen = TRUE THEN
                iGoToPos := iGoToPos - iLuftAdjust;
            END_IF;
            iSteps := 5;
        END_IF;
    END_IF;

4: (* open *)
    xOpen := TRUE;
    DSUB(TRUE, TCO_DINT_50, dwTimeStart, dwTemp);
    tTimePos := tTimePos + DINT_TO_TIME(DWORD_TO_DINT(dwTemp) * 50);

    IF iSV < iGoToPos (* Task for valve become less than current position *)
        OR (iGoToPos <= iCurValvePos) (* Reached goal position *)
        OR xIsOpened (* Valve fully opened *)
    THEN
        xOpen := FALSE;
        xLastOpen := TRUE;
        iSteps := 3;
    END_IF;

5: (* close *)
    xClose := TRUE;
    DSUB(TRUE, TCO_DINT_50, dwTimeStart, dwTemp);
    tTimePos := tTimePos + DINT_TO_TIME(DWORD_TO_DINT(dwTemp) * 50);

    IF
        iSV > iGoToPos
        OR (iGoToPos >= iCurValvePos)
        OR xIsClosed
    THEN
        xClose := FALSE;
        xLastOpen := FALSE;
        iSteps := 3;
    END_IF;

6: (* Position reset on close and init *)
    xOpen := FALSE;
    xClose := TRUE;
    IF NOT fbTpZero.Q OR xIsClosed THEN
        iSteps := 1;
        xClose := FALSE;
        tTimePos := T#0s;
    END_IF;
END_CASE;
