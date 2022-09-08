* @ValidationCode : Mjo3MzAxMDUzNTU6Y3AxMjUyOjE2MDk3NTg4Mzg0MDU6a3JhbWFzaHJpOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMC4yMDIwMDkyOS0xMjEwOi0xOi0x
* @ValidationInfo : Timestamp         : 04 Jan 2021 16:43:58
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200929-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE RT.BalanceAggregation
SUBROUTINE RT.GET.TELEPHONE.INDICIA(CUSTOMER.ID, REGULATION, CUST.SUPP.REC, RES.IN.2, RESULT, RES.OUT.1, RES.OUT.2, RES.OUT.3)
*-----------------------------------------------------------------------------
* Sample API to check telephone indicia for a customer
* Arguments:
*------------
* CUSTOMER.ID                (IN)    - Customer ID for which indicia is to be calculated
*
* REGULATION                 (IN)    - CRS/FATCA, for which regulation indicia is to be checked
*
* CUST.SUPP.REC              (IN)    - CCSI record to map telephone numbers
*
* RES.IN2                    (IN)    - Incoming Reserved Arguments
*
* RESULT                     (OUT)   - Jurisdiction if indicia is met
*                                    - Mapped CCSI record
*
* RES.OUT1,RES.OUT2,RES.OUT3 (OUT)   - Outgoing Reserved Arguments
*-----------------------------------------------------------------------------
* Modification History :
*
* 14/09/2020    - Enhancement 3972430 / Task 3972443
* 				  Sample API to check telephone indicia for a customer
*
* 02/11/2020	- Enhancement 3436134 / Task 4059536
*            	  Considering fiscal jurisdiction for indicia calculation
*
* 08/12/2020    - Task 4120825
*                 Telephone numbers defined in customer should be mapped in CCSI
*				  only when its contact type matches the one in parameter
*
* 14/12/2020    - Enhancement 3436134 / Task 4131566
*                 To avoid 'EB.RTN.NO.DELETION.LAST.MULTI.FLD', append NULL instead of
*                 '-' during deletion of mv set
*-----------------------------------------------------------------------------
    $USING RT.BalanceAggregation
    $USING EB.SystemTables
    $USING CD.Config
    $USING ST.Config
    $USING ST.CustomerService
    $USING ST.Customer
    $USING FA.Config
    $USING EB.API
    $USING CD.CustomerIdentification
    $USING ST.CompanyCreation
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    BEGIN CASE
        CASE CUST.SUPP.REC AND CRS.CHECK
            GOSUB MAP.TELE.NOS
        CASE NOT(CUST.SUPP.REC) AND (CRS.CHECK OR FATCA.CHECK)
            GOSUB INDICIA.PROCESS
    END CASE
    
RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
* Check if indicia is to be calculated for CRS or FATCA
    CRS.CHECK = ''
    FATCA.CHECK = ''
    
    BEGIN CASE
        CASE REGULATION EQ 'CRS'
            CRS.CHECK = 1
        CASE REGULATION EQ 'FATCA'
            FATCA.CHECK = 1
    END CASE
    
    RESULT = ''    ;* reset the argument
    TELE.CTRY = ''
    R.CUS = ''
    PAR.ERR = ''
    R.PARAM = ''
    REP.JUR.LIST = ''
    PARAM.TYPE = ''
    
    ID.COMP = EB.SystemTables.getIdCompany()
    
    ST.CustomerService.getRecord(CUSTOMER.ID, R.CUS)
    CONTACT.TYPE = RAISE(R.CUS<ST.Customer.Customer.EbCusContactType>)
    IDD.PREFIX = RAISE(R.CUS<ST.Customer.Customer.EbCusIddPrefixPhone>)
    CONTACT.DATA = RAISE(R.CUS<ST.Customer.Customer.EbCusContactData>)
    
    GOSUB GET.LOCAL.COUNTRY
    
RETURN
*-----------------------------------------------------------------------------
INDICIA.PROCESS:
    
* Return if any one of the prefix is local ctry's prefix
    LOCATE LOCAL.PREFIX IN IDD.PREFIX SETTING LOC.POS THEN
        RETURN
    END
    
    GOSUB GET.PARAM.DETS

