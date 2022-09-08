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

* Version 1 31/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>56</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.ModellingAddins
    SUBROUTINE SET.POSITION.SCENARIO(SAM.CODE,OPTION,R.AM.SCENARIO,R.AM.PRICE.SET,R.AM.POS)
*========================================================================
* External routine set in AM.PARAMETER
* Extract positions from AM.SCENARIO and build records in AM.POS
* in     : SAM.CODE portfolio code
* in     : OPTION OPTION<1> = session number
* in     : R.AM.SCENARIO = scenario record
* in/out : R.AM.PRICE.SET = price set record
* in/out : R.AM.POS AM.POS record to be update
*
*     Author : API
*     Date   : 01/06/2001
*========================================================================
*
* 28/02/2002 - GLOBUS_EN_10000479 - Main change for G12.2.00
*              Used parameter record R.AM.POS. Do not used AV.
*
* 22/03/2002 - GLOBUS_EN_10000556 - Multi company in modelling.
*
* 14/05/2002 - GLOBUS_EN_10000690 - Currency modelling.
*
* 24/06/2002 - GLOBUS_BG_100001446 - Should negate valuation when sell.
*
* 24/07/2002 - GLOBUS_BG_100001594 - Used SCP.VALUATION to value
*              counterparty.
*
* 30/01/2003 - GLOBUS_EN_10001613 - Performance optimisation.
*
* 29/07/15 -  ENHANCEMENT:1322379 TASK:1421332
*             Incorporation of AM.ModellingAddins
*========================================================================

    $USING EB.ErrorProcessing
    $USING AM.Modelling
    $USING AM.ModellingScenario
    $USING EB.SystemTables
*========================================================================

*========================================================================
* Check parameters and default values section
*========================================================================

    IF SAM.CODE = '' THEN RETURN

    YSAM.CODE = SAM.CODE
    YOPTION = OPTION
    YR.AM.SCENARIO = R.AM.SCENARIO


*========================================================================
* Init. section
*========================================================================

    YPOS.TYPE = 'SCENARIO'

*========================================================================
* Main controlling section
*========================================================================
*
    GOSUB DELETE.EXISTING.ENTRY
    K = DCOUNT(R.AM.POS<AM.Modelling.Pos.PosType>, @VM)

* append new simulation securities
    NB = DCOUNT(YR.AM.SCENARIO<AM.ModellingScenario.Scenario.SceScSelected>,@VM)
    FOR I = 1 TO NB
        IF YR.AM.SCENARIO<AM.ModellingScenario.Scenario.SceScSelected,I> = 'YES' THEN

            VALUATION = YR.AM.SCENARIO<AM.ModellingScenario.Scenario.SceScaValuation,I>
            NOMINAL = YR.AM.SCENARIO<AM.ModellingScenario.Scenario.SceScaNominal,I>
            IF YR.AM.SCENARIO<AM.ModellingScenario.Scenario.SceScDirection,I> = 'SELL' THEN
                VALUATION = -VALUATION
                NOMINAL = -NOMINAL
            END

            K += 1
            R.AM.POS<AM.Modelling.Pos.PosType,K> = YPOS.TYPE
            R.AM.POS<AM.Modelling.Pos.PosApplication,K> = 'SC'
            R.AM.POS<AM.Modelling.Pos.PosOption,K> = ''
            tmp.SceScaSecurity = AM.ModellingScenario.Scenario.SceScaSecurity
            tmp.SceScaCurrency = AM.ModellingScenario.Scenario.SceScaCurrency
            R.AM.POS<AM.Modelling.Pos.PosCode,K> = YR.AM.SCENARIO<tmp.SceScaSecurity,I>
            R.AM.POS<AM.Modelling.Pos.PosCurrency,K> = YR.AM.SCENARIO<tmp.SceScaCurrency,I>
            R.AM.POS<AM.Modelling.Pos.PosValuation,K> = VALUATION
            R.AM.POS<AM.Modelling.Pos.PosNominal,K> = NOMINAL

            VALUATION = YR.AM.SCENARIO<AM.ModellingScenario.Scenario.SceScpValuation,I>
            IF YR.AM.SCENARIO<AM.ModellingScenario.Scenario.SceScDirection,I> = 'SELL' THEN
                VALUATION = -VALUATION
            END

            K += 1
            R.AM.POS<AM.Modelling.Pos.PosType,K> = YPOS.TYPE
            R.AM.POS<AM.Modelling.Pos.PosApplication,K> = 'AC'
            R.AM.POS<AM.Modelling.Pos.PosOption,K> = ''
            tmp.SceScpAccount = AM.ModellingScenario.Scenario.SceScpAccount
            tmp.SceScpCurrency = AM.ModellingScenario.Scenario.SceScpCurrency
            R.AM.POS<AM.Modelling.Pos.PosCode,K> = YR.AM.SCENARIO<tmp.SceScpAccount,I>
            R.AM.POS<AM.Modelling.Pos.PosCurrency,K> = YR.AM.SCENARIO<tmp.SceScpCurrency,I>
            R.AM.POS<AM.Modelling.Pos.PosValuation,K> = -VALUATION
            R.AM.POS<AM.Modelling.Pos.PosNominal,K> = ''

        END
    NEXT I

