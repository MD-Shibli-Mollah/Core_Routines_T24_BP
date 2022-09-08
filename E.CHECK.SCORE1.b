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
* <Rating>-22</Rating>
*-----------------------------------------------------------------------------
*Subrouitne to chcek the aggregate score of a SA.SCORE.TXN versions
    $PACKAGE OP.ModelBank
    SUBROUTINE E.CHECK.SCORE1
* 04-03-16 - 1653120
*            Incorporation of components

    $USING SA.Foundation
    $USING EB.OverrideProcessing
    $USING EB.SystemTables


    GOSUB INITIALISE
    GOSUB PROCESS

INITIALISE:
    RETURN

PROCESS:
*    Y.SA.SCORE.TXN.ID = ID.NEW
*    CALL F.READ(FN.SA.SCORE.TXN,Y.SA.SCORE.TXN.ID,R.SA.TXN,F.SA.SCORE.TXN,READ.ERR1)
    Y.SCORE = EB.SystemTables.getComi()  ;*R.SA.TXN<SA.ST.AGG.SCORE>
    IF Y.SCORE LT 5 THEN
        EB.SystemTables.setText('Score is Less than 5')
        EB.OverrideProcessing.StoreOverride(1)
    END
    RETURN

    END
