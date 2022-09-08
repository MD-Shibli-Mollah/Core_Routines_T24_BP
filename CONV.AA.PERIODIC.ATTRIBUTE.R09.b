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
* <Rating>-38</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.Rules
    SUBROUTINE CONV.AA.PERIODIC.ATTRIBUTE.R09(REC.ID,R.PERIOD,YFILE)

*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
* Record Conversion routine to convert existing Periodic Attribute to include the new added fields
*
*
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History
*
* 04/02/2009 - BG_100021933
*              Change field name DURATION.TYPE to PERIOD.TYPE.
*
*** </region> 
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
*
** Input:
*
** REC.ID   - Record Id
** R.PERIOD - Periodic Attribute Record
** YFILE    - File Name
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.PERIODIC.ATTRIBUTE
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
INITIALISE:

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main process>
*** <desc>Description for the main process</desc>
PROCESS:

*For Calendar
    R.PERIOD<AA.PA.DATE.TYPE> = ''      ;*Turn the calendar type to NULL as the period for calendar should be in multiples of 12 for M or in Y
*For Duration Type
    BEGIN CASE

    CASE R.PERIOD<AA.PA.PERIOD.TYPE> EQ 'ACTUAL'
        R.PERIOD<AA.PA.PERIOD.TYPE> = 'ROLLING'
        GOSUB GET.RULE.START
        IF NOT(R.PERIOD<AA.PA.RULE.START>) THEN
            R.PERIOD<AA.PA.RULE.START> = 'ARRANGEMENT'
        END

    CASE R.PERIOD<AA.PA.PERIOD.TYPE> EQ 'LIFE'
        GOSUB GET.RULE.START
        IF NOT(R.PERIOD<AA.PA.RULE.START>) THEN
            R.PERIOD<AA.PA.RULE.START> = 'ARRANGEMENT'
        END

    CASE R.PERIOD<AA.PA.PERIOD.TYPE> EQ 'PRODUCT'
        R.PERIOD<AA.PA.PERIOD.TYPE> = 'LIFE'
        GOSUB GET.RULE.START
        IF NOT(R.PERIOD<AA.PA.RULE.START>) THEN
            R.PERIOD<AA.PA.RULE.START> = 'AGREEMENT'
        END

    END CASE
*

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get Rule Start Type>
*** <desc>Get the Rule Start Type from the Base Date</desc>
GET.RULE.START:

    BEGIN CASE

    CASE R.PERIOD<AA.PA.RULE.START> EQ 'AGREEMENT.DATE'
        R.PERIOD<AA.PA.RULE.START> = 'AGREEMENT'

    CASE R.PERIOD<AA.PA.RULE.START> EQ 'START.DATE'
        R.PERIOD<AA.PA.RULE.START> = 'START'

    CASE R.PERIOD<AA.PA.RULE.START> EQ 'TODAY'
        R.PERIOD<AA.PA.RULE.START> = 'ARRANGEMENT'

    END CASE
    RETURN
*** </region>
*-----------------------------------------------------------------------------
