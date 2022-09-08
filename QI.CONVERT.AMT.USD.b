* @ValidationCode : MjozMTUzNTgyNDI6Q3AxMjUyOjE2MTYwNjY3MDU0NjM6dmhpbmR1amE6NzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4wOjk2OjYz
* @ValidationInfo : Timestamp         : 18 Mar 2021 16:55:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vhinduja
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 63/96 (65.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE QI.Reporting
SUBROUTINE QI.CONVERT.AMT.USD(CONTRACT.ID, USDB.REC, AMOUNT.TYPE, RES.IN1, USD.AMT.LIST, EXCH.RATE, ERROR.INFO, RES.OUT.1)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 18/02/2021   - Enhancement 4240598  / Task 4240601
*                API is used to covert the amount to USD equivalent
*
* 08/03/2021   - Defect 4272095  / Task 4272715
*                ROUND the Conversion amt and exchange rate
*-----------------------------------------------------------------------------
    $USING QI.Reporting
    $USING ST.ExchangeRate
    $USING SC.Config
    $USING EB.SystemTables
    $USING EB.API
    
    IF NOT(AMOUNT.TYPE) THEN
        ERROR.INFO = "QI-AMOUNT.TYPE.IS.NOT.GIVEN"
        RETURN
    END

    GOSUB INITIALISE ; *
    GOSUB PROCESS.OUT.VALUES ; *
 
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>

*Get the necessary values
    INCOME.CODES = USDB.REC<QI.Reporting.QiUsDbTxDetails.IncomeCode>
    EVENT.CCY = USDB.REC<QI.Reporting.QiUsDbTxDetails.EventCurrency>
 
*Initialise the outgoing arguments
    USD.AMT.LIST = ""
    EXCH.RATE = ""
    ERROR.INFO = ""
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS.OUT.VALUES>
PROCESS.OUT.VALUES:
*** <desc> </desc>

    IF EVENT.CCY EQ "USD" THEN ;*Error if the event currency is  equal to USD
        ERROR.INFO = "EVENT.CURRENCY.SHOULD.NOT.BE.USD"
        RETURN
    END
    
    R.SC.PARAMETER = ""
    SC.ERR = ""
    R.SC.PARAMETER  = SC.Config.Parameter.CacheRead(EB.SystemTables.getIdCompany(), SC.ERR) ;* Reading SC.PARAMETER table with ID as Current Company ID
    IF CONTRACT.ID[1,6] EQ "SCADTX" THEN
        GOSUB GET.ADJ.VALUES ; *
    END ELSE
        INCOME.CODES = USDB.REC<QI.Reporting.QiUsDbTxDetails.IncomeCode>
        GOSUB GET.ENT.VALUES ; *
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GET.ADJ.VALUES>
GET.ADJ.VALUES:
*** <desc> </desc>

*XX-XX-REV.INCOME.AMT.USD
*XX-XX-REV.IC.TAX.AMT.USD
*XX-REV.TOT.IC.INCOME.AMT.USD
*XX-REV.TOT.IC.TAX.AMT.USD

    TOT.RVCNT = DCOUNT(USDB.REC<QI.Reporting.QiUsDbTxDetails.RevReferenceId>,@VM) ;*get the total reference Id
 
    BEGIN CASE
        
        CASE AMOUNT.TYPE EQ "REV.TOT.IC.INCOME.AMT"
            AMT.IN = USDB.REC<QI.Reporting.QiUsDbTxDetails.RevTotIcIncomeAmt,TOT.RVCNT> ;*store the last income amt set
            GOSUB EXCHANGE.RATE ; *
            USD.AMT.LIST = CONV.AMT
        
        CASE AMOUNT.TYPE EQ "REV.TOT.IC.TAX.AMT"
            AMT.IN = USDB.REC<QI.Reporting.QiUsDbTxDetails.RevTotIcTaxAmt,TOT.RVCNT> ;*store the last income amt set
            GOSUB EXCHANGE.RATE ; *
            USD.AMT.LIST = CONV.AMT
                        
        CASE 1

            INCOME.CODES = USDB.REC<QI.Reporting.QiUsDbTxDetails.RevIncomeCode,TOT.RVCNT>

            INCOME.CNT = DCOUNT(INCOME.CODES,@SM)
            FOR CNT = 1 TO INCOME.CNT
        
                BEGIN CASE
                    
                    CASE AMOUNT.TYPE EQ "REV.INCOME.AMT"
        
                        AMT.IN = USDB.REC<QI.Reporting.QiUsDbTxDetails.RevIncomeAmt,TOT.RVCNT,CNT>
        
                    CASE AMOUNT.TYPE EQ "REV.IC.TAX.AMT"
        
                        AMT.IN = USDB.REC<QI.Reporting.QiUsDbTxDetails.RevIcTaxAmt,TOT.RVCNT,CNT>
                
                END CASE
        
                GOSUB EXCHANGE.RATE ; *
        
                
                USD.AMT.LIST<1,1,CNT> = CONV.AMT
               
            NEXT CNT
    
            CONVERT @SM TO "!" IN USD.AMT.LIST
    
    END CASE
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.ENT.VALUES>
GET.ENT.VALUES:
*** <desc> </desc>
    BEGIN CASE
        
        CASE AMOUNT.TYPE EQ "TOT.IC.AMT"
            AMT.IN = USDB.REC<QI.Reporting.QiUsDbTxDetails.TotIcIncomeAmt>
            GOSUB EXCHANGE.RATE ; *
            USD.AMT.LIST = CONV.AMT
        
        CASE AMOUNT.TYPE EQ "TOT.TAX.AMT"
            AMT.IN = USDB.REC<QI.Reporting.QiUsDbTxDetails.TotIcTaxAmt>
            GOSUB EXCHANGE.RATE ; *
            USD.AMT.LIST = CONV.AMT
            
        CASE AMOUNT.TYPE EQ "FATCA.AMT"
            AMT.IN = USDB.REC<QI.Reporting.QiUsDbTxDetails.FatcaTaxAmt>
            GOSUB EXCHANGE.RATE ; *
            USD.AMT.LIST = CONV.AMT
            
        CASE AMOUNT.TYPE EQ "TOT.AMT.PAID"
            AMT.IN = USDB.REC<QI.Reporting.QiUsDbTxDetails.TotAmtPaid>
            GOSUB EXCHANGE.RATE ; *
            USD.AMT.LIST = CONV.AMT
            
        CASE 1

            INCOME.CNT = DCOUNT(INCOME.CODES,@VM)
            FOR CNT = 1 TO INCOME.CNT
        
                BEGIN CASE
                    
                    CASE AMOUNT.TYPE EQ "INCOME.AMT"
        
                        AMT.IN = USDB.REC<QI.Reporting.QiUsDbTxDetails.IncomeAmt,CNT>
        
                    CASE AMOUNT.TYPE EQ "TAX.AMT"
        
                        AMT.IN = USDB.REC<QI.Reporting.QiUsDbTxDetails.IcTaxAmt,CNT>
                
                END CASE
        
                GOSUB EXCHANGE.RATE ; *
        
                
                USD.AMT.LIST<1,CNT> = CONV.AMT
               
            NEXT CNT
    
            CONVERT @VM TO "~" IN USD.AMT.LIST ;* Note : Income amount and tax amount are multi value fields, we should seperate the values by "~"
    
    END CASE
RETURN
*** </region>

*** </region>
*-----------------------------------------------------------------------------
*** <region name= EXCHANGE.RATE>
EXCHANGE.RATE:
*** <desc> </desc>

    CONV.AMT = ""
    EXCH.RATE = ""
    
    IF AMT.IN NE "" AND NOT(AMT.IN) THEN ;* Convereted amount should be zero if AMT.IN is zero
        CONV.AMT = AMT.IN
        RETURN
    END

    CCY.MKT = R.SC.PARAMETER<SC.Config.Parameter.ParamDefaultCcyMarket>
    ST.ExchangeRate.Exchrate(CCY.MKT, EVENT.CCY, AMT.IN, "USD", CONV.AMT, "", EXCH.RATE, "", "", "")
    
    
    EB.API.RoundAmount("USD",CONV.AMT,'','') ;*Round the Conv amount
    
    EB.API.RoundAmount("USD",EXCH.RATE,'','') ;*Round the exchange rate
       
RETURN
*** </region>
END
