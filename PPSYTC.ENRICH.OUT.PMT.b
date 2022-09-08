* @ValidationCode : Mjo0MTgyNjkyNjE6Q3AxMjUyOjE2MTg0ODEyNzA1OTI6c3R1dGkuc2luZ2g6NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4yMDIxMDMwMS0wNTU2OjkyOjU4
* @ValidationInfo : Timestamp         : 15 Apr 2021 15:37:50
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : stuti.singh
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 58/92 (63.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*----------------------------------------------------------------------
$PACKAGE PPSYTC.ClearingFramework
SUBROUTINE PPSYTC.ENRICH.OUT.PMT(iPaymentDets,iIFEmitDets,oUpdatePaymentObject,oEnrichIFDets, oChangeHistory, ioReserved1, ioReserved2, ioReserved3, ioReserved4, ioReserved5)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History
*2/3/2020 - Enhancement 3131018/ Task 3130941 - Routine to Generate 7-digit unique key and assign it to senders reference outgoing.
*24/03/2020 - Enhancement 3540611/Task 3638768- Payments-Afriland - SYSTAC (CEMAC) - Direct Debits
*12/04/2021 - Defect - 4333141 / Task - 4339104 - Regression Fix
*-----------------------------------------------------------------------------
    $USING PP.OutwardMappingFramework
    $USING PP.PaymentWorkflowDASService
    $USING PP.PaymentWorkflowGUI
    $USING PP.LocalClearingService
    $USING PP.PaymentFrameworkService
    $USING PP.DebitPartyDeterminationService
    $USING PP.CreditPartyDeterminationService
    $USING AC.AccountOpening
  
    GOSUB initialise
    GOSUB Process
    GOSUB updatePORTables
    GOSUB updateRIBNumber
    GOSUB enrichChequePmts
    GOSUB outputParams
RETURN

*------------------------------------------------------------------------------------------------------------
initialise:
    
    Record = ''
    ErrConcat = ''
    
    iPorTransactionDets = RAISE(iIFEmitDets<3>)
    IF iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.clearingTransactionType> EQ 'CC' THEN
        iAcctInfDetails = RAISE(iIFEmitDets<10>)
    END ELSE
        iAcctInfDetails = RAISE(iIFEmitDets<8>)
    END
    iPORPmtFlowDetailsList = RAISE(iIFEmitDets<12>)
    iPartyCreditDetails = RAISE(iIFEmitDets<6>)
    ftNumber = FIELDS(iPaymentDets,'*',2)
    
    IBAN.ERR = ''
    R.ALTERNATE.ACCOUNT = ''
    crdtActlength = ''
    creditMainAcct = ''
    
RETURN
*------------------------------------------------------------------------------------------------------------
Process:

    UNIQUE.KEY = ''
    iLockingId = 'PPSYSTC.UNIREF' ;* locking file record id
    iAgentDigits = '2';* length of the seq no from agent's relative position
    iRandomDigitsLen = '5' ;* length of the unique reference number  from locking record
    PPSYTC.ClearingFramework.ppsystcGenerateUniqueReference(iLockingId, iAgentDigits, iRandomDigitsLen,'' ,UNIQUE.KEY,'') ;* this api returns a 7 digit unique reference number
RETURN

*------------------------------------------------------------------------------------------------------------
updatePORTables:

    IF iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.clearingTransactionType> EQ 'CT' OR iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.clearingTransactionType> EQ 'RT' THEN
        iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionDet.sendersReferenceOutgoing> =  UNIQUE.KEY
    END
    
* assign unique Key to sendersReferenceOutgoing for DD and RJ
    IF iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.clearingTransactionType> EQ 'DD' OR iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.clearingTransactionType> EQ 'RJ' THEN
        iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.sendersReferenceOutgoing> =  UNIQUE.KEY
* assign the remittance number to local ref field
        PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.PAYMENTFLOWDETAILS', iFTNumber, 'LOCK', iPORPmtFlowDetailsList, Error)
        iPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,-1> = 'FileRemittanceNumber'
        iPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,-1> = iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.fileReference>
    END
    
    IF iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.outgoingMessageType> EQ 'SYSTACDD' AND iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.clearingNatureCode> EQ 'REP' THEN
        iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.outgoingMessageType> = 'SYTCRDD'
        iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.outgoingMsgType> = 'SYTCRDD'
    END
     
RETURN
*--------------------------------------------------------------------------------------------------------------
updateRIBNumber:
    
    IF iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.clearingTransactionType> EQ 'CC' THEN
        actTypeInd = 'C'
    END ELSE
        actTypeInd = 'D'
    END
  
    LOCATE actTypeInd IN iAcctInfDetails<PP.DebitPartyDeterminationService.AccInfoDetails.mainOrChargeAccType,1> SETTING POS THEN
        accountNumber = iAcctInfDetails<PP.DebitPartyDeterminationService.AccInfoDetails.accountNumber,POS>
        length =  LEN(accountNumber)
        IF length EQ 23 ELSE
            R.ACCOUNT = AC.AccountOpening.Account.Read(accountNumber, Error)
            LOCATE 'RIB' IN  R.ACCOUNT<AC.AccountOpening.Account.AltAcctType,1> SETTING POS1 THEN
                iAcctInfDetails<PP.DebitPartyDeterminationService.AccInfoDetails.accountNumber,POS> = R.ACCOUNT<AC.AccountOpening.Account.AltAcctId,POS1>
                accountNumber = R.ACCOUNT<AC.AccountOpening.Account.AltAcctId,POS1>
            END
        END
    END

RETURN
*--------------------------------------------------------------------------------------------------------------
enrichChequePmts:

    
    IF iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.chequeNumber> NE '' AND (iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.clearingTransactionType> EQ 'CC' OR iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.clearingTransactionType> EQ 'RF') THEN
        chequeNumber = iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.chequeNumber>
        txnAmt = iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.transactionAmount>
        creditMainAcct =  iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.creditMainAccount>
        IF accountNumber NE '' THEN
            creditMainAcct = accountNumber
            iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.creditMainAccount> = accountNumber
        END
        iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.sendersReferenceOutgoing> = chequeNumber:'-':txnAmt:'-':creditMainAcct
* updation of CHEQUE.ISSUE.DATE in outward return transfer is handled

        GOSUB getSupplementaryInfo
        originalorReturnId = R.POR.PAYMENTFLOWDETAILS<PP.PaymentWorkflowGUI.PorPaymentflowdetails.OrgnlOrReturnId>
        IF originalorReturnId NE '' THEN
            ftNumber = originalorReturnId
            GOSUB getSupplementaryInfo
            localFieldName = R.POR.PAYMENTFLOWDETAILS<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldname>
            IF localFieldName NE '' THEN
                LOCATE 'CHEQUE.ISSUE.DATE' IN localFieldName<1,1> SETTING POS THEN
                    iPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldName,-1> = 'CHEQUE.ISSUE.DATE'
                    iPORPmtFlowDetailsList<PP.PaymentFrameworkService.PORPmtFlowDetailsList.localFieldValue,-1> = R.POR.PAYMENTFLOWDETAILS<PP.PaymentWorkflowGUI.PorPaymentflowdetails.Locfieldvalue,POS>
                END
            END
        END
    END
    
RETURN
*--------------------------------------------------------------------------------------------------------------
getSupplementaryInfo:
    
    PP.PaymentWorkflowGUI.getSupplementaryInfo('POR.PAYMENTFLOWDETAILS', ftNumber, 'LOCK', R.POR.PAYMENTFLOWDETAILS, Error)
    
RETURN
*--------------------------------------------------------------------------------------------------------------
outputParams:
   
    iIFEmitDets<3> = LOWER(iPorTransactionDets)  ;* the updated POR.TRANSACTION is used in EmitDetails
    iIFEmitDets<8> = LOWER(iAcctInfDetails)
    iIFEmitDets<12> = LOWER(iPORPmtFlowDetailsList)
    oEnrichIFDets =  iIFEmitDets
    oChangeHistory = 'Updated Senders Reference Outgoing and Unique Trace Number by Outward Mapping'  ;* to be updated in History Log
RETURN
*--------------------------------------------------------------------------------------------------------------
END
