* @ValidationCode : MjotMjA0NDI1ODE3ODpjcDEyNTI6MTYxODQ3NzI1Njg5MDprcmFtYXNocmk6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 15 Apr 2021 14:30:56
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE QI.CustomerIdentification
SUBROUTINE QI.PERFORM.CUST.PREF.CHECK(DE.CUST.PREF.ID, MESSAGE.GROUP, CARRIER, TAX.RESIDENCE, US.ADDR.CONFLICT, COUNTRY.FIELD.DETS, RES.OUT2, RES.OUT3)
*-----------------------------------------------------------------------------
* Sample API to perform checks in DE.CUSTOMER.PREFERENCES for Address Conflict
* Arguments:
*------------
* DE.CUST.PREF.ID            (IN)    - DE Customer preferences ID
*                                      In case of Account Preference, DE.CUST.PREF.ID<2> = CustomerID
*
* MESSAGE.GROUP              (IN)    - Message groups to be excluded for Address Conflict check
*
* CARRIER                    (IN)    - Carrier to be checked for Address
*
* TAX.RESIDENCE              (IN)    - Customer's tax residence
*
* US.ADDR.CONFLICT           (OUT)   - YES/NO, US Address Conflict Result
*
* COUNTRY.FIELD.DETS         (IN)    - <1> Field to check for PRINT.1 address
*                                      <2> Field to check for other addresses
*
* RES.OUT2,RES.OUT3          (OUT)   - Outgoing Reserved Arguments
*-----------------------------------------------------------------------------
* Modification History :
*
* 01/12/20 - SI 3436249 / Task 4104932
*            Sample API to check for Address Conflict in DE.CUSTOMER.PREFERENCES
*
* 10/01/21 - SI 3436249 / Task 4159602
*            Check COUNTRY field in DE Address instead of COUNTRY.CODE
*
* 10/03/21 - Defect 4275520 / Task 4276266
*            Changes done to consider Portfolio level and Other Customer Preferences
*
* 15/04/21 - Defect 4325660 / Task 4338966
*            Changes done to avoid fatal error in TAFC
*-----------------------------------------------------------------------------
    $USING QI.CustomerIdentification
    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $USING EB.API
    $USING EB.DataAccess
    $USING EB.LocalReferences
    $USING ST.Config
    $USING ST.CustomerService
    $USING PF.Config
    $USING PY.Config
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
    US.ADDR.CONFLICT = 'NO'
    DE.ADDRESS.ID = ''
    FIELD.LIST = ''
    
    CUST.COMP = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany)
    
* Get the customer Id from the input details
    CUSTOMER.ID = ''
    IF INDEX(DE.CUST.PREF.ID,'-',1) THEN    ;* either Account/portfolio preference
        CUSTOMER.ID = DE.CUST.PREF.ID<2>
        DE.CUST.PREF.ID = DE.CUST.PREF.ID<1>
    END ELSE
        CUSTOMER.ID = DE.CUST.PREF.ID
    END

* Get local field position
    SS.REC = ''
    EB.API.GetStandardSelectionDets('DE.ADDRESS', SS.REC)
    LOCATE 'LOCAL.REF' IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING LOC.POS THEN
        LOCAL.FIELD.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo,LOC.POS>
    END
    
    FIELD.NAME = 'BIL.WRONG.ADDR'
    BIL.WRONG.ADDR.POS = ''
    EB.LocalReferences.GetLocRef('DE.ADDRESS', FIELD.NAME, BIL.WRONG.ADDR.POS)

* Find if message group list is for inclusion/exclusion
    FIRST.MESSAGE.GRP = MESSAGE.GROUP<1>
    MESSAGE.GRP.LIST = MESSAGE.GROUP
    MESSAGE.GRP.LIST<1> = FIELD(MESSAGE.GRP.LIST<1>,'/',2)    ;* remove I/ or E/

RETURN
*-----------------------------------------------------------------------------
PROCESS:
    
