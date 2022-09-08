* @ValidationCode : MjotMTAxNjQ1NjE1MjpDcDEyNTI6MTYxMTgxNDc2MjczMjpwYXZpdGhyYS5tb2hhbjo0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEyLjIwMjAxMTI4LTA2MzA6NDU1OjIyNw==
* @ValidationInfo : Timestamp         : 28 Jan 2021 11:49:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : pavithra.mohan
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 227/455 (49.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>2396</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqFees
SUBROUTINE CHEQUE.CHARGE
*
*     CHEQUE CHARGE
*     =============
*--------Modifications---------------------------------------------------
*   01/06/01 - GLOBUS_EN_10000101
*              - Four fields Currency.Market, Rate.Type, Cheque.Status,
*                Charge.Code and 6 reserved fields added.
*              - Cheque.Status and Charge.Code are associated MV set.
*              - Value in Cheque.Status must be a valid Cheque.Status record
*              - Value in Charge.Code is validated against Ft.Charge.Type and
*                Ft.Commission.Type. Flat amount must be mentioned in
*                Ft.Commission.Type
*              - Charges mentioned in Charge.Code are defaulted in Cheque.Issue
*                applicaton for the status mentioned in field Cheque.Status
*                The charges defined in Charge.Code with Cheque.Status as blank,
*                gets defaulted for all other status.
*              - Currency.Market will be defaulted to 1 if it is left blank.
*              - Rate.Type will be defaulted to Mid.Rate if it is left blank.
*              - If the default currency in Ft.Charge and Ft.Commission is a
*                FCY, then charges are calculated at Mid.Reval.Rate.
*
*
* 20/09/02 - EN_10001178
*            Conversion of error messages to error codes.
*
* 30/03/07 - CI_10048149
*            A Local Ref field is added in CHEQUE.TYPE application.
*
* 01/03/12 - Task 360271
*            Field PERIOD.BAND.LEVEL is made as optional and if ENTERED the period.charge.cyle,charge.freq,charge.amt
*            is made as mandatory and if FLAT.CHARGE.AMT entered it ask for frequency and cycle as mandatory.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Fees as ST_ChqFees and include $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*            Routine incorporated
*
*12/10/15 -  Enhancement 1265068
*         -  Task 1497940
*            Changing Dbr to table Read
*
*
* 11/10/17 - Defect 2227731 / Task 2264416
*           Added the validation for the field ISSUE.START.DATE correctly.
*           Its accepts 4 charactor and also in DDMM format.
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
* 31/01/20 - Enhancement 3367949 / Task 3565098
*            Changing reference of routines that have been moved from ST to CG
*
* 13/01/21 - Enhancement 3784714 / Task 3784714
*            Introduced new field TAX.ID for calculate tax amount based on charge amount
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING CQ.ChqConfig
    $USING ST.Config
    $USING ST.CurrencyConfig
    $USING CG.ChargeConfig
    $USING EB.Display
    $USING EB.TransactionControl
    $USING EB.ErrorProcessing
    $USING EB.Utility
    $USING CQ.ChqFees
    $USING EB.DataAccess

*EN_10000101 -e
*************************************************************************

    GOSUB DEFINE.PARAMETERS

    IF LEN(EB.SystemTables.getVFunction()) GT 1 THEN
        GOTO V$EXIT
    END

    EB.Display.MatrixUpdate()

    GOSUB INITIALISE          ;* Special Initialising

*************************************************************************

* Main Program Loop

    LOOP

        EB.TransactionControl.RecordidInput()

    UNTIL EB.SystemTables.getMessage() = 'RET' DO

        V$ERROR = ''

        IF EB.SystemTables.getMessage() = 'NEW FUNCTION' THEN

            GOSUB CHECK.FUNCTION        ;* Special Editing of Function

            IF EB.SystemTables.getVFunction() EQ 'E' OR EB.SystemTables.getVFunction() EQ 'L' THEN
                EB.Display.FunctionDisplay()
                EB.SystemTables.setVFunction('')
            END

        END ELSE

            GOSUB CHECK.ID    ;* Special Editing of ID
            IF V$ERROR THEN GOTO MAIN.REPEAT
            EB.TransactionControl.RecordRead()

            IF EB.SystemTables.getMessage() = 'REPEAT' THEN
                GOTO MAIN.REPEAT
            END

            EB.Display.MatrixAlter()
            GOSUB CHECK.RECORD          ;* Special Editing of Record
            IF V$ERROR THEN GOTO MAIN.REPEAT

            LOOP
                GOSUB PROCESS.FIELDS    ;* ) For Input
                GOSUB PROCESS.MESSAGE   ;* ) Applications
            WHILE EB.SystemTables.getMessage() = 'ERROR' DO REPEAT

        END

