* @ValidationCode : MjotMTMxNzM5NTYwODpDcDEyNTI6MTU3MTA0NDU2Nzk5MDpzcmF2aWt1bWFyOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkxMC4yMDE5MDkwNS0xMDU0Oi0xOi0x
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

* Version 2 02/06/00  GLOBUS Release No. G14.1.01 04/12/03
*-----------------------------------------------------------------------------
* <Rating>3460</Rating>
*-----------------------------------------------------------------------------
$PACKAGE FT.BulkProcessing
SUBROUTINE FT.BK.CREDIT.OT.CROSSVAL
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
* 03/08/04 - BG_100007000
*            BUG in rate field validation.
*
* 04/08/04 - BG_100007047
*            Single Dr/Cr transaction should not be allowed.
*
* 1/08/05 - CI_10032367
*           New fields SEND.TO.PARTY & BK.TO.BK.OUT introduced.
*
* 20/04/07 - BG_100013651
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*03/08/15 -  Enhancement 1265068
*         -  Task 1433976
*			 Routine incorporated
*
* 14/10/19 - Defect 3381717 / Task 3381914
*            Code changes done to process new LIMIT.REFERENCE key format.
*
************************************************************************
*
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING EB.Utility
    $USING EB.Foundation
    $USING EB.Delivery
    $USING EB.Template
    $USING FT.Config
    $USING AC.AccountOpening
    $USING ST.ExchangeRate
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
    tmp.END.ERROR = EB.SystemTables.getEndError()
    tmp.E = EB.SystemTables.getE()
    tmp.ETEXT = EB.SystemTables.getEtext()
    IF NOT(tmp.ETEXT) AND NOT(tmp.E) AND NOT(tmp.END.ERROR)THEN         ;* BG_100006940 - S
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotTreasuryRate) = '' THEN EB.SystemTables.setRNew(FT.BulkProcessing.BulkCrOt.BkcrotTreasuryRate, EXCH.RATE)
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDebitAmount) = '' THEN EB.SystemTables.setRNew(FT.BulkProcessing.BulkCrOt.BkcrotDebitAmount, TOTAL.DEBIT.AMOUNT)
    END       ;* BG_100006940 - E

RETURN
*
************************************************************************
*
REAL.CROSSVAL:
*
* Real cross validation goes here....
*

*--------------------------
* Debit currency validation
*--------------------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotDebitCurrency)
    R.ACCOUNT.RECORD = ''
    READ.ERROR = ''
    DEBIT.ACCNO = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDebitAccount)
    R.ACCOUNT.RECORD = AC.AccountOpening.Account.Read(DEBIT.ACCNO, READ.ERROR)
    IF NOT(READ.ERROR) THEN
        ACC.CCY = R.ACCOUNT.RECORD<AC.AccountOpening.Account.Currency>
        BULK.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDebitCurrency)
        IF BULK.CCY NE ACC.CCY THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotDebitCurrency)
            EB.SystemTables.setEtext("FT-INVALID.CCY.FOR.DB.ACC")
            EB.ErrorProcessing.StoreEndError()
        END
    END

*----------------------------
* Debit Value date validation
*----------------------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate)
    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate) NE "" THEN
        CHK.TODAY.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatToday)
        IF R.TXN.TYPE(FT.Config.TxnTypeCondition.FtSixBackValueMaximum)[1,1] = "Y" THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate) < CHK.TODAY.DAT AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate) <> '' THEN
                EB.SystemTables.setEtext("FT.RTN.DR.DATE.VALUE.EXCEEDS.MAX.BACKVALUE")
                EB.SystemTables.setAv(''); EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate); EB.ErrorProcessing.StoreEndError()
            END
        END

