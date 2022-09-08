* @ValidationCode : MjoxNTI3Mjg3MTE3OkNwMTI1MjoxNTQyMzUyOTc0NjQ2OnNoYW5rYXJ2OjE6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxODExLjIwMTgxMDIyLTE0MDY6MTA6MTA=
* @ValidationInfo : Timestamp         : 16 Nov 2018 12:52:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : shankarv
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 10/10 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE DE.ModelBank
SUBROUTINE E.CONV.SWIFT.BIC.CUST
*-----------------------------------------------------------------------------
*@author : shankarv@temenos.com
*Model Conversion routine to get Customer ID for a given SWIFT BIC code.
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*14/11/2018 -  Enhancement /Task
*            New Template for STOP.REQUEST.STATUS as part of introducing functionality
*            for inward MT112 advice message.
*            Conversion routine to get Customer ID for a given SWIFT BIC code.
*
*-----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>
    $USING EB.SystemTables
    $USING DE.API
    $USING EB.Reports
*** </region>
*-----------------------------------------------------------------------------
    companyId = ''
    custId = ''
    bicCode = EB.Reports.getOData()
*   Call API routine to fetch customer from Swift Bic code and append to input BIC.CUST
    IF bicCode NE '' THEN
        companyId = EB.SystemTables.getIdCompany()
        DE.API.SwiftBic(bicCode,companyId,custId)
        IF custId NE '' THEN
            EB.Reports.setOData(custId)
        END
    END
*-----------------------------------------------------------------------------
END
