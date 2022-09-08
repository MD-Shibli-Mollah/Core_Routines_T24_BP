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

*****************************************************
*-----------------------------------------------------------------------------
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ET.Contract
    SUBROUTINE CONV.ENTITLEMENT.R07(YID,YREC,YFILE)
*****************************************************
* This record routine is attached in the CONVERSION.DETAILS
* record for ENTITLEMENT. This routine will move the field values from
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

    IF NOT(LF.ENT.TAX.CODE) THEN
        CALL SC.GET.LOC.REF('ENTITLEMENT','SC.TAX.CODE',LF.ENT.TAX.CODE)
    END

    IF NOT(LF.ENT.TAX.TYPE) THEN
        CALL SC.GET.LOC.REF('ENTITLEMENT','SC.TAX.TYPE',LF.ENT.TAX.TYPE)
    END

    IF NOT(LF.ENT.AMT.ACY) THEN
        CALL SC.GET.LOC.REF('ENTITLEMENT','SC.AMT.ACY',LF.ENT.AMT.ACY)
    END

    IF NOT(LF.ENT.AMT.LCY) THEN
        CALL SC.GET.LOC.REF('ENTITLEMENT','SC.AMT.LCY',LF.ENT.AMT.LCY)
    END

    IF NOT(LF.ENT.DIST.FACTOR) THEN
        CALL SC.GET.LOC.REF('ENTITLEMENT','INT.DIST.FACTOR',LF.ENT.DIST.FACTOR)
    END

    IF NOT(LF.ENT.INT.CTR) THEN
        CALL SC.GET.LOC.REF('ENTITLEMENT','INT.CTR',LF.ENT.INT.CTR)
    END

    IF NOT(LF.ENT.MAN.TCY) THEN
        CALL SC.GET.LOC.REF('ENTITLEMENT','MAN.TAX.TCY',LF.ENT.MAN.TCY)
    END

    IF NOT(LF.ENT.MAN.LCY) THEN
        CALL SC.GET.LOC.REF('ENTITLEMENT','MAN.TAX.LCY',LF.ENT.MAN.LCY)
    END

    RETURN

*************
DATA.CONVERT:
*************
* Values from Local reference fields have to be moved to the corresponding CORE fields

    IF YREC<139> EQ '' AND LF.ENT.TAX.CODE THEN
        YREC<139> = YREC<82,LF.ENT.TAX.CODE>
        YREC<82,LF.ENT.TAX.CODE> = ''
    END

    IF YREC<140> EQ '' AND LF.ENT.TAX.TYPE THEN
        YREC<140> = YREC<82,LF.ENT.TAX.TYPE>
        YREC<82,LF.ENT.TAX.TYPE> = ''
    END

    IF YREC<141> EQ '' AND LF.ENT.AMT.ACY THEN
        YREC<141> = YREC<82,LF.ENT.AMT.ACY>
        YREC<82,LF.ENT.AMT.ACY> = ''
    END

    IF YREC<142> EQ '' AND LF.ENT.AMT.LCY THEN
        YREC<142> = YREC<82,LF.ENT.AMT.LCY>
        YREC<82,LF.ENT.AMT.LCY> = ''
    END

    IF YREC<143> EQ '' AND LF.ENT.MAN.TCY THEN
        YREC<143> = YREC<82,LF.ENT.MAN.TCY>
        YREC<82,LF.ENT.MAN.TCY> = ''
    END

    IF YREC<144> EQ '' AND LF.ENT.MAN.LCY THEN
        YREC<144> = YREC<82,LF.ENT.MAN.LCY>
        YREC<82,LF.ENT.MAN.LCY> = ''
    END

    IF YREC<145> EQ '' AND LF.ENT.DIST.FACTOR THEN
        YREC<145> = YREC<82,LF.ENT.DIST.FACTOR>
        YREC<82,LF.ENT.DIST.FACTOR> = ''
    END

    IF YREC<146> EQ '' AND LF.ENT.INT.CTR THEN
        YREC<146> = YREC<82,LF.ENT.INT.CTR>
        YREC<82,LF.ENT.INT.CTR> = ''
    END

    RETURN
END
