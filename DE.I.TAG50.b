* @ValidationCode : MjoxMjUxMDczNjk0OkNwMTI1MjoxNjEwMTEwNDIxMzA4OmluZGh1bWF0aGlzOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMjAyMDExMjgtMDYzMDoxMzE6Nzc=
* @ValidationInfo : Timestamp         : 08 Jan 2021 18:23:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : indhumathis
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 77/131 (58.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG50(TAG,ORD.CUSTOMER,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,DE.I.FIELD.DATA,TAG.ERR)
*-----------------------------------------------------------------------------
* <Rating>-103</Rating>
***********************************************************************************************
*
* This routine assigns SWIFT tag50 - Ordering Cust to the ofs message being
* build up via inward delivery
* translate the raw data into OFS format and written away to the ofs directory specified
*
* Inward
*  Tag           -  The swift tag either 50A or 50
*  Ordering Cust  -  The swift data
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
* 10/10/02 - BG_100002334
*            MT 101 changes introduced. The tags 50G, H, C, L are
*            included.
*            Also return the Account  number if found in the
*            ORD.CUSTOMER for the tag id
*
* 29/07/04 - CI_10021646
*            Incoming MT103  cannot update full data from SWIFT field 50K.
*            If the tag 50 contains the slash in the first line(not in a first position)
*            get ignored.
*
* 22/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 13/05/10 -  Task: 27861, Enhancement: 27278
*             Tag 50F support in MT102/MT103/MT202
*
* 06/05/11 - Task 187151
*            Enhancement 187149
*            SWIFT 2011 Changes - Mapped the account number to the Incoming account number, which
*            has been added newly to support account number in TAG50 for MT103 and MT102 msgs.
*
* 11/05/11 - Task 206623
*            Enhancement 187149
*            Changes have been done to update the DE.I.FIELD.DATA correctly.
*
* 16/06/11 - Task No 226591
*            Ref : Defect 224406
*            ORD.CUST.CODE mapped directly to FT.ORD.CUST.CODE field
*
* 26/03/11 - Task 631815
*            Tag or value before sending to OFS is quoted so that the message will not
*            be trauncated
*
* 27/06/13 - Task 715657
*            Unable to process the inward messages with Tag50F
*
* 31/07/2015 - Enhancement 1265068
*              Task 1391515
*              Routine Incorporated
*
* 24/02/2017 - Defect:2028707 / Task:2031596
*              The value marker VM has been preceded with '@' inorder to retain
*              the appropriate meaning.
*
* 2/1/19 - Enhancement 2889117/ Task 2889142
*        - Changes to support CHEQUE.ADVICE
*
* 06/01/21 - Defect 4024971 / Task 4166638
*            Replaced the value "NULL" to "\NULL\" in the ordering customer field of the incoming MT103
*            message to avoid "NULL LINES NOT ALLOWED" error during formatting.
************************************************************************************
*
    $USING EB.SystemTables
    $USING SF.Foundation
    $USING DE.API
    $USING AC.Config
*
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    GOSUB INITIALISE
*
    IF EB.SystemTables.getApplication() EQ 'CHEQUE.ADVICE' THEN
        TEMP.ORD.CUSTOMER = CONVERT(CRLF,@VM,ORD.CUSTOMER)
        NO.CRLF = DCOUNT(TEMP.ORD.CUSTOMER,@VM)
        COMMA.SEP = ','
        FOR C.CRLF = 1 TO NO.CRLF
            OFS.DATA = OFS.DATA : "PAYER" : ':':C.CRLF:'=':QUOTE(TEMP.ORD.CUSTOMER<1,C.CRLF>) :COMMA.SEP
        NEXT C.CRLF
        DE.I.FIELD.DATA<3> ='"':"PAYER":'"':CHARX(251):TEMP.ORD.CUSTOMER
        OFS.DATA = TRIM(OFS.DATA,',','T')
        RETURN
    END
    IF TAG.ERR THEN
        RETURN      ;* BG_100013037 - S
    END   ;* BG_100013037 - E

    GOSUB GET.ORD.ACCT.DATA

    IF ACCT.TO.DR AND ACC.FIELD.NAME THEN
        OFS.DATA := ACC.FIELD.NAME:':1=':QUOTE(ACCT.TO.DR):","        ;* Map account number to IN.ORD.CUST.ACCT
        DE.I.FIELD.DATA = '"':ACC.FIELD.NAME:'"':CHARX(251):ACCT.TO.DR
    END

    BEGIN CASE
        CASE TAG = '50A' OR TAG = '50C' OR TAG = '50G'
            COMP.ID = EB.SystemTables.getIdCompany()
            DE.API.SwiftBic(ORD.CUSTOMER,COMP.ID,CUSTOMER.NO)
            IF CUSTOMER.NO = '' THEN
                CUSTOMER.NO = DEPREFIX:ORD.CUSTOMER
            END ELSE
* If 50A is a bank, then map the field to bank field rather than
* customer field.

                GOSUB CHECK.IF.BANK
            END
            IF BANK THEN
                OFS.DATA := BK.FIELD.NAME:':1=':QUOTE(CUSTOMER.NO)
            END ELSE
                OFS.DATA := FIELD.NAME:':1=': QUOTE(CUSTOMER.NO)
            END
            DE.I.FIELD.DATA<-1> = '"':FIELD.NAME:'"': CHARX(251):CUSTOMER.NO

*
        CASE TAG = '50D' OR TAG = '50K' OR TAG = '50' OR TAG = '50L' OR TAG = '50H' OR (TAG = '50F' AND STRUCT.ORD.TAG)
            CONVERT CRLF TO @VM IN ORD.CUSTOMER
            NO.CRLF = DCOUNT(ORD.CUSTOMER,@VM)
            FOR C.CRLF = 1 TO NO.CRLF
                FIELD.DATA = ORD.CUSTOMER<1,C.CRLF>
* Replacing the text "NULL" with "\NULL\" in the ordering customer field
                IF FIELD.DATA EQ "NULL" THEN
                    FIELD.DATA = "\NULL\"
                    ORD.CUSTOMER<1,C.CRLF> = "\NULL\"
                END
                FIELD.DATA = QUOTE(FIELD.DATA)        ;* Comma may be present
                IF C.CRLF = NO.CRLF THEN
                    COMMA.SEP = ''          ;* BG_100013037 - S
                END ELSE
                    COMMA.SEP = ','
                END     ;* BG_100013037 - E
                OFS.DATA = OFS.DATA : FIELD.NAME : ':':C.CRLF:'=':FIELD.DATA :COMMA.SEP
            NEXT C.CRLF
            DE.I.FIELD.DATA<-1> = '"':FIELD.NAME:'"':CHARX(251):ORD.CUSTOMER
*
            IF TAG  = '50F' THEN
                OFS.DATA = OFS.DATA :',':"ORD.CUST.CODE":':1:1=':QUOTE(ORD.CUST.CODE)         ;* Assign multi-value and sub-value positions as the value is passed in quotes.
                DE.I.FIELD.DATA=DE.I.FIELD.DATA:@FM:'"':"ORD.CUST.CODE":'"':CHARX(251):ORD.CUST.CODE
            END

*
        CASE 1
            TAG.ERR = 'FIELD NOT MAPPED FOR TAG -':TAG

    END CASE
*
    IF ACCT.TO.DR THEN
        ORD.CUSTOMER<TAG[1,2]> = ACCT.TO.DR       ;* BG_100013037 - S
    END   ;*                                                  BG_100013037 - E
RETURN
*
************************************************************************************
INITIALISE:
************************************************************************************
*

    EB.SystemTables.setEtext('')
    CUSTOMER.NO = ''
    CRLF = CHARX(013):CHARX(010)
    OFS.DATA = ''
    LEN.CRLF = LEN(CRLF)
    LEN.ORD.CUSTOMER = LEN(ORD.CUSTOMER)
    DEPREFIX = ''
    FIELD.NAME = ''
    TAG.ERR = ''
    FIELD.DATA = ''
    DE.I.FIELD.DATA = ''
    BANK = ''
    ACC.FIELD.NAME = ''
    ORD.CUST.CODE=''
*
    STRUCT.ORD.TAG = ''
    IF TAG<3> MATCHES '102':@VM:'103':@VM:'202C':@VM:'110' THEN
        STRUCT.ORD.TAG = 1
        TAG = TAG<1>
    END
*
    ACCT.TO.DR = ''

*
    BEGIN CASE
*
        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'
            FIELD.NAME = 'IN.ORDERING.CUS'
            BK.FIELD.NAME ='IN.ORDERING.BK'
            DEPREFIX = 'SW-'
            ACC.FIELD.NAME = 'IN.ORD.CUST.ACCT'
*
        CASE EB.SystemTables.getApplication() = 'AC.EXPECTED.RECS'
            FIELD.NAME = 'ORD.CUSTOMER'
            BK.FIELD.NAME = 'ORD.INSTITUTION'
            DEPREFIX = 'SW-'
            
        CASE EB.SystemTables.getApplication() = 'CHEQUE.ADVICE'
            NULL
            
        CASE 1
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG

*
    END CASE

RETURN
********************************************************************
GET.ORD.ACCT.DATA:
********************************************************************
* CHanges relating to 50H / G. If 50H or 50G comes in the message, then
* it would contain the account to be debited...
* Split the account no and populate into the debit side.

* BG_100002334 S
    SLASH.FOUND = INDEX(ORD.CUSTOMER,'/',1)
    CRLF.POSITION = INDEX(ORD.CUSTOMER,CRLF,1)
*
    IF SLASH.FOUND THEN
* CI_10021646 S
        BEGIN CASE
            CASE ORD.CUSTOMER[1,2] = '//'
                ORD.CUSTOMER = ORD.CUSTOMER[CRLF.POSITION+LEN.CRLF,LEN.ORD.CUSTOMER]

            CASE ORD.CUSTOMER[1,3] MATCHES '/C/':@VM:'/D/'
                SLASH = INDEX(ORD.CUSTOMER,'/',2)
                ACCT.TO.DR = ORD.CUSTOMER[SLASH+1,CRLF.POSITION-(SLASH+1)]
                ORD.CUSTOMER= ORD.CUSTOMER[CRLF.POSITION+LEN.CRLF,LEN.ORD.CUSTOMER]

            CASE ORD.CUSTOMER[1,1] = '/' AND CRLF.POSITION
                SLASH = INDEX(ORD.CUSTOMER,'/',1)
                ACCT.TO.DR = ORD.CUSTOMER[SLASH+1,CRLF.POSITION-(SLASH+1)]
                ORD.CUSTOMER= ORD.CUSTOMER[CRLF.POSITION+LEN.CRLF,LEN.ORD.CUSTOMER]

            CASE STRUCT.ORD.TAG AND ORD.CUSTOMER[5,1] EQ '/' AND ORD.CUSTOMER[8,1] EQ '/'
                CHK.ORD.CUSTOMER = ORD.CUSTOMER[CRLF.POSITION+LEN.CRLF,LEN.ORD.CUSTOMER]
                ORD.CUST.CODE=ORD.CUSTOMER[1,CRLF.POSITION-1]
                IF CHK.ORD.CUSTOMER[1,2] = '1/' THEN
                    ORD.CUSTOMER = CHK.ORD.CUSTOMER
                END
        END CASE
* CI_10021646 E
    END
* BG_100002334 E
*

*
RETURN


********************************************************************
CHECK.IF.BANK:
********************************************************************
    BANK = '' ; YRETURN = ''
    AC.Config.CheckAccountClass("BANK","",CUSTOMER.NO,"",YRETURN)
    IF YRETURN = 'YES' THEN
        BANK = 1    ;* BG_100013037 - S
    END   ;* BG_100013037 - E


RETURN

END




