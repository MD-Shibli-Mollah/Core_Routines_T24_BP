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

* Version 2 10/09/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-39</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Closeout
    SUBROUTINE DX.EVAL.OPTION.IN.THE.MONEY(IN.THE.MONEY,CALL.PUT, INT.STRIKE, PRICE.DIFF, INT.MKT.PRICE, OFFSET)
*
*-----------------------------------------------------------------------------
* I/O Parameters
* Param              Dir    Desc
* IN.THE.MONEY     - OUT  - Flag True if option in the money, otherwise False
* CALL.OR.PUT      - IN   - Is this for a call or a put option.
* INT.STRIKE       - IN   - Strike price in internal format
* PRICE.DIFF       - IN   - Adjustment amount - also be in internal format for compatibility.
* MARKET.PRICE     - IN   - Market price in internal format
* OFFSET           - IN   - Flag True if the offset is set in contract master, otherwise false
*
* This routine evaluates if an option is in the money for a given strike and market price.
* The view point is from the option BUYER since they will have the right to exercise
* when its profitable.
*     The price difference reflects any offset amounts so some options which are in the money,
* once costs of exercise have been incurred, would no longer be profitable to exercise.
*     Conversely the price difference can be negative (for system expiry) where out of the
* money options may still be in the money when compared against price difference.
* This happens when an Exchange regulates that not all options which are slightly out
* of the money should be automatically expired and there is a "grey area" where some
* holders may wish still to exercise.
*-----------------------------------------------------------------------------
*MODIFICATION HISTORY
*-----------------------------------------------------------------------------
* 17/04/02 - EN_10000560
*           Baselined
*
* 30/05/02 - EN_10000603
*            Revised for G13.
*
* 12/03/12 - Defect-13198 / Task-369870
*            During the closeout process by COB, System should consider the offset
*            defined in contract master before deciding whether to Expiry or Exercise.
*
* 05/02/16 - 1615094
*			 Incorporation of Components
*-----------------------------------------------------------------------------

    GOSUB S100.INITIALISE
    GOSUB S1000.PROCESS

    RETURN

*================================================================================
S100.INITIALISE:

    IN.THE.MONEY = ""
    IN.THE.MONEY.AMT = 0

    RETURN

*================================================================================
S1000.PROCESS:
*
* Step 1. Basically:-
*     For a Call option, where buyer is purchasing the underlying, an option is
*     in the money if the strike price is be below the market price.
*     For a Put option, where buyer is selling the underlying, an option is
*     in the money if the strike price must be above the market price.
*
*     Therefore by switching the sign accordingly, can use same principle formula
*

    IF CALL.PUT = "CALL" THEN
        MULT.SIGN = +1
    END ELSE
        MULT.SIGN = -1
    END

* Include the offset price along with original market price
    IF OFFSET THEN
        INT.MKT.PRICE = INT.MKT.PRICE + PRICE.DIFF
    END

    IN.THE.MONEY.AMT = MULT.SIGN * (INT.MKT.PRICE - INT.STRIKE)

    GOSUB CHK.IN.THE.MONEY

    RETURN


CHK.IN.THE.MONEY:

* Finds whether in the money are out of money

    IF IN.THE.MONEY.AMT GE 0 THEN
        IN.THE.MONEY = @TRUE
    END ELSE
        IN.THE.MONEY = @FALSE
    END

    RETURN

*================================================================================

* <new subroutines>
*================================================================================

    END