MAIN.REPEAT:
    REPEAT

V$EXIT:
RETURN          ;* From main program

*************************************************************************
*                      S u b r o u t i n e s                            *
*************************************************************************

PROCESS.FIELDS:

* Input or display the record fields.

    LOOP

        IF EB.SystemTables.getScreenMode() EQ 'MULTI' THEN
            IF EB.SystemTables.getFileType() EQ 'I' THEN
                EB.Display.FieldMultiInput()
            END ELSE
                EB.Display.FieldMultiDisplay()
            END
        END ELSE
            IF EB.SystemTables.getFileType() EQ 'I' THEN
                EB.Display.FieldInput()
            END ELSE
                EB.Display.FieldDisplay()
            END
        END

    UNTIL EB.SystemTables.getMessage() <> "" DO

        GOSUB CHECK.FIELDS    ;* Special Field Editing
        IF EB.SystemTables.getTSequ() NE '' THEN tmp=EB.SystemTables.getTSequ(); tmp<-1>=EB.SystemTables.getA() + 1; EB.SystemTables.setTSequ(tmp)

    REPEAT

RETURN

*************************************************************************

PROCESS.MESSAGE:

* Processing after exiting from field input (PF5)

    IF EB.SystemTables.getMessage() = 'VAL' THEN
        EB.SystemTables.setMessage('')
        BEGIN CASE
            CASE EB.SystemTables.getVFunction() EQ 'D'
*              GOSUB CHECK.DELETE       ;* Special Deletion checks
            CASE EB.SystemTables.getVFunction() EQ 'R'
*              GOSUB CHECK.REVERSAL     ;* Special Reversal checks
            CASE 1
                GOSUB CROSS.VALIDATION      ;* Special Cross Validation
        END CASE
*        IF NOT(ERROR) THEN
*           GOSUB BEFORE.UNAU.WRITE     ;* Special Processing before write
*        END
        IF NOT(V$ERROR) THEN
            EB.TransactionControl.UnauthRecordWrite()
*           IF MESSAGE NE "ERROR" THEN
*              GOSUB AFTER.UNAU.WRITE   ;* Special Processing after write
*           END
        END

    END

    IF EB.SystemTables.getMessage() = 'AUT' THEN
        GOSUB BEFORE.AUTH.WRITE         ;* Special Processing before write
        EB.TransactionControl.AuthRecordWrite()
*        GOSUB AFTER.AUTH.WRITE         ;* Special Processing after write
    END

PROCESS.MESSAGE.EXIT:
RETURN

*************************************************************************

PROCESS.DISPLAY:

* Display the record fields.

    IF EB.SystemTables.getScreenMode() EQ 'MULTI' THEN
        EB.Display.FieldMultiDisplay()
    END ELSE
        EB.Display.FieldDisplay()
    END

RETURN

*************************************************************************
*                      Special Tailored Subroutines                     *
*************************************************************************

CHECK.ID:

* Validation and changes of the ID entered.  Set ERROR to 1 if in error.


RETURN

*************************************************************************

CHECK.RECORD:

* Validation and changes of the Record.  Set ERROR to 1 if in error.
*EN_10000101 -s

    EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgChargeCode)
    ENRIX = ''
    LNGG.POS = EB.SystemTables.getLngg()
    NO.CHGS = DCOUNT(EB.SystemTables.getRNew(EB.SystemTables.getAf()),@VM)
    FOR I = 1 TO NO.CHGS
        EB.SystemTables.setAv(I)
        REC.ID = EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()>
        R.REC = CG.ChargeConfig.FtChargeType.Read(REC.ID, ER)
        ENRIX = R.REC<CG.ChargeConfig.FtChargeType.FtFivDescription,LNGG.POS>
        IF NOT(ENRIX) THEN
            ENRIX = R.REC<CG.ChargeConfig.FtChargeType.FtFivDescription,1>
        END
        IF ER THEN
            EB.SystemTables.setEtext('')
            REC.ID = EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()>
            ER = ''
            R.REC = CG.ChargeConfig.FtCommissionType.Read(REC.ID, ER)
            ENRIX = R.REC<CG.ChargeConfig.FtCommissionType.FtFouDescription,LNGG.POS>
            IF NOT(ENRIX) THEN
                ENRIX = R.REC<CG.ChargeConfig.FtCommissionType.FtFouDescription,1>
            END
        END
        EB.SystemTables.setEtext(ER)
        IF NOT(ER) THEN
            LOCATE EB.SystemTables.getAf():'.':EB.SystemTables.getAv() IN EB.SystemTables.getTFieldno()<1> SETTING A.INDEX ELSE A.INDEX = ''
            IF A.INDEX NE '' THEN
                tmp=EB.SystemTables.getTEnri(); tmp<A.INDEX>=ENRIX; EB.SystemTables.setTEnri(tmp)
            END
        END
    NEXT I
