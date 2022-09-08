* @ValidationCode : MjotMjA3Mzk4ODgzODpDcDEyNTI6MTU5NzMyMDI5NTcxOTptci5zdXJ5YWluYW1kYXI6NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNi4yMDIwMDUyNy0wNDM1OjU4OjU4
* @ValidationInfo : Timestamp         : 13 Aug 2020 17:34:55
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mr.suryainamdar
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 58/58 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPTNCL.Foundation
SUBROUTINE PPTNCL.INWARD.ENRICH.API(ioPaymentObject,orAuditTrailLogFields)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*13/08/2020 - Enhancement 3538767/Task 3808258-Payments-BHTunsian-Clearing specific API
*-----------------------------------------------------------------------------
    $USING PP.MessageMappingService
    $USING PP.PaymentFrameworkService
    $USING ST.Customer
    $USING ST.CompanyCreation
*-----------------------------------------------------------------------------
    GOSUB initialise ;
       
    IF source EQ 'POA' THEN
        GOSUB processPO
    END ELSE
        GOSUB processPH ; *
    END
    
RETURN
*-----------------------------------------------------------------------------
*** <region name= initialise>
initialise:
*** <desc> </desc>
    OrgResidency = ''
    OrgAcctType  = ''
    OrgAcctNature  = ''
    source = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.originatingSource>
    orderingCust = ''
    LocalCountry = ''
    CompanyRec = ''
    CompErr = ''
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= process>
processPO:
*** <desc> </desc>
* Customer id to be fetched from partyCustId under Debit party role ORDPTY
    flag = 1
    countRec = ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty>
    totalRoles = DCOUNT(countRec,@VM)
    LOOP
    WHILE flag LE totalRoles
        IF ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,flag,PP.MessageMappingService.PartyDebit.debitPartyRole> EQ 'ORDPTY' THEN
            orderingCust = ioPaymentObject<PP.MessageMappingService.PaymentObject.debitParty,flag,PP.MessageMappingService.PartyDebit.partyCustId>
            flag = totalRoles
        END
        flag = flag +1
    REPEAT
   
* Read the customer table and fetch value of customer Residence
    rCustomer = ST.Customer.Customer.CacheRead(orderingCust, error)
    CustomerResidence = rCustomer<ST.Customer.Customer.EbCusResidence>
    
* Read the company tabel and fetch value from localCOUNTRY field
    company = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.companyID>
    R.MNEMONIC.COMPANY = ST.CompanyCreation.MnemonicCompany.CacheRead(company, MNEMONIC.COMPANY.ERR) ;* To read F.MNEMONIC.COMPANY table from cache
    compyCode=R.MNEMONIC.COMPANY<ST.CompanyCreation.MnemonicCompany.AcMcoCompany>
    CompanyRec = ST.CompanyCreation.Company.CacheRead(compyCode, CompErr)
    localCountry = CompanyRec<ST.CompanyCreation.Company.EbComLocalCountry>
    
*check if Customer residence and local country matches, if yes map orderingPartyResidImpFlag as R
    IF CustomerResidence EQ localCountry THEN
        ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.orderingPartyResidImpFlag> = 'R'
    END ELSE
        ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.orderingPartyResidImpFlag> = ''
    END
       
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= processPH>
processPH:
*** <desc> </desc>
    totalLocalfFields = DCOUNT(ioPaymentObject<PP.MessageMappingService.PaymentObject.paymentFlowDetails>,@VM) ;* Get the count of local field
    FOR initLocalcount = 1 TO totalLocalfFields
        locFieldName = ioPaymentObject<PP.MessageMappingService.PaymentObject.paymentFlowDetails,initLocalcount,PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName>
        BEGIN CASE
            CASE locFieldName EQ 'OrginatorResidency'
                OrgResidency = ioPaymentObject<PP.MessageMappingService.PaymentObject.paymentFlowDetails,initLocalcount,PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue>
            CASE locFieldName EQ 'OrginatorAcctType'
                OrgAcctType = ioPaymentObject<PP.MessageMappingService.PaymentObject.paymentFlowDetails,initLocalcount,PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue>
            CASE locFieldName EQ 'OrginatorAcctNature'
                OrgAcctNature = ioPaymentObject<PP.MessageMappingService.PaymentObject.paymentFlowDetails,initLocalcount,PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue>
        END CASE
    NEXT initLocalcount
       
    IF  OrgResidency EQ '0' AND OrgAcctType EQ '1' AND OrgAcctNature EQ '0' THEN
        ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.clearingNatureCode> = '0'
    END ELSE
        ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.clearingNatureCode> = '1'
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
END

