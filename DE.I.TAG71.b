* @ValidationCode : MjoxNjE0MjAzMzk3OkNwMTI1MjoxNTQ1MjE5MzQ5MTkyOnJ2YXJhZGhhcmFqYW46LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxODEyLjIwMTgxMTIzLTEzMTk6LTE6LTE=
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
SUBROUTINE DE.I.TAG71(TAG,DET.CHGS,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,DE.I.FIELD.DATA,TAG.ERR)
*-----------------------------------------------------------------------------
* <Rating>-50</Rating>
***********************************************************************************************
*
*
* Inward
*  Tag           -  The swift tag 71
*                -  Option A is a 3 char code such as OUR, SHA or BEN
*                -  Option G is Receiver's charges with Currency & Amount
*                -  Option F is sender's charges with Currency & amount
*
* Outward
*  OFS.DATA      - The corresponding application field in OFS format
************************************************************************************
*
*       MODIFICATIONS
*      ---------------
*
* 24/07/02 - EN_10000786
*            New Program
*
* 03/11/02 - GLOBUS_CI_10005170
*            When the charges are "OUR", do not default to "BEN"

* 03/03/03 - EN_10001649
*            Map the incoming BEN.OUR.CHARGES, Senders charges & receiver
*            charges  to the field BEN.OUR.CHARGES, IN.SEND.CHG & IN.REC.CHG
*            of FT respectively. Remove the changes related to CI_10005170.
*            Also populate the Receiver charges in DE.I.FIELD.DATA.
*
* 3/11/03 - CI_10014215
*           REF : HD0313533
*           Format the incoming Tag 71F(Senders Charge) by calling
*           SC.FORMAT.CCY.AMT before QUOTING the Senders Charge.
*
* 14/11/03 - CI_10014797
*            REF : HD0315169
*            Tag 71F(Senders Charge) should not have space between
*            currency and amount. SWIFT will reject the message if
*            it has space between currency and amount.
*
* 21/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
*
************************************************************************************

    $USING EB.SystemTables
    $USING SF.Foundation
    $USING EB.Foundation
    
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    GOSUB INITIALISE
*
    IF TAG.ERR THEN
        RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037 - E
*
    BEGIN CASE

        CASE TAG = '71A'

* BEN.OUR.CHARGES
            OFS.DATA := DET.CODE :"=":DET.CHGS

        CASE TAG = '71G'

* Receiver charges.
            CONVERT ',' TO '.' IN DET.CHGS
            DE.I.FIELD.DATA<1> = '"':REC.CHG.FIELD.NAME:'"':CHARX(251):DET.CHGS[4,99]
            DET.CHGS = QUOTE(DET.CHGS)
            OFS.DATA := REC.CHG.FIELD.NAME :":1=":DET.CHGS

        CASE TAG = '71F'
            YCCY = ''   ;* CI_10014215 S/E
            YAMT = ''   ;* CI_10014215 S/E
* Senders charges. This is a single repetitive  tag.
            NO.CRLF = DCOUNT(DET.CHGS,@VM)
            FOR C.CRLF = 1 TO NO.CRLF
                YCCY = DET.CHGS<1,C.CRLF>[1,3]        ;* CI_10014215 STARTS
                YAMT = DET.CHGS<1,C.CRLF>[4,99]
                CONVERT ',' TO '.' IN YAMT
                EB.Foundation.ScFormatCcyAmt(YCCY, YAMT)
                DET.CHGS<1,C.CRLF> = YCCY:YAMT        ;* CI_10014215 ENDS  ; * CI_10014797 S/E
                FIELD.DATA = QUOTE( DET.CHGS<1,C.CRLF>)
                IF C.CRLF = NO.CRLF THEN
                    COMMA.SEP = ''          ;* BG_100013037 - S
                END ELSE
                    COMMA.SEP = ','
                END     ;* BG_100013037 - E

*     CONVERT ',' TO '.' IN FIELD.DATA   ; * CI_10014215 S/E
                OFS.DATA = OFS.DATA :SEND.CHG.FIELD.NAME : ':':C.CRLF:'=':FIELD.DATA :COMMA.SEP
            NEXT C.CRLF

        CASE 1
            TAG.ERR = 'FIELD NOT MAPPED FOR TAG -':TAG
    END CASE
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
        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'
            DET.CODE = 'BEN.OUR.CHARGES'
            DET.CCY.AMT = 'CHARGE.AMT'
* EN_10001649 S

            SEND.CHG.FIELD.NAME = 'IN.SEND.CHG'
            REC.CHG.FIELD.NAME = 'IN.REC.CHG'

* EN_10001649 E

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
