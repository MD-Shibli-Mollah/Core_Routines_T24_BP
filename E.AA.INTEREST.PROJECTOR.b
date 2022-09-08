* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-134</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.INTEREST.PROJECTOR(INTEREST.DETAILS)

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
* 13/02/08         - BG_100017039
*                    Call AA.ACTIVITY.INITIALISE from here instead of calling
*                    from AA.SCHEDULE.PROJECTOR.
*
* 02/05/08         - EN_10003652
*                    Changes done to
*                    1) Include a new column Nominal Rate which shows equivalent Simple Interest Rate
*                       Based on the Interest Amount.
*
*                    2) The field MERGE.DETAIL should be getting the details from Fixed Selection as well
*
* 16/05/08 - BG_100018434
*            Include a new argument TOT.PAYMENT denoting total due
*            amount for each payment date
*
* 28/11/08 - EN_10003938
*            Ref : SAR-2008-06-03-0007
*            New selection field SIM.REF to retreive details from AA.INTEREST.DETAILS
*
* 07/05/09 - CI_10062772
*            WORK.ITEM should be delimited by "*" before calling the paragraph ADD.NOMINAL.RATE.
*
* 30/10/10 - Enhancement - 73497
*            Task - 73501
*            Update the compound yield method in accrual details.
*=======================================================================================================================
*** </region>

*** <region name= Inserts>

    $USING AA.Interest
    $USING EB.Reports
    $USING AA.PaymentSchedule
    $USING EB.API
    $USING AC.Fees

*** </region>

    COMMON /AAINTENQ/ARR.ID
    EQUATE ACC.PAY.TYPE TO 1,
    ACC.PAY.DATE TO 2,
    ACC.FROM.DATE TO 3,
    ACC.TO.DATE TO 4,
    ACC.DAYS TO 5,
    ACC.PRIN TO 6,
    ACC.RATE TO 7,
    ACC.ACCRUAL TO 8,
    ACC.ACCRUAL.ACT TO 9,
    ACC.BASIS TO 10,
    ACC.COMPOUND TO 13,
    ACC.NOM.RATE TO 14,        ;*Store the nominal rate
    ACC.COMPOUND.YIELD TO 15
*
*** <region name= Main Process>
***
    GOSUB INITIALISE          ;* Initialise Variables here
    GOSUB LOAD.ACCRUAL.TO.DATE          ;* Read details from AA.INTEREST.ACCRUALS
    GOSUB BUILD.BASIC.DATA    ;* Build the Schedule Details by calling the Projection Routine
    GOSUB BUILD.ARRAY.DETAILS ;* Format the Details according to Enquiry requirements


    RETURN
*** </region>

    RETURN


*** <region name= Initialise Variables>
***
INITIALISE:


    DUE.DATES = ''  ;* Holds the list of Schedule due dates
    DUE.TYPES = ''  ;* Holds the list of Payment Types for the above dates
    DUE.TYPE.AMTS = ''        ;* Holds the Payment Type amounts
    DUE.PROPS = ''  ;* Holds the Properties due for the above type
    DUE.PROP.AMTS = ''        ;* Holds the Property Amounts for the Properties above
    DUE.OUTS = ''   ;* Oustanding Bal for the date
    DUE.METHODS = ''

    INTEREST.DETAILS = ''     ;* Array of calculation details returned
    AA.Interest.setRStoreProjection(1);* Indicates that accruals should be projected
    AA.Interest.setRProjectedAccruals('')
    MERGE.FLG = ''

    CHECK.ITEM.LIST = ACC.PAY.TYPE:@FM:ACC.PAY.DATE:@FM:ACC.PRIN:@FM:ACC.RATE:@FM:ACC.BASIS:@FM:ACC.COMPOUND:@FM:ACC.COMPOUND.YIELD

    ARR.ID = '' ; DATE.REQD = '' ; CYCLE.DATE = ''
    SIM.REF = ''
    PROPERTY = ''
    START.DATE = ''
    END.DATE = ''

    LOCATE 'ARRANGEMENT.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ARRPOS THEN
    ARR.ID = EB.Reports.getEnqSelection()<4,ARRPOS>          ;* Pick the Arrangement Id
    END

    LOCATE 'SIM.REF' IN EB.Reports.getEnqSelection()<2,1> SETTING SIMPOS THEN
    SIM.REF = EB.Reports.getEnqSelection()<4,SIMPOS>         ;* Pick the Simulation Reference
    END

    LOCATE 'DATE.FROM' IN EB.Reports.getEnqSelection()<2,1> SETTING DTFR THEN
    CYCLE.DATE = EB.Reports.getEnqSelection()<4,DTFR>        ;* if stated, pick the Start date from when Schedules are required
    START.DATE = EB.Reports.getEnqSelection()<4,DTFR>
    END

    LOCATE 'DATE.TO' IN EB.Reports.getEnqSelection()<2,1> SETTING DTTO THEN
    CYCLE.DATE := @FM:EB.Reports.getEnqSelection()<4,DTTO>    ;* If stated, pick the End date till when Schedules are required
    END.DATE = EB.Reports.getEnqSelection()<4,DTTO>
    END

    LOCATE 'MERGE.DETAIL' IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    MERGE.DETAILS = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
    CMP.STR = 'MERGE.DETAIL EQ YES'
    LOCATE CMP.STR IN EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFixedSelection,1> SETTING POS THEN
    MERGE.DETAILS = 'YES'
    END ELSE
    MERGE.DETAILS = "NO"
    END

    END

    LOCATE "PROPERTY" IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    PROPERTY = EB.Reports.getEnqSelection()<4,POS>
    END

    F.AA.INTEREST.ACCRUALS = ''

    RETURN
