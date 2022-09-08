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
* <Rating>-28</Rating>
*-----------------------------------------------------------------------------
      $PACKAGE AC.ModelBank

    SUBROUTINE V.AC.POPULATE.LEDG.RECO
*-----------------------------------------------------------------------------
* This routine will be attached as AUTH.ROUTINE for the version.
* This will populate the current account number in the field LEDG.RECO.WITH
*
*
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 24/06/13 - Enhancement 688570 / Task 712129
*            Introducing Version auth routine
*
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING AC.AccountOpening
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS ; *Check and populate the ID.NEW in LEGG.RECO.WITH field
    RETURN

*
*-----------------------------------------------------------------------------
INITIALISE:

    RETURN
*
*-----------------------------------------------------------------------------
PROCESS:
* Check and populate the ID.NEW in LEGG.RECO.WITH field

    LOCATE EB.SystemTables.getIdNew() IN EB.SystemTables.getRNew(AC.AccountOpening.Account.LedgRecoWith)<1,1> SETTING ACC.POS ELSE ;* Populate the ID.NEW if not already
        tmp=EB.SystemTables.getRNew(AC.AccountOpening.Account.LedgRecoWith); tmp<1,ACC.POS>=EB.SystemTables.getIdNew(); EB.SystemTables.setRNew(AC.AccountOpening.Account.LedgRecoWith, tmp)
        tmp=EB.SystemTables.getRNew(AC.AccountOpening.Account.StmtRecoWith); tmp<1,ACC.POS>=EB.SystemTables.getIdNew(); EB.SystemTables.setRNew(AC.AccountOpening.Account.StmtRecoWith, tmp)
    END

    RETURN
*-----------------------------------------------------------------------------
    END
