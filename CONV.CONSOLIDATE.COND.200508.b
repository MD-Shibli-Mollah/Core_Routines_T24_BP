* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*
*-----------------------------------------------------------------------------
* <Rating>931</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.Config
    SUBROUTINE CONV.CONSOLIDATE.COND.200508

**************************************************************************************
*
* This routine is to convert all field numbers in CONSOLIDATE.COND to field names
* by picking from STANDARD.SELECTION record of respective application.
*
* IMPORTANT NOTE:
*
* This conversion routine SHOULD be run immediately after Upgrade before authorising
* any of the STANDARD.SELECTION records, as SS authorisation may result in change in
* field position of application.
*
* Modification History
* ********************
* 03/05/13 - Defect 622761 / Task 666170
*            During upgrade from G13 to R12, on conversions CONV.CONSOLIDATE.COND.200508 routine
*            throws an error stating “STANDARD.SELECTION.MISSING.FOR. ” , while converting the
*            company specific CONSOLIDATE.COND records.
**************************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CONSOLIDATE.COND
    $INSERT I_F.STANDARD.SELECTION
*
    GOSUB INITIALISE
    GOSUB PROCESS.RECORDS
*
    RETURN
*
*-------------------------------------------------------------------------------------
INITIALISE:
*---------
* Initialise variables
    SEL.POS = ''
    SEL.ERR = '' ; SEL.LIST = '' ; NO.REC.SEL = ''
    GOSUB INTER.INIT

* Open files
    FN.CONSOLIDATE.COND = 'F.CONSOLIDATE.COND'
    F.CONSOLIDATE.COND = ''
    CALL OPF(FN.CONSOLIDATE.COND,F.CONSOLIDATE.COND)
*
    FN.STANDARD.SELECTION = 'F.STANDARD.SELECTION'
    F.STANDARD.SELECTION = ''
    CALL OPF(FN.STANDARD.SELECTION, F.STANDARD.SELECTION)
*
    FN.LRT = 'F.LOCAL.REF.TABLE'
    F.LRT = ''
    CALL OPF(FN.LRT, F.LRT)
*
    FN.LT = 'F.LOCAL.TABLE'
    F.LT = ''
    CALL OPF(FN.LT, F.LT)
*
    RETURN
*
*-------------------------------------------------------------------------------------
INTER.INIT:
*---------
    YR.COND = ''
    PREV.FILE.NAME = '' ; F.CNT = ''
    LF.CNT = ''
    KEY.APP.CNT = ''
    READ.ERR = ''
    R.CONSOLIDATE.COND = '' ; R.STANDARD.SELECTION = ''
    SPEC.COMP = ''
    SPEC.COMP = FIELD(COND.ID,".",2)

    RETURN
*
*-------------------------------------------------------------------------------------
PROCESS.RECORDS:
*--------------
    SEL.CMD = 'SSELECT ':FN.CONSOLIDATE.COND
    CALL EB.READLIST(SEL.CMD, SEL.LIST, '', NO.REC.SEL, SEL.ERR)
    IF NO.REC.SEL THEN
        LOOP REMOVE COND.ID FROM SEL.LIST SETTING SEL.POS
        WHILE COND.ID:SEL.POS
            GOSUB INTER.INIT
            READU R.CONSOLIDATE.COND FROM F.CONSOLIDATE.COND,COND.ID ELSE READ.ERR = "RECORD NOT FOUND"
            IF NOT(READ.ERR) THEN
                GOSUB CONVERT.FIELD.NO.TO.NAMES
                WRITE R.CONSOLIDATE.COND TO F.CONSOLIDATE.COND,COND.ID
                CALL F.RELEASE(FN.CONSOLIDATE.COND, COND.ID, F.CONSOLIDATE.COND)
            END
        REPEAT
    END
    RETURN
