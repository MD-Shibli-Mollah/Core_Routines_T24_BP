* @ValidationCode : MjotOTQ2NDA5MjEzOkNwMTI1MjoxNTg0MDE1ODk0NzE1OnJ2YXJhZGhhcmFqYW46LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 12 Mar 2020 17:54:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


* Version 10 29/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>6748</Rating>
*-----------------------------------------------------------------------------
$PACKAGE FT.Clearing
SUBROUTINE FT.SIC.CROSSVAL(CURR.NO)
*
** This routine will crossvalidate fields used in the BC transactions
** for Switzerland, specifically SIC system. Fields cross-validated
** are:
**    ORDERING.CUST
**    ORDERING.BANK
**    BEN.CUST
**    BEN.BANK
**    BEN.ACCT.NO
**    ACCT.WITH.BANK
**    LOCAL.REF (PAYMENT.CODE)
**    DEBIT.ACCT.NO
**
**  07/04/92 - GB9200199
**             Merge Hypo pifs HY9200698, HY9200642,
**             HY9200581, HY9200570, HY9100420, HY9100337.
**             Allow cheque number processing, foreign acct
**             debit, PTT tapes, and don't allow both
**             DEBIT PLUS CHARGES and CREDIT LESS CHARGES to
**             be set up together for BC txns.
**
**  16/03/92 - HY9200698
**             Allow the CHEQUE NUMBER field to be used in BC Txns
**             But not PTT transactions
**
** 09/06/92 - GB9200522
**            Allow DEBIT PLUS CHARGES with a non numeric DEBIT acct
**            providing a charge account has been entered. This is for
**            BULK ORDERS so that charges can be taken to the main
**            account
*
** 11/08/92 - GB9200790
**            The CHARGES.ACCT.NO should only be defaulted if the
**            CUSTOMER or GROUP condition has a SEPARATE entry specified
*
** 06/04/93 - GB9300344
**            Get the charge account from CUSTOMER CHARGE if set up.
**            FT.CUST.CONDITION no longer exists
**
** 26/-3/93 - GB9301214
**            Allow charges on PTT transactions, give an override instead
**
** 16/11/99 - GB9901601
**            Replace hard coded override messages with their key to the
**            override message file.
*
* 20/09/02 - GLOBUS_EN_10001180
*          Conversion Of all Error Messages to Error Codes
*
* 20/08/03 - CI_10011722
*            BEN.CUSTOMER is not mandatory when payment type is C15.
*
* 18/11/03 - CI_10014913
*            REF: HD0314866
*            INSERT and OPF of FT.CUSTOMER.CONDITION is removed, since
*            the pgm is made obsolete.
*
* 12/01/09 - BG_100021536
*            Error while uploading FT script, when FT.LOCAL.CLEARING set to SIC.
*            PAYMENT.CODE should be taken from LOCAL reference only when its position is
*            defined in the field FT.LC.PAY.CODE.LOC of FT.LOCAL.CLEARING.
*
* 20/07/10 - Task 66080
*            Change the reads to Customer to use the Customer
*            Service api calls
*
* 16/03/15 - Enhancement 1265068/ Task 1265069
*          - Initialising DIM array size within the routine and removing from insert to support componentisation
*
* 17/08/15 - Enhancement 1265068/ Task 1387507
*          - Routine incorporated
*
* 03/02/20 -   Enhancement 3568228  / Task 3568259
*            Changing reference of routines that have been moved from ST to CG
*************************************************************************************
*
    $USING AC.AccountOpening
    $USING CG.ChargeConfig
    $USING FT.Clearing
    $USING FT.Contract
    $USING FT.Config
    $USING ST.Config
    $USING EB.ErrorProcessing
    $USING AC.Config
    $USING EB.OverrideProcessing
    $USING ST.ExchangeRate
    $USING EB.SystemTables

    $INSERT I_CustomerService_NameAddress
*
** PAYMENT CODE is taken from LOCAL.REFERENCE. The position of which
** is held in FTLC$LOCAL.CLEARING(FT.LC.PAY.CODE.LOC)

    IF FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcPayCodeLoc) THEN
        PAYMENT.CODE = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)<1,FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcPayCodeLoc)>
    END ELSE
        PAYMENT.CODE = ""
    END
*
** determine if this is a PTT Transaction. Check BC code against PTT code
*
    PTT.TRANSACTION = "" ; PTT.TYPE = ""
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BcBankSortCode) THEN
        LOCATE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BcBankSortCode) IN FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcPttSortCode)<1,1> SETTING PTT.TRANSACTION ELSE PTT.TRANSACTION = ""
*
** Also check to see if the sort code is one the banks own
*
        LOCATE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BcBankSortCode) IN FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcBcCode)<1,1> SETTING X THEN
**
** In this case switch the transaction to a AC
**
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.InwardPayType) = "" THEN
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.TransactionType, "AC")
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAcctNo, EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo))
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.BenCustomer, "")
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.BenAcctNo, "")
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.AcctWithBank, "")
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.BcBankSortCode, "")
                FT.Contract.Crossval(CURR.NO,CR.NOSTRO.ACCT,DR.NOSTRO.ACCT)
                RETURN
            END
        END ELSE NULL
    END
*
    IF NOT(PAYMENT.CODE) THEN ;* Default
        GOSUB DEFAULT.ORDERING.PARTY
    END
*
    BEGIN CASE
        CASE PAYMENT.CODE         ;* Only for covers (B10)
*
** Payment code only allowed when DEBIT.ACCT is an internal account
** ie LCLSUSP acct or account of a bank
** No charges / commissions allowed
*
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingCust) THEN ;* Not allowed
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.OrderingCust); EB.SystemTables.setAv(1)
                EB.SystemTables.setEtext("FT.FTSC.NOT.ALLOWED,PAYMENT.CODE.PRESENT")
                EB.ErrorProcessing.StoreEndError()
            END
