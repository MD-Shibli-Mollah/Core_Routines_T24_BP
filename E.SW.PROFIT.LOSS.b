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

* Version 3 02/06/00  GLOBUS Release No. 200512 01/12/05
*-----------------------------------------------------------------------------
* <Rating>-65</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Reports
    SUBROUTINE E.SW.PROFIT.LOSS
*************************************************************************
* MODIFICATIONS:
****************
*
* 24/03/05 - CI_10028591
*            No values in swap reval report in PL Today column - COB
*
* 03/02/06 - EN_10002766
*            Enquiry for CIRS report also calls this routine to display NPV amounts
*            in local currency as well.
*
* 20/02/06 - BG_100010273
*            Change Report for NPV to hold Same currency(IRS) as well.
*
* 07/06/07 - EN_10003396
*            I-Descriptor Cleanup
*
* 30/12/15 - Enhancement 1226121
*		   - Task 1569212
*		   - Routine incorporated
*
* 19/03/16 - Defect 1618876 / Task 1669237
*            The enquiry SW.NPV.REVAL displays PL.TODAY incorrectly
*            for cross currency swap contracts.

*************************************************************************
    $USING SW.Contract
    $USING SW.PositionAndReval
    $USING EB.DataAccess
    $USING SW.Foundation
    $USING EB.SystemTables
    $USING EB.Reports

*************************************************************************
*
*************
MAIN.PROCESS:
*************
*
    GOSUB INITIALISATION
*
    GOSUB READ.SWAP.RECORDS
*
    DISCOUNT.RATE = EB.Reports.getOData()
    NPV = ''
    IF CROSS.CURRENCY THEN
        RUNNING.UNDER.BATCH.VAL = EB.SystemTables.getRunningUnderBatch()
        IF RUNNING.UNDER.BATCH.VAL THEN
            NPV<1> = SW.Foundation.getRSwAssetBalances()<SW.Contract.SwapBalances.BalNpv>
            NPV<2> = SW.Foundation.getRSwLiabilityBalances()<SW.Contract.SwapBalances.BalNpv>
            NPV<5> = SW.Foundation.getRSwAssetBalances()<SW.Contract.SwapBalances.BalNpvLcy>
            NPV<6> = SW.Foundation.getRSwLiabilityBalances()<SW.Contract.SwapBalances.BalNpvLcy>
            NPV<3> = NPV<5> - NPV<6>
            NPV<4> = SW.Foundation.getRSwap()<SW.Contract.Swap.NpvPlToday>
        END ELSE
            SW.PositionAndReval.NpvCalculation(DISCOUNT.RATE,NPV)
            GOSUB GET.LOCAL.EQUIV
            NPV<3> = NPV<5> - NPV<6>
            NPV<4> =  NPV<3> - SW.Foundation.getRSwap()<SW.Contract.Swap.FwdRevalPlLcy>;*PL today is the difference between previous day reval and today reval amount.
        END

    END ELSE

        RUNNING.UNDER.BATCH.VAL = EB.SystemTables.getRunningUnderBatch()
        IF RUNNING.UNDER.BATCH.VAL THEN     ;* CI_10028591/S
            NPV<1> = SW.Foundation.getRSwAssetBalances()<SW.Contract.SwapBalances.BalNpv>
            NPV<2> = SW.Foundation.getRSwLiabilityBalances()<SW.Contract.SwapBalances.BalNpv>
            NPV<3> = SW.Foundation.getRSwap()<SW.Contract.Swap.FwdRevalAmount>
            NPV<5> = SW.Foundation.getRSwAssetBalances()<SW.Contract.SwapBalances.BalNpvLcy>
            NPV<6> = SW.Foundation.getRSwLiabilityBalances()<SW.Contract.SwapBalances.BalNpvLcy>
            NPV<4> = SW.Foundation.getRSwap()<SW.Contract.Swap.NpvPlToday>
        END ELSE

            SW.PositionAndReval.NpvCalculation(DISCOUNT.RATE,NPV)
            NPV<4> = NPV<3> - SW.Foundation.getRSwap()<SW.Contract.Swap.FwdRevalAmount>
            GOSUB GET.LOCAL.EQUIV

        END


    END
