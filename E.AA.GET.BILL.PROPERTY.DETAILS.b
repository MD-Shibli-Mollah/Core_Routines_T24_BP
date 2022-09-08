* @ValidationCode : MjotMTE3NjgyMzQ1OTpDcDEyNTI6MTYxNjc2ODkxMDk1NzptYXJjaGFuYToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjIwMjEwMzA1LTA2MzY6NTU6NTU=
* @ValidationInfo : Timestamp         : 26 Mar 2021 19:58:30
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : marchana
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 55/55 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210305-0636
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.BILL.PROPERTY.DETAILS
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
*
*** Conversion routine to get the outstanding properties with the outstanding amount and including the tax penalty interest.
*** </region>
*-----------------------------------------------------------------------------
* @uses         :
* @access       : private
* @stereotype   : subroutine
* @author       : marchana@temenos.com
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
*** Arguments
*
* Incoming : O.DATA Common Variable which contains the input in the format <BillDetails>
* Outgoing : O.DATA Common Variable which contains the os.prop.amt and the corresponding property.Eg,ACCOUNT]PRINCIPALINT]PRINCIPALINT-TAX]PENALTYINT]PENALTYINT-TAX$33324.2]27.4]2.74]257.34]25.73
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History :
**
* 03/25/21  Enh  : 4263098
*           Task : 4263098
*           Changes made to display the accrued tax amount for the AccrueByBill Property.
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>Common variables and file inserts</desc>
* Inserts
*-----------------------------------------------------------------------------

    $USING AA.PaymentSchedule
    $USING EB.Reports
    $USING EB.DataAccess
    $USING EB.DatInterface
    $USING AA.ProductFramework
    $USING AA.Tax
    $USING AA.PaymentRules
    $USING AF.Framework
    $USING AA.Framework
    $USING EB.SystemTables
*-----------------------------------------------------------
*** <region name= Initialise>
***
    GOSUB PROCESS

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
***
PROCESS:
********
    PAY.TYPE = EB.Reports.getOData()
    R.AA.BILL.DETAILS = EB.Reports.getRRecord()

** Update repayment, adjustment, write-off amounts
    
    ARR.ID = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdArrangementId>
    PROPERTY.COUNT = DCOUNT(R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty>, @VM)

    FOR PR.I = 1 TO PROPERTY.COUNT
        PROPERTY.ID = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty,PR.I> ;* Get the property ID
    
        ABB.PROPERTY = "" ;* Flag to indicate the property type is accrue by bill
        TAX.AMT      = 0
        OS.ABB.AMT   = 0
        
        R.PROPERTY = AA.ProductFramework.Property.CacheRead(PROPERTY.ID, RET.ERROR)    ;* Read the Property record
        
        LOCATE 'ACCRUAL.BY.BILLS' IN R.PROPERTY<AA.ProductFramework.Property.PropPropertyType,1> SETTING PropPos THEN
            TAX.INCLUSIVE = ""
            MAKE.DUE = ""
            EFFECTIVE.DATE = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdPaymentDate>
            GOSUB CHECK.TAX.INCLUSIVE
            ABB.PROPERTY = "1"
            CUR.OR.AMT = TAX.AMT + R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsPropAmount,PR.I>
            IF CALC.TAX THEN
                GOSUB CALCULATE.TAX.AMOUNT
            END
            OS.ABB.AMT = OS.ABB.AMT + TAX.AMT + R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsPropAmount,PR.I>
        END
    
        IF TAX.AMT THEN ;* it includes the corresponding tax proeprty and outstanding tax amount on the penaltyinterest in the bill
            R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty,PR.I+1>     = PROPERTY.ID:'-':TAX.PROP
            R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsPropAmount,PR.I+1> = TAX.AMT
            R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOrPropAmount,PR.I+1> = TAX.AMT
            TAX.AMT = ''
        END

    NEXT PR.I

    R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsTotalAmount> += OS.ABB.AMT ;* it display total outstanding amt which includes the tax on penalty

    GOSUB RETURN.ARGUMENTS
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= ReturnArguments>
***
RETURN.ARGUMENTS:
    
    PROPERTIES = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty>
    OUT.AMT = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsPropAmount>
    CHANGE @VM TO '~' IN PROPERTIES
    CHANGE @VM TO '~' IN OUT.AMT
    RETURN.VALUES = PROPERTIES:'$':OUT.AMT
    EB.Reports.setOData(RETURN.VALUES)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CalculateTaxAmount>
***
CALCULATE.TAX.AMOUNT:
   

    PAYMENT.PROP.AMT = CUR.OR.AMT
    ARRANGEMENT.ID<1> = ARR.ID
    ARRANGEMENT.ID<2> = 'ENQUIRY'
    AA.Tax.GetTaxCode(ARRANGEMENT.ID , PROPERTY.ID, EFFECTIVE.DATE , TAX.PROP , TAX.CODES ,TAX.COND ,RET.ERROR)
    IF(TAX.CODES OR TAX.COND) THEN
        AA.Tax.CalculateTax(ARR.ID , EFFECTIVE.DATE , PROPERTY.ID ,PAYMENT.PROP.AMT , TAX.PROP , '', TAX.AMT , "" ,"", RET.ERROR)
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CheckTaxInclusive>
***
CHECK.TAX.INCLUSIVE:
    
    CALC.TAX = ''
    AA.PaymentRules.CheckTaxInclusiveMakedue(ARR.ID,'', EFFECTIVE.DATE, TAX.INCLUSIVE, MAKE.DUE, "", "", RET.ERROR)
    IF TAX.INCLUSIVE THEN  ;* tax is displayed only if the any paymentrule record taxinclusive/makedue setup defined in the paymentruletype record
        CALC.TAX =1
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
