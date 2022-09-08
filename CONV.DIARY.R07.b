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
    SUBROUTINE CONV.DIARY.R07(YID,YREC,YFILE)
***************************************************
* This record routine is attached in the CONVERSION.DETAILS
* record for DIARY. This routine will move the field values from
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

    IF NOT(LF.DIA.TAX.CODE) THEN
        CALL SC.GET.LOC.REF('DIARY','SC.TAX.CODE',LF.DIA.TAX.CODE)
    END

    IF NOT(LF.DIA.TAX.TYPE) THEN
        CALL SC.GET.LOC.REF('DIARY','SC.TAX.TYPE',LF.DIA.TAX.TYPE)
    END

    IF NOT(LF.DIA.DIST.FACTOR) THEN
        CALL SC.GET.LOC.REF('DIARY','INT.DIST.FACTOR',LF.DIA.DIST.FACTOR)
    END

    IF NOT(LF.DIA.INT.CTR) THEN
        CALL SC.GET.LOC.REF('DIARY','INT.CTR',LF.DIA.INT.CTR)
    END
    RETURN

*************
DATA.CONVERT:
*************
* Values from Local reference fields have to be moved to the corresponding CORE fields

    IF YREC<151> EQ '' AND LF.DIA.TAX.CODE THEN
        YREC<151> = YREC<165,LF.DIA.TAX.CODE>
        YREC<165,LF.DIA.TAX.CODE> = ''
    END

    IF YREC<152> EQ '' AND LF.DIA.TAX.TYPE THEN
        YREC<152> = YREC<165,LF.DIA.TAX.TYPE>
        YREC<165,LF.DIA.TAX.TYPE> = ''
    END

    IF YREC<153> EQ '' AND LF.DIA.DIST.FACTOR THEN
        YREC<153> = YREC<165,LF.DIA.DIST.FACTOR>
        YREC<165,LF.DIA.DIST.FACTOR> = ''
    END

    IF YREC<154> EQ '' AND LF.DIA.INT.CTR THEN
        YREC<154> = YREC<165,LF.DIA.INT.CTR>
        YREC<165,LF.DIA.INT.CTR> = ''
    END
    RETURN
END
