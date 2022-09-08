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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MG.ModelBank
    SUBROUTINE E.MB.MG.PAYMENT(MG.BAL.ID,DESC)

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.MG.PAYMENT

    FN.MG.BAL = 'F.MG.PAYMENT'
    F.MG.BAL = ''
    CALL OPF(FN.MG.BAL,F.MG.BAL)

    DESC = ''

    CALL F.READ(FN.MG.BAL,MG.BAL.ID,R.MG.BAL,F.MG.BAL,MG.BAL.ERR)
    IF R.MG.BAL NE '' THEN
        DESC = R.MG.BAL<MG.PAY.TRANSACTION.TYPE>
    END

    RETURN

