* @ValidationCode : MjotMTkyMTA2NTk4ODpDcDEyNTI6MTU0NzAxNzk5MzQzOTphbW9uaXNoYTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTAxLjIwMTgxMjIzLTAzNTM6NTI6NTI=
* @ValidationInfo : Timestamp         : 09 Jan 2019 12:43:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : amonisha
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 52/52 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201901.20181223-0353
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-42</Rating>
*-----------------------------------------------------------------------------
*SUBROUTINE TO VALIDATE VERSION EB.MORTGAGE.FORM1,ASEET.LIAB
    $PACKAGE OP.ModelBank
    SUBROUTINE ASST.LIAB.DETAILS
*------------------------------------------------------------
* 04-03-16 - 1653120
*            Incorporation of components
*
* 09/01/18 - Defect 2890806 / Task 2937649
*          - Default TDS and GDS to 0 when No income and liability is given.
*
************************************************************************************
    $USING OP.ModelBank
    $USING ST.ExchangeRate
    $USING EB.API
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN
*-------------------------------------------------------------------
INITIALISE:

    Y.ASSET.AMT=''
    Y.LIAB.AMT=''
    Y.TDS.VALUE = ''
    Y.GDS.VALUE = ''
    RETURN
*-----------------------------------------------------------------
PROCESS:
*FOR ASSETS 
    Y.ASST.COUNT = DCOUNT(EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetId),@VM)     ;*COUNTINING NUMBER OF ASSETS
    FOR Y.ASSET = 1 TO Y.ASST.COUNT
        DEAL.CCY = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetCcy)<1,Y.ASSET>     ;*READING CURRENCY TYPE
        LCY.AMOUNT = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetAmt)<1,Y.ASSET>
        EXCH.RATE = ''
        GOSUB DETERMINE.CCY.AMOUNTS
        Y.ASSET.AMT = Y.ASSET.AMT+LCY.AMOUNT      ;*ADDING ASSET AMOUNTS  AFTER CONVERTED INTO LOCAL CCY IF ANY OTHER CCY INVOLVED
    NEXT Y.ASSET
    EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrAssetTotal, Y.ASSET.AMT);*TOTAL ASSET AMOUNT
*FOR LIABILITIES
    Y.LIAB.COUNT = DCOUNT(EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabId),@VM)      ;*COUNTING NUMBER OF LIABILITIES
    FOR Y.LIAB = 1 TO Y.LIAB.COUNT
        EXCH.RATE = ''
        DEAL.CCY=EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabCcy)<1,Y.LIAB>         ;*READING CURRENCY TYPE
        LCY.AMOUNT = EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabAmt)<1,Y.LIAB>
        GOSUB DETERMINE.CCY.AMOUNTS
        Y.LIAB.AMT = Y.LIAB.AMT+LCY.AMOUNT        ;*ADDING LIAB AMOUNTS AFTR CONVERTED INTO LOCAL CCY IF ANY OTHER CCY INVOLVED
        *calculation of TDS
        IF EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrTdsInclude)<1,Y.LIAB> NE '' AND EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCalcTds) NE ''  THEN
            Y.TDS.VALUE = Y.TDS.VALUE+(EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabAmt)<1,Y.LIAB>*EXCH.RATE)*(12/EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrFqyInMonths)<1,Y.LIAB>)
        END
        *calculation of GDS
        IF EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrGdsInclude)<1,Y.LIAB> NE '' AND EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCalcGds) NE '' THEN
            Y.GDS.VALUE = Y.GDS.VALUE+((EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabAmt)<1,Y.LIAB>*EXCH.RATE)*(12/EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrFqyInMonths)<1,Y.LIAB>))
        END
    NEXT Y.LIAB
    EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrLiabTotal, Y.LIAB.AMT);*TOTAL LIABILITY AMOUNT
    IF (EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrIncomeTotal)) THEN            ;*Divide only if Income total is a NON-ZERO value
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrTdsValue, DROUND((Y.TDS.VALUE*100)/(EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrIncomeTotal)*12),2));*TDS VALUE
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrGdsValue, DROUND((Y.GDS.VALUE*100)/(EB.SystemTables.getRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrIncomeTotal)*12),2));*GDS VALUE
    END ELSE        ;*set TDS and GDS value to 0 if there is no Income 
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrTdsValue, 0);*TDS VALUE
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrGdsValue, 0);*GDS VALUE
    END
    RETURN          ;*RETURN TO MAIN
*--------------------------------------------------------------------
DETERMINE.CCY.AMOUNTS:
* DETERMINING AMOUNT IN LOCAL CURRENCY
    IF DEAL.CCY EQ EB.SystemTables.getLccy() THEN
        LCY.AMOUNT = LCY.AMOUNT
        EXCH.RATE = "1"
        FCY.AMOUNT = ""
    END ELSE
        FCY.AMOUNT = EB.SystemTables.getComi()
        LCY.AMOUNT = ''
        ST.ExchangeRate.MiddleRateConvCheck(FCY.AMOUNT,DEAL.CCY,EXCH.RATE,"1",LCY.AMOUNT,"","")
        tmp.LCCY = EB.SystemTables.getLccy()
        EB.API.RoundAmount(tmp.LCCY,LCY.AMOUNT,"","")
    END
    RETURN
*-------------------------------------------------------------------------
    END 
