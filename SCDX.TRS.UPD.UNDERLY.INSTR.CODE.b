* @ValidationCode : Mjo2MTA1NDIzNzpDcDEyNTI6MTYwNDgzNzUwMzk0MzpyZGVlcGlnYToyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA5LjIwMjAwODI4LTE2MTc6MzY6MzY=
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 36/36 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.UNDERLY.INSTR.CODE(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine return underlying Instrument Code for updation in SCDX.ARM.MIFID.DATA
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
* RET.VAL  -  Underlying instrument code ie ISIN from Security Master
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
    GOSUB PROCESS       ; *Process to return underlying Instrument Code
           
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
*** <desc>Process to return underlying Instrument Code for reporting purpose </desc>

    BEGIN CASE
        CASE TXN.ID[1,6] EQ "SCTRSC"
            SEC.CODE = TXN.REC<SC.SctTrading.SecTrade.SbsSecurityCode>
            SM.ERR = ''
            R.SECURITY.MASTER = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(SEC.CODE, SM.ERR)
            UNDERLY.CNT = DCOUNT(R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmUnderlying>,@VM)
            FOR I = 1 TO UNDERLY.CNT
                UNDERLYING.SECURITY = R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmUnderlying,I>
                GOSUB READ.SECURITY.MASTER ; *Read the Security master record to retreive the ISIN
                IF ISIN THEN
                    RET.VAL<1,-1> = ISIN
                END
            NEXT I
        
        CASE TXN.ID[1,5] EQ 'DXTRA'
            CONTRACT.CODE = TXN.REC<DX.Trade.Trade.TraContractCode>
            DCM.ERR = ''
            R.DX.CONTRACT.MASTER = DX.Configuration.ContractMaster.Read(CONTRACT.CODE, DCM.ERR)
            UNDERLY.CNT = DCOUNT(R.DX.CONTRACT.MASTER<DX.Configuration.ContractMaster.CmUnderlying>,@VM)
            FOR I = 1 TO UNDERLY.CNT
                UNDERLYING.SECURITY = R.DX.CONTRACT.MASTER<DX.Configuration.ContractMaster.CmUnderlying,I>
                GOSUB READ.SECURITY.MASTER ; *Read the Security master record to retreive the ISIN
                IF ISIN THEN
                    RET.VAL<1,-1> = ISIN
                END
            NEXT I
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= READ.SECURITY.MASTER>
READ.SECURITY.MASTER:
*** <desc>Read the Security master record to retreive the ISIN </desc>

    SM.ERR = ''
    R.UNDERLYING.SECURITY = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(UNDERLYING.SECURITY, SM.ERR)
    ISIN = R.UNDERLYING.SECURITY<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmISIN>

RETURN
*** </region>

*-----------------------------------------------------------------------------

END
