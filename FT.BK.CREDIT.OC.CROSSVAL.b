* @ValidationCode : Mjo2MTY1NTQyODc6Q3AxMjUyOjE1NzEwNDQ1Njc4NTg6c3JhdmlrdW1hcjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTAuMjAxOTA5MDUtMTA1NDotMTotMQ==
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
* <Rating>3016</Rating>
*-----------------------------------------------------------------------------
$PACKAGE FT.BulkProcessing
SUBROUTINE FT.BK.CREDIT.OC.CROSSVAL
************************************************************************
* Routine for BULK DEBIT/CREDIT Crossvalidation
*
************************************************************************
* 28/07/04 - BG_100007014
*            New Version
*
* 04/08/04 - BG_100007047
*            Single Dr/Cr transaction should not be allowed.
*
* 01/08/05 - CI_10032367
*           New fields SEND.TO.PARTY & BK.TO.BK.OUT introduced.
*
* 20/04/07 - BG_100013651
*            Bug fix.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
* 13/08/15 - Enhancement 1265068
*		   - Task 1482605
*		   - DBR changed to Table Read
*
* 14/10/19 - Defect 3381717 / Task 3381914
*            Code changes done to process new LIMIT.REFERENCE key format.
*
************************************************************************
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING EB.Utility
    $USING EB.API
    $USING EB.Foundation
    $USING EB.Delivery
    $USING EB.Template
    $USING FT.Config
    $USING AC.AccountOpening
    $USING AC.Config
    $USING ST.CompanyCreation
    $USING ST.ExchangeRate
    $USING EB.DataAccess
    $USING FT.BulkProcessing


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
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocTreasuryRate) = '' THEN EB.SystemTables.setRNew(FT.BulkProcessing.BulkCreditOc.BkcrocTreasuryRate, EXCH.RATE)
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocDrAmount) = '' THEN EB.SystemTables.setRNew(FT.BulkProcessing.BulkCreditOc.BkcrocDrAmount, TOTAL.DEBIT.AMOUNT)
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
* Debit Currency check
*----------------------
    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocDrCurrency)

    R.ACCOUNT.RECORD = ''
    READ.ERROR = ''
    DEBIT.ACCNO = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocDrAccount)
    R.ACCOUNT.RECORD = AC.AccountOpening.Account.Read(DEBIT.ACCNO, READ.ERROR)
    IF NOT(READ.ERROR) THEN
        ACC.CCY = R.ACCOUNT.RECORD<AC.AccountOpening.Account.Currency>
        BULK.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocDrCurrency)
        IF BULK.CCY NE ACC.CCY THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocDrCurrency)
            EB.SystemTables.setEtext("FT-INVALID.CCY.FOR.DB.ACC")
            EB.ErrorProcessing.StoreEndError()
        END
    END

*----------------------
* Debit Account check
*----------------------
    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocDrAccount)

* Check is done to ensure that Dr acct is not duplicated in Cr acct.
    DEBIT.ACCT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocDrAccount)
    CREDIT.ACCT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocCrAccount)
    LOCATE DEBIT.ACCT IN CREDIT.ACCT<1,1> SETTING POS ELSE POS = ''
    IF POS THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocCrAccount); EB.SystemTables.setAv(POS)
        EB.SystemTables.setEtext("FT-ACCT.CANT.BE.SAME")
        EB.ErrorProcessing.StoreEndError()
    END

* Check for a Nostro acct
    DR.NOSTRO = 0 ; DR.VOSTRO = 0
    R.DR.ACCT = AC.AccountOpening.Account.Read(DEBIT.ACCT, READ.ERR)
    DR.CUST = R.DR.ACCT<AC.AccountOpening.Account.Customer>
    DR.ACCT.CATEG = R.DR.ACCT<AC.AccountOpening.Account.Category>
    DR.LIMIT.REF = R.DR.ACCT<AC.AccountOpening.Account.LimitRef>

    IF DR.LIMIT.REF = 'NOSTRO' THEN DR.NOSTRO = 1

* Check for a Vostro acct
    AC.Config.CheckAccountClass('VOSTRO', DR.ACCT.CATEG, DR.CUST, '', RET.DATA)
    IF RET.DATA = 'YES' THEN
        DR.VOSTRO = 1
    END


*----------------------
* DR Value Date Validation
*----------------------
    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocDrValueDate)

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
    TOT.CR.AMT = ''

    NO.OF.CR = DCOUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocCrAccount), @VM)

    IF NO.OF.CR LE 1 THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocCrAccount); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext("FT-SINGLE.CR.DR.NOT.ALLOWED")
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END

    FOR MV = 1 TO NO.OF.CR

