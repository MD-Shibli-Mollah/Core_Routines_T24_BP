* @ValidationCode : MjoxODU0MDM0ODA6Q3AxMjUyOjE2MDgyMDA1MDI3MjE6c2NoYW5kaW5pOi0xOi0xOjA6MTp0cnVlOk4vQTpERVZfMjAyMDEyLjE6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Dec 2020 15:51:42
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
* <Rating>7024</Rating>
*-----------------------------------------------------------------------------
$PACKAGE FT.BulkProcessing
SUBROUTINE FT.BK.CREDIT.OT.CHECK.FIELDS
************************************************************************
* Routine for Dynamic template Online validation
************************************************************************
* 29/06/04 - EN_10002298
*            New Version
*
* 12/07/04 - BG_100006940
*            BUG FIX
*
* 01/08/05 - CI_10032367
*            CROSS COMPILATION
*
* 20/07/10 - Task 66080
*            Change the reads to Customer to use the Customer
*            Service api calls
*
* 19/01/11 - Task 131643
*            Parameter file FT.APPL.DEFAULT should be read using EB.READ.PARAMETER. Removed opening of file
*            FT.APPL.DEFAULT since EB.READ.PARAMETER will the open the file if file is passed as null.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
* 22/09/15 - Enhancement 1390617 / Task 1393200
*            Moved the application BENEFICIARY from FT to ST. Hence call to BENEFICIARY
*            referred using component ST.Payments
*
* 08/12/2020 - Enhancement 4020994 / Task 4035326
*              Changing BY.Payments reference to new component reference BY.Payments since
*              beneficiary and beneficiary links table has been moved to new module BY.
***********************************************************************************************************
	$USING EB.SystemTables
	$USING EB.Display
	$USING EB.Template
	$USING AC.AccountOpening
	$USING AC.Config
	$USING FT.Config
	$USING FT.Contract
	$USING BY.Payments
	$USING ST.Config
	$USING ST.CompanyCreation
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
*
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
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkCrOt.BkcrotTransactionType

            IF EB.SystemTables.getComi() = '' THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotTransactionType)
                EB.SystemTables.setE("FT-INP.MISS")
                RETURN
            END

            IF EB.SystemTables.getComi() NE '' AND EB.SystemTables.getComi()[1,2] NE 'OT' THEN
                EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotTransactionType)
                EB.SystemTables.setE("FT-ONLY.OT.TYPE.TXN.ALLOWED")
                RETURN
            END

            IF EB.SystemTables.getComi() THEN
                IF MESSAGE.TYPE = '' THEN
                    R.TXN.TYPE.RECORD = '' ; READ.ERR = '' ; TRANS.TYPE = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotTransactionType)
                    R.TXN.TYPE.RECORD = FT.Config.TxnTypeCondition.Read(TRANS.TYPE, READ.ERR)
                    IF READ.ERR = '' THEN
                        MESSAGE.TYPE = R.TXN.TYPE.RECORD<FT.Config.TxnTypeCondition.FtSixMessageType>
                    END
                END
            END


*-----------------------------
* Debit a/c no & credit a/c no
*-----------------------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkCrOt.BkcrotDebitAccount OR EB.SystemTables.getAf() = FT.BulkProcessing.BulkCrOt.BkcrotCreditAccount
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
                    R.ACCOUNT.RECORD.LOC = ''

                    R.ACCOUNT.RECORD.LOC = AC.AccountOpening.Account.Read(EB.SystemTables.getComi(), READ.ERROR)
                    IF READ.ERROR NE '' THEN
                        EB.SystemTables.setAf(SAVE.AF)
                        EB.SystemTables.setE("FT-NO.ACCT.RECORD")
                        RETURN
                    END

                    EB.SystemTables.setComiEnri(R.ACCOUNT.RECORD.LOC<AC.AccountOpening.Account.ShortTitle>)

                END ELSE

                    EB.SystemTables.setAf(SAVE.AF)
                    EB.SystemTables.setE('FT-PL.NOT.ALLOWED')
                    RETURN

                END

