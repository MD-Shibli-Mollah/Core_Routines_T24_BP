* @ValidationCode : MToyMDU5NDkzNDI4OlVURi04OjE1MTk4MjY3NzcyMjk6am9obnNvbjotMTotMTowOi0xOmZhbHNlOk4vQTpOL0E6MDow
* @ValidationInfo : Timestamp         : 28 Feb 2018 19:36:17
* @ValidationInfo : Encoding          : UTF-8
* @ValidationInfo : User Name         : johnson
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 0/0 (0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.Interest    
    SUBROUTINE CONV.AA.INTEREST.201607(YID, R.RECORD, FN.FILE)
 
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
** This routine will convert NEGATIVE.RATE TO TIER.NEGATIVE.RATE
*
*-----------------------------------------------------------------------------
** Field Name                           Position
*-----------------------------------------------------------------------------
*                               201603  R16
*-----------------------------------------------------------------------------
* IntNegativeRate               7       7
* IntTierNegativeRate           N/A     23
* IntTierAmount                 24      25
* Last field position available 94      95   ;*
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
** @package   AA.Interest
* @stereotype subroutine
* @author Mo, Muhammad, Mehran, Veronika
*-----------------------------------------------------------------------------
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= MODIFICATION HISTORY>
***
* 26/04/16 - Enhancement : 1651290
*            Task :        1660401
*            New field TIER.NEGATIVE.RATE added
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB DO.CONVERSION

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initilaise</desc>
INITIALISE:
   
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Do Conversion>
*** <desc>Main control logic in the sub-routine</desc>
DO.CONVERSION:

    TIER.CNT = COUNT(R.RECORD<25>, @VM) + 1
    NEGATIVE.RATE = R.RECORD<7>
    
    FOR IDX = 1 TO TIER.CNT
        R.RECORD<23, IDX> = NEGATIVE.RATE ;* negative rate 
    NEXT IDX
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------
END
