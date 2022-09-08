* @ValidationCode : MjotODYzNTg5MTgzOkNwMTI1MjoxNTM4MDM5NjgyMDg3OnZyYWphbGFrc2htaToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxODA3LjIwMTgwNjIxLTAyMjE6MjI6MTI=
* @ValidationInfo : Timestamp         : 27 Sep 2018 14:44:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vrajalakshmi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 12/22 (54.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201807.20180621-0221
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE LE.Framework
SUBROUTINE LE.SAMPLE.PARTY.ELG(customerId, customerRec, eligibility, errorMsg, reservedOne)
*-----------------------------------------------------------------------------
* Incoming Arguments:
*-----------------------------------------------------------------------------
* customerId        - Holds the customer id
* customerRec       - Holds the Customer record

*-----------------------------------------------------------------------------
* Outgoing Arguments:
*-----------------------------------------------------------------------------
* eligibility       - Holds the eligibility for the customer(YES/NO)
* errorMsg          - Holds the value of returned error
* reservedOne       - Reserved
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING ST.CustomerService
    $USING EB.SystemTables
    $USING ST.Customer
    $USING EB.SOAframework

    GOSUB initialise
    GOSUB determineEligibility

RETURN

initialise:
    
    eligibility = 'NO'
    CustError = ''
    IF customerId AND NOT(customerRec) THEN ;*if customer record is not passed
        EB.SOAframework.Checkserviceexists("CUSTOMER","getRecord",serviceName)
        IF serviceName THEN
            CALL @serviceName(customerId, customerRec) ;*fetch customer record
            IF EB.SystemTables.getEtext() THEN
                CustError = EB.SystemTables.getEtext()
                EB.SystemTables.setEtext('')
            END 
        END ELSE
            customerRec = ST.Customer.Customer.Read(customerId, CustError) ;*read customer record if passed
        END
    END
    
RETURN

determineEligibility:
    
    IF customerRec<ST.Customer.Customer.EbCusResidence> EQ "EU" THEN
        eligibility = "YES" ;*customers with residence EU are set eligible
    END
        
RETURN

END
