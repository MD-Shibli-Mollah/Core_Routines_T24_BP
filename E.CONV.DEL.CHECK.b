* @ValidationCode : MjotMjAyMDUyMzU4ODpDcDEyNTI6MTQ5ODEyODg3NTI3OTphcmNoYW5hcmFnaGF2aTotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzA0LjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 22 Jun 2017 16:24:35
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
* <Rating>-28</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.ModelBank

    SUBROUTINE E.CONV.DEL.CHECK
*-----------------------------------------------------------------------------
* Description   :
* A new routine (E.CONV.DEL.CHECK) has been introduced to Show a icon for the customer
* if he has an deliquent Account.This new routine is called from an existing enquiry (CUSTOMER.DETAILS.SCV).
*----------------------------------------------------------------------------------------------------------
********            MODIFICATION HISTORY            **********
*
* 24/11/14 - Defect 1171847/ Task 1178814
*            System should not shows the delinquent icon for the Customers those have not Accounts.
*
* 23/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 02/05/17 - Enhancement 1765879 / Task 2106068
*            Routine is not processed if AC product is not installed in the current company
*
*--------------------------------------------------------------------------------------------------------------------
    $USING EB.Reports
    $USING AC.AccountOpening
    $USING EB.API

    GOSUB INIT

    acInstalled = ''
    EB.API.ProductIsInCompany('AC', acInstalled)

    IF NOT(acInstalled) THEN
        RETURN ;* Return O.DATA with null value , so that delinquent icon is not shown.
    END

    GOSUB PROCESS
    
    RETURN
*-----------------------------------------------------------------------------

INIT:

    CUSTOMER.ID = EB.Reports.getOData()
    EB.Reports.setOData('')
    R.ACCOUNT = ''

    RETURN
*-----------------------------------------------------------------------------

PROCESS:

    R.ACC = AC.AccountOpening.tableCustomerAccount(CUSTOMER.ID,ACC.ERR)
    NO.OF.REC=DCOUNT(R.ACC,@FM)

    FOR ACC.CNT=1 TO NO.OF.REC
        AC.ID=FIELD(R.ACC,@FM,ACC.CNT)
        R.ACCOUNT = AC.AccountOpening.tableAccount(AC.ID,ACCOUNT.ERR)
        CHK = R.ACCOUNT<AC.AccountOpening.Account.OverdueStatus>
        IF CHK = 'DEL' THEN
            EB.Reports.setOData(1)
            RETURN
        END ELSE
            EB.Reports.setOData('')
        END
    NEXT ACC.CNT

    RETURN
*-----------------------------------------------------------------------------

    END
