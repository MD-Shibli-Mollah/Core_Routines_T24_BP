* @ValidationCode : Mjo3NzI0NzgwODg6Q3AxMjUyOjE1NDY0OTI3NTQ2NzI6YWJjaXZhbnVqYTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxODEyLjIwMTgxMTIzLTEzMTk6MjUyOjE1Ng==
* @ValidationInfo : Timestamp         : 03 Jan 2019 10:49:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : abcivanuja
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 156/252 (61.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE SF.Foundation
SUBROUTINE DE.I.TAG59(TAG,BENEFICIARY,OFS.DATA,SPARE1,SPARE2,SPARE3,SPARE4,DE.I.FIELD.DATA,TAG.ERR)
*-----------------------------------------------------------------------------
* <Rating>-154</Rating>
************************************************************************************
**
* This routine assigns SWIFT tag56 - Imtermediary to the ofs message being
* build up via inward delivery
* translate the raw data into OFS format and written away to the ofs directory specified
*
* Inward
*  Tag           -  The swift tag either 59 or 59A or 59F
*  Beneficiary   -  The swift data
*
* Outward
*  OFS.DATA      - The corresponding application field in OFS format
*  DE.I.FIELD.DATA - Field name : TM: field values separated by VM
*  TAG.ERR         - Tag error.
*
************************************************************************************
*
*       MODIFICATIONS
*      ---------------
*
* 24/07/02 - EN_10000786
*            New Program
* 29/10/02 - BG_100002532
*            Change COMPANY to ID.COMPANY
*
* 17/07/03 - CI_10010886
*            In inward processing, FT goes to IHLD state.When there is a
*            second slash in the tag 59, acct no is not stripped properly.
*
*
* 28/01/04 - CI_10016936
*            While mapping the Account field data to OFS.DATA, use the
*            syntax ACCOUNT field name :1= Account field data content
*
* 06/05/04 - EN_10002261
*            SWIFT related changes for bulk credit/debit processing
*
* 07/05/05 - CI_10030002
*            Map tag59 of MT111 to PAYEE Field in EB.MESSAGE.111
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
* 07/07/11 - Task 240725
*            REF:237954
*            BEN.ACCT.DATA value trimmed in order to eliminate spaces
*
* 26/03/11 - Task 631815
*            Tag or value before sending to OFS is quoted so that the message will not
*            be trauncated
*
* 10/07/15 - Enhancement 1309269 / Task 1371288
*            SWIFT 2015 - Payment message changes
*            To populate the TAG 59F data in the OFS Message.
*
* 22/09/15 - Enhancement 1265068/Task 1448651
*          - Routine incorporated
*
* 12/10/15 - Defect 1496245 / Task 1497594
*            SWIFT 2015 - TAG 59F Related Changes
*            Changes related to Tag 59F upated.
*
* 29/10/15 - Defect 1513619 / Task 1515161
*            To populate the OFS Data correctly only when IN.BEN.NAME is passed in
*            Tag 59F.
*
* 28/03/16 - Defect 1629585 / Task 1678212
*            Changes has been done such that the IN.BEN.ADDRESS is populated correctly
*            with the address as passed in Tag 59F.
*
* 01/10/16 - Defect 1830746 / Task 1872343
*            Changes has been done such that the  IN.BEN.COUNTRY and IN.BEN.TOWN is populated correctly
*            with the address as passed in Tag 59F.
*
*09/10/2019 - En_2789881/ Task 2789890
*             New Template for STOP.REQUEST.STATUS as part of introducing functionality for inward MT112
*             (status of request for stop payment). Map Tag 59 of MT112 to PAYEE.ACCOUNT.NO, PAYEE.NAME.ADDRESS and IN.PAYEE in STOP.REQUEST.STATUS.
*
* 2/1/19 - Enhancement 2889117/ Task 2889142
*        - Changes to support CHEQUE.ADVICE
*
************************************************************************************
*
    $USING DE.API
    $USING EB.SystemTables
*
    
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)

    GOSUB INITIALISE
*
    IF B.TAG AND TAG NE '59F' THEN
        GOSUB UPDATE.B.TAG
    END
    
