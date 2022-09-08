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
* <Rating>-63</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FX.ModelBank
    SUBROUTINE E.FX.SF.SWAP.BUILD(ENQUIRY.DATA)

* Build routine attached to the enquiry FX.SF.SWAP to update FX.SF.SWAP file
* The routine will do the following:
*     Clear the  contents of file FX.SF.SWAP
*     Select FOREX Swap contracts with REVALUATION.TYPE = 'SF' and STATUS NE 'MAT'
*     calls DAS.FOREX routine to achieve the above selection.
*     The contents from FOREX are written in to FX.SF.SWAP in the related fields for all selected contracts
*
* Modifications:
* -------------
* 07/06/07 - EN_10003396
*            I-Descriptor Cleanup
*
* 15/09/15 - EN_1226121 / Task 1477143
*	      	 Routine incorporated
*

    $USING FX.Contract
    $USING FX.Reports
    $USING EB.DataAccess
    $USING EB.TransactionControl

    $INSERT I_DAS.FOREX


    GOSUB INITIALISATION
    GOSUB CLEAR.FX.SF.SWAP


MAIN.PROCESS:

    GOSUB EXECUTE.DAS

* Contents are written to FX.SF.SWAP
    ID.FX = ''
    LOOP
        REMOVE ID.FX FROM FX.LIST SETTING FX.POS.NEW
    WHILE ID.FX:FX.POS.NEW
        GOSUB GET.FOREX.DETAILS
        R.FX.SF.SWAP<FX.Reports.SfSwap.SfSwapOtherCcy> = SW.NON.BASE.CCY
        R.FX.SF.SWAP<FX.Reports.SfSwap.SfSwapPlValueDate> = SWAP.PL.VALUE.DATE
        R.FX.SF.SWAP<FX.Reports.SfSwap.SfSpotDate> = R.FOREX<FX.Contract.Forex.SpotDate>
        R.FX.SF.SWAP<FX.Reports.SfSwap.SfTotIntBought> = R.FOREX<FX.Contract.Forex.TotalIntBought>
        R.FX.SF.SWAP<FX.Reports.SfSwap.SfBuyDailyAccF> = R.FOREX<FX.Contract.Forex.BuyDailyAccF>
        R.FX.SF.SWAP<FX.Reports.SfSwap.SfBuyAccTdateF> = R.FOREX<FX.Contract.Forex.BuyAccTdateF>
        R.FX.SF.SWAP<FX.Reports.SfSwap.SfTotIntSold> = R.FOREX<FX.Contract.Forex.TotalIntSold>
        R.FX.SF.SWAP<FX.Reports.SfSwap.SfSelDailyAccF> = R.FOREX<FX.Contract.Forex.SelDailyAccF>
        R.FX.SF.SWAP<FX.Reports.SfSwap.SfSelAccTdateF> = R.FOREX<FX.Contract.Forex.SelAccTdateF>
        R.FX.SF.SWAP<FX.Reports.SfSwap.SfAccountOfficer> = R.FOREX<FX.Contract.Forex.AccountOfficer>
        SWAP.REF.NO = R.FOREX<FX.Contract.Forex.SwapRefNo>
        CONVERT @VM TO '*' IN SWAP.REF.NO
        R.FX.SF.SWAP<FX.Reports.SfSwap.SfSwapRefNo> = SWAP.REF.NO

        FX.Reports.SfSwapWrite(ID.FX, R.FX.SF.SWAP, '')
        EB.TransactionControl.JournalUpdate('FX.SF.SWAP:':ID.FX)

    REPEAT
    RETURN
*-----------------------------------------------------------------------------
GET.FOREX.DETAILS:

    ER = ''
    R.FOREX = FX.Contract.Forex.Read(ID.FX, ER)
    IF ER THEN
        R.FOREX = ''
    END
    SWAP.BASE.CCY = R.FOREX<FX.Contract.Forex.SwapBaseCcy>
    CURRENCY.BOUGHT = R.FOREX<FX.Contract.Forex.CurrencyBought>
    CURRENCY.SOLD = R.FOREX<FX.Contract.Forex.CurrencySold>
    VALUE.DATE.BUY = R.FOREX<FX.Contract.Forex.ValueDateBuy>
    VALUE.DATE.SELL = R.FOREX<FX.Contract.Forex.ValueDateSell>
* extracts the SWAP non base currency and its value date
    IF SWAP.BASE.CCY EQ '' THEN
        SW.NON.BASE.CCY = ''
        SWAP.PL.VALUE.DATE = ''
    END ELSE
        IF SWAP.BASE.CCY EQ CURRENCY.BOUGHT THEN
            SW.NON.BASE.CCY = CURRENCY.SOLD
            SWAP.PL.VALUE.DATE = VALUE.DATE.SELL
        END ELSE
            SW.NON.BASE.CCY = CURRENCY.BOUGHT
            SWAP.PL.VALUE.DATE = VALUE.DATE.BUY
        END
    END
    RETURN
*--------------------------------------------------------------------------------
INITIALISATION:

    THE.ARGS = ''
    TABLE.SUFFIX = ''
    ID.FX = ''
    ACCOUNT.OFFICER = ''
    SWAP.OTHER.CCY = ''
    R.FX.SF.SWAP = ''
    R.FOREX = ''
    FX.LIST.NEW = ''
    FX.POS.NEW = ''
    FX.SF.POS = ''
    FX.SF.SWAP.LIST = ''

    RETURN
*------------------------------------------------------------------------------
CLEAR.FX.SF.SWAP:

    FX.SF.SWAP.LIST = 'ALL.IDS'
    EB.DataAccess.Das('FX.SF.SWAP',FX.SF.SWAP.LIST,THE.ARGS,TABLE.SUFFIX)

    FX.SF.SWAP.ID = ''
    LOOP
        REMOVE FX.SF.SWAP.ID FROM FX.SF.SWAP.LIST SETTING FX.SF.POS
    WHILE FX.SF.SWAP.ID:FX.SF.POS
        FX.Reports.SfSwapDelete(FX.SF.SWAP.ID,'')
    REPEAT
    RETURN
*----------------------------------------------------------------------------
EXECUTE.DAS:

* Selects Forex With Revaluation type eq 'SF' and STATUS ne 'MAT'
    THE.ARGS = ''
    FX.LIST = dasForexWithRevalTypeAndStatusCondition
    EB.DataAccess.Das('FOREX',FX.LIST,THE.ARGS,TABLE.SUFFIX)
    RETURN
*---------------------------------------------------------------------------
    END
