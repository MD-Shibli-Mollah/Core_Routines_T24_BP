* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*
*-----------------------------------------------------------------------------
* <Rating>2277</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FT.BulkProcessing
    SUBROUTINE FT.BK.DEBIT.AC.CROSSVAL
************************************************************************
* Routine for BULK DEBIT Crossvalidation of AC Txn type
*
************************************************************************
* 15/07/04 - BG_100006954
*            New Version
*
* 04/08/04 - BG_100007047
*            Single Dr/Cr transaction should not be allowed.
*
* 1/08/05 - CI_10032367
*           New fields SEND.TO.PARTY & BK.TO.BK.OUT introduced.
*
* 01/06/06 - CI_10041553
*            Remove FT.NULL.CHK validation as SNED.TO.PARTY and BK.TO.BK
*            are not madatory for BULK.DEBIT.AC.
*
* 20/04/07 - BG_100013651
*            Bug fix.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
*17/07/15 - Defect 1409118 / Task 1411647
*         - Code fixes for tafc compilation
************************************************************************
    $USING EB.SystemTables
    $USING EB.Utility
    $USING EB.Delivery
    $USING EB.API
    $USING EB.ErrorProcessing
    $USING EB.Foundation
    $USING EB.Template
    $USING FT.Config
    $USING AC.AccountOpening
    $USING ST.CompanyCreation
    $USING ST.ExchangeRate
    $USING FT.BulkProcessing
*
************************************************************************
*
*
************************************************************************
*
    GOSUB INITIALISE
*
    GOSUB REPEAT.CHECK.FIELDS
*
    GOSUB REAL.CROSSVAL
*

    IF NOT(EB.SystemTables.getEtext()) AND NOT(EB.SystemTables.getE()) AND NOT(EB.SystemTables.getEndError())THEN
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracTreasuryRate) = '' THEN EB.SystemTables.setRNew(FT.BulkProcessing.BulkDebitAc.BkdracTreasuryRate, EXCH.RATE)
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCrAmount) = '' THEN EB.SystemTables.setRNew(FT.BulkProcessing.BulkDebitAc.BkdracCrAmount, TOTAL.CREDIT.AMOUNT)
    END

    RETURN
*
************************************************************************
*
REAL.CROSSVAL:
*
* Real cross validation goes here....
*


*----------------------
* Check is done to ensure that Dr acct is not duplicated in Cr acct.
*----------------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracDrAccount)
    DEBIT.ACCT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracDrAccount)
    CREDIT.ACCT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCrAccount)
    LOCATE CREDIT.ACCT IN DEBIT.ACCT<1,1> SETTING POS ELSE POS = ''
    IF POS THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracDrAccount); EB.SystemTables.setAv(POS)
        EB.SystemTables.setEtext("FT-ACCT.CANT.BE.SAME")
        EB.ErrorProcessing.StoreEndError()
    END

