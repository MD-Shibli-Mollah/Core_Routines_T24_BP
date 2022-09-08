* @ValidationCode : MjotMTkyMjQ3NzIxNjpjcDEyNTI6MTYwMzE4ODY1NTAyMjprcmFtYXNocmk6NTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMC4wOjI4OToyNDM=
* @ValidationInfo : Timestamp         : 20 Oct 2020 15:40:55
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 243/289 (84.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE CD.CustomerIdentification
SUBROUTINE CRS.DO.REASONABLENESS.CHECK(CUSTOMER.ID, RESULT, REASON, RESERVED3, RESERVED2, RESERVED1)
*-----------------------------------------------------------------------------
* New API to check Customer reasonableness for CRS
* Arguments:
*------------
* CUSTOMER.ID       (IN)    - Customer Id for whom reasonbleness check is to be done
* RESULT            (OUT)   - Reasonableness Check Result i.e., NOK - Not Okay, OK - Okay, ERROR - Error
* REASON            (OUT)   - Reason when the result is NOK or ERROR
* RESERVED3         (INOUT) - Reserved for future use
* RESERVED2         (INOUT) - Reserved for future use
* RESERVED1         (INOUT) - Reserved for future use
*-----------------------------------------------------------------------------
* Modification History :
*
* 18/12/2019    - Enhancement 3482504  / Task 3499522
*                 New API to check Customer reasonableness for CRS
*
* 18/01/2020    - Enhancement 3482504  / Task 3525392
*                 Additional changes in API
*
* 13/02/2020    - Enhancement 3482504  / Task 3564136
*                 Changes done to output Result as Error when either FROM or TO fields are blank
*
* 11/05/2020    - Defect 3722600  / Task 3739473
*                 Changes done to check Indicia fields when INDICIA is defined in Reasonbleness parameter
*
* 31/07/2020    - Enhancement 3972460 / Task 3887531
*                 Changes done to return Reason line by line seperated by FM marker
*
* 31/07/2020    - Defect 4027258 / Task 4033613
*                 Result to be OK when no reportable jurisdictions found in FROM, TO fields
*-----------------------------------------------------------------------------
    $USING RT.Config
    $USING CD.CustomerIdentification
    $USING CD.Config
    $USING EB.DataAccess
    $USING EB.LocalReferences
    $USING EB.API
    $USING EB.SystemTables
    $USING ST.CustomerService
    $USING ST.Customer
    $USING ST.CompanyCreation
    $USING ST.Config
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    IF RESULT NE 'ERROR' THEN
        GOSUB PROCESS
    END

RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
    RESULT = ''
    REASON = ''
    LOCAL.COMP = ''
    COMP.ERR = ''
    LOCAL.CTRY = ''
    ID.COMP = EB.SystemTables.getIdCompany()
    FROM.FIELDS = ''
    TO.FIELDS = ''
    UNMATCHED.JUR = ''
    FROM.CTRY = ''
    TO.CTRY = ''
    FROM.FIELD.NAME = ''
    TO.FIELD.NAME = ''
    MISSING.INDICIA = ''
    FIRST.TEXT = ''
    SECOND.TEXT = ''
    ERROR.FIELDS = ''
    REASON.CNT = 0
    FIRST.ERR.FLAG = @FALSE
    
    R.CUSTOMER = ''
    ST.CustomerService.getRecord(CUSTOMER.ID, R.CUSTOMER)   ;* get the customer record
    IF NOT(R.CUSTOMER) THEN     ;* set Error if customer is not found
        RESULT = 'ERROR'
        REASON = 'Customer Not found'
        RETURN
    END ELSE
        GOSUB GET.LOCAL.CTRY    ;* get local country
        FN.CRS.PARAMETER = 'F.CRS.PARAMETER'
        FV.CRS.PARAMETER = ''
        ST.CompanyCreation.EbReadParameter(FN.CRS.PARAMETER,'N','',R.CRS.PARAM,ID.COMP,FV.CRS.PARAMETER,PARAM.ER)   ;* read CRS Parameter record to get reportable jurisdictions
    END
    
    RT.INSTALLED = ''
    EB.API.ProductIsInCompany('RT', RT.INSTALLED)   ;* Check if RT is installed
    IF RT.INSTALLED EQ '' THEN      ;* set Error if RT product is not installed
        RESULT = 'ERROR'
        REASON = 'RT Product is not installed'
    END
    
RETURN
*-----------------------------------------------------------------------------
PROCESS:
    
    GOSUB READ.REASONABLENESS.CHECK.PARAMETER
    IF RESULT EQ 'ERROR' THEN     ;* return if parameter is not defined
        RETURN
    END
    GOSUB READ.CCSI
    IF RESULT NE 'ERROR' THEN
        GOSUB CHECK.REASONABLENESS
    END
    
RETURN
*-----------------------------------------------------------------------------
READ.REASONABLENESS.CHECK.PARAMETER:
    
* Read CRS Customer Reasonableness Check Parameter.
    PARAM.ERR = ''
    R.CHK.PARAM = RT.Config.CustReasonablenessCheckParameter.Read('CRS', PARAM.ERR)
    IF NOT(R.CHK.PARAM) THEN    ;* set error if parameter is not defined
        RESULT = 'ERROR'
        REASON = 'Customer Reasonableness Check Parameter is not defined'
    END
    
RETURN
*-----------------------------------------------------------------------------
READ.CCSI:

* If CRS Customer Supplementary Info record does not exist for the incoming customer, the fields
* Onboard Check Country From and Onboard Check Country To are used to check reasonableness.
* If CRS Customer Supplementary Info record exists for the incoming customer, then the customer is
* already into CRS. So the fields Post Onboard Check Country From and Post Onboard Check Country To
* are used to check reasonableness.
    
    CD.ERR = ''
    R.CCSI = CD.CustomerIdentification.CrsCustSuppInfo.Read(CUSTOMER.ID, CD.ERR)
    IF NOT(R.CCSI) THEN
        FROM.FIELDS = R.CHK.PARAM<RT.Config.CustReasonablenessCheckParameter.RtResnOnbrdTaxCountryFrom>
        TO.FIELDS = R.CHK.PARAM<RT.Config.CustReasonablenessCheckParameter.RtResnOnbrdTaxCountryTo>
        IF NOT(FROM.FIELDS) OR NOT(TO.FIELDS) THEN
            REASON = 'CRS Customer Supplementary info record not found for the customer'
        END
    END ELSE
        FROM.FIELDS = R.CHK.PARAM<RT.Config.CustReasonablenessCheckParameter.RtResnPostOnbrdChkCountryFrom>
        TO.FIELDS = R.CHK.PARAM<RT.Config.CustReasonablenessCheckParameter.RtResnPostOnbrdChkCountryTo>
        IF NOT(FROM.FIELDS) OR NOT(TO.FIELDS) THEN
            REASON = 'Post Onboarding fields are not defined in Reasonableness parameter'
        END
    END
    
    IF REASON THEN  ;* set Error if FROM or TO fields is blank in Reasonableness parameter
        RESULT = 'ERROR'
    END
    
RETURN
*-----------------------------------------------------------------------------
CHECK.REASONABLENESS:
    
    GOSUB GET.FROM.FIELDS     ;* get all FROM countries in an array
    GOSUB GET.TO.FIELDS       ;* get all TO countries in an array
    GOSUB COMPARE.FROM.AND.TO.VALUES    ;* Compare FROM and TO countries
    
RETURN
*-----------------------------------------------------------------------------
GET.FROM.FIELDS:
    
    FROM.FIELDS.CNT = DCOUNT(FROM.FIELDS,@VM)   ;* get the count of from fields
    FOR J = 1 TO FROM.FIELDS.CNT
        FROM.FLD = FROM.FIELDS<1,J>
        APPLN = FIELD(FROM.FLD,'>',1)       ;* get the first part (Application Name)
        FIELD.NAME = FIELD(FROM.FLD,'>',2)  ;* get the second part (Field name)
        GOSUB GET.FIELD.VALUE   ;* fetch FROM field value
        IF FIELD.VALUE THEN
            FROM.FIELD.NAME<J> = FIELD.NAME
            FROM.CTRY<J> = FIELD.VALUE
        END
    NEXT J
    
RETURN
*-----------------------------------------------------------------------------
GET.TO.FIELDS:
    
    TO.FIELDS.CNT = DCOUNT(TO.FIELDS,@VM)   ;* get the count of to fields
    FOR I = 1 TO TO.FIELDS.CNT
        TO.FLD = TO.FIELDS<1,I>
        APPLN = FIELD(TO.FLD,'>',1)         ;* get the first part (Application Name)
        FIELD.NAME = FIELD(TO.FLD,'>',2)    ;* get the second part (Field name)
        GOSUB GET.FIELD.VALUE   ;* fetch TO field value
        TO.FIELD.NAME<I> = FIELD.NAME
        IF FIELD.VALUE THEN
            TO.CTRY<I> = FIELD.VALUE
        END
    NEXT I
    
RETURN
*-----------------------------------------------------------------------------
GET.FIELD.VALUE:

    FIELD.VALUE = ''
    IF APPLN EQ 'INDICIA' THEN      ;* If the first part defined is INDICIA, check if the mentioned indicia is met
        GOSUB CHECK.FOR.INDICIA
    END ELSE
* Read the corresponding application record
        FN.APPLN = 'F.':APPLN
        FV.APPLN = ''
        READ.ER = ''
        GOSUB GET.APPLN.ID  ;* get the id of the application
        EB.DataAccess.FRead(FN.APPLN, APPLN.ID, R.APPLN, FV.APPLN, READ.ER)
    
        FIELD.VALUE = ''
        SS.REC = ''
        EB.API.GetStandardSelectionDets(APPLN, SS.REC)      ;* read SS Record for the application
        ER = ''
        EB.API.FieldNamesToNumbers(FIELD.NAME, SS.REC, FLD.NO, '', '', '', '', ER)  ;* get the field position
        IF NOT(FLD.NO) THEN     ;* If field position is null, check for local field
            EB.LocalReferences.GetLocRef(APPLN, FIELD.NAME, FLD.NO)     ;* get local field position
            LOCATE 'LOCAL.REF' IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING POS THEN  ;* get local reference field position of the application
                LOC.REF.POS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo,POS>
            END
            FIELD.VALUE = R.APPLN<LOC.REF.POS,FLD.NO>   ;* get local field value
        END ELSE
            FIELD.VALUE = R.APPLN<FLD.NO>   ;* get the field value
        END
    END
    
RETURN
*-----------------------------------------------------------------------------
CHECK.FOR.INDICIA:

    INDICIA.TYPE = FIELD.NAME
    IND.POS = ''
* If the indicia is found, get the corresponding indicia country to check reasonableness
    LOCATE INDICIA.TYPE IN R.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiIndiciaSummary,1> SETTING IND.POS THEN
        FIELD.VALUE = R.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiIndiciaCountry,IND.POS>
    END ELSE
        MISSING.INDICIA<-1> = INDICIA.TYPE      ;* store the missing indicias in a variable
    END
  
RETURN
*-----------------------------------------------------------------------------
GET.APPLN.ID:
    
    APPLN.ID = ''
    BEGIN CASE
        CASE APPLN EQ 'DE.ADDRESS'
            APPLN.ID = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany):'.C-':CUSTOMER.ID:'.PRINT.1'
        CASE 1
            APPLN.ID = CUSTOMER.ID  ;* default one
    END CASE