* If BACK.VALUE.MAXIMUM is No in FT.TXN.TYPE.CONDITION, then raise an error
* if debit value date is lesser than BACK.VALUE.MAXIMUM from dates
* application.

        CHK.TODAY.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatBackValueMaximum)
        IF R.TXN.TYPE(FT.Config.TxnTypeCondition.FtSixBackValueMaximum)[1,1] = "N" THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate) < CHK.TODAY.DAT AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate) <> '' THEN
                EB.SystemTables.setEtext("FT.RTN.DR.DATE.VALUE.EXCEEDS.MAX.BACKVALUE")
                EB.SystemTables.setAv(''); EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate); EB.ErrorProcessing.StoreEndError()
            END
        END

* FORWARD VALUE

        CHK.TODAY.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatToday)
        IF R.TXN.TYPE(FT.Config.TxnTypeCondition.FtSixForwValueMaximum)[1,1] = "Y" THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate) > CHK.TODAY.DAT AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate) <> '' THEN
                EB.SystemTables.setEtext("FT.RTN.DR.DATE.VALUE.EXCEEDS.MAX.FORWARDVALUE")
                EB.SystemTables.setAv(''); EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate); EB.ErrorProcessing.StoreEndError()
            END
        END

* If FORW.VALUE.MAXIMUM is No in FT.TXN.TYPE.CONDITION, then raise an error
* if debit value date is greater than FORW.VALUE.MAXIMUM from dates
* application.

        CHK.TODAY.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatForwValueMaximum)
        IF R.TXN.TYPE(FT.Config.TxnTypeCondition.FtSixForwValueMaximum)[1,1] = "N" THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate) > CHK.TODAY.DAT AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate) <> '' THEN
                EB.SystemTables.setEtext("FT.RTN.DR.DATE.VALUE.EXCEEDS.MAX.FORWARDVALUE")
                EB.SystemTables.setAv(''); EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate); EB.ErrorProcessing.StoreEndError()
            END
        END

        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate) > EB.SystemTables.getRDates(EB.Utility.Dates.DatForwValueMaximum) THEN
            EB.SystemTables.setEtext("FT.RTN.DATE.EXCEEDS.MAX.FORWARD")
            EB.SystemTables.setAv(''); EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate); EB.ErrorProcessing.StoreEndError()
        END
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate) < EB.SystemTables.getRDates(EB.Utility.Dates.DatBackValueMaximum) THEN
            EB.SystemTables.setEtext("FT.RTN.DATE.EXCEEDS.MAX.BACK.VALUE")
            EB.SystemTables.setAv(''); EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotDrValueDate); EB.ErrorProcessing.StoreEndError()
        END

    END

*-------------------------------------------------------------------
* Check is done to ensure that Dr acct is not duplicated in Cr acct.
*-------------------------------------------------------------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotDebitAccount)
    DEBIT.ACCT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDebitAccount)
    CREDIT.ACCT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCreditAccount)
    LOCATE DEBIT.ACCT IN CREDIT.ACCT<1,1> SETTING POS ELSE POS = ''
    IF POS THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotCreditAccount); EB.SystemTables.setAv(POS)
        EB.SystemTables.setEtext("FT-ACCT.CANT.BE.SAME")
        EB.ErrorProcessing.StoreEndError()
    END

*--------------------------------------------
* Crossvalidation for the multi-valued fields
*--------------------------------------------

    TOT.CR.AMT = ''

    NO.OF.CR = COUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCreditAccount), @VM)+1

* Single credit transaction not allowed

    IF NO.OF.CR LE 1 THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotCreditAccount); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext("FT-SINGLE.CR.DR.NOT.ALLOWED")
        EB.ErrorProcessing.StoreEndError()
        RETURN
    END

    FOR MV = 1 TO NO.OF.CR

        TOT.CR.AMT += EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCreditAmount)<1,MV>

* Check for Credit value date field.

        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCrValueDate)<1,MV> NE "" THEN
            CHK.TODAY.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatToday)
            IF R.TXN.TYPE(FT.Config.TxnTypeCondition.FtSixBackValueMaximum)[1,1] = "Y" THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCrValueDate)<1,MV> < CHK.TODAY.DAT AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCrValueDate)<1,MV> <> '' THEN
                    EB.SystemTables.setEtext("FT.RTN.CR.DATE.VALUE.EXCEEDS.MAX.BACKVALUE")
                    EB.SystemTables.setAv(MV); EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotCrValueDate); EB.ErrorProcessing.StoreEndError()
                END
            END

