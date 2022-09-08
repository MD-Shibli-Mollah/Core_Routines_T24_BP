* @ValidationCode : MjotOTY0Mzk4MDA1OkNwMTI1MjoxNTk5MjE1MjUzNzI4Om1qZWJhcmFqOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjctMDQzNTozNjozMg==
* @ValidationInfo : Timestamp         : 04 Sep 2020 15:57:33
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mjebaraj
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 32/36 (88.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-52</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.Account
SUBROUTINE E.AA.CHK.ACCT.CLASS
*-----------------------------------------------------------------------------
*** <region name= PROGRAM DESCRIPTION>
***
*
** Conversion routine that returns 'Y' in O.DATA if the category of
** input ACCOUNT.ID is available in the category list of SAVINGS ACCOUNT.CLASS
*
*** </region>

*** <region name= MODIFICATION HISTORY>
***
* Modification History :
*
* 21/08/20 - Enhancement : 3930273
*            Task        : 3935637
*            Microservices - Skip the read to account record if the contract is from it and get category from account property record
*
*** </region>
*-----------------------------------------------------------------------------

    $USING EB.DataAccess
    $USING AC.AccountOpening
    $USING AC.Config
    $USING EB.Reports
    $USING AA.Framework

*-----------------------------------------------------------------------------

    GOSUB INITIALISE          ;*
    GOSUB PROCESS   ;*
RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> To initialise variables </desc>
    
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    FN.ACCOUNT.CLASS = 'F.ACCOUNT.CLASS'
    F.ACCOUNT.CLASS = ''

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= CHECK.CATEGORY>
PROCESS:

    GOSUB GET.ACCOUNT.CATEGORY
    GOSUB CHECK.CLASS.CATEGORY

RETURN
*** </region>

*** <region name= GET.ACCOUNT.CATEGORY>
GET.ACCOUNT.CATEGORY:
*** <desc> Get the account category </desc>
    ACCOUNT.ID = EB.Reports.getOData()
    EB.Reports.setOData("")
    R.ACCOUNT = ""
    R.AA.ACCOUNT = ""
    ACCOUNT.CATEGORY = ""
    
*** In Microservices, account data will be referred from external system and arrangement id is used as primary key to refer anything for a contract.
*** So stop reading account record in case of MS system and get category from arrangement account conditions record.
    IF ACCOUNT.ID[1,2] NE "AA" THEN
        EB.DataAccess.FRead(FN.ACCOUNT,ACCOUNT.ID, R.ACCOUNT, F.ACCOUNT, ERR.MSG)
        IF R.ACCOUNT THEN
            ACCOUNT.CATEGORY=R.ACCOUNT<AC.AccountOpening.Account.Category>
        END
    END ELSE
        AA.Framework.GetArrangementConditions(ACCOUNT.ID, "ACCOUNT", "", "", "", R.AA.ACCOUNT, ERR.MSG)     ;* Get arrangement account condition record
        R.AA.ACCOUNT = RAISE(R.AA.ACCOUNT)
        ACCOUNT.CATEGORY = R.AA.ACCOUNT<AA.Account.Account.AcCategory>    ;* Get category from account condition record for MS system
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= CHECK.CLASS.CATEGORY>
CHECK.CLASS.CATEGORY:
*** <desc> Check account class category </desc>

    ACCOUNT.CLASS.ID="SAVINGS"
    EB.DataAccess.FRead(FN.ACCOUNT.CLASS, ACCOUNT.CLASS.ID, R.ACCOUNT.CLASS, F.ACCOUNT.CLASS, ERR.MSG)
    IF R.ACCOUNT.CLASS THEN
        CATEGORY.LIST=R.ACCOUNT.CLASS<AC.Config.AccountClass.ClsCategory>
        LOCATE ACCOUNT.CATEGORY IN CATEGORY.LIST<1,1> SETTING POS THEN
            EB.Reports.setOData("Y")
        END
    END

RETURN
*** </region>

END