*
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingBank) THEN ;* Not allowed
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.OrderingBank); EB.SystemTables.setAv(1)
                EB.SystemTables.setEtext("FT.FTSC.NOT.ALLOWED,PAYMENT.CODE.PRESENT")
                EB.ErrorProcessing.StoreEndError()
            END
*
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo) THEN
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenAcctNo); EB.SystemTables.setAv("")
                EB.SystemTables.setEtext("FT.FTSC.NOT.ALLOWED,PAYMENT.CODE.PRESENT")
                EB.ErrorProcessing.StoreEndError()
            END
*
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenCustomer) THEN  ;* Not allowed
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenCustomer); EB.SystemTables.setAv(1)
                EB.SystemTables.setEtext("FT.FTSC.NOT.ALLOWED,PAYMENT.CODE.PRESENT")
                EB.ErrorProcessing.StoreEndError()
            END
*
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenBank) THEN      ;* Not allowed
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenBank); EB.SystemTables.setAv(1)
                EB.SystemTables.setEtext("FT.FTSC.NOT.ALLOWED,PAYMENT.CODE.PRESENT")
                EB.ErrorProcessing.StoreEndError()
            END
*
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank) THEN          ;* Not allowed
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.AcctWithBank); EB.SystemTables.setAv(1)
                EB.SystemTables.setEtext("FT.FTSC.NOT.ALLOWED,PAYMENT.CODE.PRESENT")
                EB.ErrorProcessing.StoreEndError()
            END
*
            IF NOT(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditTheirRef)) AND NOT(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitTheirRef)) THEN
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.CreditTheirRef); EB.SystemTables.setAv("")
                EB.SystemTables.setEtext("FT.FTSC.DR.OR.CR.REF.MAND")
                EB.ErrorProcessing.StoreEndError()
                EB.SystemTables.setEtext("FT.FTSC.DR.OR.CR.REF.MAND")
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.DebitTheirRef); EB.ErrorProcessing.StoreEndError()
            END
*
** For payment codes ending in a 1 the beneficiary reference is mandatory
*
            IF PAYMENT.CODE[1] = "1" AND NOT(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditTheirRef)) THEN
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.CreditTheirRef); EB.SystemTables.setAv("")
                EB.SystemTables.setEtext("FT.FTSC.CR.REF.REQUIRED.PAYMENT.CODE")
                EB.ErrorProcessing.StoreEndError()
            END
*
            GOSUB VALIDATE.CREDIT.REF
*
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.PaymentDetails) THEN
                EB.SystemTables.setEtext("FT.FTSC.NOT.ALLOWED.,.PAYMENT.CODE.PRESENT")
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.PaymentDetails); EB.SystemTables.setAv(1); EB.ErrorProcessing.StoreEndError()
            END
*
            IF PTT.TRANSACTION THEN
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.BcBankSortCode); EB.SystemTables.setAv("")
                EB.SystemTables.setEtext("FT.FTSC.PTT.CODE.INVALID.WITH.PAYMENT.CODE")
                EB.ErrorProcessing.StoreEndError()
            END
*
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargesAcctNo) THEN
                EB.SystemTables.setEtext("FT.FTSC.NOT.ALLOWED.COVER.PAYMENT"); EB.SystemTables.setAv("")
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.ChargesAcctNo); EB.ErrorProcessing.StoreEndError()
            END
*
            GOSUB DEFAULT.WAIVE.CHARGES
*
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CommissionCode)[1,1] NE "W" THEN
                EB.SystemTables.setEtext("FT.FTSC.WAIVE.COVER.PAYMENT")
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.CommissionCode); EB.ErrorProcessing.StoreEndError()
            END
*
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargeCode)[1,1] NE "W" THEN
                EB.SystemTables.setEtext("FT.FTSC.WAIVE.COVER.PAYMENT")
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.ChargeCode); EB.ErrorProcessing.StoreEndError()
            END
*
            FOR AF.CNT = FT.Contract.FundsTransfer.CommissionType TO FT.Contract.FundsTransfer.CommissionAmt
                EB.SystemTables.setAf(AF.CNT)
                AVC = COUNT(EB.SystemTables.getRNew(AF.CNT),@VM)+(EB.SystemTables.getRNew(AF.CNT) NE "")
                FOR AV.CNT = 1 TO AVC
                    EB.SystemTables.setAv(AV.CNT)
                    IF EB.SystemTables.getRNew(AF.CNT)<1,AV.CNT> THEN
                        EB.SystemTables.setEtext("FT.FTSC.NO.COMMISSION.ALLOWED"); EB.ErrorProcessing.StoreEndError()
                    END
                NEXT AV.CNT
            NEXT AF.CNT
*
            FOR AF.CNT1 = FT.Contract.FundsTransfer.ChargeType TO FT.Contract.FundsTransfer.ChargeAmt
                EB.SystemTables.setAf(AF.CNT1)
                AVC = COUNT(EB.SystemTables.getRNew(AF.CNT1),@VM)+(EB.SystemTables.getRNew(AF.CNT1) NE "")
                FOR AV.CNT1 = 1 TO AVC
                    EB.SystemTables.setAv(AV.CNT1)
                    IF EB.SystemTables.getRNew(AF.CNT1)<1,AV.CNT1> THEN
                        EB.SystemTables.setEtext("FT.FTSC.NO.CHARGES.ALLOWED"); EB.ErrorProcessing.StoreEndError()
                    END
                NEXT AV.CNT1
            NEXT AF.CNT1
