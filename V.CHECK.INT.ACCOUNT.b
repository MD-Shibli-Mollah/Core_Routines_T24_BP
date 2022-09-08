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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE V.CHECK.INT.ACCOUNT
*-----------------------------------------------------------------------------
* This routine will be attached as ID.ROUTINE for the version.
* This will Validate the entered id is a valid Internal Account
*
*
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 24/06/13 - Enhancement 688570 / Task 712129
*            Introducing Version ID routine
*
* 07/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING AC.AccountOpening
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS ; *Check if the account is valid internal account
    RETURN

*
*-----------------------------------------------------------------------------
INITIALISE:

    RETURN
*
*-----------------------------------------------------------------------------
PROCESS:
* Check and populate the ID.NEW in LEGG.RECO.WITH field

    INTERNAL.ACC = 0
    tmp.COMI = EB.SystemTables.getComi()
    AC.AccountOpening.IntAcc(tmp.COMI , INTERNAL.ACC) ;* Check if entered id is internal else throw error

    IF NOT(INTERNAL.ACC) THEN
        EB.SystemTables.setE('Internal Account Id Only Allowed')
    END

    RETURN
*-----------------------------------------------------------------------------
    END