*
*-------------------------------------------------------------------------------------
CONVERT.FIELD.NO.TO.NAMES:
*------------------------
*
    FILE.COUNT = COUNT(R.CONSOLIDATE.COND<RE.CON.FILE.NAME>, VM) + (R.CONSOLIDATE.COND<RE.CON.FILE.NAME> # "")
    LOOP F.CNT += 1 WHILE F.CNT <= FILE.COUNT
        Y.FILE.NAME = R.CONSOLIDATE.COND<RE.CON.FILE.NAME,F.CNT>
        Y.FIELD.NO = R.CONSOLIDATE.COND<RE.CON.FIELD.NAME,F.CNT>
        IF NUM(Y.FIELD.NO) THEN
            IF Y.FILE.NAME <> "LOCAL" AND Y.FILE.NAME <> "NO LOOKUP" THEN
                GOSUB GET.AL.FIELD.NAME
                R.CONSOLIDATE.COND<RE.CON.FIELD.NAME,F.CNT> = Y.FIELD.NAME
            END
        END
        CONVERT ' ' TO '.' IN R.CONSOLIDATE.COND<RE.CON.NAME,F.CNT>
    REPEAT
*
    LOC.FILE.COUNT = COUNT(R.CONSOLIDATE.COND<RE.CON.LOCAL.FILE.NAME>, VM) + (R.CONSOLIDATE.COND<RE.CON.LOCAL.FILE.NAME> # "")
    LOOP LF.CNT += 1 WHILE LF.CNT <= LOC.FILE.COUNT
        Y.FILE.NAME = R.CONSOLIDATE.COND<RE.CON.LOCAL.FILE.NAME, LF.CNT>
        Y.FIELD.NO = R.CONSOLIDATE.COND<RE.CON.LOCAL.FIELD.NAM, LF.CNT>
        IF NUM(FIELD(Y.FIELD.NO,'/',1)) THEN
            IF Y.FILE.NAME <> "AL" THEN
                GOSUB GET.AL.FIELD.NAME
            END ELSE
                GOSUB GET.PL.FIELD.NAME
            END
            R.CONSOLIDATE.COND<RE.CON.LOCAL.FIELD.NAM,LF.CNT> = Y.FIELD.NAME
        END
        *
        Y.FILE.NAME = R.CONSOLIDATE.COND<RE.CON.CON.ON.FILE, LF.CNT>
        Y.FIELD.NO = R.CONSOLIDATE.COND<RE.CON.CON.ON.FIELD, LF.CNT>
        IF Y.FILE.NAME THEN
            IF NUM(Y.FIELD.NO) THEN
                IF Y.FILE.NAME <> "AL" THEN
                    GOSUB GET.AL.FIELD.NAME
                END ELSE
                    GOSUB GET.PL.FIELD.NAME
                END
                R.CONSOLIDATE.COND<RE.CON.CON.ON.FIELD,LF.CNT> = Y.FIELD.NAME
            END
        END
    REPEAT
*
    KEY.APPS = COUNT(R.CONSOLIDATE.COND<RE.CON.KEY.APPLICATION>, VM) + (R.CONSOLIDATE.COND<RE.CON.KEY.APPLICATION> # "")
    LOOP KEY.APP.CNT += 1 WHILE KEY.APP.CNT <= KEY.APPS
        Y.FILE.NAME = R.CONSOLIDATE.COND<RE.CON.KEY.LOCAL.FILE, KEY.APP.CNT>
        Y.FIELD.NO = R.CONSOLIDATE.COND<RE.CON.KEY.LOCAL.FIELD, KEY.APP.CNT>
        IF NUM(Y.FIELD.NO) THEN
            GOSUB GET.AL.FIELD.NAME
            R.CONSOLIDATE.COND<RE.CON.KEY.LOCAL.FIELD, KEY.APP.CNT> = Y.FIELD.NAME
        END
    REPEAT
*
    RETURN
*
*-------------------------------------------------------------------------------------
GET.AL.FIELD.NAME:
*----------------
    IF PREV.FILE.NAME <> Y.FILE.NAME THEN
        CALL F.READ(FN.STANDARD.SELECTION, Y.FILE.NAME, R.STANDARD.SELECTION, F.STANDARD.SELECTION, READ.ERR)
        PREV.FILE.NAME = Y.FILE.NAME
    END
* Validation included to avoid the fatal error if the FILE.NAME and FIELD.NAME
* is blank in company specific CONSOLIDATE.COND
    IF SPEC.COMP AND (Y.FILE.NAME EQ '' OR R.STANDARD.SELECTION EQ '') THEN
        Y.FILE.NAME = ''
        RETURN
    END

    IF R.STANDARD.SELECTION THEN
        SS.POS = '' ; Y.FIELD.NO.1 = '';  Y.FIELD.NAME.SAVE = ''
        IF INDEX(Y.FIELD.NO, "/", 1) THEN
            Y.FIELD.NO.1 = FIELD(Y.FIELD.NO,"/",2)
            Y.FIELD.NO = FIELD(Y.FIELD.NO,"/",1)
        END
SECOND.LOOP:
        IF INDEX(Y.FIELD.NO,".",1) THEN
            Y.LOC.REF = FIELD(Y.FIELD.NO,".",2)
            Y.FIELD.NO = FIELD(Y.FIELD.NO,".",1)
            LOCATE Y.FIELD.NO IN R.STANDARD.SELECTION<SSL.SYS.FIELD.NO,1> SETTING SS.POS ELSE SS.POS = ''
                IF R.STANDARD.SELECTION<SSL.SYS.FIELD.NAME,SS.POS> = "LOCAL.REF" THEN
                    Y.FILE.REC = ''
                    CALL F.READ(FN.LRT, Y.FILE.NAME, Y.FILE.REC, F.LRT, READ.ERR)
                    IF NOT(READ.ERR) THEN
                        Y.LT.KEY = Y.FILE.REC<1,Y.LOC.REF>
                        CALL F.READ(FN.LT, Y.LT.KEY, Y.LT.REC, F.LT, READ.ERR)
                        Y.FIELD.NAME = Y.LT.REC<2,1>
                    END ELSE
                        E = "INVALID.LOCAL.REF.FOR.":Y.FILE.NAME:".IN.":COND.ID
                        GOSUB FATAL.ERROR
                    END
                END ELSE
                    E = "INVALID.FIELD.NO.FOR.":Y.FILE.NAME:".IN.":COND.ID
                    GOSUB FATAL.ERROR
                END
            END ELSE
                LOCATE Y.FIELD.NO IN R.STANDARD.SELECTION<SSL.SYS.FIELD.NO,1> SETTING SS.POS ELSE SS.POS = ''
                    IF SS.POS THEN
                        Y.FIELD.NAME = R.STANDARD.SELECTION<SSL.SYS.FIELD.NAME, SS.POS>
                    END ELSE
                        E = "INVALID.FIELD.NO.FOR.":Y.FILE.NAME:".IN.":COND.ID
                        GOSUB FATAL.ERROR
                    END
                END
                IF Y.FIELD.NO.1 THEN
                    Y.FIELD.NAME.SAVE = Y.FIELD.NAME
                    Y.FIELD.NO = Y.FIELD.NO.1
                    Y.FIELD.NO.1 = ''
                    GOTO SECOND.LOOP
                END
                IF Y.FIELD.NAME.SAVE THEN Y.FIELD.NAME = Y.FIELD.NAME.SAVE:"/":Y.FIELD.NAME
            END ELSE
                E = "STANDARD.SELECTION.MISSING.FOR.":Y.FILE.NAME
                GOSUB FATAL.ERROR
            END
            RETURN
            *
            *-------------------------------------------------------------------------------------
GET.PL.FIELD.NAME:
            *----------------
            IF NOT(YR.COND) THEN
                READ YR.COND FROM F.CONSOLIDATE.COND, "ASSET&LIAB" ELSE READ.ERR = 'RECORD NOT FOUND'
                END
                Y.FIELD.NAME = YR.COND<RE.CON.NAME, Y.FIELD.NO>
                RETURN
                *
                *-------------------------------------------------------------------------------------
FATAL.ERROR:
                *----------
                TEXT = E
                CALL FATAL.ERROR("CONV.CONSOLIDATE.COND.200508")
                *
            END
