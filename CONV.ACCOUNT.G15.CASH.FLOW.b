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
* <Rating>72</Rating>
*-----------------------------------------------------------------------------
* Version 46 25/10/00 GLOBUS Release No. G14.0.00 03/07/03
*
*************************************************************************
*
    $PACKAGE RE.ConBalanceUpdates
    SUBROUTINE CONV.ACCOUNT.G15.CASH.FLOW(ACCT.ID,ACCT.REC,FILE)
*
*************************************************************************
* This routine is to  initialise all related CASH.FLOW fields.
***************************************************************************
* Modifications:
* =============
* 29/10/04 - BG_100007563
*            To initialise all CASH.FLOW related fields in ACCOUNT and
*            to set the FIRST.AF.DATE field as the first available date
*            from the ladder. 
*************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SPF
*************************************************************************
*

    GOSUB INITIALISE

    GOSUB UPDATE.ACCOUNT



    RETURN
*
*************************************************************************
INITIALISE:
*
    EQUATE AC.VALUE.DATE TO 79
    EQUATE AC.CREDIT.MOVEMENT TO 80
    EQUATE AC.DEBIT.MOVEMENT TO 81
    EQUATE AC.VALUE.DATED.BAL TO 82
    EQUATE AC.OPEN.VAL.DATED.BAL TO 86
    EQUATE AC.AVAILABLE.DATE TO 150
    EQUATE AC.FIRST.AF.DATE TO 172


    RETURN

*************************************************************************
*
UPDATE.ACCOUNT:
* 
* Get rid of Cash flow fields.
    ACCT.REC<AC.VALUE.DATE> = ''        ;* Value date
    ACCT.REC<AC.CREDIT.MOVEMENT> = ''   ;* Cr Movement
    ACCT.REC<AC.DEBIT.MOVEMENT> = ''    ;* Dr Movement
    ACCT.REC<AC.VALUE.DATED.BAL> = ''   ;* Value dated Bal
    ACCT.REC<AC.OPEN.VAL.DATED.BAL> = ''          ;* Open Val Dated Bal
*
* Setting up the FIRST.AF.DATE as the first available date in the ladder.
* If there is no available date then leave it as blank.

    FIRST.AF.DATE = ACCT.REC<AC.AVAILABLE.DATE><1,1>

    IF FIRST.AF.DATE <> '' THEN ACCT.REC<AC.FIRST.AF.DATE> = FIRST.AF.DATE


    RETURN
*******************************************************************************

END
