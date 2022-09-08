* @ValidationCode : MjoyMTE2MDg0MTMyOkNwMTI1MjoxNTg0MDE1ODk0NDc5OnJ2YXJhZGhhcmFqYW46LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMjAwMy4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Mar 2020 17:54:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 15 29/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-132</Rating>
$PACKAGE FT.Clearing
SUBROUTINE FT.BGC.CROSSVAL(CURR.NO)
*
************************************************************************
* Description:                                                         *
* ============                                                         *
*                                                                      *
* Routine to val FT transactions for the purposes of the BGC interface *
* The passed parameters are not used in this routine but are passed to *
* keep to standards.                                                   *
*                                                                      *
************************************************************************
* Modification Log:                                                    *
* =================                                                    *
*                                                                      *
* 31/03/98 - GB9800251                                                 *
*            Force check digit if valid account number.                *
*                                                                      *
* 01/05/98 - GB9800432
*            Add a check for a Formatted account number and prevent the
*            BEN.ACCT.NO from being mandatory. The transaction could be
*            an 'AC' type converted from 'BC'.
*                                                                      *
* 01/05/98 - GB9800433
*            Add a check for any Postbank account being numeric after the
*            prefix 'P'
*                                                                      *
*                                                                      *
* 20/09/02 - GLOBUS_EN_10001180
*          Conversion Of all Error Messages to Error Codes
*                                                                      *
* 02/03/04 - CI_10017578
*            Max and min length validation of field BEN.CUSTOMER when txn type is BC done in
*            FT.BC.CROSSVAL. Hence checks removed here.
* 09/07/04 - CI_10021216
*            Validate BEN.CUSTOMER when FT is created during account
*             closure also.
*
* 28/02/07 - BG_100013036
*            CODE.REVIEW changes.
*
* 18/08/10 - Task 66080
*            Change the reads to Customer to use the Customer
*            Service api calls
*
* 27/02/12 - Task 361172
*            Changes done not to change the txn to AC type if BC.BANK.SORT.CODE is inputted.
*
* 16/03/15 - Enhancement 1265068/ Task 1265069
*          - Initialising DIM array size within the routine and removing from insert to support componentisation
*
* 3/11/15 - Enhancement / Task 1521186
*         - Routine incorporated
*
* 6/11/15 - Defect 1523300 / Task 1524581
*         - Including the inserts to support I_CHECK.ACCT.NO as it has
*         - been removed from there.
*
* 10/12/19 - Enhancement 2822520 / Task 3469644
*            Strict compiler changes
*
* 03/02/20 -   Enhancement 3568228  / Task 3568259
*            Changing reference of routines that have been moved from ST to CG
************************************************************************
*
    $USING AC.AccountOpening
    $USING AC.Config
    $USING FT.Contract
    $USING CG.ChargeConfig
    $USING FT.Clearing
    $USING FT.Config
    $USING ST.Config
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_CustomerService_NameAddress

*
* Check Benificary account number is external else not a BGC transaction.
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BcBankSortCode) EQ '' THEN
        GOSUB CHANGE.ON.AC.TYPE
    END

