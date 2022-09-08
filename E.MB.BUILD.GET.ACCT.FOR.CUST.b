* @ValidationCode : MjoxNDY4MjE1ODg0OkNwMTI1MjoxNDk4MTI4ODcxODY3OmFyY2hhbmFyYWdoYXZpOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDQuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 22 Jun 2017 16:24:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : archanaraghavi
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201704.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
$PACKAGE ST.ModelBank

SUBROUTINE E.MB.BUILD.GET.ACCT.FOR.CUST(ENQ.DATA)
*-----------------------------------------------------------------------------
* MODIFICATIONS
*
* 23/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 02/05/17 - Enhancement 1765879 / Task 2106068
*            Routine is not processed if AC product is not installed in the current company
*
*-----------------------------------------------------------------------------

    $USING AC.AccountOpening
    $USING EB.API
    $USING EB.Reports
    
    acInstalled = ''
    EB.API.ProductIsInCompany('AC', acInstalled)
    
    IF NOT(acInstalled) THEN
        EB.Reports.setEnqError('EB-PRODUCT.NOT.INSTALLED':@FM:"AC")
        RETURN
    END

    ACCOUNT.LIST = ""
    NO.OF.ACCTS = ""
    SEL.ERR = ""

    CUSTOMER.NUMBER = ENQ.DATA<4,1>

* Replaced the select on account with customer number to read the Customer account to improve performance
    ACCOUNT.LIST = AC.AccountOpening.tableCustomerAccount(CUSTOMER.NUMBER, ERR)
    NO.OF.ACCTS = DCOUNT(ACCOUNT.LIST, @FM)

    IF NO.OF.ACCTS>1 THEN
        ENQ.DATA<2,1> = "ACCOUNT"
        ENQ.DATA<3,1> = "EQ"
        CHANGE @FM TO ' ' IN ACCOUNT.LIST
        ENQ.DATA<4,1> = ACCOUNT.LIST
    END

RETURN
*-----------------------------------------------------------------------------
END
