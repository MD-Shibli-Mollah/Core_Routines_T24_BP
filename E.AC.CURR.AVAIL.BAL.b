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
* <Rating>-9</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.AC.CURR.AVAIL.BAL(BALANCE,IN.DATA)
*************************************************************************
* 15/05/06 - EN_10002924
*            Use core routine and set the flag ENT.TODAY.UPDATE in
*            in ACCOUNT.PARAMETER to get OPEN.ACTUAL.BAL and OPEN.CLEARED.BAL
*            to avoid the usage of OPEN balances fields in ACCOUNT application
*            and hence allow removal of ACCT.ENT.TODAY .
*
* 08/11/06 - CI_10045362
*            Move this code to AC.CURR.AVAIL.BAL routine.
*
* 27/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
********************************************************************************
    $USING AC.CashFlow

    AC.CashFlow.CurrAvailBal(BALANCE,IN.DATA)
*
    RETURN
*
    END