*----------------------
* Cr acct validation
*----------------------

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocCrAccount)

        CREDIT.ACCT = EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,MV>
        CR.VOSTRO = 0
        CR.NOSTRO = 0
        EB.SystemTables.setAv(MV)

        IF NUM(CREDIT.ACCT) THEN

            R.CR.ACCT = AC.AccountOpening.Account.Read(CREDIT.ACCT, READ.ERR)
            CR.CUST = R.CR.ACCT<AC.AccountOpening.Account.Customer>
            CR.ACCT.CATEG = R.CR.ACCT<AC.AccountOpening.Account.Category>
            CR.LIMIT.REF = R.CR.ACCT<AC.AccountOpening.Account.LimitRef>

* Check for a Nostro acct
            IF CR.LIMIT.REF = 'NOSTRO' THEN CR.NOSTRO = 1

* Check for a Vostro acct
            AC.Config.CheckAccountClass('VOSTRO', CR.ACCT.CATEG, CR.CUST, '', RET.DATA)
            IF RET.DATA = 'YES' THEN
                CR.VOSTRO = 1
            END


* Acct should either be Vostro / Nostro.  It cannot be a Cust acct.
            IF CR.NOSTRO OR CR.VOSTRO ELSE
                EB.SystemTables.setEtext('FT-CANT.CUST.ACCT')
                EB.ErrorProcessing.StoreEndError()
            END

* Both DR,CR accts cannot be Vostro
            IF DR.VOSTRO AND CR.VOSTRO THEN
                EB.SystemTables.setEtext('FT-BOTH.ACCTS.CANNOT.BE.VOSTRO')
                EB.ErrorProcessing.StoreEndError()
            END

        END   ;* for NUM(cr.acct)


*----------------------
* Cr ccy validation
*----------------------

* All Credit account's currency should be same.
        R.ACCT.REC = ''
        AC.ERR = ''
        CREDIT.ACCNO = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocCrAccount)<1,MV>
        R.ACCT.REC = AC.AccountOpening.Account.Read(CREDIT.ACCNO, AC.ERR)
        IF NOT(AC.ERR) THEN
            ACCT.CCY = R.ACCT.REC<AC.AccountOpening.Account.Currency>
            BUL.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocCrCurrency)
            IF BUL.CCY NE ACCT.CCY THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocCrAccount);  EB.SystemTables.setAv(MV)
                EB.SystemTables.setEtext("FT-INVALID.ACCT.FOR.CR.CCY")
                EB.ErrorProcessing.StoreEndError()
            END
        END

*----------------------
* CR Value Date Validations
*----------------------

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocCrValueDate)
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
        END   ;* Final IF of COMI


*-------------------------------------
* Beneficiary details
*-------------------------------------

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocBenCustomer)

        EB.Template.FtNullsChk()

        BEN.CUST = EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,MV>
        EB.SystemTables.setAv(MV); EB.SystemTables.setAs(1)

* BEN details not allowed if CR & DR accts are Nostro.
        IF (DR.NOSTRO AND CR.NOSTRO) THEN
            IF BEN.CUST NE '' THEN
                EB.SystemTables.setEtext("FT-NO.INP.ALLOWED.IF.CR.DR.ACCTS.NOS")
                EB.ErrorProcessing.StoreEndError()
            END

        END ELSE
            IF BEN.CUST EQ '' THEN
* Mandatory input when NO.BEN.CUST.Y.N # 'YES'
                IF R.TXN.TYPE<FT.Config.TxnTypeCondition.FtSixNoBenCustYN> <> "YES" THEN
                    EB.SystemTables.setEtext("FT-MAND.INP.BEN.CUSTOMER")
                    EB.ErrorProcessing.StoreEndError()
                END
            END
        END

* CI_10032367 S
*--------------
* SEND.TO.PARTY
*--------------

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocSendToParty)

        NO.OF.MV = COUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocBkToBkOut)<1,MV>,@SM) + 1      ;*BG_100013651 S/E
        FOR I = 1 TO NO.OF.MV
            EB.SystemTables.setAs(1)
            BEGIN CASE
                CASE EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocBkToBkOut)<1,MV,I> NE "" AND EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,MV> EQ ""
                    EB.SystemTables.setAv(MV)
                    EB.SystemTables.setEtext("FT.FC.INP.MISS")
                    EB.ErrorProcessing.StoreEndError()
                CASE EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocBkToBkOut)<1,MV,I> EQ '' AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocSendToParty)<1,MV> NE ''
                    EB.SystemTables.setAv(MV)
                    EB.SystemTables.setEtext("FT.FC.INP.MISS")
                    EB.ErrorProcessing.StoreEndError()
            END CASE
        NEXT I

        IF EB.SystemTables.getEndError() THEN RETURN

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocBkToBkOut)
        EB.Delivery.ValBkToBk()

        IF EB.SystemTables.getEtext() THEN
            EB.ErrorProcessing.StoreEndError()
            RETURN
        END

