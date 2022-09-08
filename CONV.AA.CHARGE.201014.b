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
* <Rating>77</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.Fees
    SUBROUTINE CONV.AA.CHARGE.201014(YID, R.RECORD, FN.FILE)

*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
* Conversion Routine to update TIER.COUNT in CHARGE records
*
*-----------------------------------------------------------------------------
** @package retaillending.AA
* @stereotype subroutine
* @ author bbalasubramanian@temenos.com
*-----------------------------------------------------------------------------
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc> </desc>
*
* 03/01/11 - Task : 77535
*            Ref: 56308
*            Conversion routine for the new field TIER.COUNT
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.CHARGE
    $INSERT I_AA.APP.COMMON

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

    ARRANGEMENT.ID = FIELD(YID, AA$SEP, 1)

    REF.LIMIT = ''
    MIN.CHG.AMT = ''
    MIN.CHG.WAIVE = ''

    REF.LIMIT = R.RECORD<19>
    MIN.CHG.AMT = R.RECORD<20>
    MIN.CHG.WAIVE = R.RECORD<21>

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Do Conversion>
*** <desc>Main control logic in the sub-routine</desc>
DO.CONVERSION:

    R.RECORD<19> = ''
    R.RECORD<20> = REF.LIMIT
    R.RECORD<21> = MIN.CHG.AMT
    R.RECORD<22> = MIN.CHG.WAIVE

    RETURN
*** </region>
*-----------------------------------------------------------------------------

END
