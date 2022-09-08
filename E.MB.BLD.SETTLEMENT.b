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
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.BLD.SETTLEMENT(ENQ.DATA)
*-----------------------------------------------------------------------------
* MODIFICATION
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING ST.CurrencyConfig
    $USING EB.API

    DELI.DAYS = ''
    DT = ''
    DT2 = ''

    LOCATE "CURRENCY" IN ENQ.DATA<2,1> SETTING CR.POS THEN
    V.CURR = ENQ.DATA<4,CR.POS>
    IF V.CURR NE '' THEN
        R.CURR = ST.CurrencyConfig.tableCurrency(V.CURR,ERR.CURR)
        IF R.CURR NE '' THEN
            DELI.DAYS = R.CURR<ST.CurrencyConfig.Currency.EbCurDaysDelivery>
            DT = EB.SystemTables.getToday()
            D.DAYS ="+":DELI.DAYS:"W"
            EB.API.Cdt("",DT,D.DAYS)
            DT2 = DT
            EB.API.Cdt("",DT2,"+1W")
        END
    END
    END ELSE
    DT = EB.SystemTables.getToday()
    DT2 = DT
    EB.API.Cdt("",DT2,"+1W")

    END

    VDATE.POS = DCOUNT(ENQ.DATA<2>,@VM) + 1

    ENQ.DATA<2,VDATE.POS> = 'VALUE.DATE'
    ENQ.DATA<3,VDATE.POS> = 'RG'
    ENQ.DATA<4,VDATE.POS> = DT:" ":DT2

    RETURN
*-----------------------------------------------------------------------------
    END
