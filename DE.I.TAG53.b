* @ValidationCode : MjotMTQ0NTk5MTk3MDpDcDEyNTI6MTU0NjUwODk2MzMzODphYmNpdmFudWphOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTIuMjAxODExMjMtMTMxOToxNTY6MzE=
* @ValidationInfo : Timestamp         : 03 Jan 2019 15:19:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : abcivanuja
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 31/156 (19.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG53(TAG,CORRESPONDENT,OFS.DATA,SENDING.CUSTOMER,CCY,SPARE3,SPARE4, DE.I.FIELD.DATA,TAG.ERR)       ;* CI_10012844 -S/E
*-----------------------------------------------------------------------------
* <Rating>-102</Rating>
***********************************************************************************************
*
* This routine assigns SWIFT tag53 - Senders CORRESPONDENT account to the ofs message being
* build up via inward delivery
*
* Inward
*  TAG            -  The Tag ID if it is present (TAG 53 may be optional)
*                       If not present the customer should have a single account, check
*                       this is so and find the account
*  CORRESPONDENT     -  Optional as above
*  SENDING.CUSTOMER  -  Customer No
*  CCY               -  Currency of account
*
* Outward
*  OFS.DATA          -  The corresponding application field in OFS format - an account
***********************************************************************************************
*
*       MODIFICATIONS
*      ---------------
*
* 24/07/02 - EN_10000786
*            New Program
*
* 22/09/03 - CI_10012844 / CI_10012939
*            All formats of tag 53a supported.  Parameter,
*            spare5 changed to DE.I.FIELD.DATA to return acct no.
*
* 29/09/03 - CI_10013039
*            The 'QUOTE' function is used in TAG 53B to store
*            all special characters.
*
* 30/09/04 - BG_100007343
*            Process tag 53C for Mt102.
*
* 02/03/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 26/03/11 - Task 631815
*            Tag or value before sending to OFS is quoted so that the message will not
*            be trauncated
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
    $USING DE.API
    $USING FT.Delivery

    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    GOSUB INITIALISE
    IF TAG.ERR THEN
        RETURN      ;* BG_100013037 - S
    END   ;*  BG_100013037 - E
    IF EB.SystemTables.getApplication() EQ 'CHEQUE.ADVICE' THEN
        TEMP.CORRESPONDENT = CONVERT(CRLF,@VM,CORRESPONDENT)
        NO.CRLF = DCOUNT(TEMP.CORRESPONDENT,@VM)
        COMMA.SEP = ','
        FOR C.CRLF = 1 TO NO.CRLF
            OFS.DATA = OFS.DATA : "SENDER.CORR.BANK" : ':':C.CRLF:'=':QUOTE(TEMP.CORRESPONDENT<1,C.CRLF>) :COMMA.SEP
        NEXT C.CRLF
        DE.I.FIELD.DATA<3> ='"':"SENDER.CORR.BANK":'"':CHARX(251):TEMP.CORRESPONDENT
        OFS.DATA = TRIM(OFS.DATA,',','T')
        RETURN
    END
    GOSUB GET.IND.ACCT.NO     ;* CI_10012844 -s/e

    BEGIN CASE

        CASE TAG = '53A'
            COMP.ID = EB.SystemTables.getIdCompany()
            DE.API.SwiftBic(CORRESPONDENT,COMP.ID,CUSTOMER.NO)
            IF CUSTOMER.NO EQ '' THEN
                CUSTOMER.NO = DEPREFIX:CORRESPONDENT
            END
            OFS.DATA := FIELD.NAME:':1=': QUOTE(CUSTOMER.NO)
            DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"': CHARX(251):CUSTOMER.NO

        CASE TAG = '53B'

            OFS.DATA := FIELD.NAME:':1=': QUOTE(CORRESPONDENT)
            DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"': CHARX(251):CORRESPONDENT
            IF SCORR.ACCT.DATA = '' THEN
                RETURN  ;* BG_100013037 - S
            END         ;* BG_100013037 - E

            GOSUB GET.ACCOUNT.NO

        CASE TAG = '53C'

            IF SCORR.ACCT.DATA = '' THEN
                RETURN  ;* BG_100013037 - S
            END         ;* BG_100013037 - E

            GOSUB GET.ACCOUNT.NO

        CASE TAG = '53D'
            CONVERT CRLF TO @VM IN CORRESPONDENT
            NO.CRLF = DCOUNT(CORRESPONDENT,@VM)
            FOR C.CRLF = 1 TO NO.CRLF
                FIELD.DATA = CORRESPONDENT<1,C.CRLF>
                FIELD.DATA = QUOTE(FIELD.DATA)
                IF C.CRLF = NO.CRLF THEN
                    COMMA.SEP = ''          ;* BG_100013037 - S
                END ELSE
                    COMMA.SEP = ','
                END     ;* BG_100013037 - E

                OFS.DATA :=FIELD.NAME:':':C.CRLF:'=':FIELD.DATA:COMMA.SEP

            NEXT C.CRLF
*
            DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"':CHARX(251):CORRESPONDENT


* No TAG53 present - find the account

        CASE 1
            GOSUB FIND.ACCOUNT.NO ;* BG_100013037 - S / E

    END CASE

RETURN

************************************************************************************
INITIALISE:
************************************************************************************
*
    OFS.DATA = ''
    FIELD.NAME = ''
    TAG.ERR = ''    ;* CI_10012844 - s/e
    ACCOUNT.NO = ''

* CI_10012844 -s
    CRLF = CHARX(013):CHARX(10)
    LEN.CRLF = LEN(CRLF)
    LEN.CORRESPONDENT = LEN(CORRESPONDENT)
    SAVE.CORRESPONDENT = CORRESPONDENT

    DE.I.FIELD.DATA = ''
    SCORR.ACCT.DATA = ''
    DEPREFIX = ''
* CI_10012844 -e

    BEGIN CASE

        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'
* CI_10012844 -s
            FIELD.NAME = 'IN.SEND.CORR.BK'
            ACCOUNT.FIELD = 'IN.SEND.CORR.ACC'        ;* to store the account no.
            DEPREFIX = 'SW-'
* CI_10012844 -e

        CASE EB.SystemTables.getApplication() = 'CHEQUE.ADVICE'
            NULL
        CASE 1
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG

    END CASE

RETURN

* CI_10012844 -s
*==================
GET.IND.ACCT.NO:
*==================
* Identify the account details and Bank details from the tag.

    SCORR.ACCT.DATA = ''

    IF INDEX(CORRESPONDENT,'/',1) THEN
        CRLF.POS = INDEX(CORRESPONDENT,CRLF,1)

        BEGIN CASE
            CASE (CORRESPONDENT[1,2] = '//') AND (CRLF.POS)
                SLASH = INDEX(CORRESPONDENT,'/',2)
                SCORR.ACCT.DATA = CORRESPONDENT[SLASH+1,CRLF.POS-(SLASH+1)]
                CORRESPONDENT= CORRESPONDENT[CRLF.POS+LEN.CRLF,LEN.CORRESPONDENT]

            CASE (CORRESPONDENT[1,3] MATCHES '/C/':@VM:'/D/') AND (CRLF.POS)
                SLASH = INDEX(CORRESPONDENT,'/',2)
                SCORR.ACCT.DATA = CORRESPONDENT[SLASH+1,CRLF.POS-(SLASH+1)]
                CORRESPONDENT= CORRESPONDENT[CRLF.POS+LEN.CRLF,LEN.CORRESPONDENT]

            CASE (CORRESPONDENT[1,1] = '/') AND (CRLF.POS)
                SLASH = INDEX(CORRESPONDENT,'/',1)
                SCORR.ACCT.DATA = CORRESPONDENT[SLASH+1,CRLF.POS-(SLASH+1)]
                CORRESPONDENT= CORRESPONDENT[CRLF.POS+LEN.CRLF,LEN.CORRESPONDENT]

            CASE NOT(CRLF.POS)
                IF CORRESPONDENT[1,1] = '/' THEN
                    SLASH = INDEX(CORRESPONDENT,'/',1)          ;* BG_100013037 - S
                END     ;* BG_100013037 - E

                IF (CORRESPONDENT[1,2] = '//') OR (CORRESPONDENT[1,3] MATCHES '/C/':@VM:'/D/') THEN
                    SLASH = INDEX(CORRESPONDENT,'/',2)          ;* BG_100013037 - S
                END     ;* BG_100013037 - E

                SCORR.ACCT.DATA = CORRESPONDENT[SLASH+1, LEN.CORRESPONDENT]
                CORRESPONDENT = ''
        END CASE

        IF SCORR.ACCT.DATA THEN
            DE.I.FIELD.DATA<2> ='"':ACCOUNT.FIELD:'"':CHARX(251):SCORR.ACCT.DATA
        END
    END

RETURN
* CI_10012844 -e
******************************************8
* BG_100007343 - S
GET.ACCOUNT.NO:

    ACCOUNT.NO = SCORR.ACCT.DATA

* Get account information for the customer

    CUSTOMER.NO = SENDING.CUSTOMER
    TXN.TYPE = ''
    ACCOUNT.IN = ACCOUNT.NO
    ACCOUNT = ''
    ACCOUNT.CATEGORY = ''
    ACCOUNT.COUNT = ''
    ACCOUNT.CLASS = ''
    ACCOUNT.ERROR = ''
    FT.Delivery.DeIGetAcctNo( CUSTOMER.NO, CCY, TXN.TYPE, ACCOUNT.IN, ACCOUNT, ACCOUNT.CATEGORY, ACCOUNT.COUNT,ACCOUNT.CLASS, ACCOUNT.ERROR)

* Check it isn't a NOSTRO

    LOCATE ACCOUNT.IN<2> IN ACCOUNT.CATEGORY<1> SETTING POS THEN
        IF ACCOUNT.CLASS<POS> EQ 'NOSTRO' THEN
            TAG.ERR = 'ERROR - ACCOUNT IS A NOSTRO'
        END
    END

* Check it is for the correct customer

    IF SENDING.CUSTOMER # '' AND SENDING.CUSTOMER # CUSTOMER.NO THEN
        TAG.ERR = 'ERROR - ACCOUNT DOES NOT BELONG TO SENDING.CUSTOMER'
    END

    ACCOUNT.NO = ACCOUNT.IN<1>

    IF ACCOUNT.NO THEN
        DE.I.FIELD.DATA<2> ='"':ACCOUNT.FIELD:'"':CHARX(251):ACCOUNT.NO         ;* Acct no. extracted
    END
RETURN
* BG_100007343 -E
*************************************************
* BG_100013037 - S
*===============
FIND.ACCOUNT.NO:
*===============
    CUSTOMER.NO = SENDING.CUSTOMER
    TXN.TYPE = ''
    ACCOUNT = ''
    ACCOUNT.CATEGORY = ''
    ACCOUNT.COUNT = ''
    ACCOUNT.CLASS = ''
    ACCOUNT.ERROR = ''
    ACCOUNT.IN = ''
    FT.Delivery.DeIGetAcctNo( SENDING.CUSTOMER, CCY, TXN.TYPE, ACCOUNT.IN, ACCOUNT, ACCOUNT.CATEGORY, ACCOUNT.COUNT,ACCOUNT.CLASS, ACCOUNT.ERROR)

* Find the customer's VOSTRO and check that there is only one

    LOCATE 'VOSTRO' IN ACCOUNT.CLASS<1> SETTING POS THEN
        IF ACCOUNT.COUNT<POS> GT 1 THEN
            TAG.ERR = 'ERROR - MORE THAN ONE ACCOUNT AVAILABLE'
            ACCOUNT.NO = ''
        END ELSE
            ACCOUNT.NO = ACCOUNT<POS,1>
        END
    END

* CI_10012844 -s
    OFS.DATA := FIELD.NAME:':1=': QUOTE(CORRESPONDENT)   ;* Tag details
    DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"': CHARX(251):CORRESPONDENT
    IF ACCOUNT.NO THEN
        DE.I.FIELD.DATA<2> ='"':ACCOUNT.FIELD:'"':CHARX(251):ACCOUNT.NO         ;* Acct no. extracted
    END
* CI_10012844 -e
RETURN          ;* BG_100013037 - E
*************************************************************************************************************
END
