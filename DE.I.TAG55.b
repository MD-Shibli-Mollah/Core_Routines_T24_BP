* @ValidationCode : MjoxNzk4OTcyOTc4OkNwMTI1MjoxNTQ1MjE5MzQ4ODA4OnJ2YXJhZGhhcmFqYW46LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxODEyLjIwMTgxMTIzLTEzMTk6LTE6LTE=
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

*-----------------------------------------------------------------------------
* <Rating>-72</Rating>
*-----------------------------------------------------------------------------
$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG55(TAG,THIRD.REIMB.BK,OFS.DATA,SENDING.CUSTOMER,CCY,SPARE3,SPARE4,DE.I.FIELD.DATA,TAG.ERR)
***********************************************************************************************
*
* This routine assigns SWIFT tag55 - Receivers THIRD.REIMB.BK account to the ofs message being
* build up via inward delivery
*
* Inward
*  TAG               -  The Tag ID if it is present (TAG 55 may be optional)
*                       If not present the customer should have a single account, check
*                       this is so and find the account
*  SENDING.CUSTOMER  -  Customer No
*  CCY               -  Currency of account
*
* Outward
*  OFS.DATA          -  The corresponding application field in OFS format - an account
*  TAG.ERR           -  Tag err
*  DE.I.FIELD.DATA   -  Field name :TM: Field data in VM format

***********************************************************************************************
*
*       MODIFICATIONS
*      ---------------
*
* 29/01/03 - EN_10001611
*            New Program
*
* 21/02/03 - BG_100003558
*            Bug fix for Third reimbursement Institution
*            - Set correct field name in ACCOUNT.FIELD
*
*
* 28/01/04 - CI_10016936
*            While mapping the Account field data to OFS.DATA, use the
*            syntax ACCOUNT field name :1= Account field data content
*
* 17/02/07 - BG_100013036
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
************************************************************************************
*
    $USING SF.Foundation
    $USING EB.SystemTables
    $USING DE.API

    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    GOSUB INITIALISE
    IF TAG.ERR THEN
        RETURN      ;* BG_100013036 - S
    END   ;* BG_100013036 - E
    GOSUB GET.IND.ACCT.NO
    BEGIN CASE
        CASE TAG = '55A'
            COMP.ID = EB.SystemTables.getIdCompany()
            DE.API.SwiftBic(THIRD.REIMB.BK,COMP.ID,CUSTOMER.NO)
            IF CUSTOMER.NO EQ '' THEN
                CUSTOMER.NO = EB.SystemTables.getPrefix():THIRD.REIMB.BK
            END
            OFS.DATA := FIELD.NAME:':1=': QUOTE(CUSTOMER.NO)
            DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"': CHARX(251):CUSTOMER.NO

        CASE TAG = '55B'
            OFS.DATA := FIELD.NAME :':1=':QUOTE(THIRD.REIMB.BK)
            DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"': CHARX(251):THIRD.REIMB.BK

        CASE TAG = '55D'
            CONVERT CRLF TO @VM IN THIRD.REIMB.BK
            NO.CRLF = DCOUNT(THIRD.REIMB.BK,@VM)
            FOR C.CRLF = 1 TO NO.CRLF
                FIELD.DATA = THIRD.REIMB.BK<1,C.CRLF>
                FIELD.DATA = QUOTE(FIELD.DATA)
                IF C.CRLF = NO.CRLF THEN
                    COMMA.SEP = ''          ;* ;* BG_100013036 - S
                END ELSE
                    COMMA.SEP = ','
                END     ;* ;* BG_100013036 - E
                OFS.DATA :=FIELD.NAME:':':C.CRLF:'=':FIELD.DATA:COMMA.SEP
            NEXT C.CRLF
*
            DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"':CHARX(251):THIRD.REIMB.BK
*

        CASE 1
            TAG.ERR = 'FIELD NOT MAPPED FOR TAG -':TAG

    END CASE

RETURN

*==============
INITIALISE:
*==============
    OFS.DATA = ''
    FIELD.NAME = ''
    TAG.ERR = ''
    CRLF = CHARX(013):CHARX(10)
    LEN.THIRD.REIMB.BK = LEN(THIRD.REIMB.BK)
    LEN.CRLF = LEN(CRLF)
    FIELD.DATA = ''
    DE.I.FIELD.DATA = ''
    REIMB.ACCT.DATA = ''

    BEGIN CASE

        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'

            FIELD.NAME = 'IN.3RD.REIMB.BK'
            ACCOUNT.FIELD = 'IN.3RD.REIMB.ACC'        ;* BG_100003558 S/E Earlier the value 'IN.3RD.REIMB.ACC' was set

        CASE 1

            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG
*

    END CASE

RETURN
*==================
GET.IND.ACCT.NO:
*==================

    IF INDEX(THIRD.REIMB.BK,'/',1) THEN
        CRLF.POS = INDEX(THIRD.REIMB.BK,CRLF,1)

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
            CASE THIRD.REIMB.BK[1,2] = '//'
                THIRD.REIMB.BK= THIRD.REIMB.BK[CRLF.POS+LEN.CRLF,LEN.THIRD.REIMB.BK]          ;* BG_100003558 S/E  Earlier the value was set to THIRRD.REIMB.BK
            CASE THIRD.REIMB.BK[1,3] MATCHES '/C/':@VM:'/D/'
                SLASH = INDEX(THIRD.REIMB.BK,'/',2)
                REIMB.ACCT.DATA = THIRD.REIMB.BK[SLASH+1,CRLF.POS-(SLASH+1)]
                THIRD.REIMB.BK= THIRD.REIMB.BK[CRLF.POS+LEN.CRLF,LEN.THIRD.REIMB.BK]
            CASE THIRD.REIMB.BK[1,1] = '/' AND CRLF.POS
                SLASH = INDEX(THIRD.REIMB.BK,'/',1)
                REIMB.ACCT.DATA = THIRD.REIMB.BK[SLASH+1,CRLF.POS-(SLASH+1)]
                THIRD.REIMB.BK= THIRD.REIMB.BK[CRLF.POS+LEN.CRLF,LEN.THIRD.REIMB.BK]
        END CASE

        OFS.DATA := ACCOUNT.FIELD :':1=':QUOTE(REIMB.ACCT.DATA):','         ;* CI_10016936 S/E
        DE.I.FIELD.DATA<2> ='"':ACCOUNT.FIELD:'"':CHARX(251):REIMB.ACCT.DATA
*

    END
RETURN

*------------------
END
