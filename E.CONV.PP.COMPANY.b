* @ValidationCode : MjotNTMxNjA1ODY2OkNwMTI1MjoxNDkwMTgyNzY3NTAwOmdtYW1hdGhhOjE6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzAzLjIwMTcwMzA5LTAxNDE6NDo0
* @ValidationInfo : Timestamp         : 22 Mar 2017 17:09:27
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : gmamatha
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 4/4 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201703.20170309-0141
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE AC.ModelBank
    
    SUBROUTINE E.CONV.PP.COMPANY
*--------------------------------------------------------------------------------
*
*------------------------------------------------------------------------------
* Modification History :
*24/02/17   - Task 1984155
*             TPS - Payments: Ability to drilldown to TPS from any Statement enquiry/statement.
*             To view the payment details for the transaction reference number of statement entry details.
*-----------------------------------------------------------------------------
* This routine is used to view the payment details with input as transaction reference from
* where we are reading first three characters to get company id.

    $USING EB.Reports
*-----------------------------------------------------------------------------

    ENTRY.REF = EB.Reports.getOData()
    OUT.PP.COMPANY = ENTRY.REF[1,3]
    
    EB.Reports.setOData(OUT.PP.COMPANY)

    RETURN
*--------------------------------------------------------------------
END
