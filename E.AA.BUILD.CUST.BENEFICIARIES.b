* @ValidationCode : MjotMTc1Njk2MTU1MTpDcDEyNTI6MTQ4OTU4NjgzNzU2MTptamVuc2VuOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDMuMjAxNzAyMjItMDEzNToxMDoxMA==
* @ValidationInfo : Timestamp         : 15 Mar 2017 15:07:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mjensen
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 10/10 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201703.20170222-0135
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.BUILD.CUST.BENEFICIARIES(SELECTION.CRITERIA)
*-----------------------------------------------------------------------------
* Incoming        : SELECTION.CRITERIA

* Outgoing        : SELECTION.CRITERIA modified

* Attached to     : AA.CUSTOMER.BENEFICIARIES

* Attached as     : Build Routine in the Field BUILD.ROUTINE

* Primary Purpose : To modify selecting criteria to select only
*                   the beneficiaries which are owned by the current customer

* Author          : mjensen@temenos.com

*-----------------------------------------------------------------------------
* Modification History
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING EB.Browser
    
    CurrentCustomer = EB.Browser.SystemGetvariable('CURRENT.CUSTOMER')
    
    IF CurrentCustomer EQ 'CURRENT.CUSTOMER' THEN   ;* If common variable is not available
       CurrentCustomer = ''                         ;* Reset local variable
    END

;* Only modify the search criteria if no user input and current customer is available
    IF  SELECTION.CRITERIA<2,1> EQ '' AND CurrentCustomer NE '' THEN
        SELECTION.CRITERIA<2,-1> = 'OWNING.CUSTOMER'
        SELECTION.CRITERIA<3,-1> = 'EQ'
        SELECTION.CRITERIA<4,-1> = CurrentCustomer
    END
    RETURN

    END
