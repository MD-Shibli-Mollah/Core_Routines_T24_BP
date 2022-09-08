* @ValidationCode : MjoxMzQ3MzMyMDY6Q3AxMjUyOjE1NzQxNDU2ODQ5MTU6cnRodWxhc2lyYW1hbjo1OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTEwLjIwMTkwOTIwLTA3MDc6MTE1OjEwNg==
* @ValidationInfo : Timestamp         : 19 Nov 2019 12:11:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rthulasiraman
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 106/115 (92.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-67</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.ARR.NEXT.PAYMENT
**********************************
*MODIFICATION HISTORY
*
* 05/01/09 - BG_100021512
*            Arguments changed for SIM.READ.
*
* 01/10/09 - CI_10066780
*            Replaced the call to AA.GET.ARRANGEMENT.PRODUCT with AA.GET.ARRANGEMENT.PROPERTIES
*            to get the list arrangement of properties.
*            Ref: HD0935492
*
* 23/10/09 - EN_10004405
*            Ref : SAR-2008-11-06-0009
*            Deposits Infrastructure - Review Activities and Actions
*
* 23/04/12 - Task Id / 393767
*            O.DATA is assigned to the variable ARR.NO.
*
* 26/02/16 - Task : 1644388 / Defect : 1641112
*            Next Payment Date is missing occasionally from Account Dates enquiry.
*
*
* 21/09/15 - Task   : 1476009
*            Defect : 923916
*            Enquiry enhanced to support AA.ACCOUNT.DETAILS.HIST files as well for AA.ACCOUNT.DETAILS.
*            PROCESS.TYPE<4> is set as FULL to get the Merger record of (AA.ACCOUNT.DETAILS & .HIST)
*
* 28/06/17 : Task : 2175822/ Defect: 2172764
*            When the status of Account is pending closure or close then no need to show
*            next repayment date.
*
* 28/06/17 - Task   : 2175727
*            Defect : 2174371
*            Arrangement overview screen doesn't display Next Pay Date for capitalised activity.
*
* 02/11/17 - Task : 2328127
*            Def  : 2325996
*            Next payment date in overview shows the next capitalise date even though the next makedue date occurs before. This happens
*            as the captilalise activity occurs first in scheduled activity table.
*
* 06/23/19 - Task : 3192876
*            Def  : 3190229
*            If the capitalise payment method had been specified with the end date then the next payment date should not be null
*            it should be the make due's next payment date, when make due and capitalise both are specified in the schedule.
*
* 30/07/19 - Task : 3257845
*            Def  : 3257003
*            System update NEXT.PAYMENT.DATE in Loan overview with wrong date.
*
***********************************************************************

    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING EB.DatInterface
    $USING AA.ProductFramework
    $USING EB.SystemTables
    $USING EB.Reports

***********************************************************************
*
    GOSUB INITIALISE
    
    IF PROCESS.FLAG THEN
        GOSUB PROCESS
    END
*
RETURN
***********************************************************************
INITIALISE:
**************
*
    LOCATE '@ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ID.POS THEN
        ARR.NO = EB.Reports.getEnqSelection()<4,ID.POS>
    END ELSE

        ARR.NO = EB.Reports.getOData()
    END
*
    IF EB.Reports.getEnqSimRef() THEN
        SIM.REF = EB.Reports.getEnqSimRef()
    END ELSE
        SIM.REF = ''
    END
	PROCESS.FLAG = "1"
    GOSUB GET.ARRANGEMENT.RECORD        ;*Get Arrangement Record
    PRODUCT.LINE = R.ARRANGEMENT<AA.Framework.Arrangement.ArrProductLine>       ;* Product Line from Activity
*
    RET.ERR = ''
    R.SCH = ''
    R.SIM = ''
    R.ACC.DETS = ''
    R.BILL = ''
    R.PAY.SCH = ''
    F.AA.SCH = ''
    PS.PROP = ''
    CMP.DATE = EB.SystemTables.getToday()
*
    PROCESS.TYPE = ""
    PROCESS.TYPE<1> = "INITIALISE"
    PROCESS.TYPE<4> = "FULL"  ;* To get the full record from AA.ACCOUNT.DETAILS (both AA.ACCOUNT.DETAILS & .HIST)

    IF SIM.REF THEN
        EB.DatInterface.SimRead(SIM.REF, "F.AA.SCHEDULED.ACTIVITY", ARR.NO, R.SCH, "", "", RET.ERR)
        EB.DatInterface.SimRead(SIM.REF, "F.AA.ACCOUNT.DETAILS", ARR.NO, R.ACC.DETS, "", "", RET.ERR)
        R.SIM = AA.Framework.SimulationRunner.Read(SIM.REF, RET.ERR)
        CMP.DATE = R.SIM<AA.Framework.SimulationRunner.SimSimEndDate>
    END ELSE
        R.SCH = AA.Framework.ScheduledActivity.Read(ARR.NO, RET.ERR)
        AA.PaymentSchedule.ProcessAccountDetails(ARR.NO, PROCESS.TYPE,   '', R.ACC.DETS, RET.ERROR)
    END
*
    PROP.CLS.LIST = ''
    IF SIM.REF THEN
        ARR.NO<1,2> = '1'
    END

    ARR.INFO = ARR.NO:@FM:'':@FM:'':@FM:'':@FM:'':@FM:''
    AA.Framework.GetArrangementProperties(ARR.INFO, CMP.DATE, R.ARR, PROPERTY.LIST)
    AA.ProductFramework.GetPropertyClass(PROPERTY.LIST,PROP.CLS.LIST)
    LOCATE "PAYMENT.SCHEDULE" IN PROP.CLS.LIST<1,1>  SETTING CLS.POS THEN
        PS.PROP = PROPERTY.LIST<1,CLS.POS>
    END
*
RETURN
*****************************************************************************************
PROCESS:
**********
*
    CMP.ACTIVITY = PRODUCT.LINE:'-MAKEDUE-':PS.PROP
    CAP.ACTIVITY = PRODUCT.LINE:'-CAPITALISE-':PS.PROP
    GOSUB GET.SCH.DETS
    EB.Reports.setOData(NEXT.DT)
*
RETURN
*****************************************************************************************
GET.SCH.DETS:
******************

    PROCESS.END = ''
    LAST.DT = ''
    NEXT.DT = ''
    NEXT.DT.STORE = ''
    LAST.DT.STORE = ''
    ACT.CNT = DCOUNT(R.SCH<AA.Framework.ScheduledActivity.SchActivityName>,@VM)
    FOR CNT.SCH = 1 TO ACT.CNT UNTIL PROCESS.END
        IF R.SCH<AA.Framework.ScheduledActivity.SchActivityName,CNT.SCH> EQ CMP.ACTIVITY THEN
            IF NEXT.DT.STORE NE '' THEN          ;* We have already found CAPITALISE activity and now we have found MAKEDUE activity. No need to check further.
                PROCESS.END = '1'
            END
            BEGIN CASE
                CASE NEXT.DT.STORE NE '' AND R.SCH<AA.Framework.ScheduledActivity.SchLastDate,CNT.SCH> AND NOT(R.SCH<AA.Framework.ScheduledActivity.SchNextDate,CNT.SCH>) ;* if the make due payment date has the end date specified then the next payment date will be the capitalise activity's next payment date.
                    LAST.DT.STORE = R.SCH<AA.Framework.ScheduledActivity.SchLastDate,CNT.SCH>
                        
                CASE R.SCH<AA.Framework.ScheduledActivity.SchNextDate,CNT.SCH> LT NEXT.DT.STORE OR NEXT.DT.STORE EQ ''     ;* The lesser of the Next dates of the CAPITALISE and MAKEDUE will be the next payment date.
                    LAST.DT.STORE = R.SCH<AA.Framework.ScheduledActivity.SchLastDate,CNT.SCH>
                    NEXT.DT.STORE = R.SCH<AA.Framework.ScheduledActivity.SchNextDate,CNT.SCH>
            
            END CASE
        END ELSE
            IF R.SCH<AA.Framework.ScheduledActivity.SchActivityName,CNT.SCH> EQ CAP.ACTIVITY THEN  ;*check to set last date and next date for capitalise activity
                
                IF NEXT.DT.STORE NE '' THEN      ;* We have already found MAKEDUE activity and now we have found CAPITALISE activity. No need to check further.
                    PROCESS.END = '1'
                END
                
                BEGIN CASE
                    CASE NEXT.DT.STORE NE '' AND R.SCH<AA.Framework.ScheduledActivity.SchLastDate,CNT.SCH> AND NOT(R.SCH<AA.Framework.ScheduledActivity.SchNextDate,CNT.SCH>) ;* if the capitalise payment date has the end date specified then the next payment date will be the make due's payment date.
                        LAST.DT.STORE = R.SCH<AA.Framework.ScheduledActivity.SchLastDate,CNT.SCH>
                
                
                    CASE R.SCH<AA.Framework.ScheduledActivity.SchNextDate,CNT.SCH> LT NEXT.DT.STORE OR NEXT.DT.STORE EQ ''    ;* The lesser of the Next dates of the CAPITALISE and MAKEDUE will be the next payment date.
                        LAST.DT.STORE = R.SCH<AA.Framework.ScheduledActivity.SchLastDate,CNT.SCH>
                        NEXT.DT.STORE = R.SCH<AA.Framework.ScheduledActivity.SchNextDate,CNT.SCH>
              
                END CASE

            END
        END
    NEXT CNT.SCH
    
    NEXT.DT = NEXT.DT.STORE
    LAST.DT = LAST.DT.STORE
    
    IF LAST.DT EQ CMP.DATE THEN         ;*Check for any due
        LOCATE CMP.DATE IN R.ACC.DETS<AA.PaymentSchedule.AccountDetails.AdBillPayDate,1> SETTING DT.POS THEN
            GOSUB CHECK.STATUS
        END
    END

    EB.Reports.setOData(NEXT.DT)
*
RETURN
*----------------------------------------------------------------------------------------
CHECK.STATUS:
***************
    PROCESS.END = ''
    FOR LOOP.CNT = 1 TO DCOUNT(R.ACC.DETS<AA.PaymentSchedule.AccountDetails.AdBillStatus,DT.POS>,@SM) UNTIL PROCESS.END
        IF NOT(R.ACC.DETS<AA.PaymentSchedule.AccountDetails.AdBillStatus,DT.POS,LOOP.CNT> MATCHES 'SETTLED':@VM:"CAPITALISE") AND R.ACC.DETS<AA.PaymentSchedule.AccountDetails.AdRepayReference,DT.POS,LOOP.CNT> NE 'PAYOFF' THEN ;* Next Payment date is next schedule date when the bill status is capilaised or settled
            NEXT.DT = CMP.DATE
        END
    NEXT LOOP.CNT
*
RETURN
*****************************************************************************************
*** <region name= GET.ARRANGEMENT.RECORD>
GET.ARRANGEMENT.RECORD:
*** <desc>Get Arrangement Record </desc>

    R.ARRANGEMENT = '' ; ARR.ERROR = ''
    IF AA.Framework.getRArrangement() AND ARR.NO EQ AA.Framework.getArrId() THEN
        R.ARRANGEMENT = AA.Framework.getRArrangement()
    END ELSE
        AA.Framework.GetArrangement(ARR.NO, R.ARRANGEMENT, ARR.ERROR)     ;* Arrangement record
    END
*No need to show the next payment date for pending close/close status accounts
    IF R.ARRANGEMENT<AA.Framework.Arrangement.ArrArrStatus> MATCHES "PENDING.CLOSURE":@VM:"CLOSE" THEN
        PROCESS.FLAG = "" ;* No need to process to get the next payment date
        EB.Reports.setOData("")
    END

RETURN
*** </region>
