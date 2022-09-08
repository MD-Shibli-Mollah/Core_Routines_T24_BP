* @ValidationCode : MjotMzc4NjY2MDA5OkNwMTI1MjoxNjA4MjE2Mjg0MjgyOnNjaGFuZGluaTo1OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEyLjE6Mjg6Mjg=
* @ValidationInfo : Timestamp         : 17 Dec 2020 20:14:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : schandini
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 28/28 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE ST.Channels
SUBROUTINE V.TC.UPDATE.BEN.CONCAT
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
*
* To update and remove the beneficiary Id in concat file while creating or deleting the beneficiary from TC products.
*
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Authorisation routine
* Attached To        : Version control > BENEFICIARY as a Authorisation routine
* IN Parameters      : NA
* Out Parameters     : NA
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 27/05/2016  - Enhancement 1694534 / Task 1741987
*               TCIB Componentization- Advanced Common Functional Components - Transfers/Payment/STO/Beneficiary/DD
*
* 01/09/2016 - Defect 1843192 / Task 1845471
*              Beneficiary list is showing entries twice in TCIB.
*
* 18/03/2019  - Enhancement - 2867757 / Task 3034702
*               External Beneficiary listing is handled
*
* 08/12/2020 - Enhancement 4020994 / Task 4037076
*              Changing BY.Payments reference to new component reference BY.Payments since
*              beneficiary and beneficiary links table has been moved to new module BY.
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts
    $USING EB.SystemTables
    $USING EB.TransactionControl
    $USING BY.Payments
    $USING ST.Channels

*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise variables used in this routine</desc>
INITIALISE:
*---------
    TRANSACTION.TYPE = ''; TRANSACTION.ID = ''; CUSTOMER.ID = ''; R.BENEFICIARY = ''   ;*Initialising variables
    ID.CONCAT = ''; BEN.ERR = ''; POS = ''  ;*Initialising variables

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>Concat file update process for beneficiary</desc>
PROCESS:
*-------

    FN.TC.CUSTOMER.BENEFICIARY = 'F.TC.CUSTOMER.BENEFICIARY'    ;*Intialising concat table name
*
    ALLOWED.TRANS.TYPE="BC":@VM:"OT"
    TRANSACTION.TYPE = EB.SystemTables.getRNew(BY.Payments.Beneficiary.ArcBenTransactionType)   ;*Get transaction type value of beneficiary
    TRANSACTION.ID = EB.SystemTables.getIdNew()         ;*Get Id of current beneficiary
    OLD.OWNING.CUS = EB.SystemTables.getROld(BY.Payments.Beneficiary.ArcBenOwningCustomer) ;* Get old Owning Customer
    CUSTOMER.ID = EB.SystemTables.getRNew(BY.Payments.Beneficiary.ArcBenOwningCustomer) ;*Get customer id of beneficiary
    BEN.PRODUCT = EB.SystemTables.getRNew(BY.Payments.Beneficiary.ArcBenPrefPymtProduct);*Get product of beneficiary
    
    R.BENEFICIARY = ST.Channels.TcCustomerBeneficiary.Read(CUSTOMER.ID, BEN.ERR) ;*Read Beneficiary table with current Id
*
    IF EB.SystemTables.getVFunction() EQ 'R' OR NOT(TRANSACTION.TYPE) THEN
        EB.TransactionControl.ConcatFileUpdate(FN.TC.CUSTOMER.BENEFICIARY,CUSTOMER.ID,TRANSACTION.ID,'D','AL') ;* Delete the Beneficiary Id in concat file
    END
    IF (OLD.OWNING.CUS) AND (OLD.OWNING.CUS NE CUSTOMER.ID) THEN
        EB.TransactionControl.ConcatFileUpdate(FN.TC.CUSTOMER.BENEFICIARY,OLD.OWNING.CUS,TRANSACTION.ID,'D','AL') ;* Delete the Beneficiary Id in concat file
    END
*
    IF TRANSACTION.TYPE[1,2] MATCHES ALLOWED.TRANS.TYPE OR BEN.PRODUCT EQ 'EXTERNAL' THEN		;* write the beneficiary id if it is stored via external payment order creation
        LOCATE TRANSACTION.ID IN R.BENEFICIARY SETTING POS ELSE  ;*Case for new beneficiary
            EB.TransactionControl.ConcatFileUpdate(FN.TC.CUSTOMER.BENEFICIARY,CUSTOMER.ID,TRANSACTION.ID,'I','AL')   ;*Update the beneficiary Id in Concat file
        END
    END ELSE
        EB.TransactionControl.ConcatFileUpdate(FN.TC.CUSTOMER.BENEFICIARY,CUSTOMER.ID,TRANSACTION.ID,'D','AL') ;* Delete the Beneficiary Id in concat file
    END
*
RETURN
*** </region>
*-----------------------------------------------------------------------------

END

