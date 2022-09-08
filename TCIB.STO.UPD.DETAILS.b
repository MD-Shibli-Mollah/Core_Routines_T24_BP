* @ValidationCode : Mjo5NjA1NDI2NDk6Q3AxMjUyOjE2MDgyMTQzMjgxNzY6c2NoYW5kaW5pOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMi4xOi0xOi0x
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
* <Rating>-82</Rating>
*-----------------------------------------------------------------------------
$PACKAGE T2.ModelBank
SUBROUTINE TCIB.STO.UPD.DETAILS
*-----------------------------------------------------------------------------
* Modification History:
*
* 10/03/15 - Defect_1274752 / Task_1278427
*            Unable to put payment for user defined transaction types
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
*
* 05/11/15 - Defect 1523105 / Task 1523352
*            Moved the application BENEFICIARY from FT to ST.
*            Hence Beneficiary application fields are referred using component BY.Payments
*
* 08/12/2020 - Enhancement 4020994 / Task 4037076
*              Changing BY.Payments reference to new component reference BY.Payments since
*              beneficiary and beneficiary links table has been moved to new module BY.
*-----------------------------------------------------------------------------
    $USING AC.AccountOpening
    $USING AC.StandingOrders
    $USING EB.SystemTables
    $USING BY.Payments

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
    STO.APP='FT'
    STO.ALL="ALL"
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>Get beneficiary details for process</desc>
PROCESS:
*------

    IF  EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoBeneficiaryId) THEN
        BEN.ID = EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoBeneficiaryId)
    END ELSE
        BEN.ID = EB.SystemTables.getComi()
    END
    GOSUB GET.BEN.DETAILS
RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.BEN.DETAILS>
*** <desc>Get Transaction details </desc>
GET.BEN.DETAILS:
*--------------
    R.BEN = BY.Payments.Beneficiary.Read(BEN.ID,READ.ERR)
    IF NOT(READ.ERR) THEN
        TRANS.TYPE = R.BEN<BY.Payments.Beneficiary.ArcBenTransactionType>
        EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoPayMethod, TRANS.TYPE)
        LINKED.BEN = R.BEN<BY.Payments.Beneficiary.ArcBenLinkToBeneficiary>
*
        IF LINKED.BEN NE '' THEN
            R.BENF = BY.Payments.Beneficiary.Read(LINKED.BEN,READ.ERR)
            TRANS.TYPE = R.BENF<BY.Payments.Beneficiary.ArcBenTransactionType>
            CREDIT.ACCT.NO = R.BENF<BY.Payments.Beneficiary.ArcBenBenAcctNo>
            EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoPayMethod, TRANS.TYPE)
            EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoCptyAcctNo, CREDIT.ACCT.NO)
        END
*
        BEGIN CASE
            CASE TRANS.TYPE[1,2] EQ 'OT'
                CCY.STO=EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoCurrency)
                EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoBeneficiary, R.BEN<BY.Payments.Beneficiary.ArcBenBenCustomer>)
                EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoBenAcctNo, R.BEN<BY.Payments.Beneficiary.ArcBenBenAcctNo>)
                EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoBenReference, R.BEN<BY.Payments.Beneficiary.ArcBenCustomerRef>)
                GOSUB UPDATE.STO.CPARTY
            CASE TRANS.TYPE[1,2] EQ 'BC'
                EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoPayMethod, R.BEN<BY.Payments.Beneficiary.ArcBenTransactionType>)
                EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoBankSortCode, R.BEN<BY.Payments.Beneficiary.ArcBenBankSortCode>)
                EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoBenAcctNo, R.BEN<BY.Payments.Beneficiary.ArcBenBenAcctNo>)
                EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoBeneficiary, R.BEN<BY.Payments.Beneficiary.ArcBenBenCustomer>)
                EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoBenReference, R.BEN<BY.Payments.Beneficiary.ArcBenCustomerRef>)
        END CASE

    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= UPDATE.STO.CPARTY>
*** <desc> check transaction type is available in Nostro account</desc>
UPDATE.STO.CPARTY:
*------------
    READ.NOSTRO = AC.AccountOpening.NostroAccount.Read(CCY.STO,NOSTRO.ERR)

    IF READ.NOSTRO THEN
        LOCATE STO.APP IN READ.NOSTRO<AC.AccountOpening.NostroAccount.EbNosApplication,1> SETTING POS THEN
            GOSUB READ.STO.TXN.CHK
        END ELSE
            POS=''
            LOCATE STO.ALL IN READ.NOSTRO<AC.AccountOpening.NostroAccount.EbNosApplication,1> SETTING POS THEN
                GOSUB READ.STO.TXN.CHK
            END

        END

    END

RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= READ.STO.TXN.CHK>
*** <desc> check transaction type is available in Nostro account </desc>
READ.STO.TXN.CHK:
*---------------------
    POS1=''
    LOCATE TRANS.TYPE IN READ.NOSTRO<AC.AccountOpening.NostroAccount.EbNosApplication,POS> SETTING POS1 THEN
        C.PARTY.ACC=READ.NOSTRO<AC.AccountOpening.NostroAccount.EbNosAccount,POS,POS1>
        GOSUB READ.STO.TXN.COND
    END ELSE
        C.PARTY.ACC=READ.NOSTRO<AC.AccountOpening.NostroAccount.EbNosAccount,POS,1>
        GOSUB READ.STO.TXN.COND
    END

RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= READ.STO.TXN.COND>
*** <desc> Update CPARTY ACCT NO for OT types</desc>
READ.STO.TXN.COND:
*------------

    IF C.PARTY.ACC THEN
        EB.SystemTables.setRNew(AC.StandingOrders.StandingOrder.StoCptyAcctNo, C.PARTY.ACC)
    END
RETURN

*
*** </region>
*---------------------------------------------------------
END
