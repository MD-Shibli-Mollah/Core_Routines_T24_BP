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
* <Rating>26</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Contract
    SUBROUTINE UKRAINE.SW.PRIN.ADJUST(PRIN.ARRAY, ACCRUAL.PARAM.ID, R.ACCRUAL.PARAM, CONTRACT.ID)

    $USING SW.Contract
    $USING SW.Foundation
    $USING EB.API
***********************************************************************************************************
*
*  This routine is provided as source code as it does not form part of the GLOBUS core
*  it has been developed as an example to aloow interest caluclations to conform with market
*  practice for deposits in the Ukraine.
*  Any changes necessary for this routine need to be made locallyas it will not be maintained as
*  part of the GLOBUS core.
*  It is recomended that this routine is copied into a local BP and will need to be recompiled whenever
*  GLOBUS is upgraded.
*
***********************************************************************************************************
*
* 30/12/15 - Enhancement 1226121
*		   - Task 1569212
*		   - Routine incorporated
*
***********************************************************************************************************
** This subroutine will return an adjusted principal array, For Ukraine the rules are
** increases add 1 day, decrease keep the day the same
** Format of the array
**  PRIN.ARRAY<1,x> - Effective Date
**  PRIN.ARRAY<2,x> - Principal Balance
**
** For the swaps we needs to look at each principal movement. This information is contained
** in the Swap Balances record for the CONTRACT.ID supplied in the following fields:
**  SW.BAL.SCHEDULE.TYPE  - Type of schedule we'll base increase / decrease on this
**  SW.BAL.PROCESS.DATE   - Date processed
**  SW.BAL.SCHED.EFF.DATE - The effective date for the principal we'll adjust this if need be
**  SW.BAL.CCY.AMOUNT     - The amount to use (unsigned)
**
** Schedule types are classified as follows:
**  CI - Increase
**  PI - Increase
**  NI - Increase
**  CM - Decrease
**  PD - Decrease
**  ND - Decrease
** Other types PX, RX, RR etc can be ignored
** for a swap with monthly schedules this routine will be called for every month even
** when the principal data does not change
** store some data in common to avoid having to keep building the data for each period
** and allow debug to take place
*************************************************************************************************************



    GOSUB INITIALISE
    GOSUB PROCESS.SWAP.BALANCE
    FIRST.TIME = "NO"
*
    RETURN
*
*--------------------------------------------------------------------------------------------
INITIALISE:
*==========
** Read the swap balances record or build from SW.COMMON
*
    CONTRACT = CONTRACT.ID
    IN.PRIN.DATA = PRIN.ARRAY
    NEW.PRIN.ARRAY = ''
    NO.AMTS = DCOUNT(PRIN.ARRAY<2>,@VM)
    START.AMOUNT = PRIN.ARRAY<2,NO.AMTS>
    START.DATE = PRIN.ARRAY<1,NO.AMTS>  ;* First Date in the array
*
    INCREASE.TYPES = 'CI':@VM:'PI':@VM:'NI'
    DECREASE.TYPES = 'CM':@VM:'PD':@VM:'ND'
*
    LEG.TYPE = FIELD(CONTRACT.ID,'-',2)
    CONTRACT.ID = FIELD(CONTRACT.ID,'-',1)
    IF LEG.TYPE = 'A' THEN
        R.SWAP.BALANCES = SW.Foundation.getRSwAssetBalances()
    END ELSE
        R.SWAP.BALANCES = SW.Foundation.getRSwLiabilityBalances()
    END

*
    RETURN
*
*--------------------------------------------------------------------------------------------
PROCESS.SWAP.BALANCE:
*====================
*
* for an increase add 1 to the balance date
* net the movements for each day
* so if we have a decrease of 10,000 on the 20th and an increase of 50,000 on the 19th
* the net movement for the 20th is +40,000
*
* build net movement array with oldest date first
    SCHED.COUNT = DCOUNT(R.SWAP.BALANCES<SW.Contract.SwapBalances.BalScheduleType>,@VM)
    FOR IDX = 1 TO SCHED.COUNT
        SCHED.TYPE = R.SWAP.BALANCES<SW.Contract.SwapBalances.BalScheduleType, IDX>
        SCHED.DATE = R.SWAP.BALANCES<SW.Contract.SwapBalances.BalSchedEffDate, IDX>
        SCHED.AMT = R.SWAP.BALANCES<SW.Contract.SwapBalances.BalCcyAmount,IDX>
        BEGIN CASE
            CASE SCHED.TYPE MATCHES INCREASE.TYPES
                GOSUB INCREMENT.DATE
                GOSUB ADD.MOVEMENT
            CASE SCHED.TYPE MATCHES DECREASE.TYPES
                SCHED.AMT *= -1
                GOSUB ADD.MOVEMENT
        END CASE
        *
    NEXT IDX
*
    NO.DATES = DCOUNT(NEW.PRIN.ARRAY<2>,@VM)
    FOR X = 2 TO NO.DATES     ;* now build the actual balances
        NEW.PRIN.ARRAY<2,X> += NEW.PRIN.ARRAY<2,X-1>
    NEXT X

    PRIN.ARRAY = "" ; I = 0   ;* New prin array was built in reverse order
    FOR X = NO.DATES TO 1 STEP -1
        I += 1
        PRIN.ARRAY<1,I> = NEW.PRIN.ARRAY<1,X>
        PRIN.ARRAY<2,I> = NEW.PRIN.ARRAY<2,X>
        IF PRIN.ARRAY<2,I> LT 0 THEN PRIN.ARRAY<2,I> = 0    ;* If < 0 set returned amount to 0
    NEXT X
    OUT.PRIN.DATA = PRIN.ARRAY
*
* pass back prinicpal array with oldest date last
*
    RETURN
*
*--------------------------------------------------------------------------------------------
INCREMENT.DATE:
*==============
** Add 1 calendar day to the date
*
    EB.API.Cdt("", SCHED.DATE, "+1C")
    RETURN
*
*--------------------------------------------------------------------------------------------
ADD.MOVEMENT:
*============
** Add the movement and date to the array  sign it to get the net movement for the day
** if we have a PI on the maturity date ( i.e. MAT date + 1) then ignore it
*
    IF SCHED.DATE LE R.SWAP.BALANCES<SW.Contract.SwapBalances.BalCrbMaturityDate> THEN
        LOCATE SCHED.DATE IN NEW.PRIN.ARRAY<1,1> BY 'AR' SETTING DATE.POS THEN
        NEW.PRIN.ARRAY<2, DATE.POS> += SCHED.AMT
    END ELSE
        INS SCHED.DATE BEFORE NEW.PRIN.ARRAY<1,DATE.POS>
        INS SCHED.AMT BEFORE NEW.PRIN.ARRAY<2, DATE.POS>
    END
    END
*
    RETURN
*
    END
