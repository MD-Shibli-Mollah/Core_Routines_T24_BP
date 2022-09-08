* @ValidationCode : MjotMTIyNDkxNzEyOTpDcDEyNTI6MTQ5ODYyOTM2ODIxODplc3dhcmlzYXJhbnlhOjI6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzA2LjE6MTU0Ojc2
* @ValidationInfo : Timestamp         : 28 Jun 2017 11:26:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : eswarisaranya
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 76/154 (49.3%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201706.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*---------------------------------------------------------------
*-----------------------------------------------------------------------------
* <Rating>147</Rating>
*-----------------------------------------------------------------------------
$PACKAGE MD.Foundation
SUBROUTINE CONV.MD.BALANCES.R12(MD.ID, MD.BAL.REC, SLL.FILE)
*---------------------------------------------------------------
*** <region name= Modifications>
*** <desc> </desc>
*
* 13/04/13 - TASK : 649841
*            Don't use inserts instead equate the positions.
*            REF : 649264
*
*
* 01/05/13 - TASK : 662907
*            Updation of commission rate from MD.CSN.RATE.CHANGE template.
*            REF : 660696
*
* 19/06/13 - TASK : 708406
*            Updation of MD.BALANCES for matured contracts.
*            REF : 705916
*
* 20/09/13 - TASK : 788672
*            Updation of MD.BALANCES for Invocation processing
*            REF : 782259
*
*
* 07/10/13 - TASK : 801797
*            Updation of MD.BALANCES for Principal Movement and
*            Invocation Processing on different dates.
*            REF : 782259
*
* 01/12/16 - Task : 1942478
*            Routine Corrections - Incorrect Loop statements
*            Changes made to correct incorrect NEXT statements
*            Ref : 1942466
*
* 09/06/17 - Task : 2156299
*            Future schedules should not be dropped for Principal Movements
*            Defect - 2148971
*
* Modifications
*** </region>
*----------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts </desc>

    $INSERT I_COMMON
    $INSERT I_EQUATE
    EQU MD.BAL.CSN.RATE TO 44
    EQU MD.BAL.RATE.REVISION.DATE TO 43
    EQU MD.DEA.VALUE.DATE TO 6
    EQU MD.DEA.CURRENT.RATE TO 53
    EQU MD.DEA.SL.REF.TRANCHE TO 130
    EQU MD.DEA.PARTICIPANT TO 64
    EQU MD.DEA.PRINCIPAL.AMOUNT TO 4
    EQU MD.BAL.PRIN.BALANCE TO 1
    EQU MD.BAL.PRIN.PART.BAL TO 2
    EQU MD.BAL.PRIN.EFF.DATE TO 3
    EQU MD.BAL.PAST.SCHED.DATE TO 28
    EQU MD.BAL.PAST.SCHED.AMT TO 29
    EQU MD.BAL.PAST.SCHED.TYPE TO 30
    $INSERT I_DAS.COMMON
    $INSERT I_DAS.MD.CSN.RATE.CHANGE
    EQU MD.CRC.DEAL.ID TO 6
    EQU MD.CRC.DEAL.COMM.RATE TO 7
    EQU MD.CRC.COMM.RATE TO 4
    EQU MD.CRC.CATEGORY TO 3
    EQU MD.CRC.EFFECTIVE.FROM TO 1
    EQU MD.CRC.DEAL.SUB.TYPE TO 2
    EQU MD.DEA.DEAL.SUB.TYPE TO 9
    EQU MD.DEA.CATEGORY TO 10
    EQU MD.DEA.CSN.SPREAD TO 52

*** </region>
***************************************************************************************
*** <region name= PROGRAM>
*** <desc>PROGRAM </desc>
    GOSUB CHECK.MATURED.CONTRACT ;*No need to convert data for matured contracts.
    IF NOT(MATURED.CONTRACT) THEN
        GOSUB INITIALISE
        GOSUB MAIN.PROGRAM
    END
RETURN

*** </region>
***************************************************************************************
*** <region name= INITIALISE>
*** <desc>Initialisation </desc>
INITIALISE:
***********
    FN.MD.DEAL = 'F.MD.DEAL'
    FV.MD.DEAL = ''
    MD.REC = ''
    HIST.REC.ID = MD.ID:';':'1'
    F.MD.DEAL.HIS = ''
    ERR.HIS = ''
    PAST.SCHED.CNT = ''
    CALL F.READ('F.MD.DEAL$HIS', HIST.REC.ID, MD.REC, F.MD.DEAL.HIS, ERR.HIS)
    IF NOT(MD.REC) THEN
        CALL F.READ(FN.MD.DEAL,MD.ID,MD.REC,FV.MD.DEAL,'')
    END
RETURN
*** </region>
**************************************************************************************
*** </region>
*** <region name= Main Program>
*** <desc>Main Program </desc>
MAIN.PROGRAM:
*************
    IF MD.BAL.REC<MD.BAL.CSN.RATE> EQ '' AND MD.REC AND MD.REC<MD.DEA.CURRENT.RATE> THEN
        MD.BAL.REC<MD.BAL.RATE.REVISION.DATE> = MD.REC<MD.DEA.VALUE.DATE>
        MD.BAL.REC<MD.BAL.CSN.RATE> = MD.REC<MD.DEA.CURRENT.RATE>
        GOSUB CHECK.MD.CSN.RATE.CHANGE  ;*To update the rate from MD.CSN.RATE.CHANGE template.
    END
    IF MD.REC AND NOT(MD.REC<MD.DEA.SL.REF.TRANCHE>) AND NOT(MD.REC<MD.DEA.PARTICIPANT>) THEN  ;*If no history record then take it from live file
        PRIN.AMT = MD.REC<MD.DEA.PRINCIPAL.AMOUNT>
        PRIN.EFF.DATE = MD.REC<MD.DEA.VALUE.DATE>
        PRIN.BALANCE = MD.BAL.REC<MD.BAL.PRIN.BALANCE> ;*Get existing Prin Balances
        OLD.PRIN.EFF.DATES = MD.BAL.REC<MD.BAL.PRIN.EFF.DATE> ;*Get existing Prin Eff Dates
        PRIN.PART.BAL = MD.BAL.REC<MD.BAL.PRIN.PART.BAL> ;*Get existing Prin Part Balances
        MD.BAL.REC<MD.BAL.PRIN.BALANCE> = ''
        MD.BAL.REC<MD.BAL.PRIN.EFF.DATE> = ''
        MD.BAL.REC<MD.BAL.PRIN.BALANCE,1> = PRIN.AMT
        MD.BAL.REC<MD.BAL.PRIN.EFF.DATE,1> = PRIN.EFF.DATE
        PAST.SCHED.CNT = DCOUNT(MD.BAL.REC<MD.BAL.PAST.SCHED.DATE>,@VM)
        FOR PAST.SCHED = 1 TO PAST.SCHED.CNT
            IF MD.BAL.REC<MD.BAL.PAST.SCHED.TYPE,PAST.SCHED> MATCHES 'PRN' :VM: 'INV' THEN ;*To update MD.BALANCES if invocation is done
                LOCATE MD.BAL.REC<MD.BAL.PAST.SCHED.DATE,PAST.SCHED> IN MD.BAL.REC<MD.BAL.PRIN.EFF.DATE,1> SETTING DATE.POS THEN
                    GOSUB UPDATE.PRIN.BALANCES
                    EFF.DATE.CNT = DCOUNT(MD.BAL.REC<MD.BAL.PRIN.EFF.DATE>,@VM)

                    FOR EFF.DT = DATE.POS+1 TO EFF.DATE.CNT
                        MD.BAL.REC<MD.BAL.PRIN.BALANCE,EFF.DT> +=  MD.BAL.REC<MD.BAL.PAST.SCHED.AMT,PAST.SCHED>
                    NEXT EFF.DT
                END ELSE
                    EFF.DATE.CNT = DCOUNT(MD.BAL.REC<MD.BAL.PRIN.EFF.DATE>,@VM)
                    IF MD.BAL.REC<MD.BAL.PAST.SCHED.TYPE,PAST.SCHED> EQ 'PRN' THEN ;*For principal movement or invocation on different dates MD.BALANCES get updated
                        IF PAST.SCHED = 1 THEN ;*First updation in Prin Balance is the sum of MD Principal amount and Past Sched Amt
                            MD.BAL.REC<MD.BAL.PRIN.BALANCE,PAST.SCHED> = PRIN.AMT + MD.BAL.REC<MD.BAL.PAST.SCHED.AMT,PAST.SCHED> ;*First Past sched to be added to Principal amount of MD and update in Prin Balance
                        END ELSE
                            MD.BAL.REC<MD.BAL.PRIN.BALANCE,PAST.SCHED> = MD.BAL.REC<MD.BAL.PRIN.BALANCE,EFF.DATE.CNT> + MD.BAL.REC<MD.BAL.PAST.SCHED.AMT,PAST.SCHED> ;*Principal Movement
                        END
                    END ELSE
                        MD.BAL.REC<MD.BAL.PRIN.BALANCE,PAST.SCHED> = MD.BAL.REC<MD.BAL.PRIN.BALANCE,EFF.DATE.CNT> - MD.BAL.REC<MD.BAL.PAST.SCHED.AMT,PAST.SCHED> ;*Invocation
                    END
                    MD.BAL.REC<MD.BAL.PRIN.EFF.DATE,PAST.SCHED> = MD.BAL.REC<MD.BAL.PAST.SCHED.DATE,PAST.SCHED>
                END
            END
        NEXT PAST.SCHED
        GOSUB UPDATE.FUTURE.PRIN.BALANCES ;*Future Principal Movements to be updated in MD.BALANCES file
    END
RETURN
*** </region>
**************************************************************************************
*** <region name= CHECK.MD.CSN.RATE.CHANGE>
*** <desc> </desc>
*========================
CHECK.MD.CSN.RATE.CHANGE:
*========================
    TABLE.NAME = 'MD.CSN.RATE.CHANGE'
    TABLE.SUFFIX = ''
    THE.ARGS = MD.REC<MD.DEA.VALUE.DATE>:FM:TODAY ;*Get the MD.CSN.RATE.CHANGE record from md deal value date to today's date.
    THE.LIST = DAS.MD.CSN.RATE.CHANGE$RATECHANGE
    CALL DAS(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    DATE.LIST = THE.LIST
    LOOP
        REMOVE DATE.ID FROM DATE.LIST SETTING DATE.POS
    WHILE DATE.ID
        R.MD.RATE.CHANGE = ''
        ETEXT = ''
        CALL F.READ('F.MD.CSN.RATE.CHANGE',DATE.ID,R.MD.RATE.CHANGE,F.MD.RATE.CHANGE,ETEXT)         ;*Read the MD.CSN.RATE.CHANGE record.
        IF R.MD.RATE.CHANGE THEN
            DEAL.POS = ''
            REVISED.RATE = ''
            CHECK.DEAL.TYPE = 1
            LOCATE MD.ID IN R.MD.RATE.CHANGE<MD.CRC.DEAL.ID,1> SETTING DEAL.POS THEN      ;*Check the deal id in rate change record if not cehck the category
                REVISED.RATE = R.MD.RATE.CHANGE<MD.CRC.DEAL.COMM.RATE,DEAL.POS> ;*If deal id present then take that rate.
                CHECK.DEAL.TYPE = ''    ;*Return to check the next MD.CSN.RATE.CHANGE record
            END
            IF CHECK.DEAL.TYPE THEN
                GOSUB FIND.CATEGORY
            END
            IF REVISED.RATE THEN
                GOSUB UPDATE.RATE       ;*To update the rate in MD.BALANCES
            END
        END
    REPEAT
RETURN

*** </region>
*****************************************************************************************
*** <region name= FIND.CATEGORY>
*** <desc> </desc>
*=============
FIND.CATEGORY:
*=============
    DSF.POS = ''
    CAT.POS = ''
    REVISED.RATE = ''
    IF R.MD.RATE.CHANGE<MD.CRC.DEAL.SUB.TYPE> NE '' THEN    ;*Check with deal sub type position if it is there then go check category position
        LOCATE MD.REC<MD.DEA.DEAL.SUB.TYPE> IN R.MD.RATE.CHANGE<MD.CRC.DEAL.SUB.TYPE,1> SETTING DSF.POS ELSE  ;*Deal sub type position
            DSF.POS = 0
        END
        IF DSF.POS THEN
            LOCATE MD.REC<MD.DEA.CATEGORY> IN R.MD.RATE.CHANGE<MD.CRC.CATEGORY,DSF.POS,1> SETTING CAT.POS ELSE          ;*Category position
                CAT.POS = 0
            END
            IF CAT.POS THEN
                REVISED.RATE = R.MD.RATE.CHANGE<MD.CRC.COMM.RATE,DSF.POS,CAT.POS>         ;*Rate change based on category
            END
        END
    END
RETURN

*** </region>

*************************************************************************************************
*** <region name= UPDATE.RATE>
*** <desc> </desc>
*===========
UPDATE.RATE:
*===========

    CSN.EFF.RATE = REVISED.RATE + MD.REC<MD.DEA.CSN.SPREAD>
    RATE.POS = ''
    LOCATE R.MD.RATE.CHANGE<MD.CRC.EFFECTIVE.FROM> IN MD.BAL.REC<MD.BAL.RATE.REVISION.DATE,1> BY "DR" SETTING  RATE.POS THEN
        MD.BAL.REC<MD.BAL.RATE.REVISION.DATE,RATE.POS> = R.MD.RATE.CHANGE<MD.CRC.EFFECTIVE.FROM>    ;*Rate effective date
        MD.BAL.REC<MD.BAL.CSN.RATE,RATE.POS> = CSN.EFF.RATE
    END ELSE
        INS R.MD.RATE.CHANGE<MD.CRC.EFFECTIVE.FROM> BEFORE MD.BAL.REC<MD.BAL.RATE.REVISION.DATE,RATE.POS>
        INS CSN.EFF.RATE BEFORE MD.BAL.REC<MD.BAL.CSN.RATE,RATE.POS>
    END
    RATE.CNT = DCOUNT(MD.BAL.REC<MD.BAL.RATE.REVISION.DATE>,VM)
    FOR RATE.POSITION = 1 TO RATE.CNT ;*Deleting the rate from balances if any date which is greater than Effective from date.
        IF MD.BAL.REC<MD.BAL.RATE.REVISION.DATE,RATE.POSITION> GT R.MD.RATE.CHANGE<MD.CRC.EFFECTIVE.FROM> THEN
            DEL MD.BAL.REC<MD.BAL.RATE.REVISION.DATE,RATE.POSITION>
            DEL MD.BAL.REC<MD.BAL.CSN.RATE,RATE.POSITION>
        END
    NEXT RATE.POSITION
RETURN

*** </region>
**************************************************************************************************
*** <region name= CHECK.MATURED.CONTRACT>
*** <desc> </desc>
*======================
CHECK.MATURED.CONTRACT:
*======================
    MATURED.CONTRACT = ''
    PAST.EVENTS = DCOUNT(MD.BAL.REC<MD.BAL.PAST.SCHED.DATE>,VM)
    IF MD.BAL.REC<MD.BAL.PAST.SCHED.TYPE,PAST.EVENTS> EQ 'MAT' THEN
        MATURED.CONTRACT = 1
    END
RETURN
*** </region>
**************************************************************************************************
*** <region name= UPDATE.PRIN.BALANCES>
*** <desc> </desc>
*====================
UPDATE.PRIN.BALANCES:
*====================

    IF  MD.BAL.REC<MD.BAL.PAST.SCHED.TYPE,PAST.SCHED> EQ 'PRN' THEN
        MD.BAL.REC<MD.BAL.PRIN.BALANCE,DATE.POS> +=  MD.BAL.REC<MD.BAL.PAST.SCHED.AMT,PAST.SCHED>
    END ELSE
        MD.BAL.REC<MD.BAL.PRIN.BALANCE,DATE.POS> -=  MD.BAL.REC<MD.BAL.PAST.SCHED.AMT,PAST.SCHED>
    END
RETURN
*** </region>

**************************************************************************************************
*** <region name= UPDATE.FUTURE.PRIN.BALANCES>
*** <desc> </desc>
*===========================
UPDATE.FUTURE.PRIN.BALANCES:
*===========================
    NO.OF.OLD.PRIN.EFF.DATE = DCOUNT(OLD.PRIN.EFF.DATES,@VM) ;*Existing Prin Eff Dates
    NO.OF.PRIN.EFF.DATE = DCOUNT(MD.BAL.REC<MD.BAL.PRIN.EFF.DATE>,@VM) ;*Current Prin Eff Dates
    FUTURE.BAL = 1
    FOR PRN.EFF.DATE = 1 TO NO.OF.OLD.PRIN.EFF.DATE
        LOCATE OLD.PRIN.EFF.DATES<1,PRN.EFF.DATE> IN MD.BAL.REC<MD.BAL.PRIN.EFF.DATE,1> SETTING PRN.DATE.POS ELSE ;*Check if Prin Eff Date is already existing, else those movements are considered as Future Movements
            MD.BAL.REC<MD.BAL.PRIN.EFF.DATE,NO.OF.PRIN.EFF.DATE+FUTURE.BAL> = OLD.PRIN.EFF.DATES<1,PRN.EFF.DATE> ;*Future Principal Movement date is updated in Prin Eff Date
            MD.BAL.REC<MD.BAL.PRIN.BALANCE,NO.OF.PRIN.EFF.DATE+FUTURE.BAL> = PRIN.BALANCE<1,PRN.EFF.DATE> ;*Future Principal Balances is updated in Prin Balances
            MD.BAL.REC<MD.BAL.PRIN.PART.BAL,NO.OF.PRIN.EFF.DATE+FUTURE.BAL> = PRIN.PART.BAL<1,PRN.EFF.DATE> ;*Future Principal Part Bal is updated in Prin Part Bal
            FUTURE.BAL += 1
        END
    NEXT PRN.EFF.DATE
RETURN
*** </region>

**************************************************************************************************
END
   
