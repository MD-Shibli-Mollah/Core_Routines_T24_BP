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

* Version 2 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-26</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FT.Clearing
    SUBROUTINE FT.BACS.CROSSVAL(CURR.NO)

*************************************************************************
* This routine will cross-validate fields used in the BC transactions
* for Hill Samuel Bank , specifically the BACS(Bank Automated Credit
* System).  The fields cross-validated are :
*
*            DEBIT.VALUE.DATE
*            CREDIT.VALUE.DATE
*            BEN.CUSTOMER
*            BC.BANK.SORT.CODE
*            BEN.ACCT.NO
*            ORDERING.CUST
*            PAYMENT.DETAILS
*            BENIFICIARY.BANK
*
*************************************************************************
*MODIFICATIONS

* 20/09/02 - GLOBUS_EN_10001180
*          Conversion Of all Error Messages to Error Codes
*
* 17/02/07 - BG_100013036
*            CODE.REVIEW changes.
*
* 20/07/10 - Task 66080
*            Change the reads to Customer to use the Customer
*            Service api calls
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
************************************************************************
    $USING FT.Contract
    $USING AC.AccountOpening
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING FT.Clearing
    $INSERT I_CustomerService_NameAddress

*
* No back-valued deals are allowed for BACS payments
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitValueDate) THEN
        IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitValueDate) LT EB.SystemTables.getToday() THEN
            EB.SystemTables.setAf(FT.Contract.FundsTransfer.DebitValueDate)
            EB.SystemTables.setEtext('FT.FTBC.DATE.CANT.BACK.VALUED')
            EB.ErrorProcessing.StoreEndError()
        END
    END
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditValueDate) THEN
        IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditValueDate) LT EB.SystemTables.getToday() THEN
            EB.SystemTables.setAf(FT.Contract.FundsTransfer.CreditValueDate)
            EB.SystemTables.setEtext('FT.FTBC.DATE.CANT.BACK.VALUED')
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
    END ELSE
        NULL    ;* BG_100013036 - S
    END         ;* BG_100013036 - E
    END

**  BEN.CUSTOMER is mandatory

    IF NOT(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenCustomer)) THEN
        EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenCustomer); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext("FT.FTBC.MAND.INP.BEN.CUSTOMER")
        EB.ErrorProcessing.StoreEndError()
    END

**  BC.BANK.SORT.CODE is mandatory

    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BcBankSortCode) = "" THEN
        EB.SystemTables.setAf(FT.Contract.FundsTransfer.BcBankSortCode)
        EB.SystemTables.setEtext("FT.FTBC.MAND.INP.BC.BANK.SORT.CODE")
        EB.ErrorProcessing.StoreEndError()
    END

** BEN.ACCT.NO is mandatory

*     IF NOT(R.NEW(FT.BEN.ACCT.NO)) THEN
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo) = '' THEN
        EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenAcctNo)
        EB.SystemTables.setEtext("FT.FTBC.MAND.INP.BEN.ACCT.NO")
        EB.ErrorProcessing.StoreEndError()
    END ELSE
        IF NOT(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BenAcctNo) MATCHES '8N') THEN
            EB.SystemTables.setAf(FT.Contract.FundsTransfer.BenAcctNo)
            EB.SystemTables.setEtext('FT.FTBC.MAND.8.NUMERIC.INP')
            EB.ErrorProcessing.StoreEndError()
        END
    END

** Default ORDERING.CUST if null

    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingCust) = '' THEN
        IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo) NE '' THEN
            ORD.CUS = ''
            R.NEW.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
            R.REC = ""
            ER1 = ""
            R.REC = AC.AccountOpening.Account.Read(R.NEW.ID, ER1)
            ORD.CUS = R.REC<AC.AccountOpening.Account.Customer>
            CUS.ENRI = ''
            customerKey = ORD.CUS
            customerNameAddress = ''
            prefLang = EB.SystemTables.getLngg()
            CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
            CUS.ENRI = customerNameAddress<NameAddress.shortName>
            tmp=EB.SystemTables.getRNew(FT.Contract.FundsTransfer.OrderingCust); tmp<1,1>=ORD.CUS[1,18]; EB.SystemTables.setRNew(FT.Contract.FundsTransfer.OrderingCust, tmp)
            LOCATE FT.Contract.FundsTransfer.OrderingCust:'.1' IN EB.SystemTables.getTFieldno()<1> SETTING YPOS THEN
            tmp=EB.SystemTables.getTEnri(); tmp<YPOS>=CUS.ENRI; EB.SystemTables.setTEnri(tmp)
        END
    END
    END

** PAYMENT.DETAILS is mandatory

    IF NOT(EB.SystemTables.getRNew(FT.Contract.FundsTransfer.PaymentDetails)) THEN
        EB.SystemTables.setAf(FT.Contract.FundsTransfer.PaymentDetails); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext("FT.FTBC.MAND.INP.PAYMENT.DETAILS")
        EB.ErrorProcessing.StoreEndError()
    END

*** Default charge and commission codes if they are null

    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ChargeCode) = '' THEN
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ChargeCode, 'DEBIT PLUS CHARGES')
    END
*
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CommissionCode) = '' THEN
        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CommissionCode, 'DEBIT PLUS CHARGES')
    END

    RETURN
***
    END
