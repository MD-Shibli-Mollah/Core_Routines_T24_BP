* @ValidationCode : MjoyMDEwNTIwNjQ3OkNwMTI1MjoxNTg5MzU0OTM2MjM0OmRsYXZhbnlhOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMi4yMDIwMDExNy0yMDI2Oi0xOi0x
* @ValidationInfo : Timestamp         : 13 May 2020 12:58:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dlavanya
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-80</Rating>
*-----------------------------------------------------------------------------
* Subroutine type : SUBROUTINE
* Attached to     : ENQUIRY record AA.DETAILS.SCHEDULE.REPAY
* Attached as     : Conversion Routine
*---------------------------------------------------------------------------------------------------------------
*                      M O D I F I C A T I O N S
*---------------------------------------------------------------------------------------------------------------
* 19/03/2020 - Enhancement  :  3634982
*              Task :  3634985
*              Changes are to differentiate TAX property from SKIM property. 
*-----------------------------------------------------------------------------

$PACKAGE AA.ModelBank
SUBROUTINE E.MB.LOAN.BILL.STATUS

    $USING AA.PaymentSchedule
    $USING AA.ProductFramework
    $USING EB.Reports


    GOSUB INITIALISE
    GOSUB BUILD.BASIC.DATA
    GOSUB BUILD.ARRAY.DETAILS

    EB.Reports.setOData(SCHED.ARR)

RETURN

INITIALISE:

    Y.ID=EB.Reports.getOData()

    ARR.ID=FIELD(Y.ID,"*",1)

    SIM.REF=FIELD(Y.ID,"*",2)

    Y1.DATE=FIELD(Y.ID,"*",3)


    DUE.DATES = ''  ;* Holds the list of Schedule due dates

    DUE.TYPES = ''  ;* Holds the list of Payment Types for the above dates

    DUE.TYPE.AMTS = ''        ;* Holds the Payment Type amounts

    DUE.PROPS = ''  ;* Holds the Properties due for the above type

    DUE.PROP.AMTS = ''        ;* Holds the Property Amounts for the Properties above

    DUE.OUTS = ''   ;* Oustanding Bal for the date

    DUE.METHODS = ""

    SCHED.ARR = ''

RETURN

BUILD.BASIC.DATA:

    AA.PaymentSchedule.ScheduleProjector(ARR.ID, SIM.REF, "",CYCLE.DATE, TOT.PAYMENT, DUE.DATES, "", DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)

RETURN

BUILD.ARRAY.DETAILS:

    TOT.DTES = DCOUNT(DUE.DATES,@FM)     ;* Total Number of Schedule dates

    FOR DCNT = 1 TO TOT.DTES

        DUE.DATE = DUE.DATES<DCNT>      ;* Pick each date

        IF DUE.DATE EQ Y1.DATE THEN

            GOSUB SPLIT.AMOUNT          ;*EN_10003652 -S/E

            TOT.PAYM = TOT.PAYMENT<DCNT>          ;* Total Payment for this date

            CURRENT.OS = DUE.OUTS<DCNT> ;* O/S on this date

            SCHED.ARR<-1> = TOT.PRIN.PAYM:'*':TOT.INT.PAYM:'*':CURRENT.OS

        END

    NEXT DCNT

RETURN

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

                IF PROP.LIST<1,PROP.CNT>['-',2,1] NE 'SKIM' THEN ;*Check if its not a SKIM property
                    PROP.CLS = PROP.CLS.LIST<1,TAX.PROP.POS>    ;*Store the main property for which tax is r
                    TAX.SIGN = -1 ;* Tax sign to be updated.
                END ELSE
                    TAX.PROP.POS = ''
                END

            END ELSE

                TAX.PROP.POS = ''

            END

        END

        BEGIN CASE

            CASE PROP.CLS.LIST<1,PROP.CNT> EQ 'ACCOUNT'         ;*Add to Principal

                TOT.PRIN.PAYM += PROP.AMT

            CASE PROP.CLS.LIST<1,PROP.CNT> EQ 'INTEREST'        ;*Add to Interest

                TOT.INT.PAYM += PROP.AMT

            CASE PROP.CLS.LIST<1,PROP.CNT> EQ 'CHARGE'          ;*Add to Charge

                TOT.CHG.PAYM += PROP.AMT


            CASE PROP.CLS NE ''   ;*Add to Tax

                TOT.TAX.PAYM += PROP.AMT

        END CASE

        DUE.METHOD = DUE.METHODS<DCNT,PAY.CNT, PROP.CNT>

*For tax property has not individual due methods it will take from user defined whatever they want to co

*For example they want to collect the tax for a interest property, they take due method from interest pr

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
