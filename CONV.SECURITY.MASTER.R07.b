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

*********************************************************
*-----------------------------------------------------------------------------
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ET.Contract
    SUBROUTINE CONV.SECURITY.MASTER.R07(YID,YREC,YFILE)
*********************************************************
* This record routine is attached in the CONVERSION.DETAILS
* record for SECURITY.MASTER. This routine will move the field values from
* the local reference fields to the CORE fields. This is for the
* ET clients upgrading from Lower releases to R07.

* 07/04/06 - GLOBUS_EN_10002889
*            New routine
*
* 11/07/06 - GLOBUS_CI_10042494
*            All the local reference fields gets cleared after conversion.
*
******************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STANDARD.SELECTION
    $INSERT I_F.COMPANY

    LOCATE 'ET' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING PROD.POSN THEN
        $INSERT I_ET.CONVERSION.COMMON
        GOSUB POPULATE.COMMON
        GOSUB DATA.CONVERT
    END

    RETURN

****************
POPULATE.COMMON:
****************

    IF NOT(LF.SM.TAX.CODE) THEN
        CALL SC.GET.LOC.REF('SECURITY.MASTER','SC.TAX.CODE',LF.SM.TAX.CODE)
    END

    IF NOT(LF.SM.TAX.BASIS) THEN
        CALL SC.GET.LOC.REF('SECURITY.MASTER','TAX.BASIS',LF.SM.TAX.BASIS)
    END

    IF NOT(LF.SM.ISSUE.PRICE) THEN
        CALL SC.GET.LOC.REF('SECURITY.MASTER','ISSUE.PRICE',LF.SM.ISSUE.PRICE)
    END

    IF NOT(LF.SM.REDEM.PRICE) THEN
        CALL SC.GET.LOC.REF('SECURITY.MASTER','REDEM.PRICE',LF.SM.REDEM.PRICE)
    END

    IF NOT(LF.SM.INT.CTR) THEN
        CALL SC.GET.LOC.REF('SECURITY.MASTER','INT.CTR',LF.SM.INT.CTR)
    END

    IF NOT(LF.SM.CTR.DATE) THEN
        CALL SC.GET.LOC.REF('SECURITY.MASTER','INT.CTR.DATE',LF.SM.CTR.DATE)
    END

    IF NOT(LF.SM.YIELD) THEN
        CALL SC.GET.LOC.REF('SECURITY.MASTER','ORIGINAL.YIELD',LF.SM.YIELD)
    END

    RETURN

*************
DATA.CONVERT:
*************
* Values from Local reference fields have to be moved to the corresponding CORE fields

    IF YREC<141> EQ '' AND LF.SM.TAX.CODE THEN
        YREC<141> = YREC<159,LF.SM.TAX.CODE>
        YREC<159,LF.SM.TAX.CODE> = ''
    END

    IF YREC<142> EQ '' AND LF.SM.TAX.BASIS THEN
        YREC<142> = YREC<159,LF.SM.TAX.BASIS>
        YREC<159,LF.SM.TAX.BASIS> = ''
    END

    IF YREC<143> EQ '' AND LF.SM.ISSUE.PRICE THEN
        YREC<143> = YREC<159,LF.SM.ISSUE.PRICE>
        YREC<159,LF.SM.ISSUE.PRICE> = ''
    END

    IF YREC<144> EQ '' AND LF.SM.REDEM.PRICE THEN
        YREC<144> = YREC<159,LF.SM.REDEM.PRICE>
        YREC<159,LF.SM.REDEM.PRICE> = ''
    END

    IF YREC<145> EQ '' AND LF.SM.CTR.DATE THEN
        YREC<145> = YREC<159,LF.SM.CTR.DATE>
        YREC<159,LF.SM.CTR.DATE> = ''
    END

    IF YREC<146> EQ '' AND LF.SM.INT.CTR THEN
        YREC<146> = YREC<159,LF.SM.INT.CTR>
        YREC<159,LF.SM.INT.CTR> = ''
    END

    IF YREC<147> EQ '' AND LF.SM.YIELD THEN
        YREC<147> = YREC<159,LF.SM.YIELD>
        YREC<159,LF.SM.YIELD> = ''
    END

    RETURN
END
