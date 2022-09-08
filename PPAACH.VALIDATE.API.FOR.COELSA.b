* @ValidationCode : MjotNTQ1MzMwNzA0OkNwMTI1MjoxNTkxODc0ODI2NDEzOm1taXRoaWxhOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDUuMjAyMDA1MDUtMDQyNjoyMjoyMg==
* @ValidationInfo : Timestamp         : 11 Jun 2020 16:57:06
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mmithila
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 22/22 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202005.20200505-0426
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.



*------------------------------------------------------------------------------
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
$PACKAGE PPAACH.ClearingFramework
SUBROUTINE PPAACH.VALIDATE.API.FOR.COELSA(PO.ID,R.PAYMENT.ORDER,COMP.ID,RESERVED.IN,SUXS.FAIL,ERR.DETS,RESERVED.OUT)
*-----------------------------------------------------------------------------
* Payment Features specific to a product
* @author gmamatha@temenos.com
* @stereotype Application
* @package PPAACH.ClearingFramework
* </doc>
*-----------------------------------------------------------------------------
* This is a new validate api which will trigerred from STO applocationa and configured in PAYEMENT.ORDER.PRODUCT of STP specific record.
* This api enrich the category purpose propiertary and localInstrumentpropriertary field values before creating PO record.
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 15/05/2019 - Enhancement 3131179 / Task 3131182
*              New validate api will be invoked from STO appilcation for enrichment of PO fields.
* 11/07/2019 - Enhancement 3198007/Task 3226651 - Local Transfer - Domestic Payments - Standing Orders
*            - Last digit is mapped for Category Puprose Proprietary field
* 03/10/2019 - Defect 3364913 - Adding validations for Number of digits allowed for PaymentAmount
* 11/06/2020 - Defect 3791430/Task 3796522
*              Adding validation for currency in salary payments
* ----------------------------------------------------------------------------
* <region name= Inserts>
* </region>
*-----------------------------------------------------------------------------

    $USING PI.Contract
    
    GOSUB INITIALISE
    GOSUB PROCESS
    
RETURN
  
*-----------------------------------------------------------------------------
INITIALISE:
*   initialise the variables here
    PROP.LEN = ''
    LOCAL.INSTR.PROP = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoLocalInstrProp>
    PaymentCurrency = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoPaymentCurrency>
RETURN
*-----------------------------------------------------------------------------
PROCESS:
*   First 7 digits of LocalInstProp of STO to be mapped to PO's LocalInstProp field
*   Last digits of LocalInstProp of STO to be mapped to PO's Category Puprose Proprietary field.
    PROP.LEN = LEN(LOCAL.INSTR.PROP)
    IF LOCAL.INSTR.PROP NE '' THEN
        R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoLocalInstrProp> = SUBSTRINGS(LOCAL.INSTR.PROP,1,7)
        R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoPaymentCategPurpPrty> = SUBSTRINGS(LOCAL.INSTR.PROP,PROP.LEN,1) ;* extracts the last digit
    END

* Payment Amount must contain only maximum of 8 integers and 2 decimal values for Argentina Domestic transfer
    PaymentAmount = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoPaymentAmount>
    AmtIntegerPart = FIELD(PaymentAmount,'.',1)
    AmtDecimalPart = FIELD(PaymentAmount,'.',2)
    IF LEN(AmtIntegerPart) GT 8 OR LEN(AmtDecimalPart) GT 2 THEN
        ERR.DETS ="PI-INVALID.LEN.FOR.ARGCT":@VM:PI.Contract.PaymentOrder.PoPaymentAmount;* The corresponding error will be picked from populate error routine which is handled in the core
    END
* Only ARS currency should be allowed for salary transfers
    IF PaymentCurrency NE 'ARS' AND LOCAL.INSTR.PROP EQ 'CCD-220' THEN
        ERR.DETS<-1> ="PI-INVALID.CCY.FOR.SAL.PAY":@VM:PI.Contract.PaymentOrder.PoPaymentCurrency
    END
    
RETURN
*-----------------------------------------------------------------------------
END
