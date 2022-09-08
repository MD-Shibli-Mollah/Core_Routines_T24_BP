* @ValidationCode : MjoyMDQyNzQ5Njk1OkNwMTI1MjoxNTg4Nzc3Nzk5ODIxOnZzbmVoYTotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAyMDA1LjIwMjAwNDMwLTEzMjU6LTE6LTE=
* @ValidationInfo : Timestamp         : 06 May 2020 20:39:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vsneha
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202005.20200430-1325
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 4 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>2688</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.Display
SUBROUTINE T.INP (YTEXT,C2,L2,N1,T1)
*-----------------------------------------------------------------------------
* Modifications.
*
* 15/03/00 - GB0000458
*            jBASE compatability.
*            CALL to !PTERM("-FULL") and !PTERM("-HALF") is commented th
*            through out this program.
*            Reason - The same effect could be produced by the commands
*            ECHO ON and ECHO OFF and more over these command are Jbase
*            Compatible.
*
* 03/12/03 - EN_10002087
*            If we are an OFS message and end up in here without anything in
*            the input buffer, then set comi to C.U as if we ask for input
*            the the OFS sesssion will hang
*
* 13/11/06 - CI_10045462
*            COB got crashed in the batch BNK/RP.START.OF.DAY in the job
*            RP.SOD.MATURITY.
*            Ref: HD0616817
*
* 06/05/20 - Task 3729702 / Defect 3727897
*            If Etext is wrong alphanumeric character and SPF site name is ZEROBASE
*            then clear ETEXT
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_SCREEN.VARIABLES
    $INSERT I_PERROR.COMMON
    $INSERT I_F.USER
    $INSERT I_GTS.COMMON
    $INSERT I_F.SPF
*************************************************************************
      
    C = C2 ; L = L2
    IF INPUT.BUFFER <> "" THEN
        FROM.INPUT.BUFFER = 1
        COMI = FIELD(INPUT.BUFFER," ",1)
        INPUT.BUFFER = FIELD(INPUT.BUFFER," ",2,99)
        GOTO CONTROLWORD.REQUEST
    END
      
    IF GTSACTIVE OR RUNNING.UNDER.BATCH THEN ; * If we get in here and no input buffer is set just get out! - EN_10002087 ;*CI_10045462 S/E
        COMI = C.U
        FROM.INPUT.BUFFER = 1
        GOTO CONTROLWORD.REQUEST
    END
      
*************************************************************************
COMI.INPUT:
    FROM.INPUT.BUFFER = 0
    CRLF = CHARX(13):CHARX(10)
    CONVERT CRLF TO "" IN YTEXT        ; * Remove <CR><LF>s
    IF YTEXT <> "" THEN PRINT @(1,23): S.CLEAR.EOL : YTEXT :
    MAXLENGTH = FIELD(N1,".",1)+1
*
*========================================================================
    IF T.CONTROLWORD<1> = "NV" THEN
*         CALL !PTERM("-HALF")            ; * Invisible input; GB0000458
        ECHO OFF                        ; * GB0000458
    END
    $INSERT I_SF.INPUT
    IF T.CONTROLWORD<1> = "NV" THEN
*         CALL !PTERM("-FULL")            ; * Echo again; * GB0000458
        ECHO ON                         ; *GB0000458
    END
*========================================================================
*
    IF YTEXT <> "" THEN PRINT @(1,23): S.CLEAR.EOL :
    IF N1[1,1] <> " " THEN COMI = TRIM(COMI)
* cancel space (not needed blanks)
*------------------------------------------------------------------------
CONTROLWORD.REQUEST:
    IF COMI[1] EQ C.T THEN
        IF C2 = 8 THEN IF L2 = 22 THEN IF YTEXT NE T.REMTEXT(2) THEN
            E = YTEXT
            CALL EDIT.CMD.LINE
            E = ''
        END ELSE
            COMI = ''
        END
    END
    IF COMI[1] NE C.T THEN
        ECOMI = COMI
        P$ECOMI = COMI
    END
    IF COMI = "" THEN
        CONTROLWORD.OK = "" ; GOTO CHECK.INPUT.BY.MISC.IN2
    END
    LOCATE COMI IN T.CONTROLWORD<1> SETTING X THEN
        CONTROLWORD.OK = "Y"
    END ELSE
        CONTROLWORD.OK = ""
        IF C2 = 8 THEN IF L2 = 22 THEN
            IF FROM.INPUT.BUFFER THEN    ; * THEN DISREGARD
            END ELSE IF COMI[1,1] LT SPACE(1) THEN           ; * THEN DISREGARD
            END ELSE IF YTEXT EQ T.REMTEXT(2) THEN           ; * DISREGARD AWAITING FUNCTION
            END ELSE IF APPLICATION EQ 'SIGN.ON' THEN        ; * DISREGARD
            END ELSE IF APPLICATION EQ 'PASSWORD' THEN       ; * DISREGARD
            END ELSE IF LEN(COMI) GT 1 THEN        ; * THEN SAVE IT
                IF YTEXT EQ T.REMTEXT(1) THEN ATRNO=1 ELSE ATRNO=2
                IF COMI NE CMD$STACK<ATRNO,1> THEN  ; * THEN SAVE
                    TEMP1 = INDEX(CMD$STACK<ATRNO>,VM,19)      ; * STORE LAST 20
                    IF TEMP1 THEN
                        CMD$STACK = CMD$STACK<ATRNO>[1,TEMP1-1]
                    END
                    INS COMI BEFORE CMD$STACK<ATRNO,1>
                END
            END
            IF FIELD(N1,".",1) = 70 THEN RETURN
        END
* no check for action line
        YLEN = LEN(COMI) ; YCH = COMI[YLEN,1]
        IF YCH < " " THEN
            IF YCH = C.V OR YCH = C.W THEN
* input may be finished in combination with validation key
                IF YLEN > FIELD(N1,".",1) THEN INPUT X,1
* when ctrl V or ctrl W was the char. to finish the input
* a dummy input handles the unnessecary return code
                INPUT.BUFFER = YCH
                IF N1[1,1] = " " THEN COMI = COMI[1,YLEN-1]
                ELSE COMI = TRIM(COMI[1,YLEN-1])
            END ELSE
                IF INDEX(C.U:C.B:C.F:C.E:C.T:CHARX(29):CHARX(30),YCH,1) THEN
                    IF YLEN > FIELD(N1,".",1) THEN INPUT X,1
                END
            END
        END
*
CHECK.INPUT.BY.MISC.IN2:
* 
        ROUTINE = "IN2":T1<1> ; CALL @ROUTINE (N1, T1)
        IF ETEXT = "EB.RTN.TOO.MANY.CHARACTERS.1" AND R.SPF.SYSTEM<SPF.SITE.NAME> EQ "ZEROBASE" THEN    ;* site name of spf is zerobase and etext is too.many.characters
            ETEXT = ""                                             ;* clear ETEXT
        END
        IF ETEXT <> "" THEN
            E = ETEXT
            CALL ERR
            IF NOT(RUNNING.UNDER.BATCH) THEN GOTO COMI.INPUT  ;*CI_10045462 S
        END                                                 ;*CI_10045462 E
    END
RETURN
   
END