* Loop through each telephone prefix and check based on CRS/FATCA
    TOT.CNT = DCOUNT(IDD.PREFIX,@FM)
    FOR CNT = 1 TO TOT.CNT
        CHECK.CTRY = ''
        IF CONTACT.TYPE<CNT> EQ PARAM.TYPE THEN
            ERR.INFO = ''
            ST.Config.StGetCountryFromPhoneNo(IDD.PREFIX<CNT>, CONTACT.DATA<CNT>, CHECK.CTRY, ERR.INFO, '', '')      ;* call the api and get the ctry corresponding to the telephone
            IF ERR.INFO OR NOT(CHECK.CTRY) THEN    ;* If multiple countries are returned or no country returned from the API, check with the prefix
                CURR.PREFIX = IDD.PREFIX<CNT>
                GOSUB CHECK.PREFIX
            END ELSE
                GOSUB CHECK.INDICIA
            END
        END
    NEXT CNT
    
* Append the jurisdictions met in the final output argument
    IF TELE.CTRY THEN
        RESULT = LOWER(TELE.CTRY)
    END
    
RETURN
*-----------------------------------------------------------------------------
GET.PARAM.DETS:
    
* Get reportable jurisdictions list from CRS parameter
    BEGIN CASE
        CASE CRS.CHECK
            R.PARAM = CD.Config.CrsParameter.CacheRead(ID.COMP, PAR.ERR)
            REP.JUR.LIST = R.PARAM<CD.Config.CrsParameter.CdCpPartngJuridiction> ;* reporting jurisdictions
            TELE.PREFIX.LIST = R.PARAM<CD.Config.CrsParameter.CdCpTelephoneCode>
            PARAM.TYPE = R.PARAM<CD.Config.CrsParameter.CdCpTeleContType>
        CASE FATCA.CHECK
            R.PARAM = FA.Config.FatcaParameter.CacheRead(ID.COMP, PAR.ERR)
            PARAM.TYPE = R.PARAM<FA.Config.FatcaParameter.FpTeleContType>
            
            US.REC = ''
            US.ERR = ''
            US.REC = ST.Config.Country.CacheRead('US', US.ERR)
            US.TELE.PREFIX = US.REC<ST.Config.Country.EbCouIddPrefixPhone>      ;* get US telephone prefix (for existing method)
    END CASE
    
RETURN
*-----------------------------------------------------------------------------
CHECK.INDICIA:

* If there is a valid country, get its fiscal jurisdiction
    FISCAL.JUR = ''
    ST.Config.StGetFiscalJurisdiction(CHECK.CTRY, FISCAL.JUR, '', '')
        
    BEGIN CASE
        CASE CRS.CHECK
            LOCATE FISCAL.JUR IN REP.JUR.LIST<1,1> SETTING JUR.POS THEN
                GOSUB UPDATE.JURISDICTION.LIST
            END
        CASE FATCA.CHECK
            IF FISCAL.JUR EQ 'US' THEN
                GOSUB UPDATE.JURISDICTION.LIST
            END
    END CASE
    
RETURN
*-----------------------------------------------------------------------------
UPDATE.JURISDICTION.LIST:
    
* Add the jurisdiction to the list only if it is not present already (to avoid duplicates)
    JUR.POS = ''
    LOCATE CHECK.CTRY IN TELE.CTRY SETTING JUR.POS ELSE
        TELE.CTRY<-1> = CHECK.CTRY    ;* store all the tele jurisdictions in a local array
    END
 
RETURN
*-----------------------------------------------------------------------------
CHECK.PREFIX:
    
    BEGIN CASE
        CASE CRS.CHECK      ;* check if prefix is equal to any rep jurisdisction's prefix
            LOCATE CURR.PREFIX IN TELE.PREFIX.LIST<1,1> SETTING TELE.POS THEN
                LOCATE CURR.PREFIX IN TELE.CTRY SETTING JUR.POS ELSE
                    TELE.CTRY<-1> = REP.JUR.LIST<1,TELE.POS>    ;* store all the tele jurisdictions in a local array
                END
            END
        CASE FATCA.CHECK    ;* check if prefix is equal to US country prefix
            IF CURR.PREFIX EQ US.TELE.PREFIX THEN
                TELE.CTRY = 'US'
                CNT = TOT.CNT+1
            END
    END CASE

RETURN
*-----------------------------------------------------------------------------
MAP.TELE.NOS:
    
    GOSUB GET.PARAM.DETS
    
