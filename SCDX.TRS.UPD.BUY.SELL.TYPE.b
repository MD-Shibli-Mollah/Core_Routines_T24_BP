* @ValidationCode : MjoxNjkzNTM5Nzc3OkNwMTI1MjoxNjA0ODM3NTAwMzY1OnJkZWVwaWdhOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMjAyMDA4MjgtMTYxNzoyNDoyNA==
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:40
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 24/24 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.BUY.SELL.TYPE(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine determines the customer side ie either Buyer or Seller for updation
* in SCDX.ARM.MIFID.DATA for reporting purpose
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
* RET.VAL  -  If Customer is Buyer, then RET.VAL will be B
*             If Customer is Seller, then RET.VAL will be S
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
    $USING SC.Config
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to determine the customer side ie Buyer or Seller
           
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
*** <desc>Process to determine the customer side ie Buyer or Seller for reporting purpose </desc>

    BEGIN CASE
        CASE TXN.ID[1,6] EQ "SCTRSC"
            TRANS.CODE = TXN.REC<SC.SctTrading.SecTrade.SbsCustTransCode,1>
            CRED.DEB = '' ; ERR = ''
            SC.Config.GetTransType(TRANS.CODE, CRED.DEB, ERR)
            IF CRED.DEB EQ 'CREDIT' THEN
                RET.VAL = "B"
            END ELSE
                RET.VAL = "S"
            END
        
        CASE TXN.ID[1,5] EQ "DXTRA"
            PURCHASE.OR.SALE = TXN.REC<DX.Trade.Trade.TraPriBuySell>
            IF PURCHASE.OR.SALE EQ "BUY" THEN
                RET.VAL = "B"
            END ELSE
                RET.VAL = "S"
            END
                            
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
