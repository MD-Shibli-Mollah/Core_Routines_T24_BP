* @ValidationCode : MjotMTA5NzMyMTkxMjpjcDEyNTI6MTUzMzczNDExMTQ1OTpwYWRhbWdjOjIyOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgwNy4yMDE4MDYyMS0wMjIxOjMwMjozMDI=
* @ValidationInfo : Timestamp         : 08 Aug 2018 15:15:11
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : padamgc
* @ValidationInfo : Nb tests success  : 22
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 302/302 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201807.20180621-0221
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------------
$PACKAGE AA.Interest
SUBROUTINE MULTI.CURRENCY.WEIGHTED.METHOD( ARRANGEMENT.ID, CUR.PROP, EFFECTIVE.DATE, CURRENCY, CALC.PERIOD, INTEREST.RECORD, INT.DATA)
*----------------MULTI.CURRENCY.WEIGHTED.METHOD-------------------------------------------------------------
**** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
* This is a hook routine implemented for Balance Netting (BN) feature from Nordea.
* Note: 1. This routine is only for recipient Currency Top (CT) and Summary Account (SA) only. (SA will be implemented later).
*       2. before calling this routine, CUSTOM.TYPE, CUSTOM.NAME & CUSTOM.VALUE, should be defined correctly, there is no validation in this L3 routine.
*       3. for recipient CT account, other donors can only be CT account, if any other product other than CT is applied then will come out with un-defined behaviour.
* The returned rate is weighted rate based on the balances from each currency.
* e.g.                | converted Balance (USD)   |  rate   | weighted rate |
*     USD (reference) | 1000                      |  5.0    | 0.83333333
*     EUR             | -2000                     |  10.0   | 3.33333333
*     GBP             | 3000                      |  15.0   | 7.5
*  Total absolute amount = 6000, weighted rate = 11.66666667
* because the routine is giving a period of time, then it may return list of rate plus the corresponding dates,
* which are caused by balance move, currency move, floating rate move... etc
*
*** </region>
*-----------------------------------------------------------------------------
* @access       : private
* @stereotype   : subroutine
* @author       : mghasarouye@temenos.com
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Input
* @param    ARRANGEMENT.ID      Id of the Arrangement for which details are sought
* @param    CUR.PROP            The currenct property for calculating interest rate.
* @param    EffectiveDate       The date on which the activity is run
* @param    Currency            Currency of the arrangement Id
* @param    CalcPeriod          Record Start Date, Start Date of the period and End date of the period for which the rate is requested
* @param    InterestRecord      The interest record for the date will be passed and any information recorded there could be used.
*                               The custom details and values is normally expected to store details useful for the calculation and sometimes it could even be stored in some Local ref

* Output
*
* @param    IntData             Returns the interest related information
*                               <1> contains effective dates on which rate revision has happened till this date in descending order
*                               <2> contains the effective rates as on each of these dates.
*
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History
*
* 17/06/17 - Task : 2165904
*            Enhancement : 2165901
*            Multi-currency part 2, E5: hook routine for Nordea.
*
* 26/07/17 - Task : 2211477
*            Enhancement : 2165901
*            Multi-currency part 2, rework and bugs fix
*
* 22/08/17 - Task : 2236223
*            Enhancement : 2165901
*            Multi-currency part 2, support SA account
*
* 08/01/18 - Task : 2701324
*            Defect : 2698982
*            Add the self arrangement and its source balance when the interest compensation is null
*
* 03/08/18 - Task   - 2329976
*            Enhancement - 2329973
*            Update to support balance conversion market other than default
*
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>

*** </region>
*-----------------------------------------------------------------------------

    $USING AA.Framework
    $USING AA.Interest
    $USING AA.ProductBundle
    $USING AA.ProductFramework
    $USING AA.ProductManagement
    $USING AC.Fees
    $USING EB.SystemTables
    $USING ST.RateParameters
    $USING AC.BalanceUpdates
    $USING EB.API
    $USING AA.Account
    $USING RE.ConBalanceUpdates