*--------------------------------------------
* Crossvalidation for the multi-valued fields
*--------------------------------------------

    TOT.DR.AMT = ''

    NO.OF.DR = COUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracDrAccount), @VM)+1

    IF NO.OF.DR LE 1 THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracDrAccount); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext("FT-SINGLE.CR.DR.NOT.ALLOWED")
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END

    FOR MV = 1 TO NO.OF.DR

        *--------------------------
        * Debit currency/acct validation
        *--------------------------

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracDrCurrency)
        R.ACCOUNT.RECORD = ''
        READ.ERROR = ''
        DEBIT.ACCNO = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracDrAccount)<1,MV>
        R.ACCOUNT.RECORD = AC.AccountOpening.Account.Read(DEBIT.ACCNO, READ.ERROR)
        IF NOT(READ.ERROR) THEN
            ACC.CCY = R.ACCOUNT.RECORD<AC.AccountOpening.Account.Currency>
            BULK.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracDrCurrency)
            IF BULK.CCY NE ACC.CCY THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracDrCurrency); EB.SystemTables.setAv(MV)
                EB.SystemTables.setEtext("FT-INVALID.CCY.FOR.DB.ACC")
                EB.ErrorProcessing.StoreEndError()
            END
        END

        * suming of debit amount

        TOT.DR.AMT += EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracDrAmount)<1,MV>

        *----------------------
        * DR Value Date Validation
        *----------------------

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracDrValueDate)
        DR.VALUE.DATE = EB.SystemTables.getRNew(EB.SystemTables.getAf())<1, MV>

        IF DR.VALUE.DATE NE "" THEN
            EB.SystemTables.setAv(MV)

            * If BACK.VALUE.MAXIMUM / FORW.VALUE.MAXIMUM is 'Y' in FT.TXN.TYPE.CONDITION, then check with Today's Date
            IF BK.VAL.MAX = 'Y' THEN
                IF DR.VALUE.DATE < CHK.TODAY.DAT THEN
                    EB.SystemTables.setEtext("FT.RTN.DR.DATE.VALUE.EXCEEDS.MAX.BACKVALUE")
                    EB.ErrorProcessing.StoreEndError()
                END
            END

            IF FWD.VAL.MAX = "Y" THEN
                IF DR.VALUE.DATE > CHK.TODAY.DAT THEN
                    EB.SystemTables.setEtext("FT.RTN.DR.DATE.VALUE.EXCEEDS.MAX.FORWARDVALUE")
                    EB.ErrorProcessing.StoreEndError()
                END
            END

            * Raise an error, if debit value date is greater than FORW.VALUE.MAXIMUM from dates appln.
            IF DR.VALUE.DATE > CHK.FWD.MAX.DAT THEN
                EB.SystemTables.setEtext("FT.RTN.DATE.EXCEEDS.MAX.FORWARD")
                EB.ErrorProcessing.StoreEndError()
            END

            * Raise an error, if debit value date is lesser than BACK.VALUE.MAXIMUM from dates appln.
            IF DR.VALUE.DATE < CHK.BK.MAX.DAT THEN
                EB.SystemTables.setEtext("FT.RTN.DATE.EXCEEDS.MAX.BACK.VALUE")
                EB.ErrorProcessing.StoreEndError()
            END
        END

        * Validating ordering cust and ordering bank fields

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracOrderingCu)
        GOSUB VALIDATE.ORDERING.BANK.FIELDS

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracOrderingBk)
        GOSUB VALIDATE.ORDERING.BANK.FIELDS

        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracOrderingCu)<1,MV,1> NE '' AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracOrderingBk)<1,MV,1> NE '' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracOrderingBk); EB.SystemTables.setAv(MV); EB.SystemTables.setAs(1)
            EB.SystemTables.setEtext("FT-ORDERING.CU.ALREADY.INP")
            EB.ErrorProcessing.StoreEndError()
        END

        * CI_10032367 S
        *--------------
        * SEND.TO.PARTY
        *--------------

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracSendToParty)

        NO.OF.MV = COUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracBkToBkOut)<1,MV>,@SM) + 1      ;*BG_100013651 S/E
        FOR I = 1 TO NO.OF.MV
            EB.SystemTables.setAs(1)
            BEGIN CASE
                CASE EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracBkToBkOut)<1,MV,I> NE "" AND EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,MV> EQ ""
                    EB.SystemTables.setAv(MV)
                    EB.SystemTables.setEtext("FT.FC.INP.MISS")
                    EB.ErrorProcessing.StoreEndError()
                CASE EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracBkToBkOut)<1,MV,I> EQ '' AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracSendToParty)<1,MV> NE ''
                    EB.SystemTables.setAv(MV)
                    EB.SystemTables.setEtext("FT.FC.INP.MISS")
                    EB.ErrorProcessing.StoreEndError()
            END CASE
        NEXT I

        IF EB.SystemTables.getEndError() THEN RETURN

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracBkToBkOut)
        EB.Delivery.ValBkToBk()

        IF EB.SystemTables.getEtext() THEN
            EB.ErrorProcessing.StoreEndError()
            RETURN
        END

*** Check for Duplicate Send to Party *****

        * AF = FT.BKDRAC.SEND.TO.PARTY ; * CI_10041553 S
        * CALL FT.NULLS.CHK            ; * CI_10041553 E

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracBkToBkOut)
        EB.Template.FtNullsChk()

        * CI_10032367 E


    NEXT MV

*-----------------------
* Credit leg validations
*-----------------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracCrCurrency)
    R.ACCT.REC = ''
    AC.ERR = ''
    CREDIT.ACCNO = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCrAccount)
    R.ACCT.REC = AC.AccountOpening.Account.Read(CREDIT.ACCNO, AC.ERR)
    IF NOT(AC.ERR) THEN
        ACCT.CCY = R.ACCT.REC<AC.AccountOpening.Account.Currency>
        BUL.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCrCurrency)
        IF BUL.CCY NE ACCT.CCY THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracCrAccount)
            EB.SystemTables.setEtext("FT-INVALID.ACCT.FOR.CR.CCY")
            EB.ErrorProcessing.StoreEndError()
        END
    END