*EN_10000101 -e

    GOSUB CHECK.TAX.ID

RETURN

*************************************************************************

CHECK.FIELDS:

    BEGIN CASE

        CASE EB.SystemTables.getAf()=CQ.ChqFees.ChequeCharge.ChequeChgPlCategory
            PL.CATEGORY=EB.SystemTables.getComi()
            GOSUB PL.CATEGORY.VAL
        CASE EB.SystemTables.getAf()=CQ.ChqFees.ChequeCharge.ChequeChgTransactionDr
            TRANSACTION.DR=EB.SystemTables.getComi()
            GOSUB TRANSACTION.DR.VAL
        CASE EB.SystemTables.getAf()=CQ.ChqFees.ChequeCharge.ChequeChgTransactionCr
            TRANSACTION.CR=EB.SystemTables.getComi()
            GOSUB TRANSACTION.CR.VAL
        CASE EB.SystemTables.getAf()=CQ.ChqFees.ChequeCharge.ChequeChgIssueStartDate
            CHARGE.CYCLE=EB.SystemTables.getComi()
            GOSUB ISSUE.START.VAL
        CASE EB.SystemTables.getAf()=CQ.ChqFees.ChequeCharge.ChequeChgIssueChgFqu
            IF EB.SystemTables.getComi()#'' THEN EB.Utility.Fqu()
            IF EB.SystemTables.getEtext()='' THEN
                CHARGE.FQU=EB.SystemTables.getComi()
                GOSUB CHARGE.ISS.FQU.VAL
            END ELSE ER=EB.SystemTables.getEtext()
        CASE EB.SystemTables.getAf()=CQ.ChqFees.ChequeCharge.ChequeChgPeriodChgCycle
            CHARGE.CYCLE=EB.SystemTables.getComi()
            GOSUB CHARGE.CYCLE.VAL
        CASE EB.SystemTables.getAf()=CQ.ChqFees.ChequeCharge.ChequeChgPeriodChgFqu
            IF EB.SystemTables.getComi()#'' THEN EB.Utility.Fqu()
            IF EB.SystemTables.getEtext()='' THEN
                CHARGE.FQU=EB.SystemTables.getComi()
                GOSUB CHARGE.PER.FQU.VAL
            END ELSE ER=EB.SystemTables.getEtext()
* EN_10000101 -s
* Do not accept Rate.Type without value in currency.market

        CASE EB.SystemTables.getAf()=CQ.ChqFees.ChequeCharge.ChequeChgRateType
            IF EB.SystemTables.getComi() THEN
                IF NOT(EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgCurrencyMarket)) THEN
                    EB.SystemTables.setE('ST.CCR.CCY.MARKET.NOT.DEF')
                    EB.SystemTables.setTSequ('IFLD')
                    EB.ErrorProcessing.Err()
                END
            END


*  Check if input is a valid Ft.Charge.Type code or
*  an Ft.Commission.Type code with Flat.Amt
*
        CASE EB.SystemTables.getAf()=CQ.ChqFees.ChequeCharge.ChequeChgChargeCode
            CG.ChargeConfig.InTwochg("11","CHG")
            IF EB.SystemTables.getEtext()='' THEN
                ER = EB.SystemTables.getEtext()
            END
            CHG.CODE = EB.SystemTables.getComi()
            IF CHG.CODE THEN
                EB.SystemTables.setEtext('')
                FLT.AMT = ''
                R.REC = CG.ChargeConfig.FtCommissionType.Read(CHG.CODE, ER)
                FLT.AMT = R.REC<CG.ChargeConfig.FtCommissionType.FtFouFlatAmt>
                IF NOT(ER) THEN
                    IF FLT.AMT = '' THEN
                        ER = 'FLAT AMOUNT MUST BE PRESENT'
                        EB.SystemTables.setEtext(ER)
                    END
                    IF ER THEN EB.SystemTables.setEtext(ER)
                    EB.SystemTables.setE(EB.SystemTables.getEtext())
                    IF EB.SystemTables.getE() THEN
                        EB.SystemTables.setTSequ('IFLD')
                        EB.ErrorProcessing.Err()
                    END
                END
            END
