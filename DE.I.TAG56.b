* @ValidationCode : MjotNDM0ODYxMjA5OkNwMTI1MjoxNTQ1Mzg4NzE0NzU4OnJ2YXJhZGhhcmFqYW46LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxODEyLjIwMTgxMTIzLTEzMTk6LTE6LTE=
* @ValidationInfo : Timestamp         : 21 Dec 2018 16:08:34
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
$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG56(TAG,INTERMEDIARY,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,DE.I.FIELD.DATA,TAG.ERR)
*-----------------------------------------------------------------------------
* <Rating>-53</Rating>
*********************************************************************************************
*
* This routine assigns SWIFT tag56 - Imtermediary to the ofs message being
* build up via inward delivery
* translate the raw data into OFS format and written away to the ofs directory specified
*
* Inward
*  Tag           -  The swift tag either 56A or 56D
*  Intermediary  -  The swift data
*
* Outward
* OFS.DATA      - The corresponding application field in OFS format
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
* 07/10/02 - EN_10001322
*            Account Fields for SWIFT 2002 Usage
*
* 05/11/02 - BG_100002640
*            Store the tag details in IN.INTERMED.BK and not INTERMED.BANK
* 19/12/02 - CI_10005670
*               // may be clearing codes and hence if // is present
*            it should not be treated as account numbers.
*            Map the incoming tag details directly to INTERMEDIARY of
*            AC.EXPECTED.RECS application.
*
*
* 28/01/04 - CI_10016936
*            While mapping the Account field data to OFS.DATA, use the
*            syntax ACCOUNT field name :1= Account field data content
*
* 21/02/07 - BG_100013037
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
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
*
* 03/09/2018 - Enhancement 2719154 / Task 2722527
*              Map values of TAG56 to ORG.CORRESP.BIC and CORRESP.ACCOUNT in AC.EXPECTED.RECS
*
************************************************************************************
*
    $USING EB.SystemTables
    $USING SF.Foundation
    $USING DE.API
*
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    GOSUB INITIALISE
    IF B.TAG THEN
        GOSUB UPDATE.B.TAG
    END

    IF TAG.ERR OR B.TAG THEN
        RETURN
    END
    
* Get the actual TAG56 value
    ACT.INTERMEDIARY = INTERMEDIARY
    GOSUB GET.INTERMED.DATA
*
    BEGIN CASE
        
        CASE TAG = '56A'
        
            INTERMEDIARY.DATA = INTERMEDIARY
            
* Populate intermediary with TAG56 actual value when the application is AC.EXPECTED.RECS
            IF MAP.ADDITIONAL.VALUES.TO.ACER AND EB.SystemTables.getApplication() EQ 'AC.EXPECTED.RECS' THEN
                INTERMEDIARY = ACT.INTERMEDIARY
                
* Map Intermediary Account to CORRESP.ACCOUNT
                IF INTERM.ACCT.DATA THEN
                    OFS.DATA := 'CORRESP.ACCOUNT=': INTERM.ACCT.DATA:','
                END
            END
        
            COMP.ID = EB.SystemTables.getIdCompany()
            
* Populate each line on INTERMEDIARY in seperate multivalue fields of INTERMEDIARY field
            CONVERT CRLF TO @VM IN INTERMEDIARY

            NO.CRLF = DCOUNT(INTERMEDIARY,@VM)

            FOR C.CRLF = 1 TO NO.CRLF
                
                FIELD.DATA = INTERMEDIARY<1,C.CRLF>
                
                DE.API.SwiftBic(FIELD.DATA,COMP.ID,CUSTOMER.NO)
                IF CUSTOMER.NO = '' THEN
                    CUSTOMER.NO = DEPREFIX:FIELD.DATA
                END
            
                IF C.CRLF = NO.CRLF THEN
                    COMMA.SEP = ''
                END ELSE
                    COMMA.SEP = ','
                END
                OFS.DATA := FIELD.NAME: ':':C.CRLF:'=': QUOTE(CUSTOMER.NO) :COMMA.SEP
                
            NEXT C.CRLF
                
            DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"':CHARX(251):CUSTOMER.NO
            
            IF MAP.ADDITIONAL.VALUES.TO.ACER THEN
                DE.I.FIELD.DATA<3> = "CORRESP.ACCOUNT":CHARX(251):INTERM.ACCT.DATA
                DE.I.FIELD.DATA<4> = "ORG.CORRESP.BIC":CHARX(251):INTERMEDIARY.DATA
            END
*
        CASE TAG = '56D'
        
* Populate intermediary with TAG56 actual value when the application is AC.EXPECTED.RECS
            IF MAP.ADDITIONAL.VALUES.TO.ACER AND EB.SystemTables.getApplication() EQ 'AC.EXPECTED.RECS' THEN
                INTERMEDIARY = ACT.INTERMEDIARY
                
* Map Intermediary Account to CORRESP.ACCOUNT
                IF INTERM.ACCT.DATA THEN
                    OFS.DATA := 'CORRESP.ACCOUNT=': INTERM.ACCT.DATA:','
                END
            END

            CONVERT CRLF TO @VM IN INTERMEDIARY
