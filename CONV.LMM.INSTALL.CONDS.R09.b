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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------------
* Updating the field ACCRUAL.PARAM in LMM.INSTALL.CONDS to NULL, so that in future
* this field can be used to default ACCRUAL.PARAM value in the contract if set
*
*
    $PACKAGE LM.Static
    SUBROUTINE CONV.LMM.INSTALL.CONDS.R09(LMM.INSTL.ID,LMM.INSTL.REC,FN.LMM.INSTL)
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.LMM.INSTALL.CONDS
*
    IF LMM.INSTL.REC<LD30.ACCRUAL.PARAM> THEN
        LMM.INSTL.REC<LD30.ACCRUAL.PARAM> = ''
    END
*
    RETURN
END
