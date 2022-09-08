* @ValidationCode : MToxMzY5MjUwNTQ3OklTTy04ODU5LTE6MTQ3NTE2ODQwODI3ODpzcmVlY2hhcmFuOjE6MDoyOTUwOi0xOmZhbHNlOk4vQTpERVZfMjAxNjA5LjE=
* @ValidationInfo : Timestamp         : 29 Sep 2016 18:00:08
* @ValidationInfo : Encoding          : ISO-8859-1
* @ValidationInfo : User Name         : sreecharan
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : 2950
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201609.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 17 21/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>918</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE IC.InterestAndCapitalisation
    SUBROUTINE CORR.ACCT.DR
REM "CORR.ACCT.DR",850725-001,"MAINPGM"
*
* GB9400210- 09-05-94
*            Allow equivalent currencies, initially for ZAR/ZAL processing
*
* 16/05/00 - GB0000727
*            cater for ica keys in acct*acct-date, acct*-date format
*
* 04/04/01 - GB0100940
*            New fields for Minimum Debit Interest
*
* 18/06/01 - GB0101830
*
* 18/09/02 - GLOBUS_EN_10001159
*          Conversion Of all Error Messages to Error Codes
* 24/06/08 - EN_10003730 & EN_10003749
*            Interest accrual adjustment for current cap period. Manual
*            adjustment field added. Move field definitions to a seperate
*            routine
* 04/10/10 - Task - 84420
*            Replace the enterprise(customer service api)code into  Banking framework related
*            routines which reads CUSTOMER.
* 29/09/16 - Task 1876321
*            Unable to view records
******************************************************************

    $USING AC.AccountOpening
    $USING IC.InterestAndCapitalisation
    $USING EB.Display
    $USING EB.TransactionControl
    $USING EB.ErrorProcessing
    $USING EB.Utility
    $USING EB.Template
    $USING EB.SystemTables

*************************************************************************
REM "DEFINE PGM NAME (BY USING 'C/CORR.ACCT.DR/.../G9999')
*========================================================================

    DIM F(EB.SystemTables.SysDim)
    DIM N(EB.SystemTables.SysDim)
    DIM T(EB.SystemTables.SysDim)
    DIM CHECKFILE(EB.SystemTables.SysDim)
    DIM CONCATFILE(EB.SystemTables.SysDim)

    MAT F = "" ; MAT N = "" ; MAT T = "" ; ID.T = ""
    MAT CHECKFILE = "" ; MAT CONCATFILE = ""
    ID.CHECKFILE = "" ; ID.CONCATFILE = ""
*========================================================================
REM "DEFINE PARAMETERS - SEE 'I_RULES'-DESCRIPTION:
    ID.F = "ACCOUNT.NO.DATE" ; ID.N = "55.2" ; ID.T = "A"   ;* GB0000727
    ID.T<4> = "R########################################### # DDDD DD  DD.###" ; ID.T<2> = "ND" ; ID.T<7> = 2
* checkfile "ACCOUNT":FM:AC.CUSTOMER:FM:FM:"CUSTOMER":FM:EB.CUS.SHORT.NAME separately

    EB.SystemTables.SetIdProperties(ID.F,ID.N,ID.T,ID.CONCATFILE,ID.CHECKFILE)

    IC.InterestAndCapitalisation.StmtAcctDrFields()

    EB.SystemTables.setPrefix("IC.CORDR")
*========================================================================
    V$FUNCTION.VAL = EB.SystemTables.getVFunction()
    IF LEN(V$FUNCTION.VAL) > 1 THEN
        ID.R.VAL = ''
        ID.R.VAL = "aa) Input 2-16 numeric char. (incl. checkdigit) "
        ID.R.VAL = ID.R.VAL:"ACCOUNT.NUMBER or":@FM
        ID.R.VAL = ID.R.VAL:"ab) Input 3-10 MNEMONIC char. (will "
        ID.R.VAL = ID.R.VAL:"be converted to ACCOUNT.NUMBER) and":@FM
        ID.R.VAL = ID.R.VAL:"b) '/' and":@FM
        ID.R.VAL = ID.R.VAL:"c) 1-9 date char. and":@FM
        ID.R.VAL = ID.R.VAL:"d) current number (00)1...999":@FM
        ID.R.VAL = ID.R.VAL:"No input b,c) = today's date":@FM
        ID.R.VAL = ID.R.VAL:"No input b,c,d) = current number 1":@FM
        ID.R.VAL = ID.R.VAL:"ACCOUNT.NUMBER must be an ID of ACCOUNT-record "
        ID.R.VAL = ID.R.VAL:"and relate to an ID of a CUSTOMER-record"
        EB.SystemTables.setIdR(ID.R.VAL)
        RETURN
        * RETURN when pgm used to get parameters only
    END
