* @ValidationCode : Mjo3ODQzOTk5MTg6Q3AxMjUyOjE1NjUxNTY3NTcwNTU6c3ZhbXNpa3Jpc2huYTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA3LjIwMTkwNjEyLTAzMjE6MzI6MjY=
* @ValidationInfo : Timestamp         : 07 Aug 2019 11:15:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : svamsikrishna
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 26/32 (81.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190612-0321
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE CZ.Framework
SUBROUTINE CZ.SAMPLE.ELIGIBILITY.API(CustActId, PartyRec, CdpEligibility, ErrorMsg)
*-----------------------------------------------------------------------------
**** <region name= Desc>
*** <desc>Describes the routine </desc>
*
* API to determine the Cdp Eligiblity of the customer for GDPR processing
* of the customer.
*
* @author : maparna@temenos.com
* @package: CZ.Framework
**** </region>
*-----------------------------------------------------------------------------
* Incoming Arguments:
*-----------------------------------------------------------------------------
* CustomerId        - Holds the CUSTOMER id
* CustomerRec       - Holds the CUSTOMER record
*
*-----------------------------------------------------------------------------
* Outgoing Arguments:
*-----------------------------------------------------------------------------
* CdpEligibility - Holds the value to determine the eligibility of the customer
*                  for GDPR processing
* ErrorMsg       - Error message if any
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 16/11/17 - Enhancement 2344173 / Task 2348258
*            New API introduced to determine the eligibility of the customer
*            for GDPR processing
*
* 06/08/19 - En 3247344 / Task 3247356
*			 Changes done to determine the eligibility based on the PARTY.APPLICATION passed
*
*-----------------------------------------------------------------------------
    $USING CZ.Framework
    $USING ST.Customer
    $USING EB.SystemTables
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    CdpEligibility = ''
    CusResidence = ''
    ErrorMsg = ''
    PartyId = FIELD(CustActId,"-",1)
    IF FIELD(CustActId,"-",2) THEN
        PartyAppln = FIELD(CustActId,"-",2)
    END ELSE
        PartyAppln = "CUSTOMER"
    END
    

RETURN
*-----------------------------------------------------------------------------
PROCESS:
    IF PartyId AND PartyRec THEN
        BEGIN CASE
            CASE PartyAppln EQ "CUSTOMER"
                Residence = PartyRec<ST.Customer.Customer.EbCusResidence>
            CASE PartyAppln EQ "PERSON.ENTITY"
                Residence = PartyRec<ST.Customer.PersonEntity.PerEntRegCountry>
                IF NOT(Residence) THEN
                    Residence = PartyRec<ST.Customer.PersonEntity.PerEntAddressCountry>
                END                
        END CASE
        IF Residence EQ 'EU' THEN
            CdpEligibility = "YES"
        END ELSE
            CdpEligibility = "NO"
        END
    END ELSE
        ErrorMsg = "CZ-CUSTOMER.NOT.ELIGIBLE"
    END

RETURN
*-----------------------------------------------------------------------------
END
