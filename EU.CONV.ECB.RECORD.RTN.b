* @ValidationCode : MjoxNjU0NDg5OTc5OkNwMTI1MjoxNTUxMTc5NTU3ODE0OnZ2aWduZXNoOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgxMS4yMDE4MTAyMi0xNDA2Oi0xOi0x
* @ValidationInfo : Timestamp         : 26 Feb 2019 16:42:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vvignesh
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EU.Config
SUBROUTINE EU.CONV.ECB.RECORD.RTN
**************************************************************
* This record routine is used to clear the local ECB balances,while doing euro process via EU.CONVERSION.PARAM
*
**************************************************************
* Modification logs:
* ------------------
* 08/08/2014 - Defect 1074671 / Task 1092369
*              New routine to do conversion process.
*
* 08/11/18 - Enhancement 2822520 / Task 2849759
*            Code changed done for componentisation and to avoid errors while compilation
*            using strict compile
*------------------------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_EU.COMMON
    $INSERT I_F.EB.CONTRACT.BALANCES

    IF C$R.EU.REC<ECB.CURRENCY> EQ C$EU.NEW.LCY THEN
        C$R.EU.REC<ECB.OPEN.BAL.LCL>     = ''
        C$R.EU.REC<ECB.CR.MVMT.LCL>      = ''
        C$R.EU.REC<ECB.DB.MVMT.LCL>      = ''
        C$R.EU.REC<ECB.ACCR.AMOUNT.LCY>  = ''
        C$R.EU.REC<ECB.ACCR.NAU.AMT.LCY> = ''
    END

RETURN
END
