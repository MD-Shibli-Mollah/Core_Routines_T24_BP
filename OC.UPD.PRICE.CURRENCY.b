* @ValidationCode : MjoxNjgzNjA3NjkzOkNwMTI1MjoxNTgwMjE0MTA3OTk3OnByaXlhZGhhcnNoaW5pazo0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAxLjIwMTkxMjI0LTE5MzU6MjQ6MjQ=
* @ValidationInfo : Timestamp         : 28 Jan 2020 17:51:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : priyadharshinik
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 24/24 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191224-1935
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.PRICE.CURRENCY(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* FOREX - It returns BASE CURRENCY.
* For SWAP, the notional ccurency 1 is returned
*-----------------------------------------------------------------------------
* Modification History :
*
* 31/01/2020 - Enhancement 3562849 / Task 3562851
*              CI #3 - Mapping Routines
*
*-----------------------------------------------------------------------------
*******************************************************************
*
*
* Incoming parameters:
*
* APPL.ID   - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* Ret.val- Variable holding the value of PRICE NOTATION.
*
*
*******************************************************************

    $USING FX.Contract
    $USING SW.Contract
    $USING ST.CurrencyConfig
    $USING OC.Reporting

*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB DETERMINE.FOR.T24.BANK

RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>INITIALISE </desc>

    CURRENCY=''
    RET.VAL=''

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
DETERMINE.FOR.T24.BANK:
*** <desc>PROCESS </desc>


    BEGIN CASE
* FOREX- IT return BASE CURRENCY
        CASE APPL.ID[1,2] EQ 'FX';*Sort the 2 currencies alphabetically.

            CURRENCY<1> =APPL.REC<FX.Contract.Forex.CurrencyBought>
            CURRENCY<2> =APPL.REC<FX.Contract.Forex.CurrencySold>

            IF APPL.REC<FX.Contract.Forex.Quantity> EQ '' THEN

                RET.VAL = APPL.REC<FX.Contract.Forex.BaseCcy>

            END ELSE

                ST.CurrencyConfig.GetCurrencyRecord('',CURRENCY<1>,R.CURRENCY,READ.ERR)

                IF R.CURRENCY<ST.CurrencyConfig.Currency.EbCurPreciousMetal> EQ "YES" THEN
                    RET.VAL = CURRENCY<1>
                END ELSE
                    RET.VAL =CURRENCY<2>
                END
            END

* For SWAP, the notional ccurency 1 is returned
        CASE APPL.ID[1,2] = 'SW'

            OC.Reporting.UpdNotionalCcy1(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)

    END CASE

RETURN
*** </region>

*-----------------------------------------------------------------------------


END