*** </region>
*-----------------------------------------------------------------------------
LOAD.ACCRUAL.TO.DATE:
*
** Read AA INTEREST ACCRUALS and store the details to date
*
    ACCRUALS.TO.DATE = ''
    R.ACCRUAL.DETAIL = ''
    R.ACCRUAL.DETAIL = AA.Interest.InterestAccruals.Read(ARR.ID, "")
*
*
    RETURN

*** <region name= Project the Schedule>
***
BUILD.BASIC.DATA:

    IF SIM.REF THEN ;**when sim ref is set get interest details from AA.INTEREST.DETAILS
        AA.Interest.RetrieveInterestDetails(ARR.ID, SIM.REF, PROPERTY)
    END ELSE
        AA.PaymentSchedule.ScheduleProjector(ARR.ID, "", "",CYCLE.DATE, TOT.PAYMENT, DUE.DATES, "", DUE.TYPES, DUE.METHODS,DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS) ;* Routine to Project complete schedules
    END

*
    RETURN

*** </region>


*** <region name= Build the Array according to Enquiry requirements>
***
BUILD.ARRAY.DETAILS:

*
** Take the returned accrual calculation details and return them so that one line
** of the enquiry is a set of calculation detials
*
    IF ACCRUALS.TO.DATE THEN
        ACCRUAL.WORK = ACCRUALS.TO.DATE
        ACCRUAL.WORK<-1> = AA.Interest.getRProjectedAccruals()
    END ELSE
        ACCRUAL.WORK = AA.Interest.getRProjectedAccruals()
    END
*
    LAST.CHECK.VALUE = ''     ;* Store key elements so that we can merge splits together
    INTEREST.CNT = ''
    IDX = 0
    LOOP
        IDX += 1
    WHILE ACCRUAL.WORK<IDX>
        WORK.ITEM = ACCRUAL.WORK<IDX>
        ACCRUE.TO.DATE = WORK.ITEM["*",ACC.TO.DATE,1]
        ACCRUE.FROM.DATE = WORK.ITEM["*",ACC.FROM.DATE,1]
        INT.PROPERTY = WORK.ITEM["*",ACC.PAY.TYPE,1]
        GOSUB INCLUDE.ITEM
        IF INCLUDE.ITEM THEN
            GOSUB BUILD.CHECK.VALUE
            *
            ** We can merge together amounts in the same period with the same
            ** basic calculation info: Rate, Prin, Amount, Basis and Compound Type
            *
            IF CHECK.VALUE = LAST.CHECK.VALUE AND MERGE.DETAILS = "YES" THEN
                CALC.DETAIL = INTEREST.DETAILS<INTEREST.CNT>
                CONVERT "*" TO @FM IN CALC.DETAIL
                CONVERT "*" TO @FM IN WORK.ITEM
                CALC.DETAIL<ACC.TO.DATE> = WORK.ITEM<ACC.TO.DATE>
                CALC.DETAIL<ACC.DAYS> += WORK.ITEM<ACC.DAYS>
                CALC.DETAIL<ACC.ACCRUAL> = ADDS(CALC.DETAIL<ACC.ACCRUAL>, WORK.ITEM<ACC.ACCRUAL>)
                CALC.DETAIL<ACC.ACCRUAL.ACT> = ADDS(CALC.DETAIL<ACC.ACCRUAL.ACT>, WORK.ITEM<ACC.ACCRUAL.ACT>)
                CONVERT @FM TO "*" IN CALC.DETAIL
                CONVERT @FM TO "*" IN WORK.ITEM
                MERGE.FLG = 1
                GOSUB ADD.NOMINAL.RATE
                INTEREST.DETAILS<INTEREST.CNT> = CALC.DETAIL
            END ELSE
                INTEREST.CNT += 1
                GOSUB ADD.NOMINAL.RATE
                INTEREST.DETAILS<-1> = WORK.ITEM
            END
            LAST.CHECK.VALUE = CHECK.VALUE
        END
    REPEAT

    AA.Interest.setRStoreProjection('');* Reset in case anybody elese uses it
    RETURN