* EN_10000101 -e
    END CASE

RETURN

*************************************************************************

CROSS.VALIDATION:
    ER = ''
    PL.CATEGORY=EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgPlCategory)
    GOSUB PL.CATEGORY.VAL
    IF ER THEN EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgPlCategory); EB.SystemTables.setEtext(ER); EB.ErrorProcessing.StoreEndError() ; ER=''
    TRANSACTION.DR=EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgTransactionDr)
    GOSUB TRANSACTION.DR.VAL
    IF ER THEN EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgTransactionDr); EB.SystemTables.setEtext(ER); EB.ErrorProcessing.StoreEndError() ; ER=''
    TRANSACTION.CR=EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgTransactionCr)
    GOSUB TRANSACTION.CR.VAL
    IF ER THEN EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgTransactionCr); EB.SystemTables.setEtext(ER); EB.ErrorProcessing.StoreEndError() ; ER=''
    GOSUB ISSUE.BAND.LEVEL.VAL
    CHARGE.CYCLE=EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgIssueStartDate)
    GOSUB ISSUE.START.VAL
    IF ER THEN EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgIssueStartDate); EB.SystemTables.setEtext(ER); EB.ErrorProcessing.StoreEndError() ; ER=''
    CHARGE.FQU=EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgIssueChgFqu)
    GOSUB CHARGE.ISS.FQU.VAL
    IF ER THEN EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgIssueChgFqu); EB.SystemTables.setEtext(ER); EB.ErrorProcessing.StoreEndError() ; ER=''
    GOSUB PERIOD.BAND.LEVEL.VAL
    CHARGE.CYCLE=EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgPeriodChgCycle)
    GOSUB CHARGE.CYCLE.VALIDATION
    IF ER THEN EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgPeriodChgCycle); EB.SystemTables.setEtext(ER); EB.ErrorProcessing.StoreEndError() ; ER=''
    CHARGE.FQU=EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgPeriodChgFqu)
    GOSUB CHARGE.PER.FQU.VAL
    IF ER THEN EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgPeriodChgFqu); EB.SystemTables.setEtext(ER); EB.ErrorProcessing.StoreEndError() ; ER=''
*EN_10000101 -s
* Do not accept Rate.Type without value in currency.market
    EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgCurrencyMarket)
    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) AND NOT(EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgRateType)) THEN
        EB.SystemTables.setEtext('ST.CCR.RATE.TYPE.NOT.DEF')
        EB.ErrorProcessing.StoreEndError()
        EB.SystemTables.setEtext('')
    END

    EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgRateType)
    IF EB.SystemTables.getRNew(EB.SystemTables.getAf()) AND NOT(EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgCurrencyMarket)) THEN
        EB.SystemTables.setEtext('ST.CCR.CURRENCY.MARKET.NOT.DEF')
        EB.ErrorProcessing.StoreEndError()
        EB.SystemTables.setEtext('')
    END

* Check for duplicate cheque.status or null cheque.status
    EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgChequeStatus)
    CQ.ChqFees.ChkDupChqStatus()

*  Check for duplicate charge.code or null charge.code
    EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgChargeCode)
    CQ.ChqFees.ValChgCode()
    CQ.ChqFees.ChkDupChqStatus()
* EN_10000101 -e
    GOSUB CHECK.TAX.ID
    IF TaxEnri EQ '' AND TaxId NE '' THEN
        EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgTaxId)
        EB.SystemTables.setEtext("CQ-TAX.NOT.A.VALID")
        EB.ErrorProcessing.StoreEndError()
    END
    

RETURN


*************************************************************************
CHECK.TAX.ID:
    
* Check the Tax ID and update the Enrichment
    TaxId=EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgTaxId)
    IF TaxId THEN
        IF TaxId[1,1] EQ "*" THEN ;* Could be TAX.TYPE id
            TaxType = FIELD(TaxId,'*',2)
            TaxRec = CG.ChargeConfig.TaxType.Read(TaxType, rErr)
            TaxEnri= TaxRec<CG.ChargeConfig.TaxType.TaxTtyDescription,1>
        END ELSE
            EB.DataAccess.Dbr("TAX":@FM:CG.ChargeConfig.Tax.EbTaxDescription:@FM:"L.A..D",TaxId,TaxEnri)
        END
        EB.Display.SetFieldEnrichment(CQ.ChqFees.ChequeCharge.ChequeChgTaxId, TaxEnri) ;* Update the enrichment
    END
RETURN
*************************************************************************

CHECK.DELETE:


RETURN

*************************************************************************

CHECK.REVERSAL:


RETURN

*************************************************************************