*If TAG 59F is present, then special processing for populating the B.TAG

    IF B.TAG AND TAG EQ '59F' THEN
        GOSUB UPDATE.B.TAG.59F
    END
    
        
    IF TAG.ERR OR B.TAG THEN
        RETURN
    END

*   Populate IN.PAYEE as a copy of Tag 59 for STOP.REQUEST.STATUS
    IF EB.SystemTables.getApplication() MATCHES 'STOP.REQUEST.STATUS':@VM:'CHEQUE.ADVICE' THEN
        TEMP.BENEFICIARY = CONVERT(CRLF,@VM,BENEFICIARY)
        NO.CRLF = DCOUNT(TEMP.BENEFICIARY,@VM)
        COMMA.SEP = ','
        FOR C.CRLF = 1 TO NO.CRLF
            OFS.DATA = OFS.DATA : PAYEE.FIELD : ':':C.CRLF:'=':QUOTE(TEMP.BENEFICIARY<1,C.CRLF>) :COMMA.SEP
        NEXT C.CRLF
        DE.I.FIELD.DATA<3> ='"':PAYEE.FIELD:'"':CHARX(251):TEMP.BENEFICIARY
    END
*   Fetch Payee Account Information From Tag 59
    GOSUB GET.BEN.ACCT.DATA
    IF EB.SystemTables.getApplication() EQ 'EB.MESSAGE.111'  THEN
        BENEFICIARY = SAVE.BENEFICIARY
    END

    BEGIN CASE
        CASE TAG = '59A'
            IF BENEFICIARY THEN
*               CALL DE.SWIFT.BIC(BENEFICIARY,COMPANY,CUSTOMER.NO)
                COMP.ID = EB.SystemTables.getIdCompany()
                DE.API.SwiftBic(BENEFICIARY,COMP.ID,CUSTOMER.NO)
                IF CUSTOMER.NO = '' THEN
                    CUSTOMER.NO = EB.SystemTables.getPrefix():BENEFICIARY
                END
                OFS.DATA := BEN.CUSTOMER :'=': QUOTE(CUSTOMER.NO)
                DE.I.FIELD.DATA<1> ='"':BEN.CUSTOMER:'"':CHARX(251):CUSTOMER.NO
            END
*
        CASE TAG = '59'
            IF BENEFICIARY THEN
                CONVERT CRLF TO @VM IN BENEFICIARY
*
                NO.CRLF = DCOUNT(BENEFICIARY,@VM)
*
                FOR C.CRLF = 1 TO NO.CRLF

                    FIELD.DATA = BENEFICIARY<1,C.CRLF>
                    FIELD.DATA = QUOTE(FIELD.DATA)
                    IF C.CRLF = NO.CRLF THEN
                        COMMA.SEP = ''
                    END ELSE
                        COMMA.SEP = ','
                    END
                    OFS.DATA = OFS.DATA : BEN.CUSTOMER : ':':C.CRLF:'=':FIELD.DATA :COMMA.SEP

                NEXT C.CRLF
                DE.I.FIELD.DATA<1> = '"':BEN.CUSTOMER:'"':CHARX(251):BENEFICIARY
            END
        CASE TAG = '59F'
            IF EB.SystemTables.getApplication() EQ 'CHEQUE.ADVICE' THEN
                GOSUB UPDATE.PAYEE.DETAILS
            END ELSE
                GOSUB UPDATE.BEN.DETAILS
            END
        CASE 1
            TAG.ERR = 'FIELD NOT MAPPED FOR TAG -':TAG

    END CASE
*
    OFS.DATA = TRIM(OFS.DATA,',','T')
RETURN
*
************************************************************************************
UPDATE.B.TAG:
************************************************************************************
    CONVERT CRLF TO @VM IN BENEFICIARY

    NO.CRLF = DCOUNT(BENEFICIARY,@VM)

    FOR C.CRLF = 1 TO NO.CRLF

        FIELD.DATA = BENEFICIARY<1,C.CRLF>
        FIELD.DATA = QUOTE(FIELD.DATA)
        IF C.CRLF = NO.CRLF THEN
            COMMA.SEP = ''
        END ELSE
            COMMA.SEP = ','
        END
        OFS.DATA = OFS.DATA : BEN.CUSTOMER : ':':C.CRLF:'=':FIELD.DATA :COMMA.SEP

    NEXT C.CRLF
    DE.I.FIELD.DATA<1> = '"':BEN.CUSTOMER:'"':CHARX(251):BENEFICIARY
