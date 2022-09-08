* @ValidationCode : MjoxMTk4OTY0MTI0OkNwMTI1MjoxNjE0MzIyMTUzODExOnN2YW1zaWtyaXNobmE6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMS4yMDIwMTAyOS0xNzU0OjU0OjQx
* @ValidationInfo : Timestamp         : 26 Feb 2021 12:19:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : svamsikrishna
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 41/54 (75.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE QI.Reporting
SUBROUTINE QI.GET.STATUS.TXN.AND.APPLN.CO(CONTRACT.ID, USDB.REC, MAIN.CUSTOMER, RES.IN3, STATUS.LIST, APPLN.CO.LIST, ERROR.INFO, RES.OUT.3)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 18/02/2021   - Enhancement 4240598  / Task 4240601
*            API to get a QI.STATUS and APPLICATION COUNTRY for a customer
*-----------------------------------------------------------------------------

    $USING QI.Reporting
    $USING CG.ChargeConfig
    $USING QI.Config
    $USING EB.SystemTables
    
    GOSUB INITIALISE ; *
    GOSUB PROCESS.OUT.VALUES
    IF CONTRACT.ID[1,6] EQ "SCADTX" THEN    ;*CONTRACT.ID contains ST.TAX.REPORT.DETAILS id
        CONVERT @FM TO "!" IN APPLN.CO.LIST
        CONVERT @FM TO "!" IN STATUS.LIST
    END ELSE
        CONVERT @FM TO "~" IN APPLN.CO.LIST
        CONVERT @FM TO "~" IN STATUS.LIST
    END

RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    SAVE.HIGH.TAX.CUS = ""
    STATUS.LIST = ""
    APPLN.CO.LIST = ""
    
    TAX.REP.ERR = ""
    IF CONTRACT.ID[1,6] EQ "SCADTX" THEN
        TAX.REP.REC = CG.ChargeConfig.TaxReportDetails.CacheRead(CONTRACT.ID, TAX.REP.ERR)
        TOT.RVCNT = DCOUNT(USDB.REC<QI.Reporting.QiUsDbTxDetails.RevReferenceId>,@VM) ;*get the total reference Id
        INCOME.CODES = USDB.REC<QI.Reporting.QiUsDbTxDetails.RevIncomeCode,TOT.RVCNT>
        CHANGE @SM TO @FM IN INCOME.CODES
        IF NOT(MAIN.CUSTOMER) THEN ;*main customer id is passed in single customer adj rules
            TRIGGER.ID = 'REP*SC.ADJ.TXN.UPDATE*MOD*':FIELD(CONTRACT.ID,".",1):'*':EB.SystemTables.getIdCompany()
            USDB.ID = QI.Config.QcsiTrigger.Read(TRIGGER.ID, '')
            MAIN.CUSTOMER = FIELD(USDB.ID,"*",1)
        END
    END ELSE
        TAX.REP.REC = CG.ChargeConfig.TaxReportDetails.CacheRead(FIELD(CONTRACT.ID,"*",4), TAX.REP.ERR)
        INCOME.CODES = USDB.REC<QI.Reporting.QiUsDbTxDetails.IncomeCode>
        MAIN.CUSTOMER = FIELD(CONTRACT.ID,"*",1)
        CHANGE @VM TO @FM IN INCOME.CODES
    END
    
    QcErr = ""
    QcRec = ""
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS.OUT.VALUES>
PROCESS.OUT.VALUES:
*** <desc> </desc>
    INCOME.CNT = DCOUNT(INCOME.CODES,@FM)
 
    FOR CNT = 1 TO INCOME.CNT
        HIGH.TAX.CUS = ""
        FINDSTR "*":INCOME.CODES<CNT> IN TAX.REP.REC<CG.ChargeConfig.TaxReportDetails.TaxRepCustIncomeType> SETTING IncFPos,IncVPos THEN
            JOINT.CUST.ID = RAISE(TAX.REP.REC<CG.ChargeConfig.TaxReportDetails.TaxRepJointCustTaxid,IncVPos>)
            FINDSTR "HIGHEST" IN JOINT.CUST.ID SETTING IncFPos,IncSPos THEN
                HIGH.TAX.CUS = FIELD(TAX.REP.REC<CG.ChargeConfig.TaxReportDetails.TaxRepJointCustTaxid,IncVPos,IncSPos>,"*",1) ;*get the highest taxed customer incase of joint portfolio
            END ELSE
                HIGH.TAX.CUS = FIELD(USDB.ID,"*",1)
            END
        END ELSE
            HIGH.TAX.CUS = MAIN.CUSTOMER ;*take the customer id directly in case of single customer
        END
           
        IF SAVE.HIGH.TAX.CUS NE HIGH.TAX.CUS AND HIGH.TAX.CUS THEN ;*To avoid multiple read for a same customer continously
            SAVE.HIGH.TAX.CUS = HIGH.TAX.CUS
            QcRec = QI.Config.QiCustomerSupplementaryInfo.Read(HIGH.TAX.CUS, QcErr)
        END
    
        APPLN.CO.LIST<CNT> = QcRec<QI.Config.QiCustomerSupplementaryInfo.QiSiCusApplnCountry>
        STATUS.LIST<CNT> = QcRec<QI.Config.QiCustomerSupplementaryInfo.QiSiCusQiStatus>
        
    NEXT CNT
    
RETURN
*** </region>
END
