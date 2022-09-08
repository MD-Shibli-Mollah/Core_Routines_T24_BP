* @ValidationCode : MjotMTExNTYyODk5NTpDcDEyNTI6MTYxNjA2NjcwNTUwNzp2aGluZHVqYTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjA6MjI6MTk=
* @ValidationInfo : Timestamp         : 18 Mar 2021 16:55:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vhinduja
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 19/22 (86.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE QI.Reporting
SUBROUTINE QI.CALC.TAX.PERCNT(CONTRACT.ID, USDB.REC, RES.IN1, RES.IN2, TAX.PERCENT, ERROR.INFO, RES.OUT.1, RES.OUT.2)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 18/02/2021   - Enhancement 4240598  / Task 4240601
*                API is used to calculate the TAX.PERCENT
*
* 08/03/2021   - Defect 4272095  / Task 4272715
*                ROUND the TAX.PERCENT
*-----------------------------------------------------------------------------
    $USING QI.Reporting
    $USING EB.API
    
*Initialise outgoing arguments
    ERROR.INFO = ""
    TAX.PERCENT = ""
    
    GOSUB PROCESS ; *
    
RETURN

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
*get the necessary values from USDB record
    IF CONTRACT.ID[1,6] EQ "SCADTX" THEN
        TOT.RVCNT = DCOUNT(USDB.REC<QI.Reporting.QiUsDbTxDetails.RevReferenceId>,@VM) ;*get the total reference Id
        TOT.IC.INCOME.AMT = USDB.REC<QI.Reporting.QiUsDbTxDetails.RevTotIcIncomeAmt,TOT.RVCNT> ;*store the last income amt set
        TOT.IC.TAX.AMT= USDB.REC<QI.Reporting.QiUsDbTxDetails.RevTotIcTaxAmt,TOT.RVCNT> ;*store the last income amt set
    END ELSE
        TOT.IC.INCOME.AMT = USDB.REC<QI.Reporting.QiUsDbTxDetails.TotIcIncomeAmt>
        TOT.IC.TAX.AMT = USDB.REC<QI.Reporting.QiUsDbTxDetails.TotIcTaxAmt>
    END
    
    EVENT.CCY = USDB.REC<QI.Reporting.QiUsDbTxDetails.EventCurrency>
    
    GOSUB CALC.AMT ; *
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= CALC.AMT>
CALC.AMT:
*** <desc> </desc>
    IF TOT.IC.INCOME.AMT EQ "" OR TOT.IC.TAX.AMT EQ "" THEN
        ERROR.INFO = "QI-TOT.AMOUNT.NOT.GIVEN"
        RETURN
    END
    TAX.PERCENT = (TOT.IC.TAX.AMT/TOT.IC.INCOME.AMT) * 100
    
    EB.API.RoundAmount(EVENT.CCY,TAX.PERCENT,'','')
    
RETURN
*** </region>

END