*
** HY9100169 Give an override if there is a customer account
*
            IF NUM(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)) THEN
*
** Check that customer is a bank
*
                PRETURN.CODE = ""
                CUST.ID = FT.Contract.getRDebitAcct(AC.AccountOpening.Account.Customer)
                AC.Config.CheckAccountClass("BANK", "", CUST.ID, "", PRETURN.CODE)
                EB.SystemTables.setEtext("")
                IF PRETURN.CODE NE "YES" THEN         ;* Not a bank
                    tmp.END.ERROR = EB.SystemTables.getEndError()
                    IF NOT(tmp.END.ERROR) THEN
                        EB.SystemTables.setAf(FT.Contract.FundsTransfer.DebitAcctNo); EB.SystemTables.setAv("")
                        EB.SystemTables.setText('NOT.BANK')
                        EB.OverrideProcessing.StoreOverride(CURR.NO)
                        IF EB.SystemTables.getText() = "NO" THEN
                            EB.SystemTables.setEtext("FT.FTSC.AC.CU.NOT.BANK")
                        END
                    END
                END
            END
*
*
        CASE PTT.TRANSACTION      ;* C10 or C15 payment
*
** Need to decide here if we are processing a C10 or C15. C15 does not
** contain a beneficiary customer or payment details, but ben acct and
** ben reference are mandatory.
*
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditTheirRef) THEN        ;* Assume C15
                PTT.TYPE = "C15"
            END ELSE
                IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo) = "" THEN    ;* Money order
                    PTT.TYPE = "C10M"
                END ELSE          ;* Normal type
                    PTT.TYPE = "C10"
                END
            END
*
            GOSUB VAL.ORDERING.PARTY
*
            FOR AF.CNT2 = FT.Contract.FundsTransfer.OrderingCust TO FT.Contract.FundsTransfer.OrderingBank STEP 2
                EB.SystemTables.setAf(AF.CNT2)
                IF PTT.TYPE[1,3] = "C10" THEN
                    MAX.LENGTH = 30
                    GOSUB C10.LENGTH.VALIDATION
                END
            NEXT AF.CNT2
*
            EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenCustomer)
            IF EB.SystemTables.getRNew(FT.BEN.CUSTOME) = "" AND PTT.TYPE[1,3] NE "C15" THEN   ;* CI_10011722 S/E
                EB.SystemTables.setAv(1)
                EB.SystemTables.setEtext("FT.FTSC.INP.MISS")
                EB.ErrorProcessing.StoreEndError()
            END ELSE
                IF PTT.TYPE[1,3] = "C10" THEN
                    MAX.LENGTH = 30
                    GOSUB C10.LENGTH.VALIDATION
*
                    IF PTT.TYPE = "C10M" THEN         ;* Mandatory 3 lines
                        tmp.AF = EB.SystemTables.getAf()
                        NO.LINES = COUNT(EB.SystemTables.getRNew(tmp.AF),@VM) + (EB.SystemTables.getRNew(FT.BEN.CUSTOME) NE "")
                        IF NO.LINES NE 3 AND NOT(EB.SystemTables.getRNew(FT.BEN.CUSTOME) MATCHES "1N0N" AND LEN(EB.SystemTables.getRNew(FT.BEN.CUSTOME)) LE 6) THEN
                            EB.SystemTables.setEtext("FT.FTSC.3.LINES.OR.CUST.NO.REQUIRED.MONEY.ORDER")
                            EB.SystemTables.setAv(1); EB.ErrorProcessing.StoreEndError()
                        END
                    END
*
                END
            END
*
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenBank) THEN
                EB.SystemTables.setEtext("FT.FTSC.INVALID.FLD.PTT.TRANSACTION"); EB.SystemTables.setAv(1)
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenBank); EB.ErrorProcessing.StoreEndError()
            END
*
            EB.SystemTables.setAf(FT.Contract.FundsTransfer.AcctWithBank)
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank) THEN
                IF PTT.TYPE = "C15" THEN    ;* Not allowed for C15
                    EB.SystemTables.setEtext("FT.FTSC.INVALID.FLD.PTT.TRANSACTION"); EB.SystemTables.setAv(1)
                    EB.ErrorProcessing.StoreEndError()
                END ELSE
                    MAX.LENGTH = 30
                    GOSUB C10.LENGTH.VALIDATION
                END
            END
*
            EB.SystemTables.setAv(""); EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenAcctNo)
            BEGIN CASE
                CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo) = ""
                    IF PTT.TYPE = "C15" THEN
                        EB.SystemTables.setEtext("FT.FTSC.MAND.INP.VESR.TRANSACTION")
                        EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenAcctNo); EB.ErrorProcessing.StoreEndError()
                    END
                CASE LEN(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo)) GT 9
                    EB.SystemTables.setEtext("FT.FTSC.MAX.LENGTH.9.PTT.TRANSACTION")
                    EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenAcctNo); EB.ErrorProcessing.StoreEndError()
                CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo) MATCHES "9N"     ;* okay
                    GOSUB MOD10.CHECK
                CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo) MATCHES "5N" AND PTT.TYPE = "C15"
                    GOSUB MOD10.CHECK
                CASE 1
                    IF PTT.TYPE = "C15" THEN
                        EB.SystemTables.setEtext("FT.FTSC.NUMERIC")
                    END ELSE
                        EB.SystemTables.setEtext("FT.FTSC.LENGTH.9.PTT.TRANSACTION")
                    END
                    EB.ErrorProcessing.StoreEndError()
            END CASE
*
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChequeNumber) THEN
                EB.SystemTables.setEtext("FT.FTSC.NOT.ALLOWED.PTT.TRANSACTION"); EB.SystemTables.setAv("")
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.ChequeNumber); EB.ErrorProcessing.StoreEndError()
            END
