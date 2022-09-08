* @ValidationCode : MjotMTMzMTc0NDEyODpDcDEyNTI6MTYwODIxNDMyNDc0NTpzY2hhbmRpbmk6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEyLjE6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Dec 2020 19:42:04
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
* <Rating>-41</Rating>
*-----------------------------------------------------------------------------
$PACKAGE T2.ModelBank
SUBROUTINE GET.NICKNAME.BEN
*-----------------------------------------------------------------------------
* This routine is used to populate transaction type from linked
* benficiary while creating utility payee / Beneficiary.
*-----------------------------------------------------------------------------
* *** <region name= Modification History>
*
* Modification History:
*---------------------
* 27/06/13 - Enhancement 590517
*            TCIB Retail
*
* 17/03/14 - Task 930084
*            Getting transaction type from linked beneficiary.
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
*
* 05/11/15 - Defect 1523105 / Task 1523352
*            Moved the application BENEFICIARY from FT to ST.
*            Hence Beneficiary application fields are referred using component BY.Payments
*
* 08/12/2020 - Enhancement 4020994 / Task 4037076
*              Changing BY.Payments reference to new component reference BY.Payments since
*              beneficiary and beneficiary links table has been moved to new module BY.
*** <region>
*----------------------------------------------------------------------------
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

*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise commons and do OPF </desc>
INITIALISE:
*---------

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc> Getting transaction type for beneficiary </desc>
PROCESS:
*------

    LINK.BEN = EB.SystemTables.getRNew(BY.Payments.Beneficiary.ArcBenLinkToBeneficiary)
    IF LINK.BEN THEN
        R.BEN = BY.Payments.Beneficiary.Read(LINK.BEN,BEN.ERR)
        EB.SystemTables.setRNew(BY.Payments.Beneficiary.ArcBenTransactionType, R.BEN<BY.Payments.Beneficiary.ArcBenTransactionType>)
    END
RETURN

*** </region>
*-----------------------------------------------------------------------------
END
