* @ValidationCode : Mjo0MTk2NzE2ODU6Q3AxMjUyOjE0ODc3NDE2ODMyNzk6Ym1hbGxpa2FyanVuYW46MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDIuMDoxNjoxNg==
* @ValidationInfo : Timestamp         : 22 Feb 2017 11:04:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bmallikarjunan
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 16/16 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-18</Rating>
*-----------------------------------------------------------------------------
* Subroutine type : SUBROUTINE
* Attached to     : TEC.ITEMS record MANDATE.AUTH
* Attached as     : EVENT API
*----------------------------------------------------------------------------------------------------------------
*Description:
************
*The Event API routine used to capture the event, when the signatory value is not null in the mandate application.
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
* 21/02/17 - Defect 2013863 / Task 2026928
*            Email notifications are triggered to signatories twice since MANDATE.AUTH 
*            is also called at input stage itself. So TEC.API.CHECK must be set to 1 only
*            if APPL.FIELD.DATA is NOT NULL
*-----------------------------------------------------------------------------------------------------------------
    $PACKAGE EB.Mandate     
    SUBROUTINE EB.MANDATE.AUTH.TEC(TEC.ITEM,SUB.ID,METRICS.VALUE,AFTER.IMG.REC,DYN.LINKED.VALUE,UNAUTH.OR.AUTH,TEC.API.CHECK)
    
    $USING EB.Mandate
    $USING EB.API
    $USING EB.SystemTables 

    GOSUB PROCESS
    RETURN
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
*** <desc>Check whether the signatory has value and record the event</desc>

    ERR.MSG = ''
    DIM APPLICATION.RECORD(EB.SystemTables.SysDim)    ;* Used to pass R.NEW
    DATA.REQUIRED = 1
    APPL.FIELD.NAME = 'SIGNATORY'       ;* Field name from the application
    APPLICATION.DETAILS<1> = EB.SystemTables.getApplication()          ;* ID of the EB.MANDATE.PARAMETER
    APPLICATION.DETAILS<2> = EB.SystemTables.getIdNew()     ;* ID of the transaction

    APP.RECORD.DYN = EB.SystemTables.getDynArrayFromRNew()
    MATPARSE  APPLICATION.RECORD FROM APP.RECORD.DYN   
    APPL.FIELD.DATA = ''      ;* Returns field value

    EB.Mandate.GetApplFieldData (APPLICATION.DETAILS, MAT APPLICATION.RECORD, MANDATE.DETAILS, DATA.REQUIRED, APPL.FIELD.NAME, '', APPL.FIELD.DATA, ERR.MSG, '', '')
    
    IF APPL.FIELD.DATA NE '' THEN
        TEC.API.CHECK = 1     ;*record the event
    END

    RETURN
*** </region>

END
