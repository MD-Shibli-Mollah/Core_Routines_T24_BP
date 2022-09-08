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
	$PACKAGE EB.ModelBank
	
    SUBROUTINE E.CONV.DAT.TME
*
*
* 10/05/16 - Enhancement 1499014
*          - Task 1626129
*          - Routine incorporated
** This subroutine will return the Date Time Value
*
    $USING EB.Reports

    TIME.VAL = OCONV(TIME(), "MTS" )
    TOD.DAT = OCONV(DATE(),'D4')
    DAT.VAL = TOD.DAT[1,2]:"-":TOD.DAT[4,3]:"-":TOD.DAT[8,4] 
    EB.Reports.setOData("  ":DAT.VAL:"  ":TIME.VAL)

    RETURN
END
