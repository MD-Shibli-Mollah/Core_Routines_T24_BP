* @ValidationCode : Mjo5ODA5NDUyODpDcDEyNTI6MTU0NTIxOTM0ODg3MDpydmFyYWRoYXJhamFuOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgxMi4yMDE4MTEyMy0xMzE5Oi0xOi0x
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

$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG57(TAG,INSTITUTION,OFS.DATA,CUSTOMER,CCY,SPARE3,SPARE4,DE.I.FIELD.DATA,TAG.ERR)
*-----------------------------------------------------------------------------
* <Rating>-99</Rating>
***********************************************************************************************
*
* This routine assigns SWIFT tag57 - Account with Institution to the ofs message being
* build up via inward delivery
* translate the raw data into OFS format and written away to the ofs directory specified
*
* Inward
*  Tag           -  The swift tag either 57A,57B or 57D
*  Intermediary  -  The swift data
*
* Outward
* OFS.DATA      - The corresponding application field in OFS format
* DE.I.FIELD.DATA - Field name : TM: field values separated by VM
* TAG.ERR         - Tag error.
*
************************************************************************************
*
*       MODIFICATIONS
*      ---------------
*
* 24/07/02 - EN_10000786
*            New Program
*
* 07/10/02 - EN_10001322
*            Account Fields for SWIFT 2002 Usage
*
* 19/12/02 - CI_10005670
*               // may be clearing codes and hence if // is present
*            it should not be treated as account numbers.
*
* 28/01/04 - CI_10016936
*            While mapping the Account field data to OFS.DATA, use the
*            syntax ACCOUNT field name :1= Account field data content
*
* 09/06/04 - CI_10020477
*            103 error tag 57B
*
* 30/06/04 - BG_100006876
*            Support tag 57C for MT102.
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
* 26/03/11 - Task 631815
*            Tag or value before sending to OFS is quoted so that the message will not
*            be trauncated
*
* 29/11/14 - Defect 1173446/ Task 1183745
*            When the Tag value is quoted, the value is passed to FT without quotes.
*
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
*
************************************************************************************
*
    $USING EB.SystemTables
    $USING DE.API
    $USING SF.Foundation
    $USING FT.Delivery

    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    GOSUB INITIALISE
    IF B.TAG THEN
        GOSUB UPDATE.B.TAG
    END
    IF TAG.ERR OR B.TAG THEN
        RETURN
    END
    GOSUB GET.ACCT.WITH.BANK.ACCT

*
    BEGIN CASE
        CASE TAG = '57A'
            COMP.ID = EB.SystemTables.getIdCompany()
            DE.API.SwiftBic(INSTITUTION,COMP.ID,CUSTOMER.NO)
            IF CUSTOMER.NO = '' THEN
                CUSTOMER.NO = DEPREFIX:INSTITUTION
            END
            OFS.DATA := FIELD.NAME :':1:1=' : QUOTE(CUSTOMER.NO)
            DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"':CHARX(251):CUSTOMER.NO

        CASE TAG = '57B'

            OFS.DATA := FIELD.NAME: ':1:1=' :'"': INSTITUTION:'"'
            DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"':CHARX(251):INSTITUTION

        CASE TAG = '57C'

            OFS.DATA := FIELD.NAME: ':1:1=' :'"': INSTITUTION:'"'
*
        CASE TAG = '57D'
*
            GOSUB PROCESS.TAG.57D
*
        CASE 1
* If the acct with bank present is a globus customer, then default the
* customer's nostro account.

*            TAG.ERR = 'FIELD NOT MAPPED FOR TAG -':TAG
            CUSTOMER.NO = CUSTOMER
            TXN.TYPE = ''
            ACCOUNT = ''
            ACCOUNT.CATEGORY = ''
            ACCOUNT.COUNT = ''
            ACCOUNT.CLASS = ''
            ACCOUNT.ERROR = ''
            ACCOUNT.IN = ''
            FT.Delivery.DeIGetAcctNo( CUSTOMER.NO, CCY, TXN.TYPE, ACCOUNT.IN, ACCOUNT, ACCOUNT.CATEGORY, ACCOUNT.COUNT,ACCOUNT.CLASS, ACCOUNT.ERROR)
* Find the customer's NOSTRO and check that there is only one
            LOCATE 'NOSTRO' IN ACCOUNT.CLASS<1> SETTING POS THEN
                IF ACCOUNT.COUNT<POS> GT 1 THEN
                    TAG.ERR = 'ERROR - MORE THAN ONE ACCOUNT AVAILABLE'
                    ACCOUNT.NO = ''
                END ELSE
                    ACCOUNT.NO = ACCOUNT<POS,1>
                END
            END
            IF ACCOUNT.NO THEN
                OFS.DATA = OFS.DATA :'CREDIT.ACCT.NO=':QUOTE(ACCOUNT.NO)
            END