*
            EB.SystemTables.setAv(1)
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BkToBkInfo) THEN
                EB.SystemTables.setEtext("FT.FTSC.NOT.ALLOWED.PTT.TRANSACTION"); EB.SystemTables.setAv(1)
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.BkToBkInfo); EB.ErrorProcessing.StoreEndError()
            END
*
            IF PTT.TYPE NE "C10M" THEN      ;* No Charges
*
                GOSUB DEFAULT.WAIVE.CHARGES
*
                GOSUB VALIDATE.CHARGES
*
            END ELSE
*
** Default to DEBIT PLUS CHARGES if not entered
** Charges are mandatory
*
                GOSUB VALIDATE.CHARGES
*
                IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CommissionType) = "" AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargeType) = "" THEN
                    EB.SystemTables.setAv(1)
                    IF FT.Contract.getRTxnType(FT.Config.TxnTypeCondition.FtSixCommTypes) = "" AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CommissionCode)[1,1] NE "W" THEN
                        EB.SystemTables.setEtext("FT.FTSC.CHARGES.MAND.PTT.MONEY.ORDER")
                        EB.SystemTables.setAf(FT.Contract.FundsTransfer.CommissionType); EB.ErrorProcessing.StoreEndError()
                        FT.Contract.setChargeError(1)
                    END
                    IF FT.Contract.getRTxnType(FT.Config.TxnTypeCondition.FtSixChargeTypes) = "" AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargeCode)[1,1] NE "W" THEN
                        EB.SystemTables.setEtext("FT.FTSC.CHARGES.MAND.PTT.MONEY.ORDER")
                        EB.SystemTables.setAf(FT.Contract.FundsTransfer.ChargeType); EB.ErrorProcessing.StoreEndError()
                        FT.Contract.setChargeError(1)
                    END
                END
*
            END
*
            EB.SystemTables.setAv(""); EB.SystemTables.setAf(FT.Contract.FundsTransfer.CreditTheirRef)
            IF PTT.TYPE[1,3] = "C10" THEN
                IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditTheirRef) THEN
                    EB.SystemTables.setEtext("FT.FTSC.BENEFICIARY.REF.ONLY.ALLOWED.VESR.TXNS")
                    EB.ErrorProcessing.StoreEndError()
                END
            END ELSE
                IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditTheirRef) = "" THEN
                    EB.SystemTables.setEtext("FT.FTSC.MAND.BEN.REF.VESR.TRANSACTION")
                    EB.ErrorProcessing.StoreEndError()
                END
            END
*
            EB.SystemTables.setAv(1); EB.SystemTables.setAf(FT.Contract.FundsTransfer.PaymentDetails)
            BEGIN CASE
                CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.PaymentDetails) AND PTT.TYPE = "C15"
                    EB.SystemTables.setEtext("FT.FTSC.NOT.ALLOWED.VESR.TRANSACTION")
                    EB.ErrorProcessing.StoreEndError()
                CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.PaymentDetails) AND PTT.TYPE[1,3] = "C10"
                    MAX.LENGTH = 28
                    GOSUB C10.LENGTH.VALIDATION
                CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.PaymentDetails) = ""   ;* Mandatory when no Ben acct
***!                  IF PTT.TYPE = "C10M" THEN
***!                     ETEXT = "MANDATORY FOR PTT MONEY ORDER"
***!                     CALL STORE.END.ERROR
***!                  END
            END CASE
*
** Check the length of beneficiary account against the reference
*
            IF PTT.TYPE = "C15" THEN
                IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo) THEN
                    BEGIN CASE
                        CASE LEN(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo)) = 9
                            IF NOT(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditTheirRef) MATCHES "16N":@VM:"27N") THEN
                                EB.SystemTables.setEtext("FT.FTSC.16.OR.27.NUMERIC.WITH.9.DIGIT.BEN.ACCT")
                                EB.SystemTables.setAf(FT.Contract.FundsTransfer.CreditTheirRef); EB.ErrorProcessing.StoreEndError()
                            END ELSE  ;* Checkdigit on ref no
                                EB.SystemTables.setAf(FT.Contract.FundsTransfer.CreditTheirRef); EB.SystemTables.setAv("")
                                GOSUB MOD10.CHECK
                            END
                        CASE LEN(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo)) = 5
                            IF NOT(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditTheirRef) MATCHES "15N") THEN
                                EB.SystemTables.setEtext("FT.FTSC.15.NUMERIC.WITH.5.DIGIT.BEN.ACCT")
                                EB.SystemTables.setAf(FT.Contract.FundsTransfer.CreditTheirRef); EB.ErrorProcessing.StoreEndError()
                            END
                        CASE 1
                            EB.SystemTables.setEtext("FT.FTSC.9.OR.5.LENGTH.VESR.TRANSACTION")
                            EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenAcctNo); EB.ErrorProcessing.StoreEndError()
                    END CASE
                END
            END
*
** Overrides
*
            tmp.END.ERROR = EB.SystemTables.getEndError()
            IF NOT(tmp.END.ERROR) THEN
*
** There is a maximum allowed for PTT transactions defined on the local
** clearing file. Give override if this is exceeded
** If the amount is in foreign currency then convert the PTT.MAX.AMOUNT
** at MID.rate into the other currency for comparison.
*
                YAMT = "" ; YCCY = ""
                YAMT = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAmount) ; YCCY = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitCurrency)
                IF YAMT = "" THEN
                    YAMT = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAmount) ; YCCY = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditCurrency)
                END