RETURN
*-----------------------------------------------------------------------------
COMPARE.FROM.AND.TO.VALUES:
    
;* Result will be ERROR if FROM or TO array are blank
    
    CHANGE @VM TO @FM IN FROM.FIELDS
    CHANGE @VM TO @FM IN TO.FIELDS
    
    BEGIN CASE
        CASE NOT(FROM.CTRY) AND NOT(TO.CTRY)
            RESULT = 'ERROR'
            FIRST.TEXT = 'Reasonableness check could not be done. '
            SECOND.TEXT = ' remains blank.'
            ERROR.FIELDS = FROM.FIELDS
            ERROR.FIELDS<-1> = TO.FIELDS
            FIRST.ERR.FLAG = @TRUE
            GOSUB FORM.REASON
        CASE NOT(FROM.CTRY)
            RESULT = 'ERROR'
            FIRST.TEXT = 'Reasonableness check could not be done. '
            SECOND.TEXT = ' remains blank.'
            ERROR.FIELDS = FROM.FIELDS
            FIRST.ERR.FLAG = @TRUE
            GOSUB FORM.REASON
        CASE NOT(TO.CTRY)
            RESULT = 'ERROR'
            FIRST.TEXT = 'Reasonableness check could not be done. '
            SECOND.TEXT = ' remains blank.'
            ERROR.FIELDS = TO.FIELDS
            FIRST.ERR.FLAG = @TRUE
            GOSUB FORM.REASON
    END CASE
    
    IF RESULT EQ 'ERROR' THEN
        FIRST.TEXT = ''
        SECOND.TEXT = ' indicia is not detected'
        ERROR.FIELDS = MISSING.INDICIA
        GOSUB FORM.REASON
        RETURN
    END