* If BACK.VALUE.MAXIMUM is No in FT.TXN.TYPE.CONDITION, then raise an error
* if credit value date is lesser than BACK.VALUE.MAXIMUM from dates
* application.

            CHK.TODAY.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatBackValueMaximum)
            IF R.TXN.TYPE(FT.Config.TxnTypeCondition.FtSixBackValueMaximum)[1,1] = "N" THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCrValueDate)<1,MV> < CHK.TODAY.DAT AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCrValueDate)<1,MV> <> '' THEN
                    EB.SystemTables.setEtext("FT.RTN.CR.DATE.VALUE.EXCEEDS.MAX.BACKVALUE")
                    EB.SystemTables.setAv(MV); EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotCrValueDate); EB.ErrorProcessing.StoreEndError()
                END
            END

* FORWARD VALUE

            CHK.TODAY.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatToday)
            IF R.TXN.TYPE(FT.Config.TxnTypeCondition.FtSixForwValueMaximum)[1,1] = "Y" THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCrValueDate)<1,MV> > CHK.TODAY.DAT AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCrValueDate)<1,MV> <> '' THEN
                    EB.SystemTables.setEtext("FT.RTN.CR.DATE.VALUE.EXCEEDS.MAX.FORWARDVALUE")
                    EB.SystemTables.setAv(MV); EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotCrValueDate); EB.ErrorProcessing.StoreEndError()
                END
            END

* If FORW.VALUE.MAXIMUM is No in FT.TXN.TYPE.CONDITION, then raise an error
* if credit value date is greater than FORW.VALUE.MAXIMUM from dates
* application.

            CHK.TODAY.DAT = EB.SystemTables.getRDates(EB.Utility.Dates.DatForwValueMaximum)
            IF R.TXN.TYPE(FT.Config.TxnTypeCondition.FtSixForwValueMaximum)[1,1] = "N" THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCrValueDate)<1,MV> > CHK.TODAY.DAT AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCrValueDate)<1,MV> <> '' THEN
                    EB.SystemTables.setEtext("FT.RTN.CR.DATE.VALUE.EXCEEDS.MAX.FORWARDVALUE")
                    EB.SystemTables.setAv(MV); EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotCrValueDate); EB.ErrorProcessing.StoreEndError()
                END
            END
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCrValueDate)<1,MV> > EB.SystemTables.getRDates(EB.Utility.Dates.DatForwValueMaximum) THEN
                EB.SystemTables.setEtext("FT.RTN.DATE.EXCEEDS.MAX.FORWARD")
                EB.SystemTables.setAv(MV); EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotCrValueDate); EB.ErrorProcessing.StoreEndError()
            END
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCrValueDate)<1,MV> < EB.SystemTables.getRDates(EB.Utility.Dates.DatBackValueMaximum) THEN
                EB.SystemTables.setEtext("FT.RTN.DATE.EXCEEDS.MAX.BACK.VALUE")
                EB.SystemTables.setAv(MV); EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotCrValueDate); EB.ErrorProcessing.StoreEndError()
            END

        END

*----------------
        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotCreditCurrency)
        R.ACCT.REC = ''
        AC.ERR = ''
        CREDIT.ACCNO = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCreditAccount)<1,MV>
        R.ACCT.REC = AC.AccountOpening.Account.Read(CREDIT.ACCNO, AC.ERR)
        IF NOT(AC.ERR) THEN
            ACCT.CCY = R.ACCT.REC<AC.AccountOpening.Account.Currency>
            BUL.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCreditCurrency)
            IF BUL.CCY NE ACCT.CCY THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotCreditAccount);  EB.SystemTables.setAv(MV)
                EB.SystemTables.setEtext("FT-INVALID.ACCT.FOR.CR.CCY")
                EB.ErrorProcessing.StoreEndError()
            END
        END
