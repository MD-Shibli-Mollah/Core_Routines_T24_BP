* @ValidationCode : MjotOTQ2NTYyNTc6Q3AxMjUyOjE2MTYwNjY3MDU1Mzk6dmhpbmR1amE6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4wOjYxOjQ1
* @ValidationInfo : Timestamp         : 18 Mar 2021 16:55:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vhinduja
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 45/61 (73.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE QI.Reporting
SUBROUTINE QI.GET.JOINT.CUS.TAX.DETAILS(CONTRACT.ID, USDB.REC, RES.IN1, RES.IN2, TAX.RATE.LIST, TAX.DATE.LIST, TAX.AMT.LIST, RES.OUT.1)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 18/02/2021   - Enhancement 4240598  / Task 4240601
*            API to get an Tax details from ST.TAX.REPORT.DETAILS for a respective customer
*
* 08/03/2021   - Defect 4272095  / Task 4272715
*                Get the tax details inorder to populate the fatca related fields
*-----------------------------------------------------------------------------
    $USING QI.Reporting
    $USING CG.ChargeConfig
    $USING EB.SystemTables
    $USING QI.Config

    GOSUB INITIALISE ; *
    GOSUB PROCESS.OUT.VALUES ; *
    IF CONTRACT.ID[1,6] EQ "SCADTX" THEN
        CONVERT @FM TO "!" IN TAX.RATE.LIST
        CONVERT @FM TO "!" IN TAX.DATE.LIST
        CONVERT @FM TO "!" IN TAX.AMT.LIST
    END ELSE
        CONVERT @FM TO "~" IN TAX.RATE.LIST
        CONVERT @FM TO "~" IN TAX.DATE.LIST
        CONVERT @FM TO "~" IN TAX.AMT.LIST
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
    
    TAX.RATE.LIST = ""
    TAX.DATE.LIST = ""
    TAX.AMT.LIST = ""
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS.OUT.VALUES>
PROCESS.OUT.VALUES:
*** <desc> </desc>

    BEGIN CASE
        
        CASE INCOME.CODES

            INCOME.CNT = DCOUNT(INCOME.CODES,@FM)
            FOR CNT = 1 TO INCOME.CNT

                TAX.RATE = ""
                TAX.DATE = ""
                TAX.AMT = ""
        
                FINDSTR "*":INCOME.CODES<CNT> IN TAX.REP.REC<CG.ChargeConfig.TaxReportDetails.TaxRepCustIncomeType> SETTING IncFPos,IncVPos THEN
                    GOSUB GET.TAX.DETAILS ; *
                END
    
                TAX.RATE.LIST<CNT> = TAX.RATE
                TAX.DATE.LIST<CNT> = TAX.DATE
                TAX.AMT.LIST<CNT> = TAX.AMT
               
            NEXT CNT
    
        CASE 1 ;*in case of fatca type contracts
        
            IncVPos = 1
            GOSUB GET.TAX.DETAILS ; *
            TAX.RATE.LIST<1> = TAX.RATE
            TAX.DATE.LIST<1> = TAX.DATE
            TAX.AMT.LIST<1> = TAX.AMT
              
    END CASE
    
RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= GET.TAX.DETAILS>
GET.TAX.DETAILS:
*** <desc> </desc>

    JOINT.CUS.TAX.ID = RAISE(TAX.REP.REC<CG.ChargeConfig.TaxReportDetails.TaxRepJointCustTaxid,IncVPos>)
    FINDSTR CUSTOMER.ID:"*" IN JOINT.CUS.TAX.ID SETTING IncFPos,IncSPos THEN
        TAX.RATE = TAX.REP.REC<CG.ChargeConfig.TaxReportDetails.TaxRepTaxRate,IncVPos,IncSPos>
        TAX.DATE = TAX.REP.REC<CG.ChargeConfig.TaxReportDetails.TaxRepTaxDate,IncVPos,IncSPos>
        TAX.AMT = TAX.REP.REC<CG.ChargeConfig.TaxReportDetails.TaxRepTaxAmtSplit,IncVPos,IncSPos>
        TAX.AMT = TAX.AMT[4,99]
    END
    
RETURN
*** </region>
END