*-----------------------
* Rate fields validation
*-----------------------

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCrCurrency) = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracDrCurrency) THEN
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracTreasuryRate) NE '' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracTreasuryRate)
            EB.SystemTables.setEtext("FT.FC.INVALID.SAME.CR/DR.CCY")
            EB.ErrorProcessing.StoreEndError()
        END
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCustomerRate) NE '' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracCustomerRate)
            EB.SystemTables.setEtext("FT.FC.INVALID.SAME.CR/DR.CCY")
            EB.ErrorProcessing.StoreEndError()
        END
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCustomerSpread) NE '' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracCustomerSpread)
            EB.SystemTables.setEtext("FT.FC.INVALID.SAME.CR/DR.CCY")
            EB.ErrorProcessing.StoreEndError()
        END
    END

*-------------------------------------
* Check the total of DR and CR amount if Credit amount is present else
* default the Credit amount equalent of Total Dedit amount.
*-------------------------------------

    DR.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracDrCurrency)
    CR.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCrCurrency)
    DR.AMT = TOT.DR.AMT
    EXCH.RATE = ''

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCrAmount) NE "" THEN

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracCrAmount)
        TOT.CR.AMT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCrAmount)
        CR.AMT = TOT.CR.AMT

        *   Check the totals of debit and credit amounts without giving attention
        *   to Currency in case both the ccy's are same.

        IF DR.CCY EQ CR.CCY THEN
            IF TOT.DR.AMT NE TOT.CR.AMT THEN
                DIFF = TOT.DR.AMT - TOT.CR.AMT

                IF TOT.DR.AMT LT TOT.CR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracCrAmount)
                    EB.SystemTables.setEtext('FT-TOTAL.DR.LESS.BY':@FM:DIFF)
                    EB.ErrorProcessing.StoreEndError()
                END
                IF TOT.DR.AMT GT TOT.CR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracCrAmount)
                    EB.SystemTables.setEtext('FT-TOTAL.CR.LESS.BY':@FM:DIFF)
                    EB.ErrorProcessing.StoreEndError()
                END
            END
        END ELSE

            * If both ccy's are different then find the Debit amount equalent for Credit amount
            * and check the Debit amount equalent with the TOT.DR.AMT (Sum of Debit amount)

            * Call CUST RATE to get the Debit amount equalent for the given Credit amount.

            EXCH.RATE = '' ; CUST.RATE = '' ; REQ.CCY.MKT = '1' ; BASE.CCY = ""
            RETURN.CODE = '' ; CUST.SPREAD = "0" ; CUST.SPREAD.PERCENT = ""
            DR.EQ.AMT = "" ; DEBIT.LCY.AMOUNT = "" ; CREDIT.LCY.AMOUNT = "" ; RETURN.CODE = ""

            * If Treasury.rate is present then pass the treasury rate in EXCH.RATE
            * else if Customer.rate is present then pass the customer rate in
            * CUST.RATE.

            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracTreasuryRate) THEN EXCH.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracTreasuryRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCustomerRate) THEN CUST.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCustomerRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCustomerSpread) THEN CUST.SPREAD = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCustomerSpread)

            ST.ExchangeRate.Custrate(REQ.CCY.MKT,DR.CCY,DR.EQ.AMT,CR.CCY,CR.AMT,'',EXCH.RATE,CUST.RATE,CUST.SPREAD,CUST.SPREAD.PERCENT,DEBIT.LCY.AMOUNT,CREDIT.LCY.AMOUNT,RETURN.CODE)

            IF RETURN.CODE<1> NE "" THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracCrAmount)
                EB.SystemTables.setEtext("FT-CUSTRATE.ERR":@FM:EB.SystemTables.getEtext())
                EB.ErrorProcessing.StoreEndError()
            END

            EB.Foundation.ScFormatCcyAmt(DR.CCY,TOT.DR.AMT)

            * Check the Debit equalent amount with the TOT.DR.AMT (Sum of Debit amount)

            IF DR.EQ.AMT <> TOT.DR.AMT THEN
                DIFF = DR.EQ.AMT - TOT.DR.AMT

                IF DR.EQ.AMT LT TOT.DR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracCrAmount)
                    EB.SystemTables.setEtext('FT-TOTAL.CR.LESS.BY':@FM:DIFF)
                    EB.ErrorProcessing.StoreEndError()
                END
                IF DR.EQ.AMT GT TOT.DR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracCrAmount)
                    EB.SystemTables.setEtext('FT-TOTAL.DR.LESS.BY':@FM:DIFF)
                    EB.ErrorProcessing.StoreEndError()
                END
            END

        END

    END ELSE

        TOTAL.CREDIT.AMOUNT = ''
        IF DR.CCY EQ CR.CCY THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCrAmount) = "" THEN
                EB.Foundation.ScFormatCcyAmt(DR.CCY,TOT.DR.AMT)
                TOTAL.CREDIT.AMOUNT = TOT.DR.AMT
            END
        END ELSE
            * Call CUST RATE to get the Credit amount equalent for the TOT.DR.AMT.

            EXCH.RATE = '' ; CUST.RATE = '' ; REQ.CCY.MKT = '1' ; BASE.CCY = ""
            RETURN.CODE = '' ; CUST.SPREAD = "0" ; CUST.SPREAD.PERCENT = ""
            CR.EQ.AMT = "" ; DEBIT.LCY.AMOUNT = "" ; CREDIT.LCY.AMOUNT = "" ; RETURN.CODE = ""

            * If Treasury.rate is present then pass the treasury rate in EXCH.RATE
            * else if Customer.rate is present then pass the customer rate in
            * CUST.RATE.

            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracTreasuryRate) THEN EXCH.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracTreasuryRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCustomerRate) THEN CUST.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCustomerRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCustomerSpread) THEN CUST.SPREAD = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCustomerSpread)

            ST.ExchangeRate.Custrate(REQ.CCY.MKT,DR.CCY,DR.AMT,CR.CCY,CR.EQ.AMT,'',EXCH.RATE,CUST.RATE,CUST.SPREAD,CUST.SPREAD.PERCENT,DEBIT.LCY.AMOUNT,CREDIT.LCY.AMOUNT,RETURN.CODE)

            IF RETURN.CODE<1> NE "" THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracCrAmount)
                EB.SystemTables.setEtext("FT-CUSTRATE.ERR":@FM:EB.SystemTables.getEtext())
                EB.ErrorProcessing.StoreEndError()
            END

            TOTAL.CREDIT.AMOUNT = CR.EQ.AMT
        END

    END


