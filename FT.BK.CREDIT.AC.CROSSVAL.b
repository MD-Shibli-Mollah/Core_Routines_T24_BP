* @ValidationCode : MjotMTE2MjAyNTQyOkNwMTI1MjoxNTcxMDQ0NTY3NzU4OnNyYXZpa3VtYXI6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTEwLjIwMTkwOTA1LTEwNTQ6LTE6LTE=
* @ValidationInfo : Timestamp         : 14 Oct 2019 14:46:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190905-1054
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*
*-----------------------------------------------------------------------------
* <Rating>3651</Rating>
*-----------------------------------------------------------------------------
$PACKAGE FT.BulkProcessing
SUBROUTINE FT.BK.CREDIT.AC.CROSSVAL
************************************************************************
* Routine for BULK DEBIT/CREDIT Crossvalidation
*
************************************************************************
* 29/06/04 - EN_10002298
*            New Version
*
* 12/07/04 - BG_100006940
*            Debit Amount made as optional field.
*
* 21/07/04 - BG_100006954
*            Rate fields should not be allowed if Dr & Cr ccy's are same
*
* 04/08/04 - BG_100007047
*            Single Dr/Cr transaction should not be allowed.
*
* 1/08/05 - CI_10032367
*           New fields SEND.TO.PARTY & BK.TO.BK.OUT introduced.
*
* 31/05/06 - CI_10041519
*            Remove FT.NULL.CHK validation as SNED.TO.PARTY and BK.TO.BK
*            are not madatory for BULK.CREDIT.AC.
*
* 29/11/06 - CI_10045720
*            While debiting an internal account using FT.BULK.CREDIT.AC,
*            it throws an error "PROFIT.CENTRE.CUST OR PROFIT.CENTRE.DEPT MUST BE INPUT"
*            when the fields PROFIT.CENTRE.CUST or PROFIT.CENTRE.DEPT are not inputted.This
*            check has been removed since this check is not needed for AC type of FTs.
*
* 20/01/10 - Defect: 11562, Task: 14640
*            When DEBIT.AMOUNT is not null and when the DR and CR ccy are not equal,
*            CUSTRATE should be called to calculate the DR.EQ.AMT of TOT.CR.AMT.
*            The arrived DR.EQ.AMT should be compared with DR.AMT and error should
*            be raised accordingly
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
* 10/09/15 - Enhancement 1265068 / Task 1466516
*          - Routine incorporated
*
* 14/10/19 - Defect 3381717 / Task 3381914
*            Code changes done to process new LIMIT.REFERENCE key format.
*
************************************************************************
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING EB.Utility
    $USING EB.API
    $USING EB.Delivery
    $USING EB.Template
    $USING FT.Config
    $USING AC.AccountOpening
    $USING ST.CompanyCreation
    $USING ST.ExchangeRate
    $USING EB.Foundation
    $USING FT.BulkProcessing

*
************************************************************************
*
*
************************************************************************
*
    GOSUB INITIALISE

    GOSUB REPEAT.CHECK.FIELDS

    GOSUB REAL.CROSSVAL
*
    tmp.END.ERROR = EB.SystemTables.getEndError()
    tmp.E = EB.SystemTables.getE()
    tmp.ETEXT = EB.SystemTables.getEtext()
    IF NOT(tmp.ETEXT) AND NOT(tmp.E) AND NOT(tmp.END.ERROR) THEN        ;* BG_100006940 - S
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracTreasuryRate) = '' THEN EB.SystemTables.setRNew(FT.BulkProcessing.BulkCreditAc.BkcracTreasuryRate, EXCH.RATE)
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracDrAmount) = '' THEN EB.SystemTables.setRNew(FT.BulkProcessing.BulkCreditAc.BkcracDrAmount, TOTAL.DEBIT.AMOUNT)
    END   ;* BG_100006940 - E

RETURN
*
************************************************************************
*
REAL.CROSSVAL:
*
* Real cross validation goes here....
*
*----------------------
* Debit Currency check
*----------------------
    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracDrCurrency)
    R.ACCOUNT.RECORD = ''
    READ.ERROR = ''
    DEBIT.ACCNO = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracDrAccount)
    R.ACCOUNT.RECORD = AC.AccountOpening.Account.Read(DEBIT.ACCNO, READ.ERROR)
    IF NOT(READ.ERROR) THEN
        ACC.CCY = R.ACCOUNT.RECORD<AC.AccountOpening.Account.Currency>
        BULK.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracDrCurrency)
        IF BULK.CCY NE ACC.CCY THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracDrCurrency)
            EB.SystemTables.setEtext("FT-INVALID.CCY.FOR.DB.ACC")
            EB.ErrorProcessing.StoreEndError()
        END
    END

