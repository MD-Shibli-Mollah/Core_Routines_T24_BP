* @ValidationCode : MjoyNjc2OTY3MzM6Q3AxMjUyOjE2MDgyMTYxMTMwNTA6c2NoYW5kaW5pOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMToxODoxOA==
* @ValidationInfo : Timestamp         : 17 Dec 2020 20:11:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : schandini
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 18/18 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE FT.Channels
SUBROUTINE V.TC.UPDATE.FT.BEN.DETAILS
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* To get the detials of beneficiary using Beneficiary Id and default the same in FT
*
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Validation
* Attached To        : Version > FUNDS.TRANSFER,TC as a Validation routine for BENEFICIARY.ID
* IN Parameters      : NA
* Out Parameters     : NA
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 27/05/2016  - Enhancement 1694534 / Task 1741987
*               TCIB Componentization- Advanced Common Functional Components - Transfers/Payment/STO/Beneficiary/DD
*
* 08/12/2020 - Enhancement 4020994 / Task 4037076
*              Changing BY.Payments reference to new component reference BY.Payments since
*              beneficiary and beneficiary links table has been moved to new module BY.
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts
    $USING EB.SystemTables
    $USING BY.Payments
    $USING FT.Contract

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
*** <desc>Initialise commons </desc>
INITIALISE:
*---------
    BENEFICIARY.ID = ''; TRANSACTION.TYPE= ''; LINKED.BENEFICIARY = ''; CREDIT.ACCT.NO = '' ;*Initialising variables

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>Get beneficiary details for process</desc>
PROCESS:
*-------

    BENEFICIARY.ID = EB.SystemTables.getComi()      ;*Get beneficiary Id
*
    R.BENEFICIARY = BY.Payments.Beneficiary.Read(BENEFICIARY.ID,READ.ERR)                       ;*Get beneficiary details
    IF NOT(READ.ERR) THEN
        LINKED.BENEFICIARY = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenLinkToBeneficiary>     ;* Get linked beneficiary if specified
        
        IF LINKED.BENEFICIARY NE '' THEN
            R.BENEFICIARY =BY.Payments.Beneficiary.Read(LINKED.BENEFICIARY,READ.ERR)
            TRANSACTION.TYPE = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenTransactionType>               ;*Get beneficiary transaction type
            CREDIT.ACCT.NO = R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenBenAcctNo>                 ;*Get beneficiary account no
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.TransactionType, TRANSACTION.TYPE)  ;*Set transaction type to funds transfer
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAcctNo, CREDIT.ACCT.NO) ;*Set Credit account no to funds transfer
        END
    END
RETURN
*
*** </region>
*---------------------------------------------------------
END
