* @ValidationCode : MjoxNzAwOTkwMzEyOkNwMTI1MjoxNTgwMjcwNDI0MzM1OmRwb29ybmltYTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAxLjIwMTkxMjI0LTE5MzU6MzM4OjIyNg==
* @ValidationInfo : Timestamp         : 29 Jan 2020 09:30:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dpoornima
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 226/338 (66.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191224-1935
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 02/06/00  GLOBUS Release No. 200512 09/12/05
*-----------------------------------------------------------------------------
* <Rating>-238</Rating>
*-----------------------------------------------------------------------------
$PACKAGE DX.ModelBank
SUBROUTINE E.DX.GET.IN.OUT.MONEY(RETURN.ARRAY)
*-----------------------------------------------------------------------------
* Program Description : Get trades in and out of the money for
*                       DX.OPTION.MONEY enquiry.
*-----------------------------------------------------------------------------
*** <region name= Modifications>
*** <desc>Details of modifications to this routine </desc>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 08/01/08 - BG_100016385 - aleggett@temenos.com
*            Routine created to build data for new DX.OPTION.IN.OUT.MONEY
*            enquiry.
*
* 11/02/08 - BG_100017065 - aleggett@temenos.com
*            Calculate moneyness dependent on strike price, market price and
*            CALL or PUT; regardless of whether the position is bought or
*            sold.
*
* 06/03/08 - BG_100017499 - aleggett@temenos.com
*            Call-out to external routine DX.GET.UNDERLYING.PRICE changed to
*            DX.GET.UNDERLYING.EDSP as this carries out the same function and
*            is a standard method in DX. DX.GET.UNDERLYING.PRICE made obsolete.
*
* 19/10/11 - Defect-273450 / Task-294732
*            Performance of the enquiries refereing this no file routine is increased
*            by selecting the trades based on the selection provided in enquiry
*            selection screen
*
* 06/02/12 - Defect-350274 / Task-350919
*            Enquiries not displaying the proper datas
*
* 18/07/12 - EN-360341 / Task-242183
*            Enhancement on creating currency pairs for FX-OTC options
*
* 02/05/13 - Enhancement_561544 Task_561547
*            Swaptions & Credit Default Swaps
*
* 04/06/15 - EN-1322379 / Tak-1328842
*            Incorporation of DX_ModelBank
*
* 15/02/17 - Defect:2016231 Task:2019818
*            Vanilla Bond Sell Call/Put- Customer and Counterparty details/data are interchanged on the OTC Options In/At the Moneys
*
* 21/07/17 - DEFECT 2194489 / TASK 2204873
*            Enquiry DX.OPTION.MONEY.MODEL display Customer as Counterparty and Counterparty as Customer for all Sell Call/Put trades
*
* 27/08/19 - TASK 3297213
*            Nofile enquiry DX.OPTION.MONEY.ETD
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserted commons and equates including field equates for files </desc>
    
    $USING DX.Trade
    $USING ST.RateParameters
    $USING ST.ExchangeRate
    $USING DX.Foundation
    $USING EB.Reports
    $USING EB.DataAccess
    $USING ST.CompanyCreation
    $USING DX.Configuration
    $USING EB.SystemTables
    
    $INSERT I_DAS.DX.TRADE
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main body of code>
*** <desc>Code execution starts and ends within this block. </desc>

    GOSUB S9000.INITIALISE
    GOSUB S100.MAIN.PROCESS

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= S100.MAIN.PROCESS>
*** <desc>Main processing block. </desc>
S100.MAIN.PROCESS:

    GOSUB S1000.SELECT.ALL.DEALS

    GOSUB S2000.PROCESS.DEALS

    GOSUB S3000.CONSOLIDATE.DATA

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= S1000.SELECT.ALL.DEALS>
*** <desc>Get list of all deals in DX.TRADE. </desc>
S1000.SELECT.ALL.DEALS:

* Get the list of ID's for the conditions provided in enquiry selection screen

    SEL.FLD.CNT = 0
    ARG.CNT = ''
    THE.ARGS = ''
    DX.TRADE.LIST = ''
    SEL.CRITERIA.FIELDS = EB.Reports.getDFields()
    SEL.CRITERIA.OPERANDS = EB.Reports.getDLogicalOperands()
    SEL.CRITERIA.VALUES = EB.Reports.getDRangeAndValue()

    TOT.SEL.FLD = DCOUNT(SEL.CRITERIA.FIELDS,@FM)
    FOR SEL.FLD.CNT = 1 TO TOT.SEL.FLD
        ARG.CNT += 1

        SEL.FLD = SEL.CRITERIA.FIELDS<SEL.FLD.CNT>
        SEL.OPR = SEL.CRITERIA.OPERANDS<SEL.FLD.CNT>
        SEL.VAL = SEL.CRITERIA.VALUES<SEL.FLD.CNT>
        
        BEGIN CASE
            CASE SEL.FLD EQ 'DATA.ITEM'
                ARG.CNT -= 1
            CASE SEL.FLD EQ 'MONEYNESS'
                MONEY.VAL = SEL.VAL
                ARG.CNT -= 1
            CASE 1

                BEGIN CASE
                    CASE SEL.OPR = 1
                        SEL.OPR = "EQ"
                    CASE SEL.OPR = 4
                        SEL.OPR = 'GT'
                    CASE SEL.OPR = 3
                        SEL.OPR = 'LT'
                    CASE SEL.OPR = 5
                        SEL.OPR = 'NE'
                    CASE SEL.OPR = 6
                        SEL.OPR = 'LIKE'
                        SEL.VAL = '...':SEL.VAL:'...'
                END CASE

                THE.ARGS<1,ARG.CNT> = SEL.FLD
                THE.ARGS<2,ARG.CNT> = SEL.OPR
                THE.ARGS<3,ARG.CNT> = SEL.VAL
        END CASE
    NEXT SEL.FLD.CNT
* Get list of all ids in DX.TRADE
    IF THE.ARGS EQ '' THEN
        DX.TRADE.LIST = EB.DataAccess.DasAllIds
    END ELSE
        DX.TRADE.LIST = dasDxTradeEnqSel
    END
    FILE.SUFFIX = ''
    EB.DataAccess.Das('DX.TRADE', DX.TRADE.LIST, THE.ARGS, FILE.SUFFIX)

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= S2000.PROCESS.DEALS>
*** <desc>Process each deal in turn, extracting data for in the money and out of the money options. </desc>
S2000.PROCESS.DEALS:

* Loop through the list of trades

    LOOP
        REMOVE DX.TRADE.ID FROM DX.TRADE.LIST SETTING DX.TRADE.MARK
    WHILE DX.TRADE.ID : DX.TRADE.MARK

        R.DX.TRADE = ''
        YERR = ''
        R.DX.TRADE = DX.Trade.Trade.Read(DX.TRADE.ID, YERR)
* Before incorporation : CALL F.READ(FN.DX.TRADE,DX.TRADE.ID,R.DX.TRADE,F.DX.TRADE,YERR)
        valid = @TRUE
* Find out whether this is an option or not, and whether this is a call or a put

        GOSUB S2100.GET.TRADE.DATA
        GOSUB S2200.CHECK.OPTION.TYPE

        IF valid THEN

            IF asPrincipal NE '' THEN   ;*The contract has underlying as OTHER
                GOSUB GET.PRICE.OTHER.CONT
            END ELSE
                GOSUB S2300.GET.UNDERLYING.PRICE
            END
        
            BEGIN CASE
                CASE MONEY.VAL EQ 'ITM'
* Get in the money options
                    GOSUB S2400.GET.IN.MONEY.OPTIONS

                CASE MONEY.VAL EQ 'ATM'
* Get at the money options
                    GOSUB S2500.GET.AT.MONEY.OPTIONS

                CASE MONEY.VAL EQ 'OTM'
* Get out of the money options
                    GOSUB S2600.GET.OUT.MONEY.OPTIONS
       
                CASE 1
                    GOSUB S2400.GET.IN.MONEY.OPTIONS        ;* Get in the money options
                    GOSUB S2500.GET.AT.MONEY.OPTIONS        ;* Get at the money options
                    GOSUB S2600.GET.OUT.MONEY.OPTIONS       ;* Get out of the money options
            END CASE
        END

    REPEAT

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= S2100.GET.TRADE.DATA>
*** <desc>Retrieve data from the DX.TRADE record. </desc>
S2100.GET.TRADE.DATA:

* Retrieve data needed for the enquiry rows and other checks.

    contractCode = R.DX.TRADE<DX.Trade.Trade.TraContractCode>
    maturityDate = R.DX.TRADE<DX.Trade.Trade.TraMaturityDate>
    exoticType = R.DX.TRADE<DX.Trade.Trade.TraExoticType>
    strikePrice = R.DX.TRADE<DX.Trade.Trade.TraStrikePrice>
    callOrPut = R.DX.TRADE<DX.Trade.Trade.TraOptionType>
    ccyPair<1> = R.DX.TRADE<DX.Trade.Trade.TraTradeCcy>     ;* Contract currency
    ccyPair<2> = R.DX.TRADE<DX.Trade.Trade.TraDlvCcy>       ;* Delivery Currency
    optStyle = R.DX.TRADE<DX.Trade.Trade.TraOptionStyle>    ;*Option Style
    primaryBuyOrSell = R.DX.TRADE<DX.Trade.Trade.TraPriBuySell>
    primaryLots = R.DX.TRADE<DX.Trade.Trade.TraPriLots>
    primaryCustomer = R.DX.TRADE<DX.Trade.Trade.TraPriCustNo>
    primaryPortfolio = R.DX.TRADE<DX.Trade.Trade.TraPriSecAcc>
    secondaryCustomer = R.DX.TRADE<DX.Trade.Trade.TraSecCustNo>
    secondaryPortfolio = R.DX.TRADE<DX.Trade.Trade.TraSecSecAcc>
    quoteCurrency = R.DX.TRADE<DX.Trade.Trade.TraStrikeQuoteCcy>
    quotePrice = R.DX.TRADE<DX.Trade.Trade.TraStrikeQuote>
    transid = R.DX.TRADE<DX.Trade.Trade.TraPriTransKey>
    exotic = R.DX.TRADE<DX.Trade.Trade.TraExoticType>
    exotic.cnt = DCOUNT(R.DX.TRADE<DX.Trade.Trade.TraUsrFldName>,@VM)
    exotic.value = ""
    asPrincipal = R.DX.TRADE<DX.Trade.Trade.TraAsPrincipal>
    swapMatDate = R.DX.TRADE<DX.Trade.Trade.TraSwapMatDate>
    underlySec = R.DX.TRADE<DX.Trade.Trade.TraUnderlyingSecurity>

    FOR cnt = 1 TO exotic.cnt ;*For exotic options the exotic values are needed to for market price record
        IF R.DX.TRADE<DX.Trade.Trade.TraUsrFldPrice,cnt> EQ "YES" THEN
            IF exotic.value EQ "" THEN
                exotic.value = R.DX.TRADE<DX.Trade.Trade.TraUsrFldVal,cnt>
            END ELSE
                exotic.value = exotic.value"/":R.DX.TRADE<DX.Trade.Trade.TraUsrFldVal,cnt>
            END
        END
    NEXT cnt

    IF primaryLots LT 1 THEN
        valid = @FALSE
    END

RETURN

*** </region>
*--------------------------------------------------------------------------

GET.PRICE.OTHER.CONT:
    PAY.TYPE = R.DX.TRADE<DX.Trade.Trade.TraPayType>
    RECV.TYPE = R.DX.TRADE<DX.Trade.Trade.TraReceiveType>
    PI.DATE = EB.SystemTables.getToday() ;*Today's date
    As.underlyingPrice = ''
    priceDifferential = ''
    Lb.underlyingPrice = ''

    IF PAY.TYPE EQ 'FLOATING' THEN
        MKT.ID =  R.DX.TRADE<DX.Trade.Trade.TraAsFloatKey> ;*Floating rate key
        R.MKT.TXT.REC = ST.RateParameters.MarketRateText.Read(MKT.ID, MKT.ERR)
* Before incorporation : CALL F.READ(FN.MARKET.RATE.TEXT,MKT.ID,R.MKT.TXT.REC,F.MARKET.RATE.TEXT,MKT.ERR)
        PI.FLOAT = R.MKT.TXT.REC<ST.RateParameters.MarketRateText.EbMrtRateKey>
        PI.FREQ = R.DX.TRADE<DX.Trade.Trade.TraAsIntFrequency>       ;*Frequency of interest payment
        PI.CCY = R.DX.TRADE<DX.Trade.Trade.TraTradeCcy>     ;*Trade currency
        GOSUB GET.UNDERLYING.PRICE
        underlyingPrice = CalculatedPrice
    END ELSE
        underlyingPrice = R.DX.TRADE<DX.Trade.Trade.TraAsFixedRate>
    END

    BEGIN CASE

        CASE RECV.TYPE EQ 'FLOATING'
            MKT.ID =  R.DX.TRADE<DX.Trade.Trade.TraLbFloatKey> ;*Floating rate key
            R.MKT.TXT.REC = ST.RateParameters.MarketRateText.Read(MKT.ID, MKT.ERR)
* Before incorporation : CALL F.READ(F.MARKET.RATE.TEXT,MKT.ID,R.MKT.TXT.REC,F.MARKET.RATE.TEXT,MKT.ERR)
            PI.FLOAT = R.MKT.TXT.REC<ST.RateParameters.MarketRateText.EbMrtRateKey>
            PI.FREQ = R.DX.TRADE<DX.Trade.Trade.TraLbIntFrequency>       ;*Frequency of interest payment
            PI.CCY = R.DX.TRADE<DX.Trade.Trade.TraLbCurrency>   ;*Liablity currency
            GOSUB GET.UNDERLYING.PRICE
            Lb.underlyingPrice = CalculatedPrice

        CASE RECV.TYPE EQ 'FIXED'
            Lb.underlyingPrice = R.DX.TRADE<DX.Trade.Trade.TraLbFixedRate>

        CASE 1
            Lb.underlyingPrice = R.DX.TRADE<DX.Trade.Trade.TraStrikePrice>

    END CASE

    priceDifferential = Lb.underlyingPrice - underlyingPrice

RETURN

*----------------------------------------------------------------------------

GET.UNDERLYING.PRICE:

    BEGIN CASE

* Determine the frequency to get the rest period from periodic interest table
        CASE PI.FREQ[1,1] = "D"   ;*Daily
            REST.PRD = '1D'

        CASE PI.FREQ[1,1] = "W"   ;*Weekly
            REST.PRD = PI.FREQ[5,1] * 7 :"D"          ;*Convert to days as week is not posible in PI table

        CASE PI.FREQ[1,1] = "M"   ;*Monthly
            REST.PRD = PI.FREQ[4,2]:'M'

        CASE 1
            REST.PRD = 'R'        ;*Other frequency definitions

    END CASE

* Find Bid Rate
    ST.ExchangeRate.Termrate('',PI.FLOAT,'',PI.CCY,PI.DATE,'B','',REST.PRD,'',BID.RATE,'','','','',RETURN.CODE)

* Find Offer Rate
    ST.ExchangeRate.Termrate('',PI.FLOAT,'',PI.CCY,PI.DATE,'O','',REST.PRD,'',OFFER.RATE,'','','','',RETURN.CODE)

    CalculatedPrice = 0

    IF NOT(RETURN.CODE) THEN
        CalculatedPrice = (BID.RATE + OFFER.RATE) / 2       ;*Rate
    END

RETURN

*-----------------------------------------------------------------------------
*** <region name= S2200.CHECK.OPTION.TYPE>
*** <desc>Check whether a call or a put - ignore futures. </desc>
S2200.CHECK.OPTION.TYPE:

* Make sure this is an option, and set price differential sign based on whether
* this is a call or a put.

    BEGIN CASE
        CASE callOrPut = 'CALL'
            isOption = @TRUE
            priceDifferentialSign = -1
        CASE callOrPut = 'PUT'
            isOption = @TRUE
            priceDifferentialSign = 1
        CASE 1
            valid = @FALSE
    END CASE

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= S2300.GET.UNDERLYING.PRICE>
*** <desc>Get the price of the underlying commodity. </desc>
S2300.GET.UNDERLYING.PRICE:

* Get the price of the underlying commodity

    rtnCode = ''
    intUnderlyingPrice = ''   ;* BG_100017499 S
    DX.Foundation.GetUnderlyingEdsp(closingPriceSet,contractCode,maturityDate,strikePrice,callOrPut,ccyPair,optStyle,intUnderlyingPrice,underlyingPrice,rtnCode)
    IF NUM(underlyingPrice) THEN
        priceDifferential = (strikePrice - underlyingPrice) * priceDifferentialSign
    END ELSE
        priceDifferential = 0
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= S2400.GET.IN.MONEY.OPTIONS>
*** <desc>Get data row for option if in the money </desc>
S2400.GET.IN.MONEY.OPTIONS:

* Get options which are in the money

    IF priceDifferential GT 0 THEN
        sortList = inMoneySortList
        sortPos = 1
        GOSUB S2700.BUILD.DATA
        inMoneySortList = sortList
        dataRow<1,1> = 'ITM'
        INS dataRow BEFORE inMoneyDeals<sortPos>
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= S2500.GET.AT.MONEY.OPTIONS>
*** <desc>Get data row for option if at the money </desc>
S2500.GET.AT.MONEY.OPTIONS:

* Get options which are at the money

    IF priceDifferential EQ 0 THEN
        sortList = atMoneySortList
        sortPos = 1
        GOSUB S2700.BUILD.DATA
        atMoneySortList = sortList
        dataRow<1,1> = 'ATM'
        INS dataRow BEFORE atMoneyDeals<sortPos>
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= S2600.GET.OUT.MONEY.OPTIONS>
*** <desc>Get the data row if the option is out of the money. </desc>
S2600.GET.OUT.MONEY.OPTIONS:

* Get options which are at the money

    IF priceDifferential LT 0 THEN
        sortList = outMoneySortList
        sortPos = 1
        GOSUB S2700.BUILD.DATA
        outMoneySortList = sortList
        dataRow<1,1> = 'OTM'
        INS dataRow BEFORE outMoneyDeals<sortPos>
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= S2700.BUILD.DATA>
*** <desc>Build the enquiry data row. </desc>
S2700.BUILD.DATA:

* Build the data for the enquiry row

    dataRow = ''
    dataRow<1,1> = ''         ;* Will be OTM or ITM (in/out of the money)
    dataRow<1,2> = DX.TRADE.ID
    dataRow<1,3> = contractCode
    dataRow<1,4> = maturityDate
    dataRow<1,5> = exoticType
    dataRow<1,6> = strikePrice
    dataRow<1,7> = underlyingPrice
    dataRow<1,8> = priceDifferential
    dataRow<1,9> = primaryBuyOrSell
    dataRow<1,10> = callOrPut
    dataRow<1,11> = primaryLots
    dataRow<1,15>= ccyPair<1> ;* Contract currency
    dataRow<1,16>= ccyPair<2> ;* Delivery currency
    dataRow<1,17> = optStyle  ;* Option Style
* Both DX.OPTION.MONEY.OTC and DX.OPTION.MONEY.MODEL enquiry, get processed in this routine
    ENQ.NAME = EB.Reports.getEnqSelection()<1>
    IF primaryBuyOrSell EQ 'BUY' OR ENQ.NAME EQ 'DX.OPTION.MONEY.OTC' THEN
        dataRow<1,12>= primaryCustomer
        dataRow<1,13>= primaryPortfolio
        dataRow<1,14>= secondaryCustomer
        dataRow<1,18>= secondaryPortfolio
    END ELSE
        dataRow<1,12>= secondaryCustomer
        dataRow<1,13>= secondaryPortfolio
        dataRow<1,14>= primaryCustomer
        dataRow<1,18>= primaryPortfolio
    END

    dataRow<1,19> = quoteCurrency
    dataRow<1,20> = quotePrice
    dataRow<1,21> = transid

    Argument = " TRANS.ID=":transid:" CO.LOTS=":primaryLots
    dataRow<1,22> = Argument
    R.DX.CM.REC = ''
    R.UNDERLYING.REC = ''
    UNDL.ENRI = ''
    DX.Foundation.GetUnderlying(contractCode,R.DX.CM.REC,R.UNDERLYING.REC,UNDL.ENRI)
    underlying = FIELD(UNDL.ENRI,"/",2)
    underlyingType = FIELD(UNDL.ENRI,"/",3)
    dataRow<1,25> = underlying
    dataRow<1,26>= Lb.underlyingPrice

    BEGIN CASE

        CASE underlyingType EQ 'OTC.FOREX'
            priceapp = "CURRENCY"
            priceid = ccyPair<2>

        CASE underlyingType EQ 'DX.CONTRACT.MASTER'
            priceapp = "DX.MARKET.PRICE"
            mktPriceId = closingPriceSet:":/":contractCode:"/":ccyPair<1>:"/":maturityDate:"/":callOrPut:"/":strikePrice:"/":ccyPair<2>:"/":optStyle[1,1]:":":exotic.value
            priceid = mktPriceId

        CASE underlyingType EQ 'SECURITY.MASTER'
            priceapp = "SECURITY.MASTER"
            priceid  = underlying

    END CASE

    dataRow<1,23> = priceapp
    dataRow<1,24> = priceid
    dataRow<1,27> = swapMatDate
    dataRow<1,28> = underlySec

    sortKey = contractCode:"*":strikePrice:"*":callOrPut:"*"
    sortKey:= primaryCustomer:"*":secondaryCustomer:"*":primaryLots

    LOCATE sortKey IN sortList SETTING sortPos THEN
        sortPos += 1
    END ELSE
        INS sortKey BEFORE sortList<sortPos>
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= S3000.CONSOLIDATE.DATA>
*** <desc>Consolidate the data for the enquiry for in the money options and out of the money options. </desc>
S3000.CONSOLIDATE.DATA:

* Consolidate in the money and out of the money lists
* Don't add in any blank rows when concatenating

    allDeals = inMoneyDeals

    IF atMoneyDeals THEN
        IF allDeals THEN
            allDeals := @FM:atMoneyDeals
        END ELSE
            allDeals = atMoneyDeals
        END
    END

    IF outMoneyDeals THEN
        IF allDeals THEN
            allDeals := @FM:outMoneyDeals
        END ELSE
            allDeals = outMoneyDeals
        END
    END

    CONVERT @VM TO "_" IN allDeals

    IF RETURN.ARRAY THEN
        RETURN.ARRAY<4> = LOWER(allDeals)
    END ELSE
        RETURN.ARRAY = allDeals
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= S9000.INITIALISE>
*** <desc>Initialisation section - initialise variables, open files, read parameter records. </desc>
S9000.INITIALISE:

* Open files required

    FN.DX.PARAMETER = 'F.DX.PARAMETER'
    F.DX.PARAMETER = ''
    EB.DataAccess.Opf(FN.DX.PARAMETER,F.DX.PARAMETER)

* Local variables

    priceDifferentialSign = 1 ;* -1 for CALL, 1 for PUT.
    strikePrice = 0

    inMoneyDeals = ''
    atMoneyDeals = ''
    outMoneyDeals = ''
    inMoneySortList = ''
    atMoneySortList = ''
    outMoneySortList = ''
    dataRow = ''
    asPrincipal = ''          ;*AS.PRINCIPAL from trade

    callOrPut = ''
    isOption = @FALSE
    ccyPair = ''
    optStyle = ''
    opCodes = EB.Reports.getDLogicalOperands()

* Translate Operand Codes into Operands

    selectionOprtrs = ''
    numOpcodes = DCOUNT(opCodes,@FM)
    FOR opcodeNo = 1 TO numOpcodes
        opcode = opCodes<opcodeNo>
        selectionOprtrs<opcodeNo> = EB.Reports.getOperandList()<opcode>
    NEXT opcodeNo

    selectionFields = EB.Reports.getDFields()
    selectionValues = EB.Reports.getDRangeAndValue()

* Get DX Parameter values

    DX.PARAMETER.ID = "SYSTEM"
    R.DX.PARAMETER = ""
    YERR = ""

    ST.CompanyCreation.EbReadParameter(FN.DX.PARAMETER,'N','',R.DX.PARAMETER,DX.PARAMETER.ID,F.DX.PARAMETER,yerr)
    IF yerr # "" THEN
        EB.SystemTables.setE(yerr)
    END

    closingPriceSet = R.DX.PARAMETER<DX.Configuration.Parameter.ParEoePriceSet>

RETURN

*** </region>
*-----------------------------------------------------------------------------
*
END
