* @ValidationCode : MjotNzgzMzk3NTk0OkNwMTI1MjoxNDg5NjQ0NjkzNzI3OmhhcnJzaGVldHRncjotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzAyLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 16 Mar 2017 11:41:33
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
* <Rating>-23</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.FIXED.RATE.LEG2(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
*
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* report the fixed rate on the leg2 of the contract.
*
*
* Incoming parameters:
*
* APPL.ID	-	Transaction ID of the contract.
* APPL.REC	-	A dynamic array holding the contract.
* FIELD.POS	-	Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* RET.VAL	-	1. In case of fixed vs float, SPREAD of the floating leg wherever applicable.
*               2. In case of float vs fixed, spread of the floating leg wherever applicable.
*               3. In case of fix vs fix, leave blank
*               4. In case of Flt/Flt  populate the Spread of longer duration
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*-----------------------------------------------------------------------------


    $USING SW.Contract
    $USING OC.Reporting
    $USING SW.Foundation

*-----------------------------------------------------------------------------

    GOSUB INITIALIZE
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INITIALIZE:

    RET.VAL = ''
    
    assetFixedRate = APPL.REC<SW.Contract.Swap.AsFixedRate>
    liabFixedRate = APPL.REC<SW.Contract.Swap.LbFixedRate>
    
    assetRateKey = APPL.REC<SW.Contract.Swap.AsRateKey>
    liabRateKey = APPL.REC<SW.Contract.Swap.LbRateKey>
    
    assetSpread = APPL.REC<SW.Contract.Swap.AsSpread>
    liabSpread = APPL.REC<SW.Contract.Swap.LbSpread>

    RETURN
*-----------------------------------------------------------------------------

PROCESS:


    BEGIN CASE
        CASE APPL.ID[1,2] EQ 'SW'

            BEGIN CASE

                CASE assetFixedRate AND NOT(liabFixedRate)
                    RET.VAL = APPL.REC<SW.Contract.Swap.LbSpread>

                CASE NOT(assetFixedRate) AND liabFixedRate
                    RET.VAL = APPL.REC<SW.Contract.Swap.AsSpread>


                CASE assetRateKey AND liabRateKey   ;*  float float (basis swap)

* Fetch schedule type and date freq details fron the swap contract.

                    assetType = APPL.REC<SW.Contract.Swap.AsType>
                    liabType = APPL.REC<SW.Contract.Swap.LbType>
                    assetDateFreq = APPL.REC<SW.Contract.Swap.AsDateFreq>
                    liabDateFreq=APPL.REC<SW.Contract.Swap.LbDateFreq>

                    scheduleType = assetType
                    dateFrequency = assetDateFreq
                    GOSUB CHECK.FREQ ;*check for shorter frequency.

                    assetScheduleFreq = ScheduleFreq

                    scheduleType = liabType
                    dateFrequency = liabDateFreq
                    GOSUB CHECK.FREQ    ;*check for shorter frequency.

                    liabScheduleFreq = ScheduleFreq

                    GOSUB CHECK.LONG.DURATION ;* check for longer duration.

            END CASE
    END CASE


    RETURN
*-----------------------------------------------------------------------------
*** <region name= CHECK.FREQ>
CHECK.FREQ:
*** <desc> </desc>

*Locate IP schedule

    LOCATE 'IP' IN scheduleType<1,1> SETTING POS THEN
    IpDateFrequency = dateFrequency<1,POS>;*fetch the date freq of corresponding IP schedule.
    END

    frequencyType = IpDateFrequency[9,5];*Fetch freq part from the date entered..

    IF frequencyType NE '' THEN;*if freq defined and not adhoc schedule

        BEGIN CASE

            CASE frequencyType[1,1] EQ 'D';*for daily freq

                ScheduleFreq = 1

            CASE frequencyType[1,1] EQ 'W';*for weekly freq

                ScheduleFreq = 2

            CASE frequencyType[1,1] EQ 'M';*for monthly freq

                ScheduleFreq = 3

        END CASE

    END
    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= CHECK.LONG.DURATION>
CHECK.LONG.DURATION:
*** <desc> </desc>

    BEGIN CASE

        CASE assetScheduleFreq GT liabScheduleFreq  ;*Asset Ip payments scheduled for shorter duration.

            RET.VAL = APPL.REC<SW.Contract.Swap.AsSpread>

        CASE liabScheduleFreq GT assetScheduleFreq  ;*Liability payments scheduled for shorter duration.

            RET.VAL = APPL.REC<SW.Contract.Swap.LbSpread>

    END CASE


    RETURN
*** </region>


*-----------------------------------------------------------------------------

    END
