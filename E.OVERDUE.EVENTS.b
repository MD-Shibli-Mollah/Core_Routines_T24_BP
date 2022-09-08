* @ValidationCode : MjoxMzIxMTcyODY4OkNwMTI1MjoxNDk3ODgxMTQ4OTkwOm1tb2hhbnByYWJ1OjI6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzAyLjE6NTg6NDk=
* @ValidationInfo : Timestamp         : 19 Jun 2017 19:35:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mmohanprabu
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 49/58 (84.4%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>341</Rating>
*-----------------------------------------------------------------------------
* Version 3 22/06/01  GLOBUS Release No. G12.0.00 29/06/01
*
    $PACKAGE SC.ScoReports
    SUBROUTINE E.OVERDUE.EVENTS (ENQUIRY.DATA)
*
*------------------------------------------------------------------------
*
* Subroutine to build the screen in OVERDUE.EVENTS enquiry. This will
* check whether the ENTITLEMENT records created for DIARY record have
* been authorised OR not. (After authorisation of ENTITLEMENT records,
* concat file CONCAT.DIARY is updated for each DIARY with ENTITLEMENT
* record ID) Using OVERDUE.DAYS & OVERDUE.DATE in DIARY.TYPE file,a check
* is made to decide whether the event is overdue or not. If the DIARY
* record is overdue and is not yet been authorised, the record will be
* displayed on the enquiry screen as an overdue event.
*
*------------------------------------------------------------------------
*
* 23/09/02 - EN_10001200
*            Conversion of error messages to error codes.
*
* 08/10/08 - CI_10058093
*            GETLIST fails for socket connection using Desktop
*
* 22/6/15 - 1322379 Task:1336841
*           Incorporation of components
*
* 30/10/15 - Task-1513722/Defect-1517119
*            Overdue Diary record IDs are written to ENQUIRY.DATA to avoid contention
*            when run simultaneously in multiple companies.
*06/06/17 - Task-2150589/Defect-2149238
*Adding condition to avoid throwing "NULL KEY SPECIFIED FOR SELECTION� when we run the enquiry OVERDUE.ENENTS

*------------------------------------------------------------------------

    $USING EB.ErrorProcessing
    $USING SC.SccEventCapture
    $USING EB.SystemTables
    $USING EB.DataAccess

*
*************************************************************************
    GOSUB INIT.EVERYTHING
    IF DEP.NO <> '' THEN
        SEL.COMMAND = "SELECT ":DIARY.FILE:" WITH DEPOSITORY ":OPER:" '":DEP.NO:"'"
    END ELSE
        SEL.COMMAND = "SELECT ":DIARY.FILE
    END
    SEL.COMMAND := ' WITH EVENT.STATUS NE "AUTHORISED"'
*
    KEY.LIST = '' ; SELECTED = '' ; SYSTEM.RET.CODE = ''
    EB.DataAccess.Readlist (SEL.COMMAND, KEY.LIST, '', SELECTED, SYSTEM.RET.CODE)
    LOOP
        REMOVE DIARY.ID FROM KEY.LIST SETTING MORE
    WHILE MORE:DIARY.ID DO
        GOSUB START.PROCESSING
    REPEAT
*
* Array DIARY.LIST contains Overdue Diary record IDs. This array is
* written to ENQUIRY.DATA which will be used for display purposes by
* the enquiry module.
*
    SEL.LIST = CHANGE(DIARY.LIST,@FM," ")
*    Adding condition to avoid throwing "NULL KEY SPECIFIED FOR SELECTION� when we run the enquiry OVERDUE.ENENTS
    IF SEL.LIST NE '' THEN
        ENQUIRY.DATA<2,-1> = "@ID"
        ENQUIRY.DATA<3,-1> = "EQ"
        ENQUIRY.DATA<4,-1> = SEL.LIST
    END
    RETURN
*
*----------------
START.PROCESSING:
*----------------
* Each DIARY record is checked here as to whether they are overdue OR not
* using OVERDUE.DAYS & OVERDUE.DATE fields.If the DIARY record is overdue
* and the corresponding ENTITLEMENT is not yet authorised,DIARY record ID
* is stored in a SAVE LIST to enable the routine to display them.
*

    R.DIARY = SC.SccEventCapture.Diary.Read(DIARY.ID, ER)
* Before incorporation : CALL F.READ ('F.DIARY', DIARY.ID, R.DIARY, tmp.F.DIARY, ER)

    IF ER THEN EB.SystemTables.setE(EB.SystemTables.getEtext()); GOSUB FATAL.ERR
*
    EVENT.TYPE = R.DIARY<SC.SccEventCapture.Diary.DiaEventType>

    R.DIARY.TYPE.LOCAL = SC.SccEventCapture.DiaryType.Read(EVENT.TYPE, ER)
* Before incorporation : CALL F.READ ('F.DIARY.TYPE', EVENT.TYPE, R.DIARY.TYPE.LOCAL, tmp.F.DIARY.TYPE, ER)
    IF ER THEN EB.SystemTables.setE(ER); GOSUB FATAL.ERR
*
    NEW.DATE = ''
    OVERDUE.DAYS = R.DIARY.TYPE.LOCAL<SC.SccEventCapture.DiaryType.DryOverdueDays>
    OVERDUE.DATE = R.DIARY.TYPE.LOCAL<SC.SccEventCapture.DiaryType.DryOverdueDate>
*
    BEGIN CASE
        CASE OVERDUE.DATE = 'PAY.DATE'
            NEW.DATE = R.DIARY<SC.SccEventCapture.Diary.DiaPayDate> + OVERDUE.DAYS
            *
        CASE OVERDUE.DATE = 'EX.DATE'
            NEW.DATE = R.DIARY<SC.SccEventCapture.Diary.DiaExDate> + OVERDUE.DAYS
            *
        CASE OVERDUE.DATE = 'VALUE.DATE'
            NEW.DATE = R.DIARY<SC.SccEventCapture.Diary.DiaValueDate> + OVERDUE.DAYS
            *
        CASE OVERDUE.DATE = 'REPLY.BY.DATE'
            NEW.DATE = R.DIARY<SC.SccEventCapture.Diary.DiaReplyByDate> + OVERDUE.DAYS
    END CASE
*
* If NEW.DATE is LT TODAY, Concat file is searched for the corresponding
* DIARY record. If not found, the event is considered as an Overdue Event
* and DIARY ID is stored in an array for further process in enquiry.
*
    IF NEW.DATE AND (NEW.DATE < EB.SystemTables.getToday()) THEN
        DIARY.LIST<-1> = DIARY.ID
    END
*
    RETURN
*
*---------------
INIT.EVERYTHING:
*---------------
* Initialising neccessary variables and opening required files.
*
    F.DIARY.LOCAL =''; R.DIARY = ''
    DIARY.FILE = 'F.DIARY'

    EB.DataAccess.Opf (DIARY.FILE, F.DIARY.LOCAL)

*
    OPER = ENQUIRY.DATA<3>
    DEP.NO = ENQUIRY.DATA<4>
*
    IF OPER = '' THEN OPER = 'EQ'
*
    DIARY.LIST = ''
*
    RETURN
*
*---------
FATAL.ERR:
*---------
* Call FATAL.ERR procedure with program name
*
    EB.SystemTables.setText(EB.SystemTables.getE())
    IF EB.SystemTables.getRunningUnderBatch() THEN
        tmp=EB.SystemTables.getBatchDetails(); tmp<2>=3; EB.SystemTables.setBatchDetails(tmp)
        tmp=EB.SystemTables.getBatchDetails(); tmp<3>=EB.SystemTables.getEtext(); EB.SystemTables.setBatchDetails(tmp)
    END
    EB.ErrorProcessing.FatalError('E.OVERDUE.EVENTS')
*
    RETURN
*

    END
