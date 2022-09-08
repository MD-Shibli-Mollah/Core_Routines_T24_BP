* @ValidationCode : MjotMjA2ODAyMTUwOTpDcDEyNTI6MTUyMjkzMTAzMzQzODpzYW50b3NocHJhc2FkOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDIuMjAxNzAxMjgtMDEzOTo0MzozNQ==
* @ValidationInfo : Timestamp         : 05 Apr 2018 17:53:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : santoshprasad
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 35/43 (81.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.20170128-0139
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE AC.Channels
    SUBROUTINE V.TC.UPDATE.NOSTRO.ACCOUNT
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* To set the counter party account number for new international beneficiary payment in Standing order.
*
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Validation
* Attached To        : Version > STANDING.ORDER,TC as a Validation routine for CURRENCY
* IN Parameters      : NA
* Out Parameters     : NA
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 27/05/2016  - Enhancement 1694534 / Task 1741987
*               TCIB Componentization- Advanced Common Functional Components - Transfers/Payment/STO/Beneficiary/DD
*
* 23/01/2017  - Defect 1959770 / Task 1959780
*               STO not created when provided with comments
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts

    $USING AC.AccountOpening
    $USING AC.StandingOrders
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise variables used in this routine</desc>
INITIALISE:
*---------
    TRANSACTION.TYPE = ''; BIC.CODE = ''; STO.CURRENCY = ''; R.NOSTRO = ''; C.PARTY.ACCT = '' ;*Initialising variables
    STO.APP='FT'; STO.OTHER="ALL"    ;*Initialising Application for Nostro table

    RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>Get currency details for process</desc>
PROCESS:
*-------
    BIC.CODE = EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoAcctWithBank) ;*Get Bic code
    TRANSACTION.TYPE = EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoPayMethod)    ;*Get Transaction type
    STO.CURRENCY = EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoCurrency) ;*Get Standing order currency
*
    IF STO.CURRENCY EQ '' THEN
        STO.CURRENCY = EB.SystemTables.getComi()    ;*Get currency from COMMON variable.
    END

    GOSUB UPDATE.STO.CPARTY ;*Set counter part account no

    RETURN
*** </region>
*------------------------------------------------------------------------------------------------
*** <region name= UPDATE.STO.CPARTY>
*** <desc> check application is available in Nostro account</desc
*------------------------------------------------------------------------------
UPDATE.STO.CPARTY:
*-----------------
*
    IF (TRANSACTION.TYPE[1,2] EQ 'OT') OR (TRANSACTION.TYPE[1,2] EQ 'BC') THEN
        READ.NOSTRO = AC.AccountOpening.NostroAccount.Read(STO.CURRENCY,NOSTRO.ERR)
        IF READ.NOSTRO THEN
            GOSUB GET.NOSTRO.ACCT
        END
    END

    RETURN
*
*-----------------------------------------------------------------------------
*** <region name= GET.NOSTRO.ACCT>
*** <desc> Get nostro account based on transaction type</desc>
GET.NOSTRO.ACCT:
*--------------
*
    LOCATE STO.APP IN READ.NOSTRO<AC.AccountOpening.NostroAccount.EbNosApplication,1> SETTING POS THEN
    NOSTRO.TXN.TYPE=READ.NOSTRO<AC.AccountOpening.NostroAccount.EbNosTxnType,POS>           ;*Reading type of STO
    IF NOSTRO.TXN.TYPE NE '' THEN
        LOCATE TRANSACTION.TYPE IN NOSTRO.TXN.TYPE<1,1,1> SETTING TYPEPOS THEN
        C.PARTY.ACC=READ.NOSTRO<AC.AccountOpening.NostroAccount.EbNosAccount,POS,TYPEPOS>
    END
    END ELSE
    C.PARTY.ACC=READ.NOSTRO<AC.AccountOpening.NostroAccount.EbNosAccount,POS,1>
    END
    END

    IF C.PARTY.ACC EQ '' THEN
        POS=''
        LOCATE STO.OTHER IN READ.NOSTRO<AC.AccountOpening.NostroAccount.EbNosApplication,1> SETTING POS THEN
        C.PARTY.ACC=READ.NOSTRO<AC.AccountOpening.NostroAccount.EbNosAccount,POS,1>
    END
    END

    GOSUB SET.STO.CPTY.ACCT         ;*Set counter party account 

    RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= READ.STO.TXN.COND>
*** <desc> Update cparty account for OT</desc>
SET.STO.CPTY.ACCT:
*-----------------

    IF C.PARTY.ACC THEN
        EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoCptyAcctNo, C.PARTY.ACC)     ;*Set counter party account
    END
    RETURN

*
*** </region>
*---------------------------------------------------------
    END
