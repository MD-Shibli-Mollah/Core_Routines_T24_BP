* @ValidationCode : Mjo4NTgyMzQyMjE6Q3AxMjUyOjE2MDgyMTQzMjgxOTE6c2NoYW5kaW5pOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMi4xOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Dec 2020 19:42:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : schandini
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-54</Rating>
*-----------------------------------------------------------------------------
$PACKAGE T2.ModelBank
SUBROUTINE TCIB.UTILITY.TXN.TYPE
*-----------------------------------------------------------------------------
* Subroutine to get the transaction type from a beneficiary record
*
*-----------------------------------------------------------------------------
* *** <region name= Modification History>
*** <desc>Changes done in the sub-routine </desc>
*
* Modification History:
*---------------------
* 27/06/13 - Enhancement 590517
*            TCIB Retail
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
*
* 05/11/15 - Defect 1523105 / Task 1523352
*           Moved the application BENEFICIARY from FT to ST.
*           Hence Beneficiary application fields are referred using component BY.Payments
*
* 08/12/2020 - Enhancement 4020994 / Task 4037076
*              Changing BY.Payments reference to new component reference BY.Payments since
*              beneficiary and beneficiary links table has been moved to new module BY.
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts
    $USING EB.SystemTables
    $USING BY.Payments
    $USING FT.Contract

*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>

    GOSUB INITIALISE
    GOSUB PROCESS

*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise commons and do OPF </desc>
INITIALISE:
*---------
    BEN.ID = ''
    TRANS.TYPE= ''
    ACCT.NO = ''
    CUST.ID = ''
RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>Get beneficiary details for process</desc>
PROCESS:
*------
    IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BeneficiaryId) THEN
        BEN.ID = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.BeneficiaryId)
    END ELSE
        BEN.ID = EB.SystemTables.getComi()
    END

    GOSUB GET.BEN.DETAILS
RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.BEN.DETAILS>
*** <desc>Get beneficiary details </desc>
GET.BEN.DETAILS:
*--------------
    R.BEN = BY.Payments.Beneficiary.Read(BEN.ID,READ.ERR)
    IF NOT(READ.ERR) THEN
        TRANS.TYPE = R.BEN<BY.Payments.Beneficiary.ArcBenTransactionType>        ;* Get transaction type from the customer
        CUST.ID = R.BEN<BY.Payments.Beneficiary.ArcBenOwningCustomer>  ;* Get owning customer of the beneficiary
        LINKED.BEN = R.BEN<BY.Payments.Beneficiary.ArcBenLinkToBeneficiary>     ;* Get linked beneficiary if specified

        IF LINKED.BEN NE '' THEN
            R.BEN =BY.Payments.Beneficiary.Read(LINKED.BEN,READ.ERR)
            TRANS.TYPE = R.BEN<BY.Payments.Beneficiary.ArcBenTransactionType>
            CREDIT.ACCT.NO = R.BEN<BY.Payments.Beneficiary.ArcBenBenAcctNo>
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.TransactionType, TRANS.TYPE)
            EB.SystemTables.setRNew(FT.Contract.FundsTransfer.CreditAcctNo, CREDIT.ACCT.NO)
        END
    END
RETURN

*** </region>
*---------------------------------------------------------
END