*
            NO.CRLF = DCOUNT(INTERMEDIARY,@VM)

*
            FOR C.CRLF = 1 TO NO.CRLF
*
                FIELD.DATA = INTERMEDIARY<1,C.CRLF>
                FIELD.DATA = QUOTE(FIELD.DATA)
                IF C.CRLF = NO.CRLF THEN
                    COMMA.SEP = ''
                END ELSE
                    COMMA.SEP = ','
                END
                OFS.DATA = OFS.DATA : FIELD.NAME : ':':C.CRLF:'=':FIELD.DATA :COMMA.SEP

            NEXT C.CRLF
            DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"':CHARX(251):INTERMEDIARY
            
            IF MAP.ADDITIONAL.VALUES.TO.ACER THEN
                DE.I.FIELD.DATA<3> = "CORRESP.ACCOUNT":CHARX(251):INTERM.ACCT.DATA
            END
*
        CASE TAG = '56C'
            RETURN
*

        CASE 1
            TAG.ERR = 'FIELD NOT MAPPED FOR TAG -':TAG

*
    END CASE
*
RETURN
************************************************************************************
UPDATE.B.TAG:
************************************************************************************
    CONVERT CRLF TO @VM IN INTERMEDIARY

    NO.CRLF = DCOUNT(INTERMEDIARY,@VM)


    FOR C.CRLF = 1 TO NO.CRLF


        FIELD.DATA = INTERMEDIARY<1,C.CRLF>
        FIELD.DATA = QUOTE(FIELD.DATA)
        IF C.CRLF = NO.CRLF THEN
            COMMA.SEP = ''
        END ELSE
            COMMA.SEP = ','
        END
        OFS.DATA = OFS.DATA : FIELD.NAME : ':':C.CRLF:'=':FIELD.DATA :COMMA.SEP


    NEXT C.CRLF
    DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"':CHARX(251):INTERMEDIARY
*
RETURN
************************************************************************************
INITIALISE:
************************************************************************************
*

    EB.SystemTables.setEtext('')
    CUSTOMER.NO = ''
    CRLF = CHARX(013):CHARX(010)
    OFS.DATA = ''
    LEN.CRLF = LEN(CRLF)
    LEN.INTERMEDIARY = LEN(INTERMEDIARY)
    DEPREFIX = ''
    FIELD.NAME = ''
    FIELD.DATA = ''
    TAG.ERR = ''
    DE.I.FIELD.DATA = ''
    INTERM.ACCT.DATA = ''
    ACCOUNT.FIELD = ''

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
                FIELD.NAME = 'IN.C.INTMED.BK'
            END ELSE
                FIELD.NAME = 'IN.INTERMED.BK'
                ACCOUNT.FIELD = 'IN.INTERMED.ACC'
            END
            DEPREFIX = 'SW-'
*
        CASE EB.SystemTables.getApplication() = 'AC.EXPECTED.RECS'
            FIELD.NAME = 'INTERMEDIARY'
            DEPREFIX = 'SW-'
        CASE 1
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG
*
    END CASE

* Flag to indicate the Block/Unblock of mapping TAG56 values to ORG.CORRESP.BIC and CORRESP.ACCOUNT in AC.EXPECTED.RECS
    MAP.ADDITIONAL.VALUES.TO.ACER = 1

RETURN

***********************************************************************
GET.INTERMED.DATA:
***********************************************************************

    IF INDEX(INTERMEDIARY,'/',1) THEN
        CRLF.POS = INDEX(INTERMEDIARY,CRLF,1)
*
* Check if / is present in the content of tag 56.

        SLASH = INDEX(INTERMEDIARY,'/',1)

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
            CASE INTERMEDIARY[1,2] = '//'
                INTERMEDIARY= INTERMEDIARY[CRLF.POS+LEN.CRLF,LEN.INTERMEDIARY]
            CASE INTERMEDIARY[1,3] MATCHES '/C/':@VM:'/D/'
                SLASH = INDEX(INTERMEDIARY,'/',2)
                INTERM.ACCT.DATA = INTERMEDIARY[SLASH+1,CRLF.POS-(SLASH+1)]
                INTERMEDIARY= INTERMEDIARY[CRLF.POS+LEN.CRLF,LEN.INTERMEDIARY]
            CASE INTERMEDIARY[1,1] = '/' AND CRLF.POS
                INTERM.ACCT.DATA = INTERMEDIARY[SLASH+1,CRLF.POS-(SLASH+1)]
                INTERMEDIARY= INTERMEDIARY[CRLF.POS+LEN.CRLF,LEN.INTERMEDIARY]
        END CASE
        IF ACCOUNT.FIELD THEN
            OFS.DATA := ACCOUNT.FIELD :':1=': QUOTE(INTERM.ACCT.DATA):','
            DE.I.FIELD.DATA<2> ='"':ACCOUNT.FIELD:'"':CHARX(251):INTERM.ACCT.DATA
        END
*
    END

RETURN
END
