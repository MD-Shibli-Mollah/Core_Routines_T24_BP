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

* Version 6 18/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-56</Rating>

    $PACKAGE FT.Clearing
    SUBROUTINE FT.SCC.CROSSVAL(CURR.NO)
*
************************************************************************
* Description:                                                         *
* ============                                                         *
*                                                                      *
* This routine will cross-validate fields used in the BC transactions  *
* for Slovakia, specifically the SCC (Slovak Clearing Centre) system.  *
* The fields cross-validated are :                                     *
*                                                                      *
*            BC.BANK.SORT.CODE                                         *
*            BEN.ACCT.NO                                               *
*            ORDERING.CUST                                             *
*            ORDERING.BANK                                             *
*            BEN.CUSTOMER                                              *
*            BEN.BANK                                                  *
*            LOCAL.REF (SCC.TXN.CODE)                                  *
*            LOCAL.REF (SCC.CONSTANT)                                  *
*                                                                      *
*                                                                      *
************************************************************************
* Modification Log:                                                    *
* =================                                                    *
*                                                                      *
* 31/03/98 - GB9800251                                                 *
*            Force check digit if valid account number.                *
*                                                                      *
*                                                                      *
* 20/09/02 - GLOBUS_EN_10001180
*          Conversion Of all Error Messages to Error Codes
*                                                                      *
*
* 23/02/07 - BG_100013036
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
*                                                                   *
************************************************************************
*
*
    $USING AC.AccountOpening
    $USING FT.Contract
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING FT.Clearing

*
* SCC.TXN.CODE is taken from LOCAL.REFERENCE. It is a mandatory field and therefore must
* be present. It's position is held in REQ.LOCREF.POS on FT.LOCAL.CLEARING for the
* corresponding REQ.LOCREF.NAME field.
*
    SCC.TXN.CODE.POS = ''
    LOCATE 'SCC.TXN.CODE' IN FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcReqLocrefName)<1,1> SETTING NAME.POS ELSE
    NAME.POS = ''         ;* BG_100013036 - S
    END   ;* BG_100013036 - E
    IF NAME.POS THEN
        SCC.TXN.CODE.POS = FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcReqLocrefPos)<1,NAME.POS>
    END

    SCC.TXN.CODE = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)<1,SCC.TXN.CODE.POS>
    IF SCC.TXN.CODE = '' THEN
        EB.SystemTables.setAf(FT.Contract.FundsTransfer.LocalRef); EB.SystemTables.setAv(SCC.TXN.CODE.POS)
        EB.SystemTables.setEtext('FT.FSC.INP.MAND')
        EB.ErrorProcessing.StoreEndError()
    END
*
* SCC.CONSTANT is taken from LOCAL.REFERENCE. It is a mandatory field and therefore must
* be present. It's position is held in REQ.LOCREF.POS on FT.LOCAL.CLEARING for the
* corresponding REQ.LOCREF.NAME field.
*
    SCC.CONSTANT.POS = ''

    LOCATE 'SCC.CONSTANT' IN FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcReqLocrefName)<1,1> SETTING CONS.POS ELSE
    CONS.POS = ''         ;* BG_100013036 - S
    END   ;* BG_100013036 - E

    IF CONS.POS THEN
        SCC.CONSTANT.POS = FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcReqLocrefPos)<1,CONS.POS>
    END

    SCC.CONSTANT = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)<1,SCC.CONSTANT.POS>
    IF SCC.CONSTANT = '' THEN
        EB.SystemTables.setAf(FT.Contract.FundsTransfer.LocalRef); EB.SystemTables.setAv(SCC.CONSTANT.POS)
        EB.SystemTables.setEtext('FT.FSC.INP.MAND')
        EB.ErrorProcessing.StoreEndError()
    END
