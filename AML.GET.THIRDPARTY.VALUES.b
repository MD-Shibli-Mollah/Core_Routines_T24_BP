* @ValidationCode : MjotMjA2MzI3NDQxODpDcDEyNTI6MTYxNjY3NzgxMTQ1MDp2ZWxtdXJ1Z2FuOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4yMDIxMDMwMS0wNTU2Oi0xOi0x
* @ValidationInfo : Timestamp         : 25 Mar 2021 18:40:11
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : velmurugan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*
$PACKAGE VP.Config
SUBROUTINE AML.GET.THIRDPARTY.VALUES(T.BI.ID,FIELD.INFO)
*-----------------------------------------------------------------------------
*A Sample routine released as part of AML profile that can be attached to
*AML.EXTRACT.MAPPING for POR.SUPPLEMENTARY.INFO to fetch the thirdPartyId and thirdPartyName corresponding
*to the transaction number in extracted entry. This can be customised locally as
*per the client requirement.
*-----------------------------------------------------------------------------
*20/11/2020 - Defect 4049223  / Task 4094474
*        - New routine creation
*-----------------------------------------------------------------------------
*
    $USING EB.DataAccess
    $USING PP.PaymentWorkflowDASService
    $USING PP.PaymentWorkflowGUI
    $USING EB.API
       
*
    GOSUB INITIALISE
    GOSUB GET.THIRDPARTY.VALUES
*
RETURN
*
*-----------------------------------------------------------------------------
INITIALISE:
*-----------
*
    R.POR.TRANSACTION = '';*assigning output parameter
    ERR.POR.TRANSACTION = '';*assigning error parameter
    R.POR.SUPPLEMENTARY.INFO='';*assigning output parameter
    R.ERROR='';*assigning error parameter
    partyRoles = ''
    originatorAccount = ''
    benAccount = ''
    benName = ''
    benPos = ''
    paymentDirection = ''
    clearingtransactiontype = ''
    oAdditionalPaymentRecord = ''
    TXN.REF = FIELD(T.BI.ID,'-',2) ;* fetch the transation reference id
    FIELD.INFO = ''
*
RETURN
*
*-----------------------------------------------------------------------------
GET.THIRDPARTY.VALUES:
*---------

    R.POR.TRANSACTION = PP.PaymentWorkflowDASService.PorTransaction.Read(TXN.REF, ERR.POR.TRANSACTION)
    paymentDirection = R.POR.TRANSACTION<PP.PaymentWorkflowDASService.PorTransaction.PpptxPaymentdirection>
    clearingtransactiontype = R.POR.TRANSACTION<PP.PaymentWorkflowDASService.PorTransaction.PpptxClearingtransactiontype>
    
    iTable = 'POR.PARTYCREDIT'
    IF clearingtransactiontype EQ 'CT' AND paymentDirection EQ 'O'  THEN
        GOSUB GET.SUPPLEMENTARY.INFO;*Gosub to get the POR supplementary record
        creditPartyRoles= R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartycredit.Creditpartyrole>;*Retrieve the party roles from POR.SUPPLEMENTARY TABLE
        LOCATE 'BENFCY' IN creditPartyRoles<1,1> SETTING benPos THEN
            GOSUB PARTY.CREDIT.TYPE ; *This gosub fetches the creditParty accountLine and creditPartyName
        END
    END
    
    IF clearingtransactiontype EQ 'DD' AND paymentDirection EQ 'I'  THEN
        GOSUB GET.SUPPLEMENTARY.INFO;*Gosub to get the POR supplementary record
        creditPartyRoles= R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartycredit.Creditpartyrole>;*Retrieve the party roles from POR.SUPPLEMENTARY TABLE
        LOCATE 'ORDPTY' IN creditPartyRoles<1,1> SETTING benPos THEN
            GOSUB PARTY.CREDIT.TYPE ; *This gosub fetches the creditParty accountLine and creditPartyName
        END
    END
    
    iTable = 'POR.PARTYDEBIT'
    IF clearingtransactiontype EQ 'CT' AND paymentDirection EQ 'I'  THEN
        GOSUB GET.SUPPLEMENTARY.INFO;*Gosub to get the POR supplementary record
        debitPartyRoles= R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyrole>;*Retrieve the party roles from POR.SUPPLEMENTARY TABLE
        LOCATE 'ORDPTY' IN debitPartyRoles<1,1> SETTING benPos THEN
            GOSUB PARTY.DEBIT.TYPE ; *This gosub fetches the debit party accountLine and debitPartyName
        END
    END
        
    IF clearingtransactiontype EQ 'DD' AND paymentDirection EQ 'O'  THEN
        GOSUB GET.SUPPLEMENTARY.INFO;*Gosub to get the POR supplementary record
        debitPartyRoles= R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyrole>;*Retrieve the party roles from POR.SUPPLEMENTARY TABLE
        LOCATE 'DEBTOR' IN debitPartyRoles<1,1> SETTING benPos THEN
            GOSUB PARTY.DEBIT.TYPE ; *This gosub fetches the debit party accountLine and debitPartyName
        END
    END
*
RETURN
*
*----------------------------------------------------------------------------
*** <region name= GET.SUPPLEMENTARY.INFO>
GET.SUPPLEMENTARY.INFO:
*----------------------
*
*** <desc>To get por supplementary info record values</desc>
    R.POR.SUPPLEMENTARY.INFO = ''
    Err = ''
    PP.PaymentWorkflowGUI.getSupplementaryInfo(iTable, TXN.REF,'', R.POR.SUPPLEMENTARY.INFO, Err)
*
RETURN
*
*----------------------------------------------------------------------------
*
*** <region name= PARTY.CREDIT.TYPE>
PARTY.CREDIT.TYPE:
*-----------------
*
*** <desc>This gosub fetches the credit party accountLine and creditPartyName </desc>
*
    benAccount  = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartycredit.Creditpartyaccountline,benPos>
    benName =  R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartycredit.Creditpartyname,benPos>
    FIELD.INFO = benAccount:@VM:benName
*
RETURN
*
*** </region>
*
*-----------------------------------------------------------------------------
*
*** <region name= PARTY.DEBIT.TYPE>
*
PARTY.DEBIT.TYPE:
*----------------
*
*** <desc>This gosub fetches the debit party accountLine and debitPartyName </desc>
*
    benAccount  = R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyaccountline,benPos>
    benName =  R.POR.SUPPLEMENTARY.INFO<PP.PaymentWorkflowGUI.PorPartydebit.Debitpartyname,benPos>
    FIELD.INFO = benAccount:@VM:benName
*
RETURN
*
*** </region>
*
*--------------------------------------------------------------------------------
END