* Check Credit a/c no for Nostro/Vostro

                IF EB.SystemTables.getAf() = FT.BulkProcessing.BulkCrOt.BkcrotCreditAccount THEN
                    FT.Contract.DynCreditAcctNoCheck()

                    R.ACCT.REC = ''
                    ERR = ''
                    CREDIT.ACCNO = EB.SystemTables.getComi()
                    R.ACCT.REC = AC.AccountOpening.Account.Read(CREDIT.ACCNO, AC.ERR)
                    IF NOT(AC.ERR) THEN
                        ACCT.CCY = R.ACCT.REC<AC.AccountOpening.Account.Currency>
                        BUL.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCreditCurrency)
                        IF BUL.CCY NE ACCT.CCY THEN
                            EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotCreditAccount)
                            EB.SystemTables.setE("FT-INVALID.ACCT.FOR.CR.CCY")
                            RETURN
                        END
                    END
                END

            END

*-----------------------
* Rate field validations
*-----------------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkCrOt.BkcrotTreasuryRate
            IF EB.SystemTables.getComi() NE '' THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCustomerRate) THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotTreasuryRate)
                    EB.SystemTables.setE("FT-T.RATE.NOT.ALLOW.IF.C.RATE.PRES")
                    RETURN
                END
            END

        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkCrOt.BkcrotCustomerRate
            IF EB.SystemTables.getComi() NE '' THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotTreasuryRate) OR EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCustomerSpread) THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotCustomerRate)
                    EB.SystemTables.setE("FT-C.RATE.NOT.ALLOW.IF.T.RATE.PRES")
                    RETURN
                END
            END

        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkCrOt.BkcrotCustomerSpread
            IF EB.SystemTables.getComi() NE '' THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCustomerRate) THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotCustomerSpread)
                    EB.SystemTables.setE("FT-C.SPR.NOT.ALLOW.IF.C.RATE.PRES")
                    RETURN
                END
            END

*------------------
* Intermediary Bank
*------------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk

            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'SW' ; T1<2,2> = 'BIC'
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    RETURN
                END

* If SWIFT address is entered then check for BIC code validation

                IF EB.SystemTables.getComi()[1,3] = 'SW-' AND EB.SystemTables.getAs() = 1 THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk)
                        RETURN
                    END
                END

                IF LEN(EB.SystemTables.getComi()) < 15 AND EB.SystemTables.getAs() = 1 THEN
                    FT.Contract.EnrichCusOrBic( EB.SystemTables.getComi(), EB.SystemTables.getComiEnri())
                    IF NOT(NUM(EB.SystemTables.getComi())) THEN EB.SystemTables.setEtext('')
                    IF EB.SystemTables.getEtext() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk)
                        EB.SystemTables.setE(EB.SystemTables.getEtext())
                        RETURN
                    END

                    IF NUM(EB.SystemTables.getComi()) THEN
                        REC.CORR = EB.SystemTables.getComi()
                        R.REC.CORR = ST.Config.Agency.Read(REC.CORR, ERR2)
                        IF ERR2 NE "" THEN
                            EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk)
                            EB.SystemTables.setE(ERR2)
                            RETURN
                        END
                    END
                END
                IF EB.SystemTables.getAs() > 4 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk)
                    EB.SystemTables.setText("FT-O.MAX.LINES.EXCEEDED")
                    EB.SystemTables.setE(EB.SystemTables.getText())
                    RETURN
                END

            END


*--------------
* Receiver Bank
*--------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkCrOt.BkcrotReceiverBk
            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'S' ; T1<2,2> = ''
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotReceiverBk)
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

                IF EB.SystemTables.getComi()[1,3] = 'SW-' AND EB.SystemTables.getAv() = 1 THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotReceiverBk)
                        RETURN
                    END
                END

                GOSUB CHECK.ACCOUNTS
                IF OT.ACCT.CHECK=1 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotReceiverBk)
                    EB.SystemTables.setE("FT-INVALID.FOR.N.N.TRANSFER")
                    RETURN
                END
            END


*--------------
* Rec Corr bank
*--------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkCrOt.BkcrotRecCorrBk

            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'SW' ; T1<2,2> = 'BIC'
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotRecCorrBk)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    RETURN
                END

