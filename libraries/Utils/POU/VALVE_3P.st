(* Time for walve to travel from open to close on position reset *)
fbTPZero(IN := (iSteps = 2 OR iSteps = 6), PT := TOTAL_TIME);

(* Curent valve position measured from 0-1000 *)
iCurValvePos := VALVE_POS(tTimePos, TOTAL_TIME);

(* If regulation is turned off but we are regulating *)
MOV(NOT ENABLE AND iSteps = 3, 1, iSteps);

CASE iSteps OF
0: (* init *)
    iSteps := 6;
    OPEN := FALSE;
    CLOSE := FALSE;

1: (* Wait *)
    IF ENABLE THEN
        iSteps := 3;
        (* If we just started valve work with ENABLE
        and our curent position is not 0, then start
        valve position reset *)
        IF tTimePos > T#0s THEN
            iSteps := 2;
        END_IF;
    END_IF;
    (* If we are not enabled and not closed and set close on off,
    reset valve position *)
    MOV(CLOSE_ON_DISABLE AND NOT ENABLE AND tTimePos > T#0s, 6, iSteps);

2: (* Start position reset *)
    OPEN := FALSE;
    CLOSE := TRUE;
    (* Close valve time it takes to go from open to close *)
    IF NOT fbTPZero.Q OR IS_CLOSED THEN
        iSteps := 3;
        CLOSE := FALSE;
        (* Reset position current position *)
        tTimePos := T#0s;
    END_IF;

3: (* Watch *)
    OPEN := FALSE;
    CLOSE := FALSE;

    (* SV from PID 0-1000 *)
    IF SV <> iCurValvePos THEN
        iGoToPos := SV;

        tTimeStart := TCO_DINT_50;
        iLuftAdjust := VALVE_POS(LUFT_TIME, TOTAL_TIME);
        (* If task have changes from current position
        bigger that delta *)
        IF
            (* Task is bigger than current position including delta *)
            SV > iCurValvePos + DLT
            (* Valve fully opened already *)
            AND NOT IS_OPENED
        THEN
            (* This is open operation. If last operation
            was close, we add luft *)
            IF xLastOpen = FALSE THEN
                iGoToPos := iGoToPos + iLuftAdjust;
            END_IF;
            iSteps := 4;
        END_IF;

        IF SV < iCurValvePos - DLT AND NOT IS_CLOSED THEN
            (* This is close operation. If last operation
            was open, we add luft *)
            IF xLastOpen = TRUE THEN
                iGoToPos := iGoToPos - iLuftAdjust;
            END_IF;
            iSteps := 5;
        END_IF;
    END_IF;

4: (* open *)
    OPEN := TRUE;
    DSUB(TRUE, TCO_DINT_50, tTimeStart, diTemp); 
    tTimePos := tTimePos + DINT_TO_TIME(DWORD_TO_DINT(diTemp) * 50);

    IF SV < iGoToPos (* Task for valve become less than current position *)
        OR (iGoToPos <= iCurValvePos) (* Reached goal position *)
        OR IS_OPENED (* Valve fully opened *)
    THEN
        OPEN := FALSE;
        xLastOpen := TRUE;
        iSteps := 3;
    END_IF;

5: (* close *)
    CLOSE := TRUE;
    DSUB(TRUE, TCO_DINT_50, tTimeStart, diTemp); 
    tTimePos := tTimePos + DINT_TO_TIME(DWORD_TO_DINT(diTemp) * 50);

    IF
        SV > iGoToPos
        OR (iGoToPos >= iCurValvePos)
        OR IS_CLOSED
    THEN
        CLOSE := FALSE;
        xLastOpen := FALSE;
        iSteps := 3;
    END_IF;

6: (* Position reset on close and init *)
    OPEN := FALSE;
    CLOSE := TRUE;
    IF NOT fbTPZero.Q OR IS_CLOSED THEN
        iSteps := 1;
        CLOSE := FALSE;
        tTimePos := T#0s;
    END_IF;
END_CASE;
