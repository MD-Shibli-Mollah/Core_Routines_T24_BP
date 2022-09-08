* @ValidationCode : MjotMTY2OTg2NTMwODpDcDEyNTI6MTYwODIxNjA2MzY4OTpzY2hhbmRpbmk6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMi4xOjU5OjQy
* @ValidationInfo : Timestamp         : 17 Dec 2020 20:11:03
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : schandini
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 42/59 (71.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AC.Channels
SUBROUTINE V.TC.UPDATE.STO.BEN.DETAILS
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* To get the details of beneficiary using Beneficiary Id and default the same in Standing order
*
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Validation
* Attached To        : Version > STANDING.ORDER,TC as a Validation routine for BENEFICIARY.ID
* IN Parameters      : NA
* Out Parameters     : NA
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 27/05/2016  - Enhancement 1694534 / Task 1741987
*               TCIB Componentization- Advanced Common Functional Components - Transfers/Payment/STO/Beneficiary/DD
*
* 08/12/2020 - Enhancement 4020994 / Task 4037076
*              Changing BY.Payments reference to new component reference BY.Payments since
*              beneficiary and beneficiary links table has been moved to new module BY.
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts
    $USING AC.AccountOpening
    $USING AC.StandingOrders
    $USING EB.SystemTables
    $USING BY.Payments

*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise variables used in this routine</desc>
INITIALISE:
*---------
    BENEFICIARY.ID = ''; R.BENEFICIARY = ''; LINK.BENEFICIARY = ''; R.LINK.BENEFICIARY = ''   ;*Initialising Beneficiary variables
    TRANSACTION.TYPE= ''; CREDIT.ACCOUNT.NO = ''; CUSTOMER.ID = ''; C.PARTY.ACCT = ''; TXNPOS = ''; POS=''; R.NOSTRO = ''  ;*Initialising variables
    STO.APP='FT'; STO.OTHER="ALL"    ;*Initialising Application for Nostro table

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>Get beneficiary details for process</desc>
PROCESS:
*------

    BENEFICIARY.ID = EB.SystemTables.getComi()  ;*Get Beneficiary Id

    R.BENEFICIARY = BY.Payments.Beneficiary.Read(BENEFICIARY.ID,READ.ERR)   ;*Read beneficiary Id
    IF NOT(READ.ERR) THEN
        TRANSACTION.TYPE = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenTransactionType>                   ;*Get transaction type
        EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoPayMethod, TRANSACTION.TYPE)       ;*Set transaction type
        LINK.BENEFICIARY = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenLinkToBeneficiary>                     ;*Get Linked beneficiary Id
        IF LINK.BENEFICIARY NE '' THEN
            R.LINK.BENEFICIARY = BY.Payments.Beneficiary.Read(LINK.BENEFICIARY,READ.ERR)                          ;*Read beneficiary
            TRANSACTION.TYPE = R.LINK.BENEFICIARY<BY.Payments.Beneficiary.ArcBenTransactionType>                  ;*Get transaction type
            CREDIT.ACCOUNT.NO = R.LINK.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBenAcctNo>                    ;*Get beneficiary account no
            EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoPayMethod, TRANSACTION.TYPE)           ;*Set transaction type
            EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoCptyAcctNo, CREDIT.ACCOUNT.NO)      ;*Set counter party account no
        END

        BEGIN CASE
            CASE TRANSACTION.TYPE[1,2] EQ 'OT'  ;*Case for outward transaction types
                CCY.STO=EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoCurrency)                ;*Get currency
                EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoBeneficiary, R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBenCustomer>)   ;*Set Beneficiary customer
                EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoBenAcctNo, R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBenAcctNo>)   ;*Set Beneficiary account no
                EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoBenReference, R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenCustomerRef>)  ;*Set Beneficiary reference
                GOSUB UPDATE.STO.CPARTY         ;*To update counter party account number
            CASE TRANSACTION.TYPE[1,2] EQ 'BC'  ;*Case for domestice transaction types
                EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoPayMethod, R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenTransactionType>) ;*Set Transaction type
                EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoBankSortCode, R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBankSortCode>) ;*Set Bank sort code
                EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoBenAcctNo, R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBenAcctNo>)   ;*Set Beneficiary account no
                EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoBeneficiary, R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBenCustomer>)   ;*Set Beneficiary customer
                EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoBenReference, R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenCustomerRef>)  ;*Set Beneficiary reference
        END CASE

    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= UPDATE.STO.CPARTY>
*** <desc> check application is available in Nostro account</desc>
UPDATE.STO.CPARTY:
*------------------
    R.NOSTRO = AC.AccountOpening.NostroAccount.Read(CCY.STO,NOSTRO.ERR) ;*Read nostro account

    IF R.NOSTRO THEN
        LOCATE STO.APP IN R.NOSTRO<AC.AccountOpening.NostroAccount.EbNosApplication,1> SETTING POS THEN  ;*Case for FT type
            GOSUB CHECK.CURR.STO.TXN.TYPE  ;*Check for current transaction type
        END ELSE
            LOCATE STO.OTHER IN R.NOSTRO<AC.AccountOpening.NostroAccount.EbNosApplication,1> SETTING POS THEN    ;*Case for all other types
                GOSUB CHECK.CURR.STO.TXN.TYPE  ;*Check for current transaction type
            END
        END
    END

RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CHECK.CURR.STO.TXN.TYPE>
*** <desc> check current transaction type is available in Nostro account </desc>
CHECK.CURR.STO.TXN.TYPE:
*-----------------------
   
    LOCATE TRANSACTION.TYPE IN R.NOSTRO<AC.AccountOpening.NostroAccount.EbNosApplication,POS> SETTING TXNPOS THEN
        C.PARTY.ACCT=R.NOSTRO<AC.AccountOpening.NostroAccount.EbNosAccount,POS,TXNPOS>   ;*Get the Nostro account available belongs to this transaction type
        GOSUB SET.STO.CPARTY ;*To set the counter party account in standing order
    END ELSE
        C.PARTY.ACCT=R.NOSTRO<AC.AccountOpening.NostroAccount.EbNosAccount,POS,1>
        GOSUB SET.STO.CPARTY ;*To set the counter party account in standing order
    END

RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SET.STO.CPARTY>
*** <desc> Update Counter Party Account Number for Outward types in Standing order</desc>
SET.STO.CPARTY:
*---------------

    IF C.PARTY.ACCT THEN
        EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoCptyAcctNo, C.PARTY.ACCT)     ;*Set counter party account no
    END

RETURN

*
*** </region>
*---------------------------------------------------------

END
