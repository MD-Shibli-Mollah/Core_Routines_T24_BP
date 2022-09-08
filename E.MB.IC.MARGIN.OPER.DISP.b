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
* <Rating>-8</Rating>
*-----------------------------------------------------------------------------

    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.IC.MARGIN.OPER.DISP
*-----------------------------------------------------------------------------

* Subroutine type : Subroutine
* Attached to     : Enquiry ACC.CURRENT.INT and ACC.CURRENT.INTEREST
* Attached as     : Conversion Routine
* Purpose         : Returns the Margin Operator extracted from Margin Rate.
* @author         : Model Bank

*-------------------------------------------------------------------------------
    $USING EB.Reports

    MARGIN.RATE = EB.Reports.getOData()

    MARGIN.OPERATOR = RIGHT(MARGIN.RATE,1)

    EB.Reports.setOData(MARGIN.OPERATOR)

* IF MARGIN.OPERATOR EQ '*' OR MARGIN.OPERATOR EQ '-' THEN

*    MARGIN.RATE = FIELD(MARGIN.RATE,MARGIN.OPERATOR,1)
*    O.DATA = MARGIN.RATE
*   END

    RETURN

    END
