* @ValidationCode : MjotNDgwNTIzMDEyOkNwMTI1MjoxNjAxNTUxMzc5MTY2OnJqZWV2aXRoa3VtYXI6NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjEwNjoxMDQ=
* @ValidationInfo : Timestamp         : 01 Oct 2020 16:52:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rjeevithkumar
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 104/106 (98.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-36</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AB.ModelBank
SUBROUTINE E.AA.DETAILS.BUNDLE.BALANCE(ENQ.ARRAY)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Program Description </desc>
**
*
* Nofile routine used to return bundle arrangement participant account balances
*
* @uses I_ENQUIRY.COMMON
* @class
* @package retaillending.AA
* @stereotype subroutine
* @author sivakumark@temenos.com
*
**
*** </region>
*------------------------------------------------------------------------
*** <region name= MODIFICATION HISTORY>
*
* 05/09/2014 - Task : 1077380
*              Enhancement 1052773
*              New Routine
*
* 11-06-2015 - Task : 1374858
*              Defect : 1364696
*              The Combine Group Balance enquiry in the Bundle Arrangement
*              overview is not displaying the Bundle balance.
*
*
* 13/06/17 - Enhancement : 2148615
*            Task : 2231452
*            Value markers in BunArrangements in PRODUCT.BUNDLE is changed to SM
*
* 29/08/17 - Defect : 2249269
*            Task : 2251235
*            In a Multi-currency bundle, the combined balances of the group is not correctly shown in the enquiry ENQ AA.FIND.ARRANGEMENT.AB
*
* 08/11/17 - Task   - 2329976
*            Enhancement - 2329973
*            Update to support balance conversion market other than default
*
* 27/09/18   Defect : 2768993
*            Task   : 2786453
*            Balance field in bundle arrangement is not updated correctly
*
* 22/03/19   Defect : 3042361
*            Task   : 3049503
*            Balances of participant arrangements not displayed for rule.based bundles
*            as master arrangement is not required In this case convert the participants balances to LCY
*
* 18/09/20   Defect : 3944064
*            Task   : 3977444
*            Replacing E.CALC.OPEN.BALANCE routine with E.AC.GET.AVAILABLE.BAL routine to get account balance with
*            limit amount
*
*
* 14/09/20 - Enhancement 3934727 / Task 3940554
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*** <desc>Changes done in the sub-routine<</desc>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING AA.ProductBundle
    $USING BF.ConBalanceUpdates
    $USING RE.ConBalanceUpdates
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING AC.ModelBank
    $USING EB.SystemTables
    $USING EB.API
    $USING EB.Reports
    $USING ST.ExchangeRate
    $USING ST.CurrencyConfig
    $USING AC.API

*** </region>
*----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>
    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------


*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc> </desc>
INITIALISE:
    ONLINE.ACTUAL.BAL = ""
    ONLINE.CLEARED.BAL = ""
    WORKING.BALANCE = ""
    OVERDRAWN = ""
    CCY.MARKET = ""

    RET.CODE = ""

RETURN



*** <region name= Main Process>
*** <desc>Main Process</desc>
PROCESS:

    LOCATE 'ARRANGEMENT.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ARRPOS THEN
        ARR.ID = EB.Reports.getEnqSelection()<4,ARRPOS>          ;* Pick the Arrangement Id
    END


    CHECK.DATE = EB.SystemTables.getToday()
    ARR.INFO = ARR.ID:@FM:'':@FM:'':@FM:'':@FM:'':@FM:''
    AA.Framework.GetArrangementProperties(ARR.INFO, CHECK.DATE, R.ARRANGEMENT, PROP.LIST)
    CLASS.LIST = ''
    AA.ProductFramework.GetPropertyClass(PROP.LIST, CLASS.LIST)       ;* Find their Property classes

    LOCATE 'PRODUCT.BUNDLE' IN CLASS.LIST<1,1> SETTING PROD.POS THEN
        PB.PROPERTY = PROP.LIST<1,PROD.POS>
    END
    AA.ProductFramework.GetPropertyRecord('', ARR.ID, PB.PROPERTY, CHECK.DATE, 'PRODUCT.BUNDLE', '', R.PRODUCT.BUNDLE , REC.ERR)
       
    PRD.BUNDLE.PRODUCT.GRP  = R.PRODUCT.BUNDLE<AA.ProductBundle.ProductBundle.BunProductGroup>   ;* Shared accounts product group
    TOT.PRODUCT.GRP.CNT = DCOUNT(PRD.BUNDLE.PRODUCT.GRP, @VM);*to fetch the total no of Product Groups
    FOR CNT.PRODUCT.GRP = 1 TO  TOT.PRODUCT.GRP.CNT
*In each Product Group -Product section, arrangements are now seperated by SM
        GOSUB PROCESS.ARRANGEMENTS
   
    NEXT CNT.PRODUCT.GRP
RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Process Arrangements>
*** <desc>Main Process</desc>
PROCESS.ARRANGEMENTS:
    
    CCY.MKT.DATES = ''
    CCY.MARKET = ''
    ARRANGEMENT.IDS = R.PRODUCT.BUNDLE<AA.ProductBundle.ProductBundle.BunArrangement,CNT.PRODUCT.GRP>
    MASTER.ARR.ID = R.PRODUCT.BUNDLE<AA.ProductBundle.ProductBundle.BunMasterArrangement> ;*Only one MASTER/RECIPIENT is allowed as of now
   
    IF MASTER.ARR.ID THEN
	    R.ARRANGEMENT = AA.Framework.Arrangement.Read(MASTER.ARR.ID, RETERROR)
	    MASTER.CURRENCY = R.ARRANGEMENT<AA.Framework.Arrangement.ArrCurrency> ;**To Get the Currency of the Recipient arrangement
        AA.ProductBundle.GetBundleCcyMarket(MASTER.ARR.ID, 'RECIPIENT', CHECK.DATE, CHECK.DATE, CCY.MKT.DATES, CCY.MARKET) ;* Get the currency market, it may return null, which means default ccy market
        
    END ELSE
        MASTER.CURRENCY = EB.SystemTables.getLccy() ;* If no master arrangement assign local currency
        CCY.MARKET = '1' ;* This is the default ccy market, if apply '' directly in the EXCHRATE routine as argument, it will be complained with invalid argument
    END
    
    FOR CNT = 1 TO DCOUNT(ARRANGEMENT.IDS,@SM)
        R.ARRANGEMENT = ''
        ARR.ID = ARRANGEMENT.IDS<1,1,CNT>
        AA.Framework.GetArrangement(ARR.ID, R.ARRANGEMENT, ARR.ERROR)
        ACCT.ID = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId>
        ARR.CURRENCY = R.ARRANGEMENT<AA.Framework.Arrangement.ArrCurrency>
        IF ACCT.ID THEN
            R.EB.CONTRACT.BALANCES = BF.ConBalanceUpdates.EbContractBalances.Read(ACCT.ID, RET.ERR)
            IF R.EB.CONTRACT.BALANCES THEN
                IF MASTER.CURRENCY EQ ARR.CURRENCY THEN;*Any arrangement belonging to the same currency as MASTER, consolidate the various balances(Online Actual, Online Cleared, Working Balance & Overdrawn)
                    ONLINE.ACTUAL.BAL+= R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbOnlineActualBal>
                    ONLINE.CLEARED.BAL+ = R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbOnlineClearedBal>
                    WORKING.BALANCE+ = R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbWorkingBalance>
                END ELSE ;*Any arrangement belonging to different currency compared to MASTER arrangement currency , convert the various balances to get mid-rate equivalent of recipient currency and then consolidate
                    BUY.AMT = R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbOnlineActualBal>
                    GOSUB CHECK.CONVERSION.MARKET
                    GOSUB GET.MID.RATE.EQUIVALENT ;*OnlineActualBal of DONOR is passed to Exchrate to get mid-rate equivalent of recipient currency
                    ONLINE.ACTUAL.BAL+= SELL.AMT
                    
                    BUY.AMT = R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbOnlineClearedBal>
                    GOSUB CHECK.CONVERSION.MARKET
                    GOSUB GET.MID.RATE.EQUIVALENT;*OnlineClearedBal of DONOR is passed to Exchrate to get mid-rate equivalent of recipient currency
                    ONLINE.CLEARED.BAL+ =  SELL.AMT
                    
                    BUY.AMT = R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbWorkingBalance>
                    GOSUB CHECK.CONVERSION.MARKET
                    GOSUB GET.MID.RATE.EQUIVALENT;*WorkingBalance of DONOR is passed to Exchrate to get mid-rate equivalent of recipient currency
                    WORKING.BALANCE+ =SELL.AMT
                END

* Replacing E.CALC.OPEN.BALANCE routine with E.AC.GET.AVAILABLE.BAL routine to get account balance with limit amount
         
                AccountId = ACCT.ID
                AvailBal = "" ;* To get available balance
                AC.API.EAcGetAvailableBal(AccountId,"","","",AvailBal)
               
                IF MASTER.CURRENCY EQ ARR.CURRENCY THEN;*Any arrangement belonging to the same currency as MASTER, to consolidate the various balances(Online Actual, Online Cleared, Working Balance & Overdrawn)
                    OVERDRAWN+ = AvailBal
                END ELSE ;*Any arrangement belonging to different currency compared to MASTER arrangement currency
                    BUY.AMT = AvailBal
                    GOSUB CHECK.CONVERSION.MARKET
                    GOSUB GET.MID.RATE.EQUIVALENT
                    OVERDRAWN+ = SELL.AMT
                END
            END
        END
    NEXT CNT

    ENQ.ARRAY = ONLINE.ACTUAL.BAL:"*":ONLINE.CLEARED.BAL:"*":WORKING.BALANCE:"*":OVERDRAWN

RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= GetMidRateEquivalent>
*** <desc>Logic from AA.GET.CURRENCY.BALANCE to find the mid-rate equivalent of recipient currency</desc>
GET.MID.RATE.EQUIVALENT:
* Convert the DONOR's balance to recipient's currency for any arrangement belonging to different currency compared to MASTER arrangement currency
    SELL.AMT = ''
    RET.CODE = ''
    ST.ExchangeRate.Exchrate(CCY.MARKET, ARR.CURRENCY, BUY.AMT, MASTER.CURRENCY, SELL.AMT, '','','','', RET.CODE)

RETURN
*** </region>

*------------------------------------------------------------------------------------------------------------
*** <region name= CHECK.CONVERSION.MARKET>
*** <desc>Check if conversion market exists in both buy and sell currency table</desc>
CHECK.CONVERSION.MARKET:
    
    BUY.CURRENCY = ARR.CURRENCY
    R.BUY.CURRENCY = ''
    ER = ''
    CHK.CCY.MKT = '0'
    ST.CurrencyConfig.GetCurrencyRecord('', BUY.CURRENCY, R.BUY.CURRENCY, ER)   ;* Get Buy currency record
    
    SELL.CURRENCY = MASTER.CURRENCY
    R.SELL.CURRENCY = ''
    ER = ''
    ST.CurrencyConfig.GetCurrencyRecord('', SELL.CURRENCY, R.SELL.CURRENCY, ER) ;* Get sell currency record
    
    LOCATE CCY.MARKET IN R.BUY.CURRENCY<ST.CurrencyConfig.Currency.EbCurCurrencyMarket,1> SETTING POS ELSE ;* Check if CCY.MARKT is in Buy currency record
        CHK.CCY.MKT = '1'
    END
    
    LOCATE CCY.MARKET IN R.SELL.CURRENCY<ST.CurrencyConfig.Currency.EbCurCurrencyMarket,1> SETTING POS ELSE ;* Check if CCY.MARKT is in Sell currency record
        CHK.CCY.MKT = '1'
    END
    
    IF CHK.CCY.MKT EQ '1' THEN ;* If Currency market is not in buy or sell or both currency record, set the currency market to 1
        CCY.MARKET = '1'
    END

RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------
END
