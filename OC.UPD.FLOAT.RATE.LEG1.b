* @ValidationCode : MjotOTQxMzMyNDc2OkNwMTI1MjoxNDg5NjQ0NjkzNjY1OmhhcnJzaGVldHRncjotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzAyLjA6LTE6LTE=
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
* <Rating>-22</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.FLOAT.RATE.LEG1(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
*
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* report the floating rate on the leg1 on the contract.
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
* RET.VAL	-	1. Applicable only for Float vs float.
*               2. In case of float / float, then 
*                   2.a In case of different duration, Rate Key of the shorter duration leg
*                   2.b. In case of same duration, Rate key of the leg which has the spread
*                   2.c In case of same duration, if spread on both legs, then blank
*                   2.d. In case of same duration, if no spread then blank
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

*-----------------------------------------------------------------------------
    GOSUB INITIALIZE
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INITIALIZE:

    RET.VAL = ''
    
    assetRateKey = APPL.REC<SW.Contract.Swap.AsRateKey>
    liabRateKey = APPL.REC<SW.Contract.Swap.LbRateKey>


    RETURN
*-----------------------------------------------------------------------------

PROCESS:


    BEGIN CASE
        CASE APPL.ID[1,2] EQ 'SW'

            BEGIN CASE

                CASE assetRateKey AND liabRateKey   ;*float float (basis swap)

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

                    GOSUB CHECK.SHORT.DURATION ;* check for shorter duration.

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

*** <region name= CHECK.SHORT.DURATION>
CHECK.SHORT.DURATION:
*** <desc> </desc>

    BEGIN CASE

        CASE assetScheduleFreq EQ liabScheduleFreq  ;*In case of same duration,check for spread.

            GOSUB CHECK.SPREAD  ;*if spread undefined,then logic open for clients.

        CASE assetScheduleFreq LT liabScheduleFreq  ;*Asset Ip payments scheduled for shorter duration.

            RET.VAL = APPL.REC<SW.Contract.Swap.AsRateKey>

        CASE liabScheduleFreq LT assetScheduleFreq  ;*Liability payments scheduled for shorter duration.

            RET.VAL = APPL.REC<SW.Contract.Swap.LbRateKey>

    END CASE


    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= CHECK.SPREAD>
CHECK.SPREAD:
*** <desc> </desc>

    assetSpread = APPL.REC<SW.Contract.Swap.AsSpread>
    liabSpread = APPL.REC<SW.Contract.Swap.LbSpread>

    BEGIN CASE

        CASE assetSpread AND NOT(liabSpread)

            RET.VAL = APPL.REC<SW.Contract.Swap.AsRateKey>   ;*T24 bank receives spread.

        CASE liabSpread AND NOT(assetSpread);*T24 bank pays spread..hence buyer.

            RET.VAL = APPL.REC<SW.Contract.Swap.LbRateKey>

    END CASE

*If spread defined on both sides,then logic open for clients.

    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END
