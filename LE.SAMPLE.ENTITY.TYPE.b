* @ValidationCode : MjotMTg5MzI1NDE2NzpJU08tODg1OS0xOjE1NTk5MDg3MTE2Njc6c3ZhbXNpa3Jpc2huYTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA0LjIwMTkwNDEwLTAyMzk6Mzg6MjU=
* @ValidationInfo : Timestamp         : 07 Jun 2019 17:28:31
* @ValidationInfo : Encoding          : ISO-8859-1
* @ValidationInfo : User Name         : svamsikrishna
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 25/38 (65.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201904.20190410-0239
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE LE.Framework
SUBROUTINE LE.SAMPLE.ENTITY.TYPE(customerId, customerRec, entityType, errorMsg, reservedOne)
*-----------------------------------------------------------------------------
* Incoming Arguments:
*-----------------------------------------------------------------------------
* customerId        - Holds the customer id
* customerRec       - Holds the Customer record

*-----------------------------------------------------------------------------
* Outgoing Arguments:
*-----------------------------------------------------------------------------
* entityType        - Hold the entity type of the customer(LEI/NCI/SUB.FUND)
* errorMsg          - Holds the value of returned error
* reservedOne       - Reserved
*
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 20/03/19 - Defect 3040910 / Task 3044864
*            Entity types will be classified based on the Sector but not REL.CODE
*            of the Customer
*
*-----------------------------------------------------------------------------
    $USING ST.CustomerService
    $USING EB.SystemTables
    $USING ST.Customer
    $USING EB.SOAframework

    GOSUB initialise
    GOSUB determineEntityType

RETURN

initialise:
****************************
    CustError = ''
    IF customerId AND NOT(customerRec) THEN ;*if customer record is not passed
        EB.SOAframework.Checkserviceexists("CUSTOMER","getRecord",serviceName)
        IF serviceName THEN
            CALL @serviceName(customerId, customerRec) ;*get customer record
            IF EB.SystemTables.getEtext() THEN
                CustError = EB.SystemTables.getEtext()
                EB.SystemTables.setEtext('')
            END
        END ELSE
            customerRec = ST.Customer.Customer.Read(customerId, CustError) ;*if customer record is passed
        END
    END
    sector = customerRec<ST.Customer.Customer.EbCusSector> ;*Relation code present in customer record
    
RETURN

determineEntityType:
****************************
** Sector - 1000 to 1499 individual customers
** Sector 2000 to 2999 entity customers
    BEGIN CASE
    
        CASE sector GE '1000' AND sector LE '1499'
            entityType = 'NCI' ;*individual customers
    
        CASE sector GE '2000' AND sector LE '2999'
            IF EB.SystemTables.getApplication() EQ 'OC.CUSTOMER' THEN
                IF EB.SystemTables.getRNew(ST.Customer.OcCustomer.CusUmbrellaEntity) NE '' THEN
                    entityType = "SUB.FUND" ;*derivative customers
                END ELSE
                    entityType = "LEI"
                END
            END ELSE
                oCCustomerRec = ST.Customer.OcCustomer.Read(customerId, Error)
                IF oCCustomerRec<ST.Customer.OcCustomer.CusUmbrellaEntity> NE '' THEN
                    entityType = "SUB.FUND" ;*derivative customers
                END ELSE
                    entityType = "LEI"
                END
            END
        
    END CASE
    
RETURN
*--------------------------------------------------------------------------------------------
END