*** <region name= Main control>
*** <desc>main control logic in the sub-routine</desc>

    GOSUB INITIALISE
   
    GOSUB MAIN.PROCESS

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>File variables and local variables</desc>
INITIALISE:
    INT.DATA = ''
    IF NOT(EFFECTIVE.DATE) THEN;*If EFFECTIVE.DATE is Null, then it is assumed as system date.
        EFFECTIVE.DATE = EB.SystemTables.getToday()
    END

    UNIQUE.CURRENCIES = ''
    UNIQUE.DATES = ''
    ALL.PRIN.DATA = ''
    RATE.LIST = ''
    ABSOLUTE.BALANCES.AMOUNT = ''
    RET.PRODUCT.ID = ''
    INT.REC.CUSTOM.TYPES = INTEREST.RECORD<AA.Interest.Interest.IntCustomType> ;* expect to be CCY, e.g. USD, GBP ...
    REAL.ACCOUNT = ''
    ALLOW.EXTERN.POSTING = ''
    ALLOW.MULTI.CURRENCY = ''
    AA.Account.GetAccountType(ARRANGEMENT.ID, '', '', EFFECTIVE.DATE, '', REAL.ACCOUNT, ALLOW.EXTERN.POSTING, ALLOW.MULTI.CURRENCY)
    ACCOUNT.ID = ''
    SA.CCY.LIST = ''
    ARR.RECORD = ''
    PROPERTY.LIST = ''
    R.ARR.PRODUCT = ''
    SOURCE.BALANCE = ''
    ACCOUNT.ID = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main process>
*** <desc>main processing block in the sub-routine
*** Get bundle deatils, loop through the periods defined in the bundle details.
*** In each peirod, arrangements list will be provided, because from period to period recipient/donors could updated.
***</desc>
MAIN.PROCESS:

    BEGIN CASE
        CASE ALLOW.MULTI.CURRENCY ;* SA account
            GOSUB PROCESS.SUMMARY.ACCOUNT
            
        CASE REAL.ACCOUNT ;* real account, could be recipient account, bundle details will give more information.
            GOSUB PROCESS.RECIPIENT.ACCOUNT

    END CASE
    
RETURN

*-----------------------------------------------------------------------------
*** <region name= PROCESS.SUMMARY.ACCOUNT>
*** <desc> This routine will process summary account (SA)</desc>
PROCESS.SUMMARY.ACCOUNT:
    
    ALL.PRIN.DATA = ''
    ABSOLUTE.BALANCES.AMOUNT = ''
    UNIQUE.DATES = ''
    UNIQUE.CURRENCIES = ''

    R.ARRANGEMENT = AA.Framework.Arrangement.Read(ARRANGEMENT.ID, READ.ERR)
    LOCATE 'ACCOUNT' IN R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedAppl,1> SETTING POS THEN
        ACCOUNT.ID = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId,POS>
    END
    
*** get source balance
    AA.Framework.GetArrangementProduct(ARRANGEMENT.ID, EFFECTIVE.DATE, ARR.RECORD, RET.PRODUCT.ID, PROPERTY.LIST)
    PRODUCT.ID = RET.PRODUCT.ID<1>
    AA.ProductFramework.GetProductPropertyRecord('PRODUCT', '', PRODUCT.ID, '', '', '', '', EFFECTIVE.DATE, R.ARR.PRODUCT, RET.ERROR)
    AA.Framework.GetPropertyBalance(CUR.PROP, R.ARR.PRODUCT, SOURCE.BALANCE) ;*Get source balance of property, it is only defined in product designer.
    
    RE.ConBalanceUpdates.AcGetEcbInfo(ACCOUNT.ID, "CcyList", SA.CCY.LIST, RET.ERROR) ;* get the list currencies for the SA account
    
    REQD.START.DATE = CALC.PERIOD<1,1>
    REQD.END.DATE = CALC.PERIOD<1,2>
    
    GOSUB GET.SUMMARY.ACCOUNT.BALANCES
    GOSUB CONSOLIDATE.BALANCES
    GOSUB RESOLVE.INTEREST.RATE
        
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.SUMMARY.ACCOUNT.BALANCES>
*** <desc> loop through each currency inside one SA account and get the balances
***        IN: SA.CCY.LIST
***        IN: REQD.START.DATE
***        IN: REQD.END.DATE
***        OUT: ALL.PRIN.DATA: the exchanged balance from each individual currency, with dates info as well
***        OUT: UNIQUE.DATES: the days that there is balance, currency or float rate moves
***        OUT: UNIQUE.CURRENCIES: the currencies should be considerred for calculation.
*** </desc>
GET.SUMMARY.ACCOUNT.BALANCES:

    LOOP
        REMOVE ARR.CURRENCY FROM SA.CCY.LIST SETTING POS   ;* Looping through arrangements on this date
    WHILE ARR.CURRENCY:POS
        ERROR.MESSAGE = ''
        BALANCE.DETAILS = ''          ;* The current balance figure
        REQUEST.TYPE = ""
        REQUEST.TYPE<2> = "ALL"       ;* Include all unauthorised movements;Unauthorised Movements required. Can be ALL, CR, DR
        BALANCE.AMOUNT = 0

        AA.Framework.GetPeriodBalances(ACCOUNT.ID:'*':ARR.CURRENCY, SOURCE.BALANCE, REQUEST.TYPE, REQD.START.DATE, REQD.END.DATE, "", BALANCE.DETAILS, ERROR.MESSAGE);*Get the balance for each of the movement dates
                
        IF NOT(ERROR.MESSAGE) AND BALANCE.DETAILS THEN
            ARRANGEMENT.TYPE = 'SUMMARY.ACCOUNT'
            GOSUB CREATE.DATE.LIST ;* collect the balances information and create the date list according to balance and currency move.
                
            GOSUB INSERT.DATE.DUE.TO.FLOATING.RATE.MOVE ;* in the period, there could be floating rate move if custom.name is defined as floating. need to do date split accordingly.
        END
        
    REPEAT
    SA.CCY.LIST = SA.CCY.LIST
