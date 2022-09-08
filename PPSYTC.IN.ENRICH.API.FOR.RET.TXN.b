* @ValidationCode : Mjo1MTUzMjQ3MTg6Q3AxMjUyOjE1ODcxMjUzMTk4Nzg6c2FybWVuYXM6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMS4yMDE5MTIxMy0wNTQwOjg2Ojgw
* @ValidationInfo : Timestamp         : 17 Apr 2020 17:38:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sarmenas
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 80/86 (93.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191213-0540
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*--------------------------------------------------------------
$PACKAGE PPSYTC.ClearingFramework
SUBROUTINE PPSYTC.IN.ENRICH.API.FOR.RET.TXN(ioPaymentObject,oOutgoingMsgFormat)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*2/3/2020 - Enhancement 3131018/ Task 3130941 - Routine to populate the BENFCY role of the payment with the ORDPTY role details of the original payment.
*2/3/2020 - Enhancement 3131018/ Task 3137821 - Mapping of originalorReturnId for the systac return transaction is handled.
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING PP.PaymentWorkflowGUI
    $INSERT I_PaymentWorkflowDASService_PaymentRecord
    $INSERT I_PaymentWorkflowDASService_PaymentID
    $USING PP.InwardMappingFramework
    $USING PP.PaymentWorkflowDASService
    $USING PP.MessageMappingService
    $USING EB.SystemTables
    
    GOSUB initialise ; *
    GOSUB process ; *
RETURN
*-*----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc> </desc>
    oPaymentRecordOrg=''
    oAdditionalPaymentRecordOrg=''
    txnAmtCurrency=''
    txnAmtOrg=''
    iPaymentID=''
    oPaymentRecord = ''
    oAdditionalPaymentRecord = ''
    oReadErr = ''
    R.POR.SUPPLEMENTARY.INFO = ''


RETURN

*-----------------------------------------------------------------------------
process:
    
    GOSUB getPaymentRecord
    
    IF R.TRANSACTION.CONCAT NE '' THEN
        GOSUB enrichdata ; *
    END
    
    productVAL  = EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts>
    LOCATE "SE" IN productVAL<1,1> SETTING PRO.POS THEN                                                                                 ;*SEAT Check can be performed only when SE module installed. So adding condition to check for SE module availability
        IF (EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfOpConsole> MATCHES 'ON':@VM:'PERFORMANCE':@VM:'TEST') THEN           ;*If Regression environment then
            ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.sendersReferenceIncoming> = ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.transactionReferenceIncoming>
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= process>
enrichdata:
*** <desc> </desc>

    ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.transactionCurrencyCode>=oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionCurrencyCode>
    ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.transactionAmount>=oPaymentRecord<PP.PaymentWorkflowDASService.PaymentRecord.transactionAmount>
    ioPaymentObject<PP.MessageMappingService.PaymentObject.paymentFlowDetails,1,PP.MessageMappingService.PORPmtFlowDetailsList.originalOrReturnId> = R.TRANSACTION.CONCAT<1>
    
    role = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyrole>
    LOCATE 'ORDPTY' IN role<1,1> SETTING POS1 THEN
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyRole>='BENFCY'
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyAccountLine> =  R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaccountline,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyCountry> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartycountry,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyProvinceOfBirth> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyprovinceofbirth,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyCountryOfBirth> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartycountryofbirth,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyCityOfBirth> =  R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartycityofbirth,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyContactEmailAddr> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartycontactemailaddr,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyContactPhone> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartycontactphone,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyContactMobilePhone> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartycontactmobilephone,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyFreeLine1> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyfreeline1,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyRoleIndicator> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyroleindicator,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyInformationTag> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyinformationtag,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyNationalId> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartynationalid,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyIdentifierCode> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyidentifiercode,POS1>
        
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyName> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyname,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyAddressLine1> =  R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaddressline1,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyOrgIdOtherId> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyorgidotherid,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyOrgIdOtherSchCode> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyorgidotherschcode,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyOrgIdOtherSchProp> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyorgidotherschprop,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyOrgIdOtherIssuer> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyorgidotherissuer,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyBirthDate> =  R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartybirthdate,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyPrvIdOtherId> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyprvidotherid,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyPrvIdOtherSchCode> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyorgidotherschcode,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyPrvIdOtherSchProp> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyprvidotherschprop,POS1>
        
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyOrgIdOtherIssuer> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyprvidotherissuer,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyClearingSystemIdCode> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyclearingsystemidcode,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyClearingMemberId> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyclearingmemberid,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyContactNamePrefix> =  R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartycontactnameprefix,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyContactName> =  R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartycontactname,POS1>
       
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyContactFax> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartycontactfax,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyAliasType> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaliastype,POS1>
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyContactOthr> = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartycontactothr,POS1>
                                                      
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
getPaymentRecord:
    
    tagValue= ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.transactionReferenceIncoming>
    R.TRANSACTION.CONCAT = ''
    ERR.CONCAT = ''
    iOriginatingSource=ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.originatingSource>
    IDVAL = tagValue:'-':iOriginatingSource
    PP.InwardMappingFramework.getPORTransactionConcat(IDVAL, R.TRANSACTION.CONCAT, ERR.CONCAT)
    
    IF R.TRANSACTION.CONCAT EQ '' THEN
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyRole>='BENFCY'
        ioPaymentObject<PP.MessageMappingService.PaymentObject.creditParty,1,PP.MessageMappingService.PartyCredit.creditPartyRoleIndicator>='R'
        ioPaymentObject<PP.MessageMappingService.PaymentObject.transaction,1,PP.MessageMappingService.Transaction.transactionCurrencyCode> = 'XAF'
       
    END ELSE
  
        iPaymentID=''
        iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber> = R.TRANSACTION.CONCAT<1>
        iPaymentID<PP.PaymentWorkflowDASService.PaymentID.companyID> = R.TRANSACTION.CONCAT<1>[1,3]
* Read the Payment Details for the Transaction
       
    
        PP.PaymentWorkflowDASService.getPaymentRecord(iPaymentID, oPaymentRecord, oAdditionalPaymentRecord, oReadErr)
        Err = ''
        ftNumber = iPaymentID<PP.PaymentWorkflowDASService.PaymentID.ftNumber>
        iTable = 'POR.PARTYDEBIT'
        PP.PaymentWorkflowGUI.getSupplementaryInfo(iTable, ftNumber,'', R.POR.SUPPLEMENTARY.INFO, Err)
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------

END