*------------
* Multi value should not be allowed if SWIFT address is given for Bank fields.

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk)
        AS.COUNT = DCOUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk)<1,MV>,@SM)
        IF AS.COUNT > 1 AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk)<1,MV,1>[1,3] = 'SW-' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk); EB.SystemTables.setAv(MV); EB.SystemTables.setAs(2)
            EB.SystemTables.setEtext("FT-NO.MV.WITH.SWIFT.ADD")
            EB.ErrorProcessing.StoreEndError()
        END
        EB.Template.FtNullsChk()

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotRecCorrBk)
        AS.COUNT = DCOUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotRecCorrBk)<1,MV>,@SM)
        IF AS.COUNT > 1 AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotRecCorrBk)<1,MV,1>[1,3] = 'SW-' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotRecCorrBk); EB.SystemTables.setAv(MV); EB.SystemTables.setAs(2)
            EB.SystemTables.setEtext("FT-NO.MV.WITH.SWIFT.ADD")
            EB.ErrorProcessing.StoreEndError()
        END
        EB.Template.FtNullsChk()

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk)
        AS.COUNT = DCOUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk)<1,MV>,@SM)
        IF AS.COUNT > 1 AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk)<1,MV,1>[1,3] = 'SW-' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk); EB.SystemTables.setAv(MV); EB.SystemTables.setAs(2)
            EB.SystemTables.setEtext("FT-NO.MV.WITH.SWIFT.ADD")
            EB.ErrorProcessing.StoreEndError()
        END
        EB.Template.FtNullsChk()

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenBank)
        AS.COUNT = DCOUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBenBank)<1,MV>,@SM)
        IF AS.COUNT > 1 AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBenBank)<1,MV,1>[1,3] = 'SW-' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenBank); EB.SystemTables.setAv(MV); EB.SystemTables.setAs(2)
            EB.SystemTables.setEtext("FT-NO.MV.WITH.SWIFT.ADD")
            EB.ErrorProcessing.StoreEndError()
        END
        EB.Template.FtNullsChk()

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBkToBkIn)
        EB.Template.FtNullsChk()

        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotReceiverBk)<1,MV> AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBenBank)<1,MV,1> THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotReceiverBk)<1,MV> = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBenBank)<1,MV,1> THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenBank); EB.SystemTables.setAv(MV); EB.SystemTables.setAs(1)
                EB.SystemTables.setEtext("FT.FC.NO.INP.ALLOWED")
                EB.ErrorProcessing.StoreEndError()
            END
        END

        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk)<1,MV,1> = R.ACCT.REC<AC.AccountOpening.Account.Customer> THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk); EB.SystemTables.setAv(MV); EB.SystemTables.setAs(1)
            EB.SystemTables.setEtext("FT.FC.BANK.SAME.CR.ACCT.CU")
            EB.ErrorProcessing.StoreEndError()
        END

* If RECEIVER BANK same as ACCT WITH BANK then dont allow.
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotReceiverBk)<1,MV> AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk)<1,MV,1> THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotReceiverBk)<1,MV> = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk)<1,MV,1> THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk); EB.SystemTables.setAv(MV); EB.SystemTables.setAs(1)
                EB.SystemTables.setEtext("FT-RECEIVER.BANK.SAME.ACCT.WITH.BANK")
                EB.ErrorProcessing.StoreEndError()
            END
        END

