* @ValidationCode : MjoxOTYyMDg2NDAxOmNwMTI1MjoxNjAzMTEwNjU2MzA3OmtyYW1hc2hyaTo1OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjA6MjA4OjE3MQ==
* @ValidationInfo : Timestamp         : 19 Oct 2020 18:00:56
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 171/208 (82.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE FA.CustomerIdentification
SUBROUTINE FATCA.DO.REASONABLENESS.CHECK(CUSTOMER.ID, RESULT, REASON, RESERVED3, RESERVED2, RESERVED1)
*-----------------------------------------------------------------------------
* New API to check Customer reasonableness for FATCA
* Arguments:
*------------
* CUSTOMER.ID       (IN)    - Customer Id for whom reasonbleness check is to be done
* RESULT            (OUT)   - Reasonableness Check Result i.e., NOK - Not Okay, OK - Okay
* REASON            (OUT)   - Reason when the Result is NOK or ERROR
* RESERVED3         (INOUT) - Reserved for future use
* RESERVED2         (INOUT) - Reserved for future use
* RESERVED1         (INOUT) - Reserved for future use
*-----------------------------------------------------------------------------
* Modification History :
*
* 18/12/2019    - Enhancement 3482504  / Task 3499522
*                 New API to check Customer reasonableness for FATCA
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
*-----------------------------------------------------------------------------
    $USING RT.Config
    $USING FA.CustomerIdentification
    $USING EB.DataAccess
    $USING EB.LocalReferences
    $USING EB.API
    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $USING ST.CustomerService
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
    FROM.FIELDS = ''
    TO.FIELDS = ''
    NON.US.FIELDS = ''
    FROM.FIELD.NAME = ''
    FIRST.TEXT = ''
    SECOND.TEXT = ''
    ERROR.FIELDS = ''
    FIRST.ERR.FLAG = @FALSE
    REASON.CNT = 0
    
    R.CUSTOMER = ''
    ST.CustomerService.getRecord(CUSTOMER.ID, R.CUSTOMER)   ;* get the customer record
    IF NOT(R.CUSTOMER) THEN     ;* set Error if customer is not found
        RESULT = 'ERROR'
        REASON = 'Customer Not found'
        RETURN
    END
    
    RT.INSTALLED = ''
    EB.API.ProductIsInCompany('RT', RT.INSTALLED)   ;* Check if RT is installed
    IF RT.INSTALLED EQ '' THEN
        RESULT = 'ERROR'
        REASON = 'RT Product is not installed'
    END
    
RETURN
*-----------------------------------------------------------------------------
PROCESS:
    
    GOSUB READ.REASONABLENESS.CHECK.PARAMETER
    IF RESULT EQ 'ERROR' THEN       ;* return if parameter is not defined
        RETURN
    END
    GOSUB READ.FCSI
    IF RESULT NE 'ERROR' THEN
        GOSUB CHECK.REASONABLENESS
    END
    
RETURN
*-----------------------------------------------------------------------------
READ.REASONABLENESS.CHECK.PARAMETER:

* Read FATCA Customer Reasonableness Check Parameter.
    PARAM.ERR = ''
    R.CHK.PARAM = RT.Config.CustReasonablenessCheckParameter.Read('FATCA', PARAM.ERR)
    IF NOT(R.CHK.PARAM) THEN    ;* set error if parameter is not defined
        RESULT = 'ERROR'
        REASON = 'Customer Reasonableness Check Parameter is not defined'
    END
    
RETURN
*-----------------------------------------------------------------------------
READ.FCSI:

* If FATCA Customer Supplementary Info record does not exist for the incoming customer, the fields
* Onboard Check Country From and Onboard Check Country To are used to check reasonableness.
* If FATCA Customer Supplementary Info record exists for the incoming customer, then the customer is
* already into FATCA. So the fields Post Onboard Check Country From and Post Onboard Check Country To
* are used to check reasonableness.

    FA.ERR = ''
    R.FCSI = FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.Read(CUSTOMER.ID, FA.ERR)
    IF NOT(R.FCSI) THEN
        FROM.FIELDS = R.CHK.PARAM<RT.Config.CustReasonablenessCheckParameter.RtResnOnbrdTaxCountryFrom>
        TO.FIELDS = R.CHK.PARAM<RT.Config.CustReasonablenessCheckParameter.RtResnOnbrdTaxCountryTo>
        IF NOT(FROM.FIELDS) OR NOT(TO.FIELDS) THEN
            REASON = 'FATCA Customer Supplementary info record not found for the customer'
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
    
    GOSUB GET.FROM.FIELDS       ;* get all FROM countries in an array
    GOSUB GET.TO.FIELDS         ;* get all TO countries in an array
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
            FROM.FIELD.NAME<-1> = FIELD.NAME
            FROM.CTRY<-1> = FIELD.VALUE
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
        TO.CTRY<-1> = FIELD.VALUE
    NEXT I
    
RETURN
*-----------------------------------------------------------------------------
GET.FIELD.VALUE:
    
    FIELD.VALUE = ''
    IF APPLN EQ 'INDICIA' THEN          ;* If the first part defined is INDICIA, check if the mentioned indicia is found
        GOSUB CHECK.FOR.INDICIA
    END ELSE
* Read the corresponding application record
        FN.APPLN = 'F.':APPLN
        FV.APPLN = ''
        READ.ER = ''
        GOSUB GET.APPLN.ID
        EB.DataAccess.FRead(FN.APPLN, APPLN.ID, R.APPLN, FV.APPLN, READ.ER)
    
        SS.REC = ''
        EB.API.GetStandardSelectionDets(APPLN, SS.REC)  ;* read SS Record for the application
        ER = ''
        EB.API.FieldNamesToNumbers(FIELD.NAME, SS.REC, FLD.NO, '', '', '', '', ER)  ;* get the field position
        IF NOT(FLD.NO) THEN     ;* If field position is null, check for local field
            EB.LocalReferences.GetLocRef(APPLN, FIELD.NAME, FLD.NO)     ;* get local field position
            LOCATE 'LOCAL.REF' IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING POS THEN      ;* get local reference field position of the application
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
    LOCATE INDICIA.TYPE IN R.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiIndiciaSummary,1> SETTING IND.POS THEN
        FIELD.VALUE = R.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiIndiciaCountry,IND.POS>
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
 
* Result is ERROR if FROM or TO array is blank
    
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
        CASE  NOT(FROM.CTRY)
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
        CASE 1
            CHANGE @VM TO @FM IN TO.CTRY
            CHANGE @SM TO @FM IN TO.CTRY
* If TO Country matches US, then Result is OK
            LOCATE 'US' IN TO.CTRY<1> SETTING POS THEN
                RESULT = 'OK'
            END ELSE
                GOSUB PROCESS.CHECK
            END
    END CASE
    
    IF RESULT EQ 'NOK' OR RESULT EQ 'ERROR' THEN    ;* Add the missing indicias in the reason when the result is NOK or ERROR
        FIRST.TEXT = ''
        SECOND.TEXT = ' indicia is not detected'
        ERROR.FIELDS = MISSING.INDICIA
        GOSUB FORM.REASON
    END
            
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
PROCESS.CHECK:

* Add the fields that have US reference in Reason
    TOT.FROM.CNT = DCOUNT(FROM.CTRY,@FM)
    FOR F.CNT = 1 TO TOT.FROM.CNT
        F.CTRY = FROM.CTRY<F.CNT>
        CHANGE @VM TO @FM IN F.CTRY     ;* there can be multiple values in one from field, so change VM & SM to FM marker
        CHANGE @SM TO @FM IN F.CTRY
        LOCATE 'US' IN F.CTRY<1> SETTING FPOS THEN
            REASON.CNT+=1
            IF REASON.CNT EQ '1' THEN
                REASON<-1> = 'Inconsistency detected due to ':FROM.FIELD.NAME<F.CNT>
            END ELSE
                REASON<-1> = '':'*':'':'*':'Inconsistency detected due to ':FROM.FIELD.NAME<F.CNT>
            END
        END
    NEXT F.CNT

* If there are no US fields, reason would be null, so Result should be OK
    IF REASON THEN
        RESULT = 'NOK'
    END ELSE
        RESULT = 'OK'
    END
       
RETURN
*-----------------------------------------------------------------------------
END


