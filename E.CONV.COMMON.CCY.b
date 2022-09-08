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
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.CONV.COMMON.CCY
*-----------------------------------------------------------------------------
*
* Description - Conversion routine attached to the enquiry NOSTRO.POSITION as an alternate solution to the IDESCRIPTOR field
*               SEL.CCY .
*
*************************************************************************
* Modification History
*
* 03/09/14 - Defect 1062378 / Task 1071585
*            Enquiry is not displaying any values due to IDESC field SEL.CCY given as a fixed sort in the enquiry
*            SEL.CCY field validation done in this conversion routine which determines the currency to be displayed based
*            on the MERGE.NCU value given in the enquiry.
*
* 28/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING ST.CurrencyConfig
*
    CCY = EB.Reports.getOData()
    EB.Reports.setOData('')
    LOCATE 'MERGE.NCU' IN EB.Reports.getEnqSelection()<2,1> SETTING MERGE.POS THEN
    IF EB.Reports.getEnqSelection()<4,MERGE.POS>[1,1] = 'Y' THEN       ;* Check for fixed ccy
        *
        FIX.CCY = ''
        R.CURRENCY = ''
        R.CURRENCY = ST.CurrencyConfig.tableCurrency(CCY, ERR)
        IF NOT(ERR) THEN
            FIX.CCY = R.CURRENCY<ST.CurrencyConfig.Currency.EbCurFixedCcy>
        END
        IF FIX.CCY THEN
            EB.Reports.setOData(FIX.CCY)
        END ELSE
            EB.Reports.setOData(CCY)
        END
    END ELSE
        EB.Reports.setOData(CCY)
    END
    END ELSE
    EB.Reports.setOData(CCY)
    END
*
    RETURN
*-----------------------------------------------------------------------------
    END
