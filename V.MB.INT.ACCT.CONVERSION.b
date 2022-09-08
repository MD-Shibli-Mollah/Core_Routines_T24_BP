* @ValidationCode : MjoxMDczNzg3NzI5OmNwMTI1MjoxNDg2NTUxMTg2NDI4OmhhcmlzaHZlbnVnb3BhbDoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxNzAyLjIwMTcwMTI4LTAxMzk6MzA6MzA=
* @ValidationInfo : Timestamp         : 08 Feb 2017 16:23:06
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : harishvenugopal
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 30/30 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.20170128-0139
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-9</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.ModelBank

    SUBROUTINE V.MB.INT.ACCT.CONVERSION

*************
*Description:
*************
*       This routine is attached in the CHECK.REC.RTN field of version records,
*to default the internal account based on the logged in company.
*
* If the R.Company for the value is Book EQ "1" - then it should be suffixed with appropriate Sub Division Code
* otherwise no suffix is required, to default the internal account number.

**
* 10/05/16 - Enhancement 1499014
*          - Task 1626129
*          - Routine incorporated
*
* 08/02/17 - Defect - 2004858 / Task - 2011985
*            Do not add the sub-division code when it is already available in the account number
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING ST.CompanyCreation

    COM.CURRENCY = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCurrency)         ;* To get the Logged in company currency from R.COMPANY common Variable.
    COM.BOOK = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComBook)                       ;* To get the Logged in company Book from R.COMPANY common Variable.
    COM.SUB.CODE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComSubDivisionCode)      ;* To get the Logged in company Sub Division Code from R.COMPANY common Variable.
    SAVE.COM.SUB.CODE = COM.SUB.CODE ;* Store it for later usage

    ARRAY.CNT = EB.SystemTables.getV() - 9         ;* Total Array count  - Audit fields.

*Internal Account format will be CURRENCY : CATEGORY : ACCOUNT NUMBER.
*And Internal Account category will be range from 10000 to 19999

    ACC = 'USD1'

    FOR I = 1 TO  ARRAY.CNT   ;* Loop for searching the Internal account in each array.
        REC.VERSION = EB.SystemTables.getRNew(I)
        F.CHAR = REC.VERSION[1,4]
        L.CHAR = REC.VERSION[4,99]

* Comparing the "USD1" to the first four characters of the Internal Account.
* Once condition satisfied, concat the logged in company local currency : L.CHAR and append it to R.NEW variable.

        IF ACC EQ F.CHAR THEN
            CHANGE.ACC = COM.CURRENCY:L.CHAR
            IF COM.BOOK EQ 1 THEN
                GOSUB checkSubDivisionCode ;* Check for the valid sub division code being entered by user
                CHANGE.ACC = CHANGE.ACC:COM.SUB.CODE
            END
            EB.SystemTables.setRNew(I, CHANGE.ACC)
        END
    NEXT I

    RETURN
*-----------------------------------------------------------------------------
*** <region name= checkSubDivisionCode>
checkSubDivisionCode:
*** <desc>Check for the valid sub division code being entered by user </desc>

    IF LEN(REC.VERSION) EQ 16 THEN
        accountSubDivisionCode = RIGHT(REC.VERSION,4) ;* Last 4 digits from the entered value
        IF (accountSubDivisionCode + 0) THEN
            COM.SUB.CODE = "" ;* We already have the value entered by the user, so dont bother updating it again
        END ELSE
            COM.SUB.CODE = SAVE.COM.SUB.CODE ;* Restore original value for this field
            CHANGE.ACC = CHANGE.ACC[1,12] ;* Retain only the leading 12 digits 
        END
    END
    
    RETURN
*** </region>

    END

