* @ValidationCode : MjotNzM1NTY4MjY0OkNwMTI1MjoxNjA5OTIwODY5OTE0OmFubmFwdXJuYWQ6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDExLjIwMjAxMDI5LTE3NTQ6LTE6LTE=
* @ValidationInfo : Timestamp         : 06 Jan 2021 13:44:29
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : annapurnad
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-55</Rating>
*-----------------------------------------------------------------------------
$PACKAGE PV.Config
SUBROUTINE PV.IFRS.CCF.CUT.OFF.CALC.API(CONTRACT.ID, BAL.TYPE, R.ECB, RESERVED.IN1, RESERVED.IN2, BALANCE.AMOUNT, RESERVED.OUT)
*-----------------------------------------------------------------------------
*
* Hook routine to determine the Exposure At Default.
*
* @param        CONTRACT.ID(incoming)       - ID of the contract
* @param        BAL.TYPE(incoming)          -
* @param        R.ECB(incoming)             - ECB record of the contract
* @param        RESERVED.IN1(incoming)      - Reserved Param
* @param        RESERVED.IN2(incoming)      - Reserved Param
*
* @param        BALANCE.AMOUNT(Outgoing)    - Balance Amount with CCF.CUT.OFF fator applied
*              (Balance amount upon which CCF.CUT.OFF factor is applied)
* @param        RESERVED.OUT(Outgoing)      - Reserved Param
*
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 11/12/18 - Enhancement 2890185 / Task 2890205
*            Local routine to return Balance Amount with CCF.CUT.OFF factor
*
* 08/09/20 - Enhancement 3932648 / Task 3952625
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*
* 1/1/21  - Task
*           Using API for getting undrawn commitment amount with cut off
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING EB.Utility
    $USING BF.ConBalanceUpdates

    GOSUB INITIALISE          ;* Initialise the required variables
    GOSUB GET.BALANCE    ;* To get the NPV of the contractual cashflow

RETURN
*-----------------------------------------------------------------------------
***<region name= GET.BALANCE>
GET.BALANCE:
*** <desc> to get the NPV of the contractual cashflow </desc>

    BF.ConBalanceUpdates.AcGetEcbBalance(CONTRACT.ID,BAL.TYPE,'',BALANCE.DATE,BALANCE.AMOUNT,'') ;* CCF.CUT.OFF factor is applied only to the Contingent Asset Types

RETURN
***</region>
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> Initialise the required variables </desc>

    BAL.TYPE<1> = "CURLOANTERMAMOUNT"
    BALANCE.DATE = EB.SystemTables.getRDates(EB.Utility.Dates.DatPeriodEnd)
    BALANCE.AMOUNT = 0

RETURN
*** </region>
*-----------------------------------------------------------------------------

END

