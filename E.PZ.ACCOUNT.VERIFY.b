* @ValidationCode : MjoxMDY0Mjg2MzMyOkNwMTI1MjoxNTAwNDY5Nzg5MDQ3OmJpa2FzaHJhbmphbjozOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcwNS4yMDE3MDUxNy0xMjI4OjYwOjUy
* @ValidationInfo : Timestamp         : 19 Jul 2017 18:39:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bikashranjan
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 52/60 (86.6%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201705.20170517-1228
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PZ.ModelBank
SUBROUTINE E.PZ.ACCOUNT.VERIFY(ACC.DATA)
*-----------------------------------------------------------------------------
*New NOFILE enquiry routine to return values for account verification enquiry.
*
*In/OutParam:
*=========
*ACC.DATA        -   Output for the enquiry
*
*-----------------------------------------------------------------------------
* Modification History :
* 28/06/2017 - Enhancement  2138371 / Task 2174029
*              Access to Accounts API Enhancement - Account verification API - PSD2
*              Introduce new enquiry API..
*-----------------------------------------------------------------------------
*  <region name= Inserts>
    $USING AC.AccountOpening
    $USING AC.ModelBank
    $USING EB.API
    $USING EB.Reports
    $USING EB.SystemTables
* </region>
*-----------------------------------------------------------------------------

    GOSUB INTIALISE ; *
    IF AcisInstalled THEN
        GOSUB BUILD.ACC.DATA                          ;* Build the account related details
    END ELSE
        EnqError = "PZ-PRODUCT.AC.NOT.INSTALLED"      ;* EB.ERROR record
        EB.SystemTables.setEtext('')
        EB.Reports.setEnqError(EnqError)            ;* If AC product not installed set error
    END

RETURN
*-----------------------------------------------------------------------------

*** <region name= INTIALISE>
INTIALISE:
*** <desc> </desc>
*** Initialise the enquiry data variables
    AccountId = ''
    iBan = ''
    Status = ''
*** Initialise the AC.CHECK.ACCOUNT in parameters
    AcRec = ''
    CheckData<AC.AccountOpening.AccountValidity> = 'Y'
    CheckData<AC.AccountOpening.AccountBalance>  = 'Y'
    CheckData<AC.AccountOpening.HisAccount>      = 'Y'
    CheckData<AC.AccountOpening.AccountIban>     = 'Y'
    CheckData<AC.AccountOpening.AccountBic>      = 'Y'
    CheckData<AC.AccountOpening.AccountArrangement> = 'Y'
    CheckData<AC.AccountOpening.AccountType>        = 'Y'
    CallMode = 'ONLINE'
    OverrideCode = ''
    ErrorCode = ''
    AcEntryRec = ''
    CheckDataResult = ''
    AcisInstalled=''

*** Get the Account ID
    LOCATE 'ACCOUNTREFERENCE' IN EB.Reports.getDFields()<1> SETTING AcPos THEN    ;* locate ACCOUNTREFERENCE in enquiry data and get position
        AccountId = EB.Reports.getDRangeAndValue()<AcPos>                          ;* Get the account id using the position
    END ELSE
        EnqError = "PZ-ACCOUNT.REF.NOT.PROVIDED"
        EB.Reports.setEnqError(EnqError)                                            ;* If not located then no account id passed set error
    END

*** Product installaion check
    EB.API.ProductIsInCompany('AC', AcisInstalled)

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= BUILD.ACC.DATA>
BUILD.ACC.DATA:
*** <desc> </desc>

    IF EnqError THEN        ;* If no account id passed then no need to proceed
        RETURN
    END
*** get Account record/Arrangement Id & determine STATUS
    AC.AccountOpening.CheckAccount(AccountId, AcRec, CheckData, CallMode, AcEntryRec,CheckDataResult, OverrideCode, ErrorCode)       ;* Validate the account
***

*** get status and iBan from checkAcount
    Status = CheckDataResult<AC.AccountOpening.AccountValidity,1>
    iBan   = CheckDataResult<AC.AccountOpening.AccountIban,1>

***
    IF Status = 'INVALID' THEN
        EnqError = 'AC-INVALID.AC.NO'
        EB.SystemTables.setEtext('')
        EB.Reports.setEnqError(EnqError)
        RETURN
    END
    
*** update AcVerified
    IF Status = 'ACTIVE' OR Status = 'INACTIVE' THEN                   ;* If the account status is in open then verified "YES"
        AcVerified = 'YES'
    END
    IF Status = 'CLOSED' THEN
        EnqError = 'AC-ACCOUNT.CLOSED.STATUS'                           ;* If account is closed no need to proceed further
        EB.SystemTables.setEtext('')
        EB.Reports.setEnqError(EnqError)                                ;* Set enquiry error and return
        RETURN
    END
    EB.SystemTables.setEtext('')
***
    GOSUB BUILD.ENQ.DATA ; *

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= BUILD.ENQ.DATA>
BUILD.ENQ.DATA:
*** <desc> </desc>

    ACC.DATA = AccountId:'*':iBan:'*':AcVerified    ;* Form the enquiry output
RETURN
*** </region>

*-----------------------------------------------------------------------------
END

