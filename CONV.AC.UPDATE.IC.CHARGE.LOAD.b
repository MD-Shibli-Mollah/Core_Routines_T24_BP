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

*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE IC.InterestAndCapitalisation
    SUBROUTINE CONV.AC.UPDATE.IC.CHARGE.LOAD

*New job to update the IC.CHARGE.ID in account record if WAIVE.ALL is YES.
*This job sholud be run only once after upgrade.
*The field WAIVE.CHARGE can be inputted only for account level IC.CHARGE.
*So, IC.CHARGE with WAIVE.ALL s Yes is selected.
*--------------------------------------------------------------------------
*MODIFICATION HISTORY:
*********************
* 20/01/11 - Defect - 326698 / Task - 342588
*            New routine introduced to update IC.CHARGE.ID in ACCOUNT
*---------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_CONV.AC.UPDATE.IC.CHARGE.COMMON

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)

    FN.IC.CHARGE = 'F.IC.CHARGE'
    F.IC.CHARGE = ''
    CALL OPF(FN.IC.CHARGE, F.IC.CHARGE)


    RETURN
    END