* If both the a/c are nostro then BEN bank fields not needed else either
* one BEN bank field is needed.

        IF R.ACCOUNT.RECORD<AC.AccountOpening.Account.LimitRef> = "NOSTRO" AND R.ACCT.REC<AC.AccountOpening.Account.LimitRef> = "NOSTRO" THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBenCustomer)<1,MV> NE '' THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenCustomer); EB.SystemTables.setAv(MV)
                EB.SystemTables.setEtext("FT-NO.INP.ALLOWED.IF.CR.DR.ACCTS.NOS")
                EB.ErrorProcessing.StoreEndError()
            END
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBenBank)<1,MV,1> NE '' THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenBank); EB.SystemTables.setAv(MV); EB.SystemTables.setAs(1)
                EB.SystemTables.setEtext("FT-NO.INP.ALLOWED.IF.CR.DR.ACCTS.NOS")
                EB.ErrorProcessing.StoreEndError()
            END
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBenAcctNo)<1,MV> NE '' THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenAcctNo); EB.SystemTables.setAv(MV)
                EB.SystemTables.setEtext("FT-NO.INP.ALLOWED.IF.CR.DR.ACCTS.NOS")
                EB.ErrorProcessing.StoreEndError()
            END
        END ELSE
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBenCustomer)<1,MV> = '' AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBenBank)<1,MV,1> = '' THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenCustomer); EB.SystemTables.setAv(MV)
                EB.SystemTables.setEtext("FT-BEN.CUSTOMER.OR.BEN.BANK.INP")
                EB.ErrorProcessing.StoreEndError()
            END
        END

* If REC.CORR.BANK same as INTERMED.BANK then dont allow.
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk)<1,MV,1> AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotRecCorrBk)<1,MV,1> THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk)<1,MV,1> = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotRecCorrBk)<1,MV,1> THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotRecCorrBk); EB.SystemTables.setAv(MV); EB.SystemTables.setAs(1)
                EB.SystemTables.setEtext("FT-REC.CORR.BANK.SAME.INTERMED.BANK")
                EB.ErrorProcessing.StoreEndError()
            END
        END

* If INTERMED BANK same as RECEIVER BANK then dont allow.
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk)<1,MV,1> AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotReceiverBk)<1,MV> THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk)<1,MV,1> = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotReceiverBk)<1,MV> THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotReceiverBk); EB.SystemTables.setAv(MV)
                EB.SystemTables.setEtext("FT-INTERMED.BANK.SAME.RECEIVER.BANK")
                EB.ErrorProcessing.StoreEndError()
            END
        END

* CI_10032367 S
*--------------
* SEND.TO.PARTY
*--------------

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotSendToParty)

** To validate the BANK TO BANK INFO call EB.VAL.BK.TO.BK ***
        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotSendToParty)
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBkToBkIn)<1,MV> NE "" AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotSendToParty)<1,MV> NE "" THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotSendToParty); EB.SystemTables.setAv(MV)
            EB.SystemTables.setEtext("FT.RTN.BANK.BANK.INFO.ALREADY.INP.1")
            EB.ErrorProcessing.StoreEndError()
            RETURN
        END

        NO.OF.MV = COUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBkToBkOut)<1,MV>,@SM) + 1      ;*BG_100013651 S/E
        FOR I = 1 TO NO.OF.MV
            EB.SystemTables.setAs(1)
            BEGIN CASE
                CASE EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBkToBkOut)<1,MV,I> NE "" AND EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,MV> EQ ""
                    EB.SystemTables.setAv(MV)
                    EB.SystemTables.setEtext("FT.FC.INP.MISS")
                    EB.ErrorProcessing.StoreEndError()
                CASE EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBkToBkOut)<1,MV,I> EQ '' AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotSendToParty)<1,MV> NE ''
                    EB.SystemTables.setAv(MV)
                    EB.SystemTables.setEtext("FT.FC.INP.MISS")
                    EB.ErrorProcessing.StoreEndError()
            END CASE
        NEXT I

        IF EB.SystemTables.getEndError() THEN RETURN

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBkToBkOut)
        EB.Delivery.ValBkToBk()

        IF EB.SystemTables.getEtext() THEN
            EB.ErrorProcessing.StoreEndError()
            RETURN
        END

*** Check for Duplicate Send to Party *****

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotSendToParty)
        EB.Template.FtNullsChk()

        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBkToBkOut)
        EB.Template.FtNullsChk()

* CI_10032367 E


    NEXT MV
*---------------

