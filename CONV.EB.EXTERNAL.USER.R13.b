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
* <Rating>-12</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.ARC
    SUBROUTINE CONV.EB.EXTERNAL.USER.R13(YID, R.RECORD, FN.FILE)
********************************************************************************
* This conversion routine will move the DATE.FORMAT field's value to LOCAL.REFERENCE field
* and DATE.FORMAT field value will be cleared
********************************************************************************
*** Modification History
*
* 22/01/16 - Task 1608211 / Defect 1598395
* 			 EB.EXTERNAL.USER Conversion issue in USER.TYPE field
*
*********************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE

*---------------------------------------------------------------------------------

    GOSUB CHANGE.POSITION
    RETURN

*-----------------------------------------------------------------------------

CHANGE.POSITION:
***
    LOCAL.REF.VAL = R.RECORD<42>   ;*get the local ref field value
    R.RECORD<48> = LOCAL.REF.VAL
    R.RECORD<42> = ''          ;*clear the DATE.FORMAT field value
    RETURN
***

    END
