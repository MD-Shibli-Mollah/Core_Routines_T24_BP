* @ValidationCode : MjozNzY1Mjc5NzA6Q3AxMjUyOjE1MTMyNTU4NTE1ODM6YXJjaGFuYXByYXNhZDoxOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcxMi4yMDE3MTAyNy0wMDIwOjE1NjoxMzY=
* @ValidationInfo : Timestamp         : 14 Dec 2017 18:20:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : archanaprasad
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 136/156 (87.1%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201712.20171027-0020
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-125</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.NOF.AAL.SCHEDULE.PROJECTOR(SCHED.ARR)
*** <region name= PROGRAM DESCRIPTION>
***
*
** Nofile routine is a copy of E.NOF.AA.SCHEDULE.PROJECTOR
** Returning schedule details with some additional details like
** current outstanding, interest payable, total interest,
** next EMI, total maturity amount
*
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= MODIFICATION HISTORY>
***
* Modification History :
*
* 14/12/17 - Task   : 2379588
*            Defect : 2371554
*            PRINCIPAL needs to be displayed to the Schedule When Payment method is PAY
*            TOTAL.DUE.AMOUNT should be displayed as blank, if it is 0 in the Schedule
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INSERTS>

    $USING AA.PaymentSchedule
    $USING AA.ProductFramework
    $USING EB.SystemTables
    $USING EB.Reports

*** </region>


*** <region name= Main Process>
***
    GOSUB INITIALISE          ;* Initialise Variables here
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
    DUE.METHODS = ""

    SCHED.ARR = ''

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

* Below are the newly used variables for new schedule projection enquiry

    TEMP.DUE.DATES = ''
    DATE.POS = ''
    OUTS.AMT = ''
    TEMP.CURRENT.OS = ''
    DCNT.Y = ''
    TEMP.TOT.PRIN.PAYM = ''
    TEMP.TOT.INT.PAYM = ''
    TEMP.TOT.CAP.PAYM = ''
    TEMP.TOT.CHG.PAYM = ''
    TEMP.TOT.TAX.PAYM = ''
    TEMP.TOT.PAY.PAYM = ''
    EMI.AMT = ''
    TEMP.TOT.DUE.PAYM = ''
    INT.PAID = ''
    TOT.MATURITY.AMT = ''
    TOT.INT.AMT = ''

RETURN
*** </region>


*** <region name= Project the Schedule>
***
BUILD.BASIC.DATA:

    AA.PaymentSchedule.ScheduleProjector(ARR.ID, SIM.REF, "",CYCLE.DATE, TOT.PAYMENT, DUE.DATES, "", DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)         ;* Routine to Project complete schedules
RETURN

*** </region>


*** <region name= Build the Array according to Enquiry requirements>
***
BUILD.ARRAY.DETAILS:

    TOT.DTES = DCOUNT(DUE.DATES,@FM)     ;* Total Number of Schedule dates
    FOR DCNT = 1 TO TOT.DTES
        DUE.DATE = DUE.DATES<DCNT>      ;* Pick each date
        GOSUB SPLIT.AMOUNT    ;*EN_10003652 -S/E
        TOT.PAYM = TOT.PAYMENT<DCNT>    ;* Total Payment for this date
        CURRENT.OS = DUE.OUTS<DCNT>     ;* O/S on this date
        GOSUB FIND.NEW.ADDED.VALUES.IN.ENQ
    NEXT DCNT

    GOSUB FIND.OUTS.AMT.AND.EMI

    FOR DCNT.I = 1 TO TOT.DTES
        SCHED.ARR<-1> = TEMP.DUE.DATES<DCNT.I>:'^':TEMP.TOT.DUE.PAYM<DCNT.I>:'^':TEMP.TOT.CAP.PAYM<DCNT.I>:'^':TEMP.TOT.PRIN.PAYM<DCNT.I>:'^':TEMP.TOT.INT.PAYM<DCNT.I>:'^':TEMP.TOT.CHG.PAYM<DCNT.I>:'^':TEMP.CURRENT.OS<DCNT.I>:'^':TEMP.TOT.TAX.PAYM<DCNT.I>:'^':TEMP.TOT.PAY.PAYM<DCNT.I>:'^':OUTS.AMT:'^':TOT.INT.AMT:'^':INT.PAID:'^':EMI.AMT:'^':TOT.MATURITY.AMT:'^':SIM.REF
    NEXT DCNT.I

*
RETURN

*** </region>
*------------------------------------------------------
*** <region name= Find outstanding amount of current period and next EMI amount>
***
FIND.OUTS.AMT.AND.EMI:

    LOCATE EB.SystemTables.getToday() IN TEMP.DUE.DATES BY 'AR' SETTING DATE.POS THEN
    END
    OUTS.AMT = TEMP.CURRENT.OS<DATE.POS>

    FOR DCNT.Y = DATE.POS TO TOT.DTES
        IF TEMP.TOT.PRIN.PAYM<DCNT.Y> OR TEMP.TOT.INT.PAYM<DCNT.Y> THEN
            EMI.AMT = TEMP.TOT.DUE.PAYM<DCNT.Y>
            BREAK
        END
    NEXT DCNT.Y

RETURN

*** </region>
*------------------------------------------------------
*** <region name= Find newly added fields in the Enquiry>
***
FIND.NEW.ADDED.VALUES.IN.ENQ:

    IF DUE.DATE EQ EB.SystemTables.getToday() OR DUE.DATE GT EB.SystemTables.getToday() THEN
        INT.PAID+ = TOT.INT.PAYM
    END
    TOT.MATURITY.AMT+ = TOT.DUE.PAYM
    TOT.INT.AMT+ = TOT.INT.PAYM

*When TOT.DUE.PAYM is null, to append it correctly to TEMP.TOT.DUE.PAYM variable, we need to assign it with " "
    IF TOT.DUE.PAYM EQ '' THEN
        TOT.DUE.PAYM = " "
    END
    IF TOT.CAP.PAYM EQ '' THEN
        TOT.CAP.PAYM = " "
    END
    IF TOT.PRIN.PAYM EQ '' THEN
        TOT.PRIN.PAYM = " "
    END
    IF TOT.INT.PAYM EQ '' THEN
        TOT.INT.PAYM = " "
    END
    IF TOT.TAX.PAYM EQ '' THEN
        TOT.TAX.PAYM = " "
    END
    IF TOT.PAY.PAYM EQ '' THEN
        TOT.PAY.PAYM = " "
    END

    TEMP.DUE.DATES<-1> = DUE.DATE
    TEMP.CURRENT.OS<-1> = CURRENT.OS
    TEMP.TOT.DUE.PAYM<-1> = TOT.DUE.PAYM
    TEMP.TOT.CAP.PAYM<-1> = TOT.CAP.PAYM
    TEMP.TOT.PRIN.PAYM<-1> = TOT.PRIN.PAYM
    TEMP.TOT.INT.PAYM<-1> = TOT.INT.PAYM
    TEMP.TOT.CHG.PAYM<-1> = TOT.CHG.PAYM
    TEMP.TOT.TAX.PAYM<-1> = TOT.TAX.PAYM
    TEMP.TOT.PAY.PAYM<-1> = TOT.PAY.PAYM

RETURN

*** </region>
*------------------------------------------------------
*** <region name= Split the Payment amount into Principal, Interest & Charge components>
***
SPLIT.AMOUNT:

    TOT.DUE.PAYM = ''
    TOT.CAP.PAYM = ''
    TOT.INT.PAYM = ''
    TOT.PRIN.PAYM = ''
    TOT.CHG.PAYM = ''
    TOT.TAX.PAYM = ''
    TOT.PAY.PAYM = ''
    PROP.CLS.LIST = ''
    TOT.PAY.TYPE = DCOUNT(DUE.TYPES<DCNT>,@VM)
    FOR PAY.CNT = 1 TO TOT.PAY.TYPE
        GOSUB PROCESS.PAY.TYPE
    NEXT PAY.CNT

RETURN
*** </region>
*------------------------------------------------------
*** <region name= Process Pay Type>
***
PROCESS.PAY.TYPE:

    PROP.LIST = DUE.PROPS<DCNT,PAY.CNT>
    PROP.LIST = RAISE(PROP.LIST)
    AA.ProductFramework.GetPropertyClass(PROP.LIST,PROP.CLS.LIST)
    TOT.PROP = DCOUNT(PROP.LIST,@VM)
    FOR PROP.CNT = 1 TO TOT.PROP
        PROP.CLS = ''         ;*Used to save the PC of property for which current tax amt is raised
        TAX.SIGN = 1
        PROP.AMT = DUE.PROP.AMTS<DCNT,PAY.CNT,PROP.CNT>
        TAX.PROP.POS = ''
        IF PROP.CLS.LIST<1,PROP.CNT> EQ '' THEN   ;*May be for Tax amount
            LOCATE PROP.LIST<1,PROP.CNT>['-',1,1] IN PROP.LIST<1,1> SETTING TAX.PROP.POS THEN
                PROP.CLS = PROP.CLS.LIST<1,TAX.PROP.POS>    ;*Store the main property for which tax is raised
                TAX.SIGN = -1 ;* Tax sign to be updated.
            END ELSE
                TAX.PROP.POS = ''
            END
        END
        BEGIN CASE
            CASE (PROP.CLS.LIST<1,PROP.CNT> EQ 'ACCOUNT' AND (DUE.METHODS<DCNT,PAY.CNT,PROP.CNT> MATCHES 'DUE':@VM:'PAY')) ;*Add to Principal for DUE and PAY payment Methods
                TOT.PRIN.PAYM += PROP.AMT

            CASE PROP.CLS.LIST<1,PROP.CNT> EQ 'INTEREST'        ;*Add to Interest
                TOT.INT.PAYM += PROP.AMT

            CASE (PROP.CLS.LIST<1,PROP.CNT> EQ 'CHARGE' AND DUE.METHODS<DCNT,PAY.CNT,PROP.CNT> EQ 'DUE')          ;*Add to Charge only for DUE Type
                TOT.CHG.PAYM += PROP.AMT

            CASE PROP.CLS NE ''   ;*Add to Tax
                TOT.TAX.PAYM += PROP.AMT

        END CASE

        DUE.METHOD = DUE.METHODS<DCNT,PAY.CNT, PROP.CNT>
*For tax property has not individual due methods it will take from user defined whatever they want to collect the tax.
*For example they want to collect the tax for a interest property, they take due method from interest property.
        IF TAX.PROP.POS THEN
            DUE.METHOD = DUE.METHODS<DCNT,PAY.CNT,TAX.PROP.POS>
        END

        BEGIN CASE
            CASE DUE.METHOD MATCHES 'DUE':@VM:'INFO'
                TOT.DUE.PAYM += PROP.AMT
            CASE DUE.METHOD EQ 'CAPITALISE'
                TOT.CAP.PAYM += PROP.AMT * TAX.SIGN
            CASE DUE.METHOD EQ 'PAY'
                TOT.PAY.PAYM += PROP.AMT * TAX.SIGN
        END CASE

    NEXT PROP.CNT
*
RETURN
*** </region>
*------------------------------------------------------
END
