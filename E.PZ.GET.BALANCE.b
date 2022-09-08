* @ValidationCode : MjoxMDUyNDQ2MTc3OkNwMTI1MjoxNTAwMDA5NjY4Njk0Om1hbmp1OjU6MDotNTQ6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDYuMDo2Mzo2Mw==
* @ValidationInfo : Timestamp         : 14 Jul 2017 10:51:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : manju
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : -54
* @ValidationInfo : Coverage          : 63/63 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201706.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
    $PACKAGE PZ.ModelBank
    SUBROUTINE E.PZ.GET.BALANCE(ACC.DATA)
*-----------------------------------------------------------------------------
* New NOFILE enquiry routine to return values for account get balance enquiry.
*
*Param:
*ACC.DATA   -   in/out param for enquiry
*-----------------------------------------------------------------------------
* Modification History :
* 27/06/17 - Enhancement - 2145956/Task - 2175060
*            Arrangement Balance - PSD2
*			 New NOFILE enquiry routine to return values for AA account get balance enquiry.
*-----------------------------------------------------------------------------
*  <region name= Inserts>
    $USING AA.Framework
    $USING AC.AccountOpening
    $USING EB.API
    $USING EB.Reports
    $USING EB.SystemTables
* </region>
*-----------------------------------------------------------------------------
*** <region name= Main process>
*** <desc>Program control</desc>
*
    GOSUB Initialise                                ;* Initialise the variables
    IF AcisInstalled THEN
        GOSUB BuildAccData                          ;* Build the account related details
    END ELSE
        EnqError = "PZ-PRODUCT.AC.NOT.INSTALLED"
        EB.SystemTables.setEtext('')
        EB.Reports.setEnqError(EnqError)            ;* If AC product not installed set error
    END
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
Initialise:
*** Initialise the enquiry data variables
    AccountId = ''
    AcCcy = ''
    LedgBal = ''
    AvailBal = ''
    Status = ''
    ArrId = ''
    ArrPrd = ''
*** Initialise the AC.CHECK.ACCOUNT in parameters
    AcRec = ''
    CheckData = ''
    CheckData<AC.AccountOpening.AccountValidity> = 'Y'
    CheckData<AC.AccountOpening.AccountBalance> = 'Y'
    CheckData<AC.AccountOpening.AccountIban> = 'Y'
    CheckData<AC.AccountOpening.AccountArrangement> = 'Y'
    CheckData<AC.AccountOpening.AccountType> = 'Y'
    CheckData<AC.AccountOpening.HisAccount> = 'Y'
    CallMode = 'ONLINE'
    OverrideCode = ''
    ErrorCode = ''
    AcEntryRec = ''
    CheckDataResult = ''
*** Initialise variables for IBAN
    iBan = ''
*** Initialise variables for Balance check
    AvailBalance = ''
    LockedAmt = ''
    LimitAmt = ''
*** Get the Account ID
    LOCATE 'ACCOUNTREFERENCE' IN EB.Reports.getDFields()<1> SETTING AcPos THEN    ;* locate ACCOUNTREFERENCE in enquiry data and get position
    AccountId = EB.Reports.getDRangeAndValue()<AcPos>                           ;* Get the account id using the position
    END ELSE
    EnqError = "PZ-ACCOUNT.REF.NOT.PROVIDED"
    EB.Reports.setEnqError(EnqError)                                            ;* If not located then no account id passed set error
    END
*AccountId = ACC.DATA
*** Product installaion check
    EB.API.ProductIsInCompany('AC', AcisInstalled)
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BuildEnqData>
*** <desc>Build the data for enquiry output</desc>
BuildEnqData:
***
    ACC.DATA = AccountId:'*':iBan:'*':AcCcy:'*':AvailBal    ;* Form the enquiry output
***
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BuildAccData>
BuildAccData:
*** <desc> Build the account related data such as i) get IBAN , ii) get Currency, iii) get Balances. For the account provided in the enquiry.</desc>

    IF EnqError THEN        ;* If no account id passed then no need to proceed
        RETURN
    END
*** get Account record/Arrangement Id & determine STATUS
    AC.AccountOpening.CheckAccount(AccountId, AcRec, CheckData, CallMode, AcEntryRec, CheckDataResult, OverrideCode, ErrorCode)       ;* Validate the account
***
    Status = CheckDataResult<AC.AccountOpening.AccountValidity,1>
    AvailBal = CheckDataResult<AC.AccountOpening.AccountBalance,5>
    iBan = CheckDataResult<AC.AccountOpening.AccountIban,1>
    ArrId = CheckDataResult<AC.AccountOpening.AccountArrangement,1>
    ArrPrd = CheckDataResult<AC.AccountOpening.AccountType,2>
*** Incoming IBAN/Account ID needs to be validated in T24 to be an AC or AR Module based account.
*** In cases where an AA loan or AA deposit related account number is passed API will need to return an error as "Invalid Account Type".
    IF Status = 'INVALID' OR (ArrId AND ArrPrd NE 'ACCOUNTS') THEN
        EnqError = 'AC-INVALID.AC.NO'
        EB.SystemTables.setEtext('')
        EB.Reports.setEnqError(EnqError)
        RETURN
    END
*** get CCY
    IF AcRec THEN
        AcCcy = AcRec<AC.AccountOpening.Account.Currency>
    END
    GOSUB BuildEnqData              ;* Build enquiry data
    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END