*** Check for Duplicate Send to Party *****

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocSendToParty)
        EB.Template.FtNullsChk()

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocBkToBkOut)
        EB.Template.FtNullsChk()

* CI_10032367 E

*----------------------
* Find the Total of all the Credit amounts
*----------------------
        TOT.CR.AMT += EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocCrAmount)<1,MV>

    NEXT MV

*----------------------
* Ordering Cus/ Ordering Bk
*----------------------
    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocOrderingCus)

    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) EQ '' THEN

        DR.NOSTRO.ACCT = ''
        CHECKFILE1="ACCOUNT":@FM:AC.AccountOpening.Account.LimitRef:@FM:".A"
        ER = ''
        R.NEW.ID = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocDrAccount)
        R.REC = AC.AccountOpening.Account.Read(R.NEW.ID, ER)
        X = R.REC<AC.AccountOpening.Account.LimitRef>
        
        IF X = "NOSTRO" THEN      ;* nostro found
            DR.NOSTRO.ACCT = 1
        END

        IF NOT(NUM(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocDrAccount))) OR DR.NOSTRO.ACCT = 1 THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocReturnCheque) <> "YES" THEN
                IF DR.NOSTRO.ACCT <> 1 AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocOrderingBk) = "" THEN
                    EB.SystemTables.setEtext("FT.FC.EITHER.ORDERING.CUST..BANK.MAND")
                    EB.ErrorProcessing.StoreEndError()
                END
            END
        END

    END ELSE

        EB.SystemTables.setEtext('')
        EB.Template.FtNullsChk()
        IF NOT(EB.SystemTables.getEtext()) THEN
            AV.COUNT = DCOUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocOrderingCus), @VM)
            IF AV.COUNT > 1 AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocOrderingCus)<1,1>[1,3] = 'SW-' THEN
                EB.SystemTables.setEtext("FT-NO.MV.WITH.SWIFT.ADD")
                EB.ErrorProcessing.StoreEndError()
            END
        END
    END



    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocOrderingBk)

    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) EQ '' THEN
        IF NOT(NUM(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocDrAccount))) THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocReturnCheque) <> "YES" THEN     ;*GB9900796
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocOrderingCus) = "" THEN
                    EB.SystemTables.setEtext('FT-EITHER.ORDERING.CUST..BANK.MAND')
                    EB.ErrorProcessing.StoreEndError()
                END
            END
        END

    END ELSE

        EB.SystemTables.setEtext('')
        EB.Template.FtNullsChk()
        IF NOT(EB.SystemTables.getEtext()) THEN
            AV.COUNT = DCOUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocOrderingBk), @VM)
            IF AV.COUNT > 1 AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocOrderingBk)<1,1>[1,3] = 'SW-' THEN
                EB.SystemTables.setEtext("FT-NO.MV.WITH.SWIFT.ADD")
                EB.ErrorProcessing.StoreEndError()
            END
        END
    END


*-------------------------------------
* Check the total of DR and CR amount if Debit amount is present else
* default the Debit amount equalent of Total Credit amount.
*-------------------------------------

    DR.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocDrCurrency)
    CR.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocCrCurrency)
    CR.AMT = TOT.CR.AMT
    EXCH.RATE = ''

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocDrAmount) NE "" THEN

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocDrAmount)
        TOT.DR.AMT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocDrAmount)
        DR.AMT = TOT.DR.AMT


*   Check the totals of debit and credit amounts without giving attention
*   to Currency in case both the ccy's are same.

        IF DR.CCY EQ CR.CCY THEN
            IF TOT.DR.AMT NE TOT.CR.AMT THEN
                DIFF = TOT.DR.AMT - TOT.CR.AMT

                IF TOT.DR.AMT LT TOT.CR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocDrAmount)
                    EB.SystemTables.setEtext('FT-TOTAL.DR.LESS.BY':@FM:DIFF)
                    EB.ErrorProcessing.StoreEndError()
                END
                IF TOT.DR.AMT GT TOT.CR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocDrAmount)
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
            CR.EQ.AMT = "" ; DEBIT.LCY.AMOUNT = "" ; CREDIT.LCY.AMOUNT = "" ; RETURN.CODE = ""