*** </region>
*-----------------------------------------------------------------------------
ADD.NOMINAL.RATE:
*--------------------
*This paragraph gets the Nominal Rate based on the Interest Amount
*
    NOM.BASIS = WORK.ITEM["*",ACC.BASIS,1]
    TEMP.ITEM = ''
    IF MERGE.FLG THEN         ;*Take from CALC.DETAIL
        TEMP.ITEM = CALC.DETAIL
    END ELSE        ;*Take from WORK.ITEM
        TEMP.ITEM = WORK.ITEM
    END
    NOM.DAYS = TEMP.ITEM["*",ACC.DAYS,1]
    NOM.PRIN = TEMP.ITEM["*",ACC.PRIN,1]
    NOM.INT = TEMP.ITEM["*",ACC.ACCRUAL.ACT,1]
    NOM.FR.DATE = TEMP.ITEM["*",ACC.FROM.DATE,1]
    NOM.TO.DATE = TEMP.ITEM["*",ACC.TO.DATE,1]
    EB.API.Cdt("",NOM.FR.DATE,"-1C")
    NOM.RATE = ''
    AC.Fees.EbGetEqIntRate(NOM.PRIN,NOM.INT,NOM.FR.DATE,NOM.TO.DATE,NOM.BASIS,NOM.RATE)  ;*New routine that returns equivalen
    IF NOM.RATE ELSE
        NOM.RATE = ''
    END
    CONVERT "*" TO @FM IN TEMP.ITEM
    TEMP.ITEM<ACC.NOM.RATE> = NOM.RATE
    CONVERT @FM TO "*" IN TEMP.ITEM
    IF MERGE.FLG THEN
        CALC.DETAIL = TEMP.ITEM
    END ELSE
        WORK.ITEM = TEMP.ITEM
    END
*
    RETURN
*-----------------------------------------------------------------------------

BUILD.CHECK.VALUE:
*
** Build a list of values to compare
*
    CHECK.VALUE = ''
    CHK.CNT = 0
    LOOP
        CHK.CNT +=1
        ACCRUAL.FIELD = CHECK.ITEM.LIST<CHK.CNT>
    WHILE ACCRUAL.FIELD
        IF CHECK.VALUE THEN
            CHECK.VALUE := "*":WORK.ITEM["*",ACCRUAL.FIELD,1]
        END ELSE
            CHECK.VALUE = WORK.ITEM["*",ACCRUAL.FIELD,1]
        END
    REPEAT
*
    RETURN
*
*-----------------------------------------------------------------------------
INCLUDE.ITEM:
*
    BEGIN CASE
        CASE PROPERTY AND INT.PROPERTY NE PROPERTY
            INCLUDE.ITEM = ''
        CASE START.DATE AND END.DATE
            IF ACCRUE.TO.DATE GT START.DATE AND ACCRUE.FROM.DATE LT END.DATE THEN
                INCLUDE.ITEM = 1
            END ELSE
                INCLUDE.ITEM = ''
            END
        CASE START.DATE AND ACCRUE.TO.DATE GT START.DATE
            INCLUDE.ITEM = 1
        CASE START.DATE
            INCLUDE.ITEM = ''
        CASE END.DATE AND ACCRUE.FROM.DATE LT END.DATE
            INCLUDE.ITEM =1
        CASE END.DATE
            INCLUDE.ITEM = ''
        CASE 1
            INCLUDE.ITEM =1
    END CASE
*
    RETURN
*
    END
