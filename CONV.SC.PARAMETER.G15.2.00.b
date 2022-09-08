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
    $PACKAGE SC.Config
    SUBROUTINE CONV.SC.PARAMETER.G15.2.00(PARAM.ID,R.SC.PARAM,PARAM.FILE)

* This routine is to replace local ref fields from 106 to 116 bcoz reserved fields
* are introduced after local ref fields.

    IF R.SC.PARAM<106> THEN
        R.SC.PARAM<116> = R.SC.PARAM<106>
        R.SC.PARAM<106> = ''
    END

    RETURN
END