*----------------------
* Check is done to ensure that Dr acct is not duplicated in Cr acct.
*----------------------
    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracDrAccount)
    DEBIT.ACCT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracDrAccount)
    CREDIT.ACCT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracCrAccount)
    LOCATE DEBIT.ACCT IN CREDIT.ACCT<1,1> SETTING POS ELSE POS = ''
    IF POS THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracCrAccount); EB.SystemTables.setAv(POS)
        EB.SystemTables.setEtext("FT-ACCT.CANT.BE.SAME")
        EB.ErrorProcessing.StoreEndError()
    END


*----------------------
* DR Value Date Validation
*----------------------
    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracDrValueDate)
    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) NE "" THEN
        DR.VALUE.DATE = EB.SystemTables.getRNew(EB.SystemTables.getAf())

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


*----------------------
* Crossvalidation in the multi-valued fields
*----------------------

    TOT.CR.AMT = ''

    NO.OF.CR = DCOUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracCrAccount), @VM)

    IF NO.OF.CR LE 1 THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracCrAccount); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext("FT-SINGLE.CR.DR.NOT.ALLOWED")
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END

    FOR MV = 1 TO NO.OF.CR

*----------------------
* Cr acct & Cr ccy validation
*----------------------
* All Credit account's currency should be same.
        R.ACCT.REC = ''
        CREDIT.ACCNO = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracCrAccount)<1,MV>
        R.ACCT.REC = AC.AccountOpening.Account.Read(CREDIT.ACCNO, ACC.ERR)
        IF NOT(ACC.ERR) THEN
            ACCT.CCY = R.ACCT.REC<AC.AccountOpening.Account.Currency>
            BUL.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracCrCurrency)
            IF BUL.CCY NE ACCT.CCY THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracCrAccount);  EB.SystemTables.setAv(MV)
                EB.SystemTables.setEtext("FT-INVALID.ACCT.FOR.CR.CCY")
                EB.ErrorProcessing.StoreEndError()
            END
        END

*----------------------
* CR Value Date Validations
*----------------------

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracCrValueDate)
        CR.VALUE.DATE = EB.SystemTables.getRNew(EB.SystemTables.getAf())<1, MV>
        IF CR.VALUE.DATE NE "" THEN
            EB.SystemTables.setAv(MV)

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
        END         ;* Final IF of COMI

* CI_10032367 S
*--------------
* SEND.TO.PARTY
*--------------

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracSend.Party)

        NO.OF.MV = COUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracBk.BkBk.Out)<1,MV>, @SM) + 1
        FOR I = 1 TO NO.OF.MV
            EB.SystemTables.setAs(1)
            BEGIN CASE
                CASE EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracBk.BkBk.Out)<1,MV,I> NE "" AND EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,MV> EQ ""
                    EB.SystemTables.setAv(MV)
                    EB.SystemTables.setEtext("FT.FC.INP.MISS")
                    EB.ErrorProcessing.StoreEndError()
                CASE EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracBk.BkBk.Out)<1,MV,I> EQ '' AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracSend.Party)<1,MV> NE ''
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracBk.BkBk.Out)
                    EB.SystemTables.setAv(MV)
                    EB.SystemTables.setEtext("FT.FC.INP.MISS")
                    EB.ErrorProcessing.StoreEndError()
            END CASE
        NEXT I

*  IF END.ERROR THEN RETURN

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracBk.BkBk.Out)
        EB.Delivery.ValBkToBk()

        IF EB.SystemTables.getEtext() THEN
            EB.ErrorProcessing.StoreEndError()
            RETURN
        END

*** Check for Duplicate Send to Party *****

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracBk.BkBk.Out)
        EB.Template.FtNullsChk()

* CI_10032367 E

*----------------------
* Find the Total of all the Credit amouonts
*----------------------
        TOT.CR.AMT += EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracCrAmount)<1,MV>

    NEXT MV