RETURN
*** </region>


*-----------------------------------------------------------------------------
*** <region name= PROCESS.RECIPIENT.ACCOUNT>
*** <desc> </desc>
PROCESS.RECIPIENT.ACCOUNT:
    
    BUNDLE.DETAILS = ""    ;* gets the bundle details from AA.INTEREST.ACCRUALS record
    AA.ProductBundle.GetAccrueBundleDetails(ARRANGEMENT.ID,CUR.PROP,CALC.PERIOD<1,1>,CALC.PERIOD<1,2>,BUNDLE.DETAILS,'','','',RET.ERROR)
    IF BUNDLE.DETAILS EQ "" THEN
        GOSUB FORM.BUNDLE.DETAILS ;* Form Bundedetails when interest compensation is null(No interest on MA)
    END
    BREAK.START.DATE = BUNDLE.DETAILS<1>
    BREAK.END.DATE = BUNDLE.DETAILS<2>
    
    CNT.BREAK.START.DATE = DCOUNT(BREAK.START.DATE,@VM)         ;* Get the total number of start dates for the bundle

    FOR DATE.I = 1 TO CNT.BREAK.START.DATE
        ALL.PRIN.DATA = ''
        ABSOLUTE.BALANCES.AMOUNT = ''
        UNIQUE.DATES = ''
        UNIQUE.CURRENCIES = ''
        REQD.START.DATE = BREAK.START.DATE<1,DATE.I>
        REQD.END.DATE = BREAK.END.DATE<1,DATE.I>
        
        IF NOT(REQD.END.DATE) THEN
            GOSUB DETERMINE.END.DATE        ;*Determine Period End Date if it is NULL
        END
        
        LINKED.ARRANGEMENTS = BUNDLE.DETAILS<3,DATE.I> ;* get the list of arrangements in the bundle
        SOURCE.BALANCE.NAMES = BUNDLE.DETAILS<5,DATE.I>
    
        IF NOT(RET.ERROR) THEN
            GOSUB GET.ARRANGEMENTS.CURRENCY.BALANCES
            GOSUB CONSOLIDATE.BALANCES
            GOSUB RESOLVE.INTEREST.RATE
        
        END
    
    NEXT DATE.I
RETURN
*** </region>


