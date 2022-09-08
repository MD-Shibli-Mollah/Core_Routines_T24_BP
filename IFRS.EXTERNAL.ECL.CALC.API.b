* @ValidationCode : Mjo1OTk3ODY0OTE6Y3AxMjUyOjE1ODAzODMxODU3NDc6a3JhbWFzaHJpOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkxMi4yMDE5MTExOS0xMzM0Oi0xOi0x
* @ValidationInfo : Timestamp         : 30 Jan 2020 16:49:45
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201912.20191119-1334
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE I9.Config
SUBROUTINE IFRS.EXTERNAL.ECL.CALC.API(TARRAY,PDS,LGDS,R.EB.CASHFLOW.VAL,CON.CASHFLOW.DATE, CON.CASHFLOW.AMT,EXP.CASHFLOW.AMT ,CON.NPV,EXP.NPV, tECL ,ECL.FLAG,TERROR)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
*Incoming param:
*-------------------
* TARRAY<1>   - CashflowId
* TARRAY<2>   - CustomerId
* TARRAY<3>   - Period End Date
* TARRAY<4>   - Seperated by valueMarkers and it contains the RATE Values of the contract based on npv rate.
*  *TARRAY<4,1> - Either EIR or Marketkey
*  *TARRAY<4,2> - MarginOperand
*  *TARRAY<4,3> - MarketMargin
*  *TARRAY<4,4> - Either B(BID) or O(OFFER)
* TARRAY<5>   - Seperated by valueMarkers and it contains InterestBasis
*  *TARRAY<5,1> - InterestBasis
*  *TARRAY<5,2> - Currency
* TARRAY<6>   - Present Stage of the Contract.
* TARRAY<7> - Past Due amount
*
* PDS               - All PD's specified in Application level for the Contract.
* LGDS              - Loss Given Default specified in Application level for the contract.
* CON.CASHFLOW.DATE - Contractual Cashflow Dates
* CON.CASHFLOW.AMT  - Contractual Cashflow Amounts
* ECL.FLAG          - Either 'ACTUAL.ECL' or 'PROJECTED.ECL'(ACTUAL.ECL represent to calculate the ECL for current period and PROJECTED.ECL represent to calcuate the ECL for future)
*
*
*Outgoing param:
*-------------------
* EXP.CASHFLOW.AMT - Calculated Expected Cashflow Amounts.
* CON.NPV          - Calculated Contractual Net Present Value.
* EXP.NPV          - Calculated Expected Net Present Value.
* tECL             - Calculated Expected Credit loss
* TERROR           - Any Error to be thrown
*
*
* Modification History :
* 30/12/17 - Defect 2378810 / Task 2399124
*            IFRS9 - IFRS.PARAMETER - OPENING THE FIELD FOR API
*
* 02/12/19 - SI 3345513 / Task 3463607
*            Changes with respect to movement of cashflow from IA to CW module.
*-----------------------------------------------------------------------------
    $USING I9.Valuation
    $USING CW.CashFlow
    $USING EB.API
    $USING I9.Config
    $USING EB.SystemTables
    $USING ST.CompanyCreation

*-----------------------------------------------------------------------------

    GOSUB INITIALISE               ;* Initialise required variables
    GOSUB VALIDATE.CASHFLOW.DATES
    GOSUB PROCESS                  ;* Main Process
    GOSUB NPV.EXPECTED             ; * get Npv of expected cashflow
    GOSUB NPV.CONTRACTUAL          ; * get Npv of contractual cashflow
    GOSUB CALC.ECL                 ; * Calculate expected credit loss


RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    
    CON.CASHFLOW = ""
    CON.CASHFLOW.DATES = ""
    CON.CASHFLOW = CON.CASHFLOW.AMT
    CON.CASHFLOW.DATES = CON.CASHFLOW.DATE
    
    
    currentCompany = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialCom)
    R.IFRS.PARAMETER = ''
    fInfrsParameter = ''
    errIfrsParameter = ''
    ParamId = currentCompany
   
