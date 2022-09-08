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

* Version 11 29/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-91</Rating>
    $PACKAGE FT.Clearing
    SUBROUTINE FT.SIC.DELIVERY
*
** This replaces FT.HYP.BC.DELIVERY as the delivery routine to generate
** SIC messages for Swiss bank clearing. The folowing message types are
** generated for the following SIC messages :
**   1200 - A10
**   1205 - A11
**   1210 - B10
**   1215 - B11
**   1220 - C10
**   1225 - C11 (Inward only)
**   1230 - C15
**   1235 - H70
**
** Decisions on which type of message should be sent are as follows:
**   B10 (Cover paymnet) - If a PAYMENT.CODE in LOCAL.REFERENCE is
**                         present. This message has minimal information.
**   C10 (PTT Transfer)  - If the BC SORT CODE is a PTT code defined on
**                         FT.LOCAL.CLEARING
**   C15 (vesr transfer) - If the BC SORT CODE is a PTT code defined on
**                         FT.LOCAL.CLEARING and CREDIT.THEIR.REF is
**                         present
**   A11 (Third party)   - If ACCT.WITH.BANK is present
**                         or BK TO BK INFO
**   B11 (Bank to Bank)  - If ORDERING AND BEN BANK present
**   H70 (Reversal fwd)  - Reversal of forward valued FT
**   A10 (Customer)      - Any other combination
*
** 08/04/92 - GB9200199
**            MERGE Hypo pifs HY9200570, HY9200420. For C10
**            money orders pass lines 1 and 4.
**
** 30/11/92 - GB9201075
**            Don't switch A10 to A11 if charges are present on the FT
**            as this is incorrect. If rules are clarified it may be
**            a requirement that a message should become an A11 if the
**            charge account is the CLAIM.CHARGES.ACCT and BEN.OUR.CHARG
**            is BEN. This is not part of this change.
**
** 18/05/93 - GB9300866
**            Handoff the Local Reference field to allow extra elements
*
** 26/07/93 - GB9301214
**            For mesg types A10, A11, B11 for field 45, allow A or B to
**            be added if MEM ACCT local reference is set:
**            45A means BEN ACCT NO is known by counterparty.
**            45B means BEN ACCT NO is not known by counterparty.
**            Map the reversal text from 28 and not 27. Cater for charges
**            on PTT transactions
*
* 22/02/07 - BG_100013036
*            CODE.REVIEW changes.
*
* 16/03/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
* 13/08/15 - Enhancement 1265068
*		   - Task 1482605
*		   - DBR changed to Table Read
*
*************************************************************************************************************
    $USING AC.AccountOpening
    $USING FT.Contract
    $USING ST.CompanyCreation
    $USING EB.Security
    $USING ST.Config
    $USING EB.Display
    $USING DE.API
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING FT.Clearing

*
** Initialise variables
*
    DIM YR.MESS(30) ; MAT YR.MESS = ""
    IF FT.Contract.getAutoProcessingInd() NE "Y" THEN
        YTEXT = "TRANS TYPE BC"
        EB.Display.Txt(YTEXT)
        PRINT @(45,7):YTEXT
    END
*
** Determine if a PTT TRANSACTION
*
    LOCATE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BcBankSortCode) IN FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcPttSortCode)<1,1> SETTING PTT.TXN ELSE
    PTT.TXN = ""          ;* BG_100013036 - S
    END   ;* BG_100013036 - E
*
    PAYMENT.CODE = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)<1,FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcPayCodeLoc)>         ;* Find pay code
    MEM.ACCT.CODE = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)<1,FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcMemAcctLoc)>