* Exclude non reportable jurisdictions alone & store it in a seperate array
    CHK.CTRY = FROM.CTRY
    GOSUB EXCLUDE.NON.REPORTABLE.JUR
    FROM.CTRY.FINAL = CHK.CTRY

    CHK.CTRY = TO.CTRY
    GOSUB EXCLUDE.NON.REPORTABLE.JUR
    TO.CTRY.FINAL = CHK.CTRY

    BEGIN CASE
        CASE NOT(FROM.CTRY.FINAL) AND NOT(TO.CTRY.FINAL)        ;* Result is OK if both FROM and TO array is null (after excluding non reportable jurisdiction)
            RESULT = 'OK'
        CASE NOT(TO.CTRY.FINAL)                           ;* Result is NOK since TO array is null
            RESULT = 'NOK'                           ;* FROM countries not found in TO fields
            TO.CTRY = TO.CTRY.FINAL
            GOSUB PROCESS.CHECK
        CASE NOT(FROM.CTRY.FINAL)                         ;* When FROM array is null, Result will be based on the TO country whether it is reportable/not
            RESULT = 'OK'                                 ;* when ctrl is here, there is either reportable or local jur in TO array,
        CASE 1
* If any one of the FROM countries is not found in TO country array, Result will be NOK
            GOSUB PROCESS.CHECK
    END CASE
    
    IF RESULT EQ 'NOK' OR RESULT EQ 'ERROR' THEN    ;* Add the missing indicias in the reason when the result is NOK or ERROR
        FIRST.TEXT = ''
        SECOND.TEXT = ' indicia is not detected'
        ERROR.FIELDS = MISSING.INDICIA
        GOSUB FORM.REASON
    END

