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

*-----------------------------------------------------------------------------
* <Rating>11</Rating>
*-----------------------------------------------------------------------------
* Version 3 07/09/00  GLOBUS Release No. G12.2.00 04/04/02

    $PACKAGE LD.Commitment
    SUBROUTINE CONV.LD.TRANCHE.DET
*
*   Build the new live file LD.TRANCHE.DETAILS for commitment fee
*
* 22/04/03 - BG_100004086
*            F.READU replaced with F.READ statement.
* 14/05/03 - BG_100004819
*            Extra argument passed for F.READ is removed
*
* 11/08/03 - CI_10011635
*            F.WRITE is replaced with WRITE statement.
* 02/12/03 - CI_10015410
*            Update the LD.TRANCHE.ST.LIST and
*            LD.TRANCHE.END.LIST during conversion
*
* 30/12/03 - CI_100016944
*            Populate VALUE.DATE and FIN.MAT.DATE as DD.START.DATE and
*            DD.END.DATE in LD.TRANCHE.DETAILS.
*
* 29/08/05 - CI_10034022
*            LD.TRANCHE.DETAILS shows the principal.amount as TR.OUTS.AMT
*            eventhough the drawdown is exists for principal amount.
*
* 15/12/08 - BG_100021299
*            Conversion fails while running RUN.CONVERSION.PGMS
*

    $INSERT I_COMMON
    $INSERT I_EQUATE

*
*************************************************************************
    GOSUB INITIALISE          ;* Special Initialising

*************************************************************************
* CI_10015410 S

    EQU LD.COMMT.AVAIL.AMT TO 96
    EQU LD.TRANCHE.AMT TO 97
    EQU LD.D.D.START.DATE TO 98
    EQU LD.D.D.END.DATE TO 99
    EQU LD.VALUE.DATE TO 6
    EQU LD.FIN.MAT.DATE TO 7

    EQU LD.TR.DET.TRANCHE.AMT TO 1
    EQU LD.TR.DET.DD.START.DATE TO 2
    EQU LD.TR.DET.DD.END.DATE TO 3
    EQU LD.TR.DET.TR.OUTS.AMT TO 4
    EQU LD.TR.DET.AMT.MOVEMT TO 6
    EQU LD.TR.DET.AMT.MV.DATE TO 7
*
    EQU LD27.EFFECTIVE.DATE TO 3
    EQU LD27.TRANS.PRIN.AMT TO 4

* CI_10014510 E

* Main Program Loop

*
    YLD.FILE = "F.LD.LOANS.AND.DEPOSITS"
    YLD.VAR = ""
    CALL OPF(YLD.FILE,YLD.VAR)
    LD.REC = ""
*
    SELECT.STATEMENT = 'SELECT ':YLD.FILE:' WITH ':'(':'CATEGORY GE 21095'
    SELECT.STATEMENT := ' AND CATEGORY LE 21099':')':' OR ' :'('
    SELECT.STATEMENT := ' CATEGORY GE 21101':' AND CATEGORY LE 21099':')'
*
    LD.ID.LIST = ""
    CALL EB.READLIST(SELECT.STATEMENT, LD.ID.LIST, "", "", "")
*
    LOOP
        REMOVE LD.ID FROM LD.ID.LIST SETTING ID.POS
    UNTIL LD.ID EQ ""
        ETEXT = ''
        READ LD.REC FROM YLD.VAR,  LD.ID SETTING ERR.MSG THEN
            GOSUB UPDATE.LD.TRANCHE.DET
            GOSUB UPDATE.LD.TRANCHE.LIST          ;* CI_10014510 S/E
        END
        IF ETEXT THEN CALL EXCEPTION.LOG('S','ST','CONV.LD.TRANCHE.DET','','','','F.LD.LOANS.AND.DEPOSIT',LD.ID,'','','')
    REPEAT
MAIN.REPEAT:


    V$EXIT:
    RETURN          ;* From main program