* API called to read the parameter file record from the table IFRS.PARAMETER
    ST.CompanyCreation.EbReadParameter('F.IFRS.PARAMETER', 'N', '', R.IFRS.PARAMETER, ParamId, fInfrsParameter, errIfrsParameter)
    
    PD.PER.NUM = ""
    LGD.PER.NUM = ""
    
    PD.PER.NUM = R.IFRS.PARAMETER<I9.Config.IfrsParameter.I9ParPdValFmt>
    LGD.PER.NUM = R.IFRS.PARAMETER<I9.Config.IfrsParameter.I9ParLgdValFmt>
    
    CONTRACT.ID = TARRAY<1>
    CUSTOMER = TARRAY<2>
    tStartDate = TARRAY<3>
    tRate = RAISE(TARRAY<4>)
    tIntBasis = RAISE(TARRAY<5>)
    PRESENT.STAGE = TARRAY<6>
    PAST.DUE.BAL = TARRAY<7>
    
    CON.CCY = R.EB.CASHFLOW.VAL<CW.CashFlow.EbCashflow.CshfCurrency>
    START.DATE = R.EB.CASHFLOW.VAL<CW.CashFlow.EbCashflow.CshfValueDate>
    PdReqDate = R.EB.CASHFLOW.VAL<CW.CashFlow.EbCashflow.CshfNextReviewDate>
    
    IF PAST.DUE.BAL THEN
        IF tStartDate NE CON.CASHFLOW.DATES<1> THEN
            CON.CASHFLOW = PAST.DUE.BAL:@FM:CON.CASHFLOW
            CON.CASHFLOW.DATES = tStartDate:@FM:CON.CASHFLOW.DATES
        END ELSE
            CF.WITH.DUE = PAST.DUE.BAL + CON.CASHFLOW<1> ; * Add the PD amount to the contactual cashflow.
            CON.CASHFLOW<1> = CF.WITH.DUE ; *  Assign the added PD balance to the contractual cashflow array. So that in Expected cashflow this will be automatically considered.
        END
    END
    
    GOSUB GET.CURRENT.PD ;* Get the value of current PD to be populated
    
RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name= GET.CURRENT.PD>
GET.CURRENT.PD:
*** <desc> </desc>
    CUR.PD.VALUE = ""
    CUR.PD.VALUE = PDS
    
    I9.Valuation.IfrsGetCurrentPdValue(START.DATE, PdReqDate,CUR.PD.VALUE,PRESENT.STAGE)

RETURN
*** </region>
*-----------------------------------------------------------------------------
VALIDATE.CASHFLOW.DATES:
*-----------------------
* Validaiotn: Check for equal number of cashflow and dates passed
    NO.OF.CASHFLOW = DCOUNT(CON.CASHFLOW,@FM)
    NO.OF.CASHFLOW.DATES = DCOUNT(CON.CASHFLOW.DATES,@FM)
    IF NO.OF.CASHFLOW NE NO.OF.CASHFLOW.DATES THEN
        TERROR<1> = 'CASHFLOW AND DATES NOT EQUAL'
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= process>
PROCESS:
*** <desc> Main Process </desc>

    FOR CNT = 1 TO NO.OF.CASHFLOW

        BEGIN CASE
            CASE PD.PER.NUM EQ "PERCENTAGE" AND LGD.PER.NUM EQ "PERCENTAGE"
                EXP.CASHFLOW.AMT<CNT> = CON.CASHFLOW<CNT> * (1- (CUR.PD.VALUE/100)*(LGDS/100))
            CASE PD.PER.NUM EQ "PERCENTAGE" AND LGD.PER.NUM EQ "NUMBER"
                EXP.CASHFLOW.AMT<CNT> = CON.CASHFLOW<CNT> * (1- (CUR.PD.VALUE/100)*(LGDS))
            CASE PD.PER.NUM EQ "NUMBER" AND LGD.PER.NUM EQ "PERCENTAGE"
                EXP.CASHFLOW.AMT<CNT> = CON.CASHFLOW<CNT> * (1- (CUR.PD.VALUE)*(LGDS/100))
            CASE PD.PER.NUM EQ "NUMBER" AND LGD.PER.NUM EQ "NUMBER"
                EXP.CASHFLOW.AMT<CNT> = CON.CASHFLOW<CNT> * (1- (CUR.PD.VALUE)*(LGDS))
        END CASE
        EB.API.RoundAmount(CON.CCY,EXP.CASHFLOW.AMT<CNT>,'','')
    NEXT CNT

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= NPV.EXPECTED>
NPV.EXPECTED:
*** <desc> </desc>

    YCashflows = EXP.CASHFLOW.AMT
    GOSUB NPV.CALC ; *
    VALUE = -NPV
    GOSUB ROUND.VALUE
    NPV.EXPECTED = VALUE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= NPV.CALC>
NPV.CALC:
*** <desc> </desc>
    NPV = ""
    NPV.ERR = ""
    CW.CashFlow.EbCalcNpv(YCashflows, CON.CASHFLOW.DATES, tIntBasis,tRate, tStartDate, NPV, NPV.ERR) ;* get Npv of the passed casflows

RETURN
*** </region>
ROUND.VALUE:

    EB.API.RoundAmount(CON.CCY,VALUE,'','')
RETURN
*-----------------------------------------------------------------------------
*** <region name= NPV.CONTRACTUAL>
NPV.CONTRACTUAL:
*** <desc> </desc>
    YCashflows = CON.CASHFLOW.AMT
    GOSUB NPV.CALC ; *
    VALUE = -NPV
    GOSUB ROUND.VALUE
    NPV.CONTRACTUAL  = VALUE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CALC.ECL>
CALC.ECL:
*** <desc> </desc>
    tECL = NPV.CONTRACTUAL - NPV.EXPECTED
    VALUE =  tECL
    GOSUB ROUND.VALUE
    tECL = VALUE

    CON.NPV = NPV.CONTRACTUAL
    EXP.NPV = NPV.EXPECTED
    TERROR<2> = NPV.ERR

RETURN
*** </region>

END

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
