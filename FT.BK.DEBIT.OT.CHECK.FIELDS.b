* @ValidationCode : MjoxMjM5OTIwNDE1OkNwMTI1MjoxNjA4MjAwNTA0NjU1OnNjaGFuZGluaTotMTotMTowOjE6dHJ1ZTpOL0E6REVWXzIwMjAxMi4xOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Dec 2020 15:51:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : schandini
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : DEV_202012.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 21/07/00  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>7256</Rating>
*-----------------------------------------------------------------------------
$PACKAGE FT.BulkProcessing
SUBROUTINE FT.BK.DEBIT.OT.CHECK.FIELDS
******************************************************************************
* Routine for Dynamic template Online validation for Bulk Debit of OT Txn type
******************************************************************************
* 15/07/04 - BG_100006954
*            New Version
*
* 01/08/05 - CI_10032367
*            CROSS COMPILATION
*
* 20/07/10 - Task 66080
*            Change the reads to Customer to use the Customer
*            Service api calls
*
* 19/01/11 - Task 131643
*            Parameter file FT.APPL.DEFAULT shld be read using EB.READ.PARAMETER.
*            Removed opening of file FT.APPL.DEFAULT since EB.READ.PARAMETER will
*            the open the file if file is passed as null.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
* 22/09/15 - Enhancement 1390617 / Task 1393200
*            Moved the routine IN2CUST.BIC from FT to ST. Hence call to IN2CUST.BIC
*            referred using component ST.Payments
*
* 08/12/2020 - Enhancement 4020994 / Task 4035326
*              Changing BY.Payments reference to new component reference BY.Payments since
*              beneficiary and beneficiary links table has been moved to new module BY.
*********************************************************************************
    $USING EB.SystemTables
    $USING EB.Template
    $USING EB.Display
    $USING ST.CompanyCreation
    $USING ST.Config
    $USING AC.AccountOpening
    $USING AC.Config
    $USING FT.Config
    $USING FT.Contract
    $USING BY.Payments
    $USING DE.API
    $USING FT.BulkProcessing
    $INSERT I_CustomerService_NameAddress
*
************************************************************************
*
*
************************************************************************
*
    GOSUB INITIALISE
*
************************************************************************
*
* Default the current field if input is null and the field is null.
*
    BEGIN CASE
        CASE EB.SystemTables.getAs()
            INTO.FIELD = EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>
        CASE EB.SystemTables.getAv()
            INTO.FIELD = EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()>
        CASE 1
            INTO.FIELD = EB.SystemTables.getRNew(EB.SystemTables.getAf())
    END CASE
*
    IF EB.SystemTables.getComi() = '' AND INTO.FIELD = '' THEN
        GOSUB DEFAULT.FIELDS
    END

*
* Real validation here.....
*
    GOSUB CHECK.FIELDS

*
* Now default other fields from this one if there is a value....
*
    IF EB.SystemTables.getComi() THEN
        COMI.ENRI.SAVE = EB.SystemTables.getComiEnri()
        EB.SystemTables.setComiEnri('')
        GOSUB DEFAULT.OTHER.FIELDS
        EB.SystemTables.setComiEnri(COMI.ENRI.SAVE)
    END

************************************************************************
*
* All done here.
*
RETURN
*
************************************************************************
* Local subroutines....
************************************************************************
*
INITIALISE:
    EB.SystemTables.setE('')
    EB.SystemTables.setEtext('')
    MESSAGE.TYPE = ''
    DR.CCY = ''
*
* Open files....

    F.APP.DEF=""
    R.APPL.PARM.ID = ''
    DIM R.APPLICATION.DEFAULT.LOC(FT.Config.ApplDefault.FtOneAuditDateTime)
    ST.CompanyCreation.EbReadParameter('F.FT.APPL.DEFAULT','N','',R.APPLICATION.DEFAULT.REC,R.APPL.PARM.ID,F.APP.DEF,EB.SystemTables.getEtext())
    MATPARSE R.APPLICATION.DEFAULT.LOC FROM R.APPLICATION.DEFAULT.REC
