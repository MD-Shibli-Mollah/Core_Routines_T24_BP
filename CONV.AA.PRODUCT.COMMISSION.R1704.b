* @ValidationCode : MjoxMjUwMTc4NDA4OkNwMTI1MjoxNDg4NTIwMjEzMjQyOnNpdmFrdW1hcms6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDIuMjAxNzAxMjgtMDEzOTo1MTo1MQ==
* @ValidationInfo : Timestamp         : 03 Mar 2017 11:20:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sivakumark
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 51/51 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.20170128-0139
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE AA.ProductCommission
    SUBROUTINE CONV.AA.PRODUCT.COMMISSION.R1704(Id, Record,File)
*-----------------------------------------------------------------------------
*  Conversion Routine to update the correct marker for the fields AMORT.END, DEFER.DAYS, RESERVED8, RESERVED7, ONLINE.COMMISSION.TYPE.
*-----------------------------------------------------------------------------
* @package Retaillending.AA
* @stereotype subroutine
* @ author sivakumark@temenos.com
*-----------------------------------------------------------------------------
* Modification History :
*
* 03/01/17 - Enhancement : 1696792
*            Task        : 2028385
*            Conversion Routine to update the correct marker for the fields AMORT.END, DEFER.DAYS, RESERVED8, RESERVED7, ONLINE.COMMISSION.TYPE.
*
*-----------------------------------------------------------------------------
*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB Initialise

    GOSUB MarkerForOnlineCommissionType
    GOSUB MarkerForDrawbackType
    GOSUB MarkerForDeferDays
    GOSUB MarkerForReserved8
    GOSUB MarkerForReserved7

    RETURN
*** </region>
*-------------------------------------------------------------------------------
*** <region name= Initialise>
Initialise:
*** <desc> </desc>


    PrcommScheduleCommissionType = '22' ;*ScheduleCommissionType
    PrcommOnlineCommissionType = '12'         ;*OnlineCommissionType
    PrcommDrawbackType = '8'         ;*DrawbackType
    PrcommDeferDays = '9'
    PrcommReserved8 = '10'
    PrcommReserved7 = '11'
    PrcommOnlineChg = '7'
    PrcommProductLine = '3'
    PrcommOnlineAct = '6'

    ScheduleCommissionType = Record<PrcommScheduleCommissionType>   ;* AAA1^AAA2]AAA3
    OnlineChg = Record<PrcommOnlineChg>
    OnlineCommissionType = ""
    DrawbackType = ""
    DeferDays = ""
    Reserved8 = ""              ;* Assume the RESERVED8 value as null
    Reserved7 = ""              ;* Assume the RESERVED7 value as null
    ProductLine = ""

    RETURN

*** </region>
*------------------------------------------------------------------------------------------------
*** <region name= MarkerForReserved6>
MarkerForOnlineCommissionType:
*** <desc> </desc>

    OnlineCommissionType.MergedFieldValue = SPLICE(ScheduleCommissionType,"-",REUSE(OnlineCommissionType))

*** Splite the merged values by "-" and get the second position of the string
    OnlineCommissionType = FIELDS(OnlineCommissionType.MergedFieldValue,"-",2)

    Record<PrcommOnlineCommissionType> = OnlineCommissionType

    RETURN
*** </region>
*----------------------------------------------------------------------------------------------------
MarkerForDrawbackType:
*** <desc> </desc>

    ProductCnt = DCOUNT(Record<PrcommProductLine>, @VM)
    FOR PrCnt = 1 TO ProductCnt
        ChargeCnt = DCOUNT(Record<PrcommOnlineAct,PrCnt>, @SM)
        FOR ChgCnt = 1 TO ChargeCnt
            IF Record<PrcommDrawbackType,PrCnt,ChgCnt> = "YES" THEN
                Record<PrcommDrawbackType,PrCnt,ChgCnt> = "PARTIAL"
            END
        NEXT ChgCnt
    NEXT PrCnt

    RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= MarkerForDeferDays>
MarkerForDeferDays:
*** <desc> </desc>

    DeferDays.MergedFieldValue = SPLICE(OnlineChg,"-",REUSE(DeferDays))

*** Splite the merged values by "-" and get the second position of the string
    DeferDays = FIELDS(DeferDays.MergedFieldValue,"-",2)

    Record<PrcommDeferDays> = DeferDays

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= MarkerForReserved8>
MarkerForReserved8:
*** <desc> </desc>

    Reserved8.MergedFieldValue = SPLICE(OnlineChg,"-",REUSE(Reserved8))

*** Splite the merged values by "-" and get the second position of the string
    Reserved8 = FIELDS(Reserved8.MergedFieldValue,"-",2)

    Record<PrcommReserved8> = Reserved8

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= MarkerForReserved7>
MarkerForReserved7:
*** <desc> </desc>

    Reserved7.MergedFieldValue = SPLICE(OnlineChg,"-",REUSE(Reserved7))

*** Splite the merged values by "-" and get the second position of the string
    Reserved7 = FIELDS(Reserved7.MergedFieldValue,"-",2)

    Record<PrcommReserved7> = Reserved7

    RETURN
*** </region>
    END

