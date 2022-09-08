* @ValidationCode : MjoyNTY2MzE2Mzk6Y3AxMjUyOjE1ODAzODMxMzUwNzM6a3JhbWFzaHJpOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTIuMjAxOTExMTktMTMzNDo1MDo0Nw==
* @ValidationInfo : Timestamp         : 30 Jan 2020 16:48:55
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 47/50 (94.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201912.20191119-1334
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE IA.ModelBank
SUBROUTINE E.MB.IFRS.SPLIT.DELTA
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
*
* Modification History :
*
* 18/12/2019 - Enhancement 3271128 / Task 3512468
*             Conversion routine to return the Amortised Fee, Amortised Cost
*             and Amortised Amount seperately
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Reports
    $USING IA.Config
    $USING ST.CompanyCreation
    $USING IA.ModelBank
    $USING CW.CashFlow
     
    GOSUB INITIALISE ; *To initialise required variables
    IF IA.INSTALLED THEN
        GOSUB PROCESS ; *
    END


*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>To initialise required variables </desc>
    
    ContractId = EB.Reports.getOData()
    
    LOCATE "IA" IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING Pos THEN
        IA.INSTALLED = 1
    END
    VM.CNT = 1
    FEE.CNT = 0
    COST.CNT = 0
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Returns Amortised Amount, Amortised Fee, Amortised Cost </desc>
    RIfrsAcctBalances = IA.Config.IfrsAcctBalances.Read(ContractId,AcctBalancesErr)
    REbCashflow = CW.CashFlow.EbCashflow.Read(ContractId,EbCashflowErr)
    
    IF EbCashflowErr EQ "" AND AcctBalancesErr EQ "" THEN ;*Process Only when AcctBalances and EbCashflows are available
        FeeProperty = RAISE(REbCashflow<CW.CashFlow.EbCashflow.CshfFeeProperty>)
        FeePropertyCount = DCOUNT(FeeProperty,@FM)
        FeeAmount = RAISE(REbCashflow<CW.CashFlow.EbCashflow.CshfFeeAmount>)
        AcctHeadTypes = RAISE(RIfrsAcctBalances<IA.Config.IfrsAcctBalances.IfrsAcctBalAcctHeadType>)
             
        AcctBalances = RAISE(RIfrsAcctBalances<IA.Config.IfrsAcctBalances.IfrsAcctBalBalance>)
  
        LastCalcBal = RAISE(RIfrsAcctBalances<IA.Config.IfrsAcctBalances.IfrsAcctBalLastCalcAmt>)
          
        FOR PropertyPos = 1 TO FeePropertyCount
            LOCATE "AMORTISED":"-":FeeProperty<PropertyPos> IN AcctHeadTypes SETTING AcctHeadPos THEN
                IF FeeAmount<PropertyPos> LT 0 THEN ;*Cost is negative
                    R.RECORD<1,-1> = AcctHeadTypes<AcctHeadPos>
                    R.RECORD<2,-1> = AcctBalances<AcctHeadPos> + LastCalcBal<AcctHeadPos>
                    COST.CNT + =1
                END ELSE ;*Fee details
                    R.RECORD<3,-1> = AcctHeadTypes<AcctHeadPos>
                    R.RECORD<4,-1> = AcctBalances<AcctHeadPos> + LastCalcBal<AcctHeadPos>
                    FEE.CNT + =1
                END
            END
        NEXT PropertyPos
          
    END
    
    LOCATE "AMORTISED" IN AcctHeadTypes<1> SETTING AcctHeadPos THEN
        R.RECORD<5> = "AMORTISED"
        R.RECORD<6> = AcctBalances<AcctHeadPos> + LastCalcBal<AcctHeadPos>
    END
    
    IF FEE.CNT > COST.CNT THEN
        VM.CNT = FEE.CNT
    END ELSE
        VM.CNT = COST.CNT
    END
    IF NOT(VM.CNT) THEN
        VM.CNT =1
    END
    EB.Reports.setVmCount(VM.CNT)
    EB.Reports.setRRecord(R.RECORD)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END