RETURN
*
************************************************************************
*
DEFAULT.FIELDS:
*
    BEGIN CASE
*         CASE AF = XX.FIELD.NUMBER
*            COMI = TODAY

    END CASE
* GB0001758
    EB.Display.RefreshField(EB.SystemTables.getAf(),"")

RETURN
************************************************************************
DEFAULT.OTHER.FIELDS:

    DEFAULTED.FIELD = ''
    DEFAULTED.ENRI = ''
    BEGIN CASE
*         CASE AF = XX.FIELD.NUMBER
*              DEFAULTED.FIELD = XX.FIELD.NUMBER
*              DEFAULTED.ENRI = ENRI

    END CASE

    EB.Display.RefreshField(DEFAULTED.FIELD, DEFAULTED.ENRI)

RETURN
*
************************************************************************
*
CHECK.FIELDS:
*
* Where an error occurs, set E
*
    BEGIN CASE

*-----------------
* Transaction Type
*-----------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDrOt.BkdrotTransactionType

            IF EB.SystemTables.getComi() = '' THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotTransactionType)
                EB.SystemTables.setE("FT-INP.MISS")
                RETURN
            END

            IF EB.SystemTables.getComi() NE '' AND EB.SystemTables.getComi()[1,2] NE 'OT' THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotTransactionType)
                EB.SystemTables.setE("FT-ONLY.OT.TYPE.TXN.ALLOWED")
                RETURN
            END

            IF EB.SystemTables.getComi() THEN
                IF MESSAGE.TYPE = '' THEN
                    R.TXN.TYPE.RECORD = '' ; READ.ERR = '' ; TRANS.TYPE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotTransactionType)
                    R.TXN.TYPE.RECORD = FT.Config.TxnTypeCondition.Read(TRANS.TYPE, READ.ERR)
                    IF READ.ERR = '' THEN
                        MESSAGE.TYPE = R.TXN.TYPE.RECORD<FT.Config.TxnTypeCondition.FtSixMessageType>
                    END
                END
            END


*-----------------------------
* Debit a/c no & credit a/c no
*-----------------------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDrOt.BkdrotDebitAccount OR EB.SystemTables.getAf() = FT.BulkProcessing.BulkDrOt.BkdrotCreditAccount
            IF EB.SystemTables.getComi() NE '' THEN
                SAVE.AF = EB.SystemTables.getAf()
                IF NOT (EB.SystemTables.getComi()[1,7] MATCHES 'PL5N') THEN

                    N1 = '16..C'
                    T1 = '.ALLACCVAL'
                    OBJECT.ID="ACCOUNT" ; MAX.LEN=""
                    FT.Contract.In2Allaccval(N1,T1)
                    IF EB.SystemTables.getEtext() THEN
                        EB.SystemTables.setAf(SAVE.AF)
                        EB.SystemTables.setE(EB.SystemTables.getEtext())
                        RETURN
                    END

                    READ.ERROR=""
                    R.ACCOUNT.RECORD = ''
                    R.ACCOUNT.RECORD = AC.AccountOpening.Account.Read(EB.SystemTables.getComi(), READ.ERROR)
                    IF READ.ERROR NE '' THEN
                        EB.SystemTables.setAf(SAVE.AF)
                        EB.SystemTables.setE("FT-NO.ACCT.RECORD")
                        RETURN
                    END

                    EB.SystemTables.setComiEnri(R.ACCOUNT.RECORD<AC.AccountOpening.Account.ShortTitle>)

                END ELSE

                    EB.SystemTables.setAf(SAVE.AF)
                    EB.SystemTables.setE('FT-PL.NOT.ALLOWED')
                    RETURN

                END