*
* Make sure BEN.ACCT.NO satisfies MOD 11 validation
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo) MATCHES '1N0N' THEN
        EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenAcctNo)
        SAVE.COMI = EB.SystemTables.getComi()
        EB.SystemTables.setComi(EB.SystemTables.getRNew(EB.SystemTables.getAf()))
        GOSUB CHECK.ACCT.NO.VALIDATION
        IF EB.SystemTables.getEtext() THEN
            EB.ErrorProcessing.StoreEndError()        ;* BG_100013036 - S
        END         ;* BG_100013036 - E
        EB.SystemTables.setComi(SAVE.COMI)
    END
*
* Make sure that only one of ordering bank or customer are present
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingBank) NE '' AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingCust) NE '' THEN
        EB.SystemTables.setAf(FT.Contract.FundsTransfer.OrderingCust); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext('FT.FSC.CANT.ENT.BOTH.CU.BANK')
        EB.ErrorProcessing.StoreEndError()
    END
*
* Make sure only one of beneficiary bank or customer are present
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenBank) NE '' AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenCustomer) NE '' THEN
        EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenCustomer); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext('FT.FSC.CANT.ENT.BOTH.BEN.CU.BANK')
        EB.ErrorProcessing.StoreEndError()
    END
*
* If no input is made to ORDERING.BANK or to ORDERING.CUST then default the
* SHORT.TITLE from the DEBIT.ACCOUNT.NO in ORDERING.CUST
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingBank) = '' AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingCust) = '' THEN
        ACCT.TO.CHECK = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
        SHORT.TITLE = ''
        R.REC = ""
        ER = ""
        R.REC = AC.AccountOpening.Account.Read(ACCT.TO.CHECK, ER)
        LNGG.POS = EB.SystemTables.getLngg()
        SHORT.TITLE = R.REC<AC.AccountOpening.Account.ShortTitle,LNGG.POS>
        IF NOT(SHORT.TITLE) THEN
        	SHORT.TITLE = R.REC<AC.AccountOpening.Account.ShortTitle,1>
        END
        EB.SystemTables.setEtext(ER)
        IF EB.SystemTables.getEtext() THEN
            EB.SystemTables.setEtext('');* BG_100013036 - S
        END         ;*BG_100013036 - E
        tmp=EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingCust); tmp<1,1>=SHORT.TITLE; EB.SystemTables.setRNew(FT.Contract.FundsTransfer.OrderingCust, tmp)
    END
*
* If no input is made to beneficiary customer or bank then force input
* if the payment is to the Czech Republic (defined in field PTT.SORT.CODE
* on the FT.LOCAL.CLEARING file).
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BcBankSortCode) MATCHES FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcPttSortCode) THEN
        IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenBank) = '' AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenCustomer) = '' THEN
            EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenCustomer); EB.SystemTables.setAv(1)
            EB.SystemTables.setEtext('FT.FSC.BEN.CU.OR.BANK.PRESENT')
            EB.ErrorProcessing.StoreEndError()
        END
    END
*
* If the BC.BANK.SORT.CODE is present then check to see if the sort code is
* one of the bank's own, in which case we must switch the transaction from 'BC' to 'AC'
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BcBankSortCode) THEN
        LOCATE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BcBankSortCode) IN FT.Clearing.getFtlcLocalClearing(FT.Clearing.LocalClearing.LcBcCode)<1,1> SETTING CODE.POS THEN
        IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.InwardPayType) = '' THEN
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.TransactionType, 'AC')
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAcctNo, EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo))
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.BenCustomer, '')
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.BenAcctNo, '')
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.AcctWithBank, '')
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.BcBankSortCode, '')
            FT.Contract.Crossval(CURR.NO,CR.NOSTRO.ACCT,DR.NOSTRO.ACCT)
            RETURN
        END
    END         ;* BG_100013036 - S / E
    END
*
* Check to see if charge or commission code has been set.
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargeCode) EQ '' AND EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CommissionCode) EQ '' THEN
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ChargeCode, 'DEBIT PLUS CHARGES')
    END

    RETURN

******************************************************************************************************

CHECK.ACCT.NO.VALIDATION:
*
* GB9800251s
    RETURN.ERROR = 1
* GB9800251e
*


    RETURN

***
    END