*
    ORIG.PRODUCT.DESC = ""
    ORIG.MAP.KEY = ""         ;* For H70 only
    BEGIN CASE      ;* Establish msg type
        CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.RecordStatus) = "REVE" AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditValueDate) LE EB.SystemTables.getToday()
            RETURN      ;*No message for REVersal;* BG_100013036 - S / E
        CASE PAYMENT.CODE
            MAP.KEY = "1210"
            PRODUCT.DESC = "B10 COVER"
        CASE PTT.TXN
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditTheirRef) = "" THEN
                MAP.KEY = "1220"
                IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo) THEN
                    PRODUCT.DESC = "C10 PTT TRANSFER"
                END ELSE
                    PRODUCT.DESC = "C10 MONEY ORDER"
                END
            END ELSE
                MAP.KEY = "1230"
                PRODUCT.DESC = "C15 VESR TRANSFER"
            END
        CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank)
            MAP.KEY = "1205"
            PRODUCT.DESC = "A11 THIRD PARTY"
        CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingBank) AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenBank)
            MAP.KEY = "1215"
            PRODUCT.DESC = "B11 BANK PAYMENT"
            *
***!         CASE R.NEW(FT.LOC.POS.CHGS.AMT)
***!            MAP.KEY = "1205"
***!            PRODUCT.DESC = "A11 PAYMENT WITH CHARGE"
            *
        CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BkToBkInfo)
            MAP.KEY = "1205"
            PRODUCT.DESC = "A11 SPECIAL PAYMENT"
        CASE 1
            MAP.KEY = "1200"
            PRODUCT.DESC = "A10 CUST PAYMENT"
    END CASE
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.RecordStatus) = "REVE" THEN
        ORIG.MAP.KEY = MAP.KEY          ;* Store for later
        ORIG.PRODUCT.DESC = PRODUCT.DESC
        MAP.KEY = "1235"
        PRODUCT.DESC = "H70 REVERSAL"
    END
*
    GOSUB SET.UP.COMMON.DETAILS
*
** Deal with specific message types
*
* BEN ACCT NO
    GOSUB PROCESS.BEN.ACCT.NO ;* BG_100013036 - S
*
* PAYMENT.DETAILS
    GOSUB PROCESS.PAYMENT.DETAILS       ;* BG_100013036 - E

*
* BENEFICIARY REF
    YR.MESS(13) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditTheirRef)
*
* SORT CODE
    YR.MESS(14) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BcBankSortCode)
*
* BEN CUSTOMER
    GOSUB PROCESS.BEN.CUSTOMER          ;* BG_100013036 - S

*
* ORDERING CUST
    GOSUB PROCESS.ORDERING.CUSTOMER

*
* ACCT.WITH BANK
    GOSUB PROCESS.ACCT.WITH.BANK        ;* BG_100013036 - E
*
* DEBIT ACCOUNT NO
    YR.MESS(18) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
*
* BANK TO BANK INFO
    YR.MESS(19) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BkToBkInfo)
*
* PAYMENT CODE
    YR.MESS(20) = PAYMENT.CODE
*
* CUST REF (Only for B10)
    IF MAP.KEY = "1210" THEN
        YR.MESS(21) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitTheirRef)
    END
*
* CHARGES ACCT NO
    GOSUB PROCESS.CHARGES.ACCT.NO       ;* BG_100013036 - S / E

*
* ACCT.WITH BANK ACC NO ( Our acct at ACCT.WITH)
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank) THEN
        IF NUM(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank)) THEN     ;* Read the agency record
            GOSUB READ.AGENCY.RECORD    ;* BG_100013036 - S / E
        END
    END
*
** If the message is a C15 the amount must be formatted to either 11
** or 10 in length.  11 if the ben acct no is 9 in length
*
    IF MAP.KEY = "1230" THEN
        IF LEN(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo)) = 9 THEN
            YR.MESS(4) = FMT(YR.MESS(4),"11'0'R")
        END ELSE
            YR.MESS(4) = FMT(YR.MESS(4),"10'0'R")
        END
    END
*
** Handoff the local reference field to allow the local dat to be passed
*
    YR.MESS(27) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)
