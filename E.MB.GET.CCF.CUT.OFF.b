* @ValidationCode : MjotNDkzOTY0Nzc3OmNwMTI1MjoxNTQ2NTkwNTM4NDIxOmtrYXZpdGhhbmphbGk6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgwOC4yMDE4MDcyMS0xMDI2Oi0xOi0x
* @ValidationInfo : Timestamp         : 04 Jan 2019 13:58:58
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kkavithanjali
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201808.20180721-1026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PV.ModelBank
SUBROUTINE E.MB.GET.CCF.CUT.OFF
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 01/01/19 - Enhancement 2890221 / Task 2926900
*            Conversion routine to return CCF.CUT.OFF from PV.PROFILE for PV.ASSET.DETAIL records
*
*-----------------------------------------------------------------------------

    $USING PV.Config
    $USING EB.Reports

    
    R.PV.MGT = ""
    R.PV.PROFILE = ""
    RET.ERROR = ""

*   Get the Contract Id
    RECORD.ID  = EB.Reports.getOData()

*   If the Contract Id is found, Read the PvAssetDetail record
    IF RECORD.ID THEN ;* Read PvAssetDetail record
        R.ASSET.DETAIL = PV.Config.AssetDetail.Read(RECORD.ID, RET.ERROR)
        PROFILE.ID = R.ASSET.DETAIL<PV.Config.AssetDetail.PvadProfileId>
    END

*   When ProfileId is retrieved, Call the API PV.GET.PROFILE to get the latest PV.PROFILE record
     
    IF PROFILE.ID THEN
        PV.Config.GetProfile(PROFILE.ID, CALC.DATE, R.PV.PROFILE, RET.ERROR)
        CCF.CUT.OFF = R.PV.PROFILE<PV.Config.Profile.PvpCcfCutOff>
        EB.Reports.setOData(CCF.CUT.OFF)
    END
    

RETURN

END