RETURN
    
*
***********************************************************************************
UPDATE.B.TAG.59F:
***********************************************************************************

    CONVERT CRLF TO VM IN BENEFICIARY
    NO.CRLF = DCOUNT(BENEFICIARY,VM)

    FOR C.CRLF = 1 TO NO.CRLF
        FIELD.DATA = BENEFICIARY<1,C.CRLF>
        CRLF.POS = C.CRLF
* Get the local ref field "IN.BEN.NAME.59F" position to check the existence of swift license
        APPLN = 'FUNDS.TRANSFER'
        LOCAL.FIELD = 'IN.BEN.NAME.59F'
        LOCAL.POS = ''
        CALL GET.LOC.REF(APPLN,LOCAL.FIELD,LOCAL.POS)
        IF LOCAL.POS THEN
            GOSUB GET.FIELD.NAME        ;*This is used to get the Field Names for the data that is fetched.
        END
    NEXT C.CRLF
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
    LEN.BENEFICIARY = LEN(BENEFICIARY)
    FIELD.DATA = ''
    TAG.ERR = ''
    DE.I.FIELD.DATA = ''
    BEN.ACCOUNT.FIELD = ''
* Variables initialize for TAG59F
    NAME.COUNT = 0
    ADDR.COUNT = 0
    THREE.SLASH.FLAG = 0
    SAVE.BENEFICIARY = BENEFICIARY
    B.TAG = ''

    IF TAG<2> = 'B' THEN
        B.TAG = 1
        TAG = TAG<1>
    END

    EB.SystemTables.setPrefix('')
*
    BEGIN CASE
*
        CASE EB.SystemTables.getApplication() = 'FUNDS.TRANSFER'
            BEN.CUSTOMER = 'IN.BEN.CUSTOMER'
            IF NOT(B.TAG) THEN
                BEN.ACCOUNT.FIELD = 'IN.BEN.ACCT.NO'
            END
            EB.SystemTables.setPrefix('SW-')
        CASE EB.SystemTables.getApplication() = 'PAYMENT.STOP'
            BEN.CUSTOMER = 'PAYEE'
        CASE EB.SystemTables.getApplication() = 'EB.MESSAGE.111'
            BEN.CUSTOMER = 'PAYEE'
        CASE EB.SystemTables.getApplication() = 'STOP.REQUEST.STATUS'
            BEN.CUSTOMER = 'PAYEE.NAME.ADDRESS'
            BEN.ACCOUNT.FIELD = 'PAYEE.ACCOUNT.NO'
            PAYEE.FIELD = 'IN.PAYEE'
        CASE EB.SystemTables.getApplication() = 'CHEQUE.ADVICE'
            BEN.CUSTOMER = 'PAYEE.NAME.ADDRESS'
            BEN.ACCOUNT.FIELD = 'PAYEE.ACCOUNT.NO'
            PAYEE.FIELD = 'PAYEE'
        CASE 1
*
    END CASE
*
RETURN

********************************************************************
GET.BEN.ACCT.DATA:
********************************************************************
    IF INDEX(BENEFICIARY,'/',1) THEN
        NO.CRLF = DCOUNT(BENEFICIARY,CRLF)
        IF NO.CRLF AND BENEFICIARY[1,1] = '/' THEN
            CRLF.POSITION = INDEX(BENEFICIARY,CRLF,1)
*         XX = INDEX(BENEFICIARY,'/',2)
*         IF NOT(XX) THEN
            XX = INDEX(BENEFICIARY,'/',1)
*         END
            BEN.ACCT.DATA = TRIM(BENEFICIARY[XX+1,CRLF.POSITION-(XX+1)])
            IF BEN.ACCOUNT.FIELD THEN
                OFS.DATA := BEN.ACCOUNT.FIELD :':1=':QUOTE(BEN.ACCT.DATA):','
                DE.I.FIELD.DATA<2> ='"':BEN.ACCOUNT.FIELD:'"':CHARX(251):BEN.ACCT.DATA
            END
            IF NO.CRLF GT 1 THEN
                BENEFICIARY = BENEFICIARY[CRLF.POSITION + LEN.CRLF,LEN.BENEFICIARY]
            END ELSE
                BENEFICIARY = ''
            END
        END
    END