* If SWIFT address is entered then check for BIC code validation

                IF EB.SystemTables.getComi()[1,3] = 'SW-' AND EB.SystemTables.getAs() = 1 THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotRecCorrBk)
                        RETURN
                    END
                END

                IF LEN(EB.SystemTables.getComi()) < 15 AND EB.SystemTables.getAs() = 1 THEN
                    FT.Contract.EnrichCusOrBic( EB.SystemTables.getComi(), EB.SystemTables.getComiEnri())
                    IF NOT(NUM(EB.SystemTables.getComi())) THEN EB.SystemTables.setEtext('')
                    IF EB.SystemTables.getEtext() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotRecCorrBk)
                        EB.SystemTables.setE(EB.SystemTables.getEtext())
                        RETURN
                    END

**** IF NUM(COMI) OR COMI[1,3] EQ 'SW-' THEN may not be agent
                    IF NUM(EB.SystemTables.getComi()) THEN
                        REC.CORR = EB.SystemTables.getComi()
                        R.REC.CORR = ST.Config.Agency.Read(REC.CORR, ERR1)
                        IF ERR1 NE "" THEN
                            EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotRecCorrBk)
                            EB.SystemTables.setE(ERR1)
                            RETURN
                        END
                    END
                END
                IF EB.SystemTables.getAs() > 4 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotRecCorrBk)
                    EB.SystemTables.setText("FT-O.MAX.LINES.EXCEEDED")
                    EB.SystemTables.setE(EB.SystemTables.getText())
                    RETURN
                END

            END


*------------------
* Account with Bank
*------------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk

            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'SW' ; T1<2,2> = 'BIC'
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    RETURN
                END

* If SWIFT address is entered then check for BIC code validation

                IF EB.SystemTables.getComi()[1,3] = 'SW-' AND EB.SystemTables.getAs() = 1 THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk)
                        RETURN
                    END
                END

* Check if both Accts are NOSTRO, if so then dont allow.

                GOSUB CHECK.ACCOUNTS

                IF OT.ACCT.CHECK=1 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk)
                    EB.SystemTables.setText("FT-INVALID.FOR.N.N.TRANSFER")
                    EB.SystemTables.setE(EB.SystemTables.getText())
                    RETURN
                END

                BEGIN CASE
                    CASE EB.SystemTables.getAs() > 4
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk)
                        EB.SystemTables.setE("FT-O.MAX.LINES.EXCEEDED")
                        RETURN
                    CASE EB.SystemTables.getAs() = 1
                        IF LEN(EB.SystemTables.getComi()) < 15 THEN
                            FT.Contract.EnrichCusOrBic( EB.SystemTables.getComi(), EB.SystemTables.getComiEnri())
                            IF NOT(NUM(EB.SystemTables.getComi())) THEN EB.SystemTables.setEtext('')
                            IF EB.SystemTables.getEtext() THEN
                                EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk)
                                EB.SystemTables.setE(EB.SystemTables.getEtext())
                                RETURN
                            END
                        END

                END CASE
            END


*---------------
* Ben Account No
*---------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkCrOt.BkcrotBenAcctNo
            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '34..C'
                T1 = 'S'
                EB.Template.In2s(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenAcctNo)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    RETURN
                END

                GOSUB CHECK.ACCOUNTS

                IF OT.ACCT.CHECK=1 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenAcctNo)
                    EB.SystemTables.setText("FT-INVALID.FOR.N.N.TRANSFER")
                    EB.SystemTables.setE(EB.SystemTables.getText())
                    RETURN
                END
            END

*-------------
* Ben Customer
*-------------

        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkCrOt.BkcrotBenCustomer

            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'SW' ; T1<2,2> = 'BIC'
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenCustomer)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    RETURN
                END

                IF MESSAGE.TYPE = '400' THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenCustomer)
                    EB.SystemTables.setText('FT-NOT.VALID.WITH.400')
                    EB.SystemTables.setE(EB.SystemTables.getText())
                    RETURN
                END

* If SWIFT address is entered then check for BIC code validation

                IF EB.SystemTables.getComi()[1,3] = 'SW-' AND EB.SystemTables.getAv() = 1 THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenCustomer)
                        RETURN
                    END
                END

                IF LEN(EB.SystemTables.getComi()) < 15 AND EB.SystemTables.getAv() = 1 THEN
                    FT.Contract.EnrichCusOrBic( EB.SystemTables.getComi(), EB.SystemTables.getComiEnri())
                    IF NOT(NUM(EB.SystemTables.getComi())) THEN EB.SystemTables.setEtext('')
                    IF EB.SystemTables.getEtext() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenCustomer)
                        EB.SystemTables.setE(EB.SystemTables.getEtext())
                        RETURN
                    END
                END

                GOSUB DEFAULT.BANK.FIELDS

            END

