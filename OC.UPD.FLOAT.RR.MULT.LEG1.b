* @ValidationCode : MjotNTQwODQ2NzgxOkNwMTI1MjoxNTgzMjIxMTAyODc5OnByaXlhZGhhcnNoaW5pazoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAyLjIwMjAwMTE3LTIwMjY6NTg6MzY=
* @ValidationInfo : Timestamp         : 03 Mar 2020 13:08:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : priyadharshinik
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 36/58 (62.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.FLOAT.RR.MULT.LEG1(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
*
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* report multiplier defined for the rate reset's on the contract.
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
* RET.VAL   -   In a readable format as below
*       Ex      1M  - 1
*               3M  - 3
*               D   - 1
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 21/02/2020 - Enhancement 3568600 / Task 3568601
*              CI#4 -Mapping of TX.TXN.BASE.MAPPING and related routines
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
    CPARTY.SIDE = ''
    SCHEDULE.TYPE = ''
    SCHEDULE.FREQ = ''
    RR.DATE.FREQ = ''
    FLOAT.RATE.LEG1 = ''
    
RETURN
*-----------------------------------------------------------------------------

PROCESS:

*To get the value from the field FLOAT.LEG.RATE1
    
    OC.Reporting.UpdFloatRateLeg1(APPL.ID,APPL.REC,FIELD.POS, FLOAT.RATE.LEG1)
    
    IF FLOAT.RATE.LEG1  THEN
        OC.Reporting.UpdCpartySide(APPL.ID,APPL.REC,FIELD.POS,CPARTY.SIDE)
    
        BEGIN CASE
            CASE CPARTY.SIDE = 'S'
                SCHEDULE.TYPE = APPL.REC<SW.Contract.Swap.LbType>
                SCHEDULE.FREQ = APPL.REC<SW.Contract.Swap.LbDateFreq>
                GOSUB SCHED.VALUE

            CASE CPARTY.SIDE = 'B'
                SCHEDULE.TYPE = APPL.REC<SW.Contract.Swap.AsType>
                SCHEDULE.FREQ = APPL.REC<SW.Contract.Swap.AsDateFreq>
                GOSUB SCHED.VALUE
        END CASE
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
    FREQ = RR.DATE.FREQ[9,1]

* If frequency defined and not adhoc schedule
    IF FREQ NE '' THEN
        BEGIN CASE
            
            CASE FREQ EQ "M"                       ;*Monthly frequency
                
                BEGIN CASE
                    
                    CASE RR.DATE.FREQ[10,1] EQ "0"  ;*For eg: If month is 04 then multiplier is "4"
                        RET.VAL = RR.DATE.FREQ[11,1]
                        
                    CASE RR.DATE.FREQ[10,1] NE "0"
                        IF RR.DATE.FREQ[10,2] GE "12" THEN ;*If Month is greater than or equal to 12, then it consider as yearly basis so divide by 12
                            MoreThanYear = ''
                            MonthMultiplier = ''
                            MoreThanYear = RR.DATE.FREQ[10,2] / 12
                            MonthMultiplier = FIELD(MoreThanYear,".",1)
                            RET.VAL = MonthMultiplier
                        END ELSE
                            RET.VAL = RR.DATE.FREQ[10,2]
                        END
                END CASE
                
            CASE FREQ EQ "D" OR RR.DATE.FREQ[9,5] EQ "BSNSS"                    ;*daily frequency
                RET.VAL = "1"
                
            CASE FREQ EQ "W"                    ;*Weekly frequency
                RET.VAL = RR.DATE.FREQ[13,1]
                
            CASE RR.DATE.FREQ[9,5] EQ "TWMTH" OR  RR.DATE.FREQ[9,5] EQ "LHFYR" ;*Twice Monthly or Half month in year
                RET.VAL = "2"
                 
            CASE (RR.DATE.FREQ[9,5] EQ "LWEEK") OR (RR.DATE.FREQ[9,5] EQ "LYEAR") OR (RR.DATE.FREQ[9,5] EQ "LMNTH")
                RET.VAL = "1"
   
            CASE RR.DATE.FREQ[9,5] EQ "LQUAT"  ;*Quartely
                RET.VAL = "3"
                    
        END CASE
    END

END