* Check Credit a/c no for Nostro/Vostro

                IF EB.SystemTables.getAf() = FT.BulkProcessing.BulkDrOt.BkdrotCreditAccount THEN
                    FT.Contract.DynCreditAcctNoCheck()
                END

                R.ACCT.REC = ''
                ERR = ''
                ACCNO = EB.SystemTables.getComi()
                R.ACCT.REC = AC.AccountOpening.Account.Read(ACCNO, AC.ERR)
                IF NOT(AC.ERR) THEN
                    ACCT.CCY = R.ACCT.REC<AC.AccountOpening.Account.Currency>
                    IF SAVE.AF = FT.BulkProcessing.BulkDrOt.BkdrotDebitAccount THEN
                        BUL.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDebitCurrency)
                    END
                    IF SAVE.AF = FT.BulkProcessing.BulkDrOt.BkdrotCreditAccount THEN
                        BUL.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCreditCurrency)
                    END
                    IF BUL.CCY NE ACCT.CCY THEN
                        IF SAVE.AF = FT.BulkProcessing.BulkDrOt.BkdrotDebitAccount THEN
                            EB.SystemTables.setAf(SAVE.AF)
                            EB.SystemTables.setE("FT-INVALID.CCY.FOR.DB.ACC")
                            RETURN
                        END
                        IF SAVE.AF = FT.BulkProcessing.BulkDrOt.BkdrotCreditAccount THEN
                            EB.SystemTables.setAf(SAVE.AF)
                            EB.SystemTables.setE("FT-INVALID.ACCT.FOR.CR.CCY")
                            RETURN
                        END
                    END
                END

            END


*------------------
* Ordering customer
*------------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDrOt.BkdrotOrderingCu
            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'SW' ; T1<2,2> = 'CUS'
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotOrderingCu)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    RETURN
                END

* If SWIFT address is entered then check for BIC code validation

                IF EB.SystemTables.getComi()[1,3] = 'SW-' AND EB.SystemTables.getAs() = 1 THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotOrderingCu)
                        RETURN
                    END
                END

                GOSUB CHECK.ACCOUNTS
                IF OT.ACCT.CHECK=1 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotOrderingCu)
                    EB.SystemTables.setText("FT-INVALID.FOR.N.N.TRANSFER")
                    EB.SystemTables.setE(EB.SystemTables.getText())
                    RETURN
                END

                IF LEN(EB.SystemTables.getComi()) < 11 AND EB.SystemTables.getAs() = 1 THEN
                    IF NUM(EB.SystemTables.getComi()) THEN
                        customerKey = EB.SystemTables.getComi()
                        customerNameAddress = ''
                        prefLang = EB.SystemTables.getLngg()
                        CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
                        IF EB.SystemTables.getEtext() THEN
                            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotOrderingCu)
                            EB.SystemTables.setE(EB.SystemTables.getText())
                            RETURN
                        END ELSE
                            EB.SystemTables.setComiEnri(customerNameAddress<NameAddress.shortName>)
                        END
                    END
                END

                IF EB.SystemTables.getAs() > 4 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotOrderingCu)
                    EB.SystemTables.setE("FT-O.MAX.LINES.EXCEEDED")
                    RETURN
                END

            END


*--------------
* Ordering Bank
*--------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDrOt.BkdrotOrderingBk
            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'S' ; T1<2,2> = 'BIC'
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotOrderingBk)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    RETURN
                END

* If SWIFT address is entered then check for BIC code validation

                IF EB.SystemTables.getComi()[1,3] = 'SW-' AND EB.SystemTables.getAs() = 1 THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotOrderingBk)
                        RETURN
                    END
                END

                GOSUB CHECK.ACCOUNTS
                IF OT.ACCT.CHECK=1 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotOrderingBk)
                    EB.SystemTables.setE("FT-INVALID.FOR.N.N.TRANSFER")
                    RETURN
                END

                BEGIN CASE
                    CASE EB.SystemTables.getAs() > 4
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotOrderingBk)
                        EB.SystemTables.setE("FT-O.MAX.LINES.EXCEEDED")
                        RETURN
                    CASE EB.SystemTables.getAs() = 1
                        IF LEN(EB.SystemTables.getComi()) < 15 THEN

                            FT.Contract.EnrichCusOrBic( EB.SystemTables.getComi(), EB.SystemTables.getComiEnri())
                            IF NOT(NUM(EB.SystemTables.getComi())) THEN EB.SystemTables.setEtext('')

                            IF EB.SystemTables.getEtext() THEN
                                EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotOrderingBk)
                                EB.SystemTables.setE(EB.SystemTables.getEtext())
                                RETURN
                            END
                            GOSUB IS.THIS.A.BANK
                            IF NOT.A.BANK THEN RETURN
                        END
                END CASE
            END

