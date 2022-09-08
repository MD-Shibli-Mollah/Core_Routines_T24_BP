* @ValidationCode : Mjo2OTE1NjY2Mjk6Q3AxMjUyOjE2MDMyMDI5MjcyMDk6c2FybWVuYXM6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6LTE6LTE=
* @ValidationInfo : Timestamp         : 20 Oct 2020 19:38:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sarmenas
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PPTNCL.Foundation

SUBROUTINE PPTNCL.ENRICH.OUT.MSG.API(iPaymentDets,iIFEmitDets,oUpdatePaymentObject,oEnrichIFDets, oChangeHistory, ioReserved1, ioReserved2, ioReserved3, ioReserved4, ioReserved5)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*15/09/2020 - Enhancement 3579741/Task 3970816-Payments-BTunisia- CHEQUE OPERATIONS
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING PP.OutwardMappingFramework
    $USING PP.PaymentWorkflowDASService
    $USING PP.PaymentFrameworkService
    $USING PP.OutwardInterfaceService
    
*-----------------------------------------------------------------------------
    CALL TPSLogging("Input Parameter", "PPTNCL.ENRICH.OUT.MSG.API", "iIFEmitDets : <":iIFEmitDets:">", "")

    GOSUB initialise ;
    GOSUB process;
    CALL TPSLogging("OUTPUT Parameter", "PPTNCL.ENRICH.OUT.MSG.API", "oEnrichIFDets : <":oEnrichIFDets:">", "")
    
RETURN
*-----------------------------------------------------------------------------

initialise:
*** <desc> </desc>
    noOfTypes = ''
    noOfaccTypes = ''
    clrgTxnType = ''
    iCompanyId = FIELD(iPaymentDets,'*',1)
    ftNumber = FIELD(iPaymentDets,'*',2)
    iPorTransactionDets = RAISE(iIFEmitDets<3>)
    iPORPmtFlowDetailsList = RAISE(iIFEmitDets<12>)
    iPrtyDbtDetails = RAISE(iIFEmitDets<7>)
    iAccInfoDetails = RAISE(iIFEmitDets<10>)
    
    
    
RETURN

*-----------------------------------------------------------------------------

process:
*** <desc> </desc>
    clrgTxnType = iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.clearingTransactionType>

    IF clrgTxnType EQ 'CD' THEN

        iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PorPaymentFlowDetsforDD.LocFieldName,-1> = 'RELEASE.ON.SYSTEM.DATE'
        iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PorPaymentFlowDetsforDD.LocFieldValue,-1> = '20200417'
        
        iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PorPaymentFlowDetsforDD.LocFieldName,-1> = 'NO.OF.ADDT.RECORDS'
        iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PorPaymentFlowDetsforDD.LocFieldValue,-1> = '01'

        iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PorPaymentFlowDetsforDD.LocFieldName,-1> = 'RANK'
        iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PorPaymentFlowDetsforDD.LocFieldValue,-1> = '02'
        
        iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PorPaymentFlowDetsforDD.LocFieldName,-1> ='OUTWARD.CHEQUE.ISSUE.DATE'
        iPORPmtFlowDetailsList<PP.OutwardInterfaceService.PorPaymentFlowDetsforDD.LocFieldValue,-1> = '20200417'

        noOfaccTypes = DCOUNT(iAccInfoDetails<PP.OutwardInterfaceService.PorAccountInfo.mainOrChargeAccType>,@VM)
        FOR acctype=1 TO noOfaccTypes
            
            IF iAccInfoDetails<PP.OutwardInterfaceService.PorAccountInfo.mainOrChargeAccType,acctype> EQ 'D' THEN
                IF iAccInfoDetails<PP.OutwardInterfaceService.PorAccountInfo.sectorCode,acctype> EQ '' THEN
                    iAccInfoDetails<PP.OutwardInterfaceService.PorAccountInfo.sectorCode,acctype> = '1'
                END
                IF iAccInfoDetails<PP.OutwardInterfaceService.PorAccountInfo.customerID,acctype> EQ '' THEN
            
                    iAccInfoDetails<PP.OutwardInterfaceService.PorAccountInfo.customerID,acctype> = '19000019'
                END
            END
        NEXT acctype
        
       
        noOfTypes = DCOUNT(iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyRole>,@VM)
        FOR type=1 TO noOfTypes
            
            IF iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyRole,type> EQ 'DEBTOR' THEN
                iPrtyDbtDetails<PP.OutwardInterfaceService.PorPartyDebit.dbPtyAliasType,type> = 'C'
            END
        NEXT type
        
        GOSUB updateOutParams
    END
    IF clrgTxnType EQ 'CC' THEN
        iPorTransactionDets<PP.OutwardMappingFramework.PorTransactionForDD.senderChargeAmount2> = '10'
        GOSUB updateOutParams
    END

RETURN
 
*-----------------------------------------------------------------------------
updateOutParams:
*** <desc> </desc>
    iIFEmitDets<12> = LOWER(iPORPmtFlowDetailsList)  ;* the updated POR.SUPPLEMENTARY.INFO is used in EmitDetails
    iIFEmitDets<7> = LOWER(iPrtyDbtDetails)
    iIFEmitDets<10> = LOWER(iAccInfoDetails)
    iIFEmitDets<3> = LOWER(iPorTransactionDets)
    
    oEnrichIFDets =  iIFEmitDets
    CALL TPSLogging("DB Output","PPTNCL.ENRICH.OUT.MSG.API","oEnrichIFDets : <":oEnrichIFDets:">","")

RETURN



END
