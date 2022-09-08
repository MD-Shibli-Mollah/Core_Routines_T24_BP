* @ValidationCode : MjoxOTU3NzQ5Nzg1OkNwMTI1MjoxNTAwMDA5NjY4NzgyOm1hbmp1OjY6MDotNTg6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDYuMDo3Mjo3MQ==
* @ValidationInfo : Timestamp         : 14 Jul 2017 10:51:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : manju
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : -58
* @ValidationInfo : Coverage          : 71/72 (98.6%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201706.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
    $PACKAGE PZ.ModelBank
    SUBROUTINE E.PZ.ACCOUNT.OVERVIEW(ACC.DATA)
*-----------------------------------------------------------------------------
*New NOFILE enquiry routine to return values for account overview enquiry.
*
*In/OutParam:
*=========
*ACC.DATA         -   Input/Output for the enquiry
*
*-----------------------------------------------------------------------------
* Modification History :
* 22/06/2017 - Enhancement  2098798/ Task 2171175
*              Access to Accounts API Enhancement - Account overview API - PSD2
*              Introduce new enquiry API.
*-----------------------------------------------------------------------------
*  <region name= Inserts>
    $USING AA.Framework
    $USING AC.AccountOpening
    $USING AC.ModelBank
    $USING EB.API
    $USING EB.Reports
    $USING EB.SystemTables
    $USING IN.Config
    $USING IN.IbanAPI
* </region>
*-----------------------------------------------------------------------------
*** <region name= Main process>
*** <desc>Program control</desc>
*
    GOSUB Initialise                                ;* Initialise the variables
    IF AcisInstalled THEN
        GOSUB BuildAccData                          ;* Build the account related details
    END ELSE
        EB.SystemTables.setEtext('')
        EnqError = "PZ-PRODUCT.AC.NOT.INSTALLED"    ;* EB.ERROR record
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
    AcDes = ''
    AcType =''
    AcCcy = ''
    LedgBal = ''
    AvailBal = ''
    Status = ''
*** Initialise the AC.CHECK.ACCOUNT in parameters
    AcRec = ''
    CheckData = ''
    CheckData<AC.AccountOpening.AccountValidity> = 'Y'
    CheckData<AC.AccountOpening.AccountBalance> = 'Y'
    CheckData<AC.AccountOpening.HisAccount> = 'Y'
    CheckData<AC.AccountOpening.AccountIban> = 'Y'
    CheckData<AC.AccountOpening.AccountBic> = 'Y'
    CheckData<AC.AccountOpening.AccountArrangement> = 'Y'
    CheckData<AC.AccountOpening.AccountType> = 'Y' 
    CallMode = 'ONLINE'
    OverrideCode = ''
    ErrorCode = ''
    AcEntryRec = ''
    CheckDataResult = ''
*** Initialise variables for IBAN & BIC
    iBan = ''
    Bic =''
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

*** Product installaion check
    EB.API.ProductIsInCompany('AC', AcisInstalled)

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BuildEnqData>
*** <desc>Build the data for enquiry output</desc>
BuildEnqData:
***
    ACC.DATA = AccountId:'*':iBan:'*':Bic:'*':AcDes:'*':AcType:'*':AcCcy:'*':LedgBal:'*':AvailBal:'*':Status    ;* Form the enquiry output
***
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BuildAccData>
BuildAccData:
*** <desc> Build the account related data such as i) get Account record/Arrangement Id ii) determine STATUS , iii) get IBAN , iv) get BIC ,
***         v) get Currency&Description, vi) get Balances and vi) get Type. For the account provided in the enquiry.</desc>

    IF EnqError THEN        ;* If no account id passed then no need to proceed
        RETURN
    END
*** get Account record/Arrangement Id & determine STATUS
    AC.AccountOpening.CheckAccount(AccountId, AcRec, CheckData, CallMode, AcEntryRec, CheckDataResult, OverrideCode, ErrorCode)       ;* Validate the account
***
    Status = CheckDataResult<AC.AccountOpening.AccountValidity,1>
    LedgBal = CheckDataResult<AC.AccountOpening.AccountBalance,1>
    AvailBal = CheckDataResult<AC.AccountOpening.AccountBalance,5>
    iBan = CheckDataResult<AC.AccountOpening.AccountIban,1>
    Bic = CheckDataResult<AC.AccountOpening.AccountBic,1>
    ArrId = CheckDataResult<AC.AccountOpening.AccountArrangement,1>
    AcType = CheckDataResult<AC.AccountOpening.AccountType,1>
***
    IF Status = 'INVALID' THEN
        EnqError = 'AC-INVALID.AC.NO'
        EB.SystemTables.setEtext('')
        EB.Reports.setEnqError(EnqError)
        RETURN
    END
***
*** get Currency,Description
*** Get account currency from live account record/history record Currency field. Get LANG from Lngg of EB.SystemTables &
*** Get account description from live account record/history record ShortTitle of position LANG and if not present get ShortTitle in position 1.
    Lang = EB.SystemTables.getLngg()
    IF AcRec THEN
        AcCcy = AcRec<AC.AccountOpening.Account.Currency>
        AcDes = AcRec<AC.AccountOpening.Account.ShortTitle,Lang>
        IF NOT(AcDes) THEN
            AcDes = AcRec<AC.AccountOpening.Account.ShortTitle,1>
        END
    END
***
    GOSUB BuildEnqData              ;* Build enquiry data
    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END

