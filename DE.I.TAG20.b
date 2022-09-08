* @ValidationCode : MjoyMDQ4NTc0NTg2OkNwMTI1MjoxNTQ2NTIyODM3NjQ0OmFiY2l2YW51amE6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgxMi4yMDE4MTEyMy0xMzE5OjMzOjIw
* @ValidationInfo : Timestamp         : 03 Jan 2019 19:10:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : abcivanuja
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 20/33 (60.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-38</Rating>
*-----------------------------------------------------------------------------
$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG20(TAG,TRAN.REF.NO,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,DE.I.FIELD.DATA,TAG.ERR)
***********************************************************************************************
*
*
* Inward
*  Tag           -  The swift tag 20
*
* Outward
*  OFS.DATA      - The corresponding application field in OFS format
*  DE.I.FIELD.DATA - Variable containing field name & data separeted by
*                  TM .
************************************************************************************
*
*       MODIFICATIONS
*      ---------------
*
* 24/07/02 - EN_10000786
*            New Program
*
* 28/11/02 - BG_100002640
*           Return the data in DE.I.FIELD.DATA
*
* 20/03/03 - EN_10001661
*            Quote the data .
*
* 30/01/04 - EN_10002181
*            Enhancement for MT920
*            Include IN.TRANS.REF field for the new appl DE.STATEMENT.REQUEST
*
* 06/05/04 - EN_10002261
*            SWIFT related changes for bulk credit/debit processing
*
* 07/05/05 - CI_10030002
*            Map tag20 of MT111 to IN.SENDER.REF For EB.MESSAGE.111
*
* 19/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
*
* 08/10/2019 - En_2789881/ Task 2789890
*              New Template for STOP.REQUEST.STATUS as part of introducing functionality for inward MT112
*              (status of request for stop payment). Map Tag 20 of MT112 to REFERENCE in STOP.REQUEST.STATUS.
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
    OFS.DATA := DATA.FIELD:'=':QUOTE(TRAN.REF.NO) ;* EN_10001661 S/E
    DE.I.FIELD.DATA = '"':DATA.FIELD:'"':CHARX(251):TRAN.REF.NO
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
    DE.I.FIELD.DATA = ''
    LEN.CRLF = LEN(CRLF)
*
    BEGIN CASE
*
        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'
            DATA.FIELD = 'DEBIT.THEIR.REF:1:1'
        CASE EB.SystemTables.getApplication() = 'AC.EXPECTED.RECS'
            DATA.FIELD = 'REFERENCE:1:1'
        CASE EB.SystemTables.getApplication() = 'DE.STATEMENT.REQUEST'     ;* EN_10002181 - STARTS
            DATA.FIELD = 'IN.TRANS.REF:1:1' ;* EN_10002181 - ENDS
        CASE EB.SystemTables.getApplication() = 'PAYMENT.STOP'   ;* EN_10002261 - S
            DATA.FIELD = 'OUR.REFERENCE:1:1'          ;* EN_10002261 - E
        CASE EB.SystemTables.getApplication() = 'EB.MESSAGE.111' ;* CI_10030002 - S
            DATA.FIELD = 'IN.SENDER.REF:1:1'          ;* CI_10030002 - E
        CASE EB.SystemTables.getApplication() MATCHES 'STOP.REQUEST.STATUS':@VM:'CHEQUE.ADVICE' ;* include application STOP.REQUEST.STATUS to map Tag 20 with REFERENCE
            DATA.FIELD = 'REFERENCE:1:1'
        CASE 1
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG
*
    END CASE
*
RETURN
*
END
*