RETURN
*
*-----------------------------------------------------------------------------

*** <region name= GET.FIELD.NAME>
GET.FIELD.NAME:
*** <desc>This is used to get the Field Names for the data that is fetched. </desc>
    
    BEGIN CASE
        CASE FIELD.DATA[1,1] = '/' AND CRLF.POS
            IF BEN.ACCOUNT.FIELD THEN
                OFS.DATA := BEN.ACCOUNT.FIELD :':1=':QUOTE(BEN.ACCT.DATA):','
                DE.I.FIELD.DATA<2> ='"':BEN.ACCOUNT.FIELD:'"':CHARX(251):BEN.ACCT.DATA
            END
        CASE FIELD.DATA[1,2] = '1/' AND CRLF.POS
            NAME.COUNT = NAME.COUNT + 1
            FIELD.NAME  = 'IN.BEN.NAME'
            FIELD.COUNT = NAME.COUNT
            FIELD.DATA.TEMP = FIELD(FIELD.DATA,"/", 2)
            GOSUB POPULATE.OFS.DATA ;*This is to populate the OFS data in the appropriate field
        CASE FIELD.DATA[1,2] = '2/' AND CRLF.POS
            ADDR.COUNT = ADDR.COUNT + 1
            FIELD.NAME  = 'IN.BEN.ADDRESS'
            FIELD.COUNT = ADDR.COUNT
            
* The address field has been populated with an assumption of free text.
* But the address may contain '/' in it. In that case, the correct value has been populated in OFS
            FIELD.DATA.TEMP = FIELD(FIELD.DATA,"2/", 2)
            GOSUB POPULATE.OFS.DATA ;*This is to populate the OFS data in the appropriate field
        CASE FIELD.DATA[1,2] = '3/' AND CRLF.POS
            THREE.SLASH.FLAG = THREE.SLASH.FLAG + 1
            CHK.SLASH.CNT = COUNT(FIELD.DATA, "/")
* If we have just one "/", we need to presume that only the Country is passed. E.g., 3/CN
* Otherwise the message would contain the country and Town. E.g., 3/US/POUGHKEEPSIE, NEW YORK 12602
            IF THREE.SLASH.FLAG EQ '1' THEN ;* Only the first occurence of 3/ will hold the Country and Town or the Country.
                GOSUB CHK.COUNTRY.TOWN ;*This is to check whether the data that is passed in the '3/' field is Country or Town/Additional Info.
            END ELSE
                FIELD.NAME = "IN.BEN.TOWN"
                FIELD.DATA.TEMP = FIELD(FIELD.DATA,"/", 2)
                FIELD.COUNT = THREE.SLASH.FLAG
                GOSUB POPULATE.OFS.DATA ;*This is to populate the OFS data in the appropriate field
            END
    END CASE
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CHK.COUNTRY.TOWN>
CHK.COUNTRY.TOWN:
*** <desc>This is to check whether the data that is passed in the '3/' field is Country or Town/Additional Info. </desc>
    FIELD.DATA.LOCAL = FIELD.DATA

    FOR CHK.VAL.CNT = 1 TO CHK.SLASH.CNT
        IF CHK.VAL.CNT = 1 THEN
            FIELD.NAME = "IN.BEN.COUNTRY"
            FIELD.DATA.TEMP = FIELD(FIELD.DATA,"/", CHK.VAL.CNT+1)
        END ELSE
            FIELD.NAME = "IN.BEN.TOWN"
            FIELD.DATA.TEMP = GROUP(FIELD.DATA,"/",3,CHK.SLASH.CNT)
            CHK.VAL.CNT = CHK.VAL.CNT +1
        END
        FIELD.COUNT = 1
        IF FIELD.DATA.TEMP NE '' THEN
            GOSUB POPULATE.OFS.DATA ;*This is to populate the OFS data in the appropriate field
            FIELD.DATA = FIELD.DATA.LOCAL
        END
    NEXT CHK.VAL.CNT

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= POPULATE.OFS.DATA>
POPULATE.OFS.DATA:
*** <desc>This is to populate the OFS data in the appropriate field </desc>

    FIELD.DATA = QUOTE(FIELD.DATA.TEMP)
    
