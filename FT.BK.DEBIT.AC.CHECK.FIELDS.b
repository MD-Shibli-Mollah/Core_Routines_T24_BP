* @ValidationCode : Mjo0OTAzOTE0OTk6Q3AxMjUyOjE2MDgyMDA1MDQ1NDI6c2NoYW5kaW5pOi0xOi0xOjA6MTp0cnVlOk4vQTpERVZfMjAyMDEyLjE6LTE6LTE=
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

*-----------------------------------------------------------------------------
* <Rating>2006</Rating>
*-----------------------------------------------------------------------------
* Version n dd/mm/yy  GLOBUS Release No. 200511 31/10/05
*
$PACKAGE FT.BulkProcessing
SUBROUTINE FT.BK.DEBIT.AC.CHECK.FIELDS
******************************************************************************
* Routine for Dynamic template Online validation for Bulk Debit of AC Txn type
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
*            Parameter file FT.APPL.DEFAULT should be read using EB.READ.PARAMETER. Removed opening of file
*            FT.APPL.DEFAULT since EB.READ.PARAMETER will the open the file if file is passed as null.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*            Routine incorporated
*
* 22/09/15 - Enhancement 1390617 / Task 1393200
*            Moved the routine IN2CUST.BIC from FT to ST. Hence call to IN2CUST.BIC
*            referred using component ST.Payments
*
* 15/04/16 - Defect 1693925 / Task 1699413
*            Enrichement for Titles in Account handled for multi language.
*
* 08/12/2020 - Enhancement 4020994 / Task 4035326
*              Changing BY.Payments reference to new component reference BY.Payments since
*              beneficiary and beneficiary links table has been moved to new module BY.
***********************************************************************************************************
*
    $USING EB.SystemTables
    $USING EB.Display
    $USING AC.AccountOpening
    $USING AC.Config
    $USING ST.CompanyCreation
    $USING DE.API
    $USING FT.Contract
    $USING BY.Payments
    $USING FT.Config
    $USING FT.BulkProcessing
    $USING EB.DataAccess
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
    READ.ERROR = ""
*
* Open files....
*
    F.APP.DEF=""
    R.APPL.PARM.ID = ""
    ST.CompanyCreation.EbReadParameter("F.FT.APPL.DEFAULT",'N','',R.APPLICATION.DEFAULT.LOC,R.APPL.PARM.ID,F.APP.DEF,READ.ERR)

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

*-----------------------------
* Debit a/c no & credit a/c no
*-----------------------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDebitAc.BkdracDrAccount OR EB.SystemTables.getAf() = FT.BulkProcessing.BulkDebitAc.BkdracCrAccount

            IF EB.SystemTables.getComi() NE '' THEN
                IF EB.SystemTables.getComi()[1,7] MATCHES 'PL5N' THEN EB.SystemTables.setE('FT-PL.NOT.ALLOWED'); RETURN

                N1 = '16..C'
                T1 = '.ALLACCVAL'
                OBJECT.ID="ACCOUNT" ; MAX.LEN=""
                FT.Contract.In2Allaccval(N1,T1)
                IF EB.SystemTables.getEtext() THEN EB.SystemTables.setE(EB.SystemTables.getEtext()); RETURN

                R.ACCOUNT.RECORD = AC.AccountOpening.Account.Read(EB.SystemTables.getComi(), READ.ERROR)
                EB.DataAccess.Dbr('ACCOUNT':@FM:AC.AccountOpening.Account.ShortTitle:@FM:"L", EB.SystemTables.getComi(), SH.TIT.ENRI)
                IF READ.ERROR THEN EB.SystemTables.setE("FT-INVALID.AC.NO"); RETURN
                EB.SystemTables.setComiEnri(SH.TIT.ENRI)
            END

            IF NOT(READ.ERROR) THEN
                ACCT.CCY = R.ACCOUNT.RECORD<AC.AccountOpening.Account.Currency>
                IF EB.SystemTables.getAf() = FT.BulkProcessing.BulkDebitAc.BkdracDrAccount THEN
                    BUL.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracDrCurrency)
                END
                IF EB.SystemTables.getAf() = FT.BulkProcessing.BulkDebitAc.BkdracCrAccount THEN
                    BUL.CCY = EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCrCurrency)
                END
                IF BUL.CCY NE ACCT.CCY THEN
                    IF EB.SystemTables.getAf() = FT.BulkProcessing.BulkDebitAc.BkdracDrAccount THEN
                        EB.SystemTables.setE("FT-INVALID.CCY.FOR.DB.ACC"); RETURN
                    END
                    IF EB.SystemTables.getAf() = FT.BulkProcessing.BulkDebitAc.BkdracCrAccount THEN
                        EB.SystemTables.setE("FT-INVALID.ACCT.FOR.CR.CCY"); RETURN
                    END
                END
            END


*------------------
* Ordering customer
*------------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDebitAc.BkdracOrderingCu

            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'SW' ; T1<2,2> = 'CUS'
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setE(EB.SystemTables.getEtext()); RETURN
                END

