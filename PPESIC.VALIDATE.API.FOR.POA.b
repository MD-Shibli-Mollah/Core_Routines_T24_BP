* @ValidationCode : MjotMjAyNDQwODg5NDpDcDEyNTI6MTYxMjAxMjgxOTc1OTpzaGFybWFkaGFzOjEwOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTI3LTA0MzU6MjU4OjIwMQ==
* @ValidationInfo : Timestamp         : 30 Jan 2021 18:50:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sharmadhas
* @ValidationInfo : Nb tests success  : 10
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 201/258 (77.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
$PACKAGE PPESIC.Foundation
SUBROUTINE PPESIC.VALIDATE.API.FOR.POA(PO.ID,R.PAYMENT.ORDER,COMP.ID,RESERVED.IN,SUXS.FAIL,ERR.DETS,RESERVED.OUT)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
* 23/10/2020 - Enhancement 4004713 - Task - Validation for EuroSIC PO
* 04/01/2020 - Defect 4137088 - Task 4138076 - Validation for EuroSIC PO
* 08/01/2020 - Defect 4158352 - Task 4169773 - Category Purp code / prop validation removed, handled at Application level.
* 29/01/2021 - Task 4199679 - Account Number mandating for SEPPMT is removed.
*-----------------------------------------------------------------------------
    $USING PI.Contract
*-----------------------------------------------------------------------------

    GOSUB initialise
    GOSUB process
*-----------------------------------------------------------------------------
initialise:
    orderType               = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderType>
    benIban                 = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryIban>
    benBic                  = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryBic>
    benName                 = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryName>
    benTownName             = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryTownName>
    benStreetName           = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryStreetName>
    benBuildingNum          = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryBuildingNumber>
    benPostCode             = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryPostCode>
    benCountry              = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryCountryCode>
    benAdddress             = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBenPostSwiftAddr>
    benAccNum               = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryAccountNo>
    beneficiaryOtIdType     = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryOtIdType>
    ordCusAcc               = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingCustomerAccount>
    ordCusBic               = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingCustomerBic>
    ordCusName              = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingCustName>
    ordCusName              = TRIM (ordCusName,' ','D')          ;* Removes the extra spaces
    ordCusTownName          = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingCustomerTownName>
    ordCusStreetName        = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingStreetName>
    ordCusBuildingNum       = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingBuildingNumber>
    ordCusPostCode          = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingPostCode>
    ordCusCountry           = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingCountryResidence>
    ordCusAddress           = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingPostSwiftAddr>
    ordOthIdType            = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingOtIdType>
    instCode                = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoInstructionCode>
    instCodeText            = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoInstructionCodeText>
    categoryPurp            = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoPaymentCategory>
    categoryPurpprt         = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoPaymentCategPurpPrty>
    payementPurpose         = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoPaymentPurpose>
    paymentpurpprt          = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoPurposeProprietary>
    ultimateDebtorBic = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorBic>
    ultimateDebtorName = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorName>
    ultimateDebtorTownName = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorTownName>
    ultimateDebtorCountry = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorCountry>
    ultimateDebtorAddrType = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorAddrType>
    ultimateDebtorAddrLine = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorAddrLine>
    ultimateDebtorDob = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorDob>
    ultimateDebtorBrPrvnc = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorBrPrvnc>
    ultimateDebtorBrCity = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorBrCity>
    ultimateDebtorOtIdType = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorOtIdType>
    ultimateDebtorOtId = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorOtId>
    ultimateDebtorSchmeCde = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorSchmeCde>
    ultimateDebtorSchPrty = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorSchPrty>
    ultimateDebtorSchIssur = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorSchIssur>
    ultimateDebtorBrCountry = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorBrCountry>
    ultimateDebtorLei = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateDebtorLei>
    ultimateDebtorStreetNm = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUlimateDebtorStreetName>
    ultimateDebtorBuldNm = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUlimateDebtorBuildingNumber>
    ultimateDebtorPstCd = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUlimateDebtorPostCode>
    ultimateCreditorBic = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorBic>
    ultimateCreditorName = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorName>
    ultimateCreditorTownName = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorTownName>
    ultimateCreditorCountry = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorCountry>
    ultimateCreditorAddrType = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorAddrType>
    ultimateCreditorAddrLine = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorAddrLine>
    ultimateCreditorDob = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorDob>
    ultimateCreditorBrPrvnc = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorBrPrvnc>
    ultimateCreditorBrCity = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorBrCity>
    ultimateCreditorBrCountry = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorBrCountry>
    ultimateCreditorOtIdType = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorOtIdType>
    ultimateCreditorOtId = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorOtId>
    ultimateCreditorSchmeCde = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorSchmeCde>
    ultimateCreditorSchPrty = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorSchPrty>
    ultimateCreditorSchIssur = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorSchIssur>
    ultimateCreditorLei = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUltimateCreditorLei>
    ultimateCreditorStreetNm = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUlimateCreditorStreetName>
    ultimateCreditorBuldNm = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUlimateCreditorBuildingNumber>
    ultimateCreditorPstCd = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoUlimateCreditorPostCode>
    instCodeCount           = DCOUNT(R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoInstructionCode>,@VM)
    orderingOtIdType = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingOtIdType>
    orderingDob = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingDob>
    orderingProvince = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingBrPrvnc>
    orderingCity = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingBrCity>
    orderingCountry = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderingBrCountry>
    orderingimpsdflag = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoImposeDebtorDetails>
    count                   = 1
    cnt                     = 1
    
RETURN
*-----------------------------------------------------------------------------
process:

    BEGIN CASE
* Validations specific to euroSIC Customer Transfer
        CASE orderType EQ 'Customer'
            GOSUB commanvalidation
            IF paymentType EQ '' THEN
                R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoLocalInstrProp>  = 'CSTPMT'
            END
        
            IF  ordOthIdType EQ 'PRIVATE' AND benBic NE '' THEN
                ERR.DETS<-1> = 'PI-ORDERING.ID.PRIVATE':@VM:PI.Contract.PaymentOrder.PoBeneficiaryBic
            END
        
*If Ordering Birth Date or Ordering Birth Province or Ordering Birth City or Ordering Birth Country is present, then Ordering Other Identifier Type must be set to Private
*Otherwise error will be displayed in the screen
            IF orderingOtIdType EQ 'ORGANISATION' THEN
                IF orderingDob NE '' THEN
                    ERR.DETS<-1> = 'PI-ORDERING.ID.TYPE.PRIVATE':@VM:PI.Contract.PaymentOrder.PoOrderingDob
                END
                IF orderingProvince NE '' THEN
                    ERR.DETS<-1> = 'PI-ORDERING.ID.TYPE.PRIVATE':@VM:PI.Contract.PaymentOrder.PoOrderingBrPrvnc
                END
                IF orderingCity NE '' THEN
                    ERR.DETS<-1> = 'PI-ORDERING.ID.TYPE.PRIVATE':@VM:PI.Contract.PaymentOrder.PoOrderingBrCity
                END
                IF orderingCountry NE '' THEN
                    ERR.DETS<-1> = 'PI-ORDERING.ID.TYPE.PRIVATE':@VM:PI.Contract.PaymentOrder.PoOrderingBrCountry
                END
            END
     
            GOSUB ultimate.Dbtr.Cdtr.Validate

*Looping each value of Instruction Code
            LOOP
            WHILE cnt LE instCodeCount
                a = instCode<1,cnt>
*Allowed values for Instruction code are PHOB,CHQB,HOLD,TELB.
*If any value other than allowed value is entered then error should be thrown.
                IF instCode<1,cnt> NE 'PHOB' AND instCode<1,cnt> NE 'CHQB' AND instCode<1,cnt> NE 'HOLD' AND instCode<1,cnt> NE 'TELB' THEN
                    ERR.DETS<-1> = 'PI-INVALID.INSTRUCTION.CODE':@VM:PI.Contract.PaymentOrder.PoInstructionCode:@VM:cnt
                END
                cnt = cnt + 1
            REPEAT
* Validations specific to euroSIC Bank Transfer
        CASE orderType EQ 'Bank'
            GOSUB commanvalidation
            IF paymentType EQ '' THEN
                R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoLocalInstrProp>  = 'F2FPMT'
            END
    END CASE
        
RETURN
*-----------------------------------------------------------------------------
ultimate.Dbtr.Cdtr.Validate:
* Validation for Ultimate Debtor and Ultimate creditor Fields for customer transfer
* If any of the Ultimate Debtor/Creditor details are entered, then below combinations to be checked for both
* Name, TownName and Country should be present or Bic should be present

    IF R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderType> EQ 'CUSTOMER' OR R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoOrderType> EQ 'Customer' THEN
        IF ultimateDebtorBic NE '' OR ultimateDebtorName NE '' OR ultimateDebtorTownName NE '' OR ultimateDebtorStreetNm NE '' OR ultimateDebtorBuldNm NE '' OR ultimateDebtorPstCd NE '' OR ultimateDebtorCountry NE '' OR ultimateDebtorAddrType NE '' OR ultimateDebtorAddrLine NE '' OR ultimateDebtorDob NE '' OR ultimateDebtorBrPrvnc NE '' OR ultimateDebtorBrCity NE '' OR ultimateDebtorOtIdType NE '' OR ultimateDebtorOtId NE '' OR ultimateDebtorSchmeCde NE '' OR ultimateDebtorSchPrty NE '' OR ultimateDebtorSchIssur NE '' OR ultimateDebtorBrCountry NE '' OR ultimateDebtorLei NE '' THEN
            IF (ultimateDebtorName EQ '' OR ultimateDebtorTownName EQ '' OR ultimateDebtorStreetNm EQ '' OR ultimateDebtorBuldNm EQ '' OR ultimateDebtorPstCd EQ '' OR ultimateDebtorCountry EQ '') AND (ultimateDebtorBic EQ '') AND (ultimateDebtorName EQ '' OR ultimateDebtorAddrLine EQ '') THEN
                ERR.DETS<-1> = 'PI-ULT.DEBTOR.DETAILS.MISS':@VM:PI.Contract.PaymentOrder.PoUltimateDebtorBic
            END
        END
        IF ultimateCreditorBic NE '' OR ultimateCreditorName NE '' OR ultimateCreditorTownName NE '' OR ultimateCreditorStreetNm NE '' OR ultimateCreditorBuldNm NE '' OR ultimateCreditorPstCd NE '' OR ultimateCreditorCountry NE '' OR ultimateCreditorAddrType NE '' OR ultimateCreditorAddrLine NE '' OR ultimateCreditorDob NE '' OR ultimateCreditorBrPrvnc NE '' OR ultimateCreditorBrCity NE '' OR ultimateCreditorBrCountry NE '' OR ultimateCreditorOtIdType NE '' OR ultimateCreditorOtId NE '' OR ultimateCreditorSchmeCde NE '' OR ultimateCreditorSchPrty NE '' OR ultimateCreditorSchIssur NE '' OR ultimateCreditorLei THEN
            IF (ultimateCreditorName EQ '' OR ultimateCreditorTownName EQ '' OR ultimateCreditorStreetNm EQ '' OR ultimateCreditorBuldNm EQ '' OR ultimateCreditorPstCd EQ ''  OR ultimateCreditorCountry EQ '') AND (ultimateCreditorBic EQ '') AND (ultimateCreditorName EQ '' OR ultimateCreditorAddrLine EQ '') THEN
                ERR.DETS<-1> = 'PI-ULT.CREDITOR.DETAILS.MISS':@VM:PI.Contract.PaymentOrder.PoUltimateCreditorBic
            END
        END
    END

*If Ultimate Debtor BIC or Ultimate Debtor LEI is present, then Ultimate Debtor Other Identifier Type must be set to Organisation
*Otherwise error will be displayed in the screen
    IF ultimateDebtorOtIdType EQ 'PRIVATE' THEN
        IF (ultimateDebtorBic NE '') THEN
            ERR.DETS<-1> = 'PI-ULT.DBT.ID.TYPE.ORGANISATION':@VM:PI.Contract.PaymentOrder.PoUltimateDebtorBic
        END

        IF (ultimateDebtorLei NE '') THEN
            ERR.DETS<-1> = 'PI-ULT.DBT.ID.TYPE.ORGANISATION':@VM:PI.Contract.PaymentOrder.PoUltimateDebtorLei
        END
    END
*If Ultimate Creditor BIC or Ultimate Creditor LEI is present, then Ultimate Creditor Other Identifier Type must be set to Organisation
*Otherwise error will be displayed in the screen
    IF ultimateCreditorOtIdType EQ 'PRIVATE' THEN
        IF (ultimateCreditorBic NE '') THEN
            ERR.DETS<-1> = 'PI-ULT.CDT.ID.TYPE.ORGANISATION':@VM:PI.Contract.PaymentOrder.PoUltimateCreditorBic
        END

        IF (ultimateCreditorLei NE '') THEN
            ERR.DETS<-1> = 'PI-ULT.CDT.ID.TYPE.ORGANISATION':@VM:PI.Contract.PaymentOrder.PoUltimateCreditorLei
        END
    END
*If Ultimate Debtor Ordering Birth Date or Ultimate Debto Ordering Birth Province or Ultimate Debto Ordering Birth City or Ultimate Debto Ordering Birth Country is present, then Ultimate Debto Ordering Other Identifier Type must be set to Private
*Otherwise error will be displayed in the screen
    IF ultimateDebtorOtIdType EQ 'ORGANISATION' THEN
        IF ultimateDebtorDob NE '' THEN
            ERR.DETS<-1> = 'PI-ULTDBT.ID.TYPE.PRIVATE':@VM:PI.Contract.PaymentOrder.PoUltimateDebtorDob
        END
        IF ultimateDebtorBrPrvnc NE '' THEN
            ERR.DETS<-1> = 'PI-ULTDBT.ID.TYPE.PRIVATE':@VM:PI.Contract.PaymentOrder.PoUltimateDebtorBrPrvnc
        END
        IF ultimateDebtorBrCity NE '' THEN
            ERR.DETS<-1> = 'PI-ULTDBT.ID.TYPE.PRIVATE':@VM:PI.Contract.PaymentOrder.PoUltimateDebtorBrCity
        END
        IF ultimateDebtorBrCountry NE '' THEN
            ERR.DETS<-1> = 'PI-ULTDBT.ID.TYPE.PRIVATE':@VM:PI.Contract.PaymentOrder.PoUltimateDebtorBrCountry
        END
    END
       
*If Ultimate Creditor Ordering Birth Date or Ultimate Creditor Ordering Birth Province or Ultimate Creditor Ordering Birth City or Ultimate Creditor Ordering Birth Country is present, then Ultimate Creditor Ordering Other Identifier Type must be set to Private
*Otherwise error will be displayed in the screen
    IF ultimateCreditorOtIdType EQ 'ORGANISATION' THEN
        IF ultimateCreditorDob NE '' THEN
            ERR.DETS<-1> = 'PI-ULTCRD.ID.TYPE.PRIVATE':@VM:PI.Contract.PaymentOrder.PoUltimateCreditorDob
        END
        IF ultimateCreditorBrPrvnc NE '' THEN
            ERR.DETS<-1> = 'PI-ULTCRD.ID.TYPE.PRIVATE':@VM:PI.Contract.PaymentOrder.PoUltimateCreditorBrPrvnc
        END
        IF ultimateCreditorBrCity NE '' THEN
            ERR.DETS<-1> = 'PI-ULTCRD.ID.TYPE.PRIVATE':@VM:PI.Contract.PaymentOrder.PoUltimateCreditorBrCity
        END
        IF ultimateCreditorBrCountry NE '' THEN
            ERR.DETS<-1> = 'PI-ULTCRD.ID.TYPE.PRIVATE':@VM:PI.Contract.PaymentOrder.PoUltimateCreditorBrCountry
        END
    END
RETURN
*-----------------------------------------------------------------------------
commanvalidation:
* currency should be EUR only.
    IF R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoPaymentCurrency> NE 'EUR' THEN
        ERR.DETS<-1> = 'PI-INVALID.CURRENCY.FOR.THIS.PRODUCT':@VM:PI.Contract.PaymentOrder.PoPaymentCurrency ;* The corresponding error will be picked from populate error routine which is handled in the core
    END
* Proprietory value should always be LSVBDD
    IF (R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoRefDocInfTpCdOrProp> NE 'LSVBDD') AND (R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoRefDocInfTpCdOrProp> NE '') THEN
        ERR.DETS<-1> = 'PI-PROP.PERMITTED.VALUE':@VM:PI.Contract.PaymentOrder.PoRefDocInfTpCdOrProp ;* The corresponding error will be picked from populate error routine which is handled in the core
    END
* Validation for Beneficiary side
    BEGIN CASE
* If Beneficiary Account Number and Beneficiary IBAN are not present then system should throw an error
        CASE (benIban NE '' AND   benAccNum NE '')
            ERR.DETS<-1> = 'PI-BENEFICIARY.IBAN.OR.ACCNUM.NOTALLOWED':@VM:PI.Contract.PaymentOrder.PoBeneficiaryIban
* If Beneficiary Iban is entered then along with Iban either Bic or combination of name, TownName and country or Combination of Name and Address should be present
        CASE benIban NE ''
            IF (benBic EQ '') AND (benName EQ '' OR benTownName EQ '' OR benStreetName EQ '' OR benBuildingNum EQ '' OR benPostCode EQ '' OR benCountry EQ '') AND (benName EQ '' OR benAdddress EQ '') THEN
                ERR.DETS<-1> = 'PI-BENEFICIARY.IBAN.MISSING':@VM:PI.Contract.PaymentOrder.PoBeneficiaryBic
            END
* If Beneficiary Account Number is entered then along with account Number either Bic or combination of name, TownName and country or Combination of Name and Address should be present
        CASE benAccNum NE ''
            IF (benBic EQ '') AND (benName EQ '' OR benTownName EQ '' OR benStreetName EQ '' OR benBuildingNum EQ '' OR benPostCode EQ '' OR benCountry EQ '') AND (benName EQ '' OR benAdddress EQ '') THEN
                ERR.DETS<-1> = 'PI-BENEFICIARY.ACCNUM.MISSING':@VM:PI.Contract.PaymentOrder.PoBeneficiaryBic
            END
    END CASE
     
    IF orderingimpsdflag NE '' THEN
        BEGIN CASE
            CASE ordCusAcc NE ''
                IF (ordCusBic EQ '') AND (ordCusName EQ '' OR ordCusTownName EQ '' OR ordCusStreetName EQ '' OR ordCusBuildingNum EQ '' OR ordCusPostCode EQ '' OR ordCusCountry EQ '') AND (ordCusName EQ '' OR ordCusAddress EQ '') THEN
                    ERR.DETS<-1> = 'PI-ORDPTY.DETAILS.MISSING':@VM:PI.Contract.PaymentOrder.PoOrderingCustomerBic
                END
            
            CASE ordCusBic NE '' OR ordCusName NE '' OR ordCusTownName NE '' OR ordCusStreetName NE '' OR ordCusBuildingNum NE '' OR ordCusPostCode NE '' OR ordCusCountry NE '' OR ordCusName NE '' OR ordCusAddress NE ''
                IF ordCusAcc EQ '' THEN
                    ERR.DETS<-1> = 'PI-ORDPTY.ACC.MISSING':@VM:PI.Contract.PaymentOrder.PoOrderingCustomerAccount
                END
        END CASE
    END
    
*validation for Instruction Code
* This multivalued field can be entered only five times, if entered more than five an error will be thrown
    IF R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoInstructionCode> NE '' THEN
        IF instCodeCount GT 5 THEN
            ERR.DETS<-1> = 'PI-INSTRUCTION.CODES':@VM:PI.Contract.PaymentOrder.PoInstructionCode
        END ELSE
            LOOP
            WHILE count LE instCodeCount
*Validation for instruction code text
*Value for Instruction Code text should be entered only when the value of instruction code is 'PHOB'
                IF instCode<1,count> NE 'PHOB' AND instCodeText<1,count> NE '' THEN
                    ERR.DETS<-1> = 'PI-INFORMATION.TEXT':@VM:PI.Contract.PaymentOrder.PoInstructionCodeText:@VM:count
                END
                count = count + 1
            REPEAT
        END
    END
  
* As R.PAYMENT.ORDER is inout parameter, in PAYMENT.ORDER.VALIDATE Rnew has been set with this R.PAYMENT.ORDER
* Assigning those values to R.PAYMENT.ORDER
    paymentType = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoLocalInstrProp>
    remitInfo = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoRemittanceInformation>
    paymentAmt = R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoPaymentAmount>
    
*GUI Level validations for pacs.008
    IF (paymentType EQ 'SEPPMT') AND (remitInfo EQ 'NOTPROVIDED') AND (paymentAmt GT 999999999.99) THEN
        PI.Contract.PaymentorderPopulateerror('PI-PMT.AMOUNT.LIMIT':@VM:PI.Contract.PaymentOrder.PoPaymentAmount,ErrorReason,'')
    END
    IF (paymentType EQ 'ESRPMT' OR  paymentType EQ 'ESRDEB' OR paymentType EQ 'IPIDEB') AND R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoInstructionIdRef> NE '' THEN
        PI.Contract.PaymentorderPopulateerror('PI-INPUT.NOT.ALLOWED':@VM:PI.Contract.PaymentOrder.PoInstructionIdRef,ErrorReason,'')
    END
    IF (paymentType EQ 'ESRPMT' OR  paymentType EQ 'ESRDEB' OR paymentType EQ 'IPIDEB') AND R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryAccountNo> EQ '' THEN
        PI.Contract.PaymentorderPopulateerror('PI-MANDATORY.FIELD':@VM:PI.Contract.PaymentOrder.PoBeneficiaryAccountNo,ErrorReason,'')
    END
    IF (paymentType EQ 'ESRPMT' OR  paymentType EQ 'ESRDEB') AND R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryIban> NE '' THEN
        PI.Contract.PaymentorderPopulateerror('PI-IBAN.NOT.ALLOWED':@VM:PI.Contract.PaymentOrder.PoBeneficiaryIban,ErrorReason,'')
    END
    IF (paymentType EQ 'IPIDEB' OR paymentType EQ 'SEPPMT') AND R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryIban> EQ '' THEN
        PI.Contract.PaymentorderPopulateerror('PI-MANDATORY.FIELD':@VM:PI.Contract.PaymentOrder.PoBeneficiaryIban,ErrorReason,'')
    END
    IF (paymentType EQ 'ESRPMT' OR  paymentType EQ 'ESRDEB' OR paymentType EQ 'IPIDEB') AND R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoPaymentPurpose> NE '' THEN
        PI.Contract.PaymentorderPopulateerror('PI-INPUT.NOT.ALLOWED':@VM:PI.Contract.PaymentOrder.PoPaymentPurpose,ErrorReason,'')
    END
    IF (paymentType EQ 'ESRPMT' OR  paymentType EQ 'ESRDEB' OR paymentType EQ 'IPIDEB') AND remitInfo EQ '' THEN
        PI.Contract.PaymentorderPopulateerror('PI-MANDATORY.FIELD':@VM:PI.Contract.PaymentOrder.PoRemittanceInformation,ErrorReason,'')
    END
    IF (paymentType EQ 'ESRPMT' OR  paymentType EQ 'ESRDEB' OR paymentType EQ 'IPIDEB') AND R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoStructuredCreditorReference> EQ '' THEN
        PI.Contract.PaymentorderPopulateerror('PI-MANDATORY.FIELD':@VM:PI.Contract.PaymentOrder.PoStructuredCreditorReference,ErrorReason,'')
    END
    IF (paymentType EQ 'SEPPMT' OR paymentType EQ 'CSTPMT' OR  paymentType EQ 'ESRPMT' OR  paymentType EQ 'ESRDEB' OR paymentType EQ 'IPIDEB') AND R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoAdditionalInfo> NE '' THEN
        PI.Contract.PaymentorderPopulateerror('PI-INPUT.NOT.ALLOWED':@VM:PI.Contract.PaymentOrder.PoAdditionalInfo,ErrorReason,'')
    END
    
*GUI Level validations for pacs.009
    IF LEN(R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoEndToEndReference>) GT 16 THEN
        PI.Contract.PaymentorderPopulateerror('PI-LENGTH.CANNOT.EXCEED':@VM:PI.Contract.PaymentOrder.PoEndToEndReference,ErrorReason,'')
    END
    IF (paymentType EQ 'CMPPMT' OR  paymentType EQ 'PPTTSD' OR  paymentType EQ 'SECSTM' OR  paymentType EQ 'EUXSTM' OR  paymentType EQ 'REPSTM' OR  paymentType EQ 'BCMSTM' OR  paymentType EQ 'TCMSTM' OR  paymentType EQ 'POSSTM' OR  paymentType EQ 'STVSTM' OR  paymentType EQ 'VISSTM') AND R.PAYMENT.ORDER<PI.Contract.PaymentOrder.PoBeneficiaryAccountNo> NE '' THEN
        PI.Contract.PaymentorderPopulateerror('PI-INPUT.NOT.ALLOWED':@VM:PI.Contract.PaymentOrder.PoBeneficiaryAccountNo,ErrorReason,'')
    END
    IF (paymentType EQ 'CMPPMT' OR  paymentType EQ 'COVPMT' OR  paymentType EQ 'PPTTSD' OR  paymentType EQ 'SECSTM' OR  paymentType EQ 'EUXSTM' OR  paymentType EQ 'REPSTM' OR  paymentType EQ 'BCMSTM' OR  paymentType EQ 'TCMSTM' OR  paymentType EQ 'POSSTM' OR  paymentType EQ 'STVSTM' OR  paymentType EQ 'VISSTM') AND remitInfo NE '' THEN
        PI.Contract.PaymentorderPopulateerror('PI-INPUT.NOT.ALLOWED':@VM:PI.Contract.PaymentOrder.PoRemittanceInformation,ErrorReason,'')
    END
     
RETURN
*-----------------------------------------------------------------------------
END
