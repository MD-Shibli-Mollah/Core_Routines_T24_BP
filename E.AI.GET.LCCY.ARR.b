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
* <Rating>-14</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AI.GET.LCCY.ARR(ENQ.DATA)
*--------------------------------------------------------------------------------------------
* Description:
*          Build routine attached to AI.EXT.PERS.ACCTS.LCY.ARR to display only Local Currency account
*--------------------------------------------------------------------------------------------
* Modification History :
*=========================================================================
* 19/03/14 - Defect - 703931 / Task - 945103
*            Replacing position value 1 in the Locate statement instead of -1.
*
*=========================================================================
    $USING EB.SystemTables


    GOSUB PROCESS

    RETURN

PROCESS:

    LOCATE "LINKED.APPL.ID" IN ENQ.DATA<2,1> SETTING POS THEN

    ACCT.ID=ENQ.DATA<4,POS>

    END

    ENQ.DATA<2,1> = "CURRENCY"
    ENQ.DATA<3,1> = "EQ"
    ENQ.DATA<4,1> = EB.SystemTables.getLccy()
    ENQ.DATA<2,2> = "LINKED.APPL.ID"
    ENQ.DATA<3,2> = "NE"
    ENQ.DATA<4,2> = ACCT.ID

    RETURN
    END
