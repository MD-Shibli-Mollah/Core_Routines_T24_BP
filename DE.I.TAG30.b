* @ValidationCode : MjotMjEyODkwMTM2NjpDcDEyNTI6MTU0NjQ5Mjc1NTM0MzphYmNpdmFudWphOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTIuMjAxODExMjMtMTMxOTo0MTozMA==
* @ValidationInfo : Timestamp         : 03 Jan 2019 10:49:15
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : abcivanuja
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 30/41 (73.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version n dd/mm/yy  GLOBUS Release No. G13.1.00 30/10/02
*-----------------------------------------------------------------------------
* <Rating>-29</Rating>
*-----------------------------------------------------------------------------
$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG30(TAG,DATA6,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,DE.I.FIELD.DATA,TAG.ERR)
***********************************************************************************************
*
*
* Inward
*  Tag           -  The swift tag 30
*
* Outward
*  OFS.DATA      - The corresponding application field in OFS format
* DE.I.FIELD.DATA - The field  name & content separated by TM.
************************************************************************************
*
*       MODIFICATIONS
*      ---------------
*
* 24/07/02 - EN_10000786
*            New Program
*
*
* 13/11/02 - BG_100002334
*            Add processing date
*
* 06/05/04 - EN_10002261
*            SWIFT related changes for bulk credit/debit processing
*
* 07/05/05 - CI_10030002
*            Map tag30 of MT111 to DATE.OF.ISSUE Field for EB.MESSAGE.111.
*
* 19/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
*
*08/10/2019 - En_2789881/ Task 2789890
*             New Template for STOP.REQUEST.STATUS as part of introducing functionality for inward MT112
*             (status of request for stop payment). Map Tag 30 of MT112 to DATE.OF.ISSUE in STOP.REQUEST.STATUS.
*
* 2/1/19 - Enhancement 2889117/ Task 2889142
*        - Changes to support CHEQUE.ADVICE
*
************************************************************************************
*
    $USING EB.SystemTables
    $USING SF.Foundation
*

    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    GOSUB INITIALISE
*
    IF TAG.ERR THEN
        RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037 - E
    YY = DATA6[1,2]
    MM = DATA6[3,2]
    DD = DATA6[5,2]
*   Determine Century to append to YY.
    todayDate = EB.SystemTables.getToday()
    yyToday = MOD(todayDate[1,4],100)
    CENTURY = INT(DIV(todayDate[1,4],100))

    IF YY GT yyToday AND (YY - yyToday) GT '1' THEN
        CENTURY - = 1
    END

    OFS.DATA := DATE.FIELD :'=':CENTURY:YY:MM:DD
    DE.I.FIELD.DATA = '"':DATE.FIELD:'"': CHARX(251):CENTURY:YY:MM:DD
*
*
RETURN
*
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
    BEGIN CASE
*
        CASE EB.SystemTables.getApplication() = 'AC.EXPECTED.RECS'
            DATE.FIELD = 'VALUE.DATE'
*
        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'
            DATE.FIELD = 'PROCESSING.DATE'
        CASE EB.SystemTables.getApplication() = 'PAYMENT.STOP'   ;* EN_10002261 - S
            DATE.FIELD = 'DATE.OF.ISSUE'    ;* EN_10002261 - E
        CASE EB.SystemTables.getApplication() = 'EB.MESSAGE.111' ;* CI_10030002 - S
            DATE.FIELD = 'DATE.OF.ISSUE'    ;* CI_10030002 - E
        CASE EB.SystemTables.getApplication() MATCHES 'STOP.REQUEST.STATUS':@VM:'CHEQUE.ADVICE';* include application STOP.REQUEST.STATUS to map Tag 30 with DATE.OF.ISSUE
            DATE.FIELD = 'DATE.OF.ISSUE'
        CASE 1
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG
*
    END CASE
*
RETURN
*
END
