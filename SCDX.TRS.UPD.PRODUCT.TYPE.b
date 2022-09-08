* @ValidationCode : MjotMTg2MDExMjI4NjpDcDEyNTI6MTYwNDgzNzUwMTc5MDpyZGVlcGlnYToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA5LjIwMjAwODI4LTE2MTc6MjA6MjA=
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 20/20 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.PRODUCT.TYPE(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine fetches the description of Sub Asset Type involved in Transaction
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
* RET.VAL  -  Description of Sub Asset Type
*
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
    
    END CASE

    GOSUB GET.SUB.ASSET.TYPE      ; *Get the Sub Asset Type defined in the Security Master
    GOSUB GET.SUB.ASSET.TYPE.DESC ; *Get the description of Asset Type
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.SUB.ASSET.TYPE>
GET.SUB.ASSET.TYPE:
*** <desc>Get the Sub Asset Type defined in the Security Master </desc>
    
    R.SEC.MASTER = '' ; SM.ERR = ''
    R.SEC.MASTER     = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(SECURITY.CODE, SM.ERR)
    SUB.ASSET.TYPE   = R.SEC.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmSubAssetType>

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.SUB.ASSET.TYPE.DESC>
GET.SUB.ASSET.TYPE.DESC:
*** <desc>Get the description of Asset Type </desc>

* Read the Sub Asset Type record to get the Description of Sub Asset Type
    R.SUB.ASSET.TYPE = '' ; SAT.ERR = ''
    R.SUB.ASSET.TYPE = ST.Valuation.SubAssetType.Read(SUB.ASSET.TYPE, SAT.ERR)
    RET.VAL          = R.SUB.ASSET.TYPE<ST.Valuation.SubAssetType.CsgDescription>

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