*
** Call application handoff
*
    MATBUILD YR.DE.MESS FROM YR.MESS
    MAP.KEY := ".FTBC.1"
    DEL.REF = ""
    EB.Display.Txt(PRODUCT.DESC)
    IF FT.Contract.getAutoProcessingInd() NE "Y" THEN
        PRINT @(45,9):FMT(FIELD(MAP.KEY,".",1):".1.1","11L"):PRODUCT.DESC
    END
    DE.API.ApplicationHandoff(YR.DE.MESS, "", "", "", "", "", "" ,"" , "", MAP.KEY, DEL.REF, "")
    EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DeliveryOutref, DEL.REF:"-":FMT(FIELD(MAP.KEY,".",1):".1.1","10L"):" ":PRODUCT.DESC)
*
PGM.EXIT:
    RETURN
*
*------------------------------------------------------------------------
SET.UP.COMMON.DETAILS:
*=====================
** Common details are:
**    OUR BC CODE - Derived from FT.LOCAL.CLEARING using CREDIT.ACCT
**    TXN.REF - ID.NEW
**    VALUE DATE - Debit Value date
**    DEBIT AMOUNT - LOC.AMT.DEBITED
**    CURRENCY - LCCY
**    COMPANY - ID.COMPANY
**    CUS.COMPANY - CUS.COMPANY
**    CUSTOMER - Customer of the CREDIT ACCOUNT ie on LOCAL CLEARING
**    DEPARTMENT - From contract
**    LANGUAGE - From company record
*
    LOCATE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo) IN FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcBrnchNostroBc)<1,1> SETTING BCPOS THEN
    OUR.BC.CODE = FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcBcCode)<1,BCPOS>
    END ELSE
    OUR.BC.CODE = FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcBcCode)<1,1>
    END
*
    YR.MESS(1) = OUR.BC.CODE
    YR.MESS(2) = EB.SystemTables.getIdNew()
    YR.MESS(3) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditValueDate)
    YR.MESS(4) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocAmtCredited)
    YR.MESS(5) = EB.SystemTables.getLccy()
    YR.MESS(6) = EB.SystemTables.getIdCompany()
    YR.MESS(7) = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany)
    IF FT.Contract.getRCreditAcct(AC.AccountOpening.Account.Customer) THEN
        YR.MESS(8) = FT.Contract.getRCreditAcct(AC.AccountOpening.Account.Customer)
    END ELSE        ;* Default is FT LC DEF
        YR.MESS(8) = FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcLocalCustNo)<1,1>
    END
    YR.MESS(9) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DeptCode)
    YR.MESS(10) = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLanguageCode)
*
    RETURN
*
*------------------------------------------------------------------------
* BG_100013036 - S
*====================
PROCESS.BEN.ACCT.NO:
*====================
    BEGIN CASE
        CASE MAP.KEY = "1235"     ;* H70  Reversal
            YR.MESS(25) = EB.SystemTables.getIdNew():"REV"      ;* Unique txn ref
            YR.MESS(26) = ORIG.PRODUCT.DESC[1,3]      ;* Orig msg
            *
            ** Set up field 98 the reversal info. Pass the authoriser and the text.
            *
            YR.MESS(28) = FIELD(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.Authoriser),"_",2):"#"
            YREV.TEXT = FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcRevText)<1,EB.SystemTables.getRUser()<EB.Security.User.UseLanguage>>
            YR.MESS(28) := YREV.TEXT
        CASE MAP.KEY = "1210"     ;* Ben acct no
        CASE MAP.KEY = "1220"     ;* Addressee or Ben
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank) THEN
                YR.MESS(25) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo)
            END ELSE
                YR.MESS(11) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo)
            END
        CASE 1
            IF MAP.KEY EQ "1230" THEN
                YR.MESS(11) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo)
            END ELSE
                IF MEM.ACCT.CODE = "O" THEN
                    XFLD = "A>"
                END ELSE
                    XFLD = "B>"
                END
                YR.MESS(11) = XFLD:EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo)
            END
    END CASE
    RETURN
