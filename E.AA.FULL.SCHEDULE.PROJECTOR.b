* @ValidationCode : MjotMTI5Mjg2MjU5OTpjcDEyNTI6MTYxNTI3OTg5MjE2MDpzaXZhc2FuZ2FyaW46NTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNi4yMDIwMDUyMS0wNjU1Ojk4Ojky
* @ValidationInfo : Timestamp         : 09 Mar 2021 14:21:32
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : sivasangarin
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 92/98 (93.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-----------------------------------------------------------------------------
* <Rating>-113</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.FULL.SCHEDULE.PROJECTOR(SCHED.ARR)


*** <region name= Synopsis of the Routine>
***
* NOFILE Enquiry Routine triggered to project Schedules in an Arrangement. The Actual Projection is a Generic process
* handled by a different routine. This routine only acts as a Wrapper to format the data to Enquiry Requirements
*
* Mandatory Input : Arrangement ID
* Optional Inputs : Date ranges
* Return Parameter : SCHED.ARR variable holding the Schedule details according to Enquiry Requirements
*
*** </region>

*** <region name= Modification History>
***
*=======================================================================================================================
* 18/05/06         - EN_10002937
*                    New Module AA - Schedule Projector
*
* 06/09/06         - BG_100015123
*                    Schedules with zero amount need to be suppressed
*                    Ref: TTS0706186
*
* 13/02/08         - BG_100017039
*                    AA.ACTIVITY.INITIALISE is called from here instead of
*                    calling from AA.SCHEDULE.PROJECTOR
*
* 16/05/08 - BG_100018434
*            Include a new argument TOT.PAYMENT denoting total due
*            amount for each payment date
*
* 19/08/08 - EN_10003795
*            Common variable R$STORE.PROJECTION set for storing the interest
*            accrual projection.
*            Ref: SAR-2008-05-30-0001
*
* 28/11/08 - EN_10003938
*            Ref : SAR-2008-06-03-0007
*            New selection fld SIM.REF
*            AA.ACTIVITY.INITIALISE is called from AA.SCHEDULE.PROJECTOR when NO.RESET is not set
*
* 13/01/09 - BG_100021546
*            Field Payment Method is required for the drill down enquiry.
*
* 25/02/09 - CI_10060710
*            Ref - HD0902493
*            The common variable  R$STORE.PROJECTION is set in the routine AA.SCHEDULE.PROJECTOR.
*
* 11/07/10 - Task:66399
*    Ref : 65725
*    While displaying properties under a payment type , loop for each property and display payment method
*
* 18/10/10 - Task: 98327:
*            OS amount field in ENQ AA.SCHEDULES.FULL is not showing the correct outstanding amount
*            when interest condition is defined with negative rates
*            Ref: 26687
*
* 12/01/11 - Task : 128458
*            Ref  : EN_56307
*            In the ENQ AA.SCHEDULES.FULL , the interest amount is not zero, even though it is waived
*
* 16/12/13  - Enhancement : 713743 / Task : 719999
*             Account Analysis - Deferment of PaymentSchedule
*
* 05/03/19 - Task   : 3020742
*            Enhan  : 2947685
*            Stop Schedule Projection Processing for Payment type having info type of Properties
*
*
* 23/11/20- Task        : 4062905
*           Enhancement : 3685096
*           System should display the Residual amount in the last principal
*
* 22/12/20- Task        : 4145381
*           Enhancement : 4062919
*           Unblocker - System should display the Residual amount in the last principal
*
* 04/02/21 - Enhancement : 4213569
*            Task : 4213572
*            new field called INCLUDE.NON.CUSTOMER introduced in schedules enquiry to include or  exclude NON.CUSTOMER bills and future projection
*
*=======================================================================================================================
*** </region>


*** <region name= Inserts>
    $USING AA.PaymentSchedule
    $USING EB.Reports
    $USING AA.Interest
    $USING EB.ErrorProcessing
    $USING AA.ProductFramework
    $USING EB.SystemTables
    
*** </region>


*** <region name= Main Process>
***
    GOSUB INITIALISE          ;* Initialise Variables here
    GOSUB BUILD.BASIC.DATA    ;* Build the Schedule Details by calling the Projection Routine
    GOSUB BUILD.ARRAY.DETAILS ;* Format the Details according to Enquiry requirements


RETURN
*** </region>


*** <region name= Initialise Paragraph>
***
INITIALISE:


    DUE.DATES = ''  ;* Holds the list of Schedule due dates
    DUE.TYPES = ''  ;* Holds the list of Payment Types for the above dates
    DUE.TYPE.AMTS = ''        ;* Holds the Payment Type amounts
    DUE.PROPS = ''  ;* Holds the Properties due for the above type
    DUE.PROP.AMTS = ''        ;* Holds the Property Amounts for the Properties above
    DUE.OUTS = ''   ;* Oustanding Bal for the date
    DUE.METHODS = ""
    SCHED.ARR = ''
    SAVE.CURRENT.OS = ''
    
    RESIDUAL.DETS= '' ;* Display the residual at the end of the array
    SAVE.RESIDUAL.DETS= '' ;* Display the residual only once per payment type
    

    ARR.ID = '' ; DATE.REQD = '' ; CYCLE.DATE = ''
    SIM.REF = ''
    LOCATE 'ARRANGEMENT.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ARRPOS THEN
        ARR.ID = EB.Reports.getEnqSelection()<4,ARRPOS>          ;* Pick the Arrangement Id
    END

    LOCATE 'SIM.REF' IN EB.Reports.getEnqSelection()<2,1> SETTING SIMPOS THEN
        SIM.REF = EB.Reports.getEnqSelection()<4,SIMPOS>         ;* Pick the Simulation Reference
    END

    LOCATE 'DATE.FROM' IN EB.Reports.getEnqSelection()<2,1> SETTING DTFR THEN
        CYCLE.DATE = EB.Reports.getEnqSelection()<4,DTFR>        ;* if stated, pick the Start date from when Schedules are required
    END

    LOCATE 'DATE.TO' IN EB.Reports.getEnqSelection()<2,1> SETTING DTTO THEN
        CYCLE.DATE := @FM:EB.Reports.getEnqSelection()<4,DTTO>    ;* If stated, pick the End date till when Schedules are required
    END

    LOCATE 'DATE.DUE' IN EB.Reports.getEnqSelection()<2,1> SETTING DTPOS THEN
        DATE.REQD = EB.Reports.getEnqSelection()<4,DTPOS>        ;* Exact date on whih due Details are requested. This is for Drill down Enquiry
    END
    
    LOCATE 'INCLUDE.EXTERNAL.FEES' IN EB.Reports.getEnqSelection()<2,1> SETTING EXPOS THEN
        INCLUDE.INFO.OPTION = EB.Reports.getEnqSelection()<4,EXPOS>   ;* Get the Selection criteria
        NEW.ARR.ID<2> = INCLUDE.INFO.OPTION ;* Get all the bills for the Arrangement except External bills if arrangement id only given
    END
    
    LOCATE 'INCLUDE.NON.CUSTOMER' IN EB.Reports.getEnqSelection()<2,1> SETTING NONCUTPOS THEN
        INCLUDE.NON.CUSTOMERN.FLAG = EB.Reports.getEnqSelection()<4,NONCUTPOS>   ;* Get the Selection criteria
    END
    
RETURN
*** </region>


*** <region name= Project the Schedule>
***
BUILD.BASIC.DATA:

    IF NEW.ARR.ID<2> NE '' THEN     ;* Check the Option given for field 'INCLUDE.EXTERNAL.FEES'
        ARR.ID<2> = NEW.ARR.ID<2>   ;* If option is 'YES', assign the option to the arrangement argument else no
    END
    
    IF DATE.REQD THEN   ;* proceed only if we have the error message, due to component dependency
        ARR.ID<4> = 1    ;*Flag to indicate projection for details
        RESIDUAL.PROJECTION= ARR.ID<4>
    END
        
* If field INCLUDE.NON.CUSTOMER is set then from schedules enquiry we should include NON.CUSTOMER bills and future projection.
* If this field is blank then exclude NON.CUSTOMER bill and projection as well in schedule projection
    IF INCLUDE.NON.CUSTOMERN.FLAG THEN
        ARR.ID<8> = 'INTERNAL'
    END
    
    AA.PaymentSchedule.ScheduleProjector(ARR.ID, SIM.REF, "",CYCLE.DATE, TOT.PAYMENT, DUE.DATES, DUE.DEFER.DATES, DUE.TYPES, DUE.METHODS,DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)   ;* Routine to Project complete schedules
    AA.Interest.setRStoreProjection('')
RETURN
*** </region>

*** <region name= Build the Array according to Enquiry requirements>
***
BUILD.ARRAY.DETAILS:

    TOT.DTES = DCOUNT(DUE.DATES,@FM)     ;* Total Number of Schedule dates
    FOR DCNT = 1 TO TOT.DTES
        DUE.DATE = DUE.DATES<DCNT>      ;* Pick each date
        TOT.PAYM = TOT.PAYMENT<DCNT>    ;* Total Payment for this date
        CURRENT.OS = DUE.OUTS<DCNT>     ;* O/S on this date
        SAVE.CURRENT.OS = CURRENT.OS  ;* Save the outstanding
        
        TOT.TYPES = COUNT(DUE.TYPES<DCNT>,@VM) + 1
        FOR TCNT = 1 TO TOT.TYPES
            DUE.DEFER.DATE = DUE.DEFER.DATES<DCNT,TCNT>
            DUE.TYPE = DUE.TYPES<DCNT,TCNT>
            DUE.AMT = DUE.TYPE.AMTS<DCNT,TCNT>
            DUE.METHOD = DUE.METHODS<DCNT,TCNT>
            IF DUE.AMT NE '' THEN
                GOSUB CHECK.PROPERTIES
            END
        NEXT TCNT
    NEXT DCNT
RETURN
*** </region>

*** <region name= Check for Property details>
***
CHECK.PROPERTIES:

    TOT.PROP = COUNT(DUE.PROPS<DCNT,TCNT>,@SM)+1
    FOR PCNT = 1 TO TOT.PROP
        PROP.NAME = DUE.PROPS<DCNT,TCNT,PCNT>
        PROP.AMT = DUE.PROP.AMTS<DCNT,TCNT,PCNT>
        DUE.METHOD = DUE.METHODS<DCNT,TCNT,PCNT>
        IF DATE.REQD THEN     ;* Is this a Drill-down
            IF (DATE.REQD = DUE.DATE) THEN        ;* OK...is the date on Schedule, the date that is requested
                SCHED.ARR<-1> = DUE.TYPE:'*':DUE.METHOD:'*':DUE.AMT:'*':PROP.NAME:'*':PROP.AMT      ;* Build the Array for this date
                AA.ProductFramework.GetPropertyClass(PROP.NAME, PROP.CLASS)   ;* Get the property class for the property
                IF TOT.DTES = DCNT AND SAVE.CURRENT.OS NE 0 AND PROP.CLASS EQ "ACCOUNT" AND SAVE.CURRENT.OS AND RESIDUAL.PROJECTION EQ 1 THEN
                    IF ABS(CURRENT.OS) EQ DUE.AMT AND PROP.CLASS EQ "ACCOUNT" THEN  ;* Only if its an account property, go ahead
** If there was no principal initially and if we have added Residual property to be displayed as the principal,
** then skip this display line as anyways we will display the residual in the next set of line
                        DEL SCHED.ARR<1,1>
                    END
                    RESIDUAL.DETS = 'Residual Principal':'*':DUE.METHOD:'*':ABS(SAVE.CURRENT.OS):'*':PROP.NAME:'*':ABS(SAVE.CURRENT.OS) ;* Display the Residual amount as the last principal
        
                END
            END
        
        END ELSE
            SCHED.ARR<-1> = DUE.DATE:'*':DUE.DEFER.DATE:'*':TOT.PAYM:'*':DUE.TYPE:'*':DUE.AMT:'*':PROP.NAME:'*':PROP.AMT:'*':CURRENT.OS     ;* This is the default format.
            DUE.DATE = '' ; DUE.DEFER.DATE = ''
        END
        DUE.TYPE = '' ; DUE.METHOD = ''; DUE.AMT = '' ; TOT.PAYM = '' ; CURRENT.OS = ''   ;* For Subsequent lines, these details are not required. Just Property and Property Amount should suffice
    NEXT PCNT
        
    IF RESIDUAL.DETS AND NOT(SAVE.RESIDUAL.DETS) THEN  ;* Display the residul amount once and not for every payment type
        SAVE.RESIDUAL.DETS = RESIDUAL.DETS
        SCHED.ARR<-1>= RESIDUAL.DETS  ;* Display the residual at the end of the array
    END
        
    
RETURN
*** </region>

END
