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
    $PACKAGE SC.ScvValuationUpdates
    SUBROUTINE NET.EXPOSURE.VALUE(OUT.ARRAY)

*** <region name= Description>
*** <desc> </desc>
* ----------------------------------------------------------------------------
*
* This routine is a NOFILE enquiry routine which is triggered from the enquiry
* FX.NET.EXPOSURE.
* The Dynamic Selection Criterias of the Enquiry are,
* Portfolio Number, Percentage, Reference Currency and Group Porfolio.
*
* 01/12/15 - Enhancement:1322379 Task:1550275
*            Incorporation of SC_ScvValuationUpdates
*----------------------------------------------------------------------------
*** </region>

*** <region name= Inserts>
*** <desc> </desc>

    $USING SC.ScvValuationUpdates
    $USING EB.Reports
*** </region>

*** <region name= Process flow>
*** <desc> </desc>

    Y.POS = ''

    tmp.D.FIELDS = EB.Reports.getDFields()
    tmp.D.RANGE.AND.VALUE = EB.Reports.getDRangeAndValue()

    LOCATE "PORTFOLIO.NO" IN tmp.D.FIELDS<1> SETTING Y.POS THEN
    PORTFOLIO.NUMBER = tmp.D.RANGE.AND.VALUE<Y.POS>
    END ELSE
    PORTFOLIO.NUMBER = ''
    END

    LOCATE "PERCENTAGE" IN tmp.D.FIELDS<1> SETTING Y.POS THEN
    PERCENTAGE=tmp.D.RANGE.AND.VALUE<Y.POS>
    END ELSE
    PERCENTAGE = ''
    END

    LOCATE "REFERENCE.CCY" IN tmp.D.FIELDS<1> SETTING Y.POS THEN
    REF.CCY=tmp.D.RANGE.AND.VALUE<Y.POS>
    END ELSE
    REF.CCY = ''
    END

    LOCATE "GROUP.OR.SINGLE.PORT" IN tmp.D.FIELDS<1> SETTING Y.POS THEN
    GROUP.OR.SINGLE.PORT=tmp.D.RANGE.AND.VALUE<Y.POS>
    END ELSE
    GROUP.OR.SINGLE.PORT = ''
    END

* CALC.NET.EXPOSURE.VALUE Routine Calculates the NET.EXPOSURE and returns the net exposure as well as
* Currency - wise details about Actual Portfolio, FX positions, Real Portfolio to the Enquiry routine.

    SC.ScvValuationUpdates.CalcFxNetExposureValue(PORTFOLIO.NUMBER,PERCENTAGE,REF.CCY,GROUP.OR.SINGLE.PORT,NET.EXPOSURE.IN.REF.CCY,RET.ARRAY)

    OUT.ARRAY = RET.ARRAY

    RETURN
    END
*** </region>
