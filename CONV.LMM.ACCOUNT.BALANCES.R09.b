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

*-----------------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------------
* Updating the field INT.ACCR.START in LMM.ACCOUNT.BALANCES to START.PERIOD.INT date,
* so that in future this field can be referred to get the accrual start date for
* the first accrual period
*
*------------------------------------------------------------------------------------
* Modification History :
*
* 14/11/08 - BG_100020857
*            Additional validation added to process only MM deals
*
*------------------------------------------------------------------------------------

    $PACKAGE MM.Contract
    SUBROUTINE CONV.LMM.ACCOUNT.BALANCES.R09(LMM.ACCBAL.ID,LMM.ACCBAL.REC,FN.LMM.ACCBAL)
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.LMM.ACCOUNT.BALANCES
*
    IF (LMM.ACCBAL.ID[1,2] EQ 'MM') AND (LMM.ACCBAL.REC<LD27.INT.ACCR.START> EQ '') AND LMM.ACCBAL.REC<LD27.DATE.INT.ACC.TO> THEN
* For first day accrual, update INT.ACCR.START to start interest period date
        LMM.ACCBAL.REC<LD27.INT.ACCR.START> = LMM.ACCBAL.REC<LD27.START.PERIOD.INT>
    END
*
    RETURN
END
