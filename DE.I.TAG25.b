* @ValidationCode : Mjo3MDk1OTE3MTg6Q3AxMjUyOjE1NDkwMTQ5NzEzMDY6YWJjaXZhbnVqYTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTIuMjAxODExMjMtMTMxOTotMTotMQ==
* @ValidationInfo : Timestamp         : 01 Feb 2019 15:26:11
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : abcivanuja
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG25(TAG,ACCT.ID,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,DE.I.FIELD.DATA,TAG.ERR)
*-----------------------------------------------------------------------------
* <Rating>-51</Rating>
***********************************************************************************************
*
*
* Inward
*  Tag           -  The swift tag 25
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
* 13/11/02 - BG_100002334
*            Include 25A - Charges account number.
*
* 07/01/04 - CI_10016284
*            Messages goes to repair if incoming 210 contains multiple sequence
*
* 30/01/04 - EN_10002181
*            Enhancement for MT920
*            Include IN.ACCOUNT field for the new appl DE.STATEMENT.REQUEST
*
* 16/02/04 - BG_100006188
*            QUOTE the acct.id
*
* 21/09/05 - CI_10034872
*            Changes to DE.I.TAG25 routine make AC.EXPECTED.RECS go to IHLD.
*            QUOTE(ACCT.NO) in DE.I.TAG25 make AC.EXPECTED.RECS go to IHLD.
*
* 19/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
*
* 09/03/07 - CI_10047724
*            When processing the inward 210 message, record AC.EXPECTD.RECS is not
*            created since the account number with quotes in OFS string is passed to
*            OFS.REQUEST.MANAGER, it returned with the error in the crossval without
*            creating record
*
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
*
* 01/02/19 - Defect 2967887/ Task 2971478
*            When TAG25P is passed, it should be mapped to ACCOUNT.ID for AC.EXPECTED.RECS
*******************************************************************************************
*
    $USING EB.SystemTables
    $USING SF.Foundation
*
    
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    GOSUB INITIALISE
    GOSUB GET.ACCT
    IF TAG.ERR THEN
        RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037 - E
*
    BEGIN CASE
        CASE TAG = '25A'          ;* Charges acct no
            LEN.ACCT.ID = LEN(ACCT.ID)
* CI_10016284 S
            OFS.DATA := FIELD.NAME:':1=':QUOTE(ACCT.ID[2,LEN.ACCT.ID])    ;* BG_100006188 S/E ; * CI_10034872 S/E
            DE.I.FIELD.DATA = '"':FIELD.NAME:'"': CHARX(251):ACCT.ID[2,LEN.ACCT.ID]
* CI_10016284 E
        CASE 1          ;* Account indenfication
* CI_10016284 S
            OFS.DATA := FIELD.NAME:':1=':QUOTE(ACCT.ID)         ;* BG_100006188 S/E ; * CI_10034872 S/E
            DE.I.FIELD.DATA = '"':FIELD.NAME:'"': CHARX(251):ACCT.ID
* CI_10016284 E
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
    TAG.ERR = ''
    DE.I.FIELD.DATA = '' ;    ;* CI_10016284 S/E
*
    BEGIN CASE
*
        CASE EB.SystemTables.getApplication() = 'AC.EXPECTED.RECS'
            FIELD.NAME = 'ACCOUNT.ID:1:1'   ;* CI_10016284 S/E;* CI_10047724 - S / E
*
        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'
            FIELD.NAME = 'CHARGES.ACCT.NO:1:1'        ;* CI_10016284 S/E
        CASE EB.SystemTables.getApplication() = 'DE.STATEMENT.REQUEST'     ;* EN_10002181 - STARTS
            FIELD.NAME   = 'IN.ACCOUNT:1:1' ;* EN_10002181 - ENDS
        CASE 1
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG
*
    END CASE
*
RETURN
*************************************************************************************
GET.ACCT:
************************************************************************************
*
    CRLF.POSITION = INDEX(ACCT.ID,CRLF,1)  ;* check if multiple lines are passed
    IF CRLF.POSITION AND EB.SystemTables.getApplication() EQ 'AC.EXPECTED.RECS' THEN ;* if multiple lines
        ACCT.ID= FIELD(ACCT.ID,CRLF,1) ;* get the firt line as account
    END
RETURN
************************************************************************************
END
*

