* @ValidationCode : MjoxODM2NDk0MzE2OkNwMTI1MjoxNjA4MDE5MjI3ODIyOnVtYW1haGVzd2FyaS5tYjo3OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDExLjIwMjAxMDI5LTE3NTQ6NDU6NDQ=
* @ValidationInfo : Timestamp         : 15 Dec 2020 13:30:27
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : umamaheswari.mb
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 44/45 (97.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPINIP.Foundation
SUBROUTINE PPINIP.PO.VALIDATE.API(PO.ID,R.PAYMENT.ORDER,COMP.ID,RESERVED.IN,SUXS.FAIL,ERR.DETS,RESERVED.OUT)
*-----------------------------------------------------------------------------
* This validation routine is payment order level validation for P27NIP clearing.
* This API is attached in PAYMENT.ORDER.PRODUCT>P27INST record in validateapi field.
* Screen level validations:
*--------------------------
* Payment Purpose or Purpose Proprietary field is mandatory
* Payment amount should not be less than 0.01 OR greater than 999999999999999.99
* Remittance information should not be more than 4 multivalue and max char is 140
* Payment execution date should not be back dated
*-----------------------------------------------------------------------------
* Modification History :
* 27/09/2020 - Enhancement  3852895   /Task - 3852900  - Initial Draft
*-----------------------------------------------------------------------------
    $USING PI.Contract
    $USING EB.SystemTables
    
    GOSUB Initialise ; *Initialise the variables
    GOSUB Process ; *Perform the validation on payment purpose and instruction code.
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= initialise>
Initialise:
*** <desc>Initialise the variables </desc>
    
    paymentPurpose = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoPaymentPurpose>
    PurposeProprietary = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoPurposeProprietary>
    PaymentExecutionDate = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoPaymentExecutionDate>
    paymentAmount = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoPaymentAmount>
    remittanceinfo=R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoRemittanceInformation>
    ERR.DETS = ''
    temp=''
    todayDate = EB.SystemTables.getToday()
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
Process:
*** <desc>Validate the Payment values defaulted for execution date, payment purpose, purpose proprietary and mandatory check for the same. </desc>

    
    IF paymentAmount LT 0.01 OR  paymentAmount GT 999999999999999.99 THEN
        ERR.DETS<-1>='PI-PAYMENT.AMT.RANGE':@VM:PI.Contract.PaymentOrder.PoPaymentAmount
    END
     
    fractDigit = FIELD(paymentAmount,".", 2)
    fractDigitCnt = 1
    fractFlag = 1
    LOOP
    WHILE fractFlag
        IF fractDigit[fractDigitCnt,fractDigitCnt] EQ '' THEN
            fractFlag = 0
        END ELSE
            fractDigitCnt = fractDigitCnt + 1
        END
    REPEAT
    fractDigitCnt = fractDigitCnt - 1
     
    IF fractDigitCnt GT '2' THEN
        ERR.DETS<-1>='PI-PYT.AMT.FRAC.DIGIT.2':@VM:PI.Contract.PaymentOrder.PoPaymentAmount
    END
    IF PaymentExecutionDate LT todayDate THEN
        ERR.DETS<-1> = 'PI-PMNT.EXEC.DT.LESS.THAN.TODAY':@VM:PI.Contract.PaymentOrder.PoPaymentExecutionDate
    END
    GOSUB MandatoryCheck
    GOSUB remittancecheck
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Mandatory check>
MandatoryCheck:
*** <desc>payment purpose or purpose proprietary should be mandatory </desc>
    IF (paymentPurpose EQ '' AND PurposeProprietary EQ '') OR (paymentPurpose AND PurposeProprietary) THEN
        ERR.DETS<-1> = 'PI-PURPOSE.CODE.MISSING':@VM:PI.Contract.PaymentOrder.PoPaymentPurpose
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
remittancecheck:
    remittancecnt=DCOUNT(R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoRemittanceInformation>,@VM)
    IF remittancecnt GT '4' THEN
        ERR.DETS<-1> = 'PI-REMIT.INFO.LEN':@VM:PI.Contract.PaymentOrder.PoRemittanceInformation
    END
RETURN
    
END