*-----------------------------------------------------------------------------
*** <region name= Determine the end date of period>
DETERMINE.END.DATE:
    REQD.END.DATE = EB.SystemTables.getToday() ;*Anyway get details till TODAY for now.

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= GET.ARRANGEMENTS.CURRENCY.BALANCES>
*** <desc> IN: LINKED.ARRANGEMENTS: list of arrangements
***        IN: REQD.START.DATE
***        IN: REQD.END.DATE
***        OUT: ALL.PRIN.DATA: the exchanged balance from each individual arrangements, with dates info as well
***        OUT: UNIQUE.DATES: the days that there is balance, currency or float rate moves
***        OUT: UNIQUE.CURRENCIES: the currencies should be considerred for calculation. should be both defined in CUSTOM.TYPE and valid CT account with the same currency.
*** Get the converted balance for each arrangement, and create a rate move date list and prepare for balance consolidation afterwards.
*** </desc>
GET.ARRANGEMENTS.CURRENCY.BALANCES:

    LOOP
        REMOVE LINKED.ARRANGEMENT FROM LINKED.ARRANGEMENTS SETTING POS   ;* Looping through arrangements on this date
        REMOVE SOURCE.BALANCE FROM SOURCE.BALANCE.NAMES SETTING POS
    WHILE LINKED.ARRANGEMENT:POS
                
        R.ARRANGEMENT = AA.Framework.Arrangement.Read(LINKED.ARRANGEMENT, READ.ERR)
        LOCATE 'ACCOUNT' IN R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedAppl,1> SETTING POS THEN
            ACCOUNT.ID = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId,POS>
        END
                
        ARR.CURRENCY = R.ARRANGEMENT<AA.Framework.Arrangement.ArrCurrency>        ;* storing currency of arrangement in the list

        ERROR.MESSAGE = ''
        BALANCE.DETAILS = ''          ;* The current balance figure
        REQUEST.TYPE = ""
        REQUEST.TYPE<2> = "ALL"       ;* Include all unauthorised movements;Unauthorised Movements required. Can be ALL, CR, DR
        BALANCE.AMOUNT = 0
            
        AA.Framework.GetPeriodBalances(ACCOUNT.ID, SOURCE.BALANCE, REQUEST.TYPE, REQD.START.DATE, REQD.END.DATE, "", BALANCE.DETAILS, ERROR.MESSAGE);*Get the balance for each of the movement dates
                
        IF NOT(ERROR.MESSAGE) AND BALANCE.DETAILS THEN
            ARRANGEMENT.TYPE = 'RECIPIENT'
            GOSUB CREATE.DATE.LIST ;* collect the balances information and create the date list according to balance and currency move.
                
            GOSUB INSERT.DATE.DUE.TO.FLOATING.RATE.MOVE ;* in the period, there could be floating rate move if custom.name is defined as floating. need to do date split accordingly.
        END
    REPEAT
    LINKED.ARRANGEMENTS = LINKED.ARRANGEMENTS
RETURN
*** </region>


