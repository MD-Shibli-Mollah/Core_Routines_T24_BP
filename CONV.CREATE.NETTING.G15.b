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
    $PACKAGE AC.PaymentNetting
    SUBROUTINE CONV.CREATE.NETTING.G15(CN.ID,CN.RECORD,FN.CREATE.NET)
**************************
* 27/05/04 - BG_100006684
*            New field MSG.YPE is introduced.
*            If the existing record has Ft as system.ID then MSG.TYPE
*            should have "203"
***********************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CREATE.NETTING
*=======================
    IF CN.RECORD<AC.CN.SYSTEM.ID> = 'FT' THEN
        CN.RECORD<AC.CN.MSG.TYPE> = "203"
    END
END
**************************************