*----------------------
* Ordering Cus/ Ordering Bk
*----------------------
    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracOrderingCus)
    EB.SystemTables.setEtext('')
    EB.Template.FtNullsChk()
    IF NOT(EB.SystemTables.getEtext()) THEN
        AV.COUNT = DCOUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracOrderingCus), @VM)
        IF AV.COUNT > 1 AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracOrderingCus)<1,1>[1,3] = 'SW-' THEN
            EB.SystemTables.setEtext("FT-NO.MV.WITH.SWIFT.ADD")
            EB.ErrorProcessing.StoreEndError()
        END
    END

    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracOrderingBk)
    EB.SystemTables.setEtext('')
    EB.Template.FtNullsChk()
    IF NOT(EB.SystemTables.getEtext()) THEN
        AV.COUNT = DCOUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracOrderingBk), @VM)
        IF AV.COUNT > 1 AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracOrderingBk)<1,1>[1,3] = 'SW-' THEN
            EB.SystemTables.setEtext("FT-NO.MV.WITH.SWIFT.ADD")
            EB.ErrorProcessing.StoreEndError()
        END
    END


*-----------------------
* Rate fields validation
*-----------------------

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracDrCurrency) = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracCrCurrency) THEN
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracTreasuryRate) NE '' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracTreasuryRate)
            EB.SystemTables.setEtext("FT.FC.INVALID.SAME.CR/DR.CCY")
            EB.ErrorProcessing.StoreEndError()
        END
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracCusmerRate) NE '' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracCusmerRate)
            EB.SystemTables.setEtext("FT.FC.INVALID.SAME.CR/DR.CCY")
            EB.ErrorProcessing.StoreEndError()
        END
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracCusmerSpread) NE '' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracCusmerSpread)
            EB.SystemTables.setEtext("FT.FC.INVALID.SAME.CR/DR.CCY")
            EB.ErrorProcessing.StoreEndError()
        END
    END


*-------------------------------------
* Check the total of DR and CR amount if Debit amount is present else
* default the Debit amount equalent of Total Credit amount.
*-------------------------------------

    DR.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracDrCurrency)         ;* BG_100006940 - S
    CR.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracCrCurrency)
    CR.AMT = TOT.CR.AMT
    EXCH.RATE = ""

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracDrAmount) NE "" THEN

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracDrAmount)
        TOT.DR.AMT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracDrAmount)
        DR.AMT = TOT.DR.AMT


*   Check the totals of debit and credit amounts without giving attention
*   to Currency in case both the ccy's are same.

        IF DR.CCY EQ CR.CCY THEN
            IF TOT.DR.AMT NE TOT.CR.AMT THEN
                DIFF = TOT.DR.AMT - TOT.CR.AMT

                IF TOT.DR.AMT LT TOT.CR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracDrAmount)
                    EB.SystemTables.setEtext('FT-TOTAL.DR.LESS.BY':@FM:DIFF)
                    EB.ErrorProcessing.StoreEndError()
                END
                IF TOT.DR.AMT GT TOT.CR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracDrAmount)
                    EB.SystemTables.setEtext('FT-TOTAL.CR.LESS.BY':@FM:DIFF)
                    EB.ErrorProcessing.StoreEndError()
                END
            END
        END ELSE

* If both ccy's are different then find the Debit amount equalent of credit amount
* and check the Credit amount with the TOT.CR.AMT (Sum of credit amount)

* Call CUST RATE to get the Credit amount equalent for the given Debit amount.

            EXCH.RATE = '' ; CUST.RATE = '' ; REQ.CCY.MKT = '1' ; BASE.CCY = ""
            RETURN.CODE = '' ; CUST.SPREAD = "0" ; CUST.SPREAD.PERCENT = ""
            DR.EQ.AMT = "" ; DEBIT.LCY.AMOUNT = "" ; CREDIT.LCY.AMOUNT = "" ; RETURN.CODE = ""

* If Treasury.rate is present then pass the treasury rate in EXCH.RATE
* else if Customer.rate is present then pass the customer rate in
* CUST.RATE.

            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracTreasuryRate) THEN EXCH.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracTreasuryRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracCusmerRate) THEN CUST.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracCusmerRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracCusmerSpread) THEN CUST.SPREAD = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracCusmerSpread)


            ST.ExchangeRate.Custrate(REQ.CCY.MKT,DR.CCY,DR.EQ.AMT,CR.CCY,TOT.CR.AMT,'',EXCH.RATE,CUST.RATE,CUST.SPREAD,CUST.SPREAD.PERCENT,DEBIT.LCY.AMOUNT,CREDIT.LCY.AMOUNT,RETURN.CODE)
            IF RETURN.CODE<1> NE "" THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracDrAmount)
                EB.SystemTables.setEtext("FT-CUSTRATE.ERR":@FM:EB.SystemTables.getEtext())
                EB.ErrorProcessing.StoreEndError()
            END