* If Treasury.rate is present then pass the treasury rate in EXCH.RATE
* else if Customer.rate is present then pass the customer rate in
* CUST.RATE.

            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocTreasuryRate) THEN EXCH.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocTreasuryRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocCustomerRate) THEN CUST.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocCustomerRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocCustomerSpread) THEN CUST.SPREAD = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocCustomerSpread)

            ST.ExchangeRate.Custrate(REQ.CCY.MKT,DR.CCY,DR.AMT,CR.CCY,CR.EQ.AMT,'',EXCH.RATE,CUST.RATE,CUST.SPREAD,CUST.SPREAD.PERCENT,DEBIT.LCY.AMOUNT,CREDIT.LCY.AMOUNT,RETURN.CODE)

            IF RETURN.CODE<1> NE "" THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocDrAmount)
                EB.SystemTables.setEtext("FT-CUSTRATE.ERR":@FM:EB.SystemTables.getEtext())
                EB.ErrorProcessing.StoreEndError()
            END

            EB.Foundation.ScFormatCcyAmt(CR.CCY,TOT.CR.AMT)

* Check the Credit equalent amount with the TOT.CR.AMT (Sum of credit amount)

            IF CR.EQ.AMT <> TOT.CR.AMT THEN
                DIFF = CR.EQ.AMT - TOT.CR.AMT

                IF CR.EQ.AMT LT TOT.CR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocDrAmount)
                    EB.SystemTables.setEtext('FT-TOTAL.DR.LESS.BY':@FM:DIFF)
                    EB.ErrorProcessing.StoreEndError()
                END
                IF CR.EQ.AMT GT TOT.CR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocDrAmount)
                    EB.SystemTables.setEtext('FT-TOTAL.CR.LESS.BY':@FM:DIFF)
                    EB.ErrorProcessing.StoreEndError()
                END
            END

        END
    END ELSE

        TOTAL.DEBIT.AMOUNT = ''
        IF DR.CCY EQ CR.CCY THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocDrAmount) = "" THEN
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

            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocTreasuryRate) THEN EXCH.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocTreasuryRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocCustomerRate) THEN CUST.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocCustomerRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocCustomerSpread) THEN CUST.SPREAD = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocCustomerSpread)

            ST.ExchangeRate.Custrate(REQ.CCY.MKT,DR.CCY,DR.EQ.AMT,CR.CCY,CR.AMT,'',EXCH.RATE,CUST.RATE,CUST.SPREAD,CUST.SPREAD.PERCENT,DEBIT.LCY.AMOUNT,CREDIT.LCY.AMOUNT,RETURN.CODE)

            IF RETURN.CODE<1> NE "" THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocDrAmount)
                EB.SystemTables.setEtext("FT-CUSTRATE.ERR":@FM:EB.SystemTables.getEtext())
                EB.ErrorProcessing.StoreEndError()
            END

            TOTAL.DEBIT.AMOUNT = DR.EQ.AMT
        END
    END



*----------------------
* Processing Date Validation
*----------------------
    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocProcessingDate)

    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) = '' THEN EB.SystemTables.setRNew(EB.SystemTables.getAf(), EB.SystemTables.getToday())

* Stop if Processing Date is < Today
    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) LT EB.SystemTables.getToday() THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocProcessingDate)
        EB.SystemTables.setEtext('FT-DATE.CANT.L.TODAY')
        EB.ErrorProcessing.StoreEndError()
    END


*----------------------
* Profit Centre Validation
*----------------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkCreditOc.BkcrocProfitCentreCust)

    DR.NOSTRO.ACCT = ''
    BkcrocDrAccount = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocDrAccount)
    R.DEBIT.ACCT = AC.AccountOpening.Account.Read(BkcrocDrAccount, ACCT.ERR)
    IF R.DEBIT.ACCT<AC.AccountOpening.Account.LimitRef> = 'NOSTRO' THEN DR.NOSTRO.ACCT = 1


    BEGIN CASE
        CASE EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocProfitCentreCust) = "" AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocProfitCentreDept) = ""
            IF NOT(NUM(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocDrAccount))) OR DR.NOSTRO.ACCT THEN
                EB.SystemTables.setEtext("PROFIT.CENTRE.CUST  OR PROFIT.CENTRE.DEPT MUST BE INPUT");*GB0001371 S/E
                EB.ErrorProcessing.StoreEndError()
            END ELSE
                EB.SystemTables.setRNew(FT.BulkProcessing.BulkCreditOc.BkcrocProfitCentreCust, R.DEBIT.ACCT<AC.AccountOpening.Account.Customer>)
            END

        CASE EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocProfitCentreCust) NE "" AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocProfitCentreDept) NE ""
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
    FOR I = 1 TO FT.BulkProcessing.BulkCreditOc.BkcrocRecordStatus
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
                        FOR M = 1 TO NO.OF.SV
                            EB.SystemTables.setAs(M)
                            GOSUB DO.CHECK.FIELD
                        NEXT M
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
    FT.BulkProcessing.BkCreditOcCheckFields()
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
    ID.TXN.TYPE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCreditOc.BkcrocTransactionType)
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
