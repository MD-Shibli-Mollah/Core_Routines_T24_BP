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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------

    $PACKAGE EB.ModelBank

    SUBROUTINE E.GET.LOCAL.AMT 

* Enquiry Subroutine to calculate the LOCAL equivalent when a Currrency
* and Amount is passed to it.
* Routine uses MIDDLE.RATE.CONV.CHECK to get the LCY amount.
* The data passed into this has to be in O.DATA setup in the the
* Enquiry in the format CCYnnn (CURRENCY catenated with the Amount).
*
* This routine will return the Local equivalent in O.DATA.
*
* If the Currency is the LOCAL Currency then MIDDLE.RATE...
* is not called.
* Merge of Barings changes.
*
* 10/05/16 - Enhancement 1499014
*          - Task 1626129
*          - Routine incorporated

    $USING EB.SystemTables
    $USING EB.Reports
    $USING ST.ExchangeRate

    Y.FCY = EB.Reports.getOData()[1,3]
    Y.FAMT = EB.Reports.getOData()[4,99]
    Y.RATE = ''
    Y.MARKET = ''
    Y.LAMT = ''
    Y.DIFF.AMT = ''
    Y.DIF.PCT = ''

* Dont call MIDDLE.RATE.CONV.CHECK if the Currency passed is = LCCY

    IF Y.FCY = EB.SystemTables.getLccy() THEN
        Y.LAMT = Y.FAMT
    END ELSE
        ST.ExchangeRate.MiddleRateConvCheck(Y.FAMT,Y.FCY,Y.RATE,Y.MARKET,Y.LAMT,Y.DIF.AMT,Y.DIF.PCT)
    END

    EB.Reports.setOData(Y.LAMT)

    RETURN

    END