* DE.CUST.PREFERENCES.CONCAT Id possibilities:
* C-CustId*OWN, C-CustId*OtherCustId*OTHER
* A-AcctId*OWN, A-AcctId*OtherCustId*OTHER
* P-PortId*OWN, P-PortId*OtherCustId*OTHER

* Form Selection command
    IF INDEX(DE.CUST.PREF.ID,'-',1) THEN    ;* in case of Acct/portfolio, no need to append A/P
        SEL.CMD = 'SELECT F.DE.CUST.PREFERENCES.CONCAT WITH @ID LIKE ':DE.CUST.PREF.ID:'...'
    END ELSE
        SEL.CMD = 'SELECT F.DE.CUST.PREFERENCES.CONCAT WITH @ID LIKE C-':DE.CUST.PREF.ID:'...'
    END

* Get the concat list in which the customer/Account/Portfolio is part of
    KEY.LIST = ''
    KEY.CNT = ''
    EB.DataAccess.Readlist(SEL.CMD, KEY.LIST, '', KEY.CNT, '')
    
    OWN.FLAG = @FALSE
    FOR DCP = 1 TO KEY.CNT
        CONCAT.ID = KEY.LIST<DCP>
        IF FIELD(CONCAT.ID,'*',2) EQ 'OWN' THEN     ;* set flag to indicate that OWN preference has id in concat file
            OWN.FLAG = @TRUE
        END
        EB.DataAccess.CacheRead('F.DE.CUST.PREFERENCES.CONCAT', CONCAT.ID, DCP.ID, '')
        IF DCP.ID THEN
            GOSUB PROCESS.DCP
        END
    NEXT DCP

* If there are no records in concat or OWN preference DCP id is not found, process A-AcctID/CustomerId DCP is present
    IF NOT(KEY.LIST) OR NOT(OWN.FLAG) THEN
        DCP.ID = DE.CUST.PREF.ID
        GOSUB PROCESS.DCP
    END
        
RETURN
*-----------------------------------------------------------------------------
PROCESS.DCP:
    
* Get Carrier & Address from Customer preferences
    PROPERTY = ''
    DATA.FIELD.LIST = ''
    PROPERTY<1,ST.CustomerService.CustomerPrefProperty.fieldName> = 'MESSAGE.GROUP'
    PROPERTY<2,ST.CustomerService.CustomerPrefProperty.fieldName> = 'CARRIER'
    PROPERTY<3,ST.CustomerService.CustomerPrefProperty.fieldName> = 'ADDRESS'
    PROPERTY<4,ST.CustomerService.CustomerPrefProperty.fieldName> = 'REQUIRED'
    PROPERTY<5,ST.CustomerService.CustomerPrefProperty.fieldName> = 'PREFERENCE.TYPE'
    PROPERTY<6,ST.CustomerService.CustomerPrefProperty.fieldName> = 'OTHER.RECIPIENT.REFERENCE'
    ST.CustomerService.getCustomerPreferenceProperties(DCP.ID, PROPERTY, DATA.FIELD.LIST)
    
    MESSAGE.GRPS = DATA.FIELD.LIST<1>
    GRP.CNT = 1
    TOT.GRP.CNT = DCOUNT(MESSAGE.GRPS,@VM)
    
    LOOP
    UNTIL GRP.CNT GT TOT.GRP.CNT
        
        PROCESS.FLAG = @FALSE
        IF FIRST.MESSAGE.GRP[1,1] EQ 'E' THEN   ;* means exclusion list
            LOCATE MESSAGE.GRPS<1,GRP.CNT> IN MESSAGE.GRP.LIST SETTING MSG.POS ELSE    ;* if message group donot match with the excluding list of message grps, process further
                PROCESS.FLAG = @TRUE
            END
        END ELSE        ;* I - means inclusion list
            LOCATE MESSAGE.GRPS<1,GRP.CNT> IN MESSAGE.GRP.LIST SETTING MSG.POS THEN    ;* if message group matches with the including list of message grps, process further
                PROCESS.FLAG = @TRUE
            END
        END
        
        IF PROCESS.FLAG THEN
            DE.CARRIERS = DATA.FIELD.LIST<2,GRP.CNT>
            ADDRESS.NUM = DATA.FIELD.LIST<3,GRP.CNT>
            REQD = DATA.FIELD.LIST<4,GRP.CNT>
            GOSUB PROCESS.EACH.CARRIER
        END
            
        GRP.CNT = GRP.CNT + 1
        
        IF US.ADDR.CONFLICT NE 'NO' THEN    ;* terminate the loop when conflict found
            GRP.CNT = TOT.GRP.CNT + 1
        END
    REPEAT
    
