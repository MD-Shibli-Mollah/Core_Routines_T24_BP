* @ValidationCode : MjoxMjcyNzgxMzUyOkNwMTI1MjoxNTQ1MjE5MzQ4NjIwOnJ2YXJhZGhhcmFqYW46LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxODEyLjIwMTgxMTIzLTEzMTk6LTE6LTE=
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
* <Rating>-35</Rating>
$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG34(TAG,FLOOR.LMT,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,TAG.ERR)
***********************************************************************************************
*
*
* Inward
*  Tag           -  The swift tag 34
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
* 06/02/04 - BG_100006169
*            Bug fix for MT920 Enhancement
*
* 22/02/07 - BG_100013037
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
    IF TAG.ERR THEN
        RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037  - E


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
    DATA.FIELD = ''
    LEN.CRLF = LEN(CRLF)
    TAG.ERR = ''
    IF FLOOR.LMT EQ '' THEN
        RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037 - E
*
    BEGIN CASE
*
        CASE EB.SystemTables.getApplication() = 'DE.STATEMENT.REQUEST'

            FL.COUNT = COUNT(FLOOR.LMT,@VM) + 1

            LMT.CCY = FLOOR.LMT[1,3]
            OFS.DATA := 'AC.CURRENCY:1:1=':LMT.CCY:','

            FOR FLC = 1 TO FL.COUNT

                IF FLOOR.LMT<1,FLC>[4,1] = 'D' OR NUM((FLOOR.LMT)<1,FLC>[4,1]) THEN
                    DATA.FIELD = 'DR.FLOOR.LMT:1:1='
                END

                IF FLOOR.LMT<1,FLC>[4,1] = 'C' THEN
                    DATA.FIELD = 'CR.FLOOR.LMT:1:1='
                END

                GOSUB GET.OFS.DATA
                IF FLC = 1 AND FL.COUNT > 1 THEN      ;* BG_100006169 S/E
                    OFS.DATA := ','
                END

            NEXT FLC

        CASE 1
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG
*
    END CASE
*
RETURN
*
***********************************************************************************
* BG_100013037 - S
*============
GET.OFS.DATA:
*============
    IF FLOOR.LMT[4,1] MATCHES 'D':@VM:'C' THEN
        FLR.LIMIT = FLOOR.LMT<1,FLC>[5,99]
        IF INDEX(FLR.LIMIT,',',1) < LEN(FLR.LIMIT) THEN
            CONVERT ',' TO '.' IN FLR.LIMIT
        END ELSE
            CONVERT ',' TO '' IN FLR.LIMIT
        END
        OFS.DATA := DATA.FIELD:FLR.LIMIT
    END ELSE
        FLR.LIMIT = FLOOR.LMT<1,FLC>[4,99]
        IF INDEX(FLR.LIMIT,',',1) < LEN(FLR.LIMIT) THEN
            CONVERT ',' TO '.' IN FLR.LIMIT
        END ELSE
            CONVERT ',' TO '' IN FLR.LIMIT
        END
        OFS.DATA := DATA.FIELD:FLR.LIMIT
    END
RETURN          ;* BG_100013037 - E
***********************************************************************************
END
*
