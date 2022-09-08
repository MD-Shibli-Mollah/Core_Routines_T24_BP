* @ValidationCode : MjotNjY0NTk3MTcwOmNwMTI1MjoxNDg3MDc4NDk4ODMwOmhhcnJzaGVldHRncjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMDItMTE0MjotMTotMQ==
* @ValidationInfo : Timestamp         : 14 Feb 2017 18:51:38
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201612.20161102-1142
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-37</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.FLOAT.RR.FREQ(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
*
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* report frequency defined for the rate reset's on the contract.
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
* RET.VAL	-	In a readable format as below
*		Ex		1M 	- 1 Month
*				2W 	- 2 Weeks
*				D	- Daily
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

    RETURN
*-----------------------------------------------------------------------------

PROCESS:

    OC.Reporting.UpdCpartySide(APPL.ID,APPL.REC,FIELD.POS,CPARTY.SIDE)

    IF CPARTY.SIDE = 'S' THEN
        SCHEDULE.TYPE = APPL.REC<SW.Contract.Swap.LbType>
        SCHEDULE.FREQ = APPL.REC<SW.Contract.Swap.LbDateFreq>
        GOSUB SCHED.VALUE
        RETURN
    END
    IF CPARTY.SIDE = 'B' THEN
        SCHEDULE.TYPE = APPL.REC<SW.Contract.Swap.AsType>
        SCHEDULE.FREQ = APPL.REC<SW.Contract.Swap.AsDateFreq>
        GOSUB SCHED.VALUE
    END


    RETURN

*-----------------------------------------------------------------------------

SCHED.VALUE:


* Locate RR schedule
* Fetch the date frequency of corresponding RR schedule.
    LOCATE 'RR' IN SCHEDULE.TYPE<1,1> SETTING POS THEN
    RR.DATE.FREQ = SCHEDULE.FREQ<1,POS>
    END

* Fetch frequency part from the date entered
    FREQ = RR.DATE.FREQ[9,5]

* If frequency defined and not adhoc schedule
    IF FREQ NE '' THEN
        BEGIN CASE
            CASE FREQ[1,1] EQ 'D';*for daily freq
                RET.VAL = 'Daily'

            CASE FREQ[1,1] EQ 'W';*for weekly freq
                NO.WEEKS = FREQ[5,2]
                RET.VAL =  NO.WEEKS : 'W'

            CASE FREQ[1,1] EQ 'M';*for monthly freq
                NO.MNTHS = FREQ[2,2]
                RET.VAL = NO.MNTHS : 'M'

        END CASE

    END
    RETURN

    END
