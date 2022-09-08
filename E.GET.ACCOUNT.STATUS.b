* @ValidationCode : MjotMTI4ODk1MjYwOTpDcDEyNTI6MTYwODAzOTg0MTgwNjpWYW5rYXdhbGFIZWVyOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMjAyMDExMjgtMDYzMDoyODoyMg==
* @ValidationInfo : Timestamp         : 15 Dec 2020 19:14:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : VankawalaHeer
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 22/28 (78.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AC.ModelBank
SUBROUTINE E.GET.ACCOUNT.STATUS
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 14/12/2020 - Enahancement 4133912 / Task 4133924
*              New conversion routine to return the status of the Account
*              interms of Activity - Active,Inative or Closed.
*-----------------------------------------------------------------------------

    $USING AC.AccountOpening
    $USING AA.Services
    $USING EB.Reports
    $USING AC.AccountClosure

    GOSUB Initialise ;* Intialisation of local variables
    GOSUB Process ;*Processing logic

RETURN
*-----------------------------------------------------------------------------
*** <region name= Initialise>
Initialise:
*** <desc>Intialisation of local variables</desc>

    AccNum = ''
    AccRecord = ''
    ArrangementId = ''
    Status = ''

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Process>
Process:
*** <desc>Processing logic</desc>

    AccNum = EB.Reports.getOData() ;*Get the AccountNumber inputted
    AccRecord = AC.AccountOpening.Account.CacheRead(AccNum, Error) ;*Get the Account record for the inputted accountNo
    ArrangementId = AccRecord<AC.AccountOpening.Account.ArrangementId> ;*Get the ArrangementId from the account Record
  
    IF ArrangementId THEN ;*If arrangement Account then get the accountStatus from the getAccountStatus api
        AccountStatus = ''
        RetError = ''
        AA.Services.getAccountStatus(ArrangementId, AccountStatus, RetError)
        Status = AccountStatus
    END ELSE  ;*For non-arrangement account
        BEGIN CASE
            CASE AccRecord<AC.AccountOpening.Account.InactivMarker> NE '' ;*If InactiveMarker is defined then set the status as Inactive
                Status = 'Inactive'
            CASE AccRecord<AC.AccountOpening.Account.ClosedOnline> EQ 'Y' ;*If ClosedOnline field is marked as Y then set the status as Closed
                Status = 'Closed'
            CASE 1 ;*Default case for active account
                Status = 'Active'
        END CASE
    END

    EB.Reports.setOData(Status)

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