RETURN
*-----------------------------------------------------------------------------
EXCLUDE.NON.REPORTABLE.JUR:
    
    CHANGE @VM TO @FM IN CHK.CTRY
    CHANGE @SM TO @FM IN CHK.CTRY
    
    FRM.CNT = DCOUNT(CHK.CTRY,@FM)
    LOOP
        IF CHK.CTRY<FRM.CNT> NE LOCAL.CTRY THEN
            LOCATE CHK.CTRY<FRM.CNT> IN R.CRS.PARAM<CD.Config.CrsParameter.CdCpPartngJuridiction,1> SETTING POS ELSE    ;* remove non reportable jurisdictions
                DEL CHK.CTRY<FRM.CNT>
            END
        END
        FRM.CNT = FRM.CNT - 1
    UNTIL FRM.CNT LE 0      ;* loop until Count is lesser than or equal to 0
    REPEAT
    
RETURN
*-----------------------------------------------------------------------------
PROCESS.CHECK:
    
    CHANGE @VM TO @FM IN TO.CTRY.FINAL
    CHANGE @SM TO @FM IN TO.CTRY.FINAL
            
    CHANGE @FM TO ', ' IN TO.FIELD.NAME

* Loop through each from field
    TOT.FROM.CNT = DCOUNT(FROM.CTRY.FINAL,@FM)
    FOR F.CNT = 1 TO TOT.FROM.CNT
        F.CTRY = FROM.CTRY.FINAL<F.CNT>
        CHANGE @VM TO @FM IN F.CTRY     ;* a field can hold multiple values, so change VM, SM to FM markers
        CHANGE @SM TO @FM IN F.CTRY
        GOSUB CHECK.IN.TO.FIELDS
    NEXT F.CNT
    
    IF REASON THEN   ;* Result will be NOK if Reason is not null
        RESULT = 'NOK'
    END ELSE
        RESULT = 'OK'
    END

