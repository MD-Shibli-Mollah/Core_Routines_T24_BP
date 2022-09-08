* @ValidationCode : MjotMTc1MzEwNjE2OkNwMTI1MjoxNTQ1MjE5MzQ5MTY3OnJ2YXJhZGhhcmFqYW46LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxODEyLjIwMTgxMTIzLTEzMTk6LTE6LTE=
* @ValidationInfo : Timestamp         : 19 Dec 2018 17:05:49
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
SUBROUTINE DE.I.TAG70(TAG,REMITTANCE.INFO,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,TAG.ERR)
*-----------------------------------------------------------------------------
* <Rating>-34</Rating>
*************************************************************************
*
* This routine assigns SWIFT tag70 - payment details info to the ofs message being
* build up via inward delivery
* translate the raw data into OFS format and written away to the ofs directory specified
*
* Inward
*  Tag           -  The swift tag 70
*  REMITTANCE.INFO  -  The swift data
*  SPARE1-3      -  Data slots for future processing
* Outward
*  OFS.DATA      - The corresponding application field in OFS format
************************************************************************
*
*       MODIFICATIONS
*      ---------------
*
* 24/07/02 - EN_10000786
*            New Program
*
* 20/03/03 - EN_10001661
*            Quote the data
*
* 22/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
*
* 06/03/07 - BG_100013228
*            CODE.REVIEW changes.
*
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
*
************************************************************************
*
    $USING SF.Foundation
    $USING EB.SystemTables
*
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    GOSUB INITIALISE
    IF TAG.ERR THEN
        RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037 - E
*
    CONVERT CRLF TO @FM IN REMITTANCE.INFO
    NO.CRLF = DCOUNT(REMITTANCE.INFO,@FM)
*
    IF NO.CRLF > 4 THEN       ;*Only 4 lines supported in FT
        NO.CRLF = 4 ;* BG_100013037 - S
    END   ;* BG_100013037 - E
*
*
    FOR C.CRLF = 1 TO NO.CRLF

        FIELD.DATA = REMITTANCE.INFO<C.CRLF>
        FIELD.DATA = QUOTE(FIELD.DATA)  ;* EN_10001661 S/E
        IF C.CRLF = NO.CRLF THEN
            COMMA.SEP = ''    ;* BG_100013037 - S;* BG_100013228 - S / E
        END ELSE
            COMMA.SEP = ','
        END         ;* BG_100013037 - E
        OFS.DATA = OFS.DATA : FIELD.NAME : ':':C.CRLF:'=':FIELD.DATA :COMMA.SEP
    NEXT C.CRLF
*
*
RETURN
*
*******************************************************************
INITIALISE:
*******************************************************************
*
    EB.SystemTables.setEtext('')
    CUSTOMER.NO = ''
    FIELD.DATA = ''
    CRLF = CHARX(013):CHARX(010)
    LEN.CRLF = LEN(CRLF)
    OFS.DATA = ''
*
    TAG.ERR = ''
    BEGIN CASE
*
        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'
            FIELD.NAME = 'PAYMENT.DETAILS'
*
        CASE 1
*
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG
    END CASE
*
RETURN
*
END
*
