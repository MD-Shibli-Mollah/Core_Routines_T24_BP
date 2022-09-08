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
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PW.Foundation
    SUBROUTINE CONV.PW.PROCESS.DEF.200607(DEF.ID,R.PW.PROCESS.DEF,FILE)

* Conversion routine for the PW.PROCESS.DEFINITION.
* 
* Modifications:
*
* 02/02/06 - EN_10002782
*            Re-usable of PW.ACTIVITIES
*            Ref:SAR-2005-09-27-0002
*
*----------------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE

    R.PW.PROCESS.DEF<17> = '' ; * set the PROCESS.STATUS as NULL

    CONVERT VM TO SM IN R.PW.PROCESS.DEF<18> ; * lower all vm to sm's
    CONVERT VM TO SM IN R.PW.PROCESS.DEF<19> ; * lower all vm to sm's
    
    RETURN
END