*-----------------------
* Rate field validations
*-----------------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDrOt.BkdrotTreasuryRate
            IF EB.SystemTables.getComi() NE '' THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCustomerRate) THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotTreasuryRate)
                    EB.SystemTables.setE("FT-T.RATE.NOT.ALLOW.IF.C.RATE.PRES")
                    RETURN
                END
            END

        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDrOt.BkdrotCustomerRate
            IF EB.SystemTables.getComi() NE '' THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotTreasuryRate) OR EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCustomerSpread) THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCustomerRate)
                    EB.SystemTables.setE("FT-C.RATE.NOT.ALLOW.IF.T.RATE.PRES")
                    RETURN
                END
            END

        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDrOt.BkdrotCustomerSpread
            IF EB.SystemTables.getComi() NE '' THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCustomerRate) THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotCustomerSpread)
                    EB.SystemTables.setE("FT-C.SPR.NOT.ALLOW.IF.C.RATE.PRES")
                    RETURN
                END
            END

*------------------
* Intermediary Bank
*------------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk

            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'SW' ; T1<2,2> = 'BIC'
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    RETURN
                END

* If SWIFT address is entered then check for BIC code validation

                IF EB.SystemTables.getComi()[1,3] = 'SW-' AND EB.SystemTables.getAv() = 1 THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk)
                        RETURN
                    END
                END

                IF LEN(EB.SystemTables.getComi()) < 15 AND EB.SystemTables.getAv() = 1 THEN
                    FT.Contract.EnrichCusOrBic( EB.SystemTables.getComi(), EB.SystemTables.getComiEnri())
                    IF NOT(NUM(EB.SystemTables.getComi())) THEN EB.SystemTables.setEtext('')
                    IF EB.SystemTables.getEtext() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk)
                        EB.SystemTables.setE(EB.SystemTables.getEtext())
                        RETURN
                    END

                    IF NUM(EB.SystemTables.getComi()) THEN
                        REC.CORR = EB.SystemTables.getComi()
                        R.REC.CORR = ST.Config.Agency.Read(REC.CORR, ERR2)
                        IF ERR2 NE "" THEN
                            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk)
                            EB.SystemTables.setE(ERR2)
                            RETURN
                        END
                    END
                END
                IF EB.SystemTables.getAv() > 4 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk)
                    EB.SystemTables.setText("FT-O.MAX.LINES.EXCEEDED")
                    EB.SystemTables.setE(EB.SystemTables.getText())
                    RETURN
                END

            END


*--------------
* Receiver Bank
*--------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk
            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'S' ; T1<2,2> = ''
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    RETURN
                END ELSE
                    customerKey = EB.SystemTables.getComi()
                    customerNameAddress = ''
                    prefLang = EB.SystemTables.getLngg()
                    CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
                    EB.SystemTables.setComiEnri(customerNameAddress<NameAddress.shortName>)
                END

* If SWIFT address is entered then check for BIC code validation

                IF EB.SystemTables.getComi()[1,3] = 'SW-' THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk)
                        RETURN
                    END
                END

                GOSUB CHECK.ACCOUNTS
                IF OT.ACCT.CHECK=1 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk)
                    EB.SystemTables.setE("FT-INVALID.FOR.N.N.TRANSFER")
                    RETURN
                END
            END


*--------------
* Rec Corr bank
*--------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk

            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'SW' ; T1<2,2> = 'BIC'
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    RETURN
                END

