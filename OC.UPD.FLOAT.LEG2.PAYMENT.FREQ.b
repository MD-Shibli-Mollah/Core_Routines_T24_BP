* @ValidationCode : MjotMTI2NzQ3OTE4NjpDcDEyNTI6MTU4MzIyMTEwMTMxMjpwcml5YWRoYXJzaGluaWs6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMi4yMDIwMDExNy0yMDI2OjUwOjQw
* @ValidationInfo : Timestamp         : 03 Mar 2020 13:08:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : priyadharshinik
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 40/50 (80.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.FLOAT.LEG2.PAYMENT.FREQ(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
*
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* report the multiplier defined on the floating leg of the contract.
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
*       Ex      1M  - M
*               3M  - M
*               6M  - M
*               12W - W
*               D   - D
*             TWMTH - W
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
    IP.DATE.FREQ = ''
    FLOAT.RATE.LEG2 = ''

RETURN
*-----------------------------------------------------------------------------

PROCESS:

*To get the value from the field FLOAT.RATE.LEG2.
    OC.Reporting.UpdFloatRateLeg2(APPL.ID,APPL.REC,FIELD.POS, FLOAT.RATE.LEG2)

    IF FLOAT.RATE.LEG2 THEN
    
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
*** <desc> </desc>

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
                IF IP.DATE.FREQ[10,2] GE "12" THEN ;*If Month is greater than or equal to 12, then it consider as yearly basis.
                    RET.VAL = "Y"
                END ELSE
                    RET.VAL = "M"
                END
                
            CASE FREQ EQ "D" OR IP.DATE.FREQ[9,5] EQ "BSNSS"                   ;*daily frequency
                RET.VAL = "D"
                
            CASE FREQ EQ "W"                    ;*Weekly frequency
                RET.VAL = "W"
                
            CASE IP.DATE.FREQ[9,5] EQ "TWMTH" OR IP.DATE.FREQ[9,5] EQ "LWEEK" ;*Twice Monthly or last week
                RET.VAL = "W"
                
            CASE IP.DATE.FREQ[9,5] EQ "LYEAR"
                RET.VAL = "Y"
                
            CASE IP.DATE.FREQ[9,5] EQ "LHFYR" OR IP.DATE.FREQ[9,5] EQ "LQUAT" OR IP.DATE.FREQ[9,5] EQ "LMNTH"
                RET.VAL = "M"
                      
        END CASE
    END
RETURN
**-----------------------------------------------------------------------------
END
