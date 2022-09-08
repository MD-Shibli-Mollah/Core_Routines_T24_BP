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
* <Rating>100</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScfSafekeepingFees
    SUBROUTINE CONV.SAFE.EXTRACT.200606(YID,R.RECORD,FN.FILE)
************************************************
* Record routine for SAFECUSTODY.EXTRACT
* Conversion details will populate new field PORTFOLIO
**********************************************************
* Modification History:
*
* 05/04/06 - EN_10002885
*            Addition of new field PORTFOLIO
*****************************************************
    $INSERT I_EQUATE
    $INSERT I_COMMON

    IF NOT(R.RECORD<17>) THEN R.RECORD<17> = FIELD(YID,'.',1)
    RETURN
END
