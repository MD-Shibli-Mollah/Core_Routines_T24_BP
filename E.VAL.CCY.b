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

* Version 4 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PM.Reports
    SUBROUTINE E.VAL.CCY

* This subroutine will validate that any selection made by an equiry
* select is a valid currency code.
*
* 19/09/02 - EN_10001174
*            Conversion of error messages to error codes.
*
* 26/10/15 - EN_1226121 / Task 1511358
*	      	 Routine incorporated
*
*---------------------------------------------------------------------
    $USING EB.DataAccess
    $USING EB.Template
    $USING ST.CurrencyConfig
    $USING EB.SystemTables
    $USING EB.Reports

    F.CURRENCY.LOC = ''
    CURRENCY.FILE = 'F.CURRENCY'
    EB.DataAccess.Opf(CURRENCY.FILE, F.CURRENCY.LOC)
    EB.SystemTables.setFCurrency(F.CURRENCY.LOC)

    EB.SystemTables.setE('')
    EB.SystemTables.setEtext('')

* First call IN2CYY

    EB.SystemTables.setComi(EB.Reports.getOData())
    N1 = '3.1'
    T1 = 'CCY'
    EB.Template.In2ccy(N1, T1)

    EB.Reports.setOData(EB.SystemTables.getComi())

    tmp.ETEXT = EB.SystemTables.getEtext()
    IF NOT(tmp.ETEXT) THEN

        CCY.ID = EB.SystemTables.getComi()
        ER = ""
        CCY.REC = ST.CurrencyConfig.Currency.Read(CCY.ID, ER)
        IF ER THEN
            EB.SystemTables.setEtext('PM.RTN.INVALID.CCY.CODE':@FM:CCY.ID)
        END

    END

    EB.SystemTables.setE(EB.SystemTables.getEtext())

    RETURN


******
    END
