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

* Version 3 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-17</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.ModelBank

    SUBROUTINE E.CUS.POSITION.EXCHANGE
*-----------------------------------------------------------------------------
*
** This subroutine will convert CUSTOMER.POSITION records to a given
** currency defined in DISPLAY.CCY in the selection criteria from the
** deal currency in the record
** The amounts are returned in O.DATA separated by a >
**
** As folows:
**  O.DATA<1> = Full amount
**  O.DATA<2> = Perc Amount
**  O.DATA<3> = Accrued Interest
**  O.DATA<4> = Committed Interest
**  O.DATA<5> = Other committed Int / Chg
**  O.DATA<6> = Other accrued Int / chg
*
* Modifications:
*
* 23/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 13/07/15 - Enhancement 1263704 / Task 1406519
*            Total LCCY is not displayed in Customer position enquiry
*
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING ST.Customer
    $USING ST.ExchangeRate
*
    OUT.CCY = EB.Reports.getOData()                   ; * Assume display ccy is passed
    OUT.AMT = ""
    IN.CCY = EB.Reports.getRRecord()<ST.Customer.CustomerPosition.CupDealCcy>
    IN.AMT = EB.Reports.getRRecord()<ST.Customer.CustomerPosition.CupDealAmount>
    IF IN.AMT THEN
        ST.ExchangeRate.Exchrate("1", IN.CCY, IN.AMT, OUT.CCY, OUT.AMT, "", "", "", "", "")
    END ELSE
        IN.AMT = OUT.AMT
    END
    EB.Reports.setOData(OUT.AMT)
*
    IN.AMT = EB.Reports.getRRecord()<ST.Customer.CustomerPosition.CupPercAmount> ; OUT.AMT = ""
    IF IN.AMT THEN
        ST.ExchangeRate.Exchrate("1", IN.CCY, IN.AMT, OUT.CCY, OUT.AMT, "", "", "", "", "")
    END ELSE
        IN.AMT = OUT.AMT
    END
    tmp.Odata = EB.Reports.getOData()
    EB.Reports.setOData(tmp.Odata:">":OUT.AMT)
*
    IN.AMT = EB.Reports.getRRecord()<ST.Customer.CustomerPosition.CupAccruedInt> ; OUT.AMT = ""
    IF IN.AMT THEN
        ST.ExchangeRate.Exchrate("1", IN.CCY, IN.AMT, OUT.CCY, OUT.AMT, "", "", "", "", "")
    END
    tmp.Odata = EB.Reports.getOData()
    EB.Reports.setOData(tmp.Odata:">":OUT.AMT)
*
    IN.AMT = EB.Reports.getRRecord()<ST.Customer.CustomerPosition.CupCommittedInt> ; OUT.AMT = ""
    IF IN.AMT THEN
        ST.ExchangeRate.Exchrate("1", IN.CCY, IN.AMT, OUT.CCY, OUT.AMT, "", "", "", "", "")
    END
    tmp.Odata = EB.Reports.getOData()
    EB.Reports.setOData(tmp.Odata:">":OUT.AMT)
*
    IF EB.Reports.getRRecord()<ST.Customer.CustomerPosition.CupOtherCcy> THEN    ; * Use for other amt
        IN.CCY = EB.Reports.getRRecord()<ST.Customer.CustomerPosition.CupOtherCcy>
    END
*
    IN.AMT = EB.Reports.getRRecord()<ST.Customer.CustomerPosition.CupOthIntChgAmt> ; OUT.AMT = ""
    IF IN.AMT THEN
        ST.ExchangeRate.Exchrate("1", IN.CCY, IN.AMT, OUT.CCY, OUT.AMT, "", "", "", "", "")
    END
    tmp.Odata = EB.Reports.getOData()
    EB.Reports.setOData(tmp.Odata:">":OUT.AMT)
*
    IN.AMT = EB.Reports.getRRecord()<ST.Customer.CustomerPosition.CupOthIntChgAcc> ; OUT.AMT = ""
    IF IN.AMT THEN
        ST.ExchangeRate.Exchrate("1", IN.CCY, IN.AMT, OUT.CCY, OUT.AMT, "", "", "", "", "")
    END
    tmp.Odata = EB.Reports.getOData()
    EB.Reports.setOData(tmp.Odata:">":OUT.AMT)
*
    RETURN
*-----------------------------------------------------------------------------
    END