BEFORE.UNAU.WRITE:


RETURN

*************************************************************************

AFTER.UNAU.WRITE:


RETURN

*************************************************************************

AFTER.AUTH.WRITE:


RETURN

*************************************************************************

BEFORE.AUTH.WRITE:


RETURN

*************************************************************************

CHECK.FUNCTION:

* Validation of function entered.  Set FUNCTION to null if in error.

    IF INDEX('VRHFB',EB.SystemTables.getVFunction(),1) THEN
        EB.SystemTables.setE('ST.CCR.FUNT.NOT.ALLOW.APP')
        EB.ErrorProcessing.Err()
        EB.SystemTables.setVFunction('')
    END

RETURN

*************************************************************************

INITIALISE:

RETURN

*************************************************************************

DEFINE.PARAMETERS:

    EB.SystemTables.setIdCheckfile(""); EB.SystemTables.setIdConcatfile("")
    EB.SystemTables.clearF()
    EB.SystemTables.clearN()
    EB.SystemTables.clearT()
    EB.SystemTables.clearCheckfile()
    EB.SystemTables.clearConcatfile()

    EB.SystemTables.setIdF('CHEQUE.TYPE')
    EB.SystemTables.setIdN('4.1')
    EB.SystemTables.setIdT('A')
    EB.SystemTables.setIdCheckfile("CHEQUE.TYPE":@FM:CQ.ChqConfig.ChequeType.ChequeTypeDescription:@FM:"L.A")

    Z = 0
    Z+=1
    EB.SystemTables.setF(Z, 'PL.CATEGORY'); EB.SystemTables.setN(Z, '5.1.C'); tmp=EB.SystemTables.getT(Z); tmp<4>='R##-###'; EB.SystemTables.setT(Z, tmp)
    EB.SystemTables.setCheckfile(Z, 'CATEGORY':@FM:ST.Config.Category.EbCatDescription:@FM:'L')
    Z+=1
    EB.SystemTables.setF(Z, 'TRANSACTION.DR'); EB.SystemTables.setN(Z, '3.1.C'); EB.SystemTables.setT(Z, 'A')
    EB.SystemTables.setCheckfile(Z, 'TRANSACTION':@FM:ST.Config.Transaction.AcTraNarrative:@FM:'L')
    Z+=1
    EB.SystemTables.setF(Z, 'TRANSACTION.CR'); EB.SystemTables.setN(Z, '3.1.C'); EB.SystemTables.setT(Z, 'A')
    EB.SystemTables.setCheckfile(Z, 'TRANSACTION':@FM:ST.Config.Transaction.AcTraNarrative:@FM:'L')
    Z+=1
    EB.SystemTables.setF(Z, 'FLAT.ISSUE.CHG'); EB.SystemTables.setN(Z, '019'); EB.SystemTables.setT(Z, 'AMT'); tmp=EB.SystemTables.getT(Z); tmp<2,2>=EB.SystemTables.getLccy(); EB.SystemTables.setT(Z, tmp)
    Z+=1
    EB.SystemTables.setF(Z, 'ISSUE.BAND.LEVEL'); EB.SystemTables.setN(Z, '5.1'); EB.SystemTables.setT(Z, ''); tmp=EB.SystemTables.getT(Z); tmp<2>='BAND_LEVEL'; EB.SystemTables.setT(Z, tmp)
    Z+=1
    EB.SystemTables.setF(Z, 'XX<ISSUE.UPTO'); EB.SystemTables.setN(Z, '5..C'); EB.SystemTables.setT(Z, '')
    Z+=1
    EB.SystemTables.setF(Z, 'XX>ISSUE.CHG.AMT'); EB.SystemTables.setN(Z, '019..C'); EB.SystemTables.setT(Z, 'AMT'); tmp=EB.SystemTables.getT(Z); tmp<2,2>=EB.SystemTables.getLccy(); EB.SystemTables.setT(Z, tmp)
    Z+=1
    EB.SystemTables.setF(Z, 'ISSUE.START.DATE'); EB.SystemTables.setN(Z, '17..C'); EB.SystemTables.setT(Z, 'A') ;*Manually added the validation for DDMM property instead of call IN2DDMM.
    Z+=1
    EB.SystemTables.setF(Z, 'ISSUE.CHG.FQU'); EB.SystemTables.setN(Z, '5..C'); EB.SystemTables.setT(Z, 'A')
    Z+=1
    EB.SystemTables.setF(Z, 'FLAT.PERIOD.CHG'); EB.SystemTables.setN(Z, '019'); EB.SystemTables.setT(Z, 'AMT'); tmp=EB.SystemTables.getT(Z); tmp<2,2>=EB.SystemTables.getLccy(); EB.SystemTables.setT(Z, tmp)
    Z+=1
    EB.SystemTables.setF(Z, 'PERIOD.BAND.LEVEL'); EB.SystemTables.setN(Z, '5'); EB.SystemTables.setT(Z, ''); tmp=EB.SystemTables.getT(Z); tmp<2>='BAND_LEVEL'; EB.SystemTables.setT(Z, tmp)
    Z+=1
    EB.SystemTables.setF(Z, 'XX<PERIOD.UPTO'); EB.SystemTables.setN(Z, '5..C'); EB.SystemTables.setT(Z, '')
    Z+=1
    EB.SystemTables.setF(Z, 'XX>PERIOD.CHG.AMT'); EB.SystemTables.setN(Z, '019..C'); EB.SystemTables.setT(Z, 'AMT'); tmp=EB.SystemTables.getT(Z); tmp<2,2>=EB.SystemTables.getLccy(); EB.SystemTables.setT(Z, tmp)
    Z+=1
    EB.SystemTables.setF(Z, 'PERIOD.CHG.CYCLE'); EB.SystemTables.setN(Z, '17..C'); EB.SystemTables.setT(Z, 'FQU'); tmp=EB.SystemTables.getT(Z); tmp<4>='RDD DDD DDDD #####'; EB.SystemTables.setT(Z, tmp)
    Z+=1
    EB.SystemTables.setF(Z, 'PERIOD.CHG.FQU'); EB.SystemTables.setN(Z, '5..C'); EB.SystemTables.setT(Z, 'A')