*----------------------
* CR Value Date Validations
*----------------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracCrValueDate)
    CR.VALUE.DATE = EB.SystemTables.getRNew(EB.SystemTables.getAf())

    IF CR.VALUE.DATE NE "" THEN

        * If BACK.VALUE.MAXIMUM / FORW.VALUE.MAXIMUM is 'Y' in FT.TXN.TYPE.CONDITION, then check with Today's Date
        IF BK.VAL.MAX = 'Y' THEN
            IF CR.VALUE.DATE < CHK.TODAY.DAT THEN
                EB.SystemTables.setEtext("FT.RTN.CR.DATE.VALUE.EXCEEDS.MAX.BACKVALUE")
                EB.ErrorProcessing.StoreEndError()
            END
        END

        IF FWD.VAL.MAX = "Y" THEN
            IF CR.VALUE.DATE > CHK.TODAY.DAT THEN
                EB.SystemTables.setEtext("FT.RTN.CR.DATE.VALUE.EXCEEDS.MAX.FORWARDVALUE")
                EB.ErrorProcessing.StoreEndError()
            END
        END

        * Raise an error, if credit value date is greater than FORW.VALUE.MAXIMUM from dates appln.
        IF CR.VALUE.DATE > CHK.FWD.MAX.DAT THEN
            EB.SystemTables.setEtext("FT.RTN.DATE.EXCEEDS.MAX.FORWARD")
            EB.ErrorProcessing.StoreEndError()
        END

        * Raise an error, if debit value date is lesser than BACK.VALUE.MAXIMUM from dates appln.
        IF CR.VALUE.DATE < CHK.BK.MAX.DAT THEN
            EB.SystemTables.setEtext("FT.RTN.DATE.EXCEEDS.MAX.BACK.VALUE")
            EB.ErrorProcessing.StoreEndError()
        END

        IF CR.VALUE.DATE < DR.VALUE.DATE THEN
            IF R.TXN.TYPE<FT.Config.TxnTypeCondition.FtSixDbAfterCr> NE 'YES' THEN
                EB.SystemTables.setEtext("FT.RTN.DR.VALUE.LATER.THAN.CR.VALUE.1")
                EB.ErrorProcessing.StoreEndError()
            END ELSE
                ACTUAL.NO.DAYS = ''
                REGION = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry):EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalRegion)
                EB.API.Cdd( REGION , CR.VALUE.DATE , DR.VALUE.DATE, ACTUAL.NO.DAYS )
                IF ACTUAL.NO.DAYS > R.TXN.TYPE<FT.Config.TxnTypeCondition.FtSixDbACrMaxDays> THEN
                    EB.SystemTables.setEtext("FT.RTN.LATER.THAN.DR.AFTER.CR.MAX.DAYS.1")
                    EB.ErrorProcessing.StoreEndError()
                END
            END
        END
    END       ;* Final IF of COMI



