* @ValidationCode : Mjo4NTc3NDUzNjY6Q3AxMjUyOjE1MjIyMTk2NjQxNDY6c2NoYW5kaW5pOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDQuMjAxODAzMDgtMjAwNjoxMzoxMw==
* @ValidationInfo : Timestamp         : 28 Mar 2018 12:17:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : schandini
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 13/13 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201804.20180308-2006
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE CZ.Framework
SUBROUTINE CZ.CUS.SECT.SAMPLE2.ELIGIBILITY.API(CustomerId, CustomerRec, CdpEligibility, ErrorMsg)
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
        CdpEligibility = "YES"
    END ELSE
        ErrorMsg = "CZ-CUSTOMER.NOT.ELIGIBLE"
    END
RETURN
END