*-----------------------------------------------------------------------------
*** <region name= Create date list>
*** <desc> IN: LINKED.ARRANGEMENTS: list of arrangements
***        IN: REQD.START.DATE
***        IN: REQD.END.DATE
***        OUT: ALL.PRIN.DATA: the exchanged balance from each individual arrangements, with dates info as well
***        OUT: UNIQUE.DATES: the days that there is balance and currency, except float rate moves, which need to be checked later
***        OUT: UNIQUE.CURRENCIES: the currencies should be considerred for calculation. should be both defined in CUSTOM.TYPE and valid CT account with the same currency.
*** Based on the converred balance information then create the date list, unique date list and unique currencies list. balance will be cached in ALL.PRIN.DATA
*** </desc>
CREATE.DATE.LIST:
    CURRENT.DATES = BALANCE.DETAILS<AC.BalanceUpdates.AcctActivity.IcActDayNo>
    CURRENT.CREDITS = BALANCE.DETAILS<AC.BalanceUpdates.AcctActivity.IcActBalance>
    
    PRIN.DATA = ''
    
    TOT.CURRENT.DATES = 0
    IF CURRENT.DATES THEN
        TOT.CURRENT.DATES = COUNT(CURRENT.DATES, @VM) + 1
    END
    FOR CNT.CURRENT.DATES = 1 TO TOT.CURRENT.DATES
        
        DATE.ITEM = CURRENT.DATES<1,CNT.CURRENT.DATES>
        END.DATE.ITEM = ''
        
        IF CNT.CURRENT.DATES LT TOT.CURRENT.DATES THEN
            IF CURRENT.DATES<1,CNT.CURRENT.DATES+1> MATCHES "8N" THEN ;* check this to avoid invalid date causing crash
                END.DATE.ITEM = CURRENT.DATES<1,CNT.CURRENT.DATES+1>
                EB.API.Cdt('', END.DATE.ITEM, '-1C')
            END
        END ELSE
            END.DATE.ITEM = REQD.END.DATE
        END
         
        CREDIT.ITEM = CURRENT.CREDITS<1,CNT.CURRENT.DATES>
        
    
        IF DATE.ITEM LT REQD.START.DATE THEN
            DATE.ITEM = REQD.START.DATE ;* This appied due to case: start.date = 20091228, end = 20100103, eff.date = 20091228, Balance start from DATE.ITEM = 20091224, 8000, rerturn from routine, then have to move date to the start.date. because 20091224 may not use custom rate.
        END
    
        AMOUNT = ABS(CREDIT.ITEM) ;* The valid balance on that date.
        DONOR.DATA<1> = ARR.CURRENCY
        DONOR.DATA.TEMP<1> = DATE.ITEM
        DONOR.DATA.TEMP<2> = AMOUNT
        DONOR.DATA<2,1> = LOWER(LOWER(DONOR.DATA.TEMP))
        EXCHANGED.DATA = ''
            
        AA.Framework.GetCurrencyBalance(ARRANGEMENT.ID, ARRANGEMENT.TYPE, CURRENCY, DONOR.DATA, DATE.ITEM, END.DATE.ITEM, EXCHANGED.DATA)
    
        TOT.CURRENCY.DATES = 0
        IF EXCHANGED.DATA<1> THEN
            TOT.CURRENCY.DATES = COUNT(EXCHANGED.DATA<1>, @VM) + 1
        END
    
        FOR CNT.CURRENCY.DATES = 1 TO TOT.CURRENCY.DATES
        
            LOCATE EXCHANGED.DATA<1,CNT.CURRENCY.DATES> IN PRIN.DATA<1,1> BY 'DN' SETTING DATE.POS THEN ;* The date from BALANCE.DETAILS is acending order, but from maintance point of view still make sure is in decending order in prin.data
            END
            
            INS EXCHANGED.DATA<1,CNT.CURRENCY.DATES> BEFORE PRIN.DATA<1,DATE.POS> ;*  have to be decending order for locating the balance amount afterwards.
            INS EXCHANGED.DATA<2,CNT.CURRENCY.DATES> BEFORE PRIN.DATA<2,DATE.POS>
            
            LOCATE EXCHANGED.DATA<1,CNT.CURRENCY.DATES> IN UNIQUE.DATES<1,1> BY 'DN' SETTING DATE.POS ELSE;*Adding Date to the unique list of dates if it does not exist
                INS EXCHANGED.DATA<1,CNT.CURRENCY.DATES> BEFORE UNIQUE.DATES<1, DATE.POS>
            END
    
        NEXT CNT.CURRENCY.DATES
        
    NEXT CNT.CURRENT.DATES
    
    LOCATE ARR.CURRENCY IN UNIQUE.CURRENCIES<1,1>  SETTING CUR.POS ELSE;*Adding currency to the unique list of currencies if it does not exist
        INS ARR.CURRENCY BEFORE UNIQUE.CURRENCIES<1, CUR.POS>
    END
    
*** apply concatenation to improve performance.
    IF ALL.PRIN.DATA<1> THEN
        ALL.PRIN.DATA<1> := @VM:ARR.CURRENCY
        ALL.PRIN.DATA<2> := @VM:LOWER(LOWER(PRIN.DATA))
    END ELSE
        ALL.PRIN.DATA<1> = ARR.CURRENCY
        ALL.PRIN.DATA<2> = LOWER(LOWER(PRIN.DATA))
    END
    
RETURN

