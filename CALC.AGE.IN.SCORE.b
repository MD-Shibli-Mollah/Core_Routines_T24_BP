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
* <Rating>-37</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OP.ModelBank
    SUBROUTINE CALC.AGE.IN.SCORE

* 04-03-16 - 1653120
*            Incorporation of components

    $USING SA.Foundation
    $USING OP.ModelBank
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS

INITIALISE:

    TEMP = EB.SystemTables.getComi()
    RETURN

PROCESS:
    Y.SA.TXN = ''
    VAR1 = '1'
    IF (EB.SystemTables.getComi() NE EB.SystemTables.getRNewLast(SA.Foundation.ScoreTxn.StDataVal)<1,1>) THEN
        IF EB.SystemTables.getRNew(SA.Foundation.ScoreTxn.StDataVal)<1,1>  AND (Y.SA.TXN EQ '') THEN
            I = 1
            GOSUB AGE.DETAILS
            Y.SA.TXN = VAR1 + 1
        END
        IF TEMP NE EB.SystemTables.getRNew(SA.Foundation.ScoreTxn.StDataVal)<1,1> THEN
            GOSUB AGE.DETAILS
            Y.SA.TXN = VAR1 + 1
        END
    END
    RETURN

AGE.DETAILS:
    DOB = EB.SystemTables.getRNew(SA.Foundation.ScoreTxn.StDataVal)<1,I>    ;*COMI
    tmp.TODAY = EB.SystemTables.getToday()
    OP.ModelBank.ApplCalcAge(AGE,tmp.TODAY,DOB)   ;*calculating age based on date of birth
    EB.SystemTables.setToday(tmp.TODAY)
    EB.SystemTables.setComi(AGE)
    CRT "AGE ":AGE
    TEMP = AGE
    tmp=EB.SystemTables.getRNew(SA.Foundation.ScoreTxn.StDataVal); tmp<1,I>=TEMP; EB.SystemTables.setRNew(SA.Foundation.ScoreTxn.StDataVal, tmp)
    RETURN

    END
