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
    $PACKAGE EB.Utility
    SUBROUTINE CONV.DATES.G14 (DATES.ID,R.DATES.RECORD,F.DATES.FILE)

    $INSERT I_COMMON
    $INSERT I_EQUATE

*------------------------------------------------------------------*
* The field OVERRIDE has been moved from position 15 to 20. This   *
* conversion routine moves the data corresponding to the OVERRIDE  *
* field from the position 15 to 20.                                *
*------------------------------------------------------------------*
* Modifications:                                                   *
* -------------                                                    *
* 27/08/03 - CI_10012017                                           *
*            Creation                                              *
*------------------------------------------------------------------*
    IF R.DATES.RECORD<15> THEN
        R.DATES.RECORD<20> = R.DATES.RECORD<15>
        R.DATES.RECORD<15> = ''
    END

    RETURN
END
