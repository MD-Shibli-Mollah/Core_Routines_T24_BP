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
    $PACKAGE AC.BalanceUpdates
    SUBROUTINE CONV.COMB.ACCTDT.RCB.R5(ACCT.ID,R.ACCT,FILE)
*----------------------------------------------------------------------------
* wrapper routine for perform combined conversion on account to avoid repeated
* selection on files during conversion.
*---------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.RE.CONTRACT.BALANCES
    $INSERT I_F.DATES


    CALL CONV.ACCOUNT.EXP.DATE.G152(ACCT.ID,R.ACCT,FILE)

    CALL CONV.RE.BALANCES(ACCT.ID,R.ACCT,FILE)

    RETURN

END
