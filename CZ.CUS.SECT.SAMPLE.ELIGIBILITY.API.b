* @ValidationCode : MjoxMjQ4MDE4NTIzOkNwMTI1MjoxNTcwNzAxNzQ3ODIxOnN2YW1zaWtyaXNobmE6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA3LjIwMTkwNjEyLTAzMjE6LTE6LTE=
* @ValidationInfo : Timestamp         : 10 Oct 2019 15:32:27
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : svamsikrishna
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190612-0321
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE CZ.Framework
SUBROUTINE CZ.CUS.SECT.SAMPLE.ELIGIBILITY.API(CustActId, PartyRec, CdpEligibility, ErrorMsg)
*-----------------------------------------------------------------------------
**** <region name= Desc>
*** <desc>Describes the routine </desc>
*
* API to determine the Cdp Eligiblity of the customer for GDPR processing
* of the customer.
*
* @author : svamsikrishna@temenos.com
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
* 08/02/18 - DEFECT 2453937 / Task 2454072
*            New API introduced to allow eligibility for a specific sector
*            for GDPR processing
*
* 22/08/2019 - En 3247539 / Task 3247543
*            Changes done to determine the eligibility based on the PARTY.APPLICATION passed
*
* 19/09/19 - En 3191931 / Task 3191989
*            Removed the unwanted code
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
    PeChk = ''
    PartyId = FIELD(CustActId,"-",1)
    PartyAppln = "CUSTOMER"
    IF FIELD(CustActId,"-",2) THEN
        PartyAppln = FIELD(CustActId,"-",2)
    END
    

RETURN
*-----------------------------------------------------------------------------
PROCESS:
    IF PartyId AND PartyRec THEN
        BEGIN CASE
            CASE PartyAppln EQ "CUSTOMER"
                Residence = PartyRec<ST.Customer.Customer.EbCusResidence>
                CusSector = PartyRec<ST.Customer.Customer.EbCusSector>
            CASE PartyAppln EQ "PERSON.ENTITY"
                Residence = PartyRec<ST.Customer.PersonEntity.PerEntRegCountry>
                IF NOT(Residence) THEN
                    Residence = PartyRec<ST.Customer.PersonEntity.PerEntAddressCountry>
                END
                PeChk = 1
        END CASE
        IF Residence EQ 'EU' AND (CusSector EQ "1127" OR PeChk) THEN
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