*
* For funds transfer transactions check the account is of a BGC CATEGORY
*
    R.CURRCLASS = ''
    R.SAVCLASS = ''
    V$ERROR = ''
    R.CURRCLASS = ''
    R.SAVCLASS = ''
    ACCT.NO = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
    R.ACCOUNT = AC.AccountOpening.Account.Read(ACCT.NO, V$ERROR)
    R.CURRCLASS = AC.Config.AccountClass.Read("U-BGCCURR", V$ERROR)
    R.SAVCLASS = AC.Config.AccountClass.Read("U-BGCSAV", V$ERROR)
    LOCATE R.ACCOUNT<AC.AccountOpening.Account.Category> IN R.CURRCLASS<AC.Config.AccountClass.ClsCategory,1> SETTING POSN ELSE
        LOCATE R.ACCOUNT<AC.AccountOpening.Account.Category> IN R.SAVCLASS<AC.Config.AccountClass.ClsCategory,1> SETTING POSN ELSE
            EB.SystemTables.setAf(FT.Contract.FundsTransfer.DebitAcctNo)
            EB.SystemTables.setEtext("FT.RTN.INVALID.AC.CLASS.CAT")
            EB.ErrorProcessing.StoreEndError()
            RETURN
        END
    END
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.InwardPayType)[4] NE '-LCL' THEN
* GB9800432 - The FT could be an 'AC' converted from a 'BC' and with an
*             internal account no. BEN.ACCT.NO should not be mandatory.
        IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.TransactionType)[1,2] = 'AC' ELSE
            EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenAcctNo)
            GOSUB CHECK.BEN.ACCT
            IF EB.SystemTables.getEtext() THEN
                EB.SystemTables.setAv(""); EB.SystemTables.setAs("")
                EB.ErrorProcessing.StoreEndError()
                RETURN
            END
*
* Do not check beneficiary for incoming transactions.
*
            EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenCustomer)
            GOSUB CHECK.BEN.CUST
            IF EB.SystemTables.getEtext() THEN
                EB.ErrorProcessing.StoreEndError()
                RETURN
            END
        END
    END
*
* Check to see if charge or commission code has been set.
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargeCode) EQ '' AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CommissionCode) EQ '' THEN
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ChargeCode, 'DEBIT PLUS CHARGES')
    END
*
** Lastly check the Charges acct no
*
    EB.SystemTables.setAv(""); EB.SystemTables.setAf(FT.Contract.FundsTransfer.ChargesAcctNo)
    EB.SystemTables.setComi(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargesAcctNo)); FT.Clearing.BcOnlineVal()
    IF EB.SystemTables.getEtext() THEN
        EB.ErrorProcessing.StoreEndError()  ;* BG_100013036 - S
    END   ;* BG_100013036 - E

    BEGIN CASE
        CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargesAcctNo) NE ""      ;* Don't allow if WAIVE or CREDIT

            GOSUB CHECK.ON.FT.CHARGES.ACCT.NO         ;* BG_100013036 - S / E

        CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargesAcctNo) = ""       ;* Default if appropriate
            GOSUB DEFAULT.FT.CHARGES.ACCT.NO          ;* BG_100013036 - S / E
    END CASE
*
RETURN          ;* from this program (SUBROUTINE)
*
CHECK.BEN.ACCT:
*
* This GOSUB uses the insert to check for MOD 11 validity of
* the account numbers
*
    AF1= EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(AF1) NE '' THEN
        IF LEN(EB.SystemTables.getRNew(AF1)) GE '8' AND EB.SystemTables.getRNew(AF1)[1,1] NE 'P' THEN
            IF NUM(EB.SystemTables.getRNew(AF1)) THEN
                EB.SystemTables.setComi(EB.SystemTables.getRNew(AF1))
*
* GB9800251s
                RETURN.ERROR = 1
* GB9800251e
*
                AC.AccountOpening.CheckAcctNo(RETURN.ERROR)
            END ELSE
                EB.SystemTables.setEtext('FT.RTN.INP.NUMERIC')
            END
        END ELSE
            GOSUB CHECK.ON.BEN.ACCOUNT  ;* BG_100013036 - S / E
        END
    END ELSE
        EB.SystemTables.setEtext('FT.RTN.INP.MAND')
    END
*
RETURN
*
CHECK.BEN.CUST:
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.InwardPayType)[1,3] = 'ACC' AND FT.Contract.getAutoProcessingInd() = 'Y' THEN
        GOSUB CHECK.ON.BEN.CUSTOMER
    END

