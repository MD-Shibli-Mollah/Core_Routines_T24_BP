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
* <Rating>-47</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ActivityRestriction
    SUBROUTINE CONV.AA.ACTIVITY.RESTRICTION(YID, R.RECORD, FN.FILE)

*** <region name= Program Description>
*** <desc>Conversion routine for activity restriction property class</desc>
* Program Description
*
* Conversion Routine for activity restriction property class
*
*-----------------------------------------------------------------------------
** @package retaillending.AA
* @stereotype subroutine
* @ author tamaria@temenos.com
*-----------------------------------------------------------------------------
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ACTIVITY.RESTRICTION

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB STORE.ACTIVITY.RESTRICTION
    GOSUB DO.CONVERSION
    GOSUB RESTORE.ACTIVITY.RESTRICTION

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initilaise</desc>
INITIALISE:


    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Store Activity Restriction>
*** <desc>Store the Activity Restriction Record</desc>
STORE.ACTIVITY.RESTRICTION:

    AA.ACTIVITY.RESTRICTION = R.RECORD

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Do Conversion>
*** <desc>Main control logic in the sub-routine</desc>
DO.CONVERSION:


    AA.ACTIVITY.RESTRICTION<AA.ACR.RESTRICT.ERROR> = AA.ACTIVITY.RESTRICTION<9>
    AA.ACTIVITY.RESTRICTION<9> = ""

    AA.ACTIVITY.RESTRICTION<AA.ACR.RESTRICT.OVR> = AA.ACTIVITY.RESTRICTION<8>
    AA.ACTIVITY.RESTRICTION<8> = ""

    AA.ACTIVITY.RESTRICTION<AA.ACR.RESTRICT.TYPE> = AA.ACTIVITY.RESTRICTION<5>
    AA.ACTIVITY.RESTRICTION<5> = ""

    AA.ACTIVITY.RESTRICTION<AA.ACR.RESTRICT>=AA.ACTIVITY.RESTRICTION<4>
    AA.ACTIVITY.RESTRICTION<4> = ""

    AA.ACTIVITY.RESTRICTION<AA.ACR.ACTIVITY.ID> = AA.ACTIVITY.RESTRICTION<3>
    AA.ACTIVITY.RESTRICTION<3> = ""


    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Restore Record>
*** <desc>Restore Updated Activity Restriction Record</desc>
RESTORE.ACTIVITY.RESTRICTION:

    R.RECORD  = AA.ACTIVITY.RESTRICTION

    RETURN
*** </region>
*-----------------------------------------------------------------------------
END