RETURN
*-----------------------------------------------------------------------------
PROCESS.EACH.CARRIER:
    
* Loop through each carrier
    ADDRESS.LIST = ''
    TOT.CARR.CNT = DCOUNT(DE.CARRIERS,@SM)
    FOR CNT=1 TO TOT.CARR.CNT
        CURR.CARRIER = DE.CARRIERS<1,1,CNT>   ;*  Carrier (PRINT)
        CURR.ADDR = ADDRESS.NUM<1,1,CNT>      ;*  Address (1)
        CURR.REQD = REQD<1,1,CNT>
        IF CURR.REQD EQ 'YES' THEN  ;* check only when Required is YES
            FINDSTR CURR.CARRIER IN CARRIER SETTING CAR.POS THEN   ;* perform check only when it is equal to the incoming carrier (PRINT)
                GOSUB CHECK.DE.ADDRESS
            END
        END
    NEXT CNT

RETURN
*-----------------------------------------------------------------------------
CHECK.DE.ADDRESS:

* In case of HOLDMAIL, local country will be found along with the carrier (HOLDMAIL/LU)
    IF INDEX(CARRIER<CAR.POS>,'/',1) THEN
        LOCAL.CTRY = FIELD(CARRIER<CAR.POS>,'/',2)
        IF TAX.RESIDENCE NE LOCAL.CTRY THEN     ;* there is conflict if tax residence is not local ctry
            US.ADDR.CONFLICT = 'YES*Conflict due to Mailing Preferences : ':DE.CUST.PREF.ID
            CNT = TOT.CARR.CNT + 1      ;* to terminate loop
        END
    END

    IF US.ADDR.CONFLICT NE 'NO' THEN
        RETURN
    END
    
* Store all checked Addresses in a list to avoid checking it again
    ADDR.ID = CURR.CARRIER:'.':CURR.ADDR
    LOCATE ADDR.ID IN ADDRESS.LIST SETTING POS THEN
        RETURN
    END
    ADDRESS.LIST<-1> = ADDR.ID

* Get the processing customer based on OWN/OTHER preference type
    PROCESS.CUST = ''
    IF DATA.FIELD.LIST<5> EQ 'OTHER' THEN
        PROCESS.CUST = DATA.FIELD.LIST<6>
    END ELSE
        PROCESS.CUST = CUSTOMER.ID
    END
    
    COUNTRY.CODE = ''
    IF ADDR.ID EQ 'PRINT.1' THEN    ;* in case of PRINT.1
        IF FIELD(COUNTRY.FIELD.DETS<1>,'>',1) NE 'DE.ADDRESS' THEN  ;* if appln is not DE.ADDRESS, read the corresponding rec and get the country value
            FIELD.APPL = FIELD(COUNTRY.FIELD.DETS<1>,'>',1)
            FIELD.NAME = FIELD(COUNTRY.FIELD.DETS<1>,'>',2)
            GOSUB READ.RECORD
            GOSUB GET.FIELD.VALUE
            COUNTRY.CODE = FIELD.VALUE
        END ELSE    ;* else get the DE.ADDRESS field in which country is to fetched
            COUNTRY.FIELD = FIELD(COUNTRY.FIELD.DETS<1>,'>',2)
        END
    END ELSE    ;* else get the DE.ADDRESS field in which country is to fetched
        COUNTRY.FIELD = FIELD(COUNTRY.FIELD.DETS<2>,'>',2)
    END