*
                YPTT.MAX = ""
                IF YCCY NE EB.SystemTables.getLccy() THEN        ;* Convert max to fccy
                    YMKT = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CurrencyMktDr)  ;* Both must be same lccy involved
                    YLAMT = FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcPttMaxAmount)
                    ST.ExchangeRate.MiddleRateConvCheck( YPTT.MAX, YCCY, "", YMKT, YLAMT, "", "")
                    IF EB.SystemTables.getEtext() THEN
                        EB.SystemTables.setAf(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitCurrency)); EB.ErrorProcessing.StoreEndError()
                    END
                END ELSE
                    YPTT.MAX = FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcPttMaxAmount)
                END
*
                IF YAMT GT YPTT.MAX THEN
                    EB.SystemTables.setAv("")
                    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAmount) THEN
                        EB.SystemTables.setAf(FT.Contract.FundsTransfer.DebitAmount)
                    END ELSE
                        EB.SystemTables.setAf(FT.Contract.FundsTransfer.CreditAmount)
                    END
                    EB.SystemTables.setText("MXM.AMT":@FM:YPTT.MAX:@VM:YCCY)
                    EB.OverrideProcessing.StoreOverride(CURR.NO)
                    IF EB.SystemTables.getText() = "NO" THEN
                        EB.SystemTables.setEtext("FT.FTSC.MAX.AMT.PTT.TXN":@FM:YPTT.MAX:@VM:YCCY)
                    END
                END
*
** No bank fields can be used, no charges are allowed except for
** C10 money orders where they are mandatory
*
                EB.SystemTables.setAv(""); EB.SystemTables.setAf(FT.Contract.FundsTransfer.DebitAcctNo)
                IF EB.SystemTables.getText() NE "NO" THEN
                    IF NUM(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)) THEN  ;* Only cust acct
                        IF FT.Contract.getRDebitAcct(AC.AccountOpening.Account.LimitRef) = "NOSTRO" THEN
                            EB.SystemTables.setText("NOSTRO.ACCT")
                            EB.OverrideProcessing.StoreOverride(CURR.NO)
                            IF EB.SystemTables.getText() = "NO" THEN
                                EB.SystemTables.setEtext("FT.FTSC.DR.AC.NOS.PTT.TRANSACTION")
                            END
                        END
                    END
                END
*
** Give an override if charges are speicified for a PTT transaction
*
                IF EB.SystemTables.getText() NE "NO" THEN
                    IF PTT.TYPE NE "C10M" THEN
                        FOR AF.CNT3 = FT.Contract.FundsTransfer.CommissionType TO FT.Contract.FundsTransfer.ChargeType STEP 3
                            EB.SystemTables.setAf(AF.CNT3)
                            IF EB.SystemTables.getRNew(AF.CNT3)<1,1> THEN
                                EB.SystemTables.setText("COMM.CHG.FOR.TXN")
                                EB.SystemTables.setAv(1); EB.SystemTables.setAs("")
                                EB.OverrideProcessing.StoreOverride(CURR.NO)
                                IF EB.SystemTables.getText() = "NO" THEN
                                    EB.SystemTables.setEtext("FT.FTSC.COMMISSION.CHARGE.SPECIFIED.PTT.TRANSCATION")
                                    EB.SystemTables.setAf(FT.Contract.FundsTransfer.ChargeType)
                                END
                            END
                        NEXT AF.CNT3
                    END
                END
*
            END
*
        CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank)       ;* A11 payment
*
            GOSUB VAL.ORDERING.PARTY
*
            GOSUB VALIDATE.BEN.ACCT
*
            GOSUB VALIDATE.CREDIT.REF
*
            GOSUB VALIDATE.CHARGES
*
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenCustomer) = "" AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenBank) = "" THEN
                EB.SystemTables.setEtext("FT.FTSC.INP.EITHER.BEN.CUST.OR.BANK"); EB.SystemTables.setAv(1)
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenCustomer); EB.ErrorProcessing.StoreEndError()
                EB.SystemTables.setEtext("FT.FTSC.INP.EITHER.BEN.CUST.OR.BANK")
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenBank); EB.ErrorProcessing.StoreEndError()
            END
*
** check that the ACCT.WITH.BANK is not the same as the ordering or
** BEN.BANK or customer.
*
            EB.SystemTables.setAf(FT.Contract.FundsTransfer.AcctWithBank); EB.SystemTables.setAv(1)
            IF NUM(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank)) AND LEN(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank)) LE 10 THEN
                IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank) MATCHES EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingCust):@VM:EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingBank) THEN
                    EB.SystemTables.setEtext("FT.FTSC.CANT.SAME.ORDERING.PARTY"); EB.ErrorProcessing.StoreEndError()
                END
                IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.AcctWithBank) MATCHES EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenBank):@VM:EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenCustomer) THEN
                    EB.SystemTables.setEtext("FT.FTSC.CANT.SAME.BENEFICIARY"); EB.ErrorProcessing.StoreEndError()
                END
            END
*
        CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingBank) AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenBank)     ;* B11 Payment
*
            GOSUB VAL.ORDERING.PARTY
*
            GOSUB VALIDATE.BEN.ACCT
*
            GOSUB VALIDATE.CREDIT.REF
*
            GOSUB VALIDATE.CHARGES
*
        CASE 1          ;* A10 Standard payment
*
** No charges to be taken for simple customertransfers
*
            GOSUB VAL.ORDERING.PARTY
*
            GOSUB VALIDATE.BEN.ACCT
*
            GOSUB VALIDATE.CREDIT.REF
*
            GOSUB DEFAULT.WAIVE.CHARGES     ;* Default to waive
*
** Don't force charges to be null, this will become an A11 if they are
** input.
** Similarly allow BK.TO.BK.INFO to be input. If present this will also
** become an A11.
*
            GOSUB VALIDATE.CHARGES
