* @ValidationCode : MjoxMDMwNjExMjEzOkNwMTI1MjoxNDg4OTc0MDkxMjUxOnNpdmFrdW1hcms6MjowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDMuMjAxNzAyMjItMDEzNTozNDozNA==
* @ValidationInfo : Timestamp         : 08 Mar 2017 17:24:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sivakumark
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 34/34 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201703.20170222-0135
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE AA.AgentCommission
    SUBROUTINE CONV.AA.AGENT.COMMISSION.R1704(Id, Record,File)
*-----------------------------------------------------------------------------
*  Conversion Routine to update the correct marker for new fields CommissionAction, Defer Days and reserved6.
*-----------------------------------------------------------------------------
* @package Retaillending.AA
* @stereotype subroutine
* @ author sivakumark@temenos.com
*-----------------------------------------------------------------------------

* Modification History :
*
* 03/01/17 - Enhancement : 1696792
*            Task        : 2028385
*            Conversion Routine to update the correct marker for new fields CommissionAction, Defer Days and reserved6.
*
* 08/03/17 - Task : 2045538
*            Defect : 2045508
*            Conversion for multiple brokers
*
*-----------------------------------------------------------------------------

*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB Initialise

    GOSUB ExistingFieldDrawbackType
    GOSUB NewFieldDeferDays       ;* updating markers for Reserved4.
    GOSUB NewFieldReserved6  ;* updating markers for CommissionType.

    RETURN
*** </region>
*-----------------------------------------------------------------------------------

Initialise:

    AgcommScheduleFrequency = '14'        ;* ScheduleFrequency field having exact values seprated by corresponding markers. 'A]B'
    AgcommDeferDays = '16'       ;* new fileds
    AgcommReserved6 = '17'  ;* new fileds
    AgcommDrawbackType = '15'
    AgcommOnlineEvent = '6'
    AgcommAgentId = '3'

    ScheduleFrequency = Record<AgcommScheduleFrequency>

    RETURN

*----------------------------------------------------------------------------------------

NewFieldDeferDays:

    DeferDays = ""   ;* make reserved as null.

**Concat empty value with ScheduleFrequency.
    DeferDays.MergedFieldValue = SPLICE(ScheduleFrequency,"-",REUSE(DeferDays))  ;*  A-]B-

**Splite the merged values by "-" and get the second position of the string
    DeferDays = FIELDS(DeferDays.MergedFieldValue,"-",2)                 ;* ]

    Record<AgcommDeferDays> = DeferDays                        ;* updated marker for reserverd5 as ']'

    RETURN

*------------------------------------------------------------------------------------------

NewFieldReserved6:

    Reserved6 = ""

**Concat empty value with ScheduleFrequency.
    Reserved6.MergedFieldValue = SPLICE(ScheduleFrequency,"-",REUSE(Reserved6))  ;*  A-]B-

**Splite the merged values by "-" and get the second position of the string
    Reserved6 = FIELDS(Reserved6.MergedFieldValue,"-",2)                     ;* ]

    Record<AgcommReserved6> = Reserved6                                      ;* updated marker for CommissionType as ']'

    RETURN
*------------------------------------------------------------------------------------------
ExistingFieldDrawbackType:

    DrawbackType = Record<AgcommDrawbackType>

    AgentCount = DCOUNT(Record<AgcommAgentId>,@VM)
    FOR AgCnt = 1 TO AgentCount
        CommissionCount = DCOUNT(Record<AgcommOnlineEvent,AgCnt>,@SM)
        FOR Cnt = 1 TO CommissionCount
            IF DrawbackType<1,AgCnt,Cnt> EQ "YES" THEN
                Record<AgcommDrawbackType,AgCnt,Cnt> = "PARTIAL"
            END
        NEXT Cnt
    NEXT AgCnt

    RETURN
*------------------------------------------------------------------------------------------
    END
