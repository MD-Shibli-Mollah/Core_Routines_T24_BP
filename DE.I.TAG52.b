* @ValidationCode : MjotMjAxMjkwODA3NDpDcDEyNTI6MTU2NzA3NTI4OTg4NDpqcHJpeWFkaGFyc2hpbmk6NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwOC4yMDE5MDcwNS0wMjQ3OjExMDo4MA==
* @ValidationInfo : Timestamp         : 29 Aug 2019 16:11:29
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jpriyadharshini
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 80/110 (72.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190705-0247
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG52(TAG,ORD.INST,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,DE.I.FIELD.DATA,TAG.ERR)
*-----------------------------------------------------------------------------
* <Rating>-83</Rating>
*****************************************************************
*
* This routine assigns SWIFT tag52 - Ordering Bank to the ofs message being
* build up via inward delivery
* translate the raw data into OFS format and written away to the ofs directory specified
*
* Inward
*  Tag            -  The swift tag either 52A or 52D
*  Ord inst       -  The swift data
* 
* Outward
* OFS.DATA        - The corresponding application field in OFS format
* DE.I.FIELD.DATA - Field name : TM: field values separated by VM
* TAG.ERR         - Tag error.

*********************************************************************
*
*       MODIFICATIONS
*      ---------------
*
* 24/07/02 - EN_10000786
*            New Program
*
* 06/05/04 - EN_10002261
*            SWIFT related changes for bulk credit/debit processing
*
* 17/06/04 - BG_100006684
*            If account no unable to find in the message MT111, then an
*            EB.MESSAGE.111 will be created and the tag52 info is mapped to
*            DRAWER.CUS and DRAWER.ACC  in EB.MESSAGE.111.
*
* 30/06/04 - BG_100006876
*            For message type 102 tag 52 may have option A or C
*
* 07/05/05 - CI_10030002
*            Map tag52 of MT111 to IN.DRAWER.BANK Field in EB.MESSAGE.111
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
* 08/10/2019 - En_2789881/ Task 2789890
*             New Template for STOP.REQUEST.STATUS as part of introducing functionality for inward MT112
*             (status of request for stop payment). Map Tag 52 of MT112 to DRAWER.BANK.ACCT, IN.DRAWER.BANK in STOP.REQUEST.STATUS.
*
* 24/11/18 - Enhancement 2789882 / Task 2789894
*            New Template for STOP.REQUEST.STATUS as part of introducing functionality for inward MT112.
*            Revert changes related with parsing and determining BIC code/Customer from Tag 52A
*
* 2/1/19 - Enhancement 2889117/ Task 2889142
*        - Changes to support CHEQUE.ADVICE
*
*********************************************************************
*
    $USING EB.SystemTables
    $USING SF.Foundation
    $USING DE.API
*
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)

    GOSUB INITIALISE
    IF TAG.ERR THEN
        RETURN
    END   ;* BG_100013037 - E
    GOSUB GET.ORD.ACCT.DATA

    BEGIN CASE
        CASE TAG = '52A'
*           Set the OFS Data for FIELD.NAME, defined for each application.
            IF EB.SystemTables.getApplication() EQ 'STOP.REQUEST.STATUS' THEN ;* Populate IN.DRAWER.BANK with a copy of Tag 52.
                ORD.INST = SAVED.ORD.INST
                GOSUB GET.ORD.INST.DETAILS
            END ELSE
                COMP.ID = EB.SystemTables.getIdCompany()
                DE.API.SwiftBic(ORD.INST,COMP.ID,CUSTOMER.NO)
                IF CUSTOMER.NO EQ '' THEN
                    CUSTOMER.NO = EB.SystemTables.getPrefix():ORD.INST
                END
                OFS.DATA := FIELD.NAME:':1=':QUOTE(CUSTOMER.NO)
                DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"': CHARX(251):CUSTOMER.NO
           
                IF EB.SystemTables.getApplication() EQ 'EB.MESSAGE.111' THEN
                    OFS.DATA := ',':BIC.FIELD:':1=':QUOTE(ORD.INST)
                    DE.I.FIELD.DATA<3> = '"':BIC.FIELD:'"': CHARX(251):ORD.INST
                END
            END
        
        CASE TAG = '52D' OR TAG = '52C' OR TAG = '52B'
            IF EB.SystemTables.getApplication() EQ 'STOP.REQUEST.STATUS' THEN ;* IN.DRAWER.BANK should be populated with a Copy of Tag 52
                ORD.INST = SAVED.ORD.INST
            END
            GOSUB GET.ORD.INST.DETAILS

        CASE 1
            TAG.ERR = 'FIELD NOT MAPPED FOR TAG -':TAG


    END CASE
