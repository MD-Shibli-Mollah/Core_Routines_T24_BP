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
* <Rating>66</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE IC.Config
    SUBROUTINE CONV.ACCOUNT.DATE.UPD(ACCT.ID,ACCT.REC,YFILE)
*****************************
* 12/07/06 - EN_10002987
*            New version.
*            ACCOUNT.DATE file is no more. Update the interest dates to the
*            respective ACCOUNT fields
*
* 28/09/07 - BG_100015298
*            The file routine is converted in to record routine.
*****************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
*****************************
    EQU AC.ACCT.CREDIT.INT TO 87
    EQU AC.ACCT.DEBIT.INT TO 88
    EQU AC.ACC.DEB.LIMIT TO 182
*
    EQU AC.DTE.DEBIT.DATES TO 1
    EQU AC.DTE.CREDIT.DATES TO 2
    EQU AC.DTE.DEBIT.LIMIT TO 3
********************************
***   Main processing   ***
*     ---------------     *
    GOSUB INITIALISE
    GOSUB PROCESS.ACCOUNT
    RETURN
**********************************
INITIALISE:

    FN.ACCOUNT.DATE = YFILE[".",1,1]:'.ACCOUNT.DATE'
    FV.ACCOUNT.DATE = ''
    CALL OPF(FN.ACCOUNT.DATE,FV.ACCOUNT.DATE)

    RETURN

**********************************************
PROCESS.ACCOUNT:
    READ ACCT.DATE.REC FROM FV.ACCOUNT.DATE, ACCT.ID ELSE ACCT.DATE.REC = ''
    IF ACCT.DATE.REC THEN
        ACCT.REC<AC.ACCT.DEBIT.INT> = ACCT.DATE.REC<AC.DTE.DEBIT.DATES>
        ACCT.REC<AC.ACCT.CREDIT.INT> = ACCT.DATE.REC<AC.DTE.CREDIT.DATES>
        ACCT.REC<AC.ACC.DEB.LIMIT> = ACCT.DATE.REC<AC.DTE.DEBIT.LIMIT>
*** Do no delete the account date record... requireded for re-run
***        CALL F.DELETE(FN.ACCOUNT.DATE,ACCT.ID)
    END
    RETURN
***********************************************
END
