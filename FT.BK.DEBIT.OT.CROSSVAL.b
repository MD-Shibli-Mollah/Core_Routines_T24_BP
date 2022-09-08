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

* Version 2 02/06/00  GLOBUS Release No. G14.1.01 04/12/03
*-----------------------------------------------------------------------------
* <Rating>4988</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FT.BulkProcessing
    SUBROUTINE FT.BK.DEBIT.OT.CROSSVAL
************************************************************************
* Routine for BULK DEBIT Crossvalidation for OT Txn type
*
************************************************************************
* 15/07/04 - BG_100006954
*            New Version
*
* 04/08/04 - BG_100007047
*            Single Dr/Cr transaction should not be allowed.
*
* 01/08/05 - CI_10032367
*           New fields SEND.TO.PARTY & BK.TO.BK.OUT introduced.
*
* 20/04/07 - BG_10001351
*            Bug fix.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*03/08/15 -  Enhancement 1265068
*         -  Task 1433976
*			 Routine incorporated
*
************************************************************************

    $USING EB.SystemTables
    $USING EB.Utility
    $USING EB.Delivery
    $USING EB.Template
    $USING EB.Foundation
    $USING EB.ErrorProcessing
    $USING AC.AccountOpening
    $USING AC.Config
    $USING FT.Config
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
    tmp.END.ERROR = EB.SystemTables.getEndError()
    tmp.E = EB.SystemTables.getE()
    tmp.ETEXT = EB.SystemTables.getEtext()
    IF NOT(tmp.ETEXT) AND NOT(tmp.E) AND NOT(tmp.END.ERROR) THEN
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotTreasuryRate) = '' THEN EB.SystemTables.setRNew(FT.BulkProcessing.BulkDrOt.BkdrotTreasuryRate, EXCH.RATE)
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCreditAmount) = '' THEN EB.SystemTables.setRNew(FT.BulkProcessing.BulkDrOt.BkdrotCreditAmount, TOTAL.CREDIT.AMOUNT)
    END

    RETURN
*
************************************************************************
*
REAL.CROSSVAL:
*
* Real cross validation goes here....
*

*-------------------------------------------------------------------
* Check is done to ensure that Dr acct is not duplicated in Cr acct.
*-------------------------------------------------------------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotDebitAccount)
    DEBIT.ACCT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDebitAccount)
    CREDIT.ACCT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCreditAccount)
    LOCATE CREDIT.ACCT IN DEBIT.ACCT<1,1> SETTING POS ELSE POS = ''
    IF POS THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotDebitAccount); EB.SystemTables.setAv(POS)
        EB.SystemTables.setEtext("FT-ACCT.CANT.BE.SAME")
        EB.ErrorProcessing.StoreEndError()
    END


