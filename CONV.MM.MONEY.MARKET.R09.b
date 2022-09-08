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
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
* Updating the field ACCRUAL.PARAM in MM.MONEY.MARKET to NULL, so that
* it can continue as like first day accrual contracts
*
*19/01/11 - Defect 337776 / CI_10074802
*           INCOME.TAX.CALC field is reserved, hence its corresponding value
*           should be made NULL.
*----------------------------------------------------------------------------
    $PACKAGE MM.Contract
    SUBROUTINE CONV.MM.MONEY.MARKET.R09(MM.ID,MM.REC,FN.MM.MONEY.MARKET)
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.MM.MONEY.MARKET
*
    IF MM.REC<MM.ACCRUAL.PARAM> EQ "YES" THEN
        MM.REC<MM.ACCRUAL.PARAM> = ''
    END

* Get the field number of INCOME.TAX.CALC And its corresponding value
* is made null

    APPLN = "MM.MONEY.MARKET"
    CALL GET.STANDARD.SELECTION.DETS(APPLN,MM.MONEY.MARKET.SS)

    CALL FIELD.NAMES.TO.NUMBERS('INCOME.TAX.CALC',MM.MONEY.MARKET.SS,INCOME.TAX.FLD.NO,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)
    IF NOT(ERR.MSG) THEN
        MM.REC<INCOME.TAX.FLD.NO> = ''
    END

*
    RETURN
END
