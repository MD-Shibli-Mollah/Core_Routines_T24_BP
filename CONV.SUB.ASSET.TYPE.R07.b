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

********************************************************
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ET.Contract
    SUBROUTINE CONV.SUB.ASSET.TYPE.R07(YID,YREC,YFILE)
********************************************************
* This record routine is attached in the CONVERSION.DETAILS
* record for SUB.ASSET.TYPE. This routine will move the field values from
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
        IF NOT(LF.SAT.TAX.BASIS) THEN
            CALL SC.GET.LOC.REF('SUB.ASSET.TYPE','TAX.BASIS',LF.SAT.TAX.BASIS)
        END

* Values from Local reference fields have to be moved to the corresponding CORE fields
        IF YREC<13> EQ '' AND LF.SAT.TAX.BASIS THEN
            YREC<13> = YREC<34,LF.SAT.TAX.BASIS>
            YREC<34,LF.SAT.TAX.BASIS> = ''
        END
    END

    RETURN
END