*--------------------------------------------
* Crossvalidation for the multi-valued fields
*--------------------------------------------

    TOT.DR.AMT = ''

    NO.OF.CR = COUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDebitAccount), @VM)+1

    IF NO.OF.CR LE 1 THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotDebitAccount); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext("FT-SINGLE.CR.DR.NOT.ALLOWED")
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END

    FOR MV = 1 TO NO.OF.CR

        *--------------------------
        * Debit currency/acct validation
        *--------------------------

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotDebitCurrency)
        R.ACCOUNT.RECORD = ''
        READ.ERROR = ''
        DEBIT.ACCNO = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDebitAccount)<1,MV>
        R.ACCOUNT.RECORD = AC.AccountOpening.Account.Read(DEBIT.ACCNO, READ.ERROR)
        IF NOT(READ.ERROR) THEN
            ACC.CCY = R.ACCOUNT.RECORD<AC.AccountOpening.Account.Currency>
            BULK.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDebitCurrency)
            IF BULK.CCY NE ACC.CCY THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotDebitCurrency); EB.SystemTables.setAv(MV)
                EB.SystemTables.setEtext("FT-INVALID.CCY.FOR.DB.ACC")
                EB.ErrorProcessing.StoreEndError()
            END
        END

        * suming of debit amount

        TOT.DR.AMT += EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDebitAmount)<1,MV>


        * Check for Debit value date field.

        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDrValueDate)<1,MV> NE "" THEN
            CHK.TODAY.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatToday)
            IF R.TXN.TYPE(FT.Config.TxnTypeCondition.FtSixBackValueMaximum)[1,1] = "Y" THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDrValueDate)<1,MV> < CHK.TODAY.DAT AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDrValueDate)<1,MV> <> '' THEN
                    EB.SystemTables.setEtext("FT.RTN.DR.DATE.VALUE.EXCEEDS.MAX.BACKVALUE")
                    EB.SystemTables.setAv(MV); EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotDrValueDate); EB.ErrorProcessing.StoreEndError()
                END
            END

            * If BACK.VALUE.MAXIMUM is No in FT.TXN.TYPE.CONDITION, then raise an error
            * if Debit value date is lesser than BACK.VALUE.MAXIMUM from dates
            * application.

            CHK.TODAY.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatBackValueMaximum)
            IF R.TXN.TYPE(FT.Config.TxnTypeCondition.FtSixBackValueMaximum)[1,1] = "N" THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDrValueDate)<1,MV> < CHK.TODAY.DAT AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDrValueDate)<1,MV> <> '' THEN
                    EB.SystemTables.setEtext("FT.RTN.DR.DATE.VALUE.EXCEEDS.MAX.BACKVALUE")
                    EB.SystemTables.setAv(MV); EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotDrValueDate); EB.ErrorProcessing.StoreEndError()
                END
            END

            * FORWARD VALUE

            CHK.TODAY.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatToday)
            IF R.TXN.TYPE(FT.Config.TxnTypeCondition.FtSixForwValueMaximum)[1,1] = "Y" THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDrValueDate)<1,MV> > CHK.TODAY.DAT AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDrValueDate)<1,MV> <> '' THEN
                    EB.SystemTables.setEtext("FT.RTN.DR.DATE.VALUE.EXCEEDS.MAX.FORWARDVALUE")
                    EB.SystemTables.setAv(MV); EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotDrValueDate); EB.ErrorProcessing.StoreEndError()
                END
            END

            * If FORW.VALUE.MAXIMUM is No in FT.TXN.TYPE.CONDITION, then raise an error
            * if Debit value date is greater than FORW.VALUE.MAXIMUM from dates
            * application.

            CHK.TODAY.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatForwValueMaximum)
            IF R.TXN.TYPE(FT.Config.TxnTypeCondition.FtSixForwValueMaximum)[1,1] = "N" THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDrValueDate)<1,MV> > CHK.TODAY.DAT AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDrValueDate)<1,MV> <> '' THEN
                    EB.SystemTables.setEtext("FT.RTN.DR.DATE.VALUE.EXCEEDS.MAX.FORWARDVALUE")
                    EB.SystemTables.setAv(MV); EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotDrValueDate); EB.ErrorProcessing.StoreEndError()
                END
            END
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDrValueDate)<1,MV> > EB.SystemTables.getRDates(EB.Utility.Dates.DatForwValueMaximum) THEN
                EB.SystemTables.setEtext("FT.RTN.DATE.EXCEEDS.MAX.FORWARD")
                EB.SystemTables.setAv(MV); EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotDrValueDate); EB.ErrorProcessing.StoreEndError()
            END
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDrValueDate)<1,MV> < EB.SystemTables.getRDates(EB.Utility.Dates.DatBackValueMaximum) THEN
                EB.SystemTables.setEtext("FT.RTN.DATE.EXCEEDS.MAX.BACK.VALUE")
                EB.SystemTables.setAv(MV); EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotDrValueDate); EB.ErrorProcessing.StoreEndError()
            END

        END

        * Validating ordering cust and ordering bank fields

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotOrderingCu)
        GOSUB VALIDATE.ORDERING.FIELDS

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotOrderingBk)
        GOSUB VALIDATE.ORDERING.FIELDS

        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotOrderingCu)<1,MV,1> = '' AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotOrderingBk)<1,MV,1> = '' THEN
            IF R.ACCOUNT.RECORD<AC.AccountOpening.Account.LimitRef> = 'NOSTRO' OR NOT(NUM(EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDebitAccount)<1,MV,1>)) THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotOrderingCu); EB.SystemTables.setAv(MV); EB.SystemTables.setAs(1)
                EB.SystemTables.setEtext("FT-EITHER.ORDERING.CUST..BANK.MAND")
                EB.ErrorProcessing.StoreEndError()
            END
        END

        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotOrderingCu)<1,MV,1> NE '' AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotOrderingBk)<1,MV,1> NE '' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotOrderingBk); EB.SystemTables.setAv(MV); EB.SystemTables.setAs(1)
            EB.SystemTables.setEtext("FT-ORDERING.CU.ALREADY.INP")
            EB.ErrorProcessing.StoreEndError()
        END

        * CI_10032367 S
        *--------------
        * SEND.TO.PARTY
        *--------------

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotSendToParty)

        ** To validate the BANK TO BANK INFO call EB.VAL.BK.TO.BK ***
        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotSendToParty)
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBkToBkIn)<1,MV> NE "" AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotSendToParty)<1,MV> NE "" THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotSendToParty); EB.SystemTables.setAv(MV)
            EB.SystemTables.setEtext("FT.RTN.BANK.BANK.INFO.ALREADY.INP.1")
            EB.ErrorProcessing.StoreEndError()
            RETURN
        END

        NO.OF.MV = DCOUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBkToBkOut)<1,MV>,@SM)     ;*BG_10001351 S/E
        FOR I = 1 TO NO.OF.MV
            EB.SystemTables.setAs(1)
            BEGIN CASE
                CASE EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBkToBkOut)<1,MV,I> NE "" AND EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,MV> EQ ""
                    EB.SystemTables.setAv(MV)
                    EB.SystemTables.setEtext("FT.FC.INP.MISS")
                    EB.ErrorProcessing.StoreEndError()
                CASE EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBkToBkOut)<1,MV,I> EQ '' AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotSendToParty)<1,MV> NE ''
                    EB.SystemTables.setAv(MV)
                    EB.SystemTables.setEtext("FT.FC.INP.MISS")
                    EB.ErrorProcessing.StoreEndError()
            END CASE
        NEXT I

        IF EB.SystemTables.getEndError() THEN RETURN

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBkToBkOut)
        EB.Delivery.ValBkToBk()

        IF EB.SystemTables.getEtext() THEN
            EB.ErrorProcessing.StoreEndError()
            RETURN
        END

