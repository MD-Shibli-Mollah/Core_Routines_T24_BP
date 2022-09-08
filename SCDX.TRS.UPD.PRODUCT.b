* @ValidationCode : MjotMTExNzk4NDgyOkNwMTI1MjoxNjA0OTAzMDExMDI0OnJkZWVwaWdhOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMjAyMDA4MjgtMTYxNzoyNDoyNA==
* @ValidationInfo : Timestamp         : 09 Nov 2020 11:53:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 24/24 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.PRODUCT(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine fetches the description of Asset Type involved in Transaction
* for reporting purpose.
* Attached as the link routine in TX.TXN.BASE.MAPPING for updation in
* Database SCDX.ARM.MIFID.DATA
* Incoming parameters:
**********************
* TXN.ID   -   Transaction ID of the contract.
* TXN.REC  -   A dynamic array holding the contract.
* TXN.DATA -   Data passed based on setup done in TX.TXN.BASE.MAPPING
*
* Outgoing parameters:
**********************
* RET.VAL  -   Description of Asset Type
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 22/10/2020 - SI - 3754772 / ENH - 3994136 / TASK - 3994144
*              TRS Reporting / Mapping Routines
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts and control logic</desc>

    $USING ST.Valuation
    $USING SC.SctTrading
    $USING SC.ScoSecurityMasterMaintenance
    $USING DX.Trade
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to check whether the database SCDX.ARM.MIFID.DATA updation is required for transaction
           
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>

    RET.VAL = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Process to check whether the database SCDX.ARM.MIFID.DATA updation is required for transaction </desc>

    BEGIN CASE
        CASE TXN.ID[1,6] EQ "SCTRSC"
            SECURITY.CODE    = TXN.REC<SC.SctTrading.SecTrade.SbsSecurityCode>
            R.SEC.MASTER = '' ; SM.ERR = ''
            R.SEC.MASTER     = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(SECURITY.CODE, SM.ERR)
            SUB.ASSET.TYPE   = R.SEC.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmSubAssetType>
            GOSUB GET.ASSET.TYPE.DESC ; *Get the description of Asset Type
            
        CASE TXN.ID[1,5] EQ "DXTRA"
            SUB.ASSET.TYPE   = TXN.REC<DX.Trade.Trade.TraSubAssetType>
            GOSUB GET.ASSET.TYPE.DESC ; *Get the description of Asset Type
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GET.ASSET.TYPE.DESC>
GET.ASSET.TYPE.DESC:
*** <desc>Get the description of Asset Type </desc>

* Read the Sub Asset Type record to get the Asset Type
    R.SUB.ASSET.TYPE = '' ; SAT.ERR = ''
    R.SUB.ASSET.TYPE = ST.Valuation.SubAssetType.Read(SUB.ASSET.TYPE, SAT.ERR)
    ASSET.TYPE       = R.SUB.ASSET.TYPE<ST.Valuation.SubAssetType.CsgAssetTypeCode>

* Read the ASSET.TYPE record to get the Description of Asset Type
    R.ASSET.TYPE = '' ; AT.ERR = ''
    R.ASSET.TYPE     = ST.Valuation.AssetType.Read(ASSET.TYPE,AT.ERR)
    RET.VAL          = R.ASSET.TYPE<ST.Valuation.AssetType.AssAssetDesc>

RETURN
*** </region>

END