*------------------------------------------------------------------------
    EB.Display.MatrixUpdate()
*------------------------------------------------------------------------
ID.INPUT:
    EB.TransactionControl.RecordidInput()
    IF EB.SystemTables.getMessage() = "RET" THEN
        RETURN
    END
* return to PGM.SELECTION
    IF EB.SystemTables.getMessage() = "NEW FUNCTION" THEN
        *========================================================================
        REM "CHECK FUNCTION:
        IF EB.SystemTables.getVFunction() = "V" THEN
            EB.SystemTables.setE("IC.RTN.NO.FUNT.APP.1"); EB.SystemTables.setVFunction("")
ID.ERROR:
            EB.ErrorProcessing.Err() ; GOTO ID.INPUT
        END
        *========================================================================
        IF EB.SystemTables.getVFunction() = "E" OR EB.SystemTables.getVFunction() = "L" THEN
            EB.Display.FunctionDisplay() ; EB.SystemTables.setVFunction("")
        END
        GOTO ID.INPUT
    END
*========================================================================
REM "CHECK ID OR CHANGE STANDARD ID:
*
* GB0000727  re format key for ICA style
*
    SAVE.ID.NEW = ""
    COMI.VAL = EB.SystemTables.getComi()
    IF FIELD(COMI.VAL,"*",2) THEN
        SAVE.ID.NEW = COMI.VAL
        *
        * format can be acc*acc-date or acc*-date
        * need to take out * for 1st case, take out acc* for second case
        *
        COMI.VAL = EB.SystemTables.getComi()
        BEF.DATE = FIELD(COMI.VAL,"-",1)
        AFT.DATE = FIELD(COMI.VAL,"-",2)
        FIRST.ACC = FIELD(BEF.DATE,"*",1)
        SECOND.ACC = FIELD(BEF.DATE,"*",2)
        IF SECOND.ACC THEN
            EB.SystemTables.setComi(SECOND.ACC:"-":AFT.DATE)
        END ELSE
            EB.SystemTables.setComi(FIRST.ACC:"-":AFT.DATE)
        END
    END
* GB0000727 e
    COMI.VAL = EB.SystemTables.getComi()
    CONVERT "." TO "" IN COMI.VAL
    EB.SystemTables.setComi(COMI.VAL)
* cancel '.' (part of mask only)

    COMI2 = FIELD(COMI.VAL,"-",EB.SystemTables.getIdT()<7>,99) ; EB.SystemTables.setComi(FIELD(COMI.VAL,"-",EB.SystemTables.getIdT()<7>-1))
    AC.AccountOpening.InTwoacc(16.2,"ACC")
    IF EB.SystemTables.getEtext()<> "" THEN
        EB.SystemTables.setE(EB.SystemTables.getEtext()); GOTO ID.ERROR
    END
    COMI.VAL = EB.SystemTables.getComi()
    YACCOUNT = COMI.VAL ; EB.SystemTables.setIdNew(COMI.VAL:"-"); EB.SystemTables.setComi(COMI2)
    IF EB.SystemTables.getComi() = "" THEN
        YDATE = EB.SystemTables.getToday() ; YNO = 1
    END ELSE
        COMI.VAL = EB.SystemTables.getComi()
        X = LEN(COMI.VAL)
        IF X < 4 THEN
            YNO = COMI.VAL ; YDATE = EB.SystemTables.getToday()
        END ELSE
            YNO = COMI.VAL[X-2,3] ; EB.SystemTables.setComi(COMI.VAL[1,X-3])
            EB.Utility.InTwod(11,"D")
            IF EB.SystemTables.getEtext()<> "" THEN
                EB.SystemTables.setE(EB.SystemTables.getEtext()); GOTO ID.ERROR
            END
            YDATE = EB.SystemTables.getComi()
        END
        EB.SystemTables.setComi(YNO); EB.Template.InTwo(3.1,"")
        IF EB.SystemTables.getEtext()<> "" THEN
            EB.SystemTables.setE("IC.RTN.VERSION":@FM:EB.SystemTables.getEtext()); GOTO ID.ERROR ; GOTO ID.ERROR
        END
    END
    ID.NEW.VAL = EB.SystemTables.getIdNew()
    EB.SystemTables.setVDisplay(TRIMF(FMT(ID.NEW.VAL,"R################ # "):YDATE[7,2]:" ":FIELD(EB.SystemTables.getTRemtext(19)," ",YDATE[5,2]):" ":YDATE[1,4]:"-":FMT(YNO,'3"0"R')))
    EB.SystemTables.setIdNew(ID.NEW.VAL:YDATE:FMT(YNO,'3"0"R'))
    CUSTOMER.ID = ''
    ERR = ''
    R.REC = ''
    R.REC = AC.AccountOpening.Account.Read(YACCOUNT, ERR)
    CUSTOMER.ID = R.REC<AC.AccountOpening.Account.Customer>
    EB.SystemTables.setEtext(ERR)
