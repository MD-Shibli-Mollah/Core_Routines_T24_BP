* @ValidationCode : MjotMTA3MzEzMTM3OTpDcDEyNTI6MTQ4MzQ0NDMxMDIxODpqZXlhbGF2YW55YWo6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTcwMS4yMDE2MTIyNi0wMTE3OjQ2OjQz
* @ValidationInfo : Timestamp         : 03 Jan 2017 17:21:50
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jeyalavanyaj
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 43/46 (93.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201701.20161226-0117
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* <Rating>1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T2.ModelBank
    SUBROUTINE TCIB.STO.NOSTRO.ACCT.UPDATE
*-----------------------------------------------------------------------------
* Subroutine to get the account number from a beneficiary record
* 27/06/13 - Enhancement 590517
*            TCIB Product
*
* 10/03/15 - Defect_1274752 / Task_1278427
*            Unable to put payment for user defined transaction types
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*            Incorporation of T components
*
* 06/07/16 - Defect 1785146 / Task 1787054
*            TCIB _ Logic to update RECEIVER.BANK in STANDING.ORDER application is not correct

* 30/12/16 - Defect 1966334 / Task 1968516
*            Standing orders created by TCIB users have the wrong nostro account
*-----------------------------------------------------------------------------
    $USING AC.AccountOpening
    $USING AC.StandingOrders
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INITIALISE:
*---------

    STO.APP = "FT"
    STO.ALL = "ALL"
    READ.NOSTRO = ''
    NOSTRO.TXN.TYPE = ''
    C.PARTY.ACC = ''

    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*------
*

    BIC.CODE = EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoAcctWithBank)
    TRANS.TYPE = EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoPayMethod)
    CCY.STO = EB.SystemTables.getRNew(AC.StandingOrders.StandingOrder.StoCurrency)
*
    IF CCY.STO EQ '' THEN
        CCY.STO = EB.SystemTables.getComi()
    END

    GOSUB UPDATE.STO.CPARTY


    RETURN
*
*------------------------------------------------------------------------------
UPDATE.STO.CPARTY:
*-----------------
*
    IF (TRANS.TYPE[1,2] EQ 'OT') OR (TRANS.TYPE[1,2] EQ 'BC') THEN
        READ.NOSTRO = AC.AccountOpening.NostroAccount.Read(CCY.STO,NOSTRO.ERR)
        IF READ.NOSTRO THEN
            GOSUB GET.NOSTRO.ACCT
        END
    END

    RETURN
*
*-----------------------------------------------------------------------------
*** <region name= GET.NOSTRO.ACCT>
*** <desc> Get nostro account based on transaction type</desc>
GET.NOSTRO.ACCT:
*--------------
*
    LOCATE STO.APP IN READ.NOSTRO<AC.AccountOpening.NostroAccount.EbNosApplication,1> SETTING POS THEN
    NOSTRO.TXN.TYPE=READ.NOSTRO<AC.AccountOpening.NostroAccount.EbNosTxnType,POS>           ;*Reading type of STO
    IF NOSTRO.TXN.TYPE NE '' THEN
        LOCATE TRANS.TYPE IN NOSTRO.TXN.TYPE<1,1,1> SETTING TYPEPOS THEN
        C.PARTY.ACC=READ.NOSTRO<AC.AccountOpening.NostroAccount.EbNosAccount,POS,TYPEPOS>
    END
    END ELSE
    C.PARTY.ACC=READ.NOSTRO<AC.AccountOpening.NostroAccount.EbNosAccount,POS,1>
    END
    END

    IF C.PARTY.ACC EQ '' THEN
        POS=''
        LOCATE STO.ALL IN READ.NOSTRO<AC.AccountOpening.NostroAccount.EbNosApplication,1> SETTING POS THEN
        C.PARTY.ACC=READ.NOSTRO<AC.AccountOpening.NostroAccount.EbNosAccount,POS,1>
    END
    END

    GOSUB READ.STO.TXN.COND

    RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= READ.STO.TXN.COND>
*** <desc> Update cparty account for OT</desc>
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
