* @ValidationCode : MjotOTYyMjU2NjYwOmNwMTI1MjoxNjEyODQ1ODU3NDMyOmtyYW1hc2hyaToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAxLjE6MTc1OjE0MQ==
* @ValidationInfo : Timestamp         : 09 Feb 2021 10:14:17
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 141/175 (80.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202101.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-156</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CD.CustomerIdentification
SUBROUTINE CRS.GET.INDICIA.SAMPLE(CUSTOMER.ID,CRS.PARAM.INFO,R.CRS.CUST.SUPP.INFO,CUSTOMER.INFO,CHNG.DATE,INDICIA.STRENGTH,REPORTING.JURISDICTIONS,CRS.STATUS,CRS.WAIVE)
*------------------------------------------------------------------------
*** <region name= PROGRAM DESCRIPTION>
*------------------------------------------------------------------------
* Application Interface routine to calculate the INDICIA required or not.
* This routine is attached in INDICIA.CALC.RTN field of CRS.PARAMETER.
* Also calculates the reporting jurisdictions and crs status.
* EB.API record is required for this routine.
*
* @author trinadh@temenos.com
* @stereotype H - CRS.CUST.SUPP.INFO
* @package CD - CD_CustomerIdentification
* Input Parameters:
*==================
*   CUSTOMER.ID                  - Customer Id specified in CRS.CUSTOMER.SUPPLEMENTARY.INFO
*   R.CRS.CUST.SUPP.INFO         - CRS.CUSTOMER.SUPPLEMENTARY.INFO Record
*   CRS.PARAM.INFO               - Array variable to hold the details of CRS.PARAMETER record
*                                  <1> - Holds all the participations jurisdictions
*   CUSTOMER.INFO                - Array variable to hold the details of the customer.
*                                  <1> - Holds YES/NO to identify whether the customer is new.
*   RESARG                       - Reserved for future use
*
* Output Parameters:
*===================
*   INDICIA.STRENGTH            - Returns value YES/NO
*   REPORTING.JURISDICTIONS     - List of Reporting Jurisdiction countries.
*   CRS.STATUS                  - Final CRS Status.
*   RETURN.MSG                  - Errors, if any.
*
*** </region>
*------------------------------------------------------------------------

*** <region name= MODIFICATION HISTORY>
*** <desc>Modification History</desc>
*------------------------------------------------------------------------
* Modification History :
* 29/11/18 - Defect 2854794: task 2878239
*            CRS Reporting - Passive Entity with Controlling person where Tax residense of the controlling person
*            falls under the participating Jurisdiction list.
*
* 06/11/20 - Enh 4010639 /Task 4067240
*            To include the Country of Incorporation when calculating CRS Indicia for customers
*            identified as legal entities
*
* 09/02/21 - Task 4220464
*            Telephone indicia should not be met if any of the telephone countries
*            is a local jurisdiction
*------------------------------------------------------------------------
*** </region>
*** <region name= INSERTS>
*** <desc>Inserts</desc>

    $USING EB.SystemTables
    $USING CD.CustomerIdentification
    $USING ST.Customer
    $USING ST.CustomerService
    $USING ST.CompanyCreation

*** </region>
*------------------------------------------------------------------------
*** <region name= MAIN PROCESS LOGIC>
*** <desc>Main process logic</desc>

    
    GOSUB INITIALISE
* When the user update the crs status as Inactive,then no need to calculate the reporting juristictions.
* Since Inactive customer not supported for parting jurisdiction,INACTIVE status should be in First position.
* Reporting juristiction will be calculated based on the parting juristcition countries.
    GOSUB RESIDENCE.ADDRESS.CHECK
    GOSUB ELECTRONIC.RECORD.SEARCH
    
    IF NEW.CUSTOMER EQ 'NO' THEN
* Update Indicia only for pre-existing customer.
        GOSUB UPDATE.INDICIA
    END
    GOSUB UPDATE.REPORTABLE.DETAILS
    
    CRS.PARAM.INFO = CHNG.REASON
    CRS.WAIVE = WAIVER.RECVD
    
RETURN
*** </region>
*------------------------------------------------------------------------
UPDATE.REPORTABLE.DETAILS:
*--------------------------
* Update the crs status,change date,change reason based on the reported juristiction.
    IF REPORTING.JURISDICTIONS THEN
        VM.CNT = DCOUNT(REPORTING.JURISDICTIONS,@VM)
        IF VM.CNT = 0 THEN
            VM.CNT = 1
        END
          
        FOR POS = 1 TO VM.CNT
            NEW.CRS.STATUS = ""
            WAIVER.RECEIVED = ""
            NEW.STATUS.CHNG.REASON = ""
            NEW.STATUS.CHNG.DATE = ""
            RJ.CNTRY = REPORTING.JURISDICTIONS<1,POS>
            LOCATE RJ.CNTRY IN REP.JUR<1,1> SETTING J.POS THEN
                NEW.CRS.STATUS = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCrsStatus,J.POS>
                WAIVER.RECEIVED = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiReportWaiverRec,J.POS>
                NEW.STATUS.CHNG.REASON = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiChangeReason,J.POS>
                NEW.STATUS.CHNG.DATE = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiStatusChngDate,J.POS>
            END
            GOSUB UPDATE.CRS.STATUS ;* Update CRS STATUS based on the reportrd juristictions
        NEXT POS
    END ELSE
        CRS.STATUS<1,-1> = 'NON-REPORTABLE'
    END
        
  
             
RETURN
*** </region>
*------------------------------------------------------------------------
RESIDENCE.ADDRESS.CHECK:
*-----------------------
* Check whether TAX.RESIDENCE country is one of participating jurisdiction.
* If yes, update this country to Reportable Jusrisdiction residence.

    INDICIA.COUNTRIES = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTaxResidence>
    GOSUB CHECK.INDICIA
    IF INDICIA.EXISTS THEN
        PAR.TAX.RES = 1
    END
    
    CLIENT.TYPE = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCrsCustomerType>
    R.CRS.CLIENT.TYPE = ""
    CRS.ERR = ""
    R.CRS.CLIENT.TYPE = CD.CustomerIdentification.CrsClientType.Read(CLIENT.TYPE, CRS.ERR)

    IF R.CRS.CLIENT.TYPE<CD.CustomerIdentification.CrsClientType.CdCtCrsCode> EQ "CRS103" THEN
        INDICIA.COUNTRIES = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiRtTaxResidence>
    END
    GOSUB CHECK.INDICIA

RETURN
*-------------------------------------------------------------------------
ELECTRONIC.RECORD.SEARCH:
*------------------------
* For electronic record search, check the Address countries, Telephone countries,
* Standing Instruction countries, Poa Holder countries.

    GOSUB CHECK.ADDRESS.COUNTRY
    GOSUB CHECK.TELEPHONE.COUNTRY
    GOSUB CHECK.STANDING.INST.COUNTRY
    GOSUB CHECK.POA.HOLDER.COUNTRY
    GOSUB CHECK.BIRTH.INCORP.COUNTRY ; *;*to return the incorporation country as indicia for legal entities

RETURN
*-------------------------------------------------------------------------
CHECK.ADDRESS.COUNTRY:
*---------------------
* Check whether ADDRESS.COUNTRY is one of participating jurisdiction.
* If yes, update this country to Reportable Jusrisdiction residence.

    NO.OF.VMS = DCOUNT(ADDRESS.COUNTRIES,@VM)
    FOR VM.CNT = 1 TO NO.OF.VMS
        INDICIA.COUNTRIES = RAISE(ADDRESS.COUNTRIES<1,VM.CNT>)
        GOSUB CHECK.INDICIA
        IF INDICIA.EXISTS THEN
            PAR.ADDR.COUNTRY = 1
        END
    NEXT VM.CNT

RETURN
*-------------------------------------------------------------------------
CHECK.TELEPHONE.COUNTRY:
*-----------------------
* Check whether TELEPHONE.COUNTRY is one of participating jurisdiction.
* If yes, update this country to Reportable Jusrisdiction residence.

    INDICIA.COUNTRIES = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTelephoneCountry>
    GOSUB GET.LOCAL.CTRY
    LOCATE LOCAL.CTRY IN INDICIA.COUNTRIES<1,1> SETTING LOC.POS ELSE    ;* calculate indicia only when none of the telephone country is a local jurisdiction
        GOSUB CHECK.INDICIA
        IF INDICIA.EXISTS THEN
            PAR.TEL.COUNTRY = 1
        END
    END

RETURN
*-------------------------------------------------------------------------
CHECK.STANDING.INST.COUNTRY:
*---------------------------
* Check whether STANDING.INSTRUCITION country is one of participating jurisdiction.
* If yes, update this country to Reportable Jusrisdiction residence.

    INDICIA.COUNTRIES = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiStandingInstruct>
    GOSUB CHECK.INDICIA
    IF INDICIA.EXISTS THEN
        PAR.SI.COUNTRY = 1
    END

RETURN
*-------------------------------------------------------------------------
CHECK.POA.HOLDER.COUNTRY:
*------------------------
* Check whether POA.HOLDER country is one of participating jurisdiction.
* If yes, update this country to Reportable Jusrisdiction residence.

    INDICIA.COUNTRIES = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiPoaHolderCountry>
    GOSUB CHECK.INDICIA
    IF INDICIA.EXISTS THEN
        PAR.POA.COUNTRY = 1
    END

RETURN
*-------------------------------------------------------------------------
UPDATE.INDICIA:
*--------------
* Update INDICIA is required or not for pre-existing customers.
* If Tax residence is one of participating jurisdiction and one of the following
* Address country or Telephone country or Standing Instruction country or
* POA holder country is one of participating jurisdiction, then update INDICIA as YES.

    IF PAR.TAX.RES THEN
        IF PAR.ADDR.COUNTRY OR PAR.TEL.COUNTRY OR PAR.SI.COUNTRY OR PAR.POA.COUNTRY OR PAR.INCORP.COUNTRY THEN
            INDICIA.STRENGTH = 'YES'
        END
    END

RETURN
*-------------------------------------------------------------------------
UPDATE.CRS.STATUS:
*-----------------
* If the residence of the jurisdiction is in participation jurisdiction and waiver is
* not received, then set the CRS status as reportbale else non-reportable.

    IF NEW.CRS.STATUS AND (NEW.STATUS.CHNG.DATE AND NEW.STATUS.CHNG.REASON) THEN
        CRS.STATUS<1,-1> = NEW.CRS.STATUS
    END ELSE
        IF REPORTING.JURISDICTIONS<1,POS> AND WAIVER.RECEIVED NE 'YES' THEN
            CRS.STATUS<1,-1> = 'REPORTABLE'
        END ELSE
            CRS.STATUS<1,-1> = 'NON-REPORTABLE'
        END
    END

    CHNG.DATE<1,POS> =   NEW.STATUS.CHNG.DATE
    CHNG.REASON<1,POS> = NEW.STATUS.CHNG.REASON
    WAIVER.RECVD<1,POS> = WAIVER.RECEIVED
    
      
RETURN
*-------------------------------------------------------------------------
CHECK.INDICIA:
*-------------
* Check whether the country is one of the participating jurisdiction.
* If yes, update the reporting jurisdiction with that country.

    INDICIA.EXISTS = ''
    LOOP
        REMOVE IND.COUNTRY FROM INDICIA.COUNTRIES SETTING PC.POS
    WHILE IND.COUNTRY : PC.POS
        IF IND.COUNTRY MATCHES PARTICIPATING.JURISDICTIONS THEN
            INDICIA.EXISTS = 'Y'
            IF NOT(IND.COUNTRY MATCHES REPORTING.JURISDICTIONS) THEN
                REPORTING.JURISDICTIONS<1,-1> = IND.COUNTRY
            END
        END
    REPEAT

RETURN
*-------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise</desc>
INITIALISE:
*----------
* Initialise the required variables before using.
    INDICIA.STRENGTH = ''
    REPORTING.JURISDICTIONS = ''
    CRS.STATUS = ''
    CHNG.DATE = ''
    CHNG.REASON = ''
    WAIVER.RECVD = ''
    RETURN.MSG = ''

* Variables to set when the corresponding countries is one of participating jurisdiction.
    PAR.TAX.RES = ''
    PAR.ADDR.COUNTRY = ''
    PAR.TEL.COUNTRY = ''
    PAR.SI.COUNTRY = ''
    PAR.POA.COUNTRY = ''
    PAR.INCORP.COUNTRY = ''
    POS = ''
    CNT = ''
* Variables to set when the corresponding CRS status and waiver,status change date change reason of the participating jurisdiction.
    PARTICIPATING.JURISDICTIONS = CRS.PARAM.INFO<1>         ;* List of participating countries.
    NEW.CUSTOMER = CUSTOMER.INFO<1>     ;* To identify New or pre-existing customer.
    ADDRESS.COUNTRIES = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiAddressCountry>
    REP.JUR = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiReportableJurRes>
    WAIVER.RECEIVED = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiReportWaiverRec>
    NEW.CRS.STATUS = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCrsStatus>
    STATUS.CHNG.REASON = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiChangeReason>
    STATUS.CHNG.DATE = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiStatusChngDate>
 
RETURN
*** </region>
*------------------------------------------------------------------------

*** <region name= CHECK.BIRTH.INCORP.COUNTRY>
CHECK.BIRTH.INCORP.COUNTRY:
*** <desc>;*to return the incorporation country as indicia for legal entities </desc>

    CRS.CLIENT.TYPE = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCrsCustomerType>
    R.CRS.CLIENT.TYPE.INFO = CD.CustomerIdentification.CrsClientType.CacheRead(CRS.CLIENT.TYPE, '')
    CRS.CODE = R.CRS.CLIENT.TYPE.INFO<CD.CustomerIdentification.CrsClientType.CdCtCrsCode>
    ENTITY.CODE = "CRS101":@VM:"CRS103"
    IF CRS.CODE MATCHES ENTITY.CODE THEN ;*check if the customer type is of legal entities
        INDICIA.COUNTRIES = R.CRS.CUST.SUPP.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiBirthIncorpPlace>
        GOSUB CHECK.INDICIA
        IF INDICIA.EXISTS THEN
            PAR.INCORP.COUNTRY = 1
        END
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------
GET.LOCAL.CTRY:
*-------------
* Read customer record and get customer's company.
* Fetch the corresponding country in which the company is present (local jurisdiction)

    R.CUS = ''
    ST.CustomerService.getRecord(CUSTOMER.ID, R.CUS)
    
    LOCAL.COMP = ''
    IF R.CUS<ST.Customer.Customer.EbCusCompanyBook> THEN  ;* Get local Company
        LOCAL.COMP = R.CUS<ST.Customer.Customer.EbCusCompanyBook>
    END ELSE
        LOCAL.COMP = R.CUS<ST.Customer.Customer.EbCusCoCode>
    END
    
    LOCAL.CTRY = ''
    IF LOCAL.COMP EQ EB.SystemTables.getIdCompany() THEN   ;* If customer company eq ID company
        IF EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry) THEN
            LOCAL.CTRY = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry)
        END ELSE
            LOCAL.CTRY = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalRegion)[1,2]
        END
    END ELSE    ;* else get country of customer company
        COMP.ERR = ''
        R.COMP = ST.CompanyCreation.Company.CacheRead(LOCAL.COMP, COMP.ERR)
        IF R.COMP<ST.CompanyCreation.Company.EbComLocalCountry> THEN
            LOCAL.CTRY = R.COMP<ST.CompanyCreation.Company.EbComLocalCountry>
        END ELSE
            LOCAL.CTRY = R.COMP<ST.CompanyCreation.Company.EbComLocalRegion>[1,2]
        END
    END
    
RETURN
*-----------------------------------------------------------------------------
END


         
           
