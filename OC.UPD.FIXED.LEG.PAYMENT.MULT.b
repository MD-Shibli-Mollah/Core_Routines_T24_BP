* @ValidationCode : MjotMTg1NzU4NTQzMzpDcDEyNTI6MTU4MzIyMTEwMzQ5Njpwcml5YWRoYXJzaGluaWs6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMi4yMDIwMDExNy0yMDI2OjYwOjQ4
* @ValidationInfo : Timestamp         : 03 Mar 2020 13:08:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : priyadharshinik
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 48/60 (80.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.FIXED.LEG.PAYMENT.MULT(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
*
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* report the multiplier defined on the fixed leg of the contract.
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
*               6M  - 6
*               2W -  2
*               D   - 1
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 21/02/2020 - Enhancement 3568600 / Task 3568601
*              CI#4 -Mapping of TX.TXN.BASE.MAPPING and related routines
*
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING OC.Reporting
    $USING SW.Contract

*-----------------------------------------------------------------------------
    GOSUB INITIALIZE
    GOSUB PROCESS


RETURN
*-----------------------------------------------------------------------------
INITIALIZE:

    RET.VAL = ''
    SCHEDULE.TYPE = ''
    SCHEDULE.FREQ = ''
    IP.DATE.FREQ = ''
    FREQ = ''
    FIXED.RATE.LEG1 = ''
    CPARTY.SIDE = ''

RETURN
*-----------------------------------------------------------------------------


PROCESS:

*To get the value from the field FIXED.RATE.LEG1.
    OC.Reporting.UpdFixedRateLeg1(APPL.ID, APPL.REC, FIELD.POS, FIXED.RATE.LEG1)
    
    IF FIXED.RATE.LEG1 THEN
        OC.Reporting.UpdCpartySide(APPL.ID,APPL.REC,FIELD.POS,CPARTY.SIDE)

        BEGIN CASE
            CASE CPARTY.SIDE = 'S'
                SCHEDULE.TYPE = APPL.REC<SW.Contract.Swap.AsType>
                SCHEDULE.FREQ = APPL.REC<SW.Contract.Swap.AsDateFreq>
                GOSUB SCHED.VALUE

            CASE CPARTY.SIDE = 'B'
                SCHEDULE.TYPE = APPL.REC<SW.Contract.Swap.LbType>
                SCHEDULE.FREQ = APPL.REC<SW.Contract.Swap.LbDateFreq>
                GOSUB SCHED.VALUE
        END CASE
    
    END

RETURN

**-----------------------------------------------------------------------------

SCHED.VALUE:


* Locate IP schedule
* Fetch the date frequency of corresponding IP schedule.
    LOCATE 'IP' IN SCHEDULE.TYPE<1,1> SETTING POS THEN
        IP.DATE.FREQ = SCHEDULE.FREQ<1,POS>
    END

* Fetch frequency part from the date entered..
    FREQ = IP.DATE.FREQ[9,1]

* If frequency defined and not adhoc schedule
    IF FREQ NE '' THEN
        BEGIN CASE
            
            CASE FREQ EQ "M"                       ;*Monthly frequency
                
                BEGIN CASE
                    
                    CASE IP.DATE.FREQ[10,1] EQ "0"  ;*For eg: If month is 04 then multiplier is "4"
                        RET.VAL = IP.DATE.FREQ[11,1]
                        
                    CASE IP.DATE.FREQ[10,1] NE "0"
                        IF IP.DATE.FREQ[10,2] GE "12" THEN ;*If Month is greater than or equal to 12, then it consider as yearly basis so divide by 12
                            MoreThanYear = ''
                            MonthMultiplier = ''
                            MoreThanYear = IP.DATE.FREQ[10,2] / 12
                            MonthMultiplier = FIELD(MoreThanYear,".",1)
                            RET.VAL = MonthMultiplier
                        END ELSE
                            RET.VAL = IP.DATE.FREQ[10,2]
                        END
                END CASE
                
            CASE FREQ EQ "D" OR IP.DATE.FREQ[9,5] EQ "BSNSS"   ;*daily frequency
                RET.VAL = "1"
                
            CASE FREQ EQ "W"                    ;*Weekly frequency
                RET.VAL = IP.DATE.FREQ[13,1]
                
            CASE IP.DATE.FREQ[9,5] EQ "TWMTH" OR  IP.DATE.FREQ[9,5] EQ "LHFYR" ;*Twice Monthly or Half month in year
                RET.VAL = "2"
                 
            CASE (IP.DATE.FREQ[9,5] EQ "LWEEK") OR (IP.DATE.FREQ[9,5] EQ "LYEAR") OR (IP.DATE.FREQ[9,5] EQ "LMNTH")
                RET.VAL = "1"
   
            CASE IP.DATE.FREQ[9,5] EQ "LQUAT"  ;*Quartely
                RET.VAL = "3"
                    
        END CASE
    END
RETURN
**-----------------------------------------------------------------------------
END
