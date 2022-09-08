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
* <Rating>-34</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FT.Clearing
    SUBROUTINE FT.BACS.BULK.CROSSVAL(LOCAL.CLEARING.REC, BC.PARAM.REC)

*************************************************************************
* This routine will cross-validate fields used in the BC transactions
* for Hill Samuel Bank , specifically the BACS(Bank Automated Credit
* System). The fields cross-validated are :
*
*            BENEFICIARY
*            BANK.SORT.CODE
*            BENEFIC.ACCTNO
*            ORDERING.CUST
*            PYMNT.DTAILS
*            LOCAL.REF (PAYMENT.TYPE)
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
* 07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
* 13/08/15 - Enhancement 1265068
*		   - Task 1482605
*		   - DBR changed to Table Read
*
************************************************************************
*
    $USING AC.StandingOrders
    $USING AC.AccountOpening
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING FT.Clearing

    $INSERT I_CustomerService_NameAddress

    NO.OF.PAY.METHODS = DCOUNT(EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstPayMethod), @VM)
    FOR I = 1 TO NO.OF.PAY.METHODS
        EB.SystemTables.setAv(I)
        IF EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstPayMethod)<1,EB.SystemTables.getAv()>[1,2] = 'BC' THEN

            **    BENEFICIARY is mandatory

            IF NOT(EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstBeneficiary)<1,EB.SystemTables.getAv()>) THEN
                EB.SystemTables.setAf(AC.StandingOrders.BulkSto.BstBeneficiary); EB.SystemTables.setAs(1)
                EB.SystemTables.setEtext("FT.FBBC.MAND.INP.BENEFICIARY")
                EB.ErrorProcessing.StoreEndError()
            END

            **    PYMNT.DTAILS is mandatory

            IF NOT(EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstPymntDtails)<1,EB.SystemTables.getAv()>) THEN
                EB.SystemTables.setAf(AC.StandingOrders.BulkSto.BstPymntDtails); EB.SystemTables.setAs(1)
                EB.SystemTables.setEtext("FT.FBBC.MAND.INP.PAYMENT.DETAILS")
                EB.ErrorProcessing.StoreEndError()
            END

            **     BANK.SORT.CODE is mandatory

            IF NOT(EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstBankSortCode)<1,EB.SystemTables.getAv()>) THEN
                EB.SystemTables.setAf(AC.StandingOrders.BulkSto.BstBankSortCode)
                EB.SystemTables.setEtext("FT.FBBC.MAND.INP.BANK.SORT.CODE")
                EB.ErrorProcessing.StoreEndError()
            END

            **    BENEFIC.ACCTNO is mandatory

            *           IF NOT(R.NEW(BST.BENEFIC.ACCTNO)) THEN
            GOSUB CHECK.BENIFIC.ACCTNO  ;* BG_100013036 - S / E
            *
        END
    NEXT I

** Default ORDERING.CUST if null

    IF EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstOrderingCust) = '' THEN
        ACCT.TO.USE = FIELD(EB.SystemTables.getIdNew(),'.',1)
        ORD.CUS = ''
        ER = ""
        R.REC = ""
		R.REC = AC.AccountOpening.Account.Read(ACCT.TO.USE, ER)
		ORD.CUS = R.REC<AC.AccountOpening.Account.Customer>
        CUS.ENRI = ''
        customerKey = ORD.CUS
        customerNameAddress = ''
        prefLang = EB.SystemTables.getLngg()
        CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
        CUS.ENRI = customerNameAddress<NameAddress.shortName>
        tmp=EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstOrderingCust); tmp<1,1>=ORD.CUS[1,18]; EB.SystemTables.setRNew(AC.StandingOrders.BulkSto.BstOrderingCust, tmp)
        LOCATE AC.StandingOrders.BulkSto.BstOrderingCust:'.1' IN EB.SystemTables.getTFieldno()<1> SETTING YPOS THEN
        tmp=EB.SystemTables.getTEnri(); tmp<YPOS>=CUS.ENRI; EB.SystemTables.setTEnri(tmp)
    END
    END

    RETURN
*-----------------------------------------------------------------------------------
* BG_100013036 - S
*====================
CHECK.BENIFIC.ACCTNO:
*====================
    IF EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstBeneficAcctno)<1,EB.SystemTables.getAv()> = '' THEN
        EB.SystemTables.setAf(AC.StandingOrders.BulkSto.BstBeneficAcctno)
        EB.SystemTables.setEtext("FT.FBBC.MAND.INP.BEN.ACCT.NO")
        EB.ErrorProcessing.StoreEndError()
    END ELSE
        IF NOT(EB.SystemTables.getRNew(AC.StandingOrders.BulkSto.BstBeneficAcctno)<1,EB.SystemTables.getAv()> MATCHES '8N') THEN
            EB.SystemTables.setAf(AC.StandingOrders.BulkSto.BstBeneficAcctno)
            EB.SystemTables.setEtext('FT.FBBC.MAND.8.NUMERIC.INP')
            EB.ErrorProcessing.StoreEndError()
        END
    END
    RETURN          ;*BG_100013036 - E
*-----------------------------------------------------------------------------------
***
    END