*-----------------
* Benificiary Bank
*-----------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkCrOt.BkcrotBenBank
            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'SW' ; T1<2,2> = 'BIC'
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenBank)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    RETURN
                END

* If SWIFT address is entered then check for BIC code validation

                IF EB.SystemTables.getComi()[1,3] = 'SW-' AND EB.SystemTables.getAs() = 1 THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenBank)
                        RETURN
                    END
                END

                GOSUB CHECK.ACCOUNTS
                IF OT.ACCT.CHECK=1 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenBank)
                    EB.SystemTables.setText("FT-INVALID.FOR.N.N.TRANSFER")
                    EB.SystemTables.setE(EB.SystemTables.getText())
                    RETURN
                END

                BEGIN CASE
                    CASE EB.SystemTables.getAs() > 4
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenBank)
                        EB.SystemTables.setText("FT-O.MAX.LINES.EXCEEDED")
                        EB.SystemTables.setE(EB.SystemTables.getText())
                        RETURN
                    CASE EB.SystemTables.getAs() = 1
                        IF LEN(EB.SystemTables.getComi()) < 15 THEN
                            FT.Contract.EnrichCusOrBic( EB.SystemTables.getComi(), EB.SystemTables.getComiEnri())
                            IF NOT(NUM(EB.SystemTables.getComi())) THEN EB.SystemTables.setEtext('')
                            IF EB.SystemTables.getEtext() THEN
                                EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenBank)
                                EB.SystemTables.setE(EB.SystemTables.getEtext())
                                RETURN
                            END
                            GOSUB IS.THIS.A.BANK
                            IF NOT.A.BANK THEN
                                EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotBenBank)
                                EB.SystemTables.setE("FT-NOT.A.BANK")
                                RETURN
                            END
                        END

                END CASE

                GOSUB DEFAULT.BANK.FIELDS

            END


*------------------
* Ordering customer
*------------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkCrOt.BkcrotOrderingCust
            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'SW' ; T1<2,2> = 'CUS'
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotOrderingCust)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    RETURN
                END

* If SWIFT address is entered then check for BIC code validation

                IF EB.SystemTables.getComi()[1,3] = 'SW-' AND EB.SystemTables.getAv() = 1 THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotOrderingCust)
                        RETURN
                    END
                END

                GOSUB CHECK.ACCOUNTS
                IF OT.ACCT.CHECK=1 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotOrderingCust)
                    EB.SystemTables.setText("FT-INVALID.FOR.N.N.TRANSFER")
                    EB.SystemTables.setE(EB.SystemTables.getText())
                    RETURN
                END

                IF LEN(EB.SystemTables.getComi()) < 11 AND EB.SystemTables.getAv() = 1 THEN
                    IF NUM(EB.SystemTables.getComi()) THEN
                        customerKey = EB.SystemTables.getComi()
                        customerNameAddress = ''
                        prefLang = EB.SystemTables.getLngg()
                        CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
                        IF EB.SystemTables.getEtext() THEN
                            EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotOrderingCust)
                            EB.SystemTables.setE(EB.SystemTables.getEtext())
                            RETURN
                        END ELSE
                            EB.SystemTables.setComiEnri(customerNameAddress<NameAddress.shortName>)
                        END
                    END
                END

                IF EB.SystemTables.getAv() > 4 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotOrderingCust)
                    EB.SystemTables.setText("FT-O.MAX.LINES.EXCEEDED")
                    EB.SystemTables.setE(EB.SystemTables.getText())
                    RETURN
                END

            END

*--------------
* Ordering Bank
*--------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkCrOt.BkcrotOrderingBank
            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'S' ; T1<2,2> = 'BIC'
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotOrderingBank)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    RETURN
                END