* Check the Credit equalent amount with the TOT.CR.AMT (Sum of credit amount)
            IF DR.EQ.AMT <> DR.AMT THEN
                DIFF = DR.EQ.AMT - DR.AMT

                IF DR.EQ.AMT LT DR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracDrAmount)
                    EB.SystemTables.setEtext('FT-TOTAL.DR.LESS.BY':@FM:DIFF)
                    EB.ErrorProcessing.StoreEndError()
                END
                IF DR.EQ.AMT GT DR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracDrAmount)
                    EB.SystemTables.setEtext('FT-TOTAL.CR.LESS.BY':@FM:DIFF)
                    EB.ErrorProcessing.StoreEndError()
                END
            END
        END
    END ELSE

        TOTAL.DEBIT.AMOUNT = ''
        IF DR.CCY EQ CR.CCY THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracDrAmount) = "" THEN
                EB.Foundation.ScFormatCcyAmt(CR.CCY,TOT.CR.AMT)
                TOTAL.DEBIT.AMOUNT = TOT.CR.AMT
            END
        END ELSE
* Call CUST RATE to get the Debit amount equalent for the TOT.CR.AMT.

            EXCH.RATE = '' ; CUST.RATE = '' ; REQ.CCY.MKT = '1' ; BASE.CCY = ""
            RETURN.CODE = '' ; CUST.SPREAD = "0" ; CUST.SPREAD.PERCENT = ""
            DR.EQ.AMT = "" ; DEBIT.LCY.AMOUNT = "" ; CREDIT.LCY.AMOUNT = "" ; RETURN.CODE = ""

* If Treasury.rate is present then pass the treasury rate in EXCH.RATE
* else if Customer.rate is present then pass the customer rate in
* CUST.RATE.

            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracTreasuryRate) THEN EXCH.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracTreasuryRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracCusmerRate) THEN CUST.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracCusmerRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracCusmerSpread) THEN CUST.SPREAD = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracCusmerSpread)

            ST.ExchangeRate.Custrate(REQ.CCY.MKT,DR.CCY,DR.EQ.AMT,CR.CCY,CR.AMT,'',EXCH.RATE,CUST.RATE,CUST.SPREAD,CUST.SPREAD.PERCENT,DEBIT.LCY.AMOUNT,CREDIT.LCY.AMOUNT,RETURN.CODE)

            IF RETURN.CODE<1> NE "" THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracDrAmount)
                EB.SystemTables.setEtext("FT-CUSTRATE.ERR":@FM:EB.SystemTables.getEtext())
                EB.ErrorProcessing.StoreEndError()
            END

            TOTAL.DEBIT.AMOUNT = DR.EQ.AMT
        END
    END   ;* BG_100006940 - E



*----------------------
* Processing Date Validation
*----------------------
    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracProcessingDate)

    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) = '' THEN EB.SystemTables.setRNew(EB.SystemTables.getAf(), EB.SystemTables.getToday())

* Stop if Processing Date is < Today
    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) LT EB.SystemTables.getToday() THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracProcessingDate)
        EB.SystemTables.setEtext('FT-DATE.CANT.L.TODAY')
        EB.ErrorProcessing.StoreEndError()
    END

*----------------------
* Eposure Date Validation
*----------------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracExposureDate)

    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) NE "" THEN
        EXP.DATE = EB.SystemTables.getRNew(EB.SystemTables.getAf())
        IF EXP.DATE > EB.SystemTables.getRDates(EB.Utility.Dates.DatForwValueMaximum) THEN
            EB.SystemTables.setEtext("FT.FC.DATE.EXCEEDS.MAX.FORWARD")
            EB.ErrorProcessing.StoreEndError()
        END
        IF EXP.DATE < EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracProcessingDate) THEN
            EB.SystemTables.setEtext("FT.FC.DATE.CANT.BACKVALUED")
            EB.ErrorProcessing.StoreEndError()
        END
    END

