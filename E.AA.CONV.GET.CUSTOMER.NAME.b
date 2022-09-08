* @ValidationCode : MjotMjY4MDM4MDgxOkNwMTI1MjoxNjA5MjQ1MzE3OTgzOm1qZWJhcmFqOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMTIuMjAyMDExMTEtMTIxMDo1OjU=
* @ValidationInfo : Timestamp         : 29 Dec 2020 18:05:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mjebaraj
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 5/5 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201111-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.CONV.GET.CUSTOMER.NAME
*-----------------------------------------------------------------------------
**** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
*
*** Conversion routine to get customer's short name of the customer
*
*** </region>
*-----------------------------------------------------------------------------
* @uses         : MDLPTY.Party.getCustomerShortNames
* @access       : private
* @stereotype   : subroutine
* @author       : gayathrik@temenos.com
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History :
*
* 11/12/20 - Enhancement : 3930802
*            Task        : 3930805
*            Conversion routine to get the customer short name of the customer
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING EB.Reports
    $USING MDLPTY.Party
    
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    CustomerId = EB.Reports.getOData()    ;* Get customer id

    RCustomer = MDLPTY.Party.getCustomerShortNames(CustomerId)    ;* Get customer record of the customer
    CustomerShortName = RCustomer<MDLPTY.Party.CustomerShortNames.customerName>    ;* Get customer's short name from customer record
    EB.Reports.setOData(CustomerShortName)     ;* Set customer's short name

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
