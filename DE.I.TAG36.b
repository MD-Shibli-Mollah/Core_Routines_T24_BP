* @ValidationCode : MjoxMTM0NjA1NDc4OkNwMTI1MjoxNTQ1MjE5MzQ4NjM2OnJ2YXJhZGhhcmFqYW46LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxODEyLjIwMTgxMTIzLTEzMTk6LTE6LTE=
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

*-----------------------------------------------------------------------------
* <Rating>-18</Rating>
*-----------------------------------------------------------------------------
$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG36(TAG,EXCH.RATE,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,TAG.ERR)
***********************************************************************************************
*
*
* Inward
*  Tag           -  The swift tag 36
*
* Outward
*  OFS.DATA      - The corresponding application field in OFS format
************************************************************************************
*
*       MODIFICATIONS
*      ---------------
*
* 06/11/02 - BG_100002640
*            New Version
*
* 19/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
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

    BEGIN CASE

        CASE TAG = '36'

            CONVERT ',' TO '.' IN EXCH.RATE
            OFS.DATA := EXCH.RATE

        CASE 1

            TAG.ERR = 'FIELD NOT MAPPED FOR TAG -':TAG

    END CASE

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
*
    BEGIN CASE
*
        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'
            OFS.DATA = 'IN.EXCH.RATE='
*
        CASE 1
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG
*
    END CASE
*
RETURN
*
END
*
