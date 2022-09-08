* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-39</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.MTM.CCY(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
*The routine returns the MTM currency of the contract.
*-----------------------------------------------------------------------------
* Modification History :
*
* 18/09/15 - Enhancement 1461371 / Task 1461382
*            OTC Collateral and Valuation Reporting.
*
* 30/12/15 - EN_1226121 / Task 1568411
*			 Incorporation of the routine
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts </desc>


    $USING EB.SystemTables
    $USING EB.API
    $USING SW.Contract
    $USING FR.Contract
    $USING ST.CompanyCreation
    $USING OC.Reporting 


*** </region>
*-----------------------------------------------------------------------------
*** <region name= main body>
*** <desc>main body </desc>


    GOSUB INITIALISE
    GOSUB PROCESS


    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** </region>
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Opne the files </desc>

    RET.VAL =''


    RETURN

*** </region>
*-----------------------------------------------------------------------------
*** </region>
*** <region name= PROCESS>

PROCESS:

    BEGIN CASE

        CASE TXN.ID[1,2] EQ 'SW' AND TXN.REC<SW.Contract.Swap.SwapType> EQ 'IRS'
            RET.VAL = TXN.REC<SW.Contract.Swap.FwdRevalCcy>

        CASE TXN.ID[1,2] EQ  'FR'
            RET.VAL= TXN.REC<FR.Contract.FraDeal.FrdFraCurrency>

        CASE TXN.ID[1,2] EQ 'ND' OR TXN.ID[1,2] EQ 'FX' OR (TXN.ID[1,2] EQ 'SW' AND TXN.REC<SW.Contract.Swap.SwapType> EQ 'CIRS')
            RET.VAL = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCurrency)

    END CASE 

    RETURN
*** </region>
*-----------------------------------------------------------------------------


    END