*** Check for Duplicate Send to Party *****

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotSendToParty)
        EB.Template.FtNullsChk()

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBkToBkOut)
        EB.Template.FtNullsChk()

        * CI_10032367 E

    NEXT MV

*-----------------------
* Rate fields validation
*-----------------------

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDebitCurrency) = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCreditCurrency) THEN
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotTreasuryRate) NE '' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotTreasuryRate)
            EB.SystemTables.setEtext("FT.FC.INVALID.SAME.CR/DR.CCY")
            EB.ErrorProcessing.StoreEndError()
        END
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCustomerRate) NE '' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCustomerRate)
            EB.SystemTables.setEtext("FT.FC.INVALID.SAME.CR/DR.CCY")
            EB.ErrorProcessing.StoreEndError()
        END
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCustomerSpread) NE '' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCustomerSpread)
            EB.SystemTables.setEtext("FT.FC.INVALID.SAME.CR/DR.CCY")
            EB.ErrorProcessing.StoreEndError()
        END
    END

*-------------------------------------
* Check the total of DR and CR amount if Credit amount is present else
* default the Credit amount equalent of Total Dedit amount.
*-------------------------------------

    DR.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDebitCurrency)
    CR.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCreditCurrency)
    DR.AMT = TOT.DR.AMT
    EXCH.RATE = ''

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCreditAmount) NE "" THEN

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCreditAmount)
        TOT.CR.AMT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCreditAmount)
        CR.AMT = TOT.CR.AMT

        *   Check the totals of debit and credit amounts without giving attention
        *   to Currency in case both the ccy's are same.

        IF DR.CCY EQ CR.CCY THEN
            IF TOT.DR.AMT NE TOT.CR.AMT THEN
                DIFF = TOT.DR.AMT - TOT.CR.AMT

                IF TOT.DR.AMT LT TOT.CR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCreditAmount)
                    EB.SystemTables.setEtext('FT-TOTAL.DR.LESS.BY':@FM:DIFF)
                    EB.ErrorProcessing.StoreEndError()
                END
                IF TOT.DR.AMT GT TOT.CR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCreditAmount)
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

            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotTreasuryRate) THEN EXCH.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotTreasuryRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCustomerRate) THEN CUST.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCustomerRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCustomerSpread) THEN CUST.SPREAD = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCustomerSpread)

            ST.ExchangeRate.Custrate(REQ.CCY.MKT,DR.CCY,DR.EQ.AMT,CR.CCY,CR.AMT,'',EXCH.RATE,CUST.RATE,CUST.SPREAD,CUST.SPREAD.PERCENT,DEBIT.LCY.AMOUNT,CREDIT.LCY.AMOUNT,RETURN.CODE)

            IF RETURN.CODE<1> NE "" THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCreditAmount)
                EB.SystemTables.setEtext("FT-CUSTRATE.ERR":@FM:EB.SystemTables.getEtext())
                EB.ErrorProcessing.StoreEndError()
            END

            EB.Foundation.ScFormatCcyAmt(DR.CCY,TOT.DR.AMT)

            * Check the Debit equalent amount with the TOT.DR.AMT (Sum of Debit amount)

            IF DR.EQ.AMT <> TOT.DR.AMT THEN
                DIFF = DR.EQ.AMT - TOT.DR.AMT

                IF DR.EQ.AMT LT TOT.DR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCreditAmount)
                    EB.SystemTables.setEtext('FT-TOTAL.CR.LESS.BY':@FM:DIFF)
                    EB.ErrorProcessing.StoreEndError()
                END
                IF DR.EQ.AMT GT TOT.DR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCreditAmount)
                    EB.SystemTables.setEtext('FT-TOTAL.DR.LESS.BY':@FM:DIFF)
                    EB.ErrorProcessing.StoreEndError()
                END
            END

        END

    END ELSE

        TOTAL.CREDIT.AMOUNT = ''
        IF DR.CCY EQ CR.CCY THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCreditAmount) = "" THEN
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

            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotTreasuryRate) THEN EXCH.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotTreasuryRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCustomerRate) THEN CUST.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCustomerRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCustomerSpread) THEN CUST.SPREAD = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCustomerSpread)

            ST.ExchangeRate.Custrate(REQ.CCY.MKT,DR.CCY,DR.AMT,CR.CCY,CR.EQ.AMT,'',EXCH.RATE,CUST.RATE,CUST.SPREAD,CUST.SPREAD.PERCENT,DEBIT.LCY.AMOUNT,CREDIT.LCY.AMOUNT,RETURN.CODE)

            IF RETURN.CODE<1> NE "" THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCreditAmount)
                EB.SystemTables.setEtext("FT-CUSTRATE.ERR":@FM:EB.SystemTables.getEtext())
                EB.ErrorProcessing.StoreEndError()
            END

            TOTAL.CREDIT.AMOUNT = CR.EQ.AMT
        END

    END