* If SWIFT address is entered then check for BIC code validation

                IF EB.SystemTables.getComi()[1,3] = 'SW-' AND EB.SystemTables.getAv() = 1 THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk)
                        RETURN
                    END
                END

                IF LEN(EB.SystemTables.getComi()) < 15 AND EB.SystemTables.getAv() = 1 THEN
                    FT.Contract.EnrichCusOrBic( EB.SystemTables.getComi(), EB.SystemTables.getComiEnri())
                    IF NOT(NUM(EB.SystemTables.getComi())) THEN EB.SystemTables.setEtext('')
                    IF EB.SystemTables.getEtext() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk)
                        EB.SystemTables.setE(EB.SystemTables.getEtext())
                        RETURN
                    END

**** IF NUM(COMI) OR COMI[1,3] EQ 'SW-' THEN may not be agent
                    IF NUM(EB.SystemTables.getComi()) THEN
                        REC.CORR = EB.SystemTables.getComi()
                        R.REC.CORR = ST.Config.Agency.Read(REC.CORR, ERR1)
                        IF ERR1 NE "" THEN
                            EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk)
                            EB.SystemTables.setE(ERR1)
                            RETURN
                        END
                    END
                END
                IF EB.SystemTables.getAv() > 4 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk)
                    EB.SystemTables.setText("FT-O.MAX.LINES.EXCEEDED")
                    EB.SystemTables.setE(EB.SystemTables.getText())
                    RETURN
                END

            END


*------------------
* Account with Bank
*------------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk

            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'SW' ; T1<2,2> = 'BIC'
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    RETURN
                END

* If SWIFT address is entered then check for BIC code validation

                IF EB.SystemTables.getComi()[1,3] = 'SW-' AND EB.SystemTables.getAv() = 1 THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk)
                        RETURN
                    END
                END

* Check if both Accts are NOSTRO, if so then dont allow.

                GOSUB CHECK.ACCOUNTS

                IF OT.ACCT.CHECK=1 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk)
                    EB.SystemTables.setE("FT-INVALID.FOR.N.N.TRANSFER")
                    RETURN
                END

                BEGIN CASE
                    CASE EB.SystemTables.getAv() > 4
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk)
                        EB.SystemTables.setE("FT-O.MAX.LINES.EXCEEDED")
                        RETURN
                    CASE EB.SystemTables.getAv() = 1
                        IF LEN(EB.SystemTables.getComi()) < 15 THEN
                            FT.Contract.EnrichCusOrBic( EB.SystemTables.getComi(), EB.SystemTables.getComiEnri())
                            IF NOT(NUM(EB.SystemTables.getComi())) THEN EB.SystemTables.setEtext('')
                            IF EB.SystemTables.getEtext() THEN
                                EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk)
                                EB.SystemTables.setE(EB.SystemTables.getEtext())
                                RETURN
                            END
                        END

                END CASE
            END


*---------------
* Ben Account No
*---------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDrOt.BkdrotBenAcctNo
            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '34..C'
                T1 = 'S'
                EB.Template.In2s(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenAcctNo)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    RETURN
                END

                GOSUB CHECK.ACCOUNTS

                IF OT.ACCT.CHECK=1 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenAcctNo)
                    EB.SystemTables.setE("FT-INVALID.FOR.N.N.TRANSFER")
                    RETURN
                END
            END

*-------------
* Ben Customer
*-------------

        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDrOt.BkdrotBenCustomer

            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'SW' ; T1<2,2> = 'BIC'
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenCustomer)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    RETURN
                END

                IF MESSAGE.TYPE = '400' THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenCustomer)
                    EB.SystemTables.setE('FT-NOT.VALID.WITH.400')
                    RETURN
                END