*
    END CASE
*
RETURN
*
************************************************************************************
INITIALISE:
************************************************************************************
*

    EB.SystemTables.setEtext('')
    CUSTOMER.NO = ''
    DEPREFIX = ''
    CRLF = CHARX(013):CHARX(010)
    OFS.DATA = ''
    LEN.CRLF = LEN(CRLF)
    LEN.INSTITUTION = LEN(INSTITUTION)
    TAG.ERR = ''
    FIELD.DATA = ''
    ACCOUNT.NO = ''
    DE.I.FIELD.DATA = ''
    INST.ACCT.DATA = ''
    B.TAG = ''
    IF TAG<2> = 'B' THEN
        B.TAG = 1
        TAG = TAG<1>
    END
*
    BEGIN CASE
*
        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'
            IF B.TAG THEN
                FIELD.NAME = 'IN.C.ACC.WIT.BK'
            END ELSE
                FIELD.NAME = 'ACCT.WITH.BK'
                ACCNT.FLD = 'IN.ACCT.BANK.ACC'
            END
            DEPREFIX = 'SW-'
*
        CASE 1
*
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG

    END CASE
*
RETURN

************************************************************************
GET.ACCT.WITH.BANK.ACCT:
************************************************************************
    IF INDEX(INSTITUTION,'/',1) THEN
        CRLF.POS = INDEX(INSTITUTION,CRLF,1)

* If the first 2 characters are // , then it may be the clearing code
* bit of the party identifier. Hence ignore the clearing code part and
* the rest of the content should be mapped to bank details
*
* If the frist 3 characters are /C/ or /D/, then it indicates the debit
* or credit identifier and it can be followed by account number.
* In this case get the account number between the 2nd / and first crlf.
* The rest of the content is bank details
*
* If the first character is / and CRLF is found, then the account number
* may be present between the / and CRLF.
* The rest of the content is bank details.
*
* If none of the above is met, then the entire tag is assumed to be for
* bank details only.

        BEGIN CASE
            CASE INSTITUTION[1,2] = '//'
                INSTITUTION= INSTITUTION[CRLF.POS+LEN.CRLF,LEN.INSTITUTION]
            CASE INSTITUTION[1,3] MATCHES '/C/':@VM:'/D/'
                SLASH = INDEX(INSTITUTION,'/',2)
                INST.ACCT.DATA = INSTITUTION[SLASH+1,CRLF.POS-(SLASH+1)]
                INSTITUTION= INSTITUTION[CRLF.POS+LEN.CRLF,LEN.INSTITUTION]
            CASE INSTITUTION[1,1] = '/' AND CRLF.POS
                SLASH = INDEX(INSTITUTION,'/',1)
                INST.ACCT.DATA = INSTITUTION[SLASH+1,CRLF.POS-(SLASH+1)]
                INSTITUTION= INSTITUTION[CRLF.POS+LEN.CRLF,LEN.INSTITUTION]
        END CASE
        IF ACCNT.FLD THEN
            OFS.DATA := ACCNT.FLD :':1=': QUOTE(INST.ACCT.DATA):','
            DE.I.FIELD.DATA<2> ='"':ACCNT.FLD:'"':CHARX(251):INST.ACCT.DATA
        END
    END

RETURN
*
************************************************************************************
UPDATE.B.TAG:
************************************************************************************
*
    GOSUB PROCESS.TAG.57D
*
RETURN
*===============
PROCESS.TAG.57D:
*===============
    CONVERT CRLF TO @VM IN INSTITUTION
    NO.CRLF = DCOUNT(INSTITUTION,@VM)

    FOR C.CRLF = 1 TO NO.CRLF
        FIELD.DATA = INSTITUTION<1,C.CRLF>
        FIELD.DATA = QUOTE(FIELD.DATA)
        IF C.CRLF = NO.CRLF THEN
            COMMA.SEP = ''
        END ELSE
            COMMA.SEP = ','
        END

        OFS.DATA = OFS.DATA : FIELD.NAME : ':':C.CRLF:'=':FIELD.DATA :COMMA.SEP

    NEXT C.CRLF

    DE.I.FIELD.DATA<1> ='"':FIELD.NAME:'"':CHARX(251):INSTITUTION
RETURN
****************************************************************************************
END
