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

***************************************************
*-----------------------------------------------------------------------------
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ET.Contract
    SUBROUTINE CONV.SEC.TRADE.R07(YID,YREC,YFILE)
***************************************************
* This record routine is attached in the CONVERSION.DETAILS
* record for SEC.TRADE. This routine will move the field values from
* the local reference fields to the CORE fields. This is for the
* ET clients upgrading from Lower releases to R07.

* 07/04/06 - GLOBUS_EN_10002889
*            New routine
*
* 11/07/06 - GLOBUS_CI_10042494
*            All the local reference fields gets cleared after conversion.
*
*****************************************************************************

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

    IF NOT(LF.SBS.TAX.CODE) THEN
        CALL SC.GET.LOC.REF('SEC.TRADE','CU.TAX.CODE',LF.SBS.TAX.CODE)
    END

    IF NOT(LF.SBS.TAX.TYPE) THEN
        CALL SC.GET.LOC.REF('SEC.TRADE','CU.TAX.TYPE',LF.SBS.TAX.TYPE)
    END

    IF NOT(LF.SBS.TAX.TCY) THEN
        CALL SC.GET.LOC.REF('SEC.TRADE','CU.TAX.TCY',LF.SBS.TAX.TCY)
    END

    IF NOT(LF.SBS.TAX.LCY) THEN
        CALL SC.GET.LOC.REF('SEC.TRADE','CU.TAX.LCY',LF.SBS.TAX.LCY)
    END

    IF NOT(LF.SBS.INT.CTR) THEN
        CALL SC.GET.LOC.REF('SEC.TRADE','INT.CTR',LF.SBS.INT.CTR)
    END

    IF NOT(LF.SBS.MAN.TCY) THEN
        CALL SC.GET.LOC.REF('SEC.TRADE','MAN.TAX.TCY',LF.SBS.MAN.TCY)
    END

    IF NOT(LF.SBS.MAN.LCY) THEN
        CALL SC.GET.LOC.REF('SEC.TRADE','MAN.TAX.LCY',LF.SBS.MAN.LCY)
    END

    RETURN

*************
DATA.CONVERT:
*************
* Values from Local reference fields have to be moved to the corresponding CORE fields

    IF YREC<44> EQ '' AND LF.SBS.TAX.CODE THEN
        YREC<44> = RAISE(YREC<180,LF.SBS.TAX.CODE>)
        YREC<180,LF.SBS.TAX.CODE> = ''
    END

    IF YREC<45> EQ '' AND LF.SBS.TAX.TYPE THEN
        YREC<45> = RAISE(YREC<180,LF.SBS.TAX.TYPE>)
        YREC<180,LF.SBS.TAX.TYPE> = ''
    END

    IF YREC<46> EQ '' AND LF.SBS.TAX.TCY THEN
        YREC<46> = RAISE(YREC<180,LF.SBS.TAX.TCY>)
        YREC<180,LF.SBS.TAX.TCY> = ''
    END

    IF YREC<47> EQ '' AND LF.SBS.TAX.LCY THEN
        YREC<47> = RAISE(YREC<180,LF.SBS.TAX.LCY>)
        YREC<180,LF.SBS.TAX.LCY> = ''
    END

    IF YREC<48> EQ '' AND LF.SBS.MAN.TCY THEN
        YREC<48> = RAISE(YREC<180,LF.SBS.MAN.TCY>)
        YREC<180,LF.SBS.MAN.TCY> = ''
    END

    IF YREC<49> EQ '' AND LF.SBS.MAN.LCY THEN
        YREC<49> = RAISE(YREC<180,LF.SBS.MAN.LCY>)
        YREC<180,LF.SBS.MAN.LCY> = ''
    END

    IF YREC<50> EQ '' AND LF.SBS.INT.CTR THEN
        YREC<50> = RAISE(YREC<180,LF.SBS.INT.CTR>)
        YREC<180,LF.SBS.INT.CTR> = ''
    END

    RETURN
END
