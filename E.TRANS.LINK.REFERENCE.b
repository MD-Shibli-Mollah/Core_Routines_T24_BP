* @ValidationCode : MjotMTMxNDcxOTE0OTpDcDEyNTI6MTU0Mjc5OTAxNjY5NzpwbWFoYTozOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgxMS4yMDE4MTAyMi0xNDA2OjI0NTo5NQ==
* @ValidationInfo : Timestamp         : 21 Nov 2018 16:46:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : pmaha
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 95/245 (38.7%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-83</Rating>
*-----------------------------------------------------------------------------
* Version 3 12/06/01  GLOBUS Release No. 200602 09/01/06
*
$PACKAGE EB.ModelBank
	  		
SUBROUTINE E.TRANS.LINK.REFERENCE
*
*************************************************************************
*                                                                       *
*  Routine     :  E.TRANS.LINK.REFERENCE                                *
*                                                                       *
*************************************************************************
*                                                                       *
*  Description :  TRANS.LINK.REFERENCE enquiry.                         *
*                                                                       *
*                 Enquiry to display details of all transaction refs    *
*                 for a trans.link.reference record.                    *
*                                                                       *
*                 Enquiry data is populated into the common enquiry     *
*                 variable R.RECORD.                                    *
*                                                                       *
*                 R.RECORD array :                                      *
*                                                                       *
*                 R.RECORD<10>  -  Transaction Ref Ids.                 *
*                 R.RECORD<11>  -  Transaction Applications.            *
*                 R.RECORD<12>  -  Transaction Types.                   *
*                 R.RECORD<13>  -  Transaction Customer Numbers.        *
*                 R.RECORD<14>  -  Transaction Currencies.              *
*                 R.RECORD<15>  -  Transaction Amounts.                 *
*                 R.RECORD<16>  -  Transaction Interest Rates.          *
*                 R.RECORD<17>  -  Transaction Value/Start Dates.       *
*                 R.RECORD<18>  -  Transaction Maturity Dates.          *
*                                                                       *
*************************************************************************
*                                                                       *
*  Modifications :                                                      *
*                                                                       *
*  xx/xx/95   -   GB                                                    *
*                 Initial Version.                                      *
*                                                                       *
* 25/05/2015 - Defect 1350116/ Task 1354983                             *
*              To avoid OPF error raised for uninstalled Products       *
*              Condition is added to check if the product is installed. *
*                                                                       *
* 26/05/17 - Task - 2126523 /Enhancement - 2117822                      *
*            AC,SW,MM,FX and SC product availability check has been done*
*            on the Company and skips relevant READ or OPF if product   *
*            not installed.                                             *
*                                                                       *
* 09/11/18 - Enhancement 2822523 / Task 2847649
*          - Incorporation of EB_ModelBank component
*************************************************************************
*
*  Insert files.
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.SWAP
    $INSERT I_F.SWAP.BALANCES
    $INSERT I_F.MM.MONEY.MARKET
    $INSERT I_F.LD.LOANS.AND.DEPOSITS
*$INSERT I_F.FOREIGN.EXCHANGE
    $INSERT I_F.FOREX
    $INSERT I_F.SEC.TRADE
    $INSERT I_F.FRA.DEAL
    $INSERT I_F.MG.MORTGAGE
    $INSERT I_F.COMPANY
*
*************************************************************************
*
    CALL Product.isInCompany("AC", AC.isInstalled) ; * Check for AC module in the company'

    IF AC.isInstalled THEN
        GOSUB INITIALISATION
        GOSUB PROCESS.LINK.REF
    END ELSE
        ENQ.ERROR="EB-PRODUCT.NOT.INSTALLED":@FM:"AC"
    END
*
RETURN
*
************************************************************************
*
***************
INITIALISATION:
***************
*
*  Open files.
*
    
    F.TRANS.LINK.REF = ""
    CALL OPF("F.TRANS.LINK.REFERENCE",F.TRANS.LINK.REF)
*
    LOCATE "SW" IN R.COMPANY(EB.COM.APPLICATIONS)<1, 1> SETTING SW.INSTALLED THEN   ; *Check for SW module in the company'
        F.SWAP = ""
        F.SWAP.BALANCES = ""
        CALL OPF("F.SWAP", F.SWAP)
        CALL OPF("F.SWAP.BALANCES", F.SWAP.BALANCES)
        
    END
*

*
    LOCATE "MM" IN R.COMPANY(EB.COM.APPLICATIONS)<1, 1> SETTING MM.INSTALLED THEN ; * Check for MM module in the company'
        F.MM.MONEY.MARKET = ""
        CALL OPF("F.MM.MONEY.MARKET", F.MM.MONEY.MARKET)
    END
*
    F.LD.LOANS.AND.DEPS = ""
    LD.INSTALLED=""
    LOCATE "LD" IN R.COMPANY(EB.COM.APPLICATIONS)<1, 1> SETTING LD.INSTALLED THEN  ;* Checking if LD Product is Installed
        CALL OPF("F.LD.LOANS.AND.DEPOSITS", F.LD.LOANS.AND.DEPS)
    END
*
    LOCATE "FX" IN R.COMPANY(EB.COM.APPLICATIONS)<1, 1> SETTING FX.INSTALLED THEN ; * Check for FX module in the company'
        F.FOREX = ""
        CALL OPF("F.FOREX", F.FOREX)
    END
*
    LOCATE "SC" IN R.COMPANY(EB.COM.APPLICATIONS)<1, 1> SETTING SC.INSTALLED THEN ; * Check for SC module in the company'
        F.SEC.TRADE = ""
        CALL OPF("F.SEC.TRADE", F.SEC.TRADE)
    END
*
    F.FRA.DEAL = ""
    FRA.INSTALLED=""
    LOCATE "FR" IN R.COMPANY(EB.COM.APPLICATIONS)<1, 1> SETTING FRA.INSTALLED THEN  ;* Check for FR module in the company'
        CALL OPF("F.FRA.DEAL", F.FRA.DEAL)
    END
*
    F.MG.MORTGAGE = ""
    MG.INSTALLED=""
    LOCATE "MG" IN R.COMPANY(EB.COM.APPLICATIONS)<1, 1> SETTING MG.INSTALLED THEN  ;* Checking if MG Product is Installed
        CALL OPF("F.MG.MORTGAGE", F.MG.MORTGAGE)
    END
    R.RECORD = ""
    ETEXT = ""
    TRANS.REF.ID = ""
    SORT.KEY = ""
    ENQ.SORT.LIST = ""
    POS = ""
*
RETURN
*
*************************************************************************
*
*****************
PROCESS.LINK.REF:
*****************
*
*  Read TRANS.LINK.REFERENCE file.
*  Obtain list of transaction references.
*  Determine the Globus application for each trans ref and
*  obtain data from relevant application files.
*
    R.TRANS.LINK.REF = ""
*
    READ R.TRANS.LINK.REF FROM F.TRANS.LINK.REF, ID THEN
*
        TOT.NUM.TRANS.REF = DCOUNT(R.TRANS.LINK.REF,@FM)
*
        FOR I = 1 TO TOT.NUM.TRANS.REF
*
            TRANS.REF.ID = R.TRANS.LINK.REF<I>
*
            BEGIN CASE
                CASE TRANS.REF.ID[1,2] = "FR"       ; * FRA.
                    GOSUB PROCESS.FR.CONTRACT
*
                CASE TRANS.REF.ID[1,2] = "FX"       ; * Forex.
                    GOSUB PROCESS.FX.CONTRACT
*
                CASE TRANS.REF.ID[1,2] = "LD"       ; * Loans and Deposits.
                    GOSUB PROCESS.LD.CONTRACT
*
                CASE TRANS.REF.ID[1,2] = "MM"       ; * Money Market.
                    GOSUB PROCESS.MM.CONTRACT
*
                CASE TRANS.REF.ID[1,2] = "MG"       ; * Mortgages.
                    GOSUB PROCESS.MG.CONTRACT
*
                CASE TRANS.REF.ID[1,2] = "SC"       ; * Securities.
                    GOSUB PROCESS.SC.CONTRACT
*
                CASE TRANS.REF.ID[1,2] = "SL"       ; * Syndicated Loans.
                    GOSUB PROCESS.SL.CONTRACT
*
                CASE TRANS.REF.ID[1,2] = "SW"       ; * Swaps.
                    GOSUB PROCESS.SW.CONTRACT
            END CASE
*
        NEXT I
*
        VM.COUNT = DCOUNT(R.RECORD<10>,@VM)
*
    END ELSE
        R.TRANS.LINK.REF = ""
    END
*
RETURN
*
*************************************************************************
*
********************
PROCESS.FR.CONTRACT:
********************
*
    R.FRA.DEAL = ""
    CALL F.READ("F.FRA.DEAL", TRANS.REF.ID, R.FRA.DEAL, F.FRA.DEAL, ETEXT)
*
    IF NOT(ETEXT) THEN
*
        APPLICATION = "FRA.DEAL"
        TRANS.TYPE = "FR-00"
*
        CUST.NUMBER = R.FRA.DEAL<FRD.COUNTERPARTY>
        CURRENCY = R.FRA.DEAL<FRD.FRA.CURRENCY>
        AMOUNT = R.FRA.DEAL<FRD.FRA.AMOUNT>
        INTR.RATE = R.FRA.DEAL<FRD.INTEREST.RATE>
        VALUE.DATE = R.FRA.DEAL<FRD.START.DATE>
        MATURITY.DATE = R.FRA.DEAL<FRD.MATURITY.DATE>
*
        GOSUB BUILD.ENQUIRY.DATA        ; *  Add to R.RECORD.
*
    END
*
RETURN
*
*************************************************************************
*
********************
PROCESS.FX.CONTRACT:
********************
*
    R.FOREX = ""
    CALL F.READ("F.FOREX", TRANS.REF.ID, R.FOREX, F.FOREX, ETEXT)
*
    IF NOT(ETEXT) THEN
*
        APPLICATION = "FOREX"
        TRANS.TYPE = "FX-CB"
*
        CUST.NUMBER = R.FOREX<FX.COUNTERPARTY>
        CURRENCY = R.FOREX<FX.CURRENCY.BOUGHT>
        AMOUNT = R.FOREX<FX.AMOUNT.BOUGHT> * -1
        INTR.RATE = R.FOREX<FX.INT.RATE.BUY>
        VALUE.DATE = R.FOREX<FX.SPOT.DATE>
        MATURITY.DATE = R.FOREX<FX.DEL.DATE.BUY,1>
*
        GOSUB BUILD.ENQUIRY.DATA        ; *  Add to R.RECORD.
*
        TRANS.TYPE = "FX-CS"
*
        CUST.NUMBER = R.FOREX<FX.COUNTERPARTY>
        CURRENCY = R.FOREX<FX.CURRENCY.SOLD>
        AMOUNT = R.FOREX<FX.AMOUNT.SOLD>
        INTR.RATE = R.FOREX<FX.INT.RATE.SELL>
        VALUE.DATE = R.FOREX<FX.SPOT.DATE>
        MATURITY.DATE = R.FOREX<FX.DEL.DATE.SELL,1>
*
        GOSUB BUILD.ENQUIRY.DATA        ; * Add to R.RECORD.
*
    END
*
RETURN
*
*************************************************************************
*
********************
PROCESS.LD.CONTRACT:
********************
*
    R.LD.LOANS.AND.DEPS = ""
    CALL F.READ("F.LD.LOANS.AND.DEPOSITS", TRANS.REF.ID, R.LD.LOANS.AND.DEPS, F.LD.LOANS.AND.DEPS, ETEXT)
*
    IF NOT(ETEXT) THEN
*
        CATEG.CODE = R.LD.LOANS.AND.DEPS<LD.CATEGORY>
        IF (CATEG.CODE >= 21001) AND (CATEG.CODE <= 21049) THEN
            TRANS.TYPE = "LD-D"
            AMOUNT = R.LD.LOANS.AND.DEPS<LD.AMOUNT,1>
        END ELSE
            TRANS.TYPE = "LD-L"
            AMOUNT = R.LD.LOANS.AND.DEPS<LD.AMOUNT,1> * -1
        END
*
        APPLICATION = "LD.LOANS.AND.DEPOSITS"
*
        CUST.NUMBER = R.LD.LOANS.AND.DEPS<LD.CUSTOMER.ID>
        CURRENCY = R.LD.LOANS.AND.DEPS<LD.CURRENCY>
        INTR.RATE = R.LD.LOANS.AND.DEPS<LD.INTEREST.RATE,1>
        VALUE.DATE = R.LD.LOANS.AND.DEPS<LD.VALUE.DATE>
        MATURITY.DATE = R.LD.LOANS.AND.DEPS<LD.FIN.MAT.DATE>
*
        GOSUB BUILD.ENQUIRY.DATA        ; *  Add to R.RECORD.
*
    END
*
RETURN
*
*************************************************************************
*
********************
PROCESS.MM.CONTRACT:
********************
*
    R.MM.MONEY.MARKET = ""
    CALL F.READ("F.MM.MONEY.MARKET", TRANS.REF.ID, R.MM.MONEY.MARKET, F.MM.MONEY.MARKET, ETEXT)
*
    IF NOT(ETEXT) THEN
*
        CATEG.CODE = R.MM.MONEY.MARKET<MM.CATEGORY>
        IF (CATEG.CODE >= 21001) AND (CATEG.CODE <= 21049) THEN
            TRANS.TYPE = "MM-D"
            AMOUNT = R.MM.MONEY.MARKET<MM.PRINCIPAL>
        END ELSE
            TRANS.TYPE = "MM-L"
            AMOUNT = R.MM.MONEY.MARKET<MM.PRINCIPAL> * -1
        END
*
        APPLICATION = "MM.MONEY.MARKET"
*
        CUST.NUMBER = R.MM.MONEY.MARKET<MM.CUSTOMER.ID>
        CURRENCY = R.MM.MONEY.MARKET<MM.CURRENCY>
        INTR.RATE = R.MM.MONEY.MARKET<MM.INTEREST.RATE>
        VALUE.DATE = R.MM.MONEY.MARKET<MM.VALUE.DATE>
        MATURITY.DATE = R.MM.MONEY.MARKET<MM.MATURITY.DATE>
*
        GOSUB BUILD.ENQUIRY.DATA        ; *  Add to R.RECORD.
*
    END
*
RETURN
*
*************************************************************************
*
********************
PROCESS.MG.CONTRACT:
********************
*
    R.MG.MORTGAGE = ""
    CALL F.READ("F.MG.MORTGAGE", TRANS.REF.ID, R.MG.MORTGAGE, F.MG.MORTGAGE, ETEXT)
*
    IF NOT(ETEXT) THEN
*
        APPLICATION = "MG.MORTGAGE"
        TRANS.TYPE = "MG-00"
*
        CUST.NUMBER = R.MG.MORTGAGE<MG.CUSTOMER>
        CURRENCY = R.MG.MORTGAGE<MG.CURRENCY>
        AMOUNT = R.MG.MORTGAGE<MG.PRINCIPAL.AMOUNT> * -1
        INTR.RATE = R.MG.MORTGAGE<MG.INTEREST.RATE,1>
        VALUE.DATE = R.MG.MORTGAGE<MG.VALUE.DATE>
        MATURITY.DATE = R.MG.MORTGAGE<MG.MATURITY.DATE>
*
        GOSUB BUILD.ENQUIRY.DATA        ; *  Add to R.RECORD.
*
    END
*
RETURN
*
*************************************************************************
*
********************
PROCESS.SC.CONTRACT:
********************
*
    R.SEC.TRADE = ""
    CALL F.READ("F.SEC.TRADE", TRANS.REF.ID, R.SEC.TRADE, F.SEC.TRADE, ETEXT)
*
    IF NOT(ETEXT) THEN
*
        APPLICATION = "SEC.TRADE"
        TRANS.TYPE = "SC-00"
*
        CUST.NUMBER = R.SEC.TRADE<SC.SBS.CUSTOMER.NO,1>
        CURRENCY = R.SEC.TRADE<SC.SBS.SECURITY.CURRENCY>
        AMOUNT = R.SEC.TRADE<SC.SBS.CUST.TOT.NOM,1>
        INTR.RATE = R.SEC.TRADE<SC.SBS.INTEREST.RATE>
        VALUE.DATE = R.SEC.TRADE<SC.SBS.VALUE.DATE>
        MATURITY.DATE = R.SEC.TRADE<SC.SBS.MATURITY.DATE>
*
        GOSUB BUILD.ENQUIRY.DATA        ; *  Add to R.RECORD.
*
    END
*
RETURN
*
*************************************************************************
*
********************
PROCESS.SL.CONTRACT:
********************
*
***!  R.SL.SYNDICATED.LOANS = ""
***!  CALL F.READ("F.SL.SYNDICATED.LOANS", TRANS.REF.ID, R.SL.SYNDICATED.LOANS, F.SL.SYNDICATED.LOANS, ETEXT)
*
***!  IF NOT(ETEXT) THEN
*
***!     CATEG.CODE = R.SL.SYNDICATED.LOANS<SL.SYL.CATEGORY>
***!     IF (CATEG.CODE >= 21101) AND (CATEG.CODE <= 21110) THEN
***!        TRANS.TYPE = "SL-L"      ; * Commitment.
***!        AMOUNT     = R.LD.LOANS.AND.DEPS<LD.AMOUNT,1> * -1
***!     END ELSE
***!        TRANS.TYPE = "SL-D"      ; * Tranche, Drawdown.
***!        AMOUNT     = R.LD.LOANS.AND.DEPS<LD.AMOUNT,1>
***!     END
*
***!     APPLICATION = "SL.SYNDICATED.LOANS"
***!     TRANS.TYPE  = "SL-00"
*
***!     CUST.NUMBER   = R.SL.SYNDICATED.LOANS<SL.SYL.CUSTOMER.ID>
***!     CURRENCY      = R.SL.SYNDICATED.LOANS<SL.SYL.CURRENCY>
***!     AMOUNT        = R.SL.SYNDICATED.LOANS<SL.SYL.AMOUNT>
***!     INTR.RATE     = R.SL.SYNDICATED.LOANS<SL.SYL.INTEREST.RATE,1>
***!     VALUE.DATE    = R.SL.SYNDICATED.LOANS<SL.SYL.VALUE.DATE>
***!     MATURITY.DATE = R.SL.SYNDICATED.LOANS<SL.SYL.MATURITY.DATE>
*
***!     GOSUB BUILD.ENQUIRY.DATA        ; *  Add to R.RECORD.
*
***!  END
*
RETURN
*
*************************************************************************
*
********************
PROCESS.SW.CONTRACT:
********************
*
    R.SWAP = ""
    CALL F.READ("F.SWAP", TRANS.REF.ID, R.SWAP, F.SWAP, ETEXT)
*
    IF NOT(ETEXT) THEN
*
        SW.BAL.ID.A = TRANS.REF.ID:".A"
        SW.BAL.ID.L = TRANS.REF.ID:".L"
*
*  Asset Leg.
*
        R.SWAP.BALANCES = ""
        CALL F.READ("F.SWAP.BALANCES", SW.BAL.ID.A, R.SWAP.BALANCES, F.SWAP.BALANCES, ETEXT)
*
        IF NOT(ETEXT) THEN
*
            TRANS.REF.ID = SW.BAL.ID.A
            APPLICATION = "SWAP.BALANCES"
            TRANS.TYPE = "SW-SA"
            CUST.NUMBER = R.SWAP<SW.CUSTOMER>
            VALUE.DATE = R.SWAP<SW.VALUE.DATE>
            MATURITY.DATE = R.SWAP<SW.MATURITY.DATE>
            CURRENCY = R.SWAP.BALANCES<SW.BAL.CURRENCY>
            AMOUNT = R.SWAP.BALANCES<SW.BAL.PRINCIPAL,1>
            INTR.RATE = R.SWAP.BALANCES<SW.BAL.INTEREST.RATE,1>
*
            GOSUB BUILD.ENQUIRY.DATA     ; * Add to R.RECORD.
*
        END
*
*  Liability Leg.
*
        R.SWAP.BALANCES = ""
        CALL F.READ("F.SWAP.BALANCES", SW.BAL.ID.L, R.SWAP.BALANCES, F.SWAP.BALANCES, ETEXT)
*
        IF NOT(ETEXT) THEN
*
            TRANS.REF.ID = SW.BAL.ID.L
            APPLICATION = "SWAP.BALANCES"
            TRANS.TYPE = "SW-SL"
            CUST.NUMBER = R.SWAP<SW.CUSTOMER>
            VALUE.DATE = R.SWAP<SW.VALUE.DATE>
            MATURITY.DATE = R.SWAP<SW.MATURITY.DATE>
            CURRENCY = R.SWAP.BALANCES<SW.BAL.CURRENCY>
            AMOUNT = R.SWAP.BALANCES<SW.BAL.PRINCIPAL,1> * -1
            INTR.RATE = R.SWAP.BALANCES<SW.BAL.INTEREST.RATE,1>
*
            GOSUB BUILD.ENQUIRY.DATA     ; * Add to R.RECORD.
*
        END
    END
*
RETURN
*
*************************************************************************
*
*******************
BUILD.ENQUIRY.DATA:
*******************
*
*  Build enquiry data display array R.RECORD.
*
    SORT.KEY = CURRENCY:VALUE.DATE
    LOCATE SORT.KEY IN ENQ.SORT.LIST<1,1> BY "AL" SETTING POS ELSE NULL
    INS SORT.KEY BEFORE ENQ.SORT.LIST<1,POS>

    INS TRANS.REF.ID BEFORE R.RECORD<10,POS>
    INS APPLICATION BEFORE R.RECORD<11,POS>
    INS TRANS.TYPE BEFORE R.RECORD<12,POS>
    INS CUST.NUMBER BEFORE R.RECORD<13,POS>
    INS CURRENCY BEFORE R.RECORD<14,POS>
    INS AMOUNT BEFORE R.RECORD<15,POS>
    INS INTR.RATE BEFORE R.RECORD<16,POS>
    INS VALUE.DATE BEFORE R.RECORD<17,POS>
    INS MATURITY.DATE BEFORE R.RECORD<18,POS>
*
RETURN
*
*************************************************************************
*
END
