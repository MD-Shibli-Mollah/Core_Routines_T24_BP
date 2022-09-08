* @ValidationCode : MjotMzMwMDI4MDMyOkNwMTI1MjoxNjE1NDM3MDEzNTM3OnNqYXJpbmFiYW51OjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDMuMDozNDc6MTU3
* @ValidationInfo : Timestamp         : 11 Mar 2021 10:00:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sjarinabanu
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 157/347 (45.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-133</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.ACTIVITY.LOG(RET.LIST)
***************************************************
*No file enquiry routine which will return the AA.ACTIVITY.HIST details
****************
*MODIFICATION HISTORY
*
* 06/11/08 - BG_100020815
*            Changes done to cater simulations as well
*
* 05/01/09 - BG_100021512
*            Arguments changed for SIM.READ.
*
* 08/05/09 - CI_10063186
*            Ref : TTS0906176
*            Issue Bill activities with no bills &
*            corresponding make due activities should not be displayed.
*
* 09/12/09 - CI_10068093
*            Ref : HD0946798
*            Issue Bill, Make due and Capitalise activity will not been
*            shown in the Arrangement Overview screen if the Bill was not
*            Issued. Compare the Activity date with the Start date in the
*            AA.ACCOUNT.DETAILS file, if it is less than start date then no
*            need to show the activity in the Arrangement Overview screen.
*
* 21/06/11 - Defect_212661
*            Task_230817
*            Code changes done  to not to display the Reversed Activities if SUPPRESS.REVERSAL field is set to 'YES'
*
* 30/10/12 - Defect - 507975 / Task - 510423
*            CAPITALISE activity is missed to get display in the "Activity Log" tab of retail accounts overview.
*
* 21/11/12 - Enhancement 355118
*            Task - 396212
*            Code changed to include some more selection during run time using Date & using the fixed selection in the enquiry.
*
* 25/03/14  - Task : 948832
*             Defect : 919187
*     Enquiry enhanced to support .HIST files as well for AA.BILL.DETAILS & AA.ACCOUNT.DETAILS
*
* 29/04/14  - Task: 985343
*             Ref : 983039
*             Remove usage of common variables to avoid problem when multiple arrangements are viewed simultaneously.
*
* 10/07/14  - Task   : 1053851
*             Defect : 1038303
*             Enquiry not to display activities passed through fixed selection
*
* 24/10/14 - Task 1149308
*            Ref : Defect 1102306
*            Enquiry will not display activities that has been deleted.
*
* 19/03/16 - Task 1669243
*            Ref : Defect 1667922
*            SYSTEM initiated OD activities are not displayed in System Initiated enquiry
*
* 02/04/16 - Enhancement : 1033356
*            Task : 1638897
*            New selection field ACTIVITY.CLASS is introduced. It will allow only fixed selection. It is hard coded in enquiry
*            Hard coded activities are SDB-CUSTOMER.VISIT-SDB & SDB-RECORD.STATUS-SDB activities.
*
* 16/1/17 - Task : 2417725
*            Ref : Defect 2380566
*            Display Make due , issue bill and capitalise activities even before disbursement
*
* 10/03/21 - Defect : 3680756
*            Task   : 4275633
*            In activity log enquiry system is allowing to reverse reinstate activity under deal which is initiated by facility.
*
***************************************************
    
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING EB.Reports
    $USING AA.ProductFramework
    $USING EB.DatInterface

*************************************

    GOSUB INITIALISE
    GOSUB GET.VALUES
    GOSUB GET.DETAILS

RETURN
*****************************************************
INITIALISE:
************
*Initialise variables
*
    CHECK.LIST = ''
    NEW.STR = ''
    ACTIVITY.STR = ''
*
*   If this Flag is set to YES, Then ActivityLog wont display the Reversed Activities in the Enquiry.

    SUPP.REVERSAL = ''
    ARCHIVED.ONLY = ''        ;* Flag to indicate system to return only Archived activities

    ARRANGEMENT.ID = ''
    INITIATION = ''
    ACTIVITY.AMT = ''
    SIMULATION.REF = ''
    ACTIVITY.ID = ''
    ACTIVITY.CLASS.ID = ''
    ACTIVITY.LINK.TYPES = "LINKED.INTERNAL.CHILD":@VM:"LINKED.EXTERNAL.CHILD":@VM:"INTERNAL.CHILD":@VM:"EXTERNAL.CHILD":@VM:"LINKED.FWD.INTERNAL.CHILD":@VM:"LINKED.FWD.EXTERNAL.CHILD" ;*Store allowed activity link types
*
RETURN
*****************************************************
GET.VALUES:
*************
*Get values from Enquiry.Select
*
    LOCATE 'ARRANGEMENT.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ARR.POS THEN
        ARRANGEMENT.ID = EB.Reports.getEnqSelection()<4,ARR.POS>
    END

    LOCATE 'ARCHIVED.ONLY' IN EB.Reports.getEnqSelection()<2,1> SETTING ARC.POS THEN
        ARCHIVED.ONLY = EB.Reports.getEnqSelection()<4,ARC.POS>
    END
    
    IF ARRANGEMENT.ID THEN
        AA.Framework.GetArrangement(ARRANGEMENT.ID, R.ARRANGEMENT,ERR.MSG) ;*To get R.Arrangement Record
        SUB.ARRANGEMENT = R.ARRANGEMENT<AA.Framework.Arrangement.ArrSubArrangement> ;* Get sub arrangement id's from R.Arrangement
        MASTER.TYPE = R.ARRANGEMENT<AA.Framework.Arrangement.ArrMasterType> ;*Get master type from R.Arrangement
    END

    FIX.SEL = EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFixedSelection>
    NO.SEL = DCOUNT(FIX.SEL,@VM)
    FOR CNT.LOOP = 1 TO NO.SEL
        SEL.COND = FIX.SEL<1,CNT.LOOP>

*** From the fixed selection getting values for INITIATION & SUPPRESS.REVERSAL & ACTIVITY.AMT
*** For SUPPRESS.REVERSAL value will be YES or Null . If it is YES it will Suppress all Reversed Activity
*** For Initiation values will be SCHEDULED*EOD or SCHEDULED*SOD or USER.If any values is given then the initaition
*** the appropriate records will be listed in the output.
*** For ACTIVITY.AMT values will be not equal to NULL. If it has value it will list all Financial Activity

        BEGIN CASE
            CASE SEL.COND[' ',1,1] EQ 'SUPPRESS.REVERSAL'
                SUPP.REVERSAL = SEL.COND[' ',3,1]
            CASE SEL.COND[' ',1,1] EQ 'INITIATION'
                INITIATION = SEL.COND[' ',3,1]:@VM:SEL.COND[' ',4,1]:@VM:SEL.COND[' ',5,1]:@VM:SEL.COND[' ',6,1]
            CASE SEL.COND[' ',1,1] EQ 'ACTIVITY.AMT'
                ACTIVITY.AMT = SEL.COND[' ',3,1]
            CASE SEL.COND[' ',1,1] EQ 'ARCHIVED.ONLY'
                ARCHIVED.ONLY = SEL.COND[' ',3,1]
            CASE SEL.COND[' ',1,1] EQ "ACTIVITY"
                FIX.ACT.NAME<-1> = SEL.COND[' ',3,1]
            CASE SEL.COND[' ',1,1] EQ "ACTIVITY.CLASS"
                ACTIVITY.CLASS.ID<1,-1> = SEL.COND[' ',3,1]
        END CASE

    NEXT CNT.LOOP

*
    LOCATE 'SIM.REF' IN EB.Reports.getEnqSelection()<2,1> SETTING SIM.POS THEN
        SIMULATION.REF = EB.Reports.getEnqSelection()<4,SIM.POS>
    END
*
    LOCATE 'START.DATE' IN EB.Reports.getEnqSelection()<2,1> SETTING ST.POS THEN
        ST.DT = EB.Reports.getEnqSelection()<4,ST.POS>
        ST.OPR = EB.Reports.getEnqSelection()<3,ST.POS>
    END ELSE
        ST.DT = ''
        ST.OPR = ''
    END
*
    LOCATE 'END.DATE' IN EB.Reports.getEnqSelection()<2,1> SETTING END.POS THEN
        END.DT = EB.Reports.getEnqSelection()<4,END.POS>
        END.OPR = EB.Reports.getEnqSelection()<3,END.POS>
    END ELSE
        END.DT = ''
        END.OPR = ''
    END
*
    LOCATE 'ACTIVITY.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING END.POS THEN
        ACTIVITY.ID = EB.Reports.getEnqSelection()<4,END.POS>
        ACT.OPR = EB.Reports.getEnqSelection()<3,END.POS>
        CONVERT ' ' TO @VM IN ACTIVITY.ID
        ACT.CNT = DCOUNT(ACTIVITY.ID,@VM)
        VAR.CNT = 1
        LOOP
            ACT.ID = ACTIVITY.ID<1,VAR.CNT>
        WHILE ACT.ID
            NEW.STR = ''
            GOSUB PROCESS.ACT.ID        ;*Convert the ... to appropriate strings to match
            CONVERT '...' TO '' IN ACT.ID
            ACTIVITY.ID<1,VAR.CNT> = ACT.ID
            VAR.CNT += 1
        REPEAT
    END ELSE
        ACT.ID = ''
        ACT.OPR = ''
    END
    
*
RETURN
*****************************************************
PROCESS.ACT.ID:
*
* This para process the activity id for the presence of '...' and builds NEW.STR accordingly which will be used
* only in case of LK and UL command.
*
    TOT.LEN = LEN(ACT.ID)
    FOR PR.CNT = 1 TO TOT.LEN
        IF ACT.ID[PR.CNT,1] EQ '.' AND ACT.ID[PR.CNT+1,1] EQ '.' AND ACT.ID[PR.CNT+2,1] EQ '.' THEN
            BEGIN CASE
                CASE PR.CNT GT 1 AND PR.CNT LT (TOT.LEN-2)
                    NEW.STR := "'0X'"
                CASE PR.CNT GT 1
                    NEW.STR := "'0X"
                CASE 1
                    NEW.STR := "0X'";
            END CASE
            PR.CNT += 2
        END ELSE
            BEGIN CASE
                CASE PR.CNT EQ 1
                    NEW.STR := "'"
                    NEW.STR := ACT.ID[PR.CNT,1]
                CASE PR.CNT EQ TOT.LEN
                    NEW.STR := ACT.ID[PR.CNT,1]
                    NEW.STR := "'"
                CASE 1
                    NEW.STR := ACT.ID[PR.CNT,1]
            END CASE
        END
    NEXT PR.CNT
    ACTIVITY.STR<1,VAR.CNT> = NEW.STR
*
RETURN
*****************************************************
EVALUATE.OPERAND:
*
    BEGIN CASE
        CASE TMP.OPR EQ 'EQ'
            IF TMP.ARG EQ TMP.VALUE ELSE
                PROCESS.FLG = ''
            END
*
        CASE TMP.OPR EQ 'GT'
            IF TMP.ARG GT TMP.VALUE ELSE
                PROCESS.FLG = ''
            END
*
        CASE TMP.OPR EQ 'GE'
            IF TMP.ARG GE TMP.VALUE ELSE
                PROCESS.FLG = ''
            END
*
        CASE TMP.OPR EQ 'LT'
            IF TMP.ARG LT TMP.VALUE ELSE
                PROCESS.FLG = ''
            END
*
        CASE TMP.OPR EQ 'LE'
            IF TMP.ARG LE TMP.VALUE ELSE
                PROCESS.FLG = ''
            END
*
        CASE TMP.OPR EQ 'NE'
            IF TMP.ARG NE TMP.VALUE ELSE
                PROCESS.FLG = ''
            END
*
        CASE TMP.OPR EQ 'LK'
            IF TMP.ARG MATCHES NEW.STR ELSE
                PROCESS.FLG = ''
            END
*
        CASE TMP.OPR EQ 'UL'
            IF TMP.ARG MATCHES NEW.STR THEN
                PROCESS.FLG = ''
            END
*
    END CASE
*
RETURN
*****************************************************
* Paragraph to get the activities list from the Activity History archived file. AA.ACTIVITY.HISTORY.HIST.
GET.ARCHIVED.ACITIVITY.LIST:
***************************

    F.AA.ACTIVITY.HISTORY.HIST = ""

    LOOP
        REMOVE ARC.ID FROM ARC.IDS SETTING ARCPOS
    WHILE ARC.ID : ARCPOS

        GOSUB GET.ACTIVITY.HISTORY.HIST
        IF R.AA.ACT.HIST THEN
            R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhEffectiveDate> := @VM : R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistoryHist.AhEffectiveDate>
            R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivityRef>   := @VM : R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistoryHist.AhActivityRef>
            R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivity>       := @VM : R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistoryHist.AhActivity>
            R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhSystemDate>    := @VM : R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistoryHist.AhSystemDate>
            R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivityAmt>   := @VM : R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistoryHist.AhActivityAmt>
            R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActStatus>     := @VM : R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistoryHist.AhActStatus>
            R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhInitiation>     := @VM : R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistoryHist.AhInitiation>
        END ELSE
            R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhEffectiveDate> = R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistoryHist.AhEffectiveDate>
            R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivityRef>   = R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistoryHist.AhActivityRef>
            R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivity>       = R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistoryHist.AhActivity>
            R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhSystemDate>    = R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistoryHist.AhSystemDate>
            R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivityAmt>   = R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistoryHist.AhActivityAmt>
            R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActStatus>     = R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistoryHist.AhActStatus>
            R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhInitiation>     = R.AA.ACTIVITY.HISTORY.HIST<AA.Framework.ActivityHistoryHist.AhInitiation>
        END
    REPEAT

RETURN

GET.ACTIVITY.HISTORY.HIST:
**************************

    R.AA.ACTIVITY.HISTORY.HIST = ""
    ERR.AA.ACTIVITY.HISTORY.HIST = ""

    IF SIMULATION.REF THEN
        EB.DatInterface.SimRead(SIMULATION.REF, "F.AA.ACTIVITY.HISTORY.HIST", ARC.ID, R.AA.ACTIVITY.HISTORY.HIST, "", "", ERR.MSG)
    END ELSE

        R.AA.ACTIVITY.HISTORY.HIST = AA.Framework.ActivityHistoryHist.Read(ARC.ID, ERR.AA.ACTIVITY.HISTORY.HIST)
    END

RETURN

GET.DETAILS:
*

    R.AA.ACT.HIST = ''
    ERR.MSG = ''
    R.AA.ACC.DETS = ''

    IF SIMULATION.REF THEN
        EB.DatInterface.SimRead(SIMULATION.REF, "F.AA.ACTIVITY.HISTORY", ARRANGEMENT.ID, R.AA.ACT.HIST, "", "", ERR.MSG)
        EB.DatInterface.SimRead(SIMULATION.REF, "F.AA.ACCOUNT.DETAILS", ARRANGEMENT.ID, R.AA.ACC.DETS, "", "", ERR.MSG)
    END ELSE
        AA.Framework.ReadActivityHistory(ARRANGEMENT.ID, "", "", R.AA.ACT.HIST)
        AA.PaymentSchedule.ProcessAccountDetails(ARRANGEMENT.ID, "INITIALISE", "", R.AA.ACC.DETS, ERR.MSG)
    END

    BEGIN CASE

        CASE ARCHIVED.ONLY EQ "YES"
** If Activied only is set to Yes, then archived records requested so display only the archived records.
            ARC.IDS = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhArcId>
            R.AA.ACT.HIST = ""
            GOSUB GET.ARCHIVED.ACITIVITY.LIST
        CASE ARCHIVED.ONLY EQ "NO"
*** If actived only is set to No then display all the activities including archival.
            GOSUB GET.ARCHIVED.ACITIVITY.LIST
        CASE ARCHIVED.ONLY EQ ""
*** leave with existing functionality and don't touch anything.
    END CASE

*** To Locate only the particular dates that given in selection criteria

    TOT.CNT = DCOUNT(R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhEffectiveDate>,@VM)
    GOSUB GET.DATES
    LOCATE ST.DT IN R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhEffectiveDate,1> BY "DR" SETTING START.POS THEN
    END
    LOCATE END.DT IN R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhEffectiveDate,1> BY "DR" SETTING END.POS THEN
    END

    ST.DT.FLD = AA.Framework.ActivityHistory.AhEffectiveDate
    END.DT.FLD = AA.Framework.ActivityHistory.AhEffectiveDate
    ACT.ID.FLD = AA.Framework.ActivityHistory.AhActivity

* If the position for start date is greater than the end date then need to interchange the values then only the loop gets executed.
* This will happen only when we use operator GE operator in start date & LE operator in end date.

    FLD.POS = '' ; EXC.POS =''
    IF START.POS < END.POS ELSE
        EXC.POS = START.POS
        START.POS = END.POS
        END.POS = EXC.POS
    END

    FOR LOOP.CNT = START.POS TO END.POS
        PROCESS.FLG = 1
        IF ST.DT THEN
            TMP.VALUE = ST.DT
            TMP.OPR = ST.OPR
            TMP.ARG = R.AA.ACT.HIST<ST.DT.FLD,LOOP.CNT>
            GOSUB EVALUATE.OPERAND
            IF PROCESS.FLG ELSE
                CONTINUE      ;*Skip and go to next date
            END
        END
        IF END.DT THEN
            TMP.VALUE = END.DT
            TMP.OPR = END.OPR
            TMP.ARG = R.AA.ACT.HIST<END.DT.FLD,LOOP.CNT>
            GOSUB EVALUATE.OPERAND
            IF PROCESS.FLG ELSE
                CONTINUE      ;*Skip and go to next date
            END
        END
*        IF ACT.ID.FLD THEN
        TOT.ACT = DCOUNT(R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivityRef,LOOP.CNT>,@SM)
        VAL.POS = ''
        FOR ACT.CNT = TOT.ACT TO 1 STEP -1
            PROCESS.FLG = 1
            
            BEGIN CASE
                CASE ACTIVITY.CLASS.ID
                    IF R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhInitiation,LOOP.CNT,ACT.CNT> MATCHES INITIATION THEN
                        GOSUB CHECK.CLASS.CONDITION
                    END ELSE
                        PROCESS.FLG = ''
                    END
                CASE ACTIVITY.ID
                    GOSUB CHECK.CONDITIONS
            END CASE
            
            IF PROCESS.FLG THEN
                GOSUB UPDATE.LIST
            END
        NEXT ACT.CNT
    NEXT LOOP.CNT
*
RETURN
*****************************************************
UPDATE.LIST:
*****************
*
* Add other details here
* If SUPP.REVERSAL been set to 'YES' Then dont display the Reversed activities in the ACTIVITY LOG Enquiry
    DISPLAY.FLAG = "" ;
    LINKED.ARRANGEMENT = ""
    IF NOT(SUPP.REVERSAL = 'YES' AND R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActStatus,LOOP.CNT,ACT.CNT> EQ "AUTH-REV") AND R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActStatus,LOOP.CNT,ACT.CNT> NE "DELETE" THEN
        BEGIN CASE
            CASE (R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhInitiation,LOOP.CNT,ACT.CNT> MATCHES INITIATION)
                DISPLAY.FLAG = "1"          ;* Only when initiation is given like USER,TRANSACTION,Scheduled
            CASE (R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivityAmt,LOOP.CNT,ACT.CNT> NE INITIATION AND ACTIVITY.AMT NE '' AND INITIATION EQ '')
                DISPLAY.FLAG = "1"          ;* For displaying Transaction Amount
            CASE (INITIATION EQ '' AND ACTIVITY.AMT EQ '')
                DISPLAY.FLAG = "1"          ;* When Initiation is empty
        END CASE

        IF DISPLAY.FLAG THEN
            ACTIVITY.REF = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivityRef,LOOP.CNT,ACT.CNT>
            ACTIVITY.NAME = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivity,LOOP.CNT,ACT.CNT>
            LOCATE ACTIVITY.NAME IN FIX.ACT.NAME<1> SETTING ACT.POS ELSE
                VAL.POS += 1
                FLD.POS += 1
                
***Read arrangement activity record only when deal/facility is having sub arrangement/ for drawing under facility
                IF SUB.ARRANGEMENT OR MASTER.TYPE EQ "FACILITY" THEN
                    AAA.REC = AA.Framework.ArrangementActivity.Read(ACTIVITY.REF,READ.ERR) ;*Read arrangement activity record
                    LOCATE AAA.REC<AA.Framework.ArrangementActivity.ArrActivityLinkType> IN ACTIVITY.LINK.TYPES<1,1> SETTING LINK.POS THEN
                        LINKED.ARRANGEMENT = 1 ;*Set this flag when an arrangement activity link type is matches with allowed activity link types
                    END
                END

                CHECK.LIST<1,1> = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhEffectiveDate,LOOP.CNT>
                CHECK.LIST<1,2> = TOT.ACT-ACT.CNT+1     ;*Seq Number
                CHECK.LIST<1,3> = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivity,LOOP.CNT,ACT.CNT>
                CHECK.LIST<1,4> = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivityRef,LOOP.CNT,ACT.CNT>
                CHECK.LIST<1,5> = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhSystemDate,LOOP.CNT,ACT.CNT>
                CHECK.LIST<1,6> = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivityAmt,LOOP.CNT,ACT.CNT>
                CHECK.LIST<1,7> = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActStatus,LOOP.CNT,ACT.CNT>
                CHECK.LIST<1,8> = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhInitiation,LOOP.CNT,ACT.CNT>

*** Populate time only for Activity Class selection alone. It is used only for SDB product line. specially for Customer Visit & for Record Status activities.
                
                IF ACTIVITY.CLASS.ID AND DATE.TIME THEN
                    CHECK.LIST<1,9> = DATE.TIME
                END
                IF LINKED.ARRANGEMENT THEN
                    CHECK.LIST<1,8> = "LINKED.SECONDARY" ;*When linked.arrangement flag is set, send initiation type as LINKED.SECONDARY
                END
                
                RET.LIST<FLD.POS> = CHECK.LIST    ;*Just return the number of values.
            
            END
        END
    END
*
RETURN
************************************************************
CHECK.CONDITIONS:

    VAR.CNT = 1
    LOOP
    WHILE ACTIVITY.ID<1,VAR.CNT>
        TMP.VALUE = ACTIVITY.ID<1,VAR.CNT>
        NEW.STR = ACTIVITY.STR<1,VAR.CNT>
        TMP.OPR = ACT.OPR
        TMP.ARG = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivity,LOOP.CNT,ACT.CNT>
        GOSUB EVALUATE.OPERAND
        VAR.CNT += 1
    REPEAT

*
RETURN
****************************************************

CHECK.CLASS.CONDITION:

    CLASS.FOUND = ''        ;* Initialise with Null
    
    VAR.CNT = 1
    LOOP
    WHILE ACTIVITY.CLASS.ID<1,VAR.CNT>
        USER.ACTIVITY.CLASS = ACTIVITY.CLASS.ID<1,VAR.CNT>
        AH.ACTIVITY = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivity,LOOP.CNT,ACT.CNT>
        GOSUB COMPARE.ACTIVITY.CLASS
        VAR.CNT += 1
    REPEAT
    
    IF CLASS.FOUND THEN
*** Read the AAA record and get the date and time of the activity
        Contrct.Id = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivityRef,LOOP.CNT,ACT.CNT>
        AAA.REC = AA.Framework.ArrangementActivity.Read(Contrct.Id , RetError)
        DATE.TIME = AAA.REC<AA.Framework.ArrangementActivity.ArrActDateTime>
    END ELSE
        PROCESS.FLG = ''
    END
    
RETURN
    
*****************************************************

COMPARE.ACTIVITY.CLASS:

** Read the activity class record by using either activity or Linked activity
    
    AH.ACTIVITY.CLASS = ''
    AA.ProductFramework.GetActivityClass(AH.ACTIVITY, AH.ACTIVITY.CLASS, ACTIVITY.CLASS.RECORD)
    
    IF USER.ACTIVITY.CLASS EQ AH.ACTIVITY.CLASS THEN
        CLASS.FOUND = 1
    END
      
RETURN

*****************************************************

GET.DATES:

* The dates are sorted by descending order. If end date is using LE or LT operator then need to fetch the last value from the sorted
* date list (that means need to pick the data from the Arrangement start date). If start date is using GE or GT operator then need to
* fetch the first value from the sorted list(means upto Last transaction happened)

    BEGIN CASE
        CASE ST.DT EQ '' AND END.DT NE ''
            IF END.OPR EQ "LE" OR  END.OPR EQ "LT"  THEN        ;* Getting Start Date
                ST.DT = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhEffectiveDate,TOT.CNT>
            END ELSE
                ST.DT = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhEffectiveDate,1>
            END
        CASE ST.DT NE '' AND END.DT EQ ''
            IF ST.OPR EQ "GE" OR ST.OPR EQ "GT" THEN  ;* Getting End Date
                END.DT = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhEffectiveDate,1>
            END ELSE
                END.DT = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhEffectiveDate,TOT.CNT>
            END
        CASE ST.DT NE '' AND END.DT NE ''
            RETURN
        CASE 1
            ST.DT = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhEffectiveDate,1> ; END.DT = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhEffectiveDate,TOT.CNT>
    END CASE

RETURN
END