*
            EB.SystemTables.setAv(1)
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenCustomer) = "" AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenBank) = "" THEN
                EB.SystemTables.setEtext("FT.FTSC.INP.EITHER.BEN.CUST.OR.BANK"); EB.SystemTables.setAv(1)
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenCustomer); EB.ErrorProcessing.StoreEndError()
                EB.SystemTables.setEtext("FT.FTSC.INP.EITHER.BEN.CUST.OR.BANK")
                EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenBank); EB.ErrorProcessing.StoreEndError()
            END
*
    END CASE
*
RETURN
*
*------------------------------------------------------------------------
* S U B R O U T I N E S
*------------------------------------------------------------------------
VAL.ORDERING.PARTY:
*==================
** For all transactions except B10 either ordering cust or bank must be
** present.
**
*
    BEGIN CASE      ;* Validation
        CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingBank) AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingCust)
            EB.SystemTables.setEtext("FT.FTSC.BOTH.ORD.BANK.CUST.INP"); EB.SystemTables.setAv(1)
            EB.SystemTables.setAf(FT.Contract.FundsTransfer.OrderingCust); EB.ErrorProcessing.StoreEndError()
            EB.SystemTables.setEtext("FT.FTSC.BOTH.ORD.BANK.CUST.INP")
            EB.SystemTables.setAf(FT.Contract.FundsTransfer.OrderingBank); EB.ErrorProcessing.StoreEndError()
        CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingCust) = "" AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingBank) = ""
            EB.SystemTables.setEtext("FT.FTSC.EITHER.ORD.BANK.OR.CUST.INP"); EB.SystemTables.setAv(1)
            EB.SystemTables.setAf(FT.Contract.FundsTransfer.OrderingCust); EB.ErrorProcessing.StoreEndError()
            EB.SystemTables.setEtext("FT.FTSC.EITHER.ORD.BANK.OR.CUST.INP")
            EB.SystemTables.setAf(FT.Contract.FundsTransfer.OrderingBank); EB.ErrorProcessing.StoreEndError()
    END CASE
*
RETURN
*
*------------------------------------------------------------------------
VALIDATE.BEN.ACCT:
*=================
** This validation is used for A10, A11 and B11 messages to check that
** the beneficiary account is numeric. There should may need to be a
** check at a later date to see if the account number already exists
** in the bank - if so it should be blocked as an AC should be used
** instead.
*
    EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenAcctNo); EB.SystemTables.setAv("")
    BEGIN CASE
        CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo) = ""
        CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo) MATCHES "1N0N"
        CASE 1
***!            ETEXT = "MUST BE NUMERIC"
***!            CALL STORE.END.ERROR
    END CASE
*
RETURN
*
*------------------------------------------------------------------------
DEFAULT.ORDERING.PARTY:
*======================
** Default the ordering party if there is no payment code
*
    IF NOT(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingBank)) AND NOT(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingCust)) THEN
        IF NUM(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)) THEN
            YENRI = ""        ;* Get the enrichment
            customerKey = FT.Contract.getRDebitAcct(AC.AccountOpening.Account.Customer)
            customerNameAddress = ''
            prefLang = EB.SystemTables.getLngg()
            CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
            YENRI = customerNameAddress<NameAddress.shortName>
            PRETURN.CODE = ""
            CUST.ID = FT.Contract.getRDebitAcct(AC.AccountOpening.Account.Customer)
            AC.Config.CheckAccountClass("BANK", "", CUST.ID , "", PRETURN.CODE)
            IF PRETURN.CODE NE "YES" THEN         ;* Not a bank
                YFLD = FT.Contract.FundsTransfer.OrderingCust
            END ELSE          ;* Default into Bank field
                YFLD = FT.Contract.FundsTransfer.OrderingBank
            END
            EB.SystemTables.setEtext("")
            EB.SystemTables.setRNew(YFLD, FT.Contract.getRDebitAcct(AC.AccountOpening.Account.Customer))
            LOCATE YFLD:".1" IN EB.SystemTables.getTFieldno()<1> SETTING YPOS THEN
                tmp=EB.SystemTables.getTEnri(); tmp<YPOS>=YENRI; EB.SystemTables.setTEnri(tmp)
            END
        END
    END
*
RETURN
*
*------------------------------------------------------------------------
DEFAULT.WAIVE.CHARGES:
*=====================
*
** Default the commission & charges codes to WAIVE
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CommissionCode) = "" THEN
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CommissionCode, "WAIVE")
    END
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargeCode) = "" THEN
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ChargeCode, "WAIVE")
    END
*
RETURN
*
*------------------------------------------------------------------------
VALIDATE.CHARGES:
*================
** Validate any charges present. This is only allowed for B11 and A11
** transactions
** First default the COMMISSION and CHARGE codes and validate
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CommissionCode) = "" THEN        ;* Default is DEBIT PLUS CHARGES
        BEGIN CASE
            CASE PTT.TYPE = "C10M"          ;* Default DEBIT
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CommissionCode, "DEBIT PLUS CHARGES")
            CASE FT.Contract.getRTxnType(FT.Config.TxnTypeCondition.FtSixCommTypes) = ""      ;* No comm defined
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CommissionCode, "WAIVE")
            CASE NOT(NUM(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)))
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CommissionCode, "WAIVE");* Internal account
            CASE 1
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CommissionCode, "DEBIT PLUS CHARGES")
        END CASE
    END
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargeCode) = "" THEN  ;* Default is DEBIT PLUS CHARGES
        BEGIN CASE
            CASE PTT.TYPE = "C10M"          ;* Default DEBIT
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ChargeCode, "DEBIT PLUS CHARGES")
            CASE FT.Contract.getRTxnType(FT.Config.TxnTypeCondition.FtSixChargeTypes) = ""    ;* No comm defined
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ChargeCode, "WAIVE")
            CASE NOT(NUM(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)))
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ChargeCode, "WAIVE");* Internal account
            CASE 1
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ChargeCode, "DEBIT PLUS CHARGES")
        END CASE
    END