*
RETURN
*
**********************************************************************
INITIALISE:
**********************************************************************
*
    CUSTOMER.NO = ''
    FIELD.NAME = ''
    CRLF = CHARX(013):CHARX(010)
    OFS.DATA = ''
    LEN.CRLF = LEN(CRLF)
    LEN.ORD.INST = LEN(ORD.INST)
    SAVED.ORD.INST = ORD.INST ;* Variable to store the actual input data for Ordering Institution/Drawer Bank
    TEMP.ORD.INST = ''
    TAG.ERR = ''
    DE.I.FIELD.DATA = ''
    ACCNT.ID.FLD = ''
    B.TAG = ''
    IF TAG<2> = 'B' THEN
        B.TAG = 1
        TAG = TAG<1>
    END

    BEGIN CASE
        CASE EB.SystemTables.getApplication() = 'AC.EXPECTED.RECS'
            FIELD.NAME = 'ORD.INSTITUTION'
            EB.SystemTables.setPrefix('SW-')

        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'
            IF B.TAG THEN
                FIELD.NAME = 'IN.C.ORD.BK'
            END ELSE
                FIELD.NAME = 'IN.ORDERING.BK'
            END
            EB.SystemTables.setPrefix('SW-')
        CASE EB.SystemTables.getApplication() MATCHES 'PAYMENT.STOP':@VM:'EB.MESSAGE.111'
            FIELD.NAME = 'IN.DRAWER.BANK'
            EB.SystemTables.setPrefix('SW-')
            ACCNT.ID.FLD = "IN.DRAWER.BK.ACCT"
            BIC.FIELD = 'DRAWER.BANK.BIC'
        CASE EB.SystemTables.getApplication() = 'STOP.REQUEST.STATUS'
            FIELD.NAME = 'IN.DRAWER.BANK'
            ACCNT.ID.FLD = 'DRAWER.BANK.ACCOUNT'
        CASE EB.SystemTables.getApplication() = 'CHEQUE.ADVICE'
            FIELD.NAME = 'IN.DRAWER.BANK'
            ACCNT.ID.FLD = 'DRAWER.BANK.ACCOUNT'
        CASE 1
            TAG.ERR = 'APPLICATION MISSING FOR TAG - ':TAG

    END CASE
*
RETURN

**********************************************************************
GET.ORD.ACCT.DATA:
**********************************************************************
    IF INDEX(ORD.INST,'/',1) THEN
        CRLF.POS = INDEX(ORD.INST,CRLF,1)

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
            CASE ORD.INST[1,2] = '//'
                ORD.INST= ORD.INST[CRLF.POS+LEN.CRLF,LEN.ORD.INST]
            CASE ORD.INST[1,3] MATCHES '/C/':@VM:'/D/'
                SLASH = INDEX(ORD.INST,'/',2)
                INST.ACCT.DATA = ORD.INST[SLASH+1,CRLF.POS-(SLASH+1)]
                ORD.INST= ORD.INST[CRLF.POS+LEN.CRLF,LEN.ORD.INST]
            CASE ORD.INST[1,1] = '/' AND CRLF.POS
                SLASH = INDEX(ORD.INST,'/',1)
                INST.ACCT.DATA = ORD.INST[SLASH+1,CRLF.POS-(SLASH+1)]
                ORD.INST= ORD.INST[CRLF.POS+LEN.CRLF,LEN.ORD.INST]
        END CASE
        IF ACCNT.ID.FLD AND INST.ACCT.DATA THEN
            OFS.DATA := ACCNT.ID.FLD :':1=': QUOTE(INST.ACCT.DATA):','
            DE.I.FIELD.DATA<2> ='"':ACCNT.ID.FLD:'"':CHARX(251):INST.ACCT.DATA

        END
    END

RETURN

**********************************************************************
GET.ORD.INST.DETAILS:
**********************************************************************
* Get Ordering Institution Details like IN.ORDERING.BK, IN.DRAWER.BANK etc. and populate in OFS.DATA
    CONVERT CRLF TO @VM IN ORD.INST
    NO.CRLF = DCOUNT(ORD.INST,@VM)
    FOR C.CRLF = 1 TO NO.CRLF
        FIELD.DATA = ORD.INST<1,C.CRLF>
        FIELD.DATA = QUOTE(FIELD.DATA)
        IF C.CRLF = NO.CRLF THEN
            COMMA.SEP = ''
        END ELSE
            COMMA.SEP = ','
        END
        OFS.DATA :=FIELD.NAME:':':C.CRLF:'=':FIELD.DATA:COMMA.SEP

    NEXT C.CRLF

    DE.I.FIELD.DATA<1> = '"':FIELD.NAME:'"':CHARX(251):ORD.INST

RETURN
**********************************************************************
END