*-----------------------------------------------------------------------------
*** <region name= INSERT.DATE.DUE.TO.FLOATING.RATE.MOVE>
*** <desc>
***        IN: REQD.START.DATE
***        IN: REQD.END.DATE
***        IN: INTEREST.RECORD
***        OUT: UNIQUE.DATES: on top of previous list, float rate moves should be considered.
*** in the period, there could be floating rate move if custom.name is defined as floating. need to do date split accordingly.
*** </desc>
INSERT.DATE.DUE.TO.FLOATING.RATE.MOVE:

    LOCATE ARR.CURRENCY IN INT.REC.CUSTOM.TYPES<1,1> SETTING ARR.CCY.POS THEN
    
        CUR.CUSTOM.NAME = DOWNCASE( INTEREST.RECORD<AA.Interest.Interest.IntCustomName, ARR.CCY.POS>)
        IF CUR.CUSTOM.NAME EQ 'floating' THEN
                
            FLOAT.DATES = ""
            FLOAT.RATES = ""
            FLOAT.ARR.CURRENCY<1> = ARR.CURRENCY
            FLOAT.ARR.CURRENCY<2> = "N"              ;* Pass 'N' argument to fetch the negative rates also
                    
            ST.RateParameters.EbGetFloatingRateChanges(FLOAT.ARR.CURRENCY, INTEREST.RECORD<AA.Interest.Interest.IntCustomValue, ARR.CCY.POS>, REQD.START.DATE, FLOAT.DATES, FLOAT.RATES)
                    
            LOOP
                REMOVE FLOAT.DATE FROM FLOAT.DATES SETTING FLOAT.DATE.POS   ;* Looping through the dates that floating rate is changed
            WHILE FLOAT.DATE:FLOAT.DATE.POS
                        
                IF FLOAT.DATE GE REQD.START.DATE AND FLOAT.DATE LE REQD.END.DATE THEN ;* date should be inside the period
                    LOCATE FLOAT.DATE IN UNIQUE.DATES<1,1> BY 'DN' SETTING UNIQUE.DATE.POS ELSE;*Adding Date to the unique list of dates if it does not exist
                        INS FLOAT.DATE BEFORE UNIQUE.DATES<1, UNIQUE.DATE.POS>
                    END
                END
            REPEAT
        END
    END
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= Consolidate balances>
*** <desc>
***        IN: REQD.START.DATE
***        IN: REQD.END.DATE
***        IN: UNIQUE.DATES
***        IN: UNIQUE.CURRENCIES
***        IN: ALL.PRIN.DATA
***        OUT: ABSOLUTE.BALANCES.AMOUNT: ABSOLUTE.BALANCES.AMOUNT<1, DATE.POS, CURRENCY.POS>, on each unique date, balances for each currency is stored in the SV.
*** loop through each unique date, and locate the balance from each currency's princial balance then form the whole data set before the weighted rate calculation.
*** </desc>
CONSOLIDATE.BALANCES:
    
    TOT.ARR = DCOUNT(ALL.PRIN.DATA<1>, @VM)
    DATE.POS = 1
    
    LOOP
        REMOVE DATE.ITEM FROM UNIQUE.DATES SETTING UNIQUE.DATES.POS
        
    WHILE DATE.ITEM:UNIQUE.DATES.POS
        
    
        FOR CNT.ARR = 1 TO TOT.ARR
            CURRENCY.ITEM = ALL.PRIN.DATA<1,CNT.ARR>
            PRIN.DATA = RAISE(RAISE(ALL.PRIN.DATA<2,CNT.ARR>))
            TOT.DATES = DCOUNT(PRIN.DATA<1>, @VM)
            BAL.START.DATE = PRIN.DATA<1,TOT.DATES>

            LOCATE DATE.ITEM IN PRIN.DATA<1, 1> BY "DN" SETTING DATE.ITEM.POS ELSE
            END
        
            IF DATE.ITEM GE BAL.START.DATE THEN ;* Avoid adding a balance which is before the balance initial date.
                    
                LOCATE CURRENCY.ITEM IN UNIQUE.CURRENCIES<1,1> SETTING CURRENCY.POS THEN ;* Must be able to locate the currency
                    ABSOLUTE.BALANCES.AMOUNT<1, DATE.POS, CURRENCY.POS> += ABS(PRIN.DATA<2,DATE.ITEM.POS>)
                END
            END ELSE
                LOCATE CURRENCY.ITEM IN UNIQUE.CURRENCIES<1,1> SETTING CURRENCY.POS THEN ;* Must be able to locate the currency
                    ABSOLUTE.BALANCES.AMOUNT<1, DATE.POS, CURRENCY.POS> += 0 ;* to prevent empty for one specific currency.
                END
            END
        NEXT CNT.ARR
        DATE.POS++
        
    REPEAT
    UNIQUE.DATES = UNIQUE.DATES

RETURN

*-----------------------------------------------------------------------------
*** <region name= Resolve interst rate>
*** <desc>
***        IN: UNIQUE.DATES
***        IN: ABSOLUTE.BALANCES.AMOUNT: ABSOLUTE.BALANCES.AMOUNT<1, DATE.POS, CURRENCY.POS>, on each unique date, balances for each currency is stored in the SV.
***        OUT: INT.DATA: the final results
*** loop through each unique date, get the custom rate value;
*** calculate the weighted rate with ABSOLUTE.BALANCES.AMOUNT data set, before calling the routine to do the calculation, there is pre-processing required.
*** </desc>

