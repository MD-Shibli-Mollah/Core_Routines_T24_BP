* @ValidationCode : MjotMTE3NDExMTAwMTpDcDEyNTI6MTYwNTAwMTU1Mjc3MTp1bWFtYWhlc3dhcmkubWI6MTQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MToxMzA6MTI4
* @ValidationInfo : Timestamp         : 10 Nov 2020 15:15:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : umamaheswari.mb
* @ValidationInfo : Nb tests success  : 14
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 128/130 (98.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPISIP.Foundation
SUBROUTINE PPISIP.PO.VALIDATE.API(PO.ID,R.PAYMENT.ORDER,COMP.ID,RESERVED.IN,SUXS.FAIL,ERR.DETS,RESERVED.OUT)
*-----------------------------------------------------------------------------
* This validation routine is payment order level validation for SAINST clearing.
* This API is attached in PAYMENT.ORDER.PRODUCT>SAINSTPAY record in validateapi field.
* Screen level validations:
*--------------------------
* Default payment Execution Date as Today System Date
* Payment Purpose or Purpose Proprietary field is mandatory
* Payment amount should not be less than zero
* Payment Purpose should have dropdown values ( BONU, DIVI,OTHR,SALA)
* Purpose Proprietary should have dropdown values (BEN, CIT, MOF, WEL)
* Debit IBAN is mandatory
* Default context value based on context name ('1' if Online Banking,2 if Mobile Banking,3 if Phone Banking,4 if Branch,5 if Kiosk/ATM,6 if Corporate)
* When ordering DOB is input, atleast any one of Ordering Br City or Ordering Br Country or Ordering Br Prvnc should be present
* When ordering person / ultimate debtor / ultimate creditor / benificary OT.ID is input, either schme code or scheme proprietary or scheme issues is mandatory
*-----------------------------------------------------------------------------
* Modification History :
* 27/09/2020 - Enhancement 3675355 / Task 3929661 - SAINST
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
    debitIban = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoDebitAccountIban>
    contextNames = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoContextName>
    paymentPurposeArry = 'BONU':@VM:'DIVI':@VM:'OTHR':@VM:'SALA'
    PurposeProprietaryArry = 'BEN':@VM:'CIT':@VM:'MOF':@VM:'WEL'
    paymentAmount = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoPaymentAmount>
    
    orderingDOB = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingDob>
    orderingBrCity = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingBrCity>
    orderingBrCntry = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingBrCountry>
    orderingBrPvnc = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingBrPrvnc>
    
    orderingOTidType = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingOtIdType>
    orderingOTid = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingOtId>
    orderingSchmCode = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingSchmeCde>
    orderingSchmPrty = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingSchPrty>
    orderingSchIssr = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingSchIssr>
    
    BenfcyOTidType = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryOtIdType>
    BenfcyOTid = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryOtId>
    BenfcySchmCode = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiarySchmeCde>
    BenfcySchmPrty = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiarySchPrty>
    BenfcySchIssr = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiarySchIssur>
    
    uDbtOTidType = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorOtIdType>
    uDbtOTid = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorOtId>
    uDbtSchmCode = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorSchmeCde>
    uDbtSchmPrty = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorSchPrty>
    uDbtSchIssr = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorSchIssur>
    
    uCrdtOTidType = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorOtIdType>
    uCrdtOTid = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorOtId>
    uCrdtSchmCode = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorSchmeCde>
    uCrdtSchmPrty = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorSchPrty>
    uCrdtSchIssr = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorSchIssur>
    
    ERR.DETS = ''
    todayDate = EB.SystemTables.getToday()
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process>
Process:
*** <desc>Validate the Payment values defaulted for execution date, payment purpose, purpose proprietary and mandatory check for the same. </desc>
    IF paymentAmount LE 0 THEN
        ERR.DETS<-1> = 'PI-LESS.THAN.ZERO':@VM:PI.Contract.PaymentOrder.PoPaymentAmount
    END
    
    IF PaymentExecutionDate LT todayDate THEN
        ERR.DETS<-1> = 'PI-PMNT.EXEC.DT.LESS.THAN.TODAY':@VM:PI.Contract.PaymentOrder.PoPaymentExecutionDate
    END
    GOSUB MandatoryCheck
    GOSUB DebitIbanCheck
    GOSUB checkOtherID ; *Validation to check other ID mandatory fields
    GOSUB populateContextValue
                
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Mandatory check>
MandatoryCheck:
*** <desc>payment purpose or purpose proprietary should be mandatory </desc>
    IF NOT(paymentPurpose) AND NOT(PurposeProprietary) THEN
        ERR.DETS<-1> = 'PI-PURPOSE.CODE.MISSING':@VM:PI.Contract.PaymentOrder.PoPaymentPurpose
    END ELSE
        GOSUB PurposeOrProprietaryCheck
        GOSUB DropdownValuesCheck
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Purpose or Proprietary check>

PurposeOrProprietaryCheck:
*** <desc>Either of the fields should have value not both </desc>
    IF paymentPurpose AND PurposeProprietary THEN
        ERR.DETS<-1> = 'PI-PURPOSE.CODE.MISSING':@VM:PI.Contract.PaymentOrder.PoPaymentPurpose
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Dropdown Values check>
DropdownValuesCheck:
*** <desc>Payment purpose and purpose proprietary should have values from dropdown only </desc>
    IF paymentPurpose THEN
        IF paymentPurpose MATCHES paymentPurposeArry ELSE
            ERR.DETS<-1> = 'PI-NOT.VALID.PURPOSE':@VM:PI.Contract.PaymentOrder.PoPaymentPurpose
        END
    END
    IF PurposeProprietary THEN
        IF PurposeProprietary MATCHES PurposeProprietaryArry ELSE
            ERR.DETS<-1> = 'PI-VALID.PROP':@VM:PI.Contract.PaymentOrder.PoPurposeProprietary
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Debit Iban Mandatory check>
DebitIbanCheck:
*** <desc>Debit Iban should be mandatory </desc>
    IF debitIban EQ '' THEN
        ERR.DETS<-1> = 'PI-DEBIT.IBAN.MANDATORY':@VM:PI.Contract.PaymentOrder.PoDebitAccountIban
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Populate context value>
populateContextValue:
*** <desc>populate context values based on context names </desc>
    namecnt = 0
    LOOP
        REMOVE cntxtName FROM contextNames SETTING namepos
    WHILE cntxtName:namepos
        namecnt = namecnt + 1
        BEGIN CASE
            CASE cntxtName EQ 'Online Banking'
                R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoContextValue,namecnt> = '1'
            CASE cntxtName EQ 'Mobile Banking'
                R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoContextValue,namecnt> = '2'
            CASE cntxtName EQ 'Phone Banking'
                R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoContextValue,namecnt> = '3'
            CASE cntxtName EQ 'Branch'
                R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoContextValue,namecnt> = '4'
            CASE cntxtName EQ 'Kiosk/ATM'
                R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoContextValue,namecnt> = '5'
            CASE cntxtName EQ 'Corporate'
                R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoContextValue,namecnt> = '6'
        END CASE
                
    REPEAT
RETURN
*** </region>
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

*** <region name= checkOtherID>
checkOtherID:
*** <desc>Validation to check other ID mandatory fields </desc>
    
    IF (orderingBrCity OR orderingBrCntry OR orderingBrPvnc) THEN
        IF orderingDOB EQ '' THEN
            ERR.DETS<-1> = 'PI-ORD.DOB-MANDATORY':@VM:PI.Contract.PaymentOrder.PoOrderingDob ;* ordering DOB is mandatory, when ordering br city or country or pvnc is input
        END
    END
    
    IF orderingOTidType EQ 'PRIVATE' THEN
        IF orderingSchmCode OR orderingSchmPrty OR orderingSchIssr THEN
            IF orderingOTid EQ '' THEN
                ERR.DETS<-1> = 'PI-ORD-OTHER-ID-MADATORY':@VM:PI.Contract.PaymentOrder.PoOrderingOtId
            END
        END
    END
    
    IF BenfcyOTidType EQ 'PRIVATE' THEN
        IF BenfcySchmCode OR BenfcySchmPrty OR BenfcySchIssr THEN
            IF BenfcyOTid EQ '' THEN
                ERR.DETS<-1> = 'PI-ORD-OTHER-ID-MADATORY':@VM:PI.Contract.PaymentOrder.PoBeneficiaryOtId
            END
        END
    END
    
        
    IF uDbtOTidType EQ 'PRIVATE' THEN
        IF uDbtSchmCode OR uDbtSchmPrty OR uDbtSchIssr THEN
            IF uDbtOTid EQ '' THEN
                ERR.DETS<-1> = 'PI-ORD-OTHER-ID-MADATORY':@VM:PI.Contract.PaymentOrder.PoUltimateDebtorOtId
            END
        END
    END
    
    IF uCrdtOTidType EQ 'PRIVATE' THEN
        IF uCrdtSchmCode OR uCrdtSchmPrty OR uCrdtSchIssr THEN
            IF uCrdtOTid EQ '' THEN
                ERR.DETS<-1> = 'PI-ORD-OTHER-ID-MADATORY':@VM:PI.Contract.PaymentOrder.PoUltimateCreditorOtId
            END
        END
    END
    
    
RETURN

*** </region>

END

