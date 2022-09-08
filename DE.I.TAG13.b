* @ValidationCode : MjozMzY3MjU0NDk6Q3AxMjUyOjE1NDUyMTkzNDg0MTc6cnZhcmFkaGFyYWphbjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTIuMjAxODExMjMtMTMxOTotMTotMQ==
* @ValidationInfo : Timestamp         : 19 Dec 2018 17:05:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG13(TAG,TIME.INDICATION,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,TAG.ERR)
*-----------------------------------------------------------------------------
* <Rating>-21</Rating>
*********************************************************************
*
*
* Inward
*  Tag           -  The swift tag 13 for supporting TIME.INDICATION
*
* Outward
*  OFS.DATA      - The corresponding application field in OFS format
*  TAG.ERR       - Application not found
***********************************************************************
*
*       MODIFICATIONS
*      ---------------
*
* 24/07/02 - EN_10000786
*            New Program
*
* 21/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
*
***********************************************************************
*
    $USING EB.SystemTables
    $USING SF.Foundation
*

    GOSUB INITIALISE
    IF TAG.ERR THEN
        RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037 - E
*
    BEGIN CASE

        CASE TAG = '13C'
            NO.REP.SEQ = DCOUNT(TIME.INDICATION,@VM)
            FOR NO.VM = 1 TO NO.REP.SEQ
                TIME.DATA =TIME.INDICATION<1,NO.VM>
                IF NO.VM = NO.REP.SEQ THEN
                    COMMA.SEP = ''          ;* BG_100013037 - S
                END ELSE
                    COMMA.SEP = ','
                END     ;* BG_100013037 - E
                OFS.DATA :=FIELD.NAME:':':NO.VM:'=':TIME.DATA:COMMA.SEP
            NEXT NO.VM
*
*
        CASE 1
            TAG.ERR = 'FIELD NOT MAPPED FOR TAG -':TAG
    END CASE

RETURN
*
*=============
INITIALISE:
*============
*
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    CRLF = CHARX(013):CHARX(010)
    OFS.DATA = ''
    NO.VM = ''
    NO.REP.SEQ = ''
    TIME.DATA = ''
    TAG.ERR = ''

    BEGIN CASE
*
        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'
            FIELD.NAME = 'IN.TIME.IND'
        CASE 1
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG
*
    END CASE
*
RETURN
*
END
*