*
    EB.Reports.setOData(NPV<1>)
    EB.Reports.setOData(EB.Reports.getOData() : '*':NPV<2>)
    EB.Reports.setOData(EB.Reports.getOData() : '*':NPV<3>)
    EB.Reports.setOData(EB.Reports.getOData() : '*':NPV<4>);* CI_10028591/E
    EB.Reports.setOData(EB.Reports.getOData() : '*':NPV<5>)
    EB.Reports.setOData(EB.Reports.getOData() : '*':NPV<6>)
*
    RETURN
*
************************************************************************
*
***************
INITIALISATION:
***************
*
    F$SWAP.LOC = ""
    EB.DataAccess.Opf("F.SWAP",F$SWAP.LOC)
    SW.Foundation.setFdSwap(F$SWAP.LOC)
*
    F.SWAP$NAU = ""
    EB.DataAccess.Opf("F.SWAP$NAU",F.SWAP$NAU)
*
    F$SWAP.BALANCES.LOC = ""
    EB.DataAccess.Opf("F.SWAP.BALANCES",F$SWAP.BALANCES.LOC)
    SW.Foundation.setFdSwapBalances(F$SWAP.BALANCES.LOC)
*
    SW.Foundation.setRSwap("")
    SW.Foundation.setRSwAssetBalances("")
    SW.Foundation.setRSwLiabilityBalances("")
    SW.Foundation.setCAccountingEntries("")
    SW.Foundation.setCForwardEntries("")
*
    ID.VAL = EB.Reports.getId()
    ID.SWAP = FIELD(ID.VAL,"*",1)
    SW.Foundation.setCSwapId(ID.SWAP);* Swap contract id.
    ASST.BAL.ID = SW.Foundation.getCSwapId():".A"        ;* Asset swap bal id.
    LIAB.BAL.ID = SW.Foundation.getCSwapId():".L"        ;* Liab swap bal id.
*
    RETURN
*
*************************************************************************
*
*
******************
READ.SWAP.RECORDS:
******************
*
*  Read swap contract from either the swap unauth or auth file.
*

    ER = ''
    C$SWAP.ID.VAL = SW.Foundation.getCSwapId()
    R$SWAP.VAL = SW.Contract.Swap.ReadNau(C$SWAP.ID.VAL, ER)
    IF ER THEN
        ER = ''
        R$SWAP.VAL = SW.Contract.Swap.Read(C$SWAP.ID.VAL, ER)
        IF ER THEN
            R$SWAP.VAL = ''
        END
    END
    SW.Foundation.setRSwap(R$SWAP.VAL)
*
*  Read swap balance asset and liability records.
*

    IF R$SWAP.VAL THEN
        ER = ''
        R$SW.ASSET.BALANCES.VAL = SW.Contract.SwapBalances.Read(ASST.BAL.ID, ER)
        IF ER THEN
            R$SW.ASSET.BALANCES.VAL = ''
        END
        ER = ''
        R$SW.LIABILITY.BALANCES.VAL = SW.Contract.SwapBalances.Read(LIAB.BAL.ID, ER)
        IF ER THEN
            R$SW.LIABILITY.BALANCES.VAL = ''
        END
        SW.Foundation.setRSwAssetBalances(R$SW.ASSET.BALANCES.VAL)
        SW.Foundation.setRSwLiabilityBalances(R$SW.LIABILITY.BALANCES.VAL)
    END

    CROSS.CURRENCY = ( SW.Foundation.getRSwap()<SW.Contract.Swap.AsCurrency> NE SW.Foundation.getRSwap()<SW.Contract.Swap.LbCurrency>)
*
    RETURN

**********************
GET.LOCAL.EQUIV:
**********************

    LCY.AMOUNT = ''
    AMOUNT = NPV<1>
    AMOUNT<-1> = NPV<2>
    LEG.CCY = SW.Foundation.getRSwAssetBalances()<SW.Contract.SwapBalances.BalCurrency>
    LEG.CCY<-1> = SW.Foundation.getRSwLiabilityBalances()<SW.Contract.SwapBalances.BalCurrency>
    SW.Foundation.DetermineCcyAmounts(AMOUNT,LEG.CCY,LCY.AMOUNT)
    NPV<5> = LCY.AMOUNT<1>
    NPV<6> = LCY.AMOUNT<2>

    RETURN
*************************************************************************
*
    END
