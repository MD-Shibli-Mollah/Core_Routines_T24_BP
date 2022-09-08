* @ValidationCode : MjoyMTA3NDgzOTk3OmNwMTI1MjoxNTk5NjM5MjE3MzE4OnNhaWt1bWFyLm1ha2tlbmE6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6LTE6LTE=
* @ValidationInfo : Timestamp         : 09 Sep 2020 13:43:37
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PV.Config

SUBROUTINE PV.IFRS.EAD.CALC.EXTERNAL.API(CONTRACT.ID, CUSTOMER.ID, CATEGORY.ID, R.ECB, R.EB.CASHFLOW.REC, IFRS.ACCT.BALANCES, EXPOSURE.AT.DEFAULT)
*-----------------------------------------------------------------------------
*
* Hook routine to determine the Exposure At Default.
*
* @param        CONTRACT.ID(incoming)       -  Contract id
* @param        CUSTOMER.ID(incoming)       -  Customer id
* @param        CATEGORY.ID(incoming)       -  CATEGORY id
* @param        R.ECB(incoming)             -  EB.CONTRACT.BALANCE Record
* @param        R.EB.CASHFLOW.REC(incoming) -  EB.CASHFLOW Record
* @param        IFRS.ACCT.BALANCES(incoming)-  IFRS.ACCT.BALANCES Record
*
*
* @param        EXPOSURE.AT.DEFAULT(Outgoing) - Exposure At Default
*              (Balance amount upon which provision is calculated)

*
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 21/08/18 - Enhancement 2707789 / Task 2708086
*            Local routine to calculate Exposure at default
*
*
* 09/09/20 - Enhancement 3932648 / Task 3952625
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*-----------------------------------------------------------------------------

    $USING AC.IFRS
    $USING IA.Config
    $USING BF.ConBalanceUpdates
    $USING EB.SystemTables
    $USING EB.Utility
    $USING RE.Consolidation
    $USING AC.SoftAccounting


    

    GOSUB INITIALISE ;* Initialise the required variables
    GOSUB GET.IFRS.BALANCE ;* To get the NPV of the contractual cashflow

RETURN

***<region name= GET.IFRS.BALANCE>
GET.IFRS.BALANCE:
*** <desc> to get the NPV of the contractual cashflow </desc>

    IF IFRS.ACCT.BALANCES THEN

        BEGIN CASE
            CASE IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalNpvConCfFv>

*when it is valued under Fairvalue, NPV.CON.CF.FV will have the value
                IFRS.BALANCE = IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalNpvConCfFv>

            CASE IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalNpvConCfAmort>

*when it is valued under amortised, NPV.CON.CF.AMORT will have the value
                IFRS.BALANCE = IFRS.ACCT.BALANCES<IA.Config.IfrsAcctBalances.IfrsAcctBalNpvConCfAmort>
        END CASE

    END ELSE
        GOSUB GET.CONTRACT.BALANCE ;* If IFRS.ACCT.BALANCES does not exist, try to get from ECB
    END

    EXPOSURE.AT.DEFAULT = IFRS.BALANCE*(10/100) ;*10 PERCENT applied to IFRS.BALANCE(Sample EAD Calculation)

RETURN
***</region>
*-----------------------------------------------------------------------------
***<region name= GET.T24.BALANCE>
GET.CONTRACT.BALANCE:
*--------------------
*Get the balance from ECB

    CONTINGENT.TYPES = ""
    RE.Consolidation.Types("ALL.C", CONTINGENT.TYPES)

    SOFT.TYPES = ""
    AC.SoftAccounting.GetBalanceType(SOFT.TYPES)
    CONVERT " " TO @FM IN SOFT.TYPES

    GOSUB GET.T24.BALANCE
    IFRS.BALANCE = T24.POSTED.AMT

RETURN
***</region>
*-----------------------------------------------------------------------------
***<region name= GET.T24.BALANCE>
GET.T24.BALANCE:
*--------------

    CURR.ASST.TYPE = ""
    T24.POSTED.AMT = 0
    ECB.ASSET.TYPES = R.ECB<BF.ConBalanceUpdates.EbContractBalances.EcbTypeSysdate>
    NO.OF.ECB.TYPES = DCOUNT(ECB.ASSET.TYPES,@VM)

* Loop each asset type and see if they are non IF.
* add the non IF to get the T24.POSTED.AMT

    FOR ASST.CNT = 1 TO NO.OF.ECB.TYPES
        CURR.ASST.TYPE = FIELD(ECB.ASSET.TYPES<1,ASST.CNT>,'-',1)
        CURR.SYS.DATE = FIELD(ECB.ASSET.TYPES<1,ASST.CNT>,'-',2)
        IF CURR.SYS.DATE NE '' AND CURR.SYS.DATE GT EB.SystemTables.getRDates(EB.Utility.Dates.DatPeriodEnd) THEN
            CONTINUE
        END
        IF CURR.ASST.TYPE[2] EQ 'BL' OR INDEX(CURR.ASST.TYPE,'*',1) THEN
            CONTINUE
        END
        LOCATE CURR.ASST.TYPE IN CONTINGENT.TYPES SETTING CONT.POS THEN
            CONTINUE
        END
        LOCATE CURR.ASST.TYPE IN SOFT.TYPES SETTING SOFT.POS THEN
            IF SOFT.TYPES<SOFT.POS+2> EQ 'C' OR SOFT.TYPES<SOFT.POS+2> EQ 'c' THEN
                CONTINUE
            END
        END
        T24.POSTED.AMT += SUM(R.ECB<BF.ConBalanceUpdates.EbContractBalances.EcbOpenBalance,ASST.CNT>) + SUM(R.ECB<BF.ConBalanceUpdates.EbContractBalances.EcbCreditMvmt,ASST.CNT>) + SUM(R.ECB<BF.ConBalanceUpdates.EbContractBalances.EcbDebitMvmt,ASST.CNT>)
    NEXT ASST.CNT

RETURN
***</region>

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> Initialise the required variables </desc>
    
    EXPOSURE.AT.DEFAULT = 0
    IFRS.BALANCE = 0

RETURN
*** </region>

END