*----------------------
* Processing Date Validation
*----------------------
    EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracProcessingDate)

    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) = '' THEN EB.SystemTables.setRNew(EB.SystemTables.getAf(), EB.SystemTables.getToday())

* Stop if Processing Date is < Today
    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) LT EB.SystemTables.getToday() THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracProcessingDate)
        EB.SystemTables.setEtext('FT-DATE.CANT.L.TODAY')
        EB.ErrorProcessing.StoreEndError()
    END

*----------------------
* Exposure Date Validation
*----------------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracExposureDate)

    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) NE "" THEN
        EXP.DATE = EB.SystemTables.getRNew(EB.SystemTables.getAf())
        IF EXP.DATE > EB.SystemTables.getRDates(EB.Utility.Dates.DatForwValueMaximum) THEN
            EB.SystemTables.setEtext("FT.FC.DATE.EXCEEDS.MAX.FORWARD")
            EB.ErrorProcessing.StoreEndError()
        END
        IF EXP.DATE < EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracProcessingDate) THEN
            EB.SystemTables.setEtext("FT.FC.DATE.CANT.BACKVALUED")
            EB.ErrorProcessing.StoreEndError()
        END
    END

*----------------------
* Profit Centre Validation
*----------------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkDebitAc.BkdracProfitCentreCust)

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracProfitCentreCust) NE "" AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracProfitCentreDept) NE "" THEN
        EB.SystemTables.setEtext("FT.FC.DEFINE.ONLY.1.PROFIT.CENTRE.FLD")
        EB.ErrorProcessing.StoreEndError()
    END


    RETURN
*
************************************************************************
*
REPEAT.CHECK.FIELDS:
*
* Loop through each field and repeat the check field processing if there is any defined
*
    FOR I = 1 TO FT.BulkProcessing.BulkDebitAc.BkdracRecordStatus
        EB.SystemTables.setAf(I)
        IF INDEX(EB.SystemTables.getN(EB.SystemTables.getAf()), "C", 1) THEN
            *
            * Is it a sub value, a multi value or just a field
            *
            BEGIN CASE
                CASE EB.SystemTables.getF(EB.SystemTables.getAf())[4,2] = 'XX'          ;* Sv
                    NO.OF.AV = DCOUNT(EB.SystemTables.getRNew(EB.SystemTables.getAf()), @VM)
                    IF NO.OF.AV = 0 THEN NO.OF.AV = 1
                    FOR K = 1 TO NO.OF.AV
                        EB.SystemTables.setAv(K)
                        NO.OF.SV = DCOUNT(EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()>, @SM)
                        IF NO.OF.SV = 0 THEN NO.OF.SV = 1
                        FOR S = 1 TO NO.OF.SV
                            EB.SystemTables.setAs(S)
                            GOSUB DO.CHECK.FIELD
                        NEXT S
                    NEXT K
                CASE EB.SystemTables.getF(EB.SystemTables.getAf())[1,2] = 'XX'          ;* Mv
                    EB.SystemTables.setAs('')
                    NO.OF.AV = DCOUNT(EB.SystemTables.getRNew(EB.SystemTables.getAf()), @VM)
                    IF NO.OF.AV = 0 THEN NO.OF.AV = 1
                    FOR S = 1 TO NO.OF.AV
                        EB.SystemTables.setAv(S)
                        GOSUB DO.CHECK.FIELD
                    NEXT S
                CASE 1
                    EB.SystemTables.setAv(''); EB.SystemTables.setAs('')
                    GOSUB DO.CHECK.FIELD
            END CASE
        END
    NEXT I
    RETURN
