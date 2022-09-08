* @ValidationCode : MjoxNzk0Nzk0MTUxOkNwMTI1MjoxNjA0ODM3NTAxODUzOnJkZWVwaWdhOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMjAyMDA4MjgtMTYxNzoyMzoyMw==
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 23/23 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.TRAD.CAPACITY(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine returns the Trading capacity based on the transaction to
* update it in SCDX.ARM.MIFID.DATA for reporting purpose
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
* RET.VAL  -  Trading capacity based on the transaction
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
    $USING SC.ScoPortfolioMaintenance
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to return the Trading capacity based on the transaction
*
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
*** <desc>Process to return the Trading capacity based on the Transaction for reporting purpose </desc>

    BEGIN CASE
        CASE TXN.ID[1,6] EQ "SCTRSC"
            SAM.ID  = TXN.REC<SC.SctTrading.SecTrade.SbsCustSecAcc,1>
            SAM.ERR = ''
            R.SAM = SC.ScoPortfolioMaintenance.SecAccMaster.Read(SAM.ID, SAM.ERR)
            IF R.SAM<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamDealerBook> THEN
                RET.VAL = 'DEAL'
            END ELSE
                RET.VAL = 'AOTC'
            END
        
        CASE TXN.ID[1,5] EQ 'DXTRA'
            IF TXN.REC<DX.Trade.Trade.TraTradingCapacity> THEN
                RET.VAL = TXN.REC<DX.Trade.Trade.TraTradingCapacity>
            END ELSE
                RET.VAL = 'AOTC'
            END       
    END CASE
    

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