RESOLVE.INTEREST.RATE:
    
    NOF.DATES = DCOUNT(UNIQUE.DATES,@VM)
    
    FOR DATE.INDEX = 1 TO NOF.DATES
        TIER.DEFINITION = ''
        RATE.LIST = ''
        DEAL.DATE = UNIQUE.DATES<1,DATE.INDEX>
        TIER.ABS.BALANCE.AMOUNTS = '' ;* generate the accumulated tier amount before calling the rate calculation API
        
        GOSUB GET.CURRENCY.INTEREST.RATE ;* This has to be done inside the loop of dates, because floating rate is based on the date and should not be based on the effective.date
        
        GOSUB CALCULATE.WEIGHTED.RATE ;* Convert from actual balance in the each tier to accumulated tier amount before calling the API and other preprocessing.

          
        IF NOT(RETURN.ERROR) THEN
            
            LOCATE DEAL.DATE IN INT.DATA<1,1> BY 'DN' SETTING INT.DATA.POS THEN ;* Expected not to find the match one
            END
            
            INS DEAL.DATE BEFORE INT.DATA<1,INT.DATA.POS>
            INS DEAL.RATE BEFORE INT.DATA<2,INT.DATA.POS>
        END
    NEXT DATE.INDEX
   
RETURN

*-----------------------------------------------------------------------------
*** <region name= Get INTEREST rates>
*** <desc>
***        IN: UNIQUE.CURRENCIES
***        IN: INTEREST.RECORD
***        IN: DEAL.DATE
***        OUT: RATE.LIST: the list rate get from the custom rate configuration with the same order as the UNIQUE.CURRENCIES
*** with given DEAL.DATE, get the custom rate value list;
*** </desc>
GET.CURRENCY.INTEREST.RATE:

    LOOP
        REMOVE LOOP.CCY FROM  UNIQUE.CURRENCIES SETTING UNIQUE.POS   ;* looping through list of returned currencies to consolidate their corresponding balance
    WHILE LOOP.CCY:UNIQUE.POS
        INT.RATE = '0' ;* default 0, if anything not valid

        LOCATE LOOP.CCY IN INT.REC.CUSTOM.TYPES<1,1> SETTING CCY.POS THEN
            CUR.CUSTOM.NAME = DOWNCASE( INTEREST.RECORD<AA.Interest.Interest.IntCustomName, CCY.POS>)
            
            BEGIN CASE
                CASE CUR.CUSTOM.NAME EQ 'fixed' AND INTEREST.RECORD<AA.Interest.Interest.IntCustomValue, CCY.POS> NE '' ;* fixed and value not null
            
                    INT.RATE = INTEREST.RECORD<AA.Interest.Interest.IntCustomValue, CCY.POS>
                CASE CUR.CUSTOM.NAME EQ 'floating' AND INTEREST.RECORD<AA.Interest.Interest.IntCustomValue, CCY.POS> NE '' ;* floating defined, value not null
            
                    FLOAT.INDEX = INTEREST.RECORD<AA.Interest.Interest.IntCustomValue, CCY.POS> ;*getting floating index from custom value in interest record
                    FLOAT.KEY.DATE = FLOAT.INDEX:LOOP.CCY:DEAL.DATE ;* building the id to read it from basic.interst table. Note: should apply the DEAL.DATE, not the effective date.
                    ST.RateParameters.EbGetInterestRate(FLOAT.KEY.DATE, INT.RATE) ;*reading the interest rate
            END CASE
        END
    
        RATE.LIST<1, -1> = INT.RATE ;* keep as it is right now, because the INT.RATE may not set in some error case, but can still handle the case.
    REPEAT
    UNIQUE.CURRENCIES = UNIQUE.CURRENCIES
    
RETURN
*-----------------------------------------------------------------------------

*** <region name= CALCULATE.WEIGHTED.RATE>
*** <desc>
***        IN: ABSOLUTE.BALANCES.AMOUNT
***        IN: RATE.LIST
***        OUT: DEAL.RATE: the calculated weighted rate for one day.
*** calculate the weighted rate based on the balances and rate list for the currencies.
*** Note:
*** e.g. balances: 1000, 2000, 3000 for 2 individual balances.
***        Then convert to 1000, 3000 (1000+2000), ''
***        TIER.DEFINITION<3> should also be updated to '' for each MV field
***        zero balances should also be filtered out, which will cause issue in the routine, EbResolveInterestRate
*** </desc>