*************************************************************************
*                      S u b r o u t i n e s                            *
*************************************************************************

INITIALISE:
* CI_10015410 S
    LD.TRANCHE.ST.LIST.FILE = 'F.LD.TRANCHE.ST.LIST'
    F.LD.TRANCHE.ST.LIST = ''
    CALL OPF(LD.TRANCHE.ST.LIST.FILE, F.LD.TRANCHE.ST.LIST)
*
    LD.TRANCHE.END.LIST.FILE = 'F.LD.TRANCHE.END.LIST'
    F.LD.TRANCHE.END.LIST = ''
    CALL OPF(LD.TRANCHE.END.LIST.FILE, F.LD.TRANCHE.END.LIST)
* CI_10015410  E
*
    RETURN

*************************************************************************
UPDATE.LD.TRANCHE.DET:
*
    LD.TRANCHE.DETAILS.FILE = 'F.LD.TRANCHE.DETAILS'
    LD.TRANCHE.DETAILS.VAR = ''
    CALL OPF(LD.TRANCHE.DETAILS.FILE,LD.TRANCHE.DETAILS.VAR)

    LD.TR.REC = ""
    READ LD.TR.REC FROM LD.TRANCHE.DETAILS.VAR,LD.ID  ELSE
        LD.TR.REC<LD.TR.DET.TRANCHE.AMT> = LD.REC<LD.TRANCHE.AMT>
        LD.TR.REC<LD.TR.DET.DD.START.DATE> = LD.REC<LD.VALUE.DATE>    ;* CI_10016944+
        LD.TR.REC<LD.TR.DET.DD.END.DATE> = LD.REC<LD.FIN.MAT.DATE>    ;* CI_10016944-
        NEW.TR.COUNT = DCOUNT(LD.REC<LD.TRANCHE.AMT>,VM)
        IF NEW.TR.COUNT = 1 THEN        ;* Update the first multi value set to cater prin.inc/dec problem ;* CI_10034022 S
            LD.TR.REC<LD.TR.DET.TR.OUTS.AMT,1,1> = LD.REC<LD.COMMT.AVAIL.AMT>
            LD.TR.REC<LD.TR.DET.AMT.MOVEMT,1,1> = (LD.REC<LD.TRANCHE.AMT> - LD.REC<LD.COMMT.AVAIL.AMT>) * -1
            LD.TR.REC<LD.TR.DET.AMT.MV.DATE,1,1> = LD.REC<LD.D.D.START.DATE,1>
        END ELSE    ;* CI_10034022 E
            FOR NEW.TR.I = 1 TO NEW.TR.COUNT
                LD.TR.REC<LD.TR.DET.TR.OUTS.AMT,NEW.TR.I,1> = LD.REC<LD.TRANCHE.AMT,NEW.TR.I>
                LD.TR.REC<LD.TR.DET.AMT.MOVEMT,NEW.TR.I,1> = 0
                LD.TR.REC<LD.TR.DET.AMT.MV.DATE,NEW.TR.I,1> = LD.REC<LD.VALUE.DATE>       ;* CI_10016944
            NEXT NEW.TR.I
*
* Update the tranche level movement from ACCBAL
*
            YACC.BAL.FILE = "F.LMM.ACCOUNT.BALANCES"
            YACC.BAL.VAR = ""
            CALL OPF(YACC.BAL.FILE,YACC.BAL.VAR)
            ACCBAL.ID = LD.ID:"00"

*
            READ ACCBAL.REC FROM  YACC.BAL.VAR , ACCBAL.ID SETTING  ERRMSG ELSE
                ACCBAL.REC=''
            END
            NO.EFF.DATE = DCOUNT(ACCBAL.REC<LD27.EFFECTIVE.DATE>,VM)
            FOR DATE.I = 2 TO NO.EFF.DATE
                MVMT.DATE = ACCBAL.REC<LD27.EFFECTIVE.DATE,DATE.I>
                MVMT.AMT = ACCBAL.REC<LD27.TRANS.PRIN.AMT,DATE.I> * (-1)
                IF MVMT.AMT NE 0 THEN
                    GOSUB INSERT.MOVEMENT
                END
            NEXT DATE.I