*
** Same validation for commission and charges
*
    IF PTT.TYPE = "C10M" AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CommissionCode)[1,1] = "W" AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargeCode)[1,1] = "W" THEN
        FT.Contract.setChargeError(1);* Dont reset fields
        EB.SystemTables.setEtext("FT.FTSC.CHARGES.MAND.PTT.MONEY.ORDER")
        EB.SystemTables.setAf(FT.Contract.FundsTransfer.CommissionCode); EB.SystemTables.setAv("")
        EB.ErrorProcessing.StoreEndError()
        EB.SystemTables.setEtext("FT.FTSC.CHARGES.MAND.PTT.MONEY.ORDER")
        EB.SystemTables.setAf(FT.Contract.FundsTransfer.ChargeCode); EB.ErrorProcessing.StoreEndError()
    END
*
    EB.SystemTables.setAv(1)
    FOR YFLD = FT.Contract.FundsTransfer.CommissionCode TO FT.Contract.FundsTransfer.ChargeCode STEP 3
        BEGIN CASE
            CASE EB.SystemTables.getRNew(YFLD)[1,1] = "W"     ;* Check no data for WAIVE
                IF EB.SystemTables.getRNew(YFLD+1) OR EB.SystemTables.getRNew(YFLD+2) THEN
                    EB.SystemTables.setEtext("FT.FTSC.WAIVE.SPECIFIED.BUT.COMM/CHG.EXISTS")
                    EB.SystemTables.setAf(YFLD + 1); EB.ErrorProcessing.StoreEndError()
                END
            CASE EB.SystemTables.getRNew(YFLD)[1,1] = "D"     ;* Check Not Internal acct
                IF NOT(NUM(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo))) THEN
                    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargesAcctNo) = "" THEN      ;* GB9200522
                        EB.SystemTables.setEtext("FT.FTSC.NO.CHARGES.INTERNAL.ACCT")
                        EB.SystemTables.setAf(YFLD); EB.ErrorProcessing.StoreEndError()
                    END
                END
            CASE EB.SystemTables.getRNew(YFLD)[1,1] = "C"     ;* Not for internal
                IF NOT(NUM(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditAcctNo))) THEN
                    EB.SystemTables.setEtext("FT.FTSC.NO.CHARGES.INTERNAL.ACCT")
                    EB.SystemTables.setAf(YFLD + 1); EB.ErrorProcessing.StoreEndError()
                END
        END CASE
    NEXT YFLD
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargeCode)[1,1]:EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CommissionCode)[1,1] MATCHES "DC":@VM:"CD" THEN          ;* HY9200641
        FT.Contract.setChargeError(1);* Dont reset
        EB.SystemTables.setEtext("FT.FTSC.INCOMPATIBLE.COMM/CHARGE.CODES")
        EB.SystemTables.setAf(FT.Contract.FundsTransfer.CommissionCode); EB.ErrorProcessing.StoreEndError()
    END
*
** Now check the types and amounts
*
    FOR YFLD = FT.Contract.FundsTransfer.CommissionType TO FT.Contract.FundsTransfer.ChargeType STEP 3
        VMC = COUNT(EB.SystemTables.getRNew(YFLD),@VM) + (EB.SystemTables.getRNew(YFLD) NE "")
        FOR AV.CNT4 = 1 TO VMC     ;* Check each set in turn
            EB.SystemTables.setAv(AV.CNT4)
            EB.SystemTables.setAf(YFLD)
            EB.SystemTables.setComi(EB.SystemTables.getRNew(YFLD)<1,AV.CNT4>); FT.Clearing.BcOnlineVal()
            IF EB.SystemTables.getEtext() THEN EB.ErrorProcessing.StoreEndError()
            EB.SystemTables.setAf(YFLD +1)
            EB.SystemTables.setComi(EB.SystemTables.getRNew(YFLD+1)<1,AV.CNT4>); FT.Clearing.BcOnlineVal()
            IF EB.SystemTables.getEtext() THEN EB.ErrorProcessing.StoreEndError()
            BEGIN CASE
                CASE EB.SystemTables.getRNew(YFLD)<1,AV.CNT4> = "" AND EB.SystemTables.getRNew(YFLD+1)<1,AV.CNT4>
                    EB.SystemTables.setEtext("FT.FTSC.TYPE.INP")
                    EB.SystemTables.setAf(YFLD); EB.ErrorProcessing.StoreEndError()
                CASE EB.SystemTables.getRNew(YFLD)<1,AV.CNT4> = "" AND EB.SystemTables.getRNew(YFLD+1)<1,AV.CNT4> = ""
                    IF VMC GT 1 THEN        ;* Only if more than 1 set
                        EB.SystemTables.setEtext("FT.FTSC.INP.OR.LINE.DELETION.MISS")
                        EB.SystemTables.setAf(YFLD); EB.ErrorProcessing.StoreEndError()
                    END
            END CASE
        NEXT AV.CNT4
        FOR YV = 1 TO VMC     ;* Check ccy consistent
            FOR AV.CNT5 = YV TO VMC
                EB.SystemTables.setAv(AV.CNT5)
                IF EB.SystemTables.getRNew(YFLD+1)<1,AV.CNT5> AND EB.SystemTables.getRNew(YFLD+1)<1,YV> THEN
                    IF EB.SystemTables.getRNew(YFLD+1)<1,AV.CNT5>[1,3] NE EB.SystemTables.getRNew(YFLD+1)<1,YV>[1,3] THEN
                        EB.SystemTables.setEtext("FT.FTSC.ONLY.ONE.CCY.CHG/AMT")
                        EB.SystemTables.setAf(YFLD+1); EB.ErrorProcessing.StoreEndError()
                    END
                END
            NEXT AV.CNT5
        NEXT YV
    NEXT YFLD