* Normally comma seperator would be holding ",", but when it is the last line it would hold
* a different value based on the conditions checked below
    COMMA.SEP = ','
    
    IF (C.CRLF = NO.CRLF) THEN
* This is for the case when it is the last line and the BEN.COUNTRY is only present.
        IF (FIELD.NAME = "IN.BEN.COUNTRY" AND CHK.SLASH.CNT = 1) THEN
            COMMA.SEP = ''
        END
* BEN ADDRESS is not checked as the Country should be specified if address is specified.
        IF FIELD.NAME = "IN.BEN.TOWN" OR FIELD.NAME = "IN.BEN.NAME" THEN
            COMMA.SEP = ''
        END
    END

    OFS.DATA = OFS.DATA : FIELD.NAME : ':':FIELD.COUNT:'=':FIELD.DATA :COMMA.SEP

    GOSUB POPULATE.DE.FLD.DATA ;*This is to populate the DE.I.FIELD.DATA

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= POPULATE.DE.FLD.DATA>
POPULATE.DE.FLD.DATA:
*** <desc>This is to populate the DE.I.FIELD.DATA </desc>

    BEGIN CASE

        CASE FIELD.NAME EQ "IN.BEN.NAME"  AND NAME.COUNT = 1
            DE.I.FIELD.DATA<-1> = '"':FIELD.NAME:'"':CHARX(251):FIELD.DATA.TEMP

        CASE FIELD.NAME EQ "IN.BEN.NAME"  AND NAME.COUNT GT 1
            DE.I.FIELD.DATA:=@VM:FIELD.DATA.TEMP

        CASE FIELD.NAME EQ "IN.BEN.ADDRESS" AND ADDR.COUNT = 1
            DE.I.FIELD.DATA<-1> = '"':FIELD.NAME:'"':CHARX(251):FIELD.DATA.TEMP

        CASE FIELD.NAME EQ "IN.BEN.ADDRESS" AND ADDR.COUNT GT 1
            DE.I.FIELD.DATA:=@VM:FIELD.DATA.TEMP

        CASE FIELD.NAME EQ "IN.BEN.COUNTRY"
            DE.I.FIELD.DATA<-1> = '"':FIELD.NAME:'"':CHARX(251):FIELD.DATA.TEMP

        CASE FIELD.NAME EQ "IN.BEN.TOWN" AND THREE.SLASH.FLAG = 1
            DE.I.FIELD.DATA<-1> = '"':FIELD.NAME:'"':CHARX(251):FIELD.DATA.TEMP

        CASE FIELD.NAME EQ "IN.BEN.TOWN" AND THREE.SLASH.FLAG GT 1
            DE.I.FIELD.DATA:=@VM:FIELD.DATA.TEMP
                
    END CASE

RETURN
*** </region>
UPDATE.BEN.DETAILS:
    IF BENEFICIARY THEN
        CONVERT CRLF TO @VM IN BENEFICIARY
        NO.CRLF = DCOUNT(BENEFICIARY,@VM)

        FOR C.CRLF = 1 TO NO.CRLF
            FIELD.DATA = BENEFICIARY<1,C.CRLF>
            CRLF.POS = C.CRLF
            GOSUB GET.FIELD.NAME ;*This is used to get the Field Names for the data that is fetched.
        NEXT C.CRLF
    END
RETURN
UPDATE.PAYEE.DETAILS:

    IF BENEFICIARY THEN
        TEMP.BENEFICIARY = CONVERT(CRLF,@VM,BENEFICIARY)
        NO.CRLF = DCOUNT(TEMP.BENEFICIARY,@VM)
        COMMA.SEP = ','
        MV.POS = ''
        FOR C.CRLF = 1 TO NO.CRLF
            IF NOT(TEMP.BENEFICIARY<1,C.CRLF>[1,1] = '/' AND CRLF.POS AND BEN.ACCT.DATA NE '' AND C.CRLF EQ 1) THEN
                MV.POS += 1
                OFS.DATA = OFS.DATA : BEN.CUSTOMER : ':':MV.POS:'=':QUOTE(TEMP.BENEFICIARY<1,C.CRLF>[3,35]) :COMMA.SEP
            END
        NEXT C.CRLF
    END
    
RETURN
END

