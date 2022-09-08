* @ValidationCode : Mjo2MzA3MzQ1MTc6Y3AxMjUyOjE1OTk2MzkyMTc1Mzc6c2Fpa3VtYXIubWFra2VuYTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTotMTotMQ==
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
SUBROUTINE PV.STD.EAD.CALC.EXTERNAL.API(CONTRACT.ID, CUSTOMER.ID, CATEGORY.ID, R.ECB, R.EB.CASHFLOW.REC, IFRS.ACCT.BALANCES, EXPOSURE.AT.DEFAULT)
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
* 08/09/20 - Enhancement 3932648 / Task 3952625
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*-----------------------------------------------------------------------------

    $USING BF.ConBalanceUpdates
    $USING AC.IFRS
    $USING EB.SystemTables
    $USING EB.Utility

    
    GOSUB INITIALISE ;* Initialse the required variable

    BF.ConBalanceUpdates.AcGetEcbBalance(CONTRACT.ID,BAL.TYPE,'',BALANCE.DATE,BALANCE.AMOUNT,'')
    
    EXPOSURE.AT.DEFAULT = BALANCE.AMOUNT*(10/100) ;*10 PERCENT applied to TOTAL Balance(Sample EAD Calculation)

RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> Initialse the required variable </desc>

    EXPOSURE.AT.DEFAULT = 0
    BAL.TYPE = "ACACCBAL"
    BALANCE.DATE = EB.SystemTables.getRDates(EB.Utility.Dates.DatPeriodEnd)
    BALANCE.AMOUNT = 0
    

RETURN
*** </region>

END
