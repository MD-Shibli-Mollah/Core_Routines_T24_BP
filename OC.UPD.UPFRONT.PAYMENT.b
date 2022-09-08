* @ValidationCode : MjoxMzkzNTE1OTA3OkNwMTI1MjoxNDg5NjY0MjAzODc2OmhhcnJzaGVldHRncjotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzAyLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 16 Mar 2017 17:06:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-62</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.UPFRONT.PAYMENT(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*
*<Routine description>
*
* The routine will determine the amount of any upfront payment done.
* Attached as a link routine in TX.TXN.BASE.MAPPING record to report
* the upfront payments on the contract.
*
*
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* RET.VAL   -   PM/RV amounts on the balances record
*               IF only PM
*               IF only RV
*               IF PM and RV
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*-----------------------------------------------------------------------------

    $USING SW.Contract
    $USING SW.Foundation


*-----------------------------------------------------------------------------

    GOSUB INITIALIZE
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INITIALIZE:

    RET.VAL = ''
    PM.LIAB.AMT = ''
    RV.ASST.AMT = ''
    ACT.PM.LIAB.AMT = '0'
    SCHED.TYPE.LIST = 'RV':@VM:'PM'

    RETURN

*-----------------------------------------------------------------------------

CALC.RV.AMT:

    FOR I = 1 TO NO.OF.SCHEDULES
        IF (ASST.SCHEDULE.TYPE<1,I> EQ 'RV')  THEN
            RV.ASST.AMT = RV.ASST.AMT + SW.Foundation.getRSwAssetBalances()<SW.Contract.SwapBalances.BalCcyAmount, I>
        END
    NEXT I

    RETURN
*-----------------------------------------------------------------------------
CALC.PM.AMT:

    FOR I = 1 TO NO.OF.SCHEDULES
        IF (LIAB.SCHEDULE.TYPE<1,I> EQ 'PM')  THEN
               PM.LIAB.AMT = PM.LIAB.AMT + SW.Foundation.getRSwLiabilityBalances()<SW.Contract.SwapBalances.BalCcyAmount, I>
        END
    NEXT I

    RETURN
*-----------------------------------------------------------------------------

PROCESS:

* Process Asset leg for PM/RV
    ASST.SCHEDULE.TYPE = SW.Foundation.getRSwAssetBalances()<SW.Contract.SwapBalances.BalScheduleType>
    NO.OF.SCHEDULES= DCOUNT(ASST.SCHEDULE.TYPE,@VM)
    GOSUB CALC.RV.AMT
*       LOCATE 'RV' IN R$SW.ASSET.BALANCES<SW.BAL.SCHEDULE.TYPE,1> SETTING RVAMPOS THEN
*           RV.ASST.AMT = R$SW.ASSET.BALANCES<SW.BAL.CCY.AMOUNT, RVAMPOS>
*       END

* Process Liab leg for PM/RV
    LIAB.SCHEDULE.TYPE = SW.Foundation.getRSwLiabilityBalances()<SW.Contract.SwapBalances.BalScheduleType>
    NO.OF.SCHEDULES= DCOUNT(LIAB.SCHEDULE.TYPE,@VM)
    GOSUB CALC.PM.AMT
*   LOCATE 'PM' IN R$SW.LIABILITY.BALANCES<SW.BAL.SCHEDULE.TYPE,1> SETTING PMLMPOS THEN
*       PM.LIAB.AMT = R$SW.LIABILITY.BALANCES<SW.BAL.CCY.AMOUNT, PMLMPOS>
*   END

* Its recomended that a RV schedule to be booked under Asset
* And PM to be booked under liability

* If only PM
* Return value -> PM amount multiplied by -1, since payment is always liability

* If only RV
* Return value -> RV amount, since reciept of premium is always bank's asset

* If both PM and RV are available on the Liability/Asset respectively then
* Example
* PM - Case 1 - 1000/ Case 2 - 3000
* RV - Case 1 - 3000/ Case 2 - 1000

* APM = -1000/-3000
* RV = 3000/1000

*IF PM < RV (1000 < 3000)
*Case 1 : (-1000+3000) = 2000
* IF PM > RV (3000 > 1000)
*Case 2 : (-3000+1000) = -2000

* PM - Payment schedule is always a liability, so should be negative
    ACT.PM.LIAB.AMT = -1 * PM.LIAB.AMT

    IF RV.ASST.AMT GE '0' AND PM.LIAB.AMT EQ '' THEN
        RET.VAL = RV.ASST.AMT
    END

    IF RV.ASST.AMT EQ '' AND PM.LIAB.AMT GE '0' THEN
        RET.VAL = ACT.PM.LIAB.AMT
    END

    IF RV.ASST.AMT GE '0' AND PM.LIAB.AMT GE '0' THEN
        RET.VAL = ACT.PM.LIAB.AMT + RV.ASST.AMT
    END

    RETURN

*-----------------------------------------------------------------------------

    END
