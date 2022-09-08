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

**********************************************************
*-----------------------------------------------------------------------------
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ET.Contract
    SUBROUTINE CONV.SECURITY.TRANSFER.R07(YID,YREC,YFILE)
**********************************************************
* This record routine is attached in the CONVERSION.DETAILS
* record for SECURITY.TRANSFER. This routine will move the field values from
* the local reference fields to the CORE fields. This is for the
* ET clients upgrading from Lower releases to R07.

* 07/04/06 - GLOBUS_EN_10002889
*            New routine
*
* 11/07/06 - GLOBUS_CI_10042494
*            All the local reference fields gets cleared after conversion.
*
********************************************************************************

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

    IF NOT(LF.STR.TAX.CODE) THEN
        CALL SC.GET.LOC.REF('SECURITY.TRANSFER','CU.TAX.CODE',LF.STR.TAX.CODE)
    END

    IF NOT(LF.STR.TAX.TYPE) THEN
        CALL SC.GET.LOC.REF('SECURITY.TRANSFER','CU.TAX.TYPE',LF.STR.TAX.TYPE)
    END

    IF NOT(LF.STR.TAX.TCY) THEN
        CALL SC.GET.LOC.REF('SECURITY.TRANSFER','CU.TAX.TCY',LF.STR.TAX.TCY)
    END

    IF NOT(LF.STR.TAX.LCY) THEN
        CALL SC.GET.LOC.REF('SECURITY.TRANSFER','CU.TAX.LCY',LF.STR.TAX.LCY)
    END

    IF NOT(LF.STR.INT.CTR) THEN
        CALL SC.GET.LOC.REF('SECURITY.TRANSFER','INT.CTR',LF.STR.INT.CTR)
    END

    IF NOT(LF.STR.TRFR.EFF) THEN
        CALL SC.GET.LOC.REF('SECURITY.TRANSFER','TRFR.EFF.DATE',LF.STR.TRFR.EFF)
    END

    IF NOT(LF.STR.MAN.TCY) THEN
        CALL SC.GET.LOC.REF('SECURITY.TRANSFER','MAN.TAX.TCY',LF.STR.MAN.TCY)
    END

    IF NOT(LF.STR.MAN.LCY) THEN
        CALL SC.GET.LOC.REF('SECURITY.TRANSFER','MAN.TAX.LCY',LF.STR.MAN.LCY)
    END

    RETURN

*************
DATA.CONVERT:
*************
* Values from Local reference fields have to be moved to the corresponding CORE fields

    IF YREC<84> EQ '' AND LF.STR.TAX.CODE THEN
        YREC<84> = YREC<104,LF.STR.TAX.CODE>
        YREC<104,LF.STR.TAX.CODE> = ''
    END

    IF YREC<85> EQ '' AND LF.STR.TAX.TYPE THEN
        YREC<85> = YREC<104,LF.STR.TAX.TYPE>
        YREC<104,LF.STR.TAX.TYPE> = ''
    END

    IF YREC<86> EQ '' AND LF.STR.TAX.TCY THEN
        YREC<86> = YREC<104,LF.STR.TAX.TCY>
        YREC<104,LF.STR.TAX.TCY> = ''
    END

    IF YREC<87> EQ '' AND LF.STR.TAX.LCY THEN
        YREC<87> = YREC<104,LF.STR.TAX.LCY>
        YREC<104,LF.STR.TAX.LCY> = ''
    END

    IF YREC<88> EQ '' AND LF.STR.MAN.TCY THEN
        YREC<88> = YREC<104,LF.STR.MAN.TCY>
        YREC<104,LF.STR.MAN.TCY> = ''
    END

    IF YREC<89> EQ '' AND LF.STR.MAN.LCY THEN
        YREC<89> = YREC<104,LF.STR.MAN.LCY>
        YREC<104,LF.STR.MAN.LCY> = ''
    END
    IF YREC<90> EQ '' AND LF.STR.INT.CTR THEN
        YREC<90> = YREC<104,LF.STR.INT.CTR>
        YREC<104,LF.STR.INT.CTR> = ''
    END

    IF YREC<91> EQ '' AND LF.STR.TRFR.EFF THEN
        YREC<91> = YREC<104,LF.STR.TRFR.EFF>
        YREC<104,LF.STR.TRFR.EFF> = ''
    END

    RETURN
END