*----------------
* Processing date
*----------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotProcessingDate)

* Stop if Processing Date is < Today

    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) = '' THEN EB.SystemTables.setRNew(EB.SystemTables.getAf(), EB.SystemTables.getToday())

    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) LT EB.SystemTables.getToday() THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotProcessingDate)
        EB.SystemTables.setEtext('FT-DATE.CANT.L.TODAY')
        EB.ErrorProcessing.StoreEndError()
    END


*-----------------------
* Credit leg validations
*-----------------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCreditCurrency)
    R.ACCT.REC = ''
    AC.ERR = ''
    CREDIT.ACCNO = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCreditAccount)
    R.ACCT.REC = AC.AccountOpening.Account.Read(CREDIT.ACCNO, AC.ERR)
    IF NOT(AC.ERR) THEN
        ACCT.CCY = R.ACCT.REC<AC.AccountOpening.Account.Currency>
        BUL.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCreditCurrency)
        IF BUL.CCY NE ACCT.CCY THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCreditAccount)
            EB.SystemTables.setEtext("FT-INVALID.ACCT.FOR.CR.CCY")
            EB.ErrorProcessing.StoreEndError()
        END
    END


* Check for Credit value date field.

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCrValueDate) NE "" THEN
        CHK.TODAY.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatToday)
        IF R.TXN.TYPE(FT.Config.TxnTypeCondition.FtSixBackValueMaximum)[1,1] = "Y" THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCrValueDate) < CHK.TODAY.DAT AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCrValueDate) <> '' THEN
                EB.SystemTables.setEtext("FT.RTN.CR.DATE.VALUE.EXCEEDS.MAX.BACKVALUE")
                EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCrValueDate); EB.ErrorProcessing.StoreEndError()
            END
        END

        * If BACK.VALUE.MAXIMUM is No in FT.TXN.TYPE.CONDITION, then raise an error
        * if credit value date is lesser than BACK.VALUE.MAXIMUM from dates
        * application.

        CHK.TODAY.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatBackValueMaximum)
        IF R.TXN.TYPE(FT.Config.TxnTypeCondition.FtSixBackValueMaximum)[1,1] = "N" THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCrValueDate) < CHK.TODAY.DAT AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCrValueDate) <> '' THEN
                EB.SystemTables.setEtext("FT.RTN.CR.DATE.VALUE.EXCEEDS.MAX.BACKVALUE")
                EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCrValueDate); EB.ErrorProcessing.StoreEndError()
            END
        END

        * FORWARD VALUE

        CHK.TODAY.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatToday)
        IF R.TXN.TYPE(FT.Config.TxnTypeCondition.FtSixForwValueMaximum)[1,1] = "Y" THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCrValueDate) > CHK.TODAY.DAT AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCrValueDate) <> '' THEN
                EB.SystemTables.setEtext("FT.RTN.CR.DATE.VALUE.EXCEEDS.MAX.FORWARDVALUE")
                EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCrValueDate); EB.ErrorProcessing.StoreEndError()
            END
        END

        * If FORW.VALUE.MAXIMUM is No in FT.TXN.TYPE.CONDITION, then raise an error
        * if credit value date is greater than FORW.VALUE.MAXIMUM from dates
        * application.

        CHK.TODAY.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatForwValueMaximum)
        IF R.TXN.TYPE(FT.Config.TxnTypeCondition.FtSixForwValueMaximum)[1,1] = "N" THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCrValueDate) > CHK.TODAY.DAT AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCrValueDate) <> '' THEN
                EB.SystemTables.setEtext("FT.RTN.CR.DATE.VALUE.EXCEEDS.MAX.FORWARDVALUE")
                EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCrValueDate); EB.ErrorProcessing.StoreEndError()
            END
        END
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCrValueDate) > EB.SystemTables.getRDates(EB.Utility.Dates.DatForwValueMaximum) THEN
            EB.SystemTables.setEtext("FT.RTN.DATE.EXCEEDS.MAX.FORWARD")
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCrValueDate); EB.ErrorProcessing.StoreEndError()
        END
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCrValueDate) < EB.SystemTables.getRDates(EB.Utility.Dates.DatBackValueMaximum) THEN
            EB.SystemTables.setEtext("FT.RTN.DATE.EXCEEDS.MAX.BACK.VALUE")
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCrValueDate); EB.ErrorProcessing.StoreEndError()
        END

    END


