* @ValidationCode : Mjo5MjcwNTkxMzc6Y3AxMjUyOjE2MTczMzIxMDcxOTU6a3JhbWFzaHJpOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4wOi0xOi0x
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
SUBROUTINE QI.CHECK.MAILING.PREFERENCES(CUSTOMER.ID, MESSAGE.GROUP, CARRIER, COUNTRY.FIELD.DETS, US.ADDR.CONFLICT, RES.OUT1, RES.OUT2, RES.OUT3)
*-----------------------------------------------------------------------------
* Sample API to check for Address Conflict in DE.CUSTOMER.PREFERENCES
* Arguments:
*------------
* CUSTOMER.ID                (IN)    - Customer ID
*
* MESSAGE.GROUP              (IN)    - Message groups to be considered for Address Conflict check
*                                      If blank, ALL Message grps will be considered
*
* CARRIER                    (IN)    - Carrier to be checked for Address, eg: PRINT
*                                      If blank, default Carrier PRINT alone will be checked
*
* COUNTRY.FIELD.DETS         (IN)    - Field to check for PRINT.1 address
*                                      Field to check for other addresses
*
* US.ADDR.CONFLICT           (OUT)   - YES/NO, US Address Conflict Result
*
* RES.OUT1,RES.OUT2,RES.OUT3 (OUT)   - Outgoing Reserved Arguments
*-----------------------------------------------------------------------------
* Modification History :
*
* 01/12/20 - SI 3436249 / Task 4104932
*            Sample API to check for Address Conflict in DE.CUSTOMER.PREFERENCES
*
* 10/03/21 - Defect 4275520 / Task 4276266
*            Changes done to consider Portfolio level and Other Customer Preferences
*-----------------------------------------------------------------------------
    $USING QI.CustomerIdentification
    $USING ST.CustomerService
    $USING ST.Customer
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS
    
RETURN
*-----------------------------------------------------------------------------
INITIALISE:

* Read Customer Record and get the Tax Residence
    US.ADDR.CONFLICT = 'NO'
    DE.CUST.PREF.ID = ''
    R.CUSTOMER = ''
    ST.CustomerService.getRecord(CUSTOMER.ID, R.CUSTOMER)
    TAX.RESIDENCE = R.CUSTOMER<ST.Customer.Customer.EbCusDomicile>
    
    CHANGE ',' TO @FM IN MESSAGE.GROUP
    CHANGE ',' TO @FM IN CARRIER
    CHANGE ',' TO @FM IN COUNTRY.FIELD.DETS
    
    IF NOT(CARRIER) THEN
        CARRIER = 'PRINT'   ;* default carrier to be considered
    END
   
RETURN
*-----------------------------------------------------------------------------
PROCESS:
    
    DE.CUST.PREF.ID = CUSTOMER.ID
    QI.CustomerIdentification.QIPerformCustPrefCheck(DE.CUST.PREF.ID, MESSAGE.GROUP, CARRIER, TAX.RESIDENCE, US.ADDR.CONFLICT, COUNTRY.FIELD.DETS, '', '')
    
    IF US.ADDR.CONFLICT NE 'NO' THEN
        RETURN
    END
    
    QI.CustomerIdentification.QICheckAccountPreferences(CUSTOMER.ID, MESSAGE.GROUP, CARRIER, TAX.RESIDENCE, US.ADDR.CONFLICT, COUNTRY.FIELD.DETS, '', '')
    
    IF US.ADDR.CONFLICT NE 'NO' THEN
        RETURN
    END
    
    QI.CustomerIdentification.QICheckPortfolioPreferences(CUSTOMER.ID, MESSAGE.GROUP, CARRIER, TAX.RESIDENCE, US.ADDR.CONFLICT, COUNTRY.FIELD.DETS, '', '')

RETURN
*-----------------------------------------------------------------------------
END

