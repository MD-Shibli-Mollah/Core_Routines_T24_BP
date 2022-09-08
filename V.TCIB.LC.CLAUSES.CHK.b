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
* <Rating>-26</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.ModelBank
    SUBROUTINE V.TCIB.LC.CLAUSES.CHK
*-----------------------------------------------------------------------------
* This routine is used to nullfy the Narrative field, if it exist
*
*------------------------------------------------------------------------------
*                        M O D I F I C A T I O N S
*
* 26/06/13 - Enhancement 696318
*            TCIB support- to Edit the Document record
*
* 14/07/15 - Enhancement 1326996 / Task 1399947
*			 Incorporation of T components
* 
* 05/01/16 - Defect 1589822 / Task 1589878
*	         Componentisation package error
*
*-------------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING LC.Config

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

INITIALISE:


    IF EB.SystemTables.getRNew(LC.Config.Clauses.ClDescr) NE '' AND EB.SystemTables.getVFunction() EQ 'I' THEN

        EB.SystemTables.setRNew(LC.Config.Clauses.ClDescr, '')

    END

    RETURN

PROCESS:
    RETURN
    END