* If SWIFT address is entered then check for BIC code validation

                IF EB.SystemTables.getComi()[1,3] = 'SW-' AND EB.SystemTables.getAv() = 1 THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenCustomer)
                        RETURN
                    END
                END

                IF LEN(EB.SystemTables.getComi()) < 15 AND EB.SystemTables.getAv() = 1 THEN
                    FT.Contract.EnrichCusOrBic( EB.SystemTables.getComi(), EB.SystemTables.getComiEnri())
                    IF NOT(NUM(EB.SystemTables.getComi())) THEN EB.SystemTables.setEtext('')
                    IF EB.SystemTables.getEtext() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenCustomer)
                        EB.SystemTables.setE(EB.SystemTables.getEtext())
                        RETURN
                    END
                END

                GOSUB DEFAULT.BANK.FIELDS

            END

*-----------------
* Benificiary Bank
*-----------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDrOt.BkdrotBenBank
            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'SW' ; T1<2,2> = 'BIC'
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenBank)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    RETURN
                END

* If SWIFT address is entered then check for BIC code validation

                IF EB.SystemTables.getComi()[1,3] = 'SW-' AND EB.SystemTables.getAv() = 1 THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenBank)
                        RETURN
                    END
                END

                GOSUB CHECK.ACCOUNTS
                IF OT.ACCT.CHECK=1 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenBank)
                    EB.SystemTables.setE("FT-INVALID.FOR.N.N.TRANSFER")
                    RETURN
                END

                BEGIN CASE
                    CASE EB.SystemTables.getAv() > 4
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenBank)
                        EB.SystemTables.setE("FT-O.MAX.LINES.EXCEEDED")
                        RETURN
                    CASE EB.SystemTables.getAv() = 1
                        IF LEN(EB.SystemTables.getComi()) < 15 THEN
                            FT.Contract.EnrichCusOrBic( EB.SystemTables.getComi(), EB.SystemTables.getComiEnri())
                            IF NOT(NUM(EB.SystemTables.getComi())) THEN EB.SystemTables.setEtext('')
                            IF EB.SystemTables.getEtext() THEN
                                EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenBank)
                                EB.SystemTables.setE(EB.SystemTables.getEtext())
                                RETURN
                            END
                            GOSUB IS.THIS.A.BANK
                            IF NOT.A.BANK THEN
                                EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotBenBank)
                                EB.SystemTables.setE("FT-NOT.A.BANK")
                                RETURN
                            END
                        END

                END CASE

                GOSUB DEFAULT.BANK.FIELDS

            END


*-------------
* RATE FIXING
*-------------

        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDrOt.BkdrotRateFixing
            IF EB.SystemTables.getComi() THEN
                IF NOT(R.APPLICATION.DEFAULT.LOC(FT.Config.ApplDefault.FtOneRateFixing)) AND EB.SystemTables.getComi() = 'YES' THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkDrOt.BkdrotRateFixing)
                    EB.SystemTables.setE('FT-RATE.FIX.NOT.ALLOWED')
                    RETURN
                END
            END ELSE
                EB.SystemTables.setComi(R.APPLICATION.DEFAULT.LOC(FT.Config.ApplDefault.FtOneRateFixing))
            END


    END CASE
*
CHECK.FIELD.END:
*
RETURN
*
************************************************************************
*
*-----------------
* LOCAL ROUTINES
*-----------------

CHECK.ACCOUNTS:
    OT.ACCT.CHECK=0
    R.DEB.ACCT.REC=""
    READ.ERROR=""
    DR.ACCT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotDebitAccount)
    R.DEB.ACCT.REC = AC.AccountOpening.Account.Read(DR.ACCT, READ.ERROR)
    IF READ.ERROR NE "" THEN
        RETURN
    END
    R.CRED.ACCT.REC=""
    READ.ERROR=""
    CR.ACCT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCreditAccount)
    R.CRED.ACCT.REC = AC.AccountOpening.Account.Read(CR.ACCT, READ.ERROR)
    IF READ.ERROR NE "" THEN
        RETURN
    END
    IF R.DEB.ACCT.REC<AC.AccountOpening.Account.LimitRef> = "NOSTRO" AND R.CRED.ACCT.REC<AC.AccountOpening.Account.LimitRef> = "NOSTRO" THEN
        IF R.DEB.ACCT.REC<AC.AccountOpening.Account.Currency> = R.CRED.ACCT.REC<AC.AccountOpening.Account.Currency> THEN
            IF R.DEB.ACCT.REC<AC.AccountOpening.Account.Customer> NE R.CRED.ACCT.REC<AC.AccountOpening.Account.Customer> THEN
                NOSTRO.XFR.TYPE = R.TXN.TYPE.RECORD<FT.Config.TxnTypeCondition.FtSixNostroXferType>
                IF NOSTRO.XFR.TYPE NE '202' THEN
                    OT.ACCT.CHECK=1
                END
            END
        END
    END