* Loop through each telephone prefix and update tele nos.
    TELE.NUM = ''
    TELE.CTRY = ''
    TOT.CNT = DCOUNT(IDD.PREFIX,@FM)
    FOR CNT = 1 TO TOT.CNT
        IF CONTACT.TYPE<CNT> EQ PARAM.TYPE THEN     ;* map only when contact type is defined in parameter
            CHECK.CTRY = ''
            CURR.PREFIX = IDD.PREFIX<CNT>
            ERR.INFO = ''
            ST.Config.StGetCountryFromPhoneNo(CURR.PREFIX, CONTACT.DATA<CNT>, CHECK.CTRY, ERR.INFO, '', '')
            IF ERR.INFO OR NOT(CHECK.CTRY) THEN    ;* if multiple countries or no country returned from the api
                GOSUB GET.CTRY.FROM.PREFIX
            END ELSE
                GOSUB UPDATE.TEL.DETS
            END
        END
    NEXT CNT

* Append - to remove the extra telephone numbers that are present in CCSI ( when prev telephone dets are now removed in customer)
    CNT = DCOUNT(TELE.NUM,@FM) + 1      ;* count of tele numbers updated
    
    EXISTING.TEL = CUST.SUPP.REC<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTelephoneNo>     ;* existing tele numbers in CCSI
    TOT.EXIST.CNT = DCOUNT(EXISTING.TEL,@VM)
    FOR EXIST.CNT = CNT TO TOT.EXIST.CNT    ;* remove remaining tele numbers
        TELE.NUM<EXIST.CNT> = '-'
    NEXT EXIST.CNT
    
    IF TELE.NUM EQ '-' THEN     ;* when only one mv set is to be removed, append NULL
        TELE.NUM = 'NULL'
        TELE.CTRY = 'NULL'
    END
    
    CUST.SUPP.REC<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTelephoneNo> = LOWER(TELE.NUM)
    CUST.SUPP.REC<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTelephoneCountry> = LOWER(TELE.CTRY)
    
    RESULT = CUST.SUPP.REC
    
RETURN
*-----------------------------------------------------------------------------
GET.CTRY.FROM.PREFIX:
    
    LOCATE CURR.PREFIX IN TELE.PREFIX.LIST<1,1> SETTING TEL.POS THEN
        CHECK.CTRY = REP.JUR.LIST<1,TEL.POS>
        GOSUB UPDATE.TEL.DETS
    END
        
RETURN
*-----------------------------------------------------------------------------
UPDATE.TEL.DETS:
    
    CONTACT.DATA<CNT> = TRIM(CONTACT.DATA<CNT>,'','A')
    TELE.NUM<-1> = CURR.PREFIX:'-':CONTACT.DATA<CNT>
    TELE.CTRY<-1> = CHECK.CTRY

RETURN
*-----------------------------------------------------------------------------
GET.LOCAL.COUNTRY:

* Local company is fetched from company book field, if not present fetch it from CoCode field of the customer
    LOCAL.COMP = ''
    IF R.CUS<ST.Customer.Customer.EbCusCompanyBook> THEN
        LOCAL.COMP = R.CUS<ST.Customer.Customer.EbCusCompanyBook>
    END ELSE
        LOCAL.COMP = R.CUS<ST.Customer.Customer.EbCusCoCode>
    END
    
    LOCAL.CTRY = ''
* If current company is not the local company, read the local company record and get the local country
    IF LOCAL.COMP EQ ID.COMP THEN
        IF EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry) THEN
            LOCAL.CTRY = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry)
        END ELSE
            LOCAL.CTRY = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalRegion)[1,2]
        END
    END ELSE
        COMP.ERR = ''
        R.COMP = ST.CompanyCreation.Company.CacheRead(LOCAL.COMP, COMP.ERR)
        IF R.COMP<ST.CompanyCreation.Company.EbComLocalCountry> THEN
            LOCAL.CTRY = R.COMP<ST.CompanyCreation.Company.EbComLocalCountry>
        END ELSE
            LOCAL.CTRY = R.COMP<ST.CompanyCreation.Company.EbComLocalRegion>[1,2]
        END
    END

* Get local country's prefix
    LOC.ERR = ''
    R.LOC.CTRY = ''
    R.LOC.CTRY = ST.Config.Country.CacheRead(LOCAL.CTRY, LOC.ERR)
    LOCAL.PREFIX = R.LOC.CTRY<ST.Config.Country.EbCouIddPrefixPhone>
    
RETURN
*-----------------------------------------------------------------------------
END

