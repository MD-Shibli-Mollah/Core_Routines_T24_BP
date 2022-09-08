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
* <Rating>170</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OP.ModelBank
    SUBROUTINE VAR.OR.SCORE.UPDATE

    $USING OP.ModelBank
    $USING EB.DataAccess
    $USING EB.SystemTables


    GOSUB OPENFILES
    GOSUB PROCESS
    RETURN


OPENFILES:

    Y.FORM.ID=EB.SystemTables.getRNew(OP.ModelBank.EbInternalScore.EbIntTwoOneAppFormId)
    RETURN

PROCESS:

    R.MORTGAGE = OP.ModelBank.EbMortgageFormOne.Read(Y.FORM.ID, Y.ERR)
    IF EB.SystemTables.getRNew(OP.ModelBank.EbInternalScore.EbIntTwoOneInScoreResult)='Negotiable' THEN
        R.MORTGAGE<OP.ModelBank.EbMortgageFormOne.EbMorFivThrSaScoreStatus>="NEGOTIABLE"
    END
    ELSE IF EB.SystemTables.getRNew(OP.ModelBank.EbInternalScore.EbIntTwoOneInScoreResult)='No' THEN
    R.MORTGAGE<OP.ModelBank.EbMortgageFormOne.EbMorFivThrSaScoreStatus>="REJECTED"
    END
    ELSE IF EB.SystemTables.getRNew(OP.ModelBank.EbInternalScore.EbIntTwoOneInScoreResult)='Yes' THEN
    R.MORTGAGE<OP.ModelBank.EbMortgageFormOne.EbMorFivThrSaScoreStatus>="ACCEPTED"
    END
    OP.ModelBank.EbMortgageFormOne.Write(Y.FORM.ID, R.MORTGAGE)

    RETURN

    END

