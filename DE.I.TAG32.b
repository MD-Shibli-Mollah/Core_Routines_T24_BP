* @ValidationCode : MjotOTQ4MTM1MjAyOkNwMTI1MjoxNTQ2NDkyNzU1MDA1OmFiY2l2YW51amE6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgxMi4yMDE4MTEyMy0xMzE5Ojg0OjU4
* @ValidationInfo : Timestamp         : 03 Jan 2019 10:49:15
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : abcivanuja
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 58/84 (69.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG32(TAG,DATA32,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,DE.I.FIELD.DATA,TAG.ERR)
*-----------------------------------------------------------------------------
* <Rating>-57</Rating>
***********************************************************************************************
*
* This routine assigns SWIFT tag32 - Date , Currency , Amount to the ofs message being
* build up via inward delivery
*
* Inward
*  Tag           -  The swift tag 32A , 32B
*  Data32        -  The swift data
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
* 14/03/03 - EN_10001649
*           Return the debit amount in DE.I.FIELD.DATA
*
* 06/05/04 - EN_10002261
*            SWIFT related changes for bulk credit/debit processing
* 17/06/04 - BG_100006684
*            If account no unable to find in the message MT111, then an
*            EB.MESSAGE.111 will be created and the tag32 info is mapped to
*            VALUE.DATE,CHEQUE.CCY and CHEQUE.AMOUNT in EB.MESSAGE.111.
*
* 30/06/04 - BG_100006876
*            Assing the date value in Tag 32A in ACTION.DATE of Payment stop application
*
* 04/10/04 - BG_100007343
*            Get value date from tag 32A for MT102 - FT.
*
* 21/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
*
* 03/09/2018 - Enhancement 2719154 / Task 2722527
*              Return currency details in DE.I.FIELD.DATA
*
* 25/09/18 - Enhancement 2764004/ Task 2782688
*          - BIL - Automatic Matching - Enh1 -Incoming 910 message processing
*
* 08/10/2019 - En_2789881/ Task 2789890
*             New Template for STOP.REQUEST.STATUS as part of introducing functionality for inward MT112
*             (status of request for stop payment). Map Tag 32 of MT112 to application fields in STOP.REQUEST.STATUS.
*
* 2/1/19 - Enhancement 2889117/ Task 2889142
*        - Changes to support CHEQUE.ADVICE
*
************************************************************************************
*
    $USING EB.SystemTables
    $USING DE.Inward
    $USING DE.Config
*
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    GOSUB INITIALISE
    GOSUB ASSIGN.FIELD.NAMES
*
    IF TAG.ERR THEN
        RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037 - E
    BEGIN CASE
        CASE TAG = '32A'
* BG_100007343 - S

            DDATE = DATA32[1,6]
            YY = DATA32[1,2]
            MM = DATA32[3,2]
            DD = DATA32[5,2]
            OFS.DATA := DATE.FIELD :'=':DD:MM:YY

* For MT102 only value date is enough. CCY ans AMT are taken from tag 32B tag
            IF MSG.TYPE EQ '102' THEN       ;* EN_10002261 S/E
                RETURN  ;* BG_100013037 - S
            END         ;* BG_100013037 - E
* BG_100007343 - E
*
            LEN.DATA = LEN(DATA32)
            OFS.DATA := ',':CURRENCY.FIELD :'=':DATA32[7,3]
            CURRENCY.DATA = DATA32[7,3]
            AMOUNT = DATA32[10,LEN.DATA-9]
            XX = INDEX(AMOUNT,',',1)
            IF XX THEN
                AMOUNT[XX,1] = '.'
            END
            OFS.DATA := ',':AMOUNT.FIELD :'=':AMOUNT
            
            IF CCY.AMT.FIELD AND MSG.TYPE EQ '910' THEN
                CCY.AMT.VAL = CURRENCY.DATA:AMOUNT
                OFS.DATA := ',':CCY.AMT.FIELD :'=':CCY.AMT.VAL
            END
        
            DE.I.FIELD.DATA<1> = '"':AMOUNT.FIELD:'"':CHARX(251):AMOUNT
            DE.I.FIELD.DATA<2> = '"':CURRENCY.FIELD:'"':CHARX(251):CURRENCY.DATA
            
*
        CASE TAG = '32B'
            OFS.DATA := CURRENCY.FIELD:'=':DATA32[1,3]
            CURRENCY.DATA = DATA32[1,3]
            LEN.DATA = LEN(DATA32)
            AMOUNT = DATA32[4,LEN.DATA-3]
            XX = INDEX(AMOUNT,',',1)
            AMOUNT[XX,1] = '.'
            OFS.DATA := ',': AMOUNT.FIELD :'=':AMOUNT
            DE.I.FIELD.DATA<1> = '"':AMOUNT.FIELD:'"':CHARX(251):AMOUNT
            DE.I.FIELD.DATA<2> = '"':CURRENCY.FIELD:'"':CHARX(251):CURRENCY.DATA
*
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
    MSG.TYPE = DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType)        ;* EN_10002261 S/E
    CCY.AMT.FIELD = ''
    CCY.AMT.VAL = ''
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
*
        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'
            AMOUNT.FIELD = 'DEBIT.AMOUNT'
            DATE.FIELD = 'DEBIT.VALUE.DATE'
            CURRENCY.FIELD = 'DEBIT.CURRENCY'
*
        CASE EB.SystemTables.getApplication() = 'AC.EXPECTED.RECS'
            AMOUNT.FIELD = 'AMOUNT'
            DATE.FIELD = 'VALUE.DATE'
            CURRENCY.FIELD = 'CURRENCY'
            CCY.AMT.FIELD = 'CCY.AMOUNT'
        CASE EB.SystemTables.getApplication() = 'PAYMENT.STOP'   ;* EN_10002261 - S
            AMOUNT.FIELD = 'AMOUNT.FROM'
            DATE.FIELD = 'ACTION.DATE'      ;* BG_100006876 S/E
            CURRENCY.FIELD = 'CURRENCY'     ;* EN_10002261 - E
        CASE EB.SystemTables.getApplication() MATCHES 'EB.MESSAGE.111':@VM:'CHEQUE.ADVICE' ;* BG_100006684 - S
            AMOUNT.FIELD = 'CHEQUE.AMOUNT'
            DATE.FIELD = 'VALUE.DATE'
            CURRENCY.FIELD = 'CHEQUE.CCY'   ;* BG_100006684 - E
        CASE EB.SystemTables.getApplication() = 'STOP.REQUEST.STATUS' ;* For Application STOP.REQUEST.STATUS, include amount,value date and currency
            AMOUNT.FIELD = 'CHEQUE.AMOUNT'
            DATE.FIELD = 'VALUE.DATE'
            CURRENCY.FIELD = 'CHEQUE.CURRENCY'
        CASE 1
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG
*
    END CASE
*
RETURN

END
*
