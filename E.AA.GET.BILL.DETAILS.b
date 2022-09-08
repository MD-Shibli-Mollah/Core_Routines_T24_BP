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
* <Rating>6</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.GET.BILL.DETAILS
*****************************************
* This is a conversion routine
* This routine accepts Bill Id(with or without Sim Ref)
* and returns OR.TOTAL.AMOUNT, OS.TOTAL.AMOUNT, BILL.ST.DATE and AGE.ST.DT delimited by *
*
*****************************************
*MODIFICATION HISTORY
*
* 05/01/09 - BG_100021512
*            Arguments changed for SIM.READ.
*
* 31/10/11 - Task : 300564
*            Defect : 295640
*            Original property amount should be the sum of the all adjust property amounts
*            plus OR.PROPERTY  amount.
*
* 24/01/13 - Task : 570328
*            Enhancement : 358132
*            Outstanding amount should be the sum of all the property amounts.
*
* 28/10/13 - Task : 821164
*            Defect : 818076
*            System should ignore ADJUST.AMT for suspend reference while calculating the adjust property amount for a property.
*
* 27/02/14 - Task : 926737
*            Defect : 916608
*            Outsanding Bills amount in COS screen is showing wrong calculated amount.
*
* 25/03/14 - Task : 948832
*            Defect : 919187
*            Enquiry enhanced to support .HIST files as well for AA.BILL.DETAILS & AA.ACCOUNT.DETAILS
*
* 13/05/15 - Task: 1281343
*            Defect: 1276606 & Ref: PACS00444631
*            System includes the adjusted amount in overview bills details tab Billed column when
*            adjusted interest property type set as ACCRUE.BY.BILLS.
*
*****************************************
    $USING AA.PaymentSchedule
    $USING EB.DatInterface
    $USING EB.DataAccess
    $USING AA.Overdue
    $USING EB.Reports

*****************************************
*
*** <region name= Main control>
*** <desc>main control logic in the sub-routine</desc>

    BILL.ID = EB.Reports.getOData()['%',1,1]
    SIM.REF = EB.Reports.getOData()['%',2,1]
    R.BILLS = ''

    FN.AA.ACCOUNT.DETAILS = "F.":EB.Reports.getREnq()<2>
    FN.AA.BILL.DETAILS = CHANGE(FN.AA.ACCOUNT.DETAILS,"AA.ACCOUNT.DETAILS","AA.BILL.DETAILS")

    TOTAL.ORIGINAL.PAYMENT.AMOUNT = ''  ;* Original property amount

    IF SIM.REF THEN
        EB.DatInterface.SimRead(SIM.REF, FN.AA.BILL.DETAILS, BILL.ID, R.BILLS, "", "", RET.ERR)
    END ELSE
        EB.DataAccess.FRead(FN.AA.BILL.DETAILS, BILL.ID, R.BILLS, F.AA.BILLS, RET.ERR)
    END
*
    GOSUB CALCUALTE.OR.PROPERTY.AMOUNT  ;* Calculate the sum of all adjusted property amounts

    TOTAL.ORIGINAL.PAYMENT.AMOUNT = R.BILLS<AA.PaymentSchedule.BillDetails.BdOrTotalAmount> + ADJUST.PROPERTY.AMOUNT

    EB.Reports.setOData(TOTAL.ORIGINAL.PAYMENT.AMOUNT:'*':OUTSTANDING.TOTAL.AMOUNT:'*':R.BILLS<AA.PaymentSchedule.BillDetails.BdBillStChgDt,1>:'*':R.BILLS<AA.PaymentSchedule.BillDetails.BdAgingStChgDt,1>)
*
    RETURN
*** </region>
*----------------------------------------------------------------------------------

*** <region name = Calculate OR Property Amount>
*** <desc>Calculate the OR property amount</desc>
CALCUALTE.OR.PROPERTY.AMOUNT:

    ADJUST.PROPERTY.AMOUNT = 0
    OUTSTANDING.TOTAL.AMOUNT = 0
    NO.PROPERTIES = DCOUNT(R.BILLS<AA.PaymentSchedule.BillDetails.BdProperty>,@VM)
    FOR PAY.PROPERTY = 1 TO NO.PROPERTIES
        ** Check whether the property has ACCRUAL.BY.BILLS setup in PROPERTY.TYPE field. If yes ignore to include the adjusted amount
        ** in OR. Since we always not consider ACCRUAL.BY.BILLS property amount in bill OR amount.
        CHECK.PAY.PROPERTY = R.BILLS<AA.PaymentSchedule.BillDetails.BdProperty,PAY.PROPERTY>
        ARRANGEMENT.ID = R.BILLS<AA.PaymentSchedule.BillDetails.BdArrangementId>
        PROPERTY.ACCRUE.BY.BILLS = ''
        RET.ERROR = ''
        ARRANGEMENT.SUSPEND = ''
        AA.Overdue.GetPropertySuspension(ARRANGEMENT.ID, CHECK.PAY.PROPERTY, PROPERTY.ACCRUE.BY.BILLS, ARRANGEMENT.SUSPEND, RET.ERROR)
        LOCATE "ACCRUAL.BY.BILLS" IN PROPERTY.ACCRUE.BY.BILLS<1,1> SETTING POS ELSE
        NO.OF.ADJUST.REF = DCOUNT(R.BILLS<AA.PaymentSchedule.BillDetails.BdAdjustRef,PAY.PROPERTY>, @SM)
        FOR ADJUST.REF.CNT = 1 TO NO.OF.ADJUST.REF
            ADJUST.REF = FIELD(R.BILLS<AA.PaymentSchedule.BillDetails.BdAdjustRef,PAY.PROPERTY,ADJUST.REF.CNT>, "-", 3)
            IF ADJUST.REF ELSE
                ADJUST.PROPERTY.AMOUNT += SUM(R.BILLS<AA.PaymentSchedule.BillDetails.BdAdjustAmt,PAY.PROPERTY,ADJUST.REF.CNT>)
            END
        NEXT ADJUST.REF.CNT
    END
    NEXT PAY.PROPERTY

    OUTSTANDING.TOTAL.AMOUNT = R.BILLS<AA.PaymentSchedule.BillDetails.BdOsTotalAmount>         ;* Calculate the sum of all property amounts

    RETURN
*** </region>
*----------------------------------------------------------------------------------
    END
