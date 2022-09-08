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
* <Rating>-26</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Modelling
    SUBROUTINE CONV.AM.COMPARE.R7(AM.COMPARE.ID,R.AM.COMPARE,FN.AM.COMPARE)
*-----------------------------------------------------------------------------
*This routine clears the field LINKED.TO,FLD.ONE.IS.LOCK as it has been made obsolete.
*Field number is (as of 200611): AM.COM.LINKED.TO = 4.
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE

    GOSUB EQUATE.FIELDS       ;*Equate the fields.

    GOSUB CLEAR.FIELDS        ;*Clear the fields.

    RETURN
*-----------------------------------------------------------------------------

*** <region name= EQUATE.FIELDS>
EQUATE.FIELDS:
*** <desc>Equate the fields. </desc>
    EQUATE LINKED.TO TO 4
    EQUATE FLD.ONE.IS.LOCK TO 48
    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CLEAR.FIELDS>
CLEAR.FIELDS:
*** <desc>Clear the fields. </desc>
    R.AM.COMPARE<FLD.ONE.IS.LOCK> = ''
    R.AM.COMPARE<LINKED.TO> = ''
    RETURN
*** </region>
END