* If SWIFT address is entered then check for BIC code validation

                IF EB.SystemTables.getComi()[1,3] = 'SW-' AND EB.SystemTables.getAv() = 1 THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotOrderingBank)
                        RETURN
                    END
                END

                GOSUB CHECK.ACCOUNTS
                IF OT.ACCT.CHECK=1 THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotOrderingBank)
                    EB.SystemTables.setE("FT-INVALID.FOR.N.N.TRANSFER")
                    RETURN
                END

                BEGIN CASE
                    CASE EB.SystemTables.getAv() > 4
                        EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotOrderingBank)
                        EB.SystemTables.setE("FT-O.MAX.LINES.EXCEEDED")
                        RETURN
                    CASE EB.SystemTables.getAs() = 1
                        IF LEN(EB.SystemTables.getComi()) < 15 THEN

                            FT.Contract.EnrichCusOrBic( EB.SystemTables.getComi(), EB.SystemTables.getComiEnri())
                            IF NOT(NUM(EB.SystemTables.getComi())) THEN EB.SystemTables.setEtext('')

                            IF EB.SystemTables.getEtext() THEN
                                EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotOrderingBank)
                                EB.SystemTables.setE(EB.SystemTables.getEtext())
                                RETURN
                            END
                            GOSUB IS.THIS.A.BANK
                            IF NOT.A.BANK THEN RETURN
                        END
                END CASE
            END         ;* BG_100006940 S/E


*-------------
* RATE FIXING
*-------------

        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkCrOt.BkcrotRateFixing
            IF EB.SystemTables.getComi() THEN
                IF NOT(R.APPLICATION.DEFAULT.LOC(FT.Config.ApplDefault.FtOneRateFixing)) AND EB.SystemTables.getComi() = 'YES' THEN
                    EB.SystemTables.setAf(FT.BulkProcessing.BulkCrOt.BkcrotRateFixing)
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
    DR.ACCT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotDebitAccount)
    R.DEB.ACCT.REC = AC.AccountOpening.Account.Read(DR.ACCT, READ.ERROR)
    IF READ.ERROR NE "" THEN
        RETURN
    END
    R.CRED.ACCT.REC=""
    READ.ERROR=""
    CR.ACCT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCreditAccount)
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
    IN.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCreditCurrency)

    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk):EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBenAcctNo):EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk) THEN RETURN

* Check if credit customer and Ben Customer are same. If so defaulting
* of other bank fields may not be required.

    CR.ACCT = EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotCreditAccount)
    R.CRED.REC = AC.AccountOpening.Account.Read(CR.ACCT, READ.ERROR)
    CREDIT.CUSTOMER = R.CRED.REC<AC.AccountOpening.Account.Customer>

    IF IN.CCY AND NOT(EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk):EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBenAcctNo):EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk)) THEN
        IF IN.CUST NE CREDIT.CUSTOMER THEN

            IN.APP = "FT" ; CB.CUST = "" ; CB.ACCT = "" ; IB.CUST = ""
            ST.Config.GetAgent(IN.CUST, IN.CCY, IN.APP, "", "", "", "", "", "", "", "", CB.CUST, CB.ACCT, "", "", IB.CUST, "", "")

            IF CB.CUST MATCHES "1N0N" OR CB.CUST[1,3] EQ 'SW-' THEN
                IF NOT(CB.CUST MATCHES EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotRecCorrBk):@VM:EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBenBank)) THEN
                    IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBenBank) NE EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotReceiverBk) OR EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBenBank) = "" THEN
                        IF CB.CUST <> EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotReceiverBk) AND CB.CUST <> EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk) AND CB.CUST <> R.CRED.REC<AC.AccountOpening.Account.Customer> THEN
                            EB.SystemTables.setRNew(FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk, CB.CUST)
                            FT.Contract.EnrichFieldCusOrBic (FT.BulkProcessing.BulkCrOt.BkcrotAcctWithBk, 1)

                            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotBenAcctNo) = "" THEN
                                EB.SystemTables.setRNew(FT.BulkProcessing.BulkCrOt.BkcrotBenAcctNo, CB.ACCT)
                            END
                            IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk) = "" THEN
                                EB.SystemTables.setRNew(FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk, IB.CUST)
                                FT.Contract.EnrichFieldCusOrBic (FT.BulkProcessing.BulkCrOt.BkcrotIntermedBk, 1)
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
