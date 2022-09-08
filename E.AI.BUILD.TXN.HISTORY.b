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
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
* 01/08/12- New Development
* Purpose - The routine is used to build a selection based on the account.
*-----------------------------------------------------------------------------
	$PACKAGE AI.ModelBank
    SUBROUTINE E.AI.BUILD.TXN.HISTORY(ENQ.DATA)
*-----------------------------------------------------------------------------
* Modification History
*
* 13/07/15 - Enhancement 1326996 / Task 1399903
*			  Incorporation of AI component	
*-----------------------------------------------------------------------------	
    $USING EB.SystemTables
    
    GOSUB PROCESS

    RETURN

PROCESS:
	DEFFUN 	System.getVariable()
    ACC.ID= System.getVariable('CURRENT.ACC')

    ENQ.DATA<2,-1> = "ACCT.ID"
    ENQ.DATA<3,-1> = "EQ"
    ENQ.DATA<4,-1> = ACC.ID

    RETURN

END