* append new simulation forex
    NB = DCOUNT(YR.AM.SCENARIO<AM.ModellingScenario.Scenario.SceFxSelected>,@VM)
    FOR I = 1 TO NB
        IF YR.AM.SCENARIO<AM.ModellingScenario.Scenario.SceFxSelected,I> = 'YES' THEN
            BEGIN CASE

                    * forex spot
                CASE YR.AM.SCENARIO<AM.ModellingScenario.Scenario.SceFxDealType,I> = 'SP'

                    VALUATION = YR.AM.SCENARIO<AM.ModellingScenario.Scenario.SceAmountSold,I>
                    VALUATION = -VALUATION

                    K += 1
                    R.AM.POS<AM.Modelling.Pos.PosType,K> = YPOS.TYPE
                    R.AM.POS<AM.Modelling.Pos.PosApplication,K> = 'AC'
                    R.AM.POS<AM.Modelling.Pos.PosOption,K> = ''
                    tmp.SceAccountPay = AM.ModellingScenario.Scenario.SceAccountPay
                    tmp.SceCurrencySold = AM.ModellingScenario.Scenario.SceCurrencySold
                    R.AM.POS<AM.Modelling.Pos.PosCode,K> = YR.AM.SCENARIO<tmp.SceAccountPay,I>
                    R.AM.POS<AM.Modelling.Pos.PosCurrency,K> = YR.AM.SCENARIO<tmp.SceCurrencySold,I>
                    R.AM.POS<AM.Modelling.Pos.PosValuation,K> = VALUATION
                    R.AM.POS<AM.Modelling.Pos.PosNominal,K> = ''

                    VALUATION = YR.AM.SCENARIO<AM.ModellingScenario.Scenario.SceAmountBought,I>

                    K += 1
                    R.AM.POS<AM.Modelling.Pos.PosType,K> = YPOS.TYPE
                    R.AM.POS<AM.Modelling.Pos.PosApplication,K> = 'AC'
                    R.AM.POS<AM.Modelling.Pos.PosOption,K> = ''
                    tmp.SceAccountRec = AM.ModellingScenario.Scenario.SceAccountRec
                    tmp.SceCurrencyBought = AM.ModellingScenario.Scenario.SceCurrencyBought
                    R.AM.POS<AM.Modelling.Pos.PosCode,K> = YR.AM.SCENARIO<tmp.SceAccountRec,I>
                    R.AM.POS<AM.Modelling.Pos.PosCurrency,K> = YR.AM.SCENARIO<tmp.SceCurrencyBought,I>
                    R.AM.POS<AM.Modelling.Pos.PosValuation,K> = VALUATION
                    R.AM.POS<AM.Modelling.Pos.PosNominal,K> = ''

                    * forex forward are processed by subroutine SET.HEDGING.SCENARIO
                    *               CASE YR.AM.SCENARIO<AM.SCE.FX.DEAL.TYPE,I> = 'FW'

            END CASE
        END
    NEXT I


* append new simulation inflow outflow
    NB = DCOUNT(YR.AM.SCENARIO<AM.ModellingScenario.Scenario.SceAcSelected>,@VM)
    FOR I = 1 TO NB
        IF YR.AM.SCENARIO<AM.ModellingScenario.Scenario.SceAcSelected,I> = 'YES' THEN

            VALUATION = YR.AM.SCENARIO<AM.ModellingScenario.Scenario.SceAcaValuation,I>
            IF YR.AM.SCENARIO<AM.ModellingScenario.Scenario.SceAcDirection,I> = 'OUTFLOW' THEN
                VALUATION = -VALUATION
            END

            K += 1
            R.AM.POS<AM.Modelling.Pos.PosType,K> = YPOS.TYPE
            R.AM.POS<AM.Modelling.Pos.PosApplication,K> = 'AC'
            R.AM.POS<AM.Modelling.Pos.PosOption,K> = ''
            tmp.SceAcaAccount = AM.ModellingScenario.Scenario.SceAcaAccount
            tmp.SceAcaCurrency = AM.ModellingScenario.Scenario.SceAcaCurrency
            R.AM.POS<AM.Modelling.Pos.PosCode,K> = YR.AM.SCENARIO<tmp.SceAcaAccount,I>
            R.AM.POS<AM.Modelling.Pos.PosCurrency,K> = YR.AM.SCENARIO<tmp.SceAcaCurrency,I>
            R.AM.POS<AM.Modelling.Pos.PosValuation,K> = VALUATION
            R.AM.POS<AM.Modelling.Pos.PosNominal,K> = ''

        END
    NEXT I

    RETURN

*========================================================================
* Subroutines
*========================================================================

*---------------------
DELETE.EXISTING.ENTRY:
*---------------------
* Delete existing entries in AM.POS
* YPOS.TYPE & R.AM.POS must be initialised

    NB.POS = DCOUNT(R.AM.POS<AM.Modelling.Pos.PosType>, @VM)
    FOR I = NB.POS TO 1 STEP -1
        IF R.AM.POS<AM.Modelling.Pos.PosType, I> = YPOS.TYPE THEN
            DEL R.AM.POS<AM.Modelling.Pos.PosType, I>
            DEL R.AM.POS<AM.Modelling.Pos.PosApplication, I>
            DEL R.AM.POS<AM.Modelling.Pos.PosOption, I>
            DEL R.AM.POS<AM.Modelling.Pos.PosCode, I>
            DEL R.AM.POS<AM.Modelling.Pos.PosCurrency, I>
            DEL R.AM.POS<AM.Modelling.Pos.PosValuation, I>
            DEL R.AM.POS<AM.Modelling.Pos.PosNominal, I>
        END
    NEXT I

    RETURN


*------------
FATAL.ERROR:
*------------
    EB.SystemTables.setText(EB.SystemTables.getE())
    EB.ErrorProcessing.FatalError('SET.POSITION.SCENARIO')


    END
