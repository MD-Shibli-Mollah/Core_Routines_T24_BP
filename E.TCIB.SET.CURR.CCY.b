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
	$PACKAGE T5.ModelBank
    SUBROUTINE E.TCIB.SET.CURR.CCY(ENQ.DATA)
*Setting currency value for the current variable CURRENT.SELECTED.CCY based
*on VALUATION.CCY selection field
*@author manikandant@temenos.com
*INCOMING PARAMETER - VALUATION.CCY
*-----------------------------------------------------------------------------
* Modification History:
*---------------------
* TCIB Wealth
* 30/04/2014 - Enhancement/Task ID - 641974/984685
*              Setting currency value for the current variable CURRENT.SELECTED.CCY
*
* 14/07/15 - Enhancement 1326996 / Task 1399917
*			 Incorporation of T components
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts
     
    $USING EB.Browser
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>

    GOSUB INITIALISE
    RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Setting currency value for the current variable CURRENT.SELECTED.CCY
*** based on VALUATION.CCY selection field </desc>
INITIALISE:
*---------

    LOCATE "VALUATION.CCY" IN ENQ.DATA<2,1> SETTING CCY.POS THEN
        VAL.CCY = ENQ.DATA<4,CCY.POS>
    END

     EB.Browser.SystemSetvariable('CURRENT.SELECTED.CCY',VAL.CCY)

    RETURN

*** </region>
END