*EN_10000101 -s
    Z += 1 ;
    EB.SystemTables.setF(Z, 'CURRENCY.MARKET'); EB.SystemTables.setN(Z, '2..C'); EB.SystemTables.setT(Z, "")
    EB.SystemTables.setCheckfile(Z, "CURRENCY.MARKET":@FM:ST.CurrencyConfig.CurrencyMarket.EbCmaDescription:@FM:'L.A')
    Z += 1 ;
    EB.SystemTables.setF(Z, 'RATE.TYPE'); EB.SystemTables.setN(Z, '4..1'); EB.SystemTables.setT(Z, ""); tmp=EB.SystemTables.getT(Z); tmp<2>="BUY_MID_SELL"; EB.SystemTables.setT(Z, tmp)
    Z+=1
    EB.SystemTables.setF(Z, 'XX<CHEQUE.STATUS'); EB.SystemTables.setN(Z, '2'); EB.SystemTables.setT(Z, 'A')
    EB.SystemTables.setCheckfile(Z, 'CHEQUE.STATUS':@FM:CQ.ChqConfig.ChequeStatus.ChequeStsDescription:@FM:'L')
    Z+=1
    EB.SystemTables.setF(Z, 'XX>XX.CHARGE.CODE'); EB.SystemTables.setN(Z, '11..C'); EB.SystemTables.setT(Z, 'CHG'); tmp=EB.SystemTables.getT(Z); tmp<2>='CHG':@VM:'COM';
    EB.SystemTables.setT(Z, tmp)
    Z+=1 ; EB.SystemTables.setF(Z, "XX.LOCAL.REF"); EB.SystemTables.setN(Z, "35..C"); EB.SystemTables.setT(Z, "A");* CI_10048149 S/E
    Z+=1 ; EB.SystemTables.setF(Z, "TAX.ID"); EB.SystemTables.setN(Z, "16"); EB.SystemTables.setT(Z, "A"); tmp=EB.SystemTables.getT(Z); EB.SystemTables.setT(Z, tmp)
    Z+=1 ; EB.SystemTables.setF(Z, "RESERVED4"); EB.SystemTables.setN(Z, "35"); EB.SystemTables.setT(Z, ""); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
    Z+=1 ; EB.SystemTables.setF(Z, "RESERVED3"); EB.SystemTables.setN(Z, "35"); EB.SystemTables.setT(Z, ""); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
    Z+=1 ; EB.SystemTables.setF(Z, "RESERVED2"); EB.SystemTables.setN(Z, "35"); EB.SystemTables.setT(Z, ""); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
    Z+=1 ; EB.SystemTables.setF(Z, "RESERVED1"); EB.SystemTables.setN(Z, "35"); EB.SystemTables.setT(Z, ""); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
*EN_10000101 -e



    EB.SystemTables.setV(Z + 9)

RETURN

