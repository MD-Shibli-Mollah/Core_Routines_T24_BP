* @ValidationCode : MjotOTA3MjE0Nzc4OkNwMTI1MjoxNTQ2NTA4OTYzOTAwOmFiY2l2YW51amE6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgxMi4yMDE4MTEyMy0xMzE5Ojg1OjI5
* @ValidationInfo : Timestamp         : 03 Jan 2019 15:19:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : abcivanuja
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 29/85 (34.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG54(TAG,REC.CORR.BANK,OFS.DATA,SENDING.CUSTOMER,CCY,SPARE3,SPARE4,DE.I.FIELD.DATA,TAG.ERR)
*-----------------------------------------------------------------------------
* <Rating>-81</Rating>
***********************************************************************************************
*
* This routine assigns SWIFT tag54 - Receivers REC.CORR.BANK account to the ofs message being
* build up via inward delivery
*
* Inward
*  TAG            -  The Tag ID if it is present (TAG 54 may be optional)
*                       If not present the customer should have a single account, check
*                       this is so and find the account
*  SENDING.CUSTOMER  -  Customer No
*  CCY               -  Currency of account
*
* Outward
*  OFS.DATA          -  The corresponding application field in OFS format - an account
*  TAG.ERR           -  Tag err
*  DE.I.FIELD.DATA   - Field name :TM: Field data in VM format

***********************************************************************************************
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
*        // may be clearing codes and hence if // is present
*            it should not be treated as account numbers.
*
* 28/01/04 - CI_10016936
*            While mapping the Account field data to OFS.DATA, use the
*            syntax ACCOUNT field name :1= Account field data content
*
* 21/02/07 - BG_100013037
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
    $USING FT.Contract
    
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    GOSUB INITIALISE
    IF TAG.ERR THEN
        RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037 - E
    IF EB.SystemTables.getApplication() EQ 'CHEQUE.ADVICE' THEN
        TEMP.REC.CORR.BANK = CONVERT(CRLF,@VM,REC.CORR.BANK)
        NO.CRLF = DCOUNT(TEMP.REC.CORR.BANK,@VM)
        COMMA.SEP = ','
        FOR C.CRLF = 1 TO NO.CRLF
            OFS.DATA = OFS.DATA : "RECEIVER.CORR.BANK" : ':':C.CRLF:'=':QUOTE(TEMP.REC.CORR.BANK<1,C.CRLF>) :COMMA.SEP
        NEXT C.CRLF
        OFS.DATA = TRIM(OFS.DATA,',','T')
        DE.I.FIELD.DATA<3> ='"':"RECEIVER.CORR.BANK":'"':CHARX(251):TEMP.REC.CORR.BANK
        RETURN
    END
    GOSUB GET.IND.ACCT.NO


    BEGIN CASE
        CASE TAG = '54A'
            COMP.ID = EB.SystemTables.getIdCompany()

            DE.API.SwiftBic(REC.CORR.BANK,COMP.ID,CUSTOMER.NO)
            IF CUSTOMER.NO EQ '' THEN
                CUSTOMER.NO = EB.SystemTables.getPrefix():REC.CORR.BANK
            END
            OFS.DATA := FIELD.NAME:':1=': QUOTE(CUSTOMER.NO)
            DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"': CHARX(251):CUSTOMER.NO         ;* EN_10001322 - s/e

        CASE TAG = '54B'

            OFS.DATA := FIELD.NAME :':1=':QUOTE(REC.CORR.BANK)
            DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"': CHARX(251):REC.CORR.BANK       ;* EN_10001322 - S/E

        CASE TAG = '54D'
            CONVERT CRLF TO @VM IN REC.CORR.BANK
            NO.CRLF = DCOUNT(REC.CORR.BANK,@VM)
            FOR C.CRLF = 1 TO NO.CRLF
                FIELD.DATA = REC.CORR.BANK<1,C.CRLF>
                FIELD.DATA = QUOTE(FIELD.DATA)
                IF C.CRLF = NO.CRLF THEN
                    COMMA.SEP = ''
                END ELSE          ;* BG_100013037 - S
                    COMMA.SEP = ','         ;*BG_100013037 - S
                END     ;* BG_100013037 - E

                OFS.DATA :=FIELD.NAME:':':C.CRLF:'=':FIELD.DATA:COMMA.SEP

            NEXT C.CRLF
*
            DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"':CHARX(251):REC.CORR.BANK        ;* EN_10001322 - S/E
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
    LEN.REC.CORR.BANK = LEN(REC.CORR.BANK)
    LEN.CRLF = LEN(CRLF)
    FIELD.DATA = ''
    DE.I.FIELD.DATA = ''
    REC.ACCT.DATA = ''

    BEGIN CASE

        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'

            FIELD.NAME = 'IN.REC.CORR.BK'
            ACCOUNT.FIELD = 'IN.REC.CORR.ACC'         ;* EN_10001322 - S/E
            
        CASE EB.SystemTables.getApplication() = 'CHEQUE.ADVICE'
            NULL
            
        CASE 1

            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG
*

    END CASE

RETURN
*==================
GET.IND.ACCT.NO:
*==================

    IF INDEX(REC.CORR.BANK,'/',1) THEN
        CRLF.POS = INDEX(REC.CORR.BANK,CRLF,1)
*
* EN_10001322 - S

* CI_10005670 S

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
            CASE REC.CORR.BANK[1,2] = '//'
                REC.CORR.BANK= REC.CORR.BANK[CRLF.POS+LEN.CRLF,LEN.REC.CORR.BANK]
            CASE REC.CORR.BANK[1,3] MATCHES '/C/':@VM:'/D/'
                SLASH = INDEX(REC.CORR.BANK,'/',2)
                REC.ACCT.DATA = REC.CORR.BANK[SLASH+1,CRLF.POS-(SLASH+1)]
                REC.CORR.BANK= REC.CORR.BANK[CRLF.POS+LEN.CRLF,LEN.REC.CORR.BANK]
            CASE REC.CORR.BANK[1,1] = '/' AND CRLF.POS
                SLASH = INDEX(REC.CORR.BANK,'/',1)
                REC.ACCT.DATA = REC.CORR.BANK[SLASH+1,CRLF.POS-(SLASH+1)]
                REC.CORR.BANK= REC.CORR.BANK[CRLF.POS+LEN.CRLF,LEN.REC.CORR.BANK]
        END CASE
* CI_10005670 E

        OFS.DATA := ACCOUNT.FIELD :':1=': QUOTE(REC.ACCT.DATA):',' ;* CI_10016936 S/E
        DE.I.FIELD.DATA<2> ='"':ACCOUNT.FIELD:'"':CHARX(251):REC.ACCT.DATA
*

* EN_10001322 - E
    END
RETURN


END