*
************************************************************************
*
DO.CHECK.FIELD:
** Repeat the check field validation - errors are returned in the
** variable E.
*
    EB.SystemTables.setComiEnri("")
    BEGIN CASE
        CASE EB.SystemTables.getAs()
            EB.SystemTables.setComi(EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>)
        CASE EB.SystemTables.getAv()
            EB.SystemTables.setComi(EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()>)
        CASE EB.SystemTables.getAf()
            EB.SystemTables.setComi(EB.SystemTables.getRNew(EB.SystemTables.getAf()))
    END CASE
*
    FT.BulkProcessing.BkDebitAcCheckFields()
    IF EB.SystemTables.getE() THEN
        EB.SystemTables.setEtext(EB.SystemTables.getE())
        EB.ErrorProcessing.StoreEndError()
    END ELSE
        AS1 = EB.SystemTables.getAs()
        AV1 = EB.SystemTables.getAv()
        AF1 = EB.SystemTables.getAf()
        BEGIN CASE
            CASE AS1
                tmp=EB.SystemTables.getRNew(AF1); tmp<1,AV1,AS1>=EB.SystemTables.getComi(); EB.SystemTables.setRNew(AF1, tmp)
                YENRI.FLD = AF1:".":AV1:".":AS1 ; YENRI = EB.SystemTables.getComiEnri()
                GOSUB SET.UP.ENRI
            CASE AV1
                tmp=EB.SystemTables.getRNew(AF1); tmp<1,AV1>=EB.SystemTables.getComi(); EB.SystemTables.setRNew(AF1, tmp)
                YENRI.FLD = AF1:".":AV1 ; YENRI = EB.SystemTables.getComiEnri()
                GOSUB SET.UP.ENRI
            CASE AF1
                EB.SystemTables.setRNew(AF1, EB.SystemTables.getComi())
                YENRI.FLD = AF1 ; YENRI = EB.SystemTables.getComiEnri()
                GOSUB SET.UP.ENRI
        END CASE
    END
    RETURN
*
************************************************************************
*
SET.UP.ENRI:
*
    LOCATE YENRI.FLD IN EB.SystemTables.getTFieldno()<1> SETTING YPOS THEN
*         T.ENRI<YPOS> = YENRI
    END
    RETURN
*
************************************************************************
*
INITIALISE:
*
* Read FT.TXN.TYPE.CONDITION
    ID.TXN.TYPE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracTransactionType)
    R.TXN.TYPE = FT.Config.TxnTypeCondition.Read(ID.TXN.TYPE, TXN.ERR)
    CHK.TODAY.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatToday)
    CHK.BK.MAX.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatBackValueMaximum)
    CHK.FWD.MAX.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatForwValueMaximum)
    BK.VAL.MAX = R.TXN.TYPE<FT.Config.TxnTypeCondition.FtSixBackValueMaximum>
    FWD.VAL.MAX = R.TXN.TYPE<FT.Config.TxnTypeCondition.FtSixForwValueMaximum>
    DR.VALUE.DATE = ''
    CR.VALUE.DATE = ''
    TOT.CR.AMT = ''

    RETURN
*
************************************************************************
*
VALIDATE.ORDERING.BANK.FIELDS:
    AS.COUNT = DCOUNT(EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,MV>, @SM)
    IF AS.COUNT > 1 AND EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,1>[1,3] = 'SW-' THEN
        EB.SystemTables.setAv(MV); EB.SystemTables.setAs(2)
        EB.SystemTables.setEtext("FT-NO.MV.WITH.SWIFT.ADD")
        EB.ErrorProcessing.StoreEndError()
    END

    IF AS.COUNT > 4 THEN
        EB.SystemTables.setAv(MV); EB.SystemTables.setAs(5)
        EB.SystemTables.setEtext("FT-O.MAX.LINES.EXCEEDED")
        EB.ErrorProcessing.StoreEndError()
    END

    EB.Template.FtNullsChk()

    RETURN

*
************************************************************************
*

    END