CALCULATE.WEIGHTED.RATE:
    FINAL.BALANCE = 0
    FINAL.RATE.LIST = ''
    TOT.NO.BALANCES = 0
    ABS.BALANCE.AMOUNTS =  ABSOLUTE.BALANCES.AMOUNT<1,DATE.INDEX>
    IF ABS.BALANCE.AMOUNTS THEN
        TOT.NO.BALANCES = COUNT(ABS.BALANCE.AMOUNTS, @SM) + 1
    END
    
    NOF.NONE.ZERO.BALANCE = 0
    DEAL.RATE = ""
    
    FOR CNT.NO.BALANCES = 1 TO TOT.NO.BALANCES
        IF ABS.BALANCE.AMOUNTS<1, 1, CNT.NO.BALANCES> THEN ;* Only consider the non-zero balance
            NOF.NONE.ZERO.BALANCE++
            
            FINAL.BALANCE += ABS.BALANCE.AMOUNTS<1, 1, CNT.NO.BALANCES>
            TIER.ABS.BALANCE.AMOUNTS<1, NOF.NONE.ZERO.BALANCE> = FINAL.BALANCE
            TIER.DEFINITION<3, NOF.NONE.ZERO.BALANCE> = '' ;* do not use percentage, but still need to set as ''
            FINAL.RATE.LIST<1, NOF.NONE.ZERO.BALANCE> = RATE.LIST<1, CNT.NO.BALANCES>
        END
    NEXT CNT.NO.BALANCES
    
    BEGIN CASE
        CASE NOF.NONE.ZERO.BALANCE EQ 0 ;* no none-zero balance
            DEAL.RATE = 0
            
        CASE NOF.NONE.ZERO.BALANCE EQ 1 ;* single balance
            DEAL.RATE = FINAL.RATE.LIST
            
        CASE 1 ;*  NOF.NONE.ZERO.BALANCE GT 1
            TIER.DEFINITION< 1 > = 'BAND'
            TIER.ABS.BALANCE.AMOUNTS<1, NOF.NONE.ZERO.BALANCE> = '' ;* last tier should be null
            TIER.DEFINITION< 2 > = TIER.ABS.BALANCE.AMOUNTS ;*
            TIER.DEFINITION< 4 > = FINAL.RATE.LIST
            PRINCIPAL.AMOUNT = FINAL.BALANCE
            
            AC.Fees.EbResolveInterestRate(TIER.DEFINITION, PRINCIPAL.AMOUNT, CURRENCY , "WEIGHTED.AVERAGE", "", DEAL.RATE, RETURN.ERROR)
    END CASE
    
    IF NOT(RETURN.ERROR) THEN
        EB.API.FormatRate(DEAL.RATE)
    END
    
RETURN
*** </region>




*-----------------------------------------------------------------------------

*** <region name= FORM.BUNDLE.DETAILS>
FORM.BUNDLE.DETAILS:
*** <desc>Form Bundedetails when BUNDEL.DETAILS is null </desc>

** Bundle details are not present in AA.INTEREST.ACCRUALS..
** Then add the current arrangement and source balance type in thebundle details
** so that interest is calculated based on the its source balance type

    RetErr =  ""
    SourceBalance = ""
    ProductRecord = ""
    ValErr = ""
    AA.ProductFramework.GetPublishedRecord("PRODUCT", '', '', CALC.PERIOD<1,1>, ProductRecord, ValErr)   ;* get the arrangement's product record
    AA.Framework.GetPropertyBalance(CUR.PROP, ProductRecord, SourceBalance)     ;* get the property's source balance
    BUNDLE.DETAILS<1> = CALC.PERIOD<1,1>   ;* start date
    BUNDLE.DETAILS<2> = CALC.PERIOD<1,2>   ;* end date
    BUNDLE.DETAILS<3> = ARRANGEMENT.ID     ;* current arranmgement
    BUNDLE.DETAILS<5> = SourceBalance      ;* current arrangement's source balance

RETURN
*** </region>
*-----------------------------------------------------------------------------


END
