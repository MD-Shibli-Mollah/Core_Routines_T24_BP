* @ValidationCode : MjoxMTIyMTQwMjExOmNwMTI1MjoxNDk1MTcxMjAzMTQ3OnNtYW5qdXByaXlhOjE6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzA0LjA6NTY6NDU=
* @ValidationInfo : Timestamp         : 19 May 2017 10:50:03
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : smanjupriya
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 45/56 (80.3%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201704.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*
*-----------------------------------------------------------------------------
* <Rating>-49</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank
SUBROUTINE E.MB.FETCH.AC.JOINT.HOLDERS
*-----------------------------------------------------------------------------
* Subroutine Type   : Subroutine-
* Attached to       : Enquiry ACCOUNT.STATEMENT
* Attached as       : Build Routine
* Primary Purpose   : To fetch joint account holders
*-----------------------------------------------------------------------------
* MODIFICATION HISTORY:
*
* 30-10-08 - BG_100019949
*          Mb Routine Standardisation
* 30/11/10 - Task - 84421
*            Replace the enterprise(customer service api)code into  Banking framework related
*            routines which reads CUSTOMER.
*
* 17/03/11 - Defect-170290 / Task-174161
*            Joint Holder's name not displayed for Closed Accounts. Hence code changed
*            to read History record to get the Joint Holders's name.
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 08/05/17 - Defect 2097292 / Task 2117339
*            For AA Accounts , Joint Holder field is blank under Statements record even if the account has more than one Owner.
*            Code introduced to fetch Joint Holders of AA Accounts.
*-----------------------------------------------------------------------------

    $INSERT I_CustomerService_NameAddress  ;* I_F.CUSTOMER replaced with customer service api
    $USING EB.SystemTables
    $USING EB.Reports
    $USING AC.AccountOpening
    $USING AA.Framework
    $USING AA.ProductFramework

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN

INITIALISE:

    AC.ID=EB.Reports.getOData()
    CUS.NAME = ''
    EB.Reports.setOData('')

RETURN

OPEN.FILES:

RETURN

PROCESS:

    AC.REC = AC.AccountOpening.tableAccount(AC.ID, AC.ERR)
    BEGIN CASE

        CASE AC.REC

            IF AC.REC<AC.AccountOpening.Account.ArrangementId> NE ''  THEN ;* If the Account is an Arrangement Account
                ARRANGEMENT.ID = AC.REC<AC.AccountOpening.Account.ArrangementId>
                GOSUB AA.ACCOUNT.JOINT.HOLDER ; *Fetches Joint Holders for arrangement Account
            END ELSE
                JOINT.HOLDER=AC.REC<AC.AccountOpening.Account.JointHolder>
            END

        CASE 1

            AC.AccountOpening.AccountHistRead(AC.ID,AC.HIS.REC,HIS.ERR) ;* read history record for closed accounts.

            IF AC.HIS.REC<AC.AccountOpening.Account.ArrangementId> NE ''  THEN ;* If the Account is an Arrangement Account
                ARRANGEMENT.ID = AC.HIS.REC<AC.AccountOpening.Account.ArrangementId>
                GOSUB AA.ACCOUNT.JOINT.HOLDER ;*Fetches Joint Holders for arrangement Account
            END ELSE
                JOINT.HOLDER=AC.HIS.REC<AC.AccountOpening.Account.JointHolder>
            END
    END CASE

    CONVERT @VM TO @FM IN JOINT.HOLDER
    LOOP
        REMOVE HOLDER.ID FROM JOINT.HOLDER SETTING POS
    WHILE HOLDER.ID:POS
        customerKey = HOLDER.ID
        customerNameAddress = ''
        prefLang = EB.SystemTables.getLngg()
* get the Name of the customer
        CALL CustomerService.getNameAddress(customerKey, prefLang, customerNameAddress)
        IF CUS.NAME NE '' THEN
            CUS.NAME := ","
        END
        CUS.NAME := customerNameAddress<NameAddress.name1,1>
    REPEAT
    EB.Reports.setOData(CUS.NAME)
RETURN
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

*** <region name= AA.ACCOUNT.JOINT.HOLDER>
AA.ACCOUNT.JOINT.HOLDER:
*** <desc>Fetches Joint Holders for arrangement Account </desc>
    CHECK.DATE = EB.SystemTables.getToday()

    AA.Framework.GetArrangementProperties(ARRANGEMENT.ID, CHECK.DATE, R.ARRANGEMENT, PROP.LIST)
    CLASS.LIST = ''
    OVERDRAWN = ''
    AA.ProductFramework.GetPropertyClass(PROP.LIST, CLASS.LIST)       ;* Find their Property classes

    LOCATE 'CUSTOMER' IN CLASS.LIST<1,1> SETTING PROD.POS THEN
        CUS.PROPERTY = PROP.LIST<1,PROD.POS>
    END

    AA.ProductFramework.GetPropertyRecord('', ARRANGEMENT.ID, CUS.PROPERTY, CHECK.DATE, 'CUSTOMER', '', R.CUSTOMER , REC.ERR);* Retrieves the property conditions for an Arrangement Id and the Property Class
    OWNERS = R.CUSTOMER<3>
    TOT.NO.OWNERS = DCOUNT(OWNERS, @VM)  ;* Total Number of Owners is determined
    JOINT.HOLDER = FIELD(OWNERS , @VM ,2, TOT.NO.OWNERS) ;*Customer in the first position is the Owner.Hence Joint Holders are retrieved from the second position onwards


RETURN
*** </region>

END