*************************************************************************
RETURN
*
*-----P & L CATEGORY-----------------------------------------------------
*
PL.CATEGORY.VAL:
    IF PL.CATEGORY LT 50000 OR PL.CATEGORY GE 60000 THEN
        ER='MUST BE IN THE RANGE 50-000 TO 59-999'
    END
RETURN
*
*-----DEBIT TRANSACTION CODE---------------------------------------------
*
TRANSACTION.DR.VAL:
    IF TRANSACTION.DR GE 100 AND TRANSACTION.DR LT 200 THEN
        DEBIT.CREDIT.IND=''
        R.TRANS = ST.Config.Transaction.Read(TRANSACTION.DR, TR.ER)
        DEBIT.CREDIT.IND = R.TRANS<ST.Config.Transaction.AcTraDebitCreditInd>
        IF DEBIT.CREDIT.IND='CREDIT' THEN
            ER='NO DEBIT TRANSACTION CODE'
        END
    END ELSE
        ER='MUST BE IN THE RANGE 100 TO 199'
    END
RETURN
*
*-----CREDIT TRANSACTION CODE--------------------------------------------
*
TRANSACTION.CR.VAL:
    IF TRANSACTION.CR GE 100 AND TRANSACTION.CR LT 200 THEN
        DEBIT.CREDIT.IND=''
        R.TRANS = ST.Config.Transaction.Read(TRANSACTION.CR, TR.ER)
        DEBIT.CREDIT.IND = R.TRANS<ST.Config.Transaction.AcTraDebitCreditInd>
        IF DEBIT.CREDIT.IND='DEBIT' THEN
            ER='NO CREDIT TRANSACTION CODE'
        END
    END ELSE
        ER='MUST BE IN THE RANGE 100 TO 199'
    END
RETURN
*
*-----CHARGE CYCLE-------------------------------------------------------
*
CHARGE.CYCLE.VAL:
RETURN
*
CHARGE.CYCLE.VALIDATION:
    PERIOD.CHG = EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgPeriodChgAmt)
    FLAT.CHG = EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgFlatPeriodChg)
    IF (CHARGE.CYCLE NE '') AND (PERIOD.CHG EQ '') AND (FLAT.CHG EQ '') THEN
        ER = 'I/P EITHER PERIOD.CHG.AMT/FLAT.PERIOD.CHG'
    END
RETURN
*
*-----ISSUE START DATE-
*
ISSUE.START.VAL:
*Validation for the field ISSUE.START.DATE, it accepts 4 char and DDMM format only.

    IS.START.VAL = EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgIssueStartDate)
    SAVI.COMI.VAL = EB.SystemTables.getComi()
    IF NOT(SAVI.COMI.VAL) THEN
        EB.SystemTables.setComi(IS.START.VAL)
    END
    IF IS.START.VAL NE '' THEN
        LENGTH = LEN(EB.SystemTables.getComi())
        IF NOT(NUM(EB.SystemTables.getComi())) OR (LENGTH LT 4 OR LENGTH GT 4) THEN
            ER='ST-INPUT.MUST.BE.NUMERIC.IN.DDMM.FORMAT'
        END
        IF NOT(ER) THEN
            EB.Utility.In2ddmm("", "")
            IF EB.SystemTables.getEtext() NE '' THEN
                ER = EB.SystemTables.getEtext()
            END
        END
    END
    EB.SystemTables.setComi(SAVI.COMI.VAL)
   
    IF CHARGE.CYCLE = '' AND EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgIssueChgFqu) <> '' THEN
        ER='CHARGE FQU MISSING'
    END
RETURN
*
*-----CHARGE FREQUENCY---------------------------------------------------
*
CHARGE.PER.FQU.VAL:
    IF CHARGE.FQU#'' THEN
        IF EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgPeriodChgCycle)#'' THEN
            IF CHARGE.FQU[1,1]#'M' THEN
                ER='MINIMUM MONTHLY FREQUENCY'
            END
        END ELSE
            ER='NO INPUT WITHOUT CHARGE CYCLE'
        END
    END
RETURN

CHARGE.ISS.FQU.VAL:
    IF CHARGE.FQU#'' THEN
        IF EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgIssueStartDate) = '' THEN
            ER='ISSUE START DATE MISSING'
        END
        IF CHARGE.FQU[2] <> EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgIssueStartDate)[1,2] THEN
            ER='DAYS NOT EQUAL START DATE DAY'
        END
        IF CHARGE.FQU[2,2] > 12 THEN
            ER='MONTH GREATER THAN 12'
        END
    END
RETURN

