* @ValidationCode : MjoyNDA0MjU5NTc6Q3AxMjUyOjE2MTQzMjI0Nzg5MTQ6c3ZhbXNpa3Jpc2huYToyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDExLjIwMjAxMDI5LTE3NTQ6Mzk6MzE=
* @ValidationInfo : Timestamp         : 26 Feb 2021 12:24:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : svamsikrishna
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 31/39 (79.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE QI.Reporting
SUBROUTINE QI.GET.JOINT.CUS.INCOME.AMT(CONTRACT.ID, USDB.REC, RES.IN1, RES.IN2, INCOME.AMT.LIST, ERROR.INFO, RES.OUT.1, RES.OUT.2)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 18/02/2021   - Enhancement 4240598  / Task 4240601
*            API to get an Owning amount from ST.TAX.REPORT.DETAILS for a respective customer
*-----------------------------------------------------------------------------
    $USING QI.Reporting
    $USING CG.ChargeConfig
    $USING QI.Config
    $USING EB.SystemTables

    GOSUB INITIALISE ; *
    GOSUB PROCESS.OUT.VALUES ; *
    IF CONTRACT.ID[1,6] EQ "SCADTX" THEN
        CONVERT @FM TO "!" IN INCOME.AMT.LIST
    END ELSE
        CONVERT @FM TO "~" IN INCOME.AMT.LIST
    END

RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>

    TAX.REP.ERR = ""
    IF CONTRACT.ID[1,6] EQ "SCADTX" THEN
        TAX.REP.REC = CG.ChargeConfig.TaxReportDetails.CacheRead(CONTRACT.ID, TAX.REP.ERR)
        TOT.RVCNT = DCOUNT(USDB.REC<QI.Reporting.QiUsDbTxDetails.RevReferenceId>,@VM) ;*get the total reference Id
        INCOME.CODES = USDB.REC<QI.Reporting.QiUsDbTxDetails.RevIncomeCode,TOT.RVCNT>
        CHANGE @SM TO @FM IN INCOME.CODES
        TRIGGER.ID = 'REP*SC.ADJ.TXN.UPDATE*MOD*':FIELD(CONTRACT.ID,".",1):'*':EB.SystemTables.getIdCompany()
        USDB.ID = QI.Config.QcsiTrigger.Read(TRIGGER.ID, '')
        CUSTOMER.ID = FIELD(USDB.ID,"*",1)
    END ELSE
        TAX.REP.REC = CG.ChargeConfig.TaxReportDetails.CacheRead(FIELD(CONTRACT.ID,"*",4), TAX.REP.ERR)
        INCOME.CODES = USDB.REC<QI.Reporting.QiUsDbTxDetails.IncomeCode>
        CUSTOMER.ID = FIELD(CONTRACT.ID,"*",1)
        CHANGE @VM TO @FM IN INCOME.CODES
    END
    
    INCOME.AMT.LIST = ""
    ERROR.INFO = ""
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS.OUT.VALUES>
PROCESS.OUT.VALUES:
*** <desc> </desc>

    INCOME.CNT = DCOUNT(INCOME.CODES,@FM)
    FOR CNT = 1 TO INCOME.CNT
        INCOME.AMT = ""
        FINDSTR "*":INCOME.CODES<CNT> IN TAX.REP.REC<CG.ChargeConfig.TaxReportDetails.TaxRepCustIncomeType> SETTING IncFpos,IncVPos THEN
            CUS.TAX.ID = RAISE(TAX.REP.REC<CG.ChargeConfig.TaxReportDetails.TaxRepJointCustTaxid,IncVPos>)
            FINDSTR CUSTOMER.ID:"*" IN CUS.TAX.ID SETTING IncFpos,IncSPos THEN
                INCOME.AMT = TAX.REP.REC<CG.ChargeConfig.TaxReportDetails.TaxRepOwningAmt,IncVPos,IncSPos>
                INCOME.AMT = INCOME.AMT[4,99]
            END
        END
    
        INCOME.AMT.LIST<CNT> = INCOME.AMT
               
    NEXT CNT
    
RETURN
*** </region>
END
