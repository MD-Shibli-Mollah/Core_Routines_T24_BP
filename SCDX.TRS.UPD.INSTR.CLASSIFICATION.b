* @ValidationCode : MjotNjE3MzgwMTg0OkNwMTI1MjoxNjA0ODM3NTAzNjQ4OnJkZWVwaWdhOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMjAyMDA4MjgtMTYxNzoyMjoyMg==
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 22/22 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.INSTR.CLASSIFICATION(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine return Instrument Classification for updation in SCDX.ARM.MIFID.DATA
* for reporting purpose
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
* RET.VAL  -  Instrument Classification
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

    $USING DX.Trade
    $USING SC.SctTrading
    $USING SC.ScoSecurityMasterMaintenance
    $USING DX.Configuration
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to return Instrument Classification
           
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
*** <desc>Process to return Instrument Classification for reporting purpose </desc>

    BEGIN CASE
        CASE TXN.ID[1,6] EQ "SCTRSC"
            SEC.CODE = TXN.REC<SC.SctTrading.SecTrade.SbsSecurityCode>
            SM.ERR = ''
            R.SECURITY.MASTER = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(SEC.CODE, SM.ERR)
            LOCATE 'CFI.CODE' IN R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmInstrumentType,1> SETTING POS THEN
                RET.VAL = R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmInstClassification,POS>
            END
        
        CASE TXN.ID[1,5] EQ 'DXTRA'
            CONTRACT.CODE = TXN.REC<DX.Trade.Trade.TraContractCode>
            DCM.ERR = ''
            R.DX.CONTRACT.MASTER = DX.Configuration.ContractMaster.Read(CONTRACT.CODE, DCM.ERR)
            LOCATE 'CFI.CODE' IN R.DX.CONTRACT.MASTER<DX.Configuration.ContractMaster.CmInstrumentType,1> SETTING POS THEN
                RET.VAL = R.DX.CONTRACT.MASTER<DX.Configuration.ContractMaster.CmInstClassification,POS>
            END
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