*-----------------------
* Bank field validations
*-----------------------

* Multi value should not be allowed if SWIFT address given for Bank fields.

*
* INTERMED BANK
*
    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk)

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk)<1,1> NE '' THEN

        GOSUB VALIDATE.SWIFT.CODE

        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk)<1,1> = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk)<1,1> THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk); EB.SystemTables.setAv(1)
            EB.SystemTables.setEtext("FT-INTERMED.BANK.SAME.ACCT.WITH.BANK")
            EB.ErrorProcessing.StoreEndError()
        END
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk)<1,1> = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk) THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk)
            EB.SystemTables.setEtext("FT-INTERMED.BANK.SAME.RECEIVER.BANK")
            EB.ErrorProcessing.StoreEndError()
        END
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk)<1,1> = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk)<1,1> THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk); EB.SystemTables.setAv(1)
            EB.SystemTables.setEtext("FT-REC.CORR.BANK.SAME.INTERMED.BANK")
            EB.ErrorProcessing.StoreEndError()
        END
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk)<1,1> = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBenBank)<1,1> THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenBank); EB.SystemTables.setAv(1)
            EB.SystemTables.setEtext("FT-INTERMED.BANK.SAME.BEN.BANK")
            EB.ErrorProcessing.StoreEndError()
        END
    END

*
* RECEIVER BANK
*

* When the CREDIT.ACCOUNT is an internal account,  input in this
* field is mandatory.

    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCreditAccount)
    IF NOT(NUM(EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCreditAccount))) AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk) = "" THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk)
        EB.SystemTables.setEtext("FT.FC.RECEIVER.BANK.REQUIRED.IF.CR.ACCT.INTERNAL")
        EB.ErrorProcessing.StoreEndError()
    END

