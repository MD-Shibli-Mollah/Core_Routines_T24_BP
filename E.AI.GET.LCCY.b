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
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AI.GET.LCCY(ENQ.DATA)

* Description:
*          Build routine attached to AI.EXT.PERS.ACCTS to display only Local Currency account

    $USING EB.SystemTables


    ENQ.DATA<2,-1> = "CURRENCY"
    ENQ.DATA<3,-1> = "EQ"
    ENQ.DATA<4,-1> = EB.SystemTables.getLccy()

    RETURN
