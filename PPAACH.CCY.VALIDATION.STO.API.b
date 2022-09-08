* @ValidationCode : MjoxOTM1MTg5NDA0OkNwMTI1MjoxNTYzNzA1NDA4ODUxOnNrYXlhbHZpemhpOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDcuMjAxOTA2MTItMDMyMTozMDoyMw==
* @ValidationInfo : Timestamp         : 21 Jul 2019 16:06:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : skayalvizhi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 23/30 (76.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190612-0321
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPAACH.ClearingFramework
SUBROUTINE PPAACH.CCY.VALIDATION.STO.API
*-----------------------------------------------------------------------------
* This validation API is to check currency validation for STO payment. And is attached in the STO version
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING AC.StandingOrders
    $USING EB.ErrorProcessing
    $USING AC.AccountOpening
    GOSUB INITIALISE
    GOSUB VALIDATE
    
RETURN
****************************************************************
*** <region name= INITIALISE>
INITIALISE:
    paymentCurrency = ''
    debitCurrency = ''
    paymentCurrency = EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoCurrency)
    idValue = EB.SystemTables.getIdNew()
    account = FIELD(idValue,".",1)
    R.ACCOUNT = ''
    ETEXT.VAL = ''
*** <desc> </desc>
RETURN
*** </region>


****************************************************************
****************************************************************
*** <region name= VALIDATE>
VALIDATE:
*** <desc> </desc>
    R.ACCOUNT = AC.AccountOpening.Account.Read(account, ETEXT.VAL)
    IF R.ACCOUNT THEN
        debitCurrency =  R.ACCOUNT<AC.AccountOpening.Account.Currency>
    END
* Check for allowed payment currency
    IF ((paymentCurrency NE '') AND (paymentCurrency NE 'ARS' AND paymentCurrency NE 'USD' AND paymentCurrency NE 'EUR')) THEN
        EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoCurrency)
        EB.SystemTables.setEtext("Payment Currency is not allowed for the Payment Order product")
        EB.ErrorProcessing.StoreEndError()
    END
    
* check if debit currency and payment currency are same
    IF ((debitCurrency NE '') AND (debitCurrency NE 'ARS' AND debitCurrency NE 'USD' AND debitCurrency NE 'EUR')) THEN
        EB.SystemTables.setAf("")
        EB.SystemTables.setEtext("Debit Currency is not allowed for the Payment Order product")
        EB.ErrorProcessing.StoreEndError()
    END ELSE IF (debitCurrency NE '' AND paymentCurrency NE '') AND (debitCurrency NE paymentCurrency)  THEN
        EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoCurrency)
        EB.SystemTables.setEtext("Debit Currency and Payment currency is not same")
        EB.ErrorProcessing.StoreEndError()
    END
    
RETURN
*** </region>


****************************************************************
END