* Rate fields validation.

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDebitCurrency) = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCreditCurrency) THEN
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotTreasuryRate) NE '' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotTreasuryRate)
            EB.SystemTables.setEtext("FT.FC.INVALID.SAME.CR/DR.CCY")
            EB.ErrorProcessing.StoreEndError()
        END
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCustomerRate) NE '' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotCustomerRate)
            EB.SystemTables.setEtext("FT.FC.INVALID.SAME.CR/DR.CCY")
            EB.ErrorProcessing.StoreEndError()
        END
        IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCustomerSpread) NE '' THEN
            EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotCustomerSpread)
            EB.SystemTables.setEtext("FT.FC.INVALID.SAME.CR/DR.CCY")
            EB.ErrorProcessing.StoreEndError()
        END
    END

*---------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotOrderingCust)

    AV.COUNT = DCOUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotOrderingCust),@VM)
    IF AV.COUNT > 1 AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotOrderingCust)<1,1>[1,3] = 'SW-' THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotOrderingCust); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext("FT-NO.MV.WITH.SWIFT.ADD")
        EB.ErrorProcessing.StoreEndError()
    END
    EB.Template.FtNullsChk()

    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotOrderingBank)
    AV.COUNT = DCOUNT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotOrderingBank),@VM)
    IF AV.COUNT > 1 AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotOrderingBank)<1,1>[1,3] = 'SW-' THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotOrderingBank); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext("FT-NO.MV.WITH.SWIFT.ADD")
        EB.ErrorProcessing.StoreEndError()
    END
    EB.Template.FtNullsChk()


*-------------------------------------
* Check the total of DR and CR amount if Debit amount is present else
* default the Debit amount equalent of Total Credit amount.
*-------------------------------------

    DR.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDebitCurrency)          ;* BG_100006940 - S
    CR.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCreditCurrency)
    CR.AMT = TOT.CR.AMT
    EXCH.RATE = ""

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDebitAmount) NE "" THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotDebitAmount)

        TOT.DR.AMT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDebitAmount)
        DR.AMT = TOT.DR.AMT


*   Check the totals of debit and credit amounts without giving attention
*   to Currency in case both the ccy's are same.

        IF DR.CCY EQ CR.CCY THEN
            IF TOT.DR.AMT NE TOT.CR.AMT THEN
                DIFF = TOT.DR.AMT - TOT.CR.AMT

                IF TOT.DR.AMT LT TOT.CR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotDebitAmount)
                    EB.SystemTables.setEtext('FT-TOTAL.DR.LESS.BY':@FM:DIFF)
                    EB.ErrorProcessing.StoreEndError()
                END
                IF TOT.DR.AMT GT TOT.CR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotDebitAmount)
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

            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotTreasuryRate) THEN EXCH.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotTreasuryRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCustomerRate) THEN CUST.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCustomerRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCustomerSpread) THEN CUST.SPREAD = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCustomerSpread)

            ST.ExchangeRate.Custrate(REQ.CCY.MKT,DR.CCY,DR.AMT,CR.CCY,CR.EQ.AMT,'',EXCH.RATE,CUST.RATE,CUST.SPREAD,CUST.SPREAD.PERCENT,DEBIT.LCY.AMOUNT,CREDIT.LCY.AMOUNT,RETURN.CODE)

            IF RETURN.CODE<1> NE "" THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotDebitAmount)
                EB.SystemTables.setEtext("FT-CUSTRATE.ERR":@FM:EB.SystemTables.getEtext())
                EB.ErrorProcessing.StoreEndError()
            END

            EB.Foundation.ScFormatCcyAmt(CR.CCY,TOT.CR.AMT)

