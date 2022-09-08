* @ValidationCode : MjotMTA5OTIzNDYyODpDcDEyNTI6MTU0NTIyNDc5ODQxNjpydmFyYWRoYXJhamFuOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTIuMjAxODExMjMtMTMxOTozOTozNg==
* @ValidationInfo : Timestamp         : 19 Dec 2018 18:36:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 36/39 (92.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG76(TAG,ANSWERS,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,DE.I.FIELD.DATA,TAG.ERR)
*-----------------------------------------------------------------------------
* This routine assigns SWIFT tag76 - Answers to the ofs message being
* build up via inward delivery
*
* Inward
*  Tag           -  The swift tag 76
*  Data32        -  The ANSWERS data
*
* Outward
*  OFS.DATA      - The corresponding application field in OFS format
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 16/10/2019 - En_2789881/ Task 2789890
*             New Template for STOP.REQUEST.STATUS as part of introducing functionality for inward MT112
*             (status of request for stop payment). Map Tag 76 of MT112 to application fields in STOP.REQUEST.STATUS.
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING DE.Inward
    $USING DE.Config
    
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    GOSUB INITIALISE
    GOSUB ASSIGN.FIELD.NAMES ;* Determine the corresponding field name for Answers in Application.
    IF TAG.ERR THEN
        RETURN
    END
    GOSUB POPULATE.OFS.DATA ;* Populate OFS data for Answers Field.
RETURN
************************************************************************************
INITIALISE:
************************************************************************************
*
    ER = ''
    END.POS = ''
    EB.SystemTables.setEtext('')
    CRLF = CHARX(013):CHARX(010)
    OFS.DATA = ''
    LEN.CRLF = LEN(CRLF)
    TAG.ERR = ''
    DE.I.FIELD.DATA = ''
*
RETURN
*
************************************************************************************
ASSIGN.FIELD.NAMES:
************************************************************************************
* OFS requires field names to match up the data , obviously these are different    *
* for each application.                                                            *
************************************************************************************
*
    BEGIN CASE
        CASE EB.SystemTables.getApplication() = 'STOP.REQUEST.STATUS' ;* For Application STOP.REQUEST.STATUS, include ANSWERS in OFS data
            ANSWER.FIELD = 'ANSWERS'
        CASE 1
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG
*
    END CASE
*
RETURN
************************************************************************************
************************************************************************************
POPULATE.OFS.DATA:
************************************************************************************
* OFS requires field names to match up the data , obviously these are different    *
* for each application.                                                            *
************************************************************************************
*  Populate OFS Data for Tag 76 (ANSWERS)
    IF ANSWERS THEN
        TEMP.ANSWERS = CONVERT(CRLF,@VM,ANSWERS)
        NO.CRLF = DCOUNT(TEMP.ANSWERS,@VM)
        FOR C.CRLF = 1 TO NO.CRLF
            IF C.CRLF = NO.CRLF THEN
                COMMA.SEP = ''
            END ELSE
                COMMA.SEP = ','
            END
            OFS.DATA = OFS.DATA : ANSWER.FIELD : ':':C.CRLF:'=':QUOTE(TEMP.ANSWERS<1,C.CRLF>) :COMMA.SEP
        NEXT C.CRLF
        DE.I.FIELD.DATA<1> ='"':ANSWER.FIELD:'"':CHARX(251):TEMP.ANSWERS
    END
RETURN
************************************************************************************
END
