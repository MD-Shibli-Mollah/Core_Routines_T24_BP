* @ValidationCode : MjotMTY2NDAzNjY4OTpDcDEyNTI6MTU3MDUxODY0NzM2MzpqaGFsYWt2aWo6NTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkxMC4yMDE5MDkyMC0wNzA3OjI3OjI1
* @ValidationInfo : Timestamp         : 08 Oct 2019 12:40:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jhalakvij
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 25/27 (92.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------

* <Rating>-20</Rating>

*-----------------------------------------------------------------------------

* Subroutine Type : Subroutine
* Incoming        : ENQ.DATA
* Outgoing        : ENQ.DATA Common Variable
* Attached to     : AA.ARRANGEMENT
* Attached as     : Build Routine in the Field BUILD.ROUTINE
* Primary Purpose : To only return a record if the Arrangement is not current
* Incoming        : Common variable ENQ.DATA Which contains all the
*                 : enquiry selection criteria details

* Change History  :
* Version         : First Version
* Author          : smakrinos@temenos.com
************************************************************

*MODIFICATION HISTORY
*
* 28/06/17 -    Task   : 2175686
*               Defect : 2171438
*               For expired contracts  payoff statement not working.
*
*25/05/18 -    Task   : 2589210
*               Defect : 2695661
*               To get Bill details for AA.PAYOFF.STATEMENT enquiry.
*
* 04/09/18 -    Task   : 2754104
*               Defect : 2741500
*               Arrangement | Creation | System taking more time to load and display details, when loan status is in NOT DISBURSED
*
* 15/02/19 -    Task   :2992105
*               Defect :2987501
*               When executes multiple arrangements on lending overview screen one after another in the same session
*               First arrangement payoff details will not be shown in the  payoff statment enquiry screen of the other arrangements .
*
*12/09/2019 -   Task:3257476
*               Enhancement:3193806
*               If Product Line Equals Facility and status is Auth then Payoff Bill is fetched
*
* 01/10/19 -    Task   : 3367619
*               Defect : 3362585
*               Payoff Statement for the future date not available
************************************************************
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.NOT.CURRENT(ENQ.DATA)

************************************************************

    $USING EB.Reports
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING EB.SystemTables

****************************

    GOSUB INITIALISE

    GOSUB PROCESS

RETURN

****************************

INITIALISE:

    ARR.ID = ""
    LOCATE "ARRANGEMENT.ID" IN ENQ.DATA<2,1> SETTING ARR.POS THEN
        ARR.ID = ENQ.DATA<4,ARR.POS>
    END

    SIM.REF = EB.Reports.getEnqSimRef()

    IF SIM.REF THEN
        ARR.ID<1,2> = SIM.REF
    END

RETURN

**********************

PROCESS:

**********************

    RET.ERROR = ''
    BILL.IDS = ''
    

    AA.Framework.GetArrangement(ARR.ID, R.ARRANGEMENT, RET.ERROR)
    ProductLine = R.ARRANGEMENT<AA.Framework.Arrangement.ArrProductLine>
    ArrStatus = R.ARRANGEMENT<AA.Framework.Arrangement.ArrArrStatus>
    
    ENQ.DATA<2,ARR.POS>="@ID"
    ENQ.DATA<3,ARR.POS>="EQ"
    
    IF (ProductLine NE "FACILITY" AND NOT(ArrStatus MATCHES "CURRENT":@VM:"EXPIRED")) OR (ProductLine EQ "FACILITY" AND ArrStatus NE "AUTH") THEN   ;*If Product Line Equals Facility and status is Auth then Payoff Bill is fetched
        ENQ.DATA<4,ARR.POS>='NOT.CURRENT'
    END ELSE
* Clear the Account details before calling AA.GET.BILL routine since within that routine under GET.ACCOUNT.DETAILS para
* we have condition like if AccountDetails already set then use that same values to get bills.
* so when you execute multiple arrangement on Lending overview in the same session ,Then it may have problem to display the respective arrangement pay off bill details.
* Payoff bill cannot be more than one hence no need pass the bill date, BILL.TYPE is enough to get the payoff bill.
        AA.Framework.setAccountDetails("")
        AA.PaymentSchedule.GetBill(ARR.ID, "", "", "", "", "PAYOFF", "", "", "", "", "", "", BILL.IDS, RET.ERR)
        ENQ.DATA<4,ARR.POS>=BILL.IDS
    END
  
    

RETURN

******************************

END
