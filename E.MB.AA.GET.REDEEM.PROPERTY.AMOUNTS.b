* @ValidationCode : MjoxODQzNzQ1MTY3OkNwMTI1MjoxNjA5MjM4NTQyNzAwOm1hbmlydWRoOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTAuMjAyMDA5MTktMDQ1OTo5NDo3Ng==
* @ValidationInfo : Timestamp         : 29 Dec 2020 16:12:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : manirudh
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 76/94 (80.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200919-0459
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE AA.ModelBank
SUBROUTINE E.MB.AA.GET.REDEEM.PROPERTY.AMOUNTS
*-----------------------------------------------------------------------------
**** <region name= Program description>
*** <desc> </desc>
*
* Nofile routine that will return the property details in the following format
* Property Name*Debit/Credit Indicator*Property Amount
* This routine will get triggered to display redemption statement
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification history>
*** <desc> </desc>
* Modification History :
*
* 26/02/16 - 1640269
*            Ref: EN_1631634
*            New routine
*
* 05/09/17 - Task : 2260225
*            Defect : 2257591
*            While displaying the outstanding bill amount consider waive, repay & adjustement amounts as well.
*
* 17/04/18 - Task : 2556284
*            Def  : 2536521
*            AA Redemption statement not showing the Deposit Interest properly with PO setup on settlement property
*
* 10/10/18 - Task   : 2804380
*            Defect : 2799907
*            Redemption Statement displaying incorrect settlement amount with PO and Activity Restriction Setup
*
* 25/01/19 - Task : 2961200
*            Defect : 2961183
*            New Sub routine to avoid common variable problems of AA.GET.SOURCE.BALANCE.TYPE
*            When it is called from the Enquiry
*
* 15/12/20 - Task : 4134305
*            Defect : 4082799
*            Redemption statement is made to shown for the backdated simulation dates.
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>

    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.DataAccess
    $USING EB.DatInterface
    $USING AA.PaymentSchedule
    $USING AA.Framework
    $USING AA.Interest
    $USING AA.ProductFramework

*** </region>
*------------------------------------------------------------------------------
*** <region name= Main Process>
*** <desc> </desc>

    GOSUB INITIALISE
    GOSUB PROCESS.BILL.DETAILS

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc> </desc>
INITIALISE:

    INCOMING.VAL = EB.Reports.getOData()
    BILL.ID = FIELD(INCOMING.VAL,"*",1)          ;* Arrangement Id
    SIM.REF = FIELD(INCOMING.VAL,"*",2)         ;* Simulation Reference
    SIM.END.DATE = FIELD(INCOMING.VAL,"*",3)
    SIM.ONLY = FIELD(INCOMING.VAL,"*",4)

    FN.AA.BILL.DETAILS = "F.AA.BILL.DETAILS"
    F.AA.BILL.DETAILS = ""
    EB.DataAccess.Opf(FN.AA.BILL.DETAILS, F.AA.BILL.DETAILS)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process bill details>
*** <desc> </desc>
PROCESS.BILL.DETAILS:

    EB.DatInterface.SimRead(SIM.REF, FN.AA.BILL.DETAILS, BILL.ID, R.AA.BILL.DETAILS, 1, "", "")

    IF R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentDate> LE SIM.END.DATE THEN   ;* get the redemption details, when payment date is less or same as of the sim end date
        GOSUB GET.REDEMPTION.AMOUNT
        EB.Reports.setOData(PAYMENT.DETAILS)
    END ELSE
        EB.Reports.setOData("")
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get Redemption Amount>
*** <desc> </desc>
GET.REDEMPTION.AMOUNT:

    ARR.ID = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdArrangementId>

    LOCATE "DEPOSIT.REDEEM" IN R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentType, 1> SETTING REDEEM.POS THEN
        GOSUB UPDATE.PROPERTY.DETAILS
    END ELSE
        GOSUB UPDATE.OTHER.DETAILS
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Update Other Details>
*** <desc> </desc>
UPDATE.OTHER.DETAILS:

    NO.OF.PAYMENT.TYPES = DCOUNT(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentType>, @VM)

    FOR REDEEM.POS = 1 TO NO.OF.PAYMENT.TYPES
        GOSUB UPDATE.PROPERTY.DETAILS
    NEXT REDEEM.POS

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Update property details>
*** <desc> </desc>
UPDATE.PROPERTY.DETAILS:

    PROPERTY.REPAY.AMTS = ""
    PROPERTY.ADJUST.AMTS = ""
    PAYMENT.PROPERTIES = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPayProperty, REDEEM.POS>
    PAYMENT.AMOUNTS = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOrPrAmt, REDEEM.POS>
    OUTSTANDIDNG.AMOUNTS = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsPrAmt, REDEEM.POS>
    WAIVED.AMOUNTS = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdWaivePrAmt, REDEEM.POS> ;* Get the Waive property amount as SM according to the property
*** the repayment amount and ajustment amount feilds are associated with the PROPERTY field and not with PAYMENT.TYPE field, hence we cannot use REDEEM.POS as the multivalue position for these fields.
    PAY.PROPERTY.CNT = DCOUNT(PAYMENT.PROPERTIES,@SM)
    FOR PAY.PROPERTY = 1 TO PAY.PROPERTY.CNT
        LOCATE PAYMENT.PROPERTIES<1,1,PAY.PROPERTY> IN R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty, 1> SETTING PROPERTY.POS THEN
            REPAYMENT.AMOUNTS = SUM(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdRepayAmount, PROPERTY.POS>)
            ADJUSTMENT.AMOUNTS = SUM(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdAdjustAmt, PROPERTY.POS>)
            PROPERTY.REPAY.AMTS<1, PAY.PROPERTY> = REPAYMENT.AMOUNTS
            PROPERTY.ADJUST.AMTS<1, PAY.PROPERTY> = ADJUSTMENT.AMOUNTS
        END
    NEXT PAY.PROPERTY
    
    LOOP
        REMOVE PAYMENT.PROPERTY FROM PAYMENT.PROPERTIES SETTING PROP.POS
        REMOVE PAYMENT.AMOUNT FROM PAYMENT.AMOUNTS SETTING AMT.POS
        REMOVE OUTSTANDIDNG.AMOUNT FROM OUTSTANDIDNG.AMOUNTS SETTING OUT.POS
        REMOVE WAIVED.AMOUNT FROM WAIVED.AMOUNTS SETTING WAIVE.POS
        REMOVE REPAYMENT.AMOUNT FROM PROPERTY.REPAY.AMTS SETTING REPAY.POS
        REMOVE ADJUSTMENT.AMOUNT FROM PROPERTY.ADJUST.AMTS SETTING ADJ.POS
    WHILE PAYMENT.PROPERTY

        GOSUB GET.PAYMENT.INDICATOR
        GOSUB UPDATE.PROPERTY.AMOUNTS

    REPEAT

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get Payment Indicator>
*** <desc> </desc>
GET.PAYMENT.INDICATOR:

    AA.Framework.GetArrangementProduct(ARR.ID, SIM.END.DATE, "", PRODUCT.ID, "")
    AA.ModelBank.EMbAaGetSourceBalanceType(PAYMENT.PROPERTY, PRODUCT.ID, SOURCE.TYPE, "")
    AA.Interest.CheckAdvanceInterest(ARR.ID, PAYMENT.PROPERTY, ADVANCE.FLAG)
    AA.ProductFramework.GetPropertyClass(PAYMENT.PROPERTY, PROPERTY.CLASS)

    BEGIN CASE
        CASE ADVANCE.FLAG
            SOURCE.TYPE = "ADVANCE"

        CASE PROPERTY.CLASS = "ACCOUNT"
            SOURCE.TYPE = "CREDIT"

        CASE FIELD(PAYMENT.PROPERTY,"-",2)
            SOURCE.TYPE = "DEBIT"

        CASE 1

    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Update Property Amounts>
*** <desc> </desc>
UPDATE.PROPERTY.AMOUNTS:

    PAY.AMOUNT = ADJUSTMENT.AMOUNT + REPAYMENT.AMOUNT + WAIVED.AMOUNT + OUTSTANDIDNG.AMOUNT ;* Total amount against the property which may equal to the OR.AMOUNT or not!!

    BEGIN CASE
        CASE PAY.AMOUNT EQ PAYMENT.AMOUNT ;* Some cases like Adjustement there may be a chance of difference in OR & total property amount!!
            PAYMENT.AMOUNT = PAYMENT.AMOUNT - WAIVED.AMOUNT ;* in that case reduce the waive amount from OR to get the outstanding amount property!!
        CASE ((PAYMENT.AMOUNT - WAIVED.AMOUNT) EQ '0') AND OUTSTANDIDNG.AMOUNT NE '0' ;* If OR amount equals to waive amount then
            PAYMENT.AMOUNT = PAY.AMOUNT
        CASE WAIVED.AMOUNT ;* if waived amount exists then take OR amount as payment amount otherwise take it as outstanding amount
            IF WAIVED.AMOUNT EQ OUTSTANDIDNG.AMOUNT THEN
                PAYMENT.AMOUNT = PAYMENT.AMOUNT
            END ELSE
                PAYMENT.AMOUNT = OUTSTANDIDNG.AMOUNT
            END
        CASE 1
            PAYMENT.AMOUNT = PAY.AMOUNT ;* By default take the outstanding amount as property amount.!!
    END CASE

    IF PAYMENT.DETAILS = "" THEN
        PAYMENT.DETAILS = PAYMENT.PROPERTY:"*":SOURCE.TYPE:"*":PAYMENT.AMOUNT
    END ELSE
        PAYMENT.DETAILS = PAYMENT.DETAILS:"~": PAYMENT.PROPERTY:"*":SOURCE.TYPE:"*":PAYMENT.AMOUNT
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

END