* The Receiver bank cannot be the same as the Customer of the credit
* account unless the credit account is a VOSTRO.
* AND
* Input in this field is not allowed when the Credit Account Number
* is a Vostro unless it is the Customer of the Vostro.


    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk) NE "" THEN
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk)[1,3] # "SW-" THEN

            DR.ACCT.VOSTRO = ""
            RETURN.CODE = ""
            OUT.COMP = EB.SystemTables.getIdCompany()
            CATEG = R.ACCT.REC<AC.AccountOpening.Account.Category>
            CUST = R.ACCT.REC<AC.AccountOpening.Account.Customer>
            AC.Config.CheckAccountClass("VOSTRO",CATEG,CUST,"",RETURN.CODE)

            IF RETURN.CODE EQ "NO" THEN
                DR.ACCT.VOSTRO = 0      ;* Debit acct is not a vostro acct.
            END ELSE
                DR.ACCT.VOSTRO = 1      ;* Debit acct is a vostro acct.
            END

            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk) AND DR.ACCT.VOSTRO = 1 THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk) NE CUST THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk)
                    EB.SystemTables.setEtext("FT.FC.INP.NOT.ALLOWED")
                    EB.ErrorProcessing.StoreEndError()
                END
            END
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk) = CUST THEN
                IF DR.ACCT.VOSTRO NE 1 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk)
                    EB.SystemTables.setEtext("FT.FC.DELETE.BANK.SAME.CR.ACCT.CUST")
                    EB.ErrorProcessing.StoreEndError()
                END
            END
        END
    END

*
* RECEIVER CORRESPONDENT BANK
*

    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk)

* This field will not be allowed unless the Receiver Bank is input.

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk)<1,1> AND NOT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk)) THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext("FT.FC.INVALID.RECEIVER.BANK.REQD")
        EB.ErrorProcessing.StoreEndError()
    END
    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk)<1,1> NE "" THEN

        GOSUB VALIDATE.SWIFT.CODE

        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk)<1,1> NE "" AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk)<1,1> = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk)<1,1> THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk); EB.SystemTables.setAv(1)
            EB.SystemTables.setEtext("FT.FC.REC.CORR.BANK.SAME.ACCT.WITH.BANK")
            EB.ErrorProcessing.StoreEndError()
        END

        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk)<1,1> NE "" AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk)<1,1> = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk)<1,1> THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk); EB.SystemTables.setAv(1)
            EB.SystemTables.setEtext("FT-REC.CORR.BANK.SAME.INTERMED.BANK")
            EB.ErrorProcessing.StoreEndError()
        END

        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBenBank)<1,1> NE "" AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk)<1,1> = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBenBank)<1,1> THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk); EB.SystemTables.setAv(1)
            EB.SystemTables.setEtext("FT.FC.REC.CORR.BANK.SAME.BEN.BANK")
            EB.ErrorProcessing.StoreEndError()
        END


    END


*
* ACCOUNT WITH BANK
*

    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk)

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk) NE "" THEN

        GOSUB VALIDATE.SWIFT.CODE

        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk)<1,1> = R.ACCT.REC<AC.AccountOpening.Account.Customer> THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk); EB.SystemTables.setAv(1)
            EB.SystemTables.setEtext("FT.FC.BANK.SAME.CR.ACCT.CU")
            EB.ErrorProcessing.StoreEndError()
        END

        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk)<1,1> = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk) THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk); EB.SystemTables.setAv(1)
            EB.SystemTables.setEtext("FT-ACCT.WITH.BANK.SAME.REC.BK")
            EB.ErrorProcessing.StoreEndError()
        END

        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk)<1,1> = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk)<1,1> THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk); EB.SystemTables.setAv(1)
            EB.SystemTables.setEtext("FT-ACCT.WITH.BANK.SAME.REC.CO.BK")
            EB.ErrorProcessing.StoreEndError()
        END

        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk)<1,1> = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk)<1,1> THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk); EB.SystemTables.setAv(1)
            EB.SystemTables.setEtext("FT-ACCT.WITH.BANK.SAME.IN.BK")
            EB.ErrorProcessing.StoreEndError()
        END

    END


