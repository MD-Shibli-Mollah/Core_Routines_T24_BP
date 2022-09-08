* @ValidationCode : MjoxNTkwNzAzNjA4OkNwMTI1MjoxNTQ1MjE5MzQ4NDAxOnJ2YXJhZGhhcmFqYW46LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxODEyLjIwMTgxMTIzLTEzMTk6LTE6LTE=
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

* Version n dd/mm/yy  GLOBUS Release No. G14.1.01 04/12/03
*-----------------------------------------------------------------------------
* <Rating>-18</Rating>
*-----------------------------------------------------------------------------
$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG12(TAG,MSG.TYPE,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,TAG.ERR)
***********************************************************************************************
*
*
* Inward
*  Tag           -  The swift tag 12
*
* Outward
*  OFS.DATA      - The corresponding application field in OFS format
************************************************************************************
*
*       MODIFICATIONS
*      ---------------
*
* 30/01/04 - EN_10002181
*            NEW TAG ROUTINE - Enhancement for MT920
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

    GOSUB INITIALISE
    IF TAG.ERR THEN
        RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037 - E
*
    OFS.DATA := DATA.FIELD:'=':MSG.TYPE


RETURN
*
************************************************************************************
INITIALISE:
************************************************************************************
*
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    ER = ''
    END.POS = ''
    EB.SystemTables.setEtext('')
    CRLF = CHARX(013):CHARX(010)
    DATA.FIELD = ''
    LEN.CRLF = LEN(CRLF)
    TAG.ERR = ''
*
    BEGIN CASE
*
        CASE EB.SystemTables.getApplication() = 'DE.STATEMENT.REQUEST'
            DATA.FIELD = 'MESSAGE.TYPE:1:1'

        CASE 1
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG
*
    END CASE
*
RETURN
*
END
*
