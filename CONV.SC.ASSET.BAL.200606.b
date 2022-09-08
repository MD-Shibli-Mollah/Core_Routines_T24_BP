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
    $PACKAGE SC.ScfAdvisoryFees
    SUBROUTINE CONV.SC.ASSET.BAL.200606(YID,YREC,YFILE)

*-------------------------------------------------------------------------
* Conversion routine to populate newly added fields PORTFOLIO and
* SECURITY.CODE for existing records.
*
*
*-------------------------------------------------------------------------
*
* Modification History:
*
*-------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE

    YREC<12> = FIELD(YID,'.',1)
    YREC<13> = FIELD(YID,'.',2)

    RETURN
END