*------------------------------------------------------------------------
*=======================
PROCESS.PAYMENT.DETAILS:
*=======================
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.PaymentDetails) THEN
        IF MAP.KEY NE "1220" THEN
            YR.MESS(12) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.PaymentDetails)
        END ELSE    ;* Prefix with "c" or "d" tag
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo) THEN
                YR.MESS(12) = "C>":EB.SystemTables.getRNew(FT.Contract.FundsTransfer.PaymentDetails)
            END ELSE          ;* Money order
                YR.MESS(12) = "D>":EB.SystemTables.getRNew(FT.Contract.FundsTransfer.PaymentDetails)
            END
        END
    END
*--------------------------------------------------------------------------
*====================
PROCESS.BEN.CUSTOMER:
*====================
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenCustomer) THEN
        BEGIN CASE
            CASE MAP.KEY NE "1220"
                YR.MESS(15) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenCustomer)
            CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo)
                YR.MESS(15) = "C>":EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenCustomer)
            CASE 1      ;* PTT money order
                YR.MESS(15) = "D>":EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenCustomer)
                AVC = COUNT(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenCustomer),@VM) + (EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenCustomer) NE "")
                IF AVC GT 1 THEN
                    YR.MESS(15)<1,2> = YR.MESS(15)<1,2>:@VM      ;* Field 3 must be blank
                END
        END CASE
    END ELSE
        YR.MESS(15) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenBank)
    END
    RETURN
*--------------------------------------------------------------------------
*==========================
PROCESS.ORDERING.CUSTOMER:
*==========================
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingCust) THEN
        YR.MESS(16) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingCust)
    END ELSE
        YR.MESS(16) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingBank)
    END
    RETURN
*--------------------------------------------------------------------------
*=======================
PROCESS.ACCT.WITH.BANK:
*=======================
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank) THEN
        BEGIN CASE
            CASE MAP.KEY NE "1220"
                YR.MESS(17) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank)
            CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo)
                YR.MESS(17) = "C>":EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank)
            CASE 1      ;* PTT money order
                YR.MESS(17) = "D>":EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank)
        END CASE
    END
    RETURN
*--------------------------------------------------------------------------
*=======================
PROCESS.CHARGES.ACCT.NO:
*=======================
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocPosChgsAmt) THEN
        BEGIN CASE
            CASE MAP.KEY = "1230" ;* No charges on C15
            CASE MAP.KEY = "1220" AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo)     ;* No charges on normal C10
            CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargesAcctNo)
                YR.MESS(22) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargesAcctNo)
                YR.MESS(23) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocPosChgsAmt)
            CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CommissionCode)[1,1] = "D" OR EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargeCode)[1,1] = "D"
                YR.MESS(22) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
                YR.MESS(23) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocPosChgsAmt)
            CASE 1
                YR.MESS(22) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo)
                YR.MESS(23) = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocPosChgsAmt)
        END CASE
        *
    END ELSE
        *
        RETURN
        *--------------------------------------------------------------------------
        *==================
READ.AGENCY.RECORD:
        *==================
        R.AGENT = ""; YERR = ""
        tmp.R.NEW.FT.Contract.FundsTransfer.AcctWithBank = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank)
        R.AGENT = ST.Config.Agency.Read(tmp.R.NEW.FT.Contract.FundsTransfer.AcctWithBank, YERR)
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.AcctWithBank, tmp.R.NEW.FT.Contract.FundsTransfer.AcctWithBank)
        YEND = ""; YCNT = 1
        LOOP
            YID.ACCT = R.AGENT<ST.Config.Agency.EbAgNostroAcctNo,YCNT>
        UNTIL YID.ACCT = "" OR YEND
            YID.CCY = ""

            R.REC = ""
            ER = ""
            R.REC = AC.AccountOpening.Account.Read(YID.ACCT, ER)
            YID.CCY = R.REC<AC.AccountOpening.Account.Currency>
            IF YID.CCY = EB.SystemTables.getLccy() THEN      ;* Take the first local acct  found
                YR.MESS(24) = R.AGENT<ST.Config.Agency.EbAgOurExtAcctNo,YCNT>
                YEND = 1
            END     ;* Otherwise try the next
            YCNT += 1
        REPEAT
        RETURN      ;* BG_100013036 - E
        *--------------------------------------------------------------------------
    END