*
* BENEFICIARY CUSTOMER & BENEFICIARY BANK
*
    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenCustomer)

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBenCustomer)<1,1> = "" AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBenBank)<1,1> = "" THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenCustomer); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext("FT.FC.BEN.CUSTOMER.OR.BEN.BANK.INP")
        EB.ErrorProcessing.StoreEndError()

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenBank); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext("FT.FC.BEN.CUSTOMER.OR.BEN.BANK.INP")
        EB.ErrorProcessing.StoreEndError()
    END

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBenCustomer)<1,1> NE "" AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBenBank)<1,1> NE "" THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenCustomer); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext("FT-BEN.CUST.AND.BEN.BANK.CANT.INP")
        EB.ErrorProcessing.StoreEndError()

        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenBank); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext("FT-BEN.CUST.AND.BEN.BANK.CANT.INP")
        EB.ErrorProcessing.StoreEndError()
    END

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBenCustomer)<1,1> NE "" THEN
        GOSUB VALIDATE.SWIFT.CODE
    END

    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenBank)
    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBenBank)<1,1> NE "" THEN
        GOSUB VALIDATE.SWIFT.CODE
    END

    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBkToBkIn)
    EB.Template.FtNullsChk()



*-------------------------
* Profit Centre Validation
*-------------------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotProfitCentreCust)

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotProfitCentreCust) NE "" AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotProfitCentreDept) NE "" THEN
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
    FOR I = 1 TO FT.BulkProcessing.BulkDrOt.BkdrotRecordStatus
        EB.SystemTables.setAf(I)
        IF INDEX(EB.SystemTables.getN(EB.SystemTables.getAf()), "C", 1) THEN
            *
            * Is it a sub value, a multi value or just a field
            *
            BEGIN CASE
                CASE EB.SystemTables.getF(EB.SystemTables.getAf())[4,2] = 'XX'      ;* Sv
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
                CASE EB.SystemTables.getF(EB.SystemTables.getAf())[1,2] = 'XX'      ;* Mv
                    EB.SystemTables.setAs('')
                    NO.OF.AV = DCOUNT(EB.SystemTables.getRNew(EB.SystemTables.getAf()), @VM)
                    IF NO.OF.AV = 0 THEN NO.OF.AV = 1
                    FOR K = 1 TO NO.OF.AV
                        EB.SystemTables.setAv(K)
                        GOSUB DO.CHECK.FIELD
                    NEXT K
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
    FT.BulkProcessing.BkDebitOtCheckFields()
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

    DIM R.TXN.TYPE(FT.Config.TxnTypeCondition.FtSixAuditDateTime)
    TXN.ID = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotTransactionType)

    R.TXN.TYPE.CONDITION = FT.Config.TxnTypeCondition.Read(TXN.ID, TYPE.ERR)
    MATPARSE R.TXN.TYPE FROM R.TXN.TYPE.CONDITION

    TRUE = 1

    RETURN
*
************************************************************************
*
VALIDATE.ORDERING.FIELDS:
    AS.COUNT = COUNT(EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,MV>,@SM)+1
    IF AS.COUNT > 1 AND EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,MV,1>[1,3] = 'SW-' THEN
        EB.SystemTables.setAf(EB.SystemTables.getAf()); EB.SystemTables.setAs(1)
        EB.SystemTables.setEtext("FT-NO.MV.WITH.SWIFT.ADD")
        EB.ErrorProcessing.StoreEndError()
    END
    IF AS.COUNT > 4 THEN
        EB.SystemTables.setAf(EB.SystemTables.getAf()); EB.SystemTables.setAs(5)
        EB.SystemTables.setEtext("FT-O.MAX.LINES.EXCEEDED")
        EB.ErrorProcessing.StoreEndError()
    END

    EB.Template.FtNullsChk()

    RETURN
*
************************************************************************
*
VALIDATE.SWIFT.CODE:
    AV.COUNT = DCOUNT(EB.SystemTables.getRNew(EB.SystemTables.getAf()),@VM)
    IF AV.COUNT > 1 AND EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,1>[1,3] = 'SW-' THEN
        EB.SystemTables.setAf(EB.SystemTables.getAf()); EB.SystemTables.setAv(2)
        EB.SystemTables.setEtext("FT-NO.MV.WITH.SWIFT.ADD")
        EB.ErrorProcessing.StoreEndError()
    END
    IF AV.COUNT > 4 THEN
        EB.SystemTables.setAf(EB.SystemTables.getAf()); EB.SystemTables.setAv(5)
        EB.SystemTables.setEtext("FT-O.MAX.LINES.EXCEEDED")
        EB.ErrorProcessing.StoreEndError()
    END

    EB.Template.FtNullsChk()

    RETURN
*
************************************************************************
*
    END
