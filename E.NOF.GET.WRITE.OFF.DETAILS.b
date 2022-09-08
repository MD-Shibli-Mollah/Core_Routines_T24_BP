* @ValidationCode : Mjo4ODA2NjExMDM6Q3AxMjUyOjE2MDc2Njk5ODUxNTc6anViaXR0YWpvaG46NjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNy4yMDIwMDcwMS0wNjU3OjI0NToyMjc=
* @ValidationInfo : Timestamp         : 11 Dec 2020 12:29:45
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jubittajohn
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 227/245 (92.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.20200701-0657
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------

* <Rating>-124</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.NOF.GET.WRITE.OFF.DETAILS(WRITE.OFF.DETAILS)
** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
** This routine return the array to the enquiry AA.DETAILS.WRITE.OFF
*
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History
*
* 12/11/14 - Task 1165744
*            Ref : Defect 1098257
*            Get write-off details for the arrangement from ActivityBalances
*            and Bill details - for both write-off balances, and write-off bill
*
* 20/01/17 - Task : 1996450
*            Defect : 1987730
*            Write off enquiry displays write off interest property amount as
*            summation of actual interest property amount and suspended interest amount in bill.
*
* 13/11/18 - Task : 2851761
*            Defect : 2849618
*            Write off balance details are not shown in the write off statement.
*
* 15/02/19 - Task : 2992715
*            Defect : 2983851
*            Total Write off balance contains the double of loanamount
*
* 11/03/19 - Task : 3030616
*            Defect : 3022058
*            Both PRINCIPAL amount and COMMITMENT amount are summed up and displayed in the enquiry AA.DETAILS.WRITE.OFF.ACTIVITIES.
*
*04/04/19 - Task:3069048
*           Defect:3053691
*           The loan writeoff enquiry displays the wrong value in the overview screen for the interest property.
*
* 20/05/19 - Task   : 3139089
*            Defect : 3128036
*            Loans write off enquiry displays duplicate values for ACCRUE.BY.BILL type property
*
* 02/07/20 - Task   : 3836589
*            Defect : 3780629
*            The write off enquiry should not display the ACC balance type amount
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING EB.DataAccess
    $USING EB.DatInterface
    $USING AA.ProductFramework
    $USING EB.SystemTables
    $USING EB.Reports
    $USING AC.SoftAccounting
    $USING AA.Overdue

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>

    GOSUB INITIALISE

    GOSUB GET.ARRANGEMENT.DETAILS

    GOSUB BUILD.WRITE.OFF.DETAILS

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
INITIALISE:

    ARR.ID = ""
    SIM.REF = ""

    LOCATE 'ARRANGEMENT.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ARRPOS THEN
        ARR.ID = EB.Reports.getEnqSelection()<4,ARRPOS>          ;* Arrangement Id
    END

    LOCATE 'SIM.REF' IN EB.Reports.getEnqSelection()<2,1> SETTING SIMPOS THEN
        SIM.REF = EB.Reports.getEnqSelection()<4,SIMPOS>         ;* Simulation Reference
    END

    F.AA.ACCOUNT.DETAILS = ""

    F.AA.ACCOUNT.DETAILS.HIST = ""

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    EB.DataAccess.Opf(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    FN.AA.BILL.DETAILS.HIST = "F.AA.BILL.DETAILS.HIST"
    F.AA.BILL.DETAILS.HIST = ""
    EB.DataAccess.Opf(FN.AA.BILL.DETAILS.HIST, F.AA.BILL.DETAILS.HIST)

    F.AA.ARRANGEMENT.ACTIVITY = ''

    TEMP.ACTIVITY.DATES = ""  ;* Activity Dates used to sort the return list by Oldest First
    WRITE.OFF.DETAILS = ""    ;* Complete write-off details returned to the enquiry

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Arrangement Details>
*** <desc>Get Arrangement Details, like Product Line, Properties, etc</desc>

GET.ARRANGEMENT.DETAILS:

    IF SIM.REF THEN
        EB.DatInterface.SimRead(SIM.REF, "F.AA.ARRANGEMENT", ARR.ID, R.AA.ARRANGEMENT, "", "", "")
    END ELSE
        AA.Framework.GetArrangement(ARR.ID, R.AA.ARRANGEMENT, "")
    END

** Product Line

    PRODUCT.LINE = R.AA.ARRANGEMENT<AA.Framework.Arrangement.ArrProductLine>

** BalanceMaintenance Property and its related Activities

    EFFECTIVE.DATE = EB.SystemTables.getToday()
    PROPERTY.CLASS.LIST = ""
    PROPERTY.LIST = ""
    ARRANGEMENT.INFO = ARR.ID
    AA.Framework.GetArrangementProperties(ARRANGEMENT.INFO, EFFECTIVE.DATE, '', PROPERTY.LIST)

    AA.ProductFramework.GetPropertyClass(PROPERTY.LIST, PROPERTY.CLASS.LIST)

    LOCATE "BALANCE.MAINTENANCE" IN PROPERTY.CLASS.LIST<1,1> SETTING PROP.POS THEN
        BALANCE.MAINTENANCE.PROPERTY = PROPERTY.LIST<1,PROP.POS>
    END

    WRITE.OFF.ACTIVITIES = PRODUCT.LINE:'-WRITE.OFF-':BALANCE.MAINTENANCE.PROPERTY:@VM:PRODUCT.LINE:'-WRITE.OFF.BALANCE-':BALANCE.MAINTENANCE.PROPERTY

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Build Write-Off Details>
*** <desc>Build Write-off details from Activity Balances and Bill Details</desc>
BUILD.WRITE.OFF.DETAILS:

** Write off details from both Bill and Balances (ActivityBalances) will need to be
** grouped by Arrangement Activity reference

    GOSUB RESET.SORTED.WRITE.OFF.DETAILS ;* Reset sorting variables

    GOSUB BALANCE.WRITE.OFF.DETAILS ;* Get write-off details from Balances

    GOSUB BILL.WRITE.OFF.DETAILS ;* Get write-off details from Bills

    GOSUB UPDATE.SORTED.WRITE.OFF.DETAILS ;* Update sorted write-off details to return array

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get Balance Write-Off Details>
*** <desc>Write-off Details from Activity Balances</desc>
BALANCE.WRITE.OFF.DETAILS:

    ACTIVITY.DATE = ""
    ACTIVITY = ""
    ACTIVITY.REF = ""
    PROPERTY = ""
    PROPERTY.BALANCE = ""
    PROPERTY.BALANCE.NAME = ""
    PROPERTY.AMOUNT = ""


    R.AA.ACTIVITY.BALANCES = ""
    IF SIM.REF THEN
        EB.DatInterface.SimRead(SIM.REF, "F.AA.ACTIVITY.BALANCES", ARR.ID, R.AA.ACTIVITY.BALANCES, "", "", "")
    END ELSE
        AA.Framework.GetActivityBalances(ARR.ID, R.AA.ACTIVITY.BALANCES, "")
    END

    ACT.POS = 1

    ACTIVITY.LIST = RAISE(R.AA.ACTIVITY.BALANCES<AA.Framework.ActivityBalances.ActBalActivity>)

    LOOP
        REMOVE ACTIVITY FROM ACTIVITY.LIST SETTING POS
    WHILE ACTIVITY:POS
        IF ACTIVITY MATCHES WRITE.OFF.ACTIVITIES THEN ;* Pick only write-off details, identified by activity name
            ACTIVITY.DATE = R.AA.ACTIVITY.BALANCES<AA.Framework.ActivityBalances.ActBalActivityDate,ACT.POS>
            ACTIVITY = R.AA.ACTIVITY.BALANCES<AA.Framework.ActivityBalances.ActBalActivity,ACT.POS>
            ACTIVITY.REF = R.AA.ACTIVITY.BALANCES<AA.Framework.ActivityBalances.ActBalActivityRef,ACT.POS>
            PROPERTY.COUNT = DCOUNT(R.AA.ACTIVITY.BALANCES<AA.Framework.ActivityBalances.ActBalProperty,ACT.POS>, @SM)
            FOR PR.POS = 1 TO PROPERTY.COUNT
                PROPERTY = FIELD(R.AA.ACTIVITY.BALANCES<AA.Framework.ActivityBalances.ActBalProperty,ACT.POS,PR.POS>,".",1) ;* Extract Property name
                BALTYPE = FIELD(R.AA.ACTIVITY.BALANCES<AA.Framework.ActivityBalances.ActBalProperty,ACT.POS,PR.POS>,".",2) ;* Extract BalanceType
                BALTYPE = FIELD(BALTYPE,"-",1) ;* Exclude the YES part
                
                PROPERTY.TYPE = ""
                AA.Overdue.GetPropertySuspension(ARR.ID, PROPERTY, PROPERTY.TYPE, "", RET.ERROR)
                
* Check whether ACCRUAL.BY.BILLS is set for the property then ignore it. This will included in Billed amount
                LOCATE "ACCRUAL.BY.BILLS" IN PROPERTY.TYPE<1,1> SETTING SUSP.POS ELSE
                    R.BALANCE.TYPE = ''
                    READ.ERR = ''
                    R.BALANCE.TYPE = AC.SoftAccounting.BalanceType.CacheRead(BALTYPE, READ.ERR)
                    IF R.BALANCE.TYPE<AC.SoftAccounting.BalanceType.BtReportingType> = "NON-CONTINGENT" AND BALTYPE[1,3] NE "ACC" THEN  ;* I am a real balance.Also the amount that is not posted is not taken(skipping the balance prefix with ACC)
                        PROPERTY.BALANCE = FIELD(R.AA.ACTIVITY.BALANCES<AA.Framework.ActivityBalances.ActBalProperty,ACT.POS,PR.POS>,".",2) ;* Extract BalanceType
                        PROPERTY.BALANCE = FIELD(PROPERTY.BALANCE,"-",1) ;* Exclude the YES part
                        IF RIGHT(PROPERTY.BALANCE,2) NE 'SP' THEN
                            PROPERTY.BALANCE = "Current" ;* Since status for the bill is complex, for now, it is decided to just specify Bill/Current
                            PROPERTY.AMOUNT = ABS(R.AA.ACTIVITY.BALANCES<AA.Framework.ActivityBalances.ActBalPropertyAmt,ACT.POS,PR.POS>)
                            GOSUB SORT.WRITE.OFF.DETAILS ;* Build temp array so that bill details could be merged subsequently
                        END
                    END
                END
            NEXT PR.POS
        END
        ACT.POS += 1
    REPEAT

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get Bill Write-Off Details>
*** <desc>Write-Off Details from Bill Details</desc>
BILL.WRITE.OFF.DETAILS:

    ACTIVITY.DATE = ""
    ACTIVITY = ""
    ACTIVITY.REF = ""
    PROPERTY = ""
    PROPERTY.BALANCE = ""
    PROPERTY.BALANCE.NAME = ""
    PROPERTY.AMOUNT = ""

    GOSUB GET.BILL.IDS ;* Get all Bill Ids

    GOSUB PROCESS.BILL.DETAILS ;* Extract write-off details

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get Bill Ids>
***
GET.BILL.IDS:
*
** Ensure we read the live/sim record of AA.ACCOUNT.DETAILS which has the BillIds
*

    IF SIM.REF THEN
        EB.DatInterface.SimRead(SIM.REF, "F.AA.ACCOUNT.DETAILS", ARR.ID, R.AA.ACCOUNT.DETAILS, "", "", "")
    END ELSE
        R.AA.ACCOUNT.DETAILS = AA.PaymentSchedule.AccountDetails.Read(ARR.ID, "")
    END

*
** Ensure we read Hist record as well, for both live/sim
*

    IF SIM.REF THEN
        EB.DatInterface.SimRead(SIM.REF, "F.AA.ACCOUNT.DETAILS.HIST", ARR.ID, R.AA.ACCOUNT.DETAILS.HIST, "", "", "")
    END ELSE
        R.AA.ACCOUNT.DETAILS.HIST = AA.PaymentSchedule.AccountDetailsHist.Read(ARR.ID, "")
    END

    BILL.IDS.HIST = ""
    IF R.AA.ACCOUNT.DETAILS.HIST<AA.PaymentSchedule.AccountDetailsHist.AdBillId,1> THEN      ;* There are some bill records that are archived
        BILL.IDS.HIST = RAISE(RAISE(R.AA.ACCOUNT.DETAILS.HIST<AA.PaymentSchedule.AccountDetailsHist.AdBillId>))  ;* Raise it to FM marker
    END

    BILL.IDS.LIVE = ""
    IF R.AA.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillId,1> THEN ;* There are some bill records in live
        BILL.IDS.LIVE = RAISE(RAISE(R.AA.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillId>))
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------


*** <region name= Process Bill Details>
***
PROCESS.BILL.DETAILS:

** Process both archived and live Bills

    HISTORY = ""    ;* Flag to indicate if bill is to be read from .HIST or from LIVE
    BILL.IDS = BILL.IDS.LIVE
    GOSUB GET.BILL.WRITE.OFF.DETAILS

    HISTORY = 1
    BILL.IDS = BILL.IDS.HIST
    GOSUB GET.BILL.WRITE.OFF.DETAILS

RETURN

*** </region>
*-----------------------------------------------------------------------------


*** <region name= Parse Bill Details>
***
GET.BILL.WRITE.OFF.DETAILS:

    LOOP
        REMOVE BILL.ID FROM BILL.IDS SETTING BILL.POS
    WHILE BILL.ID:BILL.POS

        GOSUB GET.BILL.RECORD ;* Read Bill record from simulation details/live - either archived or live

        PR.COUNT = DCOUNT(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty>, @VM)

        FOR PR.POS = 1 TO PR.COUNT

            WOF.COUNT = DCOUNT(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdWriteoffRef,PR.POS>, @SM)
            FOR WOF.POS = 1 TO WOF.COUNT
                ACTIVITY.REF = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdWriteoffRef,PR.POS,WOF.POS>
                ACTIVITY.DATE = FIELD(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdWriteoffRef,PR.POS,WOF.POS>,"-",2)
                ACTIVITY = ""
                PROPERTY = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty,PR.POS>
                IF R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdAgingStatus,1> THEN
                    PROPERTY.BALANCE = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdAgingStatus,1>:PROPERTY
                END ELSE
                    PROPERTY.BALANCE = "DUE":PROPERTY
                END
                PROPERTY.BALANCE = "Billed" ;* Since status for the bill is complex, for now, it is decided to just specify Bill/Current
                PROPERTY.AMOUNT = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdWriteoffAmt,PR.POS,WOF.POS>
                
                REF = FIELD(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdWriteoffRef,PR.POS,WOF.POS>,"-",2)
                IF REF MATCHES "SUSPEND" :@VM: "RESUME" ELSE
                    ACTIVITY.REF = FIELD(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdWriteoffRef,PR.POS,WOF.POS>,"-",1)
                    GOSUB SORT.WRITE.OFF.DETAILS ;* Include Balance/Bill details
                END
            NEXT WOF.POS
        NEXT PR.POS
    REPEAT

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get Bill Record>
***
GET.BILL.RECORD:

    IF HISTORY THEN ;* Archived Bill
        FN.BILL.DETAILS = FN.AA.BILL.DETAILS.HIST
        F.BILL.DETAILS = F.AA.BILL.DETAILS.HIST
    END ELSE        ;* Live Bill
        FN.BILL.DETAILS = FN.AA.BILL.DETAILS
        F.BILL.DETAILS = F.AA.BILL.DETAILS
    END

    IF SIM.REF THEN ;* Get Bill details from simulation, if not, SIM.READ will get it from live
        EB.DatInterface.SimRead(SIM.REF, FN.BILL.DETAILS, BILL.ID, R.AA.BILL.DETAILS, "", "", "")
    END ELSE        ;* Only live record is required
        EB.DataAccess.FRead(FN.BILL.DETAILS, BILL.ID, R.AA.BILL.DETAILS, F.BILL.DETAILS, "")
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise Formatted WriteOff Details by ActivityReference>
***
RESET.SORTED.WRITE.OFF.DETAILS:

    TEMP.ACTIVITY.REFERENCES = ""
    TEMP.ACTIVITY.DATE = ""
    TEMP.ACTIVITY = ""
    TEMP.PROPERTY = ""
    TEMP.PROPERTY.BALANCE = ""
    TEMP.PROPERTY.AMOUNT = ""

RETURN

*** </region>
*-----------------------------------------------------------------------------


*** <region name= Format WriteOff Details by ActivityReference>
***
SORT.WRITE.OFF.DETAILS:

    ACT.POS.FM = ""
    ACT.POS.VM = ""
    ACT.POS.SM = ""

    FIND ACTIVITY.REF IN TEMP.ACTIVITY.REFERENCES SETTING ACT.POS.FM, ACT.POS.VM, ACT.POS.SM ELSE ;* Dont use LOCATE with alpha-numeric key
        ACT.POS.FM = DCOUNT(TEMP.ACTIVITY.REFERENCES, @FM) + 1
        TEMP.ACTIVITY.REFERENCES<ACT.POS.FM> = ACTIVITY.REF
        TEMP.ACTIVITY.DATE<ACT.POS.FM> = ACTIVITY.DATE
        TEMP.ACTIVITY<ACT.POS.FM> = ACTIVITY
    END
    LOCATE PROPERTY IN TEMP.PROPERTY<ACT.POS.FM,1> SETTING PROP.POS THEN
        LOCATE PROPERTY.BALANCE IN TEMP.PROPERTY.BALANCE<ACT.POS.FM,PROP.POS,1> SETTING BALANCE.POS THEN
            TEMP.PROPERTY.AMOUNT<ACT.POS.FM,PROP.POS,BALANCE.POS> += PROPERTY.AMOUNT
        END ELSE
            BALANCE.POS = DCOUNT(TEMP.PROPERTY.BALANCE<ACT.POS.FM,PROP.POS>, @SM) + 1
            TEMP.PROPERTY.BALANCE<ACT.POS.FM,PROP.POS,BALANCE.POS> = PROPERTY.BALANCE
            TEMP.PROPERTY.AMOUNT<ACT.POS.FM,PROP.POS,BALANCE.POS> = PROPERTY.AMOUNT
        END
    END ELSE
        PROP.POS = DCOUNT(TEMP.PROPERTY.BALANCE<ACT.POS.FM>, @VM) + 1
        BALANCE.POS = DCOUNT(TEMP.PROPERTY.BALANCE<ACT.POS.FM,PROP.POS>, @SM) + 1
        TEMP.PROPERTY<ACT.POS.FM,PROP.POS,BALANCE.POS> = PROPERTY
        TEMP.PROPERTY.BALANCE<ACT.POS.FM,PROP.POS,BALANCE.POS> = PROPERTY.BALANCE
        TEMP.PROPERTY.AMOUNT<ACT.POS.FM,PROP.POS,BALANCE.POS> = PROPERTY.AMOUNT
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Updated formatted WriteOff Details by activity>
***
UPDATE.SORTED.WRITE.OFF.DETAILS:

    ACTIVITY.COUNT = DCOUNT(TEMP.ACTIVITY.REFERENCES, @FM)
    FOR ACT.POS = 1 TO ACTIVITY.COUNT
        ACTIVITY.REF = TEMP.ACTIVITY.REFERENCES<ACT.POS>
        ACTIVITY.DATE = TEMP.ACTIVITY.DATE<ACT.POS>
        ACTIVITY = TEMP.ACTIVITY<ACT.POS>
        IF NOT(ACTIVITY) THEN
            GOSUB GET.ACTIVITY
            ACTIVITY = ACTIVITY.PROCESSED
        END
        GOSUB FORMAT.PROPERTY.DETAILS ;* Convert SM TO VM
        PROPERTY = TEMP.PROPERTY<ACT.POS>
        PROPERTY.BALANCE = TEMP.PROPERTY.BALANCE<ACT.POS>
        PROPERTY.AMOUNT = TEMP.PROPERTY.AMOUNT<ACT.POS>
        TOTAL.AMOUNT = SUM(PROPERTY.AMOUNT)       ;* Get the total amount for the activity
        GOSUB UPDATE.WRITE.OFF.DETAILS
    NEXT ACT.POS

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= get Activity Name>
***
GET.ACTIVITY:

    R.AA.ARRANGEMENT.ACTIVITY = ""
    IF SIM.REF THEN
        EB.DatInterface.SimRead(SIM.REF, "F.AA.ARRANGEMENT.ACTIVITY", ACTIVITY.REF, R.AA.ARRANGEMENT.ACTIVITY, "", "", "")
    END ELSE
        R.AA.ARRANGEMENT.ACTIVITY = AA.Framework.ArrangementActivity.Read(ACTIVITY.REF, "")
    END

    ACTIVITY.PROCESSED = R.AA.ARRANGEMENT.ACTIVITY<AA.Framework.ArrangementActivity.ArrActActivity>

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Format property details>
***
FORMAT.PROPERTY.DETAILS:

    PROPERTY.COUNT = DCOUNT(TEMP.PROPERTY<ACT.POS>, @VM)
    FOR PR.POS = 1 TO PROPERTY.COUNT
        BALANCE.COUNT = DCOUNT(TEMP.PROPERTY.BALANCE<ACT.POS,PR.POS>, @SM)
        FOR BAL.POS = 1 TO BALANCE.COUNT
            TEMP.PROPERTY<ACT.POS,PR.POS,BAL.POS> = TEMP.PROPERTY<ACT.POS,PR.POS>
        NEXT BAL.POS
    NEXT PR.POS

    CONVERT @SM TO @VM IN TEMP.PROPERTY<ACT.POS>
    CONVERT @SM TO @VM IN TEMP.PROPERTY.BALANCE<ACT.POS>
    CONVERT @SM TO @VM IN TEMP.PROPERTY.AMOUNT<ACT.POS>

RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Update Write-Off details>
***
UPDATE.WRITE.OFF.DETAILS:

    LOCATE ACTIVITY.DATE IN TEMP.ACTIVITY.DATES<1> BY "AR" SETTING NEXT.POS ELSE
        INS ACTIVITY.DATE BEFORE TEMP.ACTIVITY.DATES<NEXT.POS>
    END

    TEMP.WRITE.OFF.DETAILS = ACTIVITY.DATE:"*":ACTIVITY:"*":ACTIVITY.REF:"*":PROPERTY:"*":PROPERTY.BALANCE:"*":PROPERTY.AMOUNT:"*":TOTAL.AMOUNT

    INS TEMP.WRITE.OFF.DETAILS BEFORE WRITE.OFF.DETAILS<NEXT.POS>

RETURN

*** </region>
*-----------------------------------------------------------------------------

END
