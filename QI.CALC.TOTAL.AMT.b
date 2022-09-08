* @ValidationCode : Mjo4MTYyODg3NzA6Q3AxMjUyOjE2MTQzMjIxNTM4NzM6c3ZhbXNpa3Jpc2huYTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDExLjIwMjAxMDI5LTE3NTQ6MjQ6MTY=
* @ValidationInfo : Timestamp         : 26 Feb 2021 12:19:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : svamsikrishna
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 16/24 (66.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE QI.Reporting
SUBROUTINE QI.CALC.TOTAL.AMT(USDB.ID, USDB.REC, AMOUNT.TYPE, RES.IN1, TOTAL.AMOUNT, ERROR.INFO, RES.OUT.1, RES.OUT.2)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 18/02/2021   - Enhancement 4240598  / Task 4240601
*                API is used to calculate the total income amount and tax amount
*-----------------------------------------------------------------------------
    $USING QI.Reporting
       
    GOSUB INITIALISE ; *
    GOSUB PROCESS.OUT.VALUES ; *
         
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>

*Get necessary values
    INCOME.CODES = USDB.REC<QI.Reporting.QiUsDbTxDetails.IncomeCode>
    
    TOTAL.AMOUNT = ""
    ERROR.INFO = ""
           
RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= PROCESS.OUT.VALUES>
PROCESS.OUT.VALUES:
*** <desc> </desc>

    BEGIN CASE
        
        CASE NOT(AMOUNT.TYPE) ;*Error if amount type is not given
            ERROR.INFO = "QI-AMOUNT.TYPE.IS.NOT.GIVEN"
            
        CASE AMOUNT.TYPE EQ "TOT.INCOME.AMT" ;*calculate the total income amount
            TOTAL.AMOUNT = SUM(USDB.REC<QI.Reporting.QiUsDbTxDetails.IncomeAmt>)
        
        CASE AMOUNT.TYPE EQ "TOT.TAX.AMT" ;*calculate the total tax amount
            TOTAL.AMOUNT = SUM(USDB.REC<QI.Reporting.QiUsDbTxDetails.IcTaxAmt>)
        
        CASE AMOUNT.TYPE EQ "REV.TOT.IC.INCOME.AMT"
            TOT.RVCNT = DCOUNT(USDB.REC<QI.Reporting.QiUsDbTxDetails.RevReferenceId>,@VM) ;*get the total reference Id
            REV.AMT.IN = USDB.REC<QI.Reporting.QiUsDbTxDetails.RevIncomeAmt,TOT.RVCNT> ;*store the last income amt set
            TOTAL.AMOUNT = SUM(REV.AMT.IN)
            
        CASE AMOUNT.TYPE EQ "REV.TOT.IC.TAX.AMT"
            TOT.RVCNT = DCOUNT(USDB.REC<QI.Reporting.QiUsDbTxDetails.RevReferenceId>,@VM) ;*get the total reference Id
            REV.AMT.IN = USDB.REC<QI.Reporting.QiUsDbTxDetails.RevIcTaxAmt,TOT.RVCNT> ;*store the last income amt set
            TOTAL.AMOUNT = SUM(REV.AMT.IN)
        
    END CASE

RETURN
*** </region>
END
