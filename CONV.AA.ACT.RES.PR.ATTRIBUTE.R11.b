* @ValidationCode : MjotOTI4MDA3NzM5OkNwMTI1MjoxNTY3MDUxMDcxNDEzOm1hcmNoYW5hOjE6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTA3LjIwMTkwNjEyLTAzMjE6NTM6NTE=
* @ValidationInfo : Timestamp         : 29 Aug 2019 09:27:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : marchana
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 51/53 (96.2%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190612-0321
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-85</Rating>
*-----------------------------------------------------------------------------

$PACKAGE AA.ActivityRestriction
SUBROUTINE CONV.AA.ACT.RES.PR.ATTRIBUTE.R11(YID, R.RECORD, FN.FILE)

*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
*
*-----------------------------------------------------------------------------
** @package retaillending.AA
* @stereotype subroutine
* @author sivall@temenos.com
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modification done in the sub-routine</desc>
* Modification History
*
* 05/04/11 - Defect: 178652
*            Task: 185623
*            In the UPDATE.ACTIVITY.BASED.FIELDS para, while checking for RESTRICT.TYPE EQ "ERROR",
*            the record buffer was wrongly used as AA.ACTIVITY.RESTRICTION instead of AA.ACTIVITY.RESTRICTION.NEW
*
* 8/28/19  - Defect: 3303002
*            Task  : 3309433
*            Blank override on backdated payments.
*            Changes made in the routine to Update PR.BRK.MSG only PR.BRK.MSG is available in record
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ACTIVITY.RESTRICTION

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB STORE.DETAILS
    GOSUB DO.CONVERSION
    GOSUB CLEAR.PR.ATTRIBUTE.FIELDS
    GOSUB RESTORE.DETAILS

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initilaise</desc>
INITIALISE:


RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Store Account Details>
*** <desc>Store the Account Details Record</desc>
STORE.DETAILS:

    AA.ACTIVITY.RESTRICTION = R.RECORD
    AA.ACTIVITY.RESTRICTION.NEW = AA.ACTIVITY.RESTRICTION

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Do Conversion>
*** <desc>Main control logic in the sub-routine</desc>
DO.CONVERSION:

    IF AA.ACTIVITY.RESTRICTION<AA.ACR.PR.ATTRIBUTE> THEN

        TOTAL.RULE.COUNT = DCOUNT(AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.RULE.NAME>, VM)

        TOTAL.PR.COUNT = DCOUNT(AA.ACTIVITY.RESTRICTION<AA.ACR.PR.ATTRIBUTE>, VM)

        FOR C.NT = 1 TO TOTAL.PR.COUNT
            TOTAL.RULE.COUNT = TOTAL.RULE.COUNT + 1
            GOSUB UPDATE.RULE.BASED.FIELDS        ;* Update Rule based fields.
            GOSUB UPDATE.ACTIVITY.BASED.FIELDS    ;* Update Activity based fields
        NEXT C.NT

    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= UPDATE.RULE.BASED.FIELDS>
*** <desc>Update Rule based fields. </desc>
UPDATE.RULE.BASED.FIELDS:

    AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.RULE.NAME, TOTAL.RULE.COUNT> = AA.ACTIVITY.RESTRICTION<AA.ACR.PR.ATTRIBUTE, C.NT>
    AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.PERIODIC.ATTRIBUTE, TOTAL.RULE.COUNT> = AA.ACTIVITY.RESTRICTION<AA.ACR.PR.ATTRIBUTE, C.NT>
    AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.RULE.ACTIVITY.ID, TOTAL.RULE.COUNT> = AA.ACTIVITY.RESTRICTION<AA.ACR.ACTIVITY.ID, C.NT>
    AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.PERIODIC.VALUE, TOTAL.RULE.COUNT> = AA.ACTIVITY.RESTRICTION<AA.ACR.PR.VALUE, C.NT>

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= UPDATE.ACTIVITY.BASED.FIELDS>
*** <desc>Update Activity based fields </desc>
UPDATE.ACTIVITY.BASED.FIELDS:


    AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.ACTIVITY.ID, TOTAL.RULE.COUNT> = AA.ACTIVITY.RESTRICTION<AA.ACR.ACTIVITY.ID, C.NT>
    AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.RULE.ID, TOTAL.RULE.COUNT> = AA.ACTIVITY.RESTRICTION<AA.ACR.PR.ATTRIBUTE, C.NT>
    AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.RESTRICT.TYPE, TOTAL.RULE.COUNT> = AA.ACTIVITY.RESTRICTION<AA.ACR.PR.BRK.RES, C.NT>

    IF AA.ACTIVITY.RESTRICTION<AA.ACR.PR.BRK.MSG, C.NT> THEN ;* Update only PR.BRK.MSG is available
        IF AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.RESTRICT.TYPE, TOTAL.RULE.COUNT> EQ "ERROR" THEN

            AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.RESTRICT.ERROR, TOTAL.RULE.COUNT> = AA.ACTIVITY.RESTRICTION<AA.ACR.PR.BRK.MSG, C.NT>

        END ELSE

            AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.RESTRICT.OVR, TOTAL.RULE.COUNT> = AA.ACTIVITY.RESTRICTION<AA.ACR.PR.BRK.MSG, C.NT>

        END
    END
    AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.PROPERTY, TOTAL.RULE.COUNT> =  AA.ACTIVITY.RESTRICTION<AA.ACR.PR.BRK.CHARGE, C.NT>
    AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.APP.PERIOD, TOTAL.RULE.COUNT> =  AA.ACTIVITY.RESTRICTION<AA.ACR.PR.APP.PERIOD, C.NT>
    AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.APP.METHOD, TOTAL.RULE.COUNT> =  AA.ACTIVITY.RESTRICTION<AA.ACR.PR.APP.METHOD, C.NT>

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CLEAR.PR.ATTRIBUTE.FIELDS>
*** <desc>Clear the Periodic attribute fields fields </desc>
CLEAR.PR.ATTRIBUTE.FIELDS:

    AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.PR.ATTRIBUTE> = ""
    AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.PR.VALUE> = ""
    AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.PR.BRK.RES> = ""
    AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.PR.BRK.MSG> = ""
    AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.PR.BRK.CHARGE> = ""
    AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.PR.APP.METHOD> = ""
    AA.ACTIVITY.RESTRICTION.NEW<AA.ACR.PR.APP.PERIOD> = ""

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= Restore Record>
*** <desc>Restore Updated Account Details Record</desc>
RESTORE.DETAILS:

    R.RECORD  = AA.ACTIVITY.RESTRICTION.NEW

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
