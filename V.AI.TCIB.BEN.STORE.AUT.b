* @ValidationCode : MjoxNjM4MDQ4MzUwOkNwMTI1MjoxNjA4MjE0MzgyMjk4OnNjaGFuZGluaTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEyLjE6MjE6MjE=
* @ValidationInfo : Timestamp         : 17 Dec 2020 19:43:02
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : schandini
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 21/21 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE T2.ModelBank
SUBROUTINE V.AI.TCIB.BEN.STORE.AUT
*-------------------------------------------------------------------------
* Company Name       : TCIB Product
* Developed By       : Temenos Application Management
* Developer Name     : ssrimathi@temenos.com
* Routine type       : Version
* Attached To        : VERSION>BENEFICIARY,TCIB.INPUT
* Date               : 09-Dec-2013
* Purpose            : This routine used to update the concat file
*-------------------------------------------------------------------------
* Files Used
*----------
*
*-------------------------------------------------------------------------
* Modification History
*--------------------
*
* 25/09/14 - Defect 1123686 / Task 1124279
*            BENEFICIARY table file - not updating while Reversing
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*            Incorporation of T components
*
* 05/11/15 - Defect 1523105 / Task 1523352
*            Moved the application BENEFICIARY from FT to ST.
*            Hence Beneficiary application fields are referred using component BY.Payments
*
* 01/09/16 - Defect 1843192 / Task 1845471
*              Beneficiary list is showing entries twice in TCIB.
*
* 08/12/2020 - Enhancement 4020994 / Task 4037076
*              Changing BY.Payments reference to new component reference BY.Payments since
*              beneficiary and beneficiary links table has been moved to new module BY.
*--------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING EB.TransactionControl
    $USING BY.Payments
    $USING T2.ModelBank
*
    FN.TCIB.CUSTOMER.BENEFICIARY = 'F.TCIB.CUSTOMER.BENEFICIARY' ;*Intialising concat table name
*
    ALLOWED.TRANS.TYPE="BC":@VM:"OT":@VM:"AC"
    Y.TRANS.TYPE=EB.SystemTables.getRNew(BY.Payments.Beneficiary.ArcBenTransactionType) ;*Get transaction type value of beneficiary
    OLD.OWNING.CUS = EB.SystemTables.getROld(BY.Payments.Beneficiary.ArcBenOwningCustomer) ;* Get old Owning Customer
    Y.TRANS.ID = EB.SystemTables.getIdNew()  ;*Get Id of current beneficiary
    Y.OWNING.CUS = EB.SystemTables.getRNew(BY.Payments.Beneficiary.ArcBenOwningCustomer) ;*Get customer id of beneficiary
    R.BENEFICIARY = T2.ModelBank.TcibCustomerBeneficiary.Read(Y.OWNING.CUS, BEN.ERR) ;*Read Beneficiary table with current Id
*
    IF EB.SystemTables.getVFunction() EQ 'R' OR NOT(Y.TRANS.TYPE) THEN
        EB.TransactionControl.ConcatFileUpdate(FN.TCIB.CUSTOMER.BENEFICIARY,Y.OWNING.CUS,Y.TRANS.ID,'D','AL') ;* Delete the Beneficiary Id in concat file
    END
    IF (OLD.OWNING.CUS) AND (OLD.OWNING.CUS NE Y.OWNING.CUS) THEN
        EB.TransactionControl.ConcatFileUpdate(FN.TCIB.CUSTOMER.BENEFICIARY,OLD.OWNING.CUS,Y.TRANS.ID,'D','AL') ;* Delete the Beneficiary Id in concat file
    END
    IF Y.TRANS.TYPE[1,2] MATCHES ALLOWED.TRANS.TYPE THEN
        LOCATE Y.TRANS.ID IN R.BENEFICIARY SETTING POS ELSE
            EB.TransactionControl.ConcatFileUpdate(FN.TCIB.CUSTOMER.BENEFICIARY,Y.OWNING.CUS,Y.TRANS.ID,'I','AL') ;*Update the beneficiary Id in Concat file
        END
    END ELSE
        EB.TransactionControl.ConcatFileUpdate(FN.TCIB.CUSTOMER.BENEFICIARY,Y.OWNING.CUS,Y.TRANS.ID,'D','AL') ;* Delete the Beneficiary Id in concat file
    END
*
RETURN
*-----------------------------------------------------------------------------
END
