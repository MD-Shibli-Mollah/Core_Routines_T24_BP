* @ValidationCode : MjotMTUyNTQxNzE2MDpDcDEyNTI6MTYwNDkwMzAxMTI4MTpyZGVlcGlnYToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA5LjIwMjAwODI4LTE2MTc6MjA6MjA=
* @ValidationInfo : Timestamp         : 09 Nov 2020 11:53:31
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
SUBROUTINE SCDX.TRS.UPD.UNDERLYING.INDEX(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine return underlying index name for updation in SCDX.ARM.MIFID.DATA
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
* RET.VAL  -  Underlying Index name if it is index option
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
    GOSUB PROCESS       ; *Process to return underlying index name
           
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
*** <desc>Process to return underlying index name for reporting purpose </desc>

    BEGIN CASE
        CASE TXN.ID[1,5] EQ 'DXTRA'
            CONTRACT.CODE = TXN.REC<DX.Trade.Trade.TraContractCode>
            DCM.ERR = ''
            R.DX.CONTRACT.MASTER = DX.Configuration.ContractMaster.Read(CONTRACT.CODE, DCM.ERR)
            UNDERLYING.SECURITY = R.DX.CONTRACT.MASTER<DX.Configuration.ContractMaster.CmUnderlying,1>
            IF UNDERLYING.SECURITY THEN
                SM.ERR = ''
                R.UNDERLYING.SECURITY = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(UNDERLYING.SECURITY, SM.ERR)
                IF SM.ERR THEN
                    RET.VAL = UNDERLYING.SECURITY
                END
            END
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