*
**********************************************************************
*
ISSUE.BAND.LEVEL.VAL:
*
* Successive values of UPTO numbers must increase in sequence.
*
    EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgIssueUpto)
    tmp.AF = EB.SystemTables.getAf()
    NUM.UPTOS = COUNT(EB.SystemTables.getRNew(tmp.AF),@VM)+1
    EB.SystemTables.setAf(tmp.AF)
    FOR I = 1 TO NUM.UPTOS
        EB.SystemTables.setAv(I)
        IF EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()> AND EB.SystemTables.getAv() > 1 AND EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()> < EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()-1> THEN
            EB.SystemTables.setEtext('ST.CCR.INCREASE.SEQUENCE')
            EB.ErrorProcessing.StoreEndError()
        END
*
* Only last value may be blank
*
        IF EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()> = "" AND EB.SystemTables.getAv() < NUM.UPTOS THEN
            EB.SystemTables.setEtext('ST.CCR.ONLY.LAST.VALUE.MAY.BLANK')
            EB.ErrorProcessing.StoreEndError()
        END
*
* Last value must be blank
*
        IF EB.SystemTables.getAv() = NUM.UPTOS AND EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()> <> "" THEN
            EB.SystemTables.setEtext('ST.CCR.LAST.VALUE.BLANK')
            EB.ErrorProcessing.StoreEndError()
        END
*
* A charge must be entered for each existing upto value even if zero.
*
        IF EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgIssueChgAmt)<1,EB.SystemTables.getAv()> = "" THEN
            EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgIssueChgAmt)
            EB.SystemTables.setEtext("ST.CCR.CHRG.AMT.MISS")
            EB.ErrorProcessing.StoreEndError()
        END
    NEXT I
    EB.SystemTables.setEtext("")
RETURN
*
**********************************************************************
*
PERIOD.BAND.LEVEL.VAL:
*
* Successive values of UPTO numbers must increase in sequence.
*
    EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgPeriodUpto)
    NUM.UPTOS = COUNT(EB.SystemTables.getRNew(EB.SystemTables.getAf()),@VM)+1
    FOR I = 1 TO NUM.UPTOS
        EB.SystemTables.setAv(I)
        IF EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()> AND EB.SystemTables.getAv() > 1 AND EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()> < EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()-1> THEN
            EB.SystemTables.setEtext('ST.CCR.INCREASE.SEQUENCE')
            EB.ErrorProcessing.StoreEndError()
        END
*
* Only last value may be blank
*
        IF EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()> = "" AND EB.SystemTables.getAv() < NUM.UPTOS THEN
            EB.SystemTables.setEtext('ST.CCR.ONLY.LAST.VALUE.MAY.BLANK')
            EB.ErrorProcessing.StoreEndError()
        END
*
* Last value must be blank
*
        IF EB.SystemTables.getAv() = NUM.UPTOS AND EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()> <> "" THEN
            EB.SystemTables.setEtext('ST.CCR.LAST.VALUE.BLANK')
            EB.ErrorProcessing.StoreEndError()
        END
    NEXT I
* If period.band.level is inputted then charge.amt is made as madatory
*
    EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgPeriodChgAmt)
    IF EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgPeriodBandLevel) <> '' THEN
        CHG.AMT = COUNT(EB.SystemTables.getRNew(EB.SystemTables.getAf()),@VM)+1
        FOR I = 1 TO CHG.AMT
            EB.SystemTables.setAv(I)
            IF EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()> = '' THEN

                EB.SystemTables.setEtext("ST.CCR.INP.MISS")
                EB.ErrorProcessing.StoreEndError()
            END
        NEXT I
    END
*
* If periodic charges are defined then a charge frequency must be input
*
    IF EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgPeriodBandLevel) <> "" AND EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgPeriodChgCycle) = "" THEN
        EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgPeriodChgCycle)
        EB.SystemTables.setEtext("ST.CCR.INP.MISS")
        EB.ErrorProcessing.StoreEndError()
    END

    IF EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgPeriodBandLevel) <> "" AND EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgPeriodChgFqu) = "" THEN
        EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgPeriodChgFqu)
        EB.SystemTables.setEtext("ST.CCR.INP.MISS")
        EB.ErrorProcessing.StoreEndError()
    END

    IF EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgFlatPeriodChg) <> "" AND EB.SystemTables.getRNew(CQ.ChqFees.ChequeCharge.ChequeChgPeriodChgFqu) = "" THEN
        EB.SystemTables.setAf(CQ.ChqFees.ChequeCharge.ChequeChgPeriodChgFqu)
        EB.SystemTables.setEtext("ST.CCR.INP.MISS")
        EB.ErrorProcessing.StoreEndError()
    END
    EB.SystemTables.setEtext("")
RETURN
END
