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

* Version 3 25/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FT.Clearing
    SUBROUTINE FT.BACS.STO.CROSSVAL(LOCAL.CLEARING.REC, BC.PARAM.REC)

*************************************************************************
* This routine will cross-validate fields used in the BC transactions
* for Hill Samuel Bank , specifically the BACS(Bank Automated Credit
* System).  The fields cross-validated are :
*
*            BENEFICIARY
*            BANK.SORT.CODE
*            BEN.ACCT.NO
*            ORDERING.CUSTOMER
*            PAYMENT.DETAILS
*            LOCAL.REF (PAYMENT.TYPE)
*
**************************************************************************
*
* 23/04/97 - GB9700339
*            Change reference to field STO.ORDERING.CUSTOMER to
*            STO.ORDERING.CUST
*
* 20/09/02 - GLOBUS_EN_10001180
*          Conversion Of all Error Messages to Error Codes
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
*************************************************************************

    $USING AC.StandingOrders
    $USING AC.AccountOpening
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING FT.Clearing

    $INSERT I_CustomerService_NameAddress

**  BENEFICIARY is mandatory

    IF NOT(EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoBeneficiary)) THEN
        EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoBeneficiary); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext("FT.FBSC.MAND.INP.BENEFICIARY")
        EB.ErrorProcessing.StoreEndError()
    END

**  BANK.SORT.CODE is mandatory

    IF NOT(EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoBankSortCode)) THEN
        EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoBankSortCode)
        EB.SystemTables.setEtext("FT.FBSC.MAND.INP.BANK.SORT.CODE")
        EB.ErrorProcessing.StoreEndError()
    END

** BEN.ACCT.NO is mandatory

*     IF NOT(R.NEW(STO.BEN.ACCT.NO)) THEN
    IF EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoBenAcctNo) = '' THEN
        EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoBenAcctNo)
        EB.SystemTables.setEtext("FT.FBSC.MAND.INP.BEN.ACCT.NO")
        EB.ErrorProcessing.StoreEndError()
    END ELSE
        IF NOT(EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoBenAcctNo) MATCHES '8N') THEN
            EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoBenAcctNo)
            EB.SystemTables.setEtext('FT.FBSC.MAND.8.NUMERIC.INP')
            EB.ErrorProcessing.StoreEndError()
        END
    END

** Default ORDERING.CUSTOMER if null

    IF EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoOrderingCust) = '' THEN
        ACCT.TO.USE = FIELD(EB.SystemTables.getIdNew(),'.',1)
        ORD.CUS = ''
        R.REC = ""
        ER = ""
        R.REC = AC.AccountOpening.Account.Read(ACCT.TO.USE, ER)
        ORD.CUS = R.REC<AC.AccountOpening.Account.Customer>
        CUS.ENRI = ''
        customerKey = ORD.CUS
        customerNameAddress = ''
        prefLang = EB.SystemTables.getLngg()
        CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
        CUS.ENRI = customerNameAddress<NameAddress.shortName>
        tmp=EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoOrderingCust); tmp<1,1>=ORD.CUS[1,18]; EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoOrderingCust, tmp)
        LOCATE AC.StandingOrders.StandingOrder.StoOrderingCust:'.1' IN EB.SystemTables.getTFieldno()<1> SETTING YPOS THEN
        tmp=EB.SystemTables.getTEnri(); tmp<YPOS>=CUS.ENRI; EB.SystemTables.setTEnri(tmp)
    END
    END

** PAYMENT.DETAILS is mandatory

    IF NOT(EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoPaymentDetails)) THEN
        EB.SystemTables.setAf(AC.StandingOrders.StandingOrder.StoPaymentDetails); EB.SystemTables.setAv(1)
        EB.SystemTables.setEtext("FT.FBSC.MAND.INP.PAYMENT.DETAILS")
        EB.ErrorProcessing.StoreEndError()
    END
    RETURN

***
    END