*
        END
        WRITE LD.TR.REC TO LD.TRANCHE.DETAILS.VAR, LD.ID    ;* CI_10011635

*
    END
*
    RETURN
*************************************************************************
INSERT.MOVEMENT:
*
    TR.COUNT = DCOUNT(LD.TR.REC<LD.TR.DET.TRANCHE.AMT>,VM)
    INVALID.MOVEMENT = 1
    AMT.INSERTED = ""
    FOR TR.I = 1 TO TR.COUNT UNTIL AMT.INSERTED
*
        IF MVMT.DATE GE LD.TR.REC<LD.TR.DET.DD.START.DATE,TR.I> AND MVMT.DATE LE LD.TR.REC<LD.TR.DET.DD.END.DATE,TR.I> THEN
            LOCATE MVMT.DATE IN LD.TR.REC<LD.TR.DET.AMT.MV.DATE,TR.I,1> BY "AL" SETTING DT.POS THEN
                LD.TR.REC<LD.TR.DET.AMT.MOVEMT,TR.I,DT.POS> += MVMT.AMT
            END ELSE
                INS MVMT.AMT BEFORE LD.TR.REC<LD.TR.DET.AMT.MOVEMT,TR.I,DT.POS>
                INS MVMT.DATE BEFORE LD.TR.REC<LD.TR.DET.AMT.MV.DATE,TR.I,DT.POS>
            END
            INVALID.MOVEMENT = ""
            AMT.INSERTED = 1
            LD.TR.REC<LD.TR.DET.TR.OUTS.AMT,TR.I> = ""
            OUTS.AMT = LD.TR.REC<LD.TR.DET.TRANCHE.AMT,TR.I>
            NO.OF.INSERT = DCOUNT(LD.TR.REC<LD.TR.DET.AMT.MV.DATE,TR.I>,SM)
            FOR INS.I = 1 TO NO.OF.INSERT
                OUTS.AMT += LD.TR.REC<LD.TR.DET.AMT.MOVEMT,TR.I,INS.I>
                LD.TR.REC<LD.TR.DET.TR.OUTS.AMT,TR.I,INS.I> = OUTS.AMT
            NEXT INS.I
        END
*
    NEXT TR.I
    RETURN
**************************************************************************************
* CI_10015410 S

UPDATE.LD.TRANCHE.LIST:
********************

* Update LD.TRANCHE.ST.LIST and LD.TRANCHE.END.LIST with D.D.START.DATE
* and D.D.END.DATE.

    DD.START.DATE = LD.REC<LD.D.D.START.DATE>
    DD.END.DATE = LD.REC<LD.D.D.END.DATE>
*

    IF DD.START.DATE THEN

        FILE.ID = DD.START.DATE
        FN.FILE = LD.TRANCHE.ST.LIST.FILE
        F.FILE = F.LD.TRANCHE.ST.LIST
        GOSUB READ.TRANCHE.LIST
        GOSUB WRITE.TRANCHE.LIST
    END

    IF DD.END.DATE THEN

        FILE.ID = DD.END.DATE
        FN.FILE = LD.TRANCHE.END.LIST.FILE
        F.FILE = F.LD.TRANCHE.END.LIST
        GOSUB READ.TRANCHE.LIST
        GOSUB WRITE.TRANCHE.LIST
    END

    RETURN

READ.TRANCHE.LIST:
****************
    YREC = ''
    READ YREC FROM F.FILE,FILE.ID ELSE
        YREC = ''
    END
    RETURN

WRITE.TRANCHE.LIST:
*****************

    IF YREC THEN
        YREC<1,-1> = LD.ID
    END ELSE
        YREC = LD.ID
    END
    WRITE YREC ON F.FILE,FILE.ID
    RETURN

* CI_10015410 E
END       ;* Final End