* get the SHORT.NAME of customer related to account
    customerId = CUSTOMER.ID
    customerName = ''
    prefLang = EB.SystemTables.getLngg()
    CALL CustomerService.getNameAddress(customerId, prefLang, customerName)
* assigned customer's short name to ID.ENRI varible to get enrichment to id.
    EB.SystemTables.setIdEnri(customerName<NameAddress.shortName>)

    IF SAVE.ID.NEW THEN
        EB.SystemTables.setIdNew(SAVE.ID.NEW);* GB0000727 put it back
    END
    IF EB.SystemTables.getEtext()<> "" THEN
        EB.SystemTables.setE(EB.SystemTables.getEtext()); GOTO ID.ERROR
    END
    YCCY = ""
    ERR = ''
    R.REC = ''
    R.REC = AC.AccountOpening.Account.Read(YACCOUNT, ERR)
    YCCY = R.REC<AC.AccountOpening.Account.Currency>
    LINE.CNT = DCOUNT(YCCY,@VM)
    FULL.STR = ''
    FOR CNT = 1 TO LINE.CNT
        LNGG.CODE = EB.SystemTables.getLngg()
        IF LNGG.CODE > 1 THEN IF YCCY<1,CNT,LNGG.CODE> = "" THEN LNGG.CODE = 1
        FULL.STR = FULL.STR:' ':YCCY<1,CNT,LNGG.CODE>
    NEXT CNT
    YCCY = TRIM(FULL.STR)
    EB.SystemTables.setEtext(ERR)
    IF ERR <> "" THEN
        EB.SystemTables.setE(ERR); GOTO ID.ERROR
    END
* GB9601705
    YAMT.FIELDS = ''
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrDrValBalance
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrUnadjDrInt
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrDrIntAmt
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrDrIntTaxAmt
*
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrIntAddonFree
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrUnadjIntAddon
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrIntAddonAmt
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrAddonTaxAmt
*
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrGvValBalance
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrGovMarginAmt
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrGovMrgTotAmt
*
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrHighestDrBal
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrHighestDrFree
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrUnadjHighestDr
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrHighestDrAmt
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrHiDrTaxAmt
*
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrIntStmtAmt
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrStmtTaxAmt
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrTotalInterest
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrTotalCharge
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrTotalTax
    YAMT.FIELDS<1,-1> = IC.InterestAndCapitalisation.CorrAcctDr.CordrGrandTotal
*
    AMT.CNT = 1
    LOOP
        YFLDNO = YAMT.FIELDS<1,AMT.CNT>
    UNTIL YFLDNO = '' DO
        tmp=EB.SystemTables.getT(YFLDNO); tmp<2,2>=YCCY; EB.SystemTables.setT(YFLDNO, tmp)
        AMT.CNT += 1
    REPEAT
*
* update 'AMT'-Type with Currency
*========================================================================
    EB.TransactionControl.RecordRead()
    IF EB.SystemTables.getMessage() = "REPEAT" THEN
        GOTO ID.INPUT
    END
    EB.Display.MatrixAlter()
*========================================================================
REM "SPECIAL CHECKS OR CHANGE FIELDS AFTER READING RECORD(S):
*========================================================================
FIELD.DISPLAY.OR.INPUT:
    IF EB.SystemTables.getScreenMode() = "MULTI" THEN
        EB.Display.FieldMultiDisplay()
    END ELSE
        EB.Display.FieldDisplay()
    END
*------------------------------------------------------------------------
    GOTO ID.INPUT
*************************************************************************
    END
