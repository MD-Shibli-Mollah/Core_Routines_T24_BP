* @ValidationCode : MjotMTYxMDQ1ODI3MjpDcDEyNTI6MTU3MzYyNTY5NDExNTptYXJjaGFuYToyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTEwLjIwMTkwOTIwLTA3MDc6MzM5OjE3MQ==
* @ValidationInfo : Timestamp         : 13 Nov 2019 11:44:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : marchana
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 171/339 (50.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>1258</Rating>
*-----------------------------------------------------------------------------
$PACKAGE PR.ModelBank
SUBROUTINE E.AA.GET.PREF.PRICES(ENQ.DATA)
*
*-----------------------------------------------------------------------------
*
* 07 MAY 2013 - rwood@temenos.com - Added sorting of products
* 08 May 2013 - rwood@temenos.com - Started translating the descriptions
* 10 May 2013 - rwood@temenos.com - Added property description to the output
* 11 May 2013 - rwood@temenos.com - Currencies can be submultivalued
*-----------------------------------------------------------------------------
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done in the routine </desc>
*
* 27/10/14 - Task : 1144828
*            Defect : 1144817
*            Pricing Overview Changes
*
* 09/09/15 - Task : 1447056
*            Enhancement : 1434821
*            Get the GL Custoemr by calling AA.GET.ARRANGEMENT.CUSTOMER routine.
*
* 24/02/17 - Defect : 2024964
*            Task   : 2031544
*            Gets the GL customer by calling AA.GET.ARRANGEMENT.CONDITIONS and AA.GET.ARRANGEMENT.CUSTOMER
*
* 20/06/19 -  Task : 3189666
*             Defect : 3183465
*             Gets the current variation for the current product
*
* 31/10/19 -  Task : 3414112
*             Defect : 3413763
*             Local language description to be get from product, product group, product line
*
*** </region>
*-----------------------------------------------------------------------------

    $USING AA.Framework
    $USING AA.PreferentialPricing
    $USING AA.ProductManagement
    $USING AA.ProductFramework
    $USING ST.Customer
    $USING EB.Browser
    $USING EB.SystemTables
    $USING EB.Reports
    $USING AA.Customer

*
    EQUATE THIS.PRODUCT.LINE TO "RELATIONSHIP.PRICING"
    EQUATE DELIM TO "*"
*
    PROMPT ""
*
*-----------------------------------------------------------------------------
*
    GOSUB INITIALISE
    GOSUB PROCESS
    GOSUB FINISH
*
RETURN
*
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
*
*** The INITAIALISE routine works out what we were passed and it with be
*** an arrangement number or a CUSTOMER number.
*
    IF THIS.AA <> "" THEN
        GOSUB PROCESS.ARRANGEMENT
    END ELSE
        GOSUB READ.CUSTOMER
*
*** Now read what arrangements this customer has
*
        R.AA.CUSTOMER.ARRANGEMENT = ""
        R.AA.CUSTOMER.ARRANGEMENT = AA.Framework.CustomerArrangement.Read(THIS.CUSTOMER.ID, READ.ERR)
*
*** NOW WE LOOK FOR THE PREFERENTIAL PRICING ARRANGEMENTS
*
        PRODUCT.LINES = R.AA.CUSTOMER.ARRANGEMENT<AA.Framework.CustomerArrangement.CusarrProductLine>
        IF PRODUCT.LINES <> ""  THEN
            LOCATE THIS.PRODUCT.LINE IN PRODUCT.LINES<1,1> SETTING PP.POS THEN
                ARRANGEMENTS = R.AA.CUSTOMER.ARRANGEMENT<AA.Framework.CustomerArrangement.CusarrArrangement,PP.POS>
                NUM.ARRANGMENTS = DCOUNT(ARRANGEMENTS,@SM)
                FOR AA.COUNTER = 1 TO NUM.ARRANGMENTS
                    THIS.AA = ARRANGEMENTS<1,1,AA.COUNTER>
                    GOSUB PROCESS.ARRANGEMENT
                NEXT AA.COUNTER
*
            END ELSE
                EB.Reports.setEnqError('No records selected')
            END
        END ELSE
            EB.Reports.setEnqError('No records selected')
        END
    END
*
RETURN
*
*-----------------------------------------------------------------------------
PROCESS.ARRANGEMENT:
*-----------------------------------------------------------------------------
*
    READ.ERR = ""
    R.AA.ARRANGEMENT = ""
    R.AA.ARRANGEMENT = AA.Framework.Arrangement.Read(THIS.AA, READ.ERR)
*
*** If we were just passed the arrangement ID we won't have read the customer in yet
*
    IF THIS.CUSTOMER.ID = "" THEN

* During enquiry launch, system should not rely on common variables.
* Hence instead of fetching customer record from AA.GET.PROPERTY.RECORD which relies on common variable inside AA.GET.ARRANGEMENT.CUSTOMER,
* get record by calling AA.GET.ARRANGEMENT.CONDITIONS by reading the record from the database.

        EFF.DATE  = EB.SystemTables.getToday()
        RCustomer = ''   ;* stores customer record
        AA.Framework.GetArrangementConditions(THIS.AA, "CUSTOMER", "", EFF.DATE, "", RCustomer, "")  ;* get customer record
        RCustomer = RAISE(RCustomer)    ;* raise the record
    
        AA.Customer.GetArrangementCustomer(THIS.AA, "", RCustomer, "", "", THIS.CUSTOMER.ID, RET.ERROR)  ;* returns the arrangement customer

        GOSUB READ.CUSTOMER
    END
*
    LOCATE "CURRENT" IN R.AA.ARRANGEMENT<AA.Framework.Arrangement.ArrProductStatus,1> SETTING DT.POS THEN   ;*Gets the current variation for the current product
        YR.PRODUCT = R.AA.ARRANGEMENT<AA.Framework.Arrangement.ArrProduct,DT.POS>
        VARIATIONS = R.AA.ARRANGEMENT<AA.Framework.Arrangement.ArrVariation,DT.POS>
        VARIATION = VARIATIONS<1,1,1>
    END
    
    R.AA.PRODUCT = AA.ProductManagement.Product.Read(YR.PRODUCT, READ.ERR)
    ARRANGEMENT.DESCRIPTION = R.AA.PRODUCT<AA.ProductManagement.Product.PdtDescription,EB.SystemTables.getLngg()>
    idProperty = ""
    idPropertyClass = ""
    effectiveDate = ""        ;*** the routine will default to today
    AA.Framework.GetArrangementConditions(THIS.AA, "PREFERENTIAL.PRICING", "", effectiveDate, returnIds, Conditions, returnError)
    IF Conditions <> "" THEN
        Conditions = RAISE(Conditions)
        GOSUB ADD.CONDITIONS
    END
*
RETURN
*
*-----------------------------------------------------------------------------
ADD.CONDITIONS:
*-----------------------------------------------------------------------------
*
    GOSUB ADD.INT.CONDITIONS
    GOSUB ADD.BONUS.CONDITIONS
    GOSUB ADD.CHARGE.CONDITIONS
*
RETURN
*
*-----------------------------------------------------------------------------
ADD.INT.CONDITIONS:
*-----------------------------------------------------------------------------
*
    PROD.LINES = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefIntProdLine>
    PROD.GROUPS = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefIntProdGroup>
    PRODUCTS = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefIntProduct>
    PROPERTIES = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefIntProperty>
    CURRENCIES = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefIntCurrency>
    OPERANDS = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefIntOperand>
    MARGINS = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefIntMargin>
    NUM.PROD.LINES = DCOUNT(PROD.LINES,@VM)
    FOR PROD.COUNTER = 1 TO NUM.PROD.LINES        ;*** go through each product line
        CURRENCY.LIST = CURRENCIES<1,PROD.COUNTER>
        NUM.CURRENCIES = DCOUNT(CURRENCY.LIST,@SM)
        FOR CURR.COUNTER = 1 TO NUM.CURRENCIES    ;*** but we have to take each currency as a separate product line so loop here, NOT in the common routine
            THIS.CURRENCY = CURRENCY.LIST<1,1,CURR.COUNTER>
            THIS.PROPERTY = PROPERTIES<1,PROD.COUNTER,CURR.COUNTER>
            GOSUB GET.LINE.KEY
            IF THIS.PROPERTY = "" THEN
                PROPERTY.TEXT = "All Interest"
            END ELSE
                R.AA.PROPERTY = ""
                R.AA.PROPERTY = AA.ProductFramework.Property.Read(THIS.PROPERTY, READ.ERR)
                PROPERTY.TEXT = R.AA.PROPERTY<AA.ProductFramework.Property.PropDescription,EB.SystemTables.getLngg()>
            END
            THIS.OPERAND = OPERANDS<1,PROD.COUNTER,CURR.COUNTER>
            IF THIS.OPERAND = "ADD" THEN
                MARGIN.TEXT = "% Premium on ":PROPERTY.TEXT
            END ELSE
                MARGIN.TEXT = "% Reduction on ":PROPERTY.TEXT
            END
            THIS.MARGIN = FMT(MARGINS<1,PROD.COUNTER,CURR.COUNTER>,2)
            REP.LINES<LINE.POS,6> = THIS.MARGIN:MARGIN.TEXT
        NEXT CURR.COUNTER
    NEXT PROD.COUNTER
*
RETURN
*
*-----------------------------------------------------------------------------
ADD.BONUS.CONDITIONS:
*-----------------------------------------------------------------------------
*
    PROD.LINES = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefBonusProdLine>
    PROD.GROUPS = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefBonusProdGroup>
    PRODUCTS = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefBonusProduct>
    PROPERTIES = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefBonusProperty>
    CURRENCIES = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefBonusCurrency>
    UPLIFTS = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefBonusUplift>
    AMOUNTS = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefBonusAmount>
    NUM.PROD.LINES = DCOUNT(PROD.LINES,@VM)
    FOR PROD.COUNTER = 1 TO NUM.PROD.LINES
        CURRENCY.LIST = CURRENCIES<1,PROD.COUNTER>
        NUM.CURRENCIES = DCOUNT(CURRENCY.LIST,@SM)
        FOR CURR.COUNTER = 1 TO NUM.CURRENCIES
            THIS.CURRENCY = CURRENCY.LIST<1,1,CURR.COUNTER>
            THIS.PROPERTY = PROPERTIES<1,PROD.COUNTER,CURR.COUNTER>
            GOSUB GET.LINE.KEY
            IF THIS.PROPERTY = "" THEN
                PROPERTY.TEXT = "All Bonuses"
            END ELSE
                R.AA.PROPERTY = ""
                R.AA.PROPERTY = AA.ProductFramework.Property.Read(THIS.PROPERTY, READ.ERR)
                PROPERTY.TEXT = R.AA.PROPERTY<AA.ProductFramework.Property.PropDescription,EB.SystemTables.getLngg()>
            END
            THIS.UPLIFT = UPLIFTS<1,PROD.COUNTER,CURR.COUNTER>
            IF THIS.UPLIFT <> "" THEN
                MARGIN.TEXT = THIS.UPLIFT:"% Premium On ":PROPERTY.TEXT
            END ELSE
                MARGIN.TEXT = AMOUNTS<1,PROD.COUNTER,CURR.COUNTER>:" Fixed On ":PROPERTY.TEXT
            END
            REP.LINES<LINE.POS,7> = MARGIN.TEXT
        NEXT CURR.COUNTER
    NEXT PROD.COUNTER
*
RETURN
*
*-----------------------------------------------------------------------------
ADD.CHARGE.CONDITIONS:
*-----------------------------------------------------------------------------
*
    PROD.LINES = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefChargeProdLine>
    PROD.GROUPS = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefChargeProdGroup>
    PRODUCTS = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefChargeProduct>
    PROPERTIES = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefChargeProperty>
    CURRENCIES = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefChargeCurrency>
    DISCOUNTS = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefChargeDiscount>
    AMOUNTS = Conditions<AA.PreferentialPricing.PreferentialPricing.PrefChargeAmount>
    BEGIN CASE
        CASE PROD.LINES
            NUM.PROD.LINES = DCOUNT(PROD.LINES,@VM)
            FOR PROD.COUNTER = 1 TO NUM.PROD.LINES
                CURRENCY.LIST = CURRENCIES<1,PROD.COUNTER>
                NUM.CURRENCIES = DCOUNT(CURRENCY.LIST,@SM)
                FOR CURR.COUNTER = 1 TO NUM.CURRENCIES
                    THIS.CURRENCY = CURRENCY.LIST<1,1,CURR.COUNTER>
                    THIS.PROPERTY = PROPERTIES<1,PROD.COUNTER,CURR.COUNTER>
                    GOSUB GET.LINE.KEY
                    IF THIS.PROPERTY = "" THEN
                        PROPERTY.TEXT = "All Charges"
                    END ELSE
                        R.AA.PROPERTY = ""
                        R.AA.PROPERTY = AA.ProductFramework.Property.Read(THIS.PROPERTY, READ.ERR)
* Before incorporation : CALL F.READ("F.AA.PROPERTY",THIS.PROPERTY,R.AA.PROPERTY,F.AA.PROPERTY,READ.ERR)
                        PROPERTY.TEXT = R.AA.PROPERTY<AA.ProductFramework.Property.PropDescription,EB.SystemTables.getLngg()>
                    END
                    THIS.DISCOUNT = DISCOUNTS<1,PROD.COUNTER,CURR.COUNTER>
                    IF THIS.DISCOUNT <> "" THEN
                        CHARGE.TEXT = THIS.DISCOUNT:"% Discount On ":PROPERTY.TEXT
                    END ELSE
                        CHARGE.TEXT = AMOUNTS<1,PROD.COUNTER,CURR.COUNTER>:" Fixed On ":PROPERTY.TEXT
                    END
                    REP.LINES<LINE.POS,8> = CHARGE.TEXT
                NEXT CURR.COUNTER
            NEXT PROD.COUNTER
        CASE PROD.GROUPS
            NUM.PROD.GROUPS = DCOUNT(PROD.GROUPS,@VM)
            FOR PROD.COUNTER = 1 TO NUM.PROD.GROUPS
                CURRENCY.LIST = CURRENCIES<1,PROD.COUNTER>
                NUM.CURRENCIES = DCOUNT(CURRENCY.LIST,@SM)
                FOR CURR.COUNTER = 1 TO NUM.CURRENCIES
                    THIS.CURRENCY = CURRENCY.LIST<1,1,CURR.COUNTER>
                    THIS.PROPERTY = PROPERTIES<1,PROD.COUNTER,CURR.COUNTER>
                    GOSUB GET.LINE.KEY
                    IF THIS.PROPERTY = "" THEN
                        PROPERTY.TEXT = "All Charges"
                    END ELSE
                        R.AA.PROPERTY = ""
                        R.AA.PROPERTY = AA.ProductFramework.Property.Read(THIS.PROPERTY, READ.ERR)
* Before incorporation : CALL F.READ("F.AA.PROPERTY",THIS.PROPERTY,R.AA.PROPERTY,F.AA.PROPERTY,READ.ERR)
                        PROPERTY.TEXT = R.AA.PROPERTY<AA.ProductFramework.Property.PropDescription,EB.SystemTables.getLngg()>
                    END
                    THIS.DISCOUNT = DISCOUNTS<1,PROD.COUNTER,CURR.COUNTER>
                    IF THIS.DISCOUNT <> "" THEN
                        CHARGE.TEXT = THIS.DISCOUNT:"% Discount On ":PROPERTY.TEXT
                    END ELSE
                        CHARGE.TEXT = AMOUNTS<1,PROD.COUNTER,CURR.COUNTER>:" Fixed On ":PROPERTY.TEXT
                    END
                    REP.LINES<LINE.POS,8> = CHARGE.TEXT
                NEXT CURR.COUNTER
            NEXT PROD.COUNTER
        CASE PRODUCTS
            NUM.PROD.GROUPS = DCOUNT(PRODUCTS,@VM)
            FOR PROD.COUNTER = 1 TO NUM.PROD.GROUPS
                CURRENCY.LIST = CURRENCIES<1,PROD.COUNTER>
                NUM.CURRENCIES = DCOUNT(CURRENCY.LIST,@SM)
                FOR CURR.COUNTER = 1 TO NUM.CURRENCIES
                    THIS.CURRENCY = CURRENCY.LIST<1,1,CURR.COUNTER>
                    THIS.PROPERTY = PROPERTIES<1,PROD.COUNTER,CURR.COUNTER>
                    GOSUB GET.LINE.KEY
                    IF THIS.PROPERTY = "" THEN
                        PROPERTY.TEXT = "All Charges"
                    END ELSE
                        R.AA.PROPERTY = ""
                        R.AA.PROPERTY = AA.ProductFramework.Property.Read(THIS.PROPERTY, READ.ERR)
* Before incorporation : CALL F.READ("F.AA.PROPERTY",THIS.PROPERTY,R.AA.PROPERTY,F.AA.PROPERTY,READ.ERR)
                        PROPERTY.TEXT = R.AA.PROPERTY<AA.ProductFramework.Property.PropDescription,EB.SystemTables.getLngg()>
                    END
                    THIS.DISCOUNT = DISCOUNTS<1,PROD.COUNTER,CURR.COUNTER>
                    IF THIS.DISCOUNT <> "" THEN
                        CHARGE.TEXT = THIS.DISCOUNT:"% Discount On ":PROPERTY.TEXT
                    END ELSE
                        CHARGE.TEXT = AMOUNTS<1,PROD.COUNTER,CURR.COUNTER>:" Fixed On ":PROPERTY.TEXT
                    END
                    REP.LINES<LINE.POS,8> = CHARGE.TEXT
                NEXT CURR.COUNTER
            NEXT PROD.COUNTER
        CASE PROPERTIES
            NUM.PROPERTIES = DCOUNT(PROPERTIES,@SM)
            CURRENCY.LIST = CURRENCIES
            FOR PROD.COUNTER = 1 TO NUM.PROPERTIES
                NUM.CURRENCIES = DCOUNT(CURRENCY.LIST,@SM)
                FOR CURR.COUNTER = 1 TO NUM.CURRENCIES
                    THIS.CURRENCY = CURRENCY.LIST<1,1,CURR.COUNTER>
                    THIS.PROPERTY = PROPERTIES<1,PROD.COUNTER,CURR.COUNTER>
                    GOSUB GET.LINE.KEY
                    IF THIS.PROPERTY = "" THEN
                        PROPERTY.TEXT = "All Charges"
                    END ELSE
                        R.AA.PROPERTY = ""
                        R.AA.PROPERTY = AA.ProductFramework.Property.Read(THIS.PROPERTY, READ.ERR)
* Before incorporation : CALL F.READ("F.AA.PROPERTY",THIS.PROPERTY,R.AA.PROPERTY,F.AA.PROPERTY,READ.ERR)
                        PROPERTY.TEXT = R.AA.PROPERTY<AA.ProductFramework.Property.PropDescription,EB.SystemTables.getLngg()>
                    END
                    THIS.DISCOUNT = DISCOUNTS<1,PROD.COUNTER,CURR.COUNTER>
                    IF THIS.DISCOUNT <> "" THEN
                        CHARGE.TEXT = THIS.DISCOUNT:"% Discount On ":PROPERTY.TEXT
                    END ELSE
                        CHARGE.TEXT = AMOUNTS<1,PROD.COUNTER,CURR.COUNTER>:" Fixed On ":PROPERTY.TEXT
                    END
                    REP.LINES<LINE.POS,8> = CHARGE.TEXT
                NEXT CURR.COUNTER
            NEXT PROD.COUNTER
    END CASE
*
RETURN
*
*-----------------------------------------------------------------------------
GET.LINE.KEY:
*-----------------------------------------------------------------------------
*
*** This finds the unique line of the report this item should be added to
*
    THIS.PROD.LINE = PROD.LINES<1,PROD.COUNTER>
    THIS.PROD.GROUP = PROD.GROUPS<1,PROD.COUNTER>
    THIS.PRODUCT = PRODUCTS<1,PROD.COUNTER>
    IF THIS.CURRENCY = "" THEN
        THIS.CURRENCY = "All"
    END
*
*** See what the lowest level of "product" we have and use that's description
*
    BEGIN CASE
        CASE THIS.PRODUCT <> ""
            R.AA.PRODUCT = AA.ProductManagement.Product.Read(THIS.PRODUCT, READ.ERR)
            PRODUCT.DESCRIPTION = R.AA.PRODUCT<AA.ProductManagement.Product.PdtDescription,EB.SystemTables.getLngg()>
        CASE THIS.PROD.GROUP <> ""
            R.AA.PRODUCT.GROUP = AA.ProductFramework.ProductGroup.Read(THIS.PROD.GROUP, READ.ERR)
            PRODUCT.DESCRIPTION = R.AA.PRODUCT.GROUP<AA.ProductFramework.ProductGroup.PgDescription,EB.SystemTables.getLngg()>
        CASE THIS.PROD.LINE <> ""
            R.AA.PRODUCT.LINE = AA.ProductFramework.ProductLine.Read(THIS.PROD.LINE, READ.ERR)
            PRODUCT.DESCRIPTION = "All ":R.AA.PRODUCT.LINE<AA.ProductFramework.ProductLine.PlDescription,EB.SystemTables.getLngg()>
        CASE 1
            PRODUCT.DESCRIPTION = "All Products"
    END CASE
    THIS.LINE.KEY = THIS.AA:DELIM:THIS.PROD.LINE:DELIM:THIS.PROD.GROUP:DELIM:THIS.PRODUCT:DELIM:THIS.CURRENCY

    LOCATE THIS.LINE.KEY IN LINE.KEYS<1,1> BY "AL" SETTING LINE.POS THEN
        INS THIS.LINE.KEY BEFORE LINE.KEYS<1,LINE.POS>
        INS "*" BEFORE REP.LINES<LINE.POS>        ;***inserting a "" doesn't work in some releases of jbase
        REP.LINES<LINE.POS,1> = THIS.CUST.SHORT.NAME
        REP.LINES<LINE.POS,2> = ARRANGEMENT.DESCRIPTION
        REP.LINES<LINE.POS,3> = THIS.AA
        REP.LINES<LINE.POS,4> = PRODUCT.DESCRIPTION
        REP.LINES<LINE.POS,5> = THIS.CURRENCY
        REP.LINES<LINE.POS,9> = VARIATION
    END ELSE
*
*** We haven't got this unique key so add the first five reporting fields and
*** add it to the index
        INS THIS.LINE.KEY BEFORE LINE.KEYS<1,LINE.POS>
        INS "*" BEFORE REP.LINES<LINE.POS>        ;***inserting a "" doesn't work in some releases of jbase
        REP.LINES<LINE.POS,1> = THIS.CUST.SHORT.NAME
        REP.LINES<LINE.POS,2> = ARRANGEMENT.DESCRIPTION
        REP.LINES<LINE.POS,3> = THIS.AA
        REP.LINES<LINE.POS,4> = PRODUCT.DESCRIPTION
        REP.LINES<LINE.POS,5> = THIS.CURRENCY
        REP.LINES<LINE.POS,9> = VARIATION
    END
*
RETURN
*
*-----------------------------------------------------------------------------
INITIALISE:
*-----------------------------------------------------------------------------
*
    F.AA.CUSTOMER.ARRANGEMENT = ""
*
    F.AA.ARRANGEMENT = ""
*
    F.AA.PRODUCT = ""
*
    F.AA.PROPERTY = ""
*
    F.AA.PRODUCT.GROUP = ""
*
    F.AA.PRODUCT.LINE = ""
*
    F.CUSTOMER.LOC = ""
*
    F.AA.ARR.PREFERENTIAL.PRICING = ""
*
    YR.VARIABLE.NAMES = ""
    YR.VARIABLE.VALUES = ""
    EB.Browser.SystemGetuservariables(YR.VARIABLE.NAMES,YR.VARIABLE.VALUES)
*
    LOCATE 'CURRENT.CUSTOMER' IN YR.VARIABLE.NAMES SETTING YR.POS.1 THEN
        THIS.CUSTOMER.ID = YR.VARIABLE.VALUES<YR.POS.1>
    END
*
    ENQ.DATA = ""
    LINE.NUM = 1
    THIS.CUSTOMER.ID = ""
    LINE.KEYS = ""  ;*** this hold the key for each line so we can consolidate the INT, CHARGE and BONUS parts
    REP.LINES = ""  ;*** this holds the consolodated data for each line
*
    GOSUB FRAME.SEL.CMD
*
RETURN
*
*-----------------------------------------------------------------------------
FRAME.SEL.CMD:
*-----------------------------------------------------------------------------
*
*** See what we were called with. It should either be an ARRANGEMENT number or a CUSTOMER
*** operator should be EQ and if we have both the ARRANGMENT wins
*
    SEL.FLD = ''
    D.POS = ''
    TMP.DFIELDS = EB.Reports.getDFields()
    LOOP
        REMOVE SEL.FLD FROM TMP.DFIELDS SETTING D.POS
    WHILE SEL.FLD :D.POS
        SEL.I += 1
        BEGIN CASE
            CASE SEL.FLD = "ARRANGEMENT"
                THIS.AA = EB.Reports.getDRangeAndValue()<SEL.I>
            CASE SEL.FLD = "CUSTOMER"
                THIS.CUSTOMER.ID = EB.Reports.getDRangeAndValue()<SEL.I>
            CASE 1
        END CASE
    REPEAT
*
RETURN
*
*-----------------------------------------------------------------------------
READ.CUSTOMER:
*-----------------------------------------------------------------------------
*
    READ.ERR = ""
    R.CUSTOMER.LOC = ST.Customer.Customer.Read(THIS.CUSTOMER.ID, READ.ERR)
    THIS.CUST.SHORT.NAME = R.CUSTOMER.LOC<ST.Customer.Customer.EbCusShortName>
    IF THIS.CUST.SHORT.NAME = "" THEN
        THIS.CUST.SHORT.NAME = THIS.CUSTOMER.ID
    END
*
RETURN
*
*-----------------------------------------------------------------------------
FINISH:
*-----------------------------------------------------------------------------
*
*** Here we convert REP.LINES into ENQ.DATA
*

    LINE.COUNT = 1
    LAST.AA = ""
    LOOP
        NEXT.LINE = REP.LINES<LINE.COUNT>
    UNTIL NEXT.LINE = "" DO
        THIS.AA = NEXT.LINE<1,3>
        IF THIS.AA = LAST.AA THEN
            NEXT.LINE<1,2> = ""
            NEXT.LINE<1,3> = ""
            NEXT.LINE<1,9> = ""
        END ELSE
            LAST.AA = THIS.AA
        END
        IF LINE.COUNT <> 1 THEN
            NEXT.LINE<1,1> = ""         ;*** remove the name
        END
        ENQ.DATA<-1> = NEXT.LINE

        LINE.COUNT +=1
    REPEAT
*
    CONVERT @VM TO DELIM IN ENQ.DATA
*
RETURN
END
