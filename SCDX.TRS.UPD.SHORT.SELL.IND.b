* @ValidationCode : MjotMTc0MzE3NTkzNzpDcDEyNTI6MTYwNDgzNzUwMDkxNjpyZGVlcGlnYTo0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA5LjIwMjAwODI4LTE2MTc6MjQ6MjQ=
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
SUBROUTINE SCDX.TRS.UPD.SHORT.SELL.IND(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine returns CUST.TRANS.CODE inputted for Sell Transactions only
* for updation in SCDX.ARM.MIFID.DATA for reporting purpose
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
* RET.VAL  -  Short Sell indicator based on Transaction code
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

    $USING SC.SctTrading
    
*** </region>
*-----------------------------------------------------------------------------
    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to fetch the Transaction code if sell Transaction alone
           
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
*** <desc>Process to fetch the Transaction code if sell Transaction alone for reporting purpose </desc>

    CUS.SIDE = ''
    SC.SctTrading.ScdxTrsUpdBuySellType(TXN.ID,TXN.REC,TXN.DATA,CUS.SIDE)
    BEGIN CASE
        CASE TXN.ID[1,6] EQ 'SCTRSC'
            IF CUS.SIDE EQ 'S' THEN
                TRANS.CODE = TXN.REC<SC.SctTrading.SecTrade.SbsCustTransCode,1>
            END
    END CASE

* Based on the Transaction code, return the value that need to be updated in the report
    BEGIN CASE
        CASE TRANS.CODE EQ 'SES'
            RET.VAL = 'SESH'        ;* Short sale with no exemption         
        CASE TRANS.CODE EQ 'SSE'
            RET.VAL = 'SSEX'        ;* Short sale with exemption
        CASE TRANS.CODE EQ 'SEL'
            RET.VAL = 'SELL'        ;* No short sale 
        CASE TRANS.CODE EQ 'UND'
            RET.VAL = 'UNDI'        ;* Information not available
    END CASE
    
*
RETURN
*** </region>
*-----------------------------------------------------------------------------

END