*
** Lastly check the Charges acct no
*
    EB.SystemTables.setAv(""); EB.SystemTables.setAf(FT.Contract.FundsTransfer.ChargesAcctNo)
    EB.SystemTables.setComi(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargesAcctNo)); FT.Clearing.BcOnlineVal()
    IF EB.SystemTables.getEtext() THEN EB.ErrorProcessing.StoreEndError()
    BEGIN CASE
        CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargesAcctNo) NE ""      ;* Don't allow if WAIVE or CREDIT
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargeCode)[1,1] = "W" AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CommissionCode)[1,1] = "W" THEN
                EB.SystemTables.setEtext("FT.FTSC.INVALID.CHARGES.WAIVED")
                EB.ErrorProcessing.StoreEndError()
            END
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargeCode)[1,1] = "C" OR EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CommissionCode)[1,1] = "C" THEN
                EB.SystemTables.setEtext("FT.FTSC.INVALID.COMM/CHARGE.CODE.C")
                EB.ErrorProcessing.StoreEndError()
            END
*
            ACC.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargesAcctNo)
            R.DR.CHARGE.ACCOUNT.REC = AC.AccountOpening.Account.Read(ACC.ID, ER)
            FT.Contract.setDynArrayToRDrChargeAccount(R.DR.CHARGE.ACCOUNT.REC)
            IF EB.SystemTables.getEtext() THEN
                EB.ErrorProcessing.StoreEndError()
            END
        CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargesAcctNo) = ""       ;* Default if appropriate
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CommissionCode)[1,1] = "D" OR EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargeCode)[1,1] = "D" THEN
                BEGIN CASE
                    CASE FT.Contract.getRCustomerCharge(CG.ChargeConfig.CustomerCharge.EbCchChgComAccount)  ;* Defined for Customer
                        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ChargesAcctNo, FT.Contract.getRCustomerCharge(CG.ChargeConfig.CustomerCharge.EbCchChgComAccount))
                    CASE FT.Contract.getRGenCondition(FT.Config.GroupCondition.FtThrChgCommSeparate) = "Y"
                        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ChargesAcctNo, EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo))
                END CASE
                IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargesAcctNo) = "" OR FT.Contract.getGeneralConditionInd() = "Y" THEN
                    RET.CODE = ""
                    ACC.NO = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
                    ST.Config.GetNostro("","FT",ACC.NO,"BC","","","","","",RET.CODE,"")
                    EB.SystemTables.setEtext("");* Reset
                    IF RET.CODE = 0 THEN    ;* If NOSTRO take INT
                        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ChargesAcctNo, FT.Contract.getRApplicationDefault(FT.Config.ApplDefault.FtOneClaimChargesAcct))
                    END
                END
                IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargesAcctNo) THEN ;* Read the charge account record
                    ACC.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargesAcctNo)
                    R.DR.CHARGE.ACCOUNT.REC = AC.AccountOpening.Account.Read(ACC.ID, ER)
                    FT.Contract.setDynArrayToRDrChargeAccount(R.DR.CHARGE.ACCOUNT.REC)
                    IF ER THEN
                        EB.SystemTables.setEtext(ER)
                        EB.ErrorProcessing.StoreEndError()
                    END
                END
            END
    END CASE
*
RETURN
*
*------------------------------------------------------------------------
C10.LENGTH.VALIDATION:
*=====================
*
** Check the length of any narrative does not exceed 30 chars for C10
*
    AF.CNT6 = EB.SystemTables.getAf()
    AVC = COUNT(EB.SystemTables.getRNew(AF.CNT6),@VM) + (EB.SystemTables.getRNew(AF.CNT6) NE "")
    FOR AV.CNT6 = 1 TO AVC
        EB.SystemTables.setAv(AV.CNT6)
        IF LEN(EB.SystemTables.getRNew(AF.CNT6)<1,AV.CNT6>) GT MAX.LENGTH THEN
            EB.SystemTables.setEtext("FT.FTSC.MAX.LENGTH.PTT.TXN":@FM:MAX.LENGTH)
            EB.ErrorProcessing.StoreEndError()
        END
    NEXT AV.CNT6
*
RETURN
*
*-------------------------------------------------------------------------
VALIDATE.CREDIT.REF:
*===================
** Check that CREDIT.THEIR.REF is 16 or less apart from C15
*
    IF LEN(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditTheirRef)) GT 16 THEN
        EB.SystemTables.setEtext("FT.FTSC.MAX.LENGTH.16.TXN.TYPE")
        EB.SystemTables.setAf(FT.Contract.FundsTransfer.CreditTheirRef); EB.ErrorProcessing.StoreEndError()
    END
*
RETURN
*
*-------------------------------------------------------------------------
MOD10.CHECK:
*==========
** Ptt accounts must satisfy mod 10 account number validation
*
    tmp.AF = EB.SystemTables.getAf()
    IN.FIELD = EB.SystemTables.getRNew(tmp.AF)
    EB.SystemTables.setAf(tmp.AF)
    YERR = ''
    FT.Contract.Mod10Check(IN.FIELD,"VAL","",YERR)
    IF YERR THEN
        EB.SystemTables.setEtext(YERR)
        EB.ErrorProcessing.StoreEndError()
    END
*
RETURN
*
*------------------------------------------------------------------------
END