RETURN          ;* from GOSUB
*
*************************************************************************************************************
* BG_100013036 - S
*============================
CHECK.ON.FT.CHARGES.ACCT.NO:
*============================
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargeCode)[1,1] = "W" AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CommissionCode)[1,1] = "W" THEN
        EB.SystemTables.setEtext("FT.RTN.INVALID.CHARGES.WAIVED")
        EB.ErrorProcessing.StoreEndError()
    END
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargeCode)[1,1] = "C" OR EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CommissionCode)[1,1] = "C" THEN
        EB.SystemTables.setEtext("FT.RTN.INVALID.COMM/CHARGE.CODE.C")
        EB.ErrorProcessing.StoreEndError()
    END
*
    tmp.AF = EB.SystemTables.getAf()
    ACC.ID = EB.SystemTables.getRNew(tmp.AF)
    R.DR.CHARGE.ACCOUNT.REC = ''
    R.DR.CHARGE.ACCOUNT.REC = AC.AccountOpening.Account.Read(ACC.ID, ER)
    FT.Contract.setDynArrayToRDrChargeAccount(R.DR.CHARGE.ACCOUNT.REC)
    IF ER THEN
        EB.SystemTables.setEtext(ER)
        EB.ErrorProcessing.StoreEndError()
    END
RETURN
*************************************************************************************************************
*=============================
DEFAULT.FT.CHARGES.ACCT.NO:
*=============================
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CommissionCode)[1,1] = "D" OR EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargeCode)[1,1] = "D" THEN
        BEGIN CASE
            CASE FT.Contract.getRCustomerCharge(CG.ChargeConfig.CustomerCharge.EbCchChgComAccount)      ;* Defined for Customer
                EB.SystemTables.setRNew(EB.SystemTables.getAf(), FT.Contract.getRCustomerCharge(CG.ChargeConfig.CustomerCharge.EbCchChgComAccount))
            CASE FT.Contract.getRGenCondition(FT.Config.GroupCondition.FtThrChgCommSeparate) = "Y"
                EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ChargesAcctNo, EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo))
        END CASE
        tmp.AF = EB.SystemTables.getAf()
        IF EB.SystemTables.getRNew(tmp.AF) = "" OR FT.Contract.getGeneralConditionInd() = "Y" THEN
            RET.CODE = ""
            ACC.NO = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
            ST.Config.GetNostro("","FT",ACC.NO,"BC","","","","","",RET.CODE,"")
            EB.SystemTables.setEtext("");* Reset
            IF RET.CODE = 0 THEN        ;* If NOSTRO take INT
                EB.SystemTables.setRNew(EB.SystemTables.getAf(), FT.Contract.getRApplicationDefault(FT.Config.ApplDefault.FtOneClaimChargesAcct))
            END
        END
        tmp.AF = EB.SystemTables.getAf()
        ACCT.NO = EB.SystemTables.getRNew(tmp.AF)
        IF ACCT.NO  THEN     ;* Read the charge account record
            R.DR.CHARGE.ACCOUNT.REC = AC.AccountOpening.Account.Read(ACCT.NO, ER)
            FT.Contract.setDynArrayToRDrChargeAccount(R.DR.CHARGE.ACCOUNT.REC)
            IF ER THEN
                EB.SystemTables.setEtext(ER)
                EB.ErrorProcessing.StoreEndError()    ;* BG_100013036 - S
            END     ;* BG_100013036 - E
        END
    END
RETURN
*************************************************************************************************************
*====================
CHECK.ON.BEN.ACCOUNT:
*====================
    AF2 = EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(AF2)[1,1] NE 'P' THEN
        IF EB.SystemTables.getRNew(AF2) MATCHES '1N0N' THEN
            EB.SystemTables.setRNew(AF2, FMT(EB.SystemTables.getRNew(AF2),'9"0"R'))
            EB.SystemTables.setRNew(AF2, 'P':EB.SystemTables.getRNew(AF2))
        END ELSE
            EB.SystemTables.setEtext('FT.RTN.INP.NUMERIC')
        END
    END ELSE
        TEMP.AF = EB.SystemTables.getRNew(AF2)
        CONVERT " " TO "" IN TEMP.AF
        IF TEMP.AF NE EB.SystemTables.getRNew(AF2) THEN
            EB.SystemTables.setEtext('FT.RTN.NO.SPACES.ALLOWED')
        END ELSE
            NUM.LEN = LEN(EB.SystemTables.getRNew(AF2))-1
            EB.SystemTables.setRNew(AF2, EB.SystemTables.getRNew(AF2)[2,NUM.LEN])