* Check the Credit equalent amount with the TOT.CR.AMT (Sum of credit amount)

            IF CR.EQ.AMT <> TOT.CR.AMT THEN
                DIFF = CR.EQ.AMT - TOT.CR.AMT

                IF CR.EQ.AMT LT TOT.CR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotDebitAmount)
                    EB.SystemTables.setEtext('FT-TOTAL.DR.LESS.BY':@FM:DIFF)
                    EB.ErrorProcessing.StoreEndError()
                END
                IF CR.EQ.AMT GT TOT.CR.AMT THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotDebitAmount)
                    EB.SystemTables.setEtext('FT-TOTAL.CR.LESS.BY':@FM:DIFF)
                    EB.ErrorProcessing.StoreEndError()
                END
            END

        END
    END ELSE
        TOTAL.DEBIT.AMOUNT = ''
        IF DR.CCY EQ CR.CCY THEN
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDebitAmount) = "" THEN
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

            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotTreasuryRate) THEN EXCH.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotTreasuryRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCustomerRate) THEN CUST.RATE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCustomerRate)
            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCustomerSpread) THEN CUST.SPREAD = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCustomerSpread)

            ST.ExchangeRate.Custrate(REQ.CCY.MKT,DR.CCY,DR.EQ.AMT,CR.CCY,CR.AMT,'',EXCH.RATE,CUST.RATE,CUST.SPREAD,CUST.SPREAD.PERCENT,DEBIT.LCY.AMOUNT,CREDIT.LCY.AMOUNT,RETURN.CODE)

            IF RETURN.CODE<1> NE "" THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotDebitAmount)
                EB.SystemTables.setEtext("FT-CUSTRATE.ERR":@FM:EB.SystemTables.getEtext())
                EB.ErrorProcessing.StoreEndError()
            END

            TOTAL.DEBIT.AMOUNT = DR.EQ.AMT
        END
    END       ;* BG_100006940 - E

*----------------
* Processing date
*----------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotProcessingDate)

* Stop if Processing Date is < Today

    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) = '' THEN EB.SystemTables.setRNew(EB.SystemTables.getAf(), EB.SystemTables.getToday())

    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) LT EB.SystemTables.getToday() THEN
        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotProcessingDate)
        EB.SystemTables.setEtext('FT-DATE.CANT.L.TODAY')
        EB.ErrorProcessing.StoreEndError()
    END


*-------------------------
* Profit Centre Validation
*-------------------------

    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotProfitCentreCust)

    DR.NOSTRO.ACCT = ''
    DEBIT.ACC = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDebitAccount)
    R.DEBIT.ACCT = AC.AccountOpening.Account.Read(DEBIT.ACC, ACCT.ERR)
    IF R.DEBIT.ACCT<AC.AccountOpening.Account.LimitRef> = 'NOSTRO' THEN DR.NOSTRO.ACCT = 1


    BEGIN CASE
        CASE EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotProfitCentreCust) = "" AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotProfitCentreDept) = ""
            IF NOT(NUM(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDebitAccount))) OR DR.NOSTRO.ACCT THEN
                EB.SystemTables.setEtext("FT-PRO.CENT.CUST.OR.DEPT.INPUT")
                EB.ErrorProcessing.StoreEndError()
            END ELSE
                EB.SystemTables.setRNew(FT.BulkProcessing.BulkCrOt.BkcrotProfitCentreCust, R.DEBIT.ACCT<AC.AccountOpening.Account.Customer>)
            END

        CASE EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotProfitCentreCust) NE "" AND EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotProfitCentreDept) NE ""
            EB.SystemTables.setEtext("FT.FC.DEFINE.ONLY.1.PROFIT.CENTRE.FLD")
            EB.ErrorProcessing.StoreEndError()
    END CASE



RETURN
*
************************************************************************
*
REPEAT.CHECK.FIELDS:
*
* Loop through each field and repeat the check field processing if there is any defined
*
    FOR I = 1 TO FT.BulkProcessing.BulkCrOt.BkcrotRecordStatus
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
    FT.BulkProcessing.BkCreditOtCheckFields()       ;* BG_100006940 S/E
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
    TXN.ID = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotTransactionType)
    R.TXN.TYPE.CONDITION = FT.Config.TxnTypeCondition.Read(TXN.ID, READ.ER)

    MATPARSE R.TXN.TYPE FROM R.TXN.TYPE.CONDITION
RETURN
*
************************************************************************
*
END
