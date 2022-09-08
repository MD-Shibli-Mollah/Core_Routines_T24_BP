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
* <Rating>350</Rating>
*-----------------------------------------------------------------------------
* Version 4 07/06/01  GLOBUS Release No. 200508 30/06/05
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.FORMAT.SIGN.AMT(FACTOR, FLAG)

* This routine will format amounts based on the information passed
* in the common variable R$PM.ENQ.PARAM which should have been previously
* read from the PM.ENQ.PARAM file by the E.PM.INIT.COMMON routine.
* Amounts will be returned prefixed with a "+" or "-", enclosed in
* brackets or with no change according to the contents of R$PM.ENQ.PARAM.
* The user must indicate via FLAG if the amount is etiher a simple
* asset/liability figure or a difference figure. Additionally amounts can
* be formatted to the correct number of decimals for the CCY specified or
* expressed in round thousands or millions etc as specifed by the FACTOR.
*
* INPUT
* =====
* O.DATA         : The amount to be formatted. Assets must be passed to
*                  this routine as positive amounts and liabilities as
*                  negative.
* R$PM.ENQ.PARAM : Array containing the relevant PM.ENQ.PARAM record.
*                  This controls the signing convention for both pure
*                  asset/liab figures and for difference figures.
* PM$CCY         : The currency of the amount passed in O.DATA. Only
*                  required if formatting to the correct number of
*                  decimals is required. Note this will be ignored if a
*                  factor is specified.
* FACTOR         : Allows the user to specifiy that amounts should be
*                  returned to the nearest 1000 etc. The amount passed
*                  will be divided by the FACTOR and rounded to the
*                  nearest whole unit.
* FLAG           : Used to indicate if the amount passed represents a pure
*                  asset/liability amount or a difference amount. Should
*                  be either PURE or DIFF. Default is PURE.
* OUTPUT
* ======
* O.DATA         : The amount correctly formatted and signed.
*
*-----------------------------------------------------------------------------
* MODIFICATIONS
*
* GB0002037 - RPK 09/09/2000
*
* Addition of sign formatting for ENQ.TYPE = FX forex
*
* 05/08/-5 - CI_10033145
*            Make sure the formatted amount allows for only 1 sign type being set
*            don't put a - sign on zero amounts.
* 17/04/07 - CI_10048526
*            The ENQUIRY PM.GAP is showing the values as not correctly formatted
*            Changes added to make it correctly
*
* 26/05/10 - Defect-49555 / Task-52388
*            Enquiry dispalys zero in amount fields when TYPE CCY is set
*
* 26/10/15 - EN_1226121 / Task 1511358
*	      	 Routine incorporated
*
*********************************************************************************
*

    $USING PM.Config
    $USING EB.SystemTables
    $USING ST.CurrencyConfig
    $USING PM.Reports
    $USING EB.Reports


    BEGIN CASE
        CASE FACTOR
            EB.Reports.setOData(EB.Reports.getOData() / FACTOR)
            FMT.CODE = 'MD0,'
        CASE PM.Config.getCcy()
            GOSUB GET.FMT.CODE.FOR.CCY
        CASE 1
    END CASE

* Add the relevant sign - note at this stage assets should be positve
* and liabilites negative.

    IF PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqOniteDlyFile) = '' THEN RETURN

    BEGIN CASE
        CASE FLAG = 'PURE'
        CASE FLAG = 'DIFF'
        CASE 1
            FLAG = 'PURE'
    END CASE

    IF PM.Config.getRPmEnqParam(PM.Reports.EnqParam.EnqEnqType) = "FX" THEN
        BEGIN CASE
            CASE EB.Reports.getOData() < 0
                tmp.O.DATA = EB.Reports.getOData()
                EB.Reports.setOData(ABS(tmp.O.DATA))
                FLD.NO = PM.Reports.EnqParam.EnqFxSellSign
            CASE EB.Reports.getOData() > 0
                FLD.NO = PM.Reports.EnqParam.EnqFxBuySign
            CASE 1
                FLD.NO = ''
        END CASE
    END ELSE
        BEGIN CASE
            CASE EB.Reports.getOData() < 0 AND FLAG = 'PURE'
                EB.Reports.setOData(EB.Reports.getOData() * -1)
                FLD.NO = PM.Reports.EnqParam.EnqTakSign
            CASE EB.Reports.getOData() < 0 AND FLAG = 'DIFF'
                EB.Reports.setOData(EB.Reports.getOData() * -1)
                FLD.NO = PM.Reports.EnqParam.EnqDifTakSign
            CASE FLAG = 'PURE'
                FLD.NO = PM.Reports.EnqParam.EnqPlacSign
            CASE FLAG = 'DIFF'
                FLD.NO = PM.Reports.EnqParam.EnqDifPlacSign
            CASE 1
                FLD.NO = ''
        END CASE
    END
    IF EB.Reports.getOData() = 0 THEN ZERO.AMT = 1 ELSE ZERO.AMT = 0


    IF FLD.NO THEN  ;* Align decimal points
        PART1 = PM.Config.getRPmEnqParam(FLD.NO)<1,1>
        PART2 = PM.Config.getRPmEnqParam(FLD.NO)<1,2>

        BEGIN CASE
            CASE PART1 NE " " AND PART2 NE " "
                EB.Reports.setOData(PART1:EB.Reports.getOData():PART2)
            CASE PART1 NE " "
                EB.Reports.setOData(PART1:EB.Reports.getOData())
            CASE PART2 NE " "
                IF PART2 <> "+" THEN
                    EB.Reports.setOData(PART2:EB.Reports.getOData())
                END
            CASE 1
                EB.Reports.setOData(EB.Reports.getOData() : " ")
        END CASE
        IF ZERO.AMT THEN EB.Reports.setOData(EB.Reports.getOData()[2,1]);* Don't have - sign on zero amounts
    END
    RETURN


GET.FMT.CODE.FOR.CCY:
*====================

* Format to the correct number of decimals for the currency. Do not call
* EB.ROUND.AMOUNT as we need to add commas between the thousands.

    LOCATE PM.Config.getCcy() IN EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfNonTwodecCcy,1> SETTING V$ THEN
    MD='NO.OF.DECIMALS'
    tmp.PM$CCY = PM.Config.getCcy()
    ST.CurrencyConfig.UpdCcy(tmp.PM$CCY,MD)
    PM.Config.setCcy(tmp.PM$CCY)
    FMT.CODE='MD':MD
    END ELSE
    FMT.CODE='MD2'
    END

    FMT.CODE := ','

    RETURN


******
    END
