* @ValidationCode : MjotMTE0NDE1NzkyMTpDcDEyNTI6MTYwODIxNDMyMDg4NDpzY2hhbmRpbmk6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEyLjE6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Dec 2020 19:42:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : schandini
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-63</Rating>
*-----------------------------------------------------------------------------
$PACKAGE T2.ModelBank
SUBROUTINE E.NOFILE.TCIB.BEN.LIST.AI(Y.FINAL.ARRAY)
*--------------------------------------------------------------------------------------------------------------------
* Company Name       : TCIB Product
* Developed By       : Temenos
* Developer Name     : ssrimathi@temenos.com
* Routine type       : Nofile
* Attached To        : STANDARD.SELECTION>NOFILE.TCIB.BEN.LIST.AI
* Date               : 09-Dec-2013
* Purpose            : This routine used to display the Beneficiary acct numbers
*--------------------------------------------------------------------------------------------------------------------
* Files Used
*----------
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*--------------------
* 26/12/13 - Enhancement 590517
*            TCIB Development
*
* 07/03/14 - Task 933876 /Defect 933742
*            INSERT statement changes
*
* 15/05/14 - Task 1003825 / Defect 986452
*            By deleting the comment the previous comment is saved under Utility Payees page.
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
*
* 05/11/15 - Defect 1523105 / Task 1523352
*            Moved the application BENEFICIARY from FT to ST.
*            Hence Beneficiary application fields are referred using component BY.Payments
*
* 05/01/16 - Enhancement 1572530 / Task
*            POA Integration for Standing order, payees and view payments
*
* 08/12/2020 - Enhancement 4020994 / Task 4037076
*              Changing BY.Payments reference to new component reference BY.Payments since
*              beneficiary and beneficiary links table has been moved to new module BY.
*------------------------

    $USING EB.Reports
    $USING FT.Config
    $USING T2.ModelBank
    $USING BY.Payments
*
    GOSUB INITIALISE
    GOSUB PROCESS
RETURN
*---------------------------------------------------------------------------------------------------------------------
INITIALISE:
*----------
*
RETURN
*---------------------------------------------------------------------------------------------------------------------
PROCESS:
*--------
*
    LOCATE 'Y.CUSTOMER' IN EB.Reports.getDFields()<1> SETTING REC.POS THEN
        Y.CUSTOMER = EB.Reports.getDRangeAndValue()<REC.POS>   ;* Get the customer value from enquiry selection.
    END

*    Y.CUSTOMER = System.getVariable("EXT.CUSTOMER")

    R.BEN.DET = T2.ModelBank.TcibCustomerBeneficiary.Read(Y.CUSTOMER, ERR.BEN)
    IF R.BEN.DET THEN
        GOSUB BEN.PROCESS
    END
*
RETURN
*-----------------------------------------------------------------------------------------------------------------------
BEN.CUS.NICKNAME.CHECK:
*------------------------

    IF Y.BEN.CUS NE '' AND Y.BEN.NICK.NAME NE '' THEN
        Y.BEN.CUS.NICK = Y.BEN.CUS:" ":"(":Y.BEN.NICK.NAME:")"
    END ELSE
        IF Y.BEN.CUS EQ '' THEN
            Y.BEN.CUS.NICK = Y.BEN.NICK.NAME
        END ELSE
            Y.BEN.CUS.NICK = Y.BEN.CUS
        END
    END

RETURN
*-----------------------------------------------------------------------------------------------------------------------
BEN.PROCESS:
*------------
*
    LOOP
        REMOVE Y.BEN.ID FROM R.BEN.DET SETTING BEN.POS
    WHILE Y.BEN.ID:BEN.POS
        Y.BEN.ID = FIELD(Y.BEN.ID,'.',1)
        R.BENEFICIARY = BY.Payments.Beneficiary.Read(Y.BEN.ID, ERR.BENFCRY)
        IF R.BENEFICIARY THEN
            Y.BEN.NICK.NAME = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenNickname>
            Y.CATEGORY = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenCategory>
            Y.BEN.ACT.NO = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBenAcctNo>
            Y.BEN.CUS = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBenCustomer>
            Y.TRANS.TYPE = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenTransactionType>
            Y.SOT.CODE = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBankSortCode>
            Y.BIC = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBic>
            Y.IBAN.BEN = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenIbanBen>
            Y.COMMENT = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenDefaultNarrative>
            Y.CUSTOMER.REF = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenCustomerRef>
            Y.ACCT.WITH.BANK = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenAcctWithBank>
            Y.PAYMENT.CCY = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenPaymentCcy>
            Y.PREF.PYMT.AMOUNT = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenPrefPymtAmount>
            Y.BEN.OUR.CHARGES = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBenOurCharges>
            Y.BEN.PYMT.COUNTRY = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBenPymtCountry>
            Y.PREF.PYMT.PRODUCT = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenPrefPymtProduct>
            GOSUB BEN.CUS.NICKNAME.CHECK
*
            Y.LINK.TO.BENE = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenLinkToBeneficiary>
*
            R.TXN.TYPE = FT.Config.TxnTypeCondition.CacheRead(Y.TRANS.TYPE, ERR.TR)
            Y.TXN.DESC = R.TXN.TYPE<FT.Config.TxnTypeCondition.FtSixDescription>

            Y.FINAL.ARRAY<-1> = Y.BEN.ID:"*":Y.BEN.NICK.NAME:"*":Y.CATEGORY:"*":Y.BEN.ACT.NO:'*':Y.BEN.CUS:"*":Y.TXN.DESC:"*":Y.TRANS.TYPE:"*":Y.SOT.CODE:"*":Y.BIC:"*":Y.IBAN.BEN:'*':Y.LINK.TO.BENE:'*':Y.BEN.CUS.NICK:'*':Y.CUSTOMER.REF:'*':Y.COMMENT:"*":Y.ACCT.WITH.BANK:"*":Y.PAYMENT.CCY:"*":Y.PREF.PYMT.AMOUNT:"*":Y.BEN.OUR.CHARGES:"*":Y.BEN.PYMT.COUNTRY:"*":Y.PREF.PYMT.PRODUCT
        END

    REPEAT
RETURN
END
