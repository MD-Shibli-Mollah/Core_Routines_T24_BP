* @ValidationCode : Mjo5MDg2NjIzNjA6Y3AxMjUyOjE2MTczMzIxMDcyMjc6a3JhbWFzaHJpOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4wOi0xOi0x
* @ValidationInfo : Timestamp         : 02 Apr 2021 08:25:07
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
SUBROUTINE QI.CHECK.PORTFOLIO.PREFERENCES(CUSTOMER.ID, MESSAGE.GROUP, CARRIER, TAX.RESIDENCE, US.ADDR.CONFLICT, COUNTRY.FIELD.DETS, RESOUT2, RESOUT3)
*-----------------------------------------------------------------------------
* Sample API to check for Address Conflict in Portfolio's preferences
* Arguments:
*------------
* CUSTOMER.ID                (IN)    - Customer ID
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
* 10/03/21 - Defect 4275520 / Task 4276266
*            Sample API to check for Address Conflict in Portfolio's preferences
*-----------------------------------------------------------------------------
    $USING QI.CustomerIdentification
    $USING EB.API
    $USING ST.Customer
    $USING SC.ScvValuationUpdates
    $USING FA.CustomerIdentification
*-----------------------------------------------------------------------------
    
    GOSUB INITIALISE
    IF SC.INSTALLED THEN
        GOSUB PROCESS
    END
    
RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
    US.ADDR.CONFLICT = 'NO'
    R.SEC.ACC.CUST = ''
    PORT.ID = ''
    R.CUS.REL.XREF = ''
    CR.LIST = ''
    CR.ID = ''

* Check for SC product installation
    SC.INSTALLED = ''
    EB.API.ProductIsInCompany('SC', SC.INSTALLED)

RETURN
*-----------------------------------------------------------------------------
PROCESS:

* Read SEC.ACC.CUST file and get the list of portfolios owned by the customer
    SC.ERR = ''
    R.SEC.ACC.CUST = SC.ScvValuationUpdates.SecAccCust.Read(CUSTOMER.ID, SC.ERR)

* Loop and call the api to check for portfolio preferences
    LOOP
        REMOVE PORT.ID FROM R.SEC.ACC.CUST SETTING SC.POS
    WHILE PORT.ID:SC.POS
        DE.CUST.PREF.ID = ''
        DE.CUST.PREF.ID<1> = 'P-':PORT.ID    ;* form DCP Id = P-PortfolioId
        DE.CUST.PREF.ID<2> = CUSTOMER.ID     ;* Portfolio customer
        QI.CustomerIdentification.QIPerformCustPrefCheck(DE.CUST.PREF.ID, MESSAGE.GROUP, CARRIER, TAX.RESIDENCE, US.ADDR.CONFLICT, COUNTRY.FIELD.DETS, '', '')
    REPEAT
    
    GOSUB FIND.JOINT.PORTFOLIOS
    
RETURN
*-----------------------------------------------------------------------------
FIND.JOINT.PORTFOLIOS:

* In order to find the portfolios in which this customer is a joint, get CR id from Customer
* Relationship Xref Record (REVERSE type)
    CR.ERR = ''
    R.CUS.REL.XREF = ST.Customer.customerRelationshipXref.Read(CUSTOMER.ID, CR.ERR)
    LOCATE 'REVERSE' IN R.CUS.REL.XREF<ST.Customer.customerRelationshipXref.CrxRelationType,1> SETTING REL.POS ELSE
        RETURN
    END

* Loop through all the CR ids
    CR.LIST = R.CUS.REL.XREF<ST.Customer.customerRelationshipXref.CrxCustomerRelationshipId,REL.POS>
    CHANGE @SM TO @FM IN CR.LIST
    LOOP
        REMOVE CR.ID FROM CR.LIST SETTING CR.POS
    WHILE CR.ID:CR.POS
        GOSUB GET.LATEST.CR.ID
        IF FCSI.REC.ID THEN     ;* proceed if FCSI id is formed
            FA.ERR = ''
            R.FCSI = ''
            R.FCSI = FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.CacheRead(FCSI.REC.ID, FA.ERR)    ;* read the FCSI rec to get the portfolio id
            PORT.ID = R.FCSI<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiPortfolioId>
            IF PORT.ID THEN
                DE.CUST.PREF.ID = ''
                DE.CUST.PREF.ID<1> = 'P-':PORT.ID             ;* form DCP Id = P-PortfolioId
                DE.CUST.PREF.ID<2> = FIELD(PORT.ID,'-',1)     ;* Portfolio customer
                QI.CustomerIdentification.QIPerformCustPrefCheck(DE.CUST.PREF.ID, MESSAGE.GROUP, CARRIER, TAX.RESIDENCE, US.ADDR.CONFLICT, COUNTRY.FIELD.DETS, '', '')
            END
        END
    REPEAT

RETURN
*-----------------------------------------------------------------------------
GET.LATEST.CR.ID:

* Get the dates file to take the latest date for CR.ID
    R.ST.CUST.RELATIONSHIP.DATES = ''
    LATEST.CR.DATE = ''
    FCSI.REC.ID = ''
    Y.ERROR = ''
    R.ST.CUST.RELATIONSHIP.DATES = ST.Customer.CustRelationshipDates.Read(CR.ID, Y.ERROR)
    
    IF R.ST.CUST.RELATIONSHIP.DATES THEN
        NO.CR.DATES = DCOUNT(R.ST.CUST.RELATIONSHIP.DATES,@FM) ;* get the count and take the last as the latest date
        LATEST.CR.DATE = R.ST.CUST.RELATIONSHIP.DATES<NO.CR.DATES> ;* Latest Date for the Customer relationship id
        FCSI.REC.ID = CR.ID:'-':LATEST.CR.DATE ;* Form the customer relationship record id with latest date
    END

RETURN
*-----------------------------------------------------------------------------
END

