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
* <Rating>-26</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AD.ModelBank
    SUBROUTINE V.TT.FUND.CCY.VALIDATE
*
*-----------------------------------------------------------------------------
* This Subroutine is used to check whether the inputted currency is local or FCY
*-----------------------------------------------------------------------------
* Modification History :
*
* 12-05-14 - DEFECT - 987410
*            TASK - 995513/995525
*-----------------------------------------------------------------------------

    $USING ST.CompanyCreation
    $USING EB.ErrorProcessing
    $USING EB.SystemTables



    GOSUB INIT
    GOSUB PROCESS
    RETURN

*-------------------------------------------------------------------------------
INIT:
*-------------------------------------------------------------------------------
*Initiliase neccessary variable.

    CHECK.CURRENCY = EB.SystemTables.getComi()
    LOCAL.CURRENCY.COMP = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComLocalCurrency)

    RETURN

*-------------------------------------------------------------------------------
PROCESS:
*-------------------------------------------------------------------------------
*Check whether LCY equals inputted currency, then raise error.

    IF CHECK.CURRENCY = LOCAL.CURRENCY.COMP THEN
        EB.SystemTables.setEtext("TT-LOCAL.CCY.NOT.ALLOWED")
        EB.ErrorProcessing.StoreEndError()
    END

    RETURN
    END
