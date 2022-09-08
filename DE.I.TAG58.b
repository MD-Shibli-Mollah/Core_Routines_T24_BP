* @ValidationCode : Mjo2MTg2NTQzMDY6Q3AxMjUyOjE1NDUyMTkzNDkxMjA6cnZhcmFkaGFyYWphbjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTIuMjAxODExMjMtMTMxOTotMTotMQ==
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
SUBROUTINE DE.I.TAG58(TAG,BEN.BANK,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,DE.I.FIELD.DATA,TAG.ERR)
*-----------------------------------------------------------------------------
* <Rating>-78</Rating>
***********************************************************************************************
*
* This routine assigns SWIFT tag58 - Beneficiary Bank to the ofs message being
* build up via inward delivery
* translate the raw data into OFS format and written away to the ofs directory specified
*
* Inward
*  Tag           -  The swift tag either 58A or 58D
*  BEN.BANK   -  The swift data
*
* Outward
*  OFS.DATA      - The corresponding application field in OFS format
* DE.I.FIELD.DATA - Field name : TM: field values separated by VM
* TAG.ERR         - Tag error.


************************************************************************************
*
*       MODIFICATIONS
*      ---------------
*
* 24/07/02 - EN_10000786
*            New Program
*
* 29/10/02 - BG_100002532
*            Change COMPANY to ID.COMPANY
* 19/12/02 - CI_10005670
*               // may be clearing codes and hence if // is present
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
* 29/11/14 - Defect 1173446/ Task 1183745
*            When the Tag value is quoted, the value is passed to FT without quotes.
*
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
*
************************************************************************************
*
*
    $USING EB.SystemTables
    $USING DE.API
    $USING SF.Foundation
    
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    
    GOSUB INITIALISE
    IF TAG.ERR THEN
        RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037 - E

    GOSUB GET.BEN.ACCT.DATA
*
    BEGIN CASE

        CASE TAG = '58A'

* In this tag , we get the ben account and BIC code of the
* Beneficiary bank.

*            CALL DE.SWIFT.BIC(BEN.BANK,COMPANY,CUSTOMER.NO) ; * BG_100002532 S/E
            COMP.ID = EB.SystemTables.getIdCompany()
            DE.API.SwiftBic(BEN.BANK,COMP.ID,CUSTOMER.NO)
            IF CUSTOMER.NO = '' THEN
                CUSTOMER.NO = DEPREFIX:BEN.BANK
            END
            OFS.DATA := BEN.BANK.FIELD :':1:1=': QUOTE(CUSTOMER.NO)
            DE.I.FIELD.DATA<1> ='"':BEN.BANK.FIELD:'"':CHARX(251):CUSTOMER.NO
*
        CASE TAG = '58D'

            CONVERT CRLF TO @VM IN BEN.BANK
            NO.CRLF = DCOUNT(BEN.BANK,@VM)

*
            FOR C.CRLF = 1 TO NO.CRLF
                FIELD.DATA = BEN.BANK<1,C.CRLF>
                FIELD.DATA = QUOTE(FIELD.DATA)
                IF C.CRLF = NO.CRLF THEN
                    COMMA.SEP = ''          ;* BG_100013037 - S
                END ELSE
                    COMMA.SEP = ','
                END     ;* BG_100013037 - E

                OFS.DATA = OFS.DATA :BEN.BANK.FIELD:':':C.CRLF:'=':FIELD.DATA :COMMA.SEP
            NEXT C.CRLF
*
            DE.I.FIELD.DATA<1> = '"':BEN.BANK.FIELD:'"':CHARX(251):BEN.BANK

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

    EB.SystemTables.setEtext('')
    CRLF = CHARX(013):CHARX(010)
    OFS.DATA = ''
    LEN.CRLF = LEN(CRLF)
    LEN.BEN.BANK = LEN(BEN.BANK)
    DEPREFIX = ''
    FIELD.DATA = ''
    TAG.DATA = ''
    TAG.ERR = ''
    DE.I.FIELD.DATA = ''
    BEN.ACCT.DATA = ''

*
    BEGIN CASE
*
        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'
            BEN.BANK.FIELD = 'IN.BEN.BANK'
            BEN.ACCOUNT.FIELD = 'IN.BEN.ACCT.NO'
            DEPREFIX = 'SW-'
*
        CASE 1
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG

*
    END CASE
*
RETURN
********************************************************************
GET.BEN.ACCT.DATA:
********************************************************************

    IF INDEX(BEN.BANK,'/',1) THEN
        CRLF.POS = INDEX(BEN.BANK,CRLF,1)



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
            CASE BEN.BANK[1,2] = '//'
                BEN.BANK= BEN.BANK[CRLF.POS+LEN.CRLF,LEN.BEN.BANK]
            CASE BEN.BANK[1,3] MATCHES '/C/':@VM:'/D/'
                XX = INDEX(BEN.BANK,'/',2)
                BEN.ACCT.DATA = BEN.BANK[XX+1,CRLF.POS-(XX+1)]
                BEN.BANK= BEN.BANK[CRLF.POS+LEN.CRLF,LEN.BEN.BANK]
            CASE BEN.BANK[1,1] = '/' AND CRLF.POS
                XX = INDEX(BEN.BANK,'/',1)
                BEN.ACCT.DATA = BEN.BANK[XX+1,CRLF.POS-(XX+1)]
                BEN.BANK= BEN.BANK[CRLF.POS+LEN.CRLF,LEN.BEN.BANK]
        END CASE
* CI_10005670 E


        OFS.DATA := BEN.ACCOUNT.FIELD :':1=': QUOTE(BEN.ACCT.DATA):','          ;* CI_10016936 S/E
        DE.I.FIELD.DATA<2> ='"':BEN.ACCOUNT.FIELD:'"':CHARX(251):BEN.ACCT.DATA

    END
RETURN


END