RETURN

*-------------------
DEFAULT.BANK.FIELDS:
*-------------------

    IN.CUST = EB.SystemTables.getComi()
    IN.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCreditCurrency)

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk):EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBenAcctNo):EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk) THEN RETURN

* Check if credit customer and Ben Customer are same. If so defaulting
* of other bank fields may not be required.

    CR.ACCT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotCreditAccount)
    R.CRED.REC = AC.AccountOpening.Account.Read(CR.ACCT, READ.ERROR)
    CREDIT.CUSTOMER = R.CRED.REC<AC.AccountOpening.Account.Customer>

    IF IN.CCY AND NOT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk):EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBenAcctNo):EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk)) THEN
        IF IN.CUST NE CREDIT.CUSTOMER THEN

            IN.APP = "FT" ; CB.CUST = "" ; CB.ACCT = "" ; IB.CUST = ""
            ST.Config.GetAgent(IN.CUST, IN.CCY, IN.APP, "", "", "", "", "", "", "", "", CB.CUST, CB.ACCT, "", "", IB.CUST, "", "")

            IF CB.CUST MATCHES "1N0N" OR CB.CUST[1,3] EQ 'SW-' THEN
                IF NOT(CB.CUST MATCHES EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotRecCorrBk):@VM:EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBenBank)) THEN
                    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBenBank) NE EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk) OR EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBenBank) = "" THEN
                        IF CB.CUST <> EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotReceiverBk) AND CB.CUST <> EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk) AND CB.CUST <> R.CRED.REC<AC.AccountOpening.Account.Customer> THEN
                            EB.SystemTables.setRNew(FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk, CB.CUST)
                            FT.Contract.EnrichFieldCusOrBic (FT.BulkProcessing.BulkDrOt.BkdrotAcctWithBk, 1)

                            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotBenAcctNo) = "" THEN
                                EB.SystemTables.setRNew(FT.BulkProcessing.BulkDrOt.BkdrotBenAcctNo, CB.ACCT)
                            END
                            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk) = "" THEN
                                EB.SystemTables.setRNew(FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk, IB.CUST)
                                FT.Contract.EnrichFieldCusOrBic (FT.BulkProcessing.BulkDrOt.BkdrotIntermedBk, 1)
                            END

                        END
                    END
                END
            END
        END
    END

RETURN

*--------------
IS.THIS.A.BANK:
*--------------

    IF NUM(EB.SystemTables.getComi()) AND LEN(EB.SystemTables.getComi()) < 11 THEN
        PRETURN.CODE = ""
        AC.Config.CheckAccountClass ( "BANK", "", EB.SystemTables.getComi(), "", PRETURN.CODE)

        IF PRETURN.CODE = "YES" THEN
            NOT.A.BANK = 0
        END ELSE
            NOT.A.BANK = 1
            EB.SystemTables.setE("FT-INP.BANK.,.PLEASE.RETYPE")
        END
    END ELSE
        NOT.A.BANK = 0        ;* Treat as a BANK
    END

RETURN

*-------------------
CHECK.SWIFT.ADDRESS:
*-------------------
    SAVE.COMI = EB.SystemTables.getComi()
    EB.SystemTables.setComi(EB.SystemTables.getComi()[4,99])
    DE.API.ValidateSwiftAddress("1","1")
    IF EB.SystemTables.getEtext() THEN EB.SystemTables.setE(EB.SystemTables.getEtext())
    EB.SystemTables.setComi(SAVE.COMI)
RETURN


************************************************************************
END
