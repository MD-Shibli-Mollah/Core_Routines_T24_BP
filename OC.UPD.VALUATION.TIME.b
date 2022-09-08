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
* <Rating>-32</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.VALUATION.TIME(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
*The routine updates the time of valuation.
*-----------------------------------------------------------------------------
* Modification History :
*
* 21/09/15 - Enhancement 1461371 / Task 1461382
*            OTC Collateral and Valuation Reporting.
*
* 30/12/15 - EN_1226121 / Task 1568411
*			 Incorporation of the routine
*-----------------------------------------------------------------------------
    
    $USING EB.SystemTables
    $USING EB.API
*-----------------------------------------------------------------------------

    GOSUB INITIALISE ; *Initialise the variables
    GOSUB GET.TIME ; *Get time stamp


    RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables </desc>

    RET.VAL=''

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.TIME>
GET.TIME:
*** <desc>Get time stamp </desc>

    VAL.TIME = TIMEDATE()

    RET.VAL = VAL.TIME[1,8]

    RETURN
*** </region>

    END