* If country code is not obtained, read DE.ADDRESS and get value from the country field
    IF NOT(COUNTRY.CODE) THEN
        DE.ADDRESS.ID = CUST.COMP: '.C-':PROCESS.CUST:'.':CURR.CARRIER:'.':CURR.ADDR    ;* Fetch DE.ADDRESS record details
        R.DE.ADDRESS = ''
        YERR = ''
        R.DE.ADDRESS = PY.Config.Address.CacheRead(DE.ADDRESS.ID, YERR)
        
        FIELD.APPL = 'DE.ADDRESS'
        FIELD.NAME = COUNTRY.FIELD
        R.REC = R.DE.ADDRESS
        GOSUB GET.FIELD.VALUE
        COUNTRY.CODE = FIELD.VALUE
    END

* Get fiscal jurisdiction country
    GOSUB GET.FISCAL.JUR
    ADDRESS.CTRY = FISCAL.JUR
            
    BEGIN CASE
        CASE ADDRESS.CTRY AND (ADDRESS.CTRY NE TAX.RESIDENCE)       ;* Country code check
            US.ADDR.CONFLICT = 'YES*Conflict due to Mailing Preferences : ':DCP.ID:' ,Address :':CURR.CARRIER:'.':CURR.ADDR
            CNT = TOT.CARR.CNT + 1      ;* to terminate loop
        CASE BIL.WRONG.ADDR.POS AND (R.DE.ADDRESS<LOCAL.FIELD.POS,BIL.WRONG.ADDR.POS>[1,1] EQ 'Y')   ;* BIL Wrong Addr check
            US.ADDR.CONFLICT = 'YES*Conflict due to Mailing Preferences : ':DCP.ID:' ,Address :':CURR.CARRIER:'.':CURR.ADDR
            CNT = TOT.CARR.CNT + 1      ;* to terminate loop
    END CASE

RETURN
*-----------------------------------------------------------------------------
GET.FISCAL.JUR:

* Call the API to get fiscal jurisdiction of the country
    FISCAL.JUR = ''
    IF COUNTRY.CODE THEN
        ST.Config.StGetFiscalJurisdiction(COUNTRY.CODE, FISCAL.JUR, '', '')
    END

RETURN
*-----------------------------------------------------------------------------
READ.RECORD:

* Read the application record using processing customer id (considering CUSTOMER)
    FN.FILE.NAME = 'F.':FIELD.APPL
    FV.FILE.NAME = ''
    R.REC = ''
    READ.ER = ''
    EB.DataAccess.FRead(FN.FILE.NAME, PROCESS.CUST, R.REC, FV.FILE.NAME, READ.ER)
        
RETURN
*-----------------------------------------------------------------------------
GET.FIELD.VALUE:
    
    FIELD.VALUE = ''
    SS.REC = ''
    EB.API.GetStandardSelectionDets(FIELD.APPL, SS.REC)  ;* read SS Record for the application
    
    ER = ''
    FLD.NO = ''
    LOC.REF.POS = ''
    EB.API.FieldNamesToNumbers(FIELD.NAME, SS.REC, FLD.NO, '', '', '', '', ER)  ;* get the field position
    IF FLD.NO EQ '' THEN     ;* If field position is null, check for local field
        EB.LocalReferences.GetLocRef(FIELD.APPL, FIELD.NAME, FLD.NO)     ;* get local field position
        LOCATE 'LOCAL.REF' IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING POS THEN      ;* get local reference field position of the application
            LOC.REF.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo,POS>
        END
        FIELD.VALUE = R.REC<LOC.REF.POS,FLD.NO>   ;* get local field value
    END ELSE
        FIELD.VALUE = R.REC<FLD.NO>   ;* get the field value
    END

RETURN
*-----------------------------------------------------------------------------
END



