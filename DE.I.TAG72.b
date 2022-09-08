* @ValidationCode : MjoxNDA2MzQ0MTEwOkNwMTI1MjoxNTQ2NTA4OTY0MjQ0OmFiY2l2YW51amE6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgxMi4yMDE4MTEyMy0xMzE5OjQ4OjM2
* @ValidationInfo : Timestamp         : 03 Jan 2019 15:19:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : abcivanuja
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 36/48 (75.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG72(TAG,BANK.TO.BANK,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,DE.I.FIELD.DATA,TAG.ERR)
*-----------------------------------------------------------------------------
* <Rating>-31</Rating>
***********************************************************************************************
*
* This routine assigns SWIFT tag72 - Sender to Reciever info to the ofs message being
* build up via inward delivery
* translate the raw data into OFS format and written away to the ofs directory specified
*
* Inward
*  Tag           -  The swift tag 72
*  BANK.TO.BANK  -  The swift data
*  SPARE1-3      -  Data slots for future processing
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
* 08/11/02 - BG_100002640
*            Allow double slash in 72 tag.
*
* 22/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 28/04/09 - EN_10004043
*            SAR Ref: SAR-2008-12-19-0003
*            For 202C this tag will be called twice. One for A and another one
*            is for B sequence. To differentiate it TAG<2> will contain 'B', i.e.,
*            it is being called for B seq tags
*
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
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
    IF TAG.ERR THEN
        RETURN
    END
*
    CONVERT CRLF TO @FM IN BANK.TO.BANK
    NO.CRLF = DCOUNT(BANK.TO.BANK,@FM)
    IF NO.CRLF > 6 THEN       ;*Only 6 lines supported in FT
        NO.CRLF = 6
    END
*
* Loop around extracting data between line returns. The last crlf
* is not identidfied by INDEX.
*
    FOR C.CRLF = 1 TO NO.CRLF
        FIELD.DATA = BANK.TO.BANK<C.CRLF>
        FIELD.DATA = QUOTE(FIELD.DATA)
        IF C.CRLF = NO.CRLF THEN
            COMMA.SEP = ''
        END ELSE
            COMMA.SEP = ','
        END

        OFS.DATA = OFS.DATA : FIELD.NAME : ':':C.CRLF:'=':FIELD.DATA :COMMA.SEP
    NEXT C.CRLF
    IF EB.SystemTables.getApplication() EQ 'CHEQUE.ADVICE' THEN
        BANK.TO.BANK = CONVERT(@FM,@VM,BANK.TO.BANK)
        DE.I.FIELD.DATA<1> ='"':FIELD.NAME:'"':CHARX(251):BANK.TO.BANK
    END
    
*
RETURN
*
************************************************************************************
INITIALISE:
************************************************************************************
*
    CUSTOMER.NO = ''
    CRLF = CHARX(013):CHARX(010)
    LEN.CRLF = LEN(CRLF)
    OFS.DATA = ''
    B.TAG = ''
    IF TAG<2> = 'B' THEN
        B.TAG = 1
        TAG = TAG<1>
    END
*
    BEGIN CASE
*
        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'
*
            IF B.TAG THEN
                FIELD.NAME = 'IN.C.BK.T.BK.IN'
            END ELSE
                FIELD.NAME = 'IN.BK.TO.BK.INFO'
            END
*
        CASE EB.SystemTables.getApplication() = 'CHEQUE.ADVICE'
            FIELD.NAME = 'SENDER.RECEIVER.INFO'
        CASE 1
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG
*
    END CASE
*
RETURN
*
END
*
