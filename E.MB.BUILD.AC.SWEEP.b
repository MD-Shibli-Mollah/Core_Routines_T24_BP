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
*-----------------------------------------------------------------------------
* <Rating>-42</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.BUILD.AC.SWEEP(ENQ.DATA)
*----------------------------------------------------------------------------
* The main purpose of this routine is used to for a new selection criteria for the
* enquiry ACCT.SWEEP when the selection criteria is not specified (i.e ACCOUNT.NO).
*--------------------------------------------------------------------------------
*Modification History:
*
*16/09/08 - BG_100019949
*           Routine restructure
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*--------------------------------------------------------------------------------
    $USING RS.Sweeping
    $USING EB.DataAccess

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN

*------------
INITIALISE:
*------------
*Initialise the variables and open the respective files

    FN.AC.ACCT.LINK.CONCAT = "F.AC.ACCOUNT.LINK.CONCAT"
    F.AC.ACCT.LINK.CONCAT = ''
    EB.DataAccess.Opf(FN.AC.ACCT.LINK.CONCAT,F.AC.ACCT.LINK.CONCAT)

    AC.SWEEP.ID = '' ; SWAP.ARRAY = '' ; ACCOUNT.ARRAY = ''
    AC.SWEEP.ID = ENQ.DATA<4,1>

    RETURN

*--------
PROCESS:
*---------
* Check if the selection criteria is not specified and then form the selection criteria
* that has to be passed to the enquiry.

    IF AC.SWEEP.ID NE '' THEN
        RETURN
    END
    ELSE
    GOSUB PROCESS.ARRAY
    END
    RETURN

*---------------
PROCESS.ARRAY:
*--------------
* Select all the records from the file AC.ACCOUNT.LINK.CONCAT and read the records to form an array
* with distinct sweep id's.

    SEL.ACCT.LINK = "SELECT ":FN.AC.ACCT.LINK.CONCAT
    EB.DataAccess.Readlist(SEL.ACCT.LINK,SEL.LIST,'',NO.OF.SW,SW.ERR)

    LOOP
        REMOVE AC.SWEEP.ID FROM SEL.LIST SETTING SW.MORE
    WHILE AC.SWEEP.ID:SW.MORE
        EB.DataAccess.FRead(FN.AC.ACCT.LINK.CONCAT,AC.SWEEP.ID,R.SWEEP.REC,F.AC.ACCT.LINK.CONCAT,SW.ERR1)
        ACCOUNT.SWEEP.ID = R.SWEEP.REC<1>
        LOCATE ACCOUNT.SWEEP.ID IN SWAP.ARRAY<1> SETTING SW.POS ELSE
        IF SWAP.ARRAY NE '' THEN
            SWAP.ARRAY := @FM : ACCOUNT.SWEEP.ID
        END ELSE
            SWAP.ARRAY = ACCOUNT.SWEEP.ID
        END
        IF ACCOUNT.ARRAY NE '' THEN
            ACCOUNT.ARRAY := @FM : AC.SWEEP.ID
        END ELSE
            ACCOUNT.ARRAY = AC.SWEEP.ID
        END
    END
    REPEAT

    CONVERT @FM TO " " IN ACCOUNT.ARRAY
    ENQ.DATA<2,1> = "ACCOUNT.ID"
    ENQ.DATA<3,1> = "EQ"
    ENQ.DATA<4,1> = ACCOUNT.ARRAY
    RETURN
*-----------------------------------------------------------------------------

    END
