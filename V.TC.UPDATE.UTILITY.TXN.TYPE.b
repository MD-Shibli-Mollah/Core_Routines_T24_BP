* @ValidationCode : Mjo4MjIxMzUzNjc6Q3AxMjUyOjE2MDgyMTYyODM4MzI6c2NoYW5kaW5pOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMToxMToxMQ==
* @ValidationInfo : Timestamp         : 17 Dec 2020 20:14:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : schandini
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 11/11 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE ST.Channels
SUBROUTINE V.TC.UPDATE.UTILITY.TXN.TYPE
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
*
* To populate the transaction type from linked benficiary while creating utility payee / Beneficiary.
*
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Validation
* Attached To        : Version > BENEFICIARY,TC as a Validation routine for LINK.TO.BENEFICIARY
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
    LINK.BENEFICIARY = ''; R.BENEFICIARY = ''   ;*Initialising variables

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>Get beneficiary details for process</desc>
PROCESS:
*-------

    LINK.BENEFICIARY = EB.SystemTables.getRNew(BY.Payments.Beneficiary.ArcBenLinkToBeneficiary)     ;*Get beneficiary Id
*
    IF LINK.BENEFICIARY THEN
        R.BENEFICIARY = BY.Payments.Beneficiary.Read(LINK.BENEFICIARY,BEN.ERR)      ;*Read Beneficiary
        EB.SystemTables.setRNew(BY.Payments.Beneficiary.ArcBenTransactionType, R.BENEFICIARY<BY.Payments.Beneficiary.ArcBenTransactionType>)    ;*Set transaction type for beneficiary
    END
*
RETURN

*** </region>
*-----------------------------------------------------------------------------
END

