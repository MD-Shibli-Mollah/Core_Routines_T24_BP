* @ValidationCode : Mjo1MTczMTIxODA6Q3AxMjUyOjE1MjIyOTU3NjU5OTM6c2NoYW5kaW5pOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDQuMjAxODAzMDgtMjAwNjoxOToxOQ==
* @ValidationInfo : Timestamp         : 29 Mar 2018 09:26:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : schandini
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 19/19 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201804.20180308-2006
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE CZ.Framework
SUBROUTINE CZ.CUS.SECT.SAMPLE1.ELIGIBILITY.API(CustomerId, CustomerRec, CdpEligibility, ErrorMsg)
    $USING CZ.Framework
    $USING ST.Customer
    $USING EB.SystemTables
**** <region name= Desc>
*** <desc>Describes the routine </desc>
*
* API to determine the Cdp Eligiblity of the customer for GDPR processing
* of the customer.
*
* @author : schandini@temenos.com
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
*-----------------------------------------------------------------------------
*
* 28/03/2018 - Defect 2479345 / Task 2525741
*              To test the API for customer eligibility
*
*-----------------------------------------------------------------------------
    GOSUB INITIALISE
    GOSUB PROCESS
RETURN
INITIALISE:
    CdpEligibility = ''
    CusResidence = ''
    ErrorMsg = ''
RETURN
PROCESS:
    IF CustomerId AND CustomerRec THEN
        CusResidence = CustomerRec<ST.Customer.Customer.EbCusResidence>
        CusSector = CustomerRec<ST.Customer.Customer.EbCusSector>
        IF (CusResidence EQ 'FR' OR CusResidence EQ 'DE') AND CusSector EQ '1000' THEN
            CdpEligibility = "YES"
        END ELSE
            CdpEligibility = "NO"
        END
    END ELSE
        ErrorMsg = "CZ-CUSTOMER.NOT.ELIGIBLE"
    END
RETURN
END
