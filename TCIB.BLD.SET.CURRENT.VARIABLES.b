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
* <Rating>-16</Rating>
*-----------------------------------------------------------------------------
	$PACKAGE T5.ModelBank
    SUBROUTINE TCIB.BLD.SET.CURRENT.VARIABLES(ENQ.DATA)
*-----------------------------------------------------------------------------
* It is used to setup the current variables.
* attached as build routine.
* @author jayaramank@temenos.com
* INCOMING PARAMETER  -Portfolio Id and Currency.
* OUTGOING PARAMETER  - ENQ.DATA
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 28/04/2014 - Enhancement/Task_641974/995233
*              Set the current variables for Portfolio Id and portfolio Currency.
*
* 14/07/15 - Enhancement 1326996 / Task 1399917
*			 Incorporation of T components
*-------------------------------------------------------------------------------
  
	$USING EB.Browser
	
    LOCATE "PORTFOLIO.NO" IN ENQ.DATA<2,1> SETTING PORT.POS THEN      ;* Locate the field in the array.
        Y.PORTFOLIO.ID = ENQ.DATA<4,PORT.POS>     ;* Get the Portfolio number
    END
    LOCATE "PORTFOLIO.CCY" IN ENQ.DATA<2,1> SETTING CCY.POS THEN      ;* Locate the field in the array.
        Y.CCY = ENQ.DATA<4,CCY.POS>     ;* Get the Portfolio currency
    END

     EB.Browser.SystemSetvariable('CURRENT.SELECTED.PORTFOLIOS',Y.PORTFOLIO.ID)       ;* Set the portfolio number to Current variable.
     EB.Browser.SystemSetvariable('CURRENT.SELECTED.CCY',Y.CCY)   ;* Set the portfolio currency  to Current variable.

*
    RETURN
    END
