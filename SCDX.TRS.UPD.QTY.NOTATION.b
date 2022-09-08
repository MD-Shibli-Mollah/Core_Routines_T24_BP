* @ValidationCode : Mjo2ODQ5NjI2NjA6Q3AxMjUyOjE2MDQ4Mzc1MDA2Mzg6cmRlZXBpZ2E6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOS4yMDIwMDgyOC0xNjE3OjIxOjIx
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:40
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 21/21 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.QTY.NOTATION(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine returns the Quantity Notation from the transaction to
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
* RET.VAL  -  Quantity Notation from the transaction
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
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to return the quantity notation from the transaction
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
*** <desc>Process to return the quantity notation from the Transaction for reporting purpose </desc>

    BEGIN CASE
        CASE TXN.ID[1,6] EQ "SCTRSC"
            SEC.CODE = TXN.REC<SC.SctTrading.SecTrade.SbsSecurityCode>
            SM.ERR = ''
            R.SECURITY.MASTER = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(SEC.CODE, SM.ERR)
            IF R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmBondOrShare> EQ 'S' THEN
                RET.VAL = '1'
            END ELSE
                RET.VAL = '2'
            END
        
        CASE TXN.ID[1,5] EQ 'DXTRA'
            IF TXN.REC<DX.Trade.Trade.TraPriLots> THEN
                RET.VAL = '1'
            END
    END CASE
    

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
