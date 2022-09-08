* @ValidationCode : MjotMjE5MTMxNzI1OkNwMTI1MjoxNTk0ODk5NDI2MzAzOnVtYW1haGVzd2FyaS5tYjo0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTI3LTA0MzU6MzY6MzY=
* @ValidationInfo : Timestamp         : 16 Jul 2020 17:07:06
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : umamaheswari.mb
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 36/36 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPSARI.Foundation
SUBROUTINE PPSARI.PaymentOrderValidateAPI(PO.ID,R.PAYMENT.ORDER,COMP.ID,RESERVED.IN,SUXS.FAIL,ERR.DETS,RESERVED.OUT)
*-----------------------------------------------------------------------------
* This validation routine is payment order level validation for SARIE RTGS clearing. This API is attached in PAYMENT.ORDER.PRODUCT>SARIE record in validateapi field.
* Screen level validations:
*--------------------------
* 1. payment purpose code should not be greater than three character
* 2. When payment purpose is 'PAY' OR '/DIV/' then remittance information should start with /PAYROLL/ or /DIVIDEND/ respectively
* 3. When payment purpose is not 'PAY' neither '/DIV/' then remittance information should not start with /PAYROLL/ or /DIVIDEND/
* 4. Instruction codes - PHOB and TELB are mutually exclusive
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
 
    $USING PI.Contract
 
    GOSUB Initialise ; *Initialise the variables
    GOSUB Process ; *Perform the validation on payment purpose and instruction code.
RETURN
*-----------------------------------------------------------------------------

*** <region name= Initialise>
Initialise:
*** <desc>Initialise the variables </desc>
    paymentPurpose = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoPaymentPurpose>
    instructionCode = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoInstructionCode>
    PHOBflag = 0
    TELBflag = 0
    ERR.DETS = ''
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Process>
Process:
*** <desc>Perform the validation on payment purpose and instruction code. </desc>

    IF LEN(paymentPurpose) GT 3 THEN ;* Payment purpose code should not be greater than 3
        ERR.DETS<-1> = 'PI-PAY.PUR.CODE.GT.3':@VM:PI.Contract.PaymentOrder.PoPaymentPurpose
    END
    BEGIN CASE ;* Validations on payment purpose code and remittance information
        CASE paymentPurpose EQ 'PAY'
            IF R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoRemittanceInformation,1>[1,9] NE '/PAYROLL/' THEN
                ERR.DETS<-1> = 'PI-REMIT.INFO.CHECK':@VM:PI.Contract.PaymentOrder.PoRemittanceInformation
            END

        CASE paymentPurpose EQ 'DIV'
            IF R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoRemittanceInformation,1>[1,10] NE '/DIVIDEND/' THEN
                ERR.DETS<-1> = 'PI-REMIT.INFO.CHECK01':@VM:PI.Contract.PaymentOrder.PoRemittanceInformation
            END

        CASE 1
            IF  R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoRemittanceInformation,1>[1,9] EQ '/PAYROLL/' OR R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoRemittanceInformation,1>[1,10] EQ '/DIVIDEND/' THEN
                ERR.DETS<-1> = 'PI-REMIT.INFO.CHECK02':@VM:PI.Contract.PaymentOrder.PoRemittanceInformation
            END
    END CASE
        
* Instruction codes - PHOB and TELB are mutually exclusive
    LOCATE 'PHOB' IN instructionCode<1,1> SETTING iCodePos THEN
        PHOBflag  = 1
    END

    LOCATE 'TELB' IN instructionCode<1,1> SETTING iCodePos THEN
        TELBflag  = 1
    END

    IF PHOBflag AND TELBflag THEN
        ERR.DETS<-1> = 'PI-INST.CODE.CHECK':@VM:PI.Contract.PaymentOrder.PoInstructionCode
    END
RETURN
*** </region>

END