RETURN
*-----------------------------------------------------------------------------
CHECK.IN.TO.FIELDS:

* Loop through each field value & check if it is present in TO array
    LOOP
        REMOVE CTRY FROM F.CTRY SETTING C.POS
    WHILE CTRY:C.POS
        BEGIN CASE
            CASE CTRY EQ LOCAL.CTRY     ;* if the country is local jurisdiction, do not add it in reason
                NULL
            CASE 1
                LOCATE CTRY IN TO.CTRY.FINAL<1> SETTING T.POS ELSE    ;*if the country is not available in TO array, add the country in reason
                    REASON.CNT+=1
                    IF REASON.CNT EQ '1' THEN
                        REASON<-1> = 'Inconsistency detected due to ':FROM.FIELD.NAME<F.CNT>:'>':TO.FIELD.NAME:'-':CTRY
                    END ELSE
                        REASON<-1> = '':'*':'':'*':'Inconsistency detected due to ':FROM.FIELD.NAME<F.CNT>:'>':TO.FIELD.NAME:'-':CTRY
                    END
                END
        END CASE
    REPEAT

RETURN
*-----------------------------------------------------------------------------
FORM.REASON:

* Store the reason line by line seperated by FM

    IF FIRST.ERR.FLAG AND NOT(REASON.CNT) THEN      ;* append the first text in the reason array
        REASON<-1> = FIRST.TEXT
        FIRST.TEXT = ''         ;* make it null so that this does not get added in the next lines
    END
    
    ERROR.TOT.CNT = DCOUNT(ERROR.FIELDS,@FM)
    FOR LINE.CNT = 1 TO ERROR.TOT.CNT
        REASON.CNT+=1
        IF FIELD(ERROR.FIELDS<LINE.CNT>,'>',1) EQ 'INDICIA' THEN    ;* donot add INDICIA>RESIDENCE in the reason since the missing indicias will be added in the end
            CONTINUE
        END
        IF REASON.CNT EQ 1 AND NOT(FIRST.ERR.FLAG) THEN   ;* when flag is set, first line would have been added already
            REASON<-1> = FIRST.TEXT:ERROR.FIELDS<LINE.CNT>:SECOND.TEXT  ;* first line has CustomerID*Result*ReasonLine1
        END ELSE
            REASON<-1> = '':'*':'':'*':FIRST.TEXT:ERROR.FIELDS<LINE.CNT>:SECOND.TEXT    ;* remaining lines have **ReasonLine
        END
    NEXT LINE.CNT
    
RETURN
*-----------------------------------------------------------------------------
GET.LOCAL.CTRY:
    
    IF R.CUSTOMER<ST.Customer.Customer.EbCusCompanyBook> THEN  ;* Get local Company
        LOCAL.COMP = R.CUSTOMER<ST.Customer.Customer.EbCusCompanyBook>
    END ELSE
        LOCAL.COMP = R.CUSTOMER<ST.Customer.Customer.EbCusCoCode>
    END
    
    IF LOCAL.COMP EQ ID.COMP THEN   ;* If customer company eq ID company
        IF EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry) THEN
            LOCAL.CTRY = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCountry)
        END ELSE
            LOCAL.CTRY = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalRegion)[1,2]
        END
    END ELSE    ;* else get country of customer company
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

