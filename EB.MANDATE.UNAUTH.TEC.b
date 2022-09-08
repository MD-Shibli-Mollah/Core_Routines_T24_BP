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
* <Rating>-18</Rating>
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Subroutine type : SUBROUTINE
* Attached to     : TEC.ITEMS record MANDATE.INIT
* Attached as     : EVENT API
*----------------------------------------------------------------------------------------------------------------
*Description:
************
*The Event API routine used to capture the event, when the signatory value is null in the mandate application.
*-----------------------------------------------------------------------------------------------------------------
*Modification History:
**********************
* 02/08/13 - Task 668952/ Enhancement 644961
*            Email notification to the signatories for pending payments
*
* 18/08/14 - Task 911253 / Enhancement 897278
*            Customer & Account mandates. Use the API EB.GET.APPL.FIELD.DATE
*            to get the SIGNATORY field value.
*
* 06/04/16 - Enhancement 1474899
*          - Task 1486674
*          - Routine incorporated
*
*-----------------------------------------------------------------------------------------------------------------
    $PACKAGE EB.Mandate
    
    SUBROUTINE EB.MANDATE.UNAUTH.TEC(TEC.ITEM,SUB.ID,METRICS.VALUE,AFTER.IMG.REC,DYN.LINKED.VALUE,UNAUTH.OR.AUTH,TEC.API.CHECK)

    $USING EB.Mandate
    $USING EB.API
    $USING EB.SystemTables

    GOSUB PROCESS
    RETURN
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc>Check whether the sigantory is null in mandate application and record the event</desc>

    ERR.MSG = ''
    DIM APPLICATION.RECORD(EB.SystemTables.SysDim)    ;* Used to pass R.NEW
    DATA.REQUIRED = 1
    APPL.FIELD.NAME = 'SIGNATORY'       ;* Field name from the application
    APPLICATION.DETAILS<1> = EB.SystemTables.getApplication()          ;* ID of the EB.MANDATE.PARAMETER
    APPLICATION.DETAILS<2> = EB.SystemTables.getIdNew()     ;* ID of the transaction
    APPL.RECORD.DYN = EB.SystemTables.getDynArrayFromRNew()
    MATPARSE APPLICATION.RECORD FROM APPL.RECORD.DYN
    APPL.FIELD.DATA = ''      ;* Returns field value
    EB.Mandate.GetApplFieldData (APPLICATION.DETAILS, MAT APPLICATION.RECORD, MANDATE.DETAILS, DATA.REQUIRED, APPL.FIELD.NAME, '', APPL.FIELD.DATA, ERR.MSG, '', '')

    IF APPL.FIELD.DATA EQ '' THEN
        TEC.API.CHECK = 1     ;*record the event
    END

    RETURN
*** </region>

END
