* @ValidationCode : MjoxNzc4MjA3MjAxOkNwMTI1MjoxNTQ2NDkyMDE2OTcwOmFiY2l2YW51amE6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgxMi4yMDE4MTEyMy0xMzE5OjUzOjQw
* @ValidationInfo : Timestamp         : 03 Jan 2019 10:36:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : abcivanuja
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 40/53 (75.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version n dd/mm/yy  GLOBUS Release No. G13.2.00 02/03/03
*-----------------------------------------------------------------------------
* <Rating>-29</Rating>
*-----------------------------------------------------------------------------
$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG21(TAG,RELATED.REF.NO,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,SPARE5,TAG.ERR)
***********************************************************************************************
*
*
* Inward
*  Tag           -  The swift tag 21
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

* 20/03/03 - EN_10001661
*            Quote the data
*
* 06/05/04 - EN_10002261
*            SWIFT related changes for bulk credit/debit processing
*
* 07/05/05 - CI_10030002
*            Map tag21 of MT111 to CHEQUE.NUMBER Field for EB.MESSAGE.111.
*
* 19/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
*
*10/10/2019 - En_2789881/ Task 2789890
*             New Template for STOP.REQUEST.STATUS as part of introducing functionality for inward MT112
*             (status of request for stop payment). Map Tag 21 of MT111/MT112 to CHEQUE.TYPE, CHEQUE.NUMBER in EB.MESSAGE.111/STOP.REQUEST.STATUS.
*
* 2/1/19 - Enhancement 2889117/ Task 2889142
*        - Changes to support CHEQUE.ADVICE
*
************************************************************************************
    $USING EB.SystemTables
    $USING SF.Foundation
*
    GOSUB INITIALISE
    IF TAG.ERR THEN
        RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037 - E
*
    BEGIN CASE
        CASE EB.SystemTables.getApplication() MATCHES "EB.MESSAGE.111" :@VM: "STOP.REQUEST.STATUS"
            GOSUB GET.CHEQUE.TYPE.NUMBER
            IF CHQ.NUMBER THEN
                OFS.DATA = FLD.CHQ.NUMBER:QUOTE(CHQ.NUMBER)
            END
            IF CHQ.TYPE THEN
                OFS.DATA := ',':FLD.CHQ.TYPE:QUOTE(CHQ.TYPE)
            END
        CASE 1
            OFS.DATA := QUOTE(RELATED.REF.NO)   ;* EN_10001661 S/E
    END CASE
*
*
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
    OFS.DATA = ''
    LEN.CRLF = LEN(CRLF)
    TAG.ERR = ''
*
    BEGIN CASE
*
        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'
            OFS.DATA = 'RELATED.REF:1:1='
        CASE EB.SystemTables.getApplication() = 'AC.EXPECTED.RECS'
            OFS.DATA = 'RELATED.REF:1:1='
        CASE EB.SystemTables.getApplication() = 'PAYMENT.STOP'   ;* EN_10002261  - S
            OFS.DATA = 'FIRST.CHEQUE.NO:1:1='         ;* EN_10002261 - E
        CASE EB.SystemTables.getApplication() MATCHES "EB.MESSAGE.111" :@VM: "STOP.REQUEST.STATUS" ;* CI_10030002 - S
*           Changes to include Cheque Type and Cheque Number.
            FLD.CHQ.NUMBER = 'CHEQUE.NUMBER:1:1=' ;* CI_10030002 - E
            FLD.CHQ.TYPE = 'CHEQUE.TYPE:1:1='
        CASE EB.SystemTables.getApplication() = 'CHEQUE.ADVICE'
            OFS.DATA = 'CHEQUE.NUMBER:1:1='
*
        CASE 1
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG
*
    END CASE
*
RETURN
*
************************************************************************************
*<Desc> To derive Cheque type and Cheque Number from Tag 21. If Cheque type available then
*       Populated as "Cheque Type/Cheque Number"
GET.CHEQUE.TYPE.NUMBER:
    CHQ.TYPE = ''
    CHQ.NUMBER = ''
    IF INDEX(RELATED.REF.NO,'/',1) THEN
        IF NOT(RELATED.REF.NO[1,1] EQ '/') THEN
            CHQ.TYPE = FIELD(RELATED.REF.NO,'/',1)
        END
        CHQ.NUMBER = FIELD(RELATED.REF.NO, '/',2)
    END ELSE
        CHQ.NUMBER = RELATED.REF.NO
    END
RETURN
************************************************************************************
END
*