* If SWIFT address is entered then check for BIC code validation
                IF EB.SystemTables.getComi()[1,3] = 'SW-' AND EB.SystemTables.getAs() = 1 THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN RETURN
                END

                IF LEN(EB.SystemTables.getComi()) < 11 AND EB.SystemTables.getAs() = 1 THEN
                    IF NUM(EB.SystemTables.getComi()) THEN
                        customerKey = EB.SystemTables.getComi()
                        customerNameAddress = ''
                        prefLang = EB.SystemTables.getLngg()
                        CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
                        EB.SystemTables.setComiEnri(customerNameAddress<NameAddress.shortName>)
                        IF EB.SystemTables.getEtext() THEN
                            EB.SystemTables.setE(EB.SystemTables.getEtext()); RETURN
                        END
                    END
                END

                IF EB.SystemTables.getAs() > 4 THEN
                    EB.SystemTables.setE('FT-O.NOT.EXCEED.4.LINES'); RETURN
                END
            END

*--------------
* Ordering Bank
*--------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDebitAc.BkdracOrderingBk

            IF EB.SystemTables.getComi() NE "" THEN
                N1 = '35..C'
                T1 = 'CUST.BIC' ; T1<2,1> = 'S' ; T1<2,2> = 'BIC'
                BY.Payments.In2custBic(N1,T1)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setE(EB.SystemTables.getEtext()); RETURN
                END

* If SWIFT address is entered then check for BIC code validation
                IF EB.SystemTables.getComi()[1,3] = 'SW-' AND EB.SystemTables.getAs() = 1 THEN
                    GOSUB CHECK.SWIFT.ADDRESS
                    IF EB.SystemTables.getE() THEN RETURN
                END

                BEGIN CASE
                    CASE EB.SystemTables.getAs() > 4
                        EB.SystemTables.setE("FT-O.NOT.EXCEED.4.LINES"); RETURN
                    CASE EB.SystemTables.getAs() = 1
                        IF LEN(EB.SystemTables.getComi()) < 15 THEN

                            FT.Contract.EnrichCusOrBic( EB.SystemTables.getComi(), EB.SystemTables.getComiEnri())

                            IF NOT(NUM(EB.SystemTables.getComi())) THEN EB.SystemTables.setEtext('')

                            IF EB.SystemTables.getEtext() THEN
                                EB.SystemTables.setE(EB.SystemTables.getEtext()); RETURN
                            END
                            GOSUB IS.THIS.A.BANK
                            IF NOT.A.BANK THEN RETURN
                        END
                END CASE
            END


*-----------------------
* Rate field validations
*-----------------------
        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDebitAc.BkdracTreasuryRate
            IF EB.SystemTables.getComi() NE '' THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCustomerRate) THEN
                    EB.SystemTables.setE("FT-T.RATE.NOT.ALLOW.IF.C.RATE.PRES"); RETURN
                END
            END

        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDebitAc.BkdracCustomerRate
            IF EB.SystemTables.getComi() NE '' THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracTreasuryRate) OR EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCustomerSpread) THEN
                    EB.SystemTables.setE("FT-C.RATE.NOT.ALLOW.IF.T.RATE.PRES"); RETURN
                END
            END

        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDebitAc.BkdracCustomerSpread
            IF EB.SystemTables.getComi() NE '' THEN
                IF EB.SystemTables.getRNew(FT.BulkProcessing.BulkDebitAc.BkdracCustomerRate) THEN
                    EB.SystemTables.setE("FT-C.SPR.NOT.ALLOW.IF.C.RATE.PRES"); RETURN
                END
            END


*-------------
* RATE FIXING
*-------------

        CASE EB.SystemTables.getAf() = FT.BulkProcessing.BulkDebitAc.BkdracRateFixing
            IF EB.SystemTables.getComi() THEN
                IF NOT(R.APPLICATION.DEFAULT.LOC<FT.Config.ApplDefault.FtOneRateFixing>) AND EB.SystemTables.getComi() = 'YES' THEN
                    EB.SystemTables.setE('FT-RATE.FIX.NOT.ALLOWED'); RETURN
                END
            END ELSE
                EB.SystemTables.setComi(R.APPLICATION.DEFAULT.LOC<FT.Config.ApplDefault.FtOneRateFixing>)
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

*--------------
IS.THIS.A.BANK:
*--------------

    tmp.COMI = EB.SystemTables.getComi()
    tmp.COMI = EB.SystemTables.getComi()
    IF NUM(tmp.COMI) AND LEN(tmp.COMI) < 11 THEN
        PRETURN.CODE = ""
        tmp.COMI = EB.SystemTables.getComi()
        AC.Config.CheckAccountClass ( "BANK", "", tmp.COMI, "", PRETURN.CODE)
        EB.SystemTables.setComi(tmp.COMI)

        IF PRETURN.CODE = "YES" THEN
            NOT.A.BANK = 0
        END ELSE
            NOT.A.BANK = 1
            EB.SystemTables.setE("FT-INP.BANK.,.PLEASE.RETYPE")
        END
    END ELSE
        NOT.A.BANK = 0      ;* Treat as a BANK
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