* GB9800433 - Set ETEXT if the rest of the Postbank account is not num
            IF NOT(NUM(EB.SystemTables.getRNew(AF2))) THEN
                EB.SystemTables.setEtext("FT.RTN.INVALID.POSTBANK.AC")
            END
            EB.SystemTables.setRNew(AF2, 'P':EB.SystemTables.getRNew(AF2))
        END
    END
RETURN
*************************************************************************************************************
*=====================
CHECK.ON.BEN.CUSTOMER:
*=====================
    DR.ACCT.REC = ''
    READ.FAILED = ''
    ACCT.NO = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
    DR.ACCT.REC = AC.AccountOpening.Account.Read(ACCT.NO, READ.FAILED)
    IF NOT(READ.FAILED) THEN
        customerKey = DR.ACCT.REC<AC.AccountOpening.Account.Customer>
        prefLang = EB.SystemTables.getLngg()
        customerNameAddress = ''
        CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
        IF EB.SystemTables.getEtext() THEN
            RETURN
        END
        tmp=EB.SystemTables.getRNew(EB.SystemTables.getAf()); tmp<1,1>=customerNameAddress<NameAddress.shortName>; EB.SystemTables.setRNew(EB.SystemTables.getAf(), tmp)
        tmp=EB.SystemTables.getRNew(EB.SystemTables.getAf()); tmp<1,2>=customerNameAddress<NameAddress.townCountry>; EB.SystemTables.setRNew(EB.SystemTables.getAf(), tmp)

* CI_10021216 S
* Validate BEN.CUSTOMER if updated now.
        AF3 = EB.SystemTables.getAf()
        SAVE$AV = EB.SystemTables.getAv() ; SAVE$COMI = EB.SystemTables.getComi()
        NO.LINES = COUNT(EB.SystemTables.getRNew(AF3),@VM)+(EB.SystemTables.getRNew(AF3) NE "")
        FOR G$AV = 1 TO NO.LINES        ;* Basic checks
            EB.SystemTables.setAv(G$AV)
            EB.SystemTables.setComi(EB.SystemTables.getRNew(AF3)<1,G$AV>); FT.Clearing.BcOnlineVal()
            IF EB.SystemTables.getEtext() THEN
                EXIT
            END
        NEXT G$AV
        EB.SystemTables.setAv(SAVE$AV); EB.SystemTables.setComi(SAVE$COMI)
* CI_10021216 E


    END
RETURN          ;* BG_100013036 - E
*************************************************************************************************************
CHANGE.ON.AC.TYPE:
*--------------------
    R.ACCOUNT = ''
    ACC.BO = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo)
    R.ACCOUNT = AC.AccountOpening.Account.Read(ACC.NO, ER)
    IF R.ACCOUNT THEN
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.TransactionType, 'AC')
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAcctNo, EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo))
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.BenAcctNo, '')
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.BenCustomer, '')
        FT.Contract.Crossval(CURR.NO,'','')
* GB9800432 - Second check required for formatted account no
    END ELSE
        FMT.BEN.ACCT.NO = FMT(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo),'10"0"R')
        R.ACCOUNT = AC.AccountOpening.Account.Read(FMT.BEN.ACCT.NO, ER)
        IF R.ACCOUNT THEN
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.TransactionType, 'AC')
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAcctNo, FMT.BEN.ACCT.NO)
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.BenAcctNo, '')
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.BenCustomer, '')
            FT.Contract.Crossval(CURR.NO,'','')
        END
    END
RETURN
*********************************************************************************************
END