*----------------------
* Profit Centre Validation
*----------------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditAc.BkcracProfitCentreCust)

    DR.NOSTRO.ACCT = ''
    BkcracDrAccount = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracDrAccount)
    R.DEBIT.ACCT = AC.AccountOpening.Account.Read(BkcracDrAccount, ACCT.ERR)
    IF R.DEBIT.ACCT<AC.AccountOpening.Account.LimitRef> = 'NOSTRO' THEN DR.NOSTRO.ACCT = 1


    BEGIN CASE
        CASE EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracProfitCentreCust) = "" AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracProfitCentreDept) = ""
            IF NOT(ACCT.ERR) THEN ;* CI_10045720 - S/E
                EB.SystemTables.setRNew(FT.BulkProcessing.BulkCreditAc.BkcracProfitCentreCust, R.DEBIT.ACCT<AC.AccountOpening.Account.Customer>)
            END

        CASE EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracProfitCentreCust) NE "" AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracProfitCentreDept) NE ""
            EB.SystemTables.setEtext("FT.FC.DEFINE.ONLY.1.PROFIT.CENTRE.FLD")
            EB.ErrorProcessing.StoreEndError()
    END CASE


*----------------------
RETURN
*
************************************************************************
*
REPEAT.CHECK.FIELDS:
*
* Loop through each field and repeat the check field processing if there is any defined
*
    AF.CNT = EB.SystemTables.getAf()
    FOR AF.CNT = 1 TO FT.BulkProcessing.BulkCreditAc.BkcracRecordStatus
        EB.SystemTables.setAf(AF.CNT)
        IF INDEX(EB.SystemTables.getN(AF.CNT), "C", 1) THEN
*
* Is it a sub value, a multi value or just a field
*
            BEGIN CASE
                CASE EB.SystemTables.getF(AF.CNT)[4,2] = 'XX'      ;* Sv
                    NO.OF.AV = DCOUNT(EB.SystemTables.getRNew(AF.CNT), @VM)
                    IF NO.OF.AV = 0 THEN NO.OF.AV = 1
                    FOR AV.NUM = 1 TO NO.OF.AV
                        EB.SystemTables.setAv(AV.NUM)
                        NO.OF.SV = DCOUNT(EB.SystemTables.getRNew(AF.CNT)<1,AV.NUM>, @SM)
                        IF NO.OF.SV = 0 THEN NO.OF.SV = 1
                        FOR AS.CNT = 1 TO NO.OF.SV
                            EB.SystemTables.setAs(AS.CNT)
                            GOSUB DO.CHECK.FIELD
                        NEXT AS.CNT
                    NEXT AV.NUM
                CASE EB.SystemTables.getF(AF.CNT)[1,2] = 'XX'      ;* Mv
                    EB.SystemTables.setAs('')
                    NO.OF.AV = DCOUNT(EB.SystemTables.getRNew(AF.CNT), @VM)
                    IF NO.OF.AV = 0 THEN NO.OF.AV = 1
                    FOR AV.CNT = 1 TO NO.OF.AV
                        EB.SystemTables.setAv(AV.CNT)
                        GOSUB DO.CHECK.FIELD
                    NEXT AV.CNT
                CASE 1
                    EB.SystemTables.setAv(''); EB.SystemTables.setAs('')
                    GOSUB DO.CHECK.FIELD
            END CASE
        END
    NEXT AF.CNT
RETURN
*
************************************************************************
*
DO.CHECK.FIELD:
** Repeat the check field validation - errors are returned in the
** variable E.

    AF1 = EB.SystemTables.getAf()
    AV1 = EB.SystemTables.getAv()
    AS1 = EB.SystemTables.getAs()
    EB.SystemTables.setComiEnri("")
    BEGIN CASE
        CASE AS1
            EB.SystemTables.setComi(EB.SystemTables.getRNew(AF1)<1,AV1,AS1>)
        CASE AV1
            EB.SystemTables.setComi(EB.SystemTables.getRNew(AF1)<1,AV1>)
        CASE AF1
            EB.SystemTables.setComi(EB.SystemTables.getRNew(AF1))
    END CASE
*
    FT.BulkProcessing.BkCreditAcCheckFields()
    IF EB.SystemTables.getE() THEN
        EB.SystemTables.setEtext(EB.SystemTables.getE())
        EB.ErrorProcessing.StoreEndError()
    END ELSE
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
    ID.TXN.TYPE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditAc.BkcracTransactionType)
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
END
