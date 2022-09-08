* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-73</Rating>
*-----------------------------------------------------------------------------
* Version 2 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
*
    $PACKAGE SW.Foundation
    SUBROUTINE CONV.EB.DETERMINE.PROCESS.DATE(SCHEDULE.DATE,BUSINESS.CENTRES,DAY.CONVENTION,DATE.ADJUSTMENT,PROCESS.DATE,ENTRY.DATE,EFFECTIVE.DATE)
*
*************************************************************************
*                                                                       *
*  Routine     :  CONV.EB.DETERMINE.PROCESS.DATE                             *
*                                                                       *
*************************************************************************
*                                                                       *
*  Description :  This routine will determine the date a swap schedule  *
*                 should be processed, the value date of the associated *
*                 entries, and the period end date of the schedule.     *
*                                                                       *
*                 Based on the day convention and the business centres, *
*                 the process date for the schedules are determined.    *
*                                                                       *
*                 Then, depending on the date adjustment, the value     *
*                 dates and period end dates are calculated.            *
*                                                                       *
*                 Arguments passed are as follows :                     *
*                                                                       *
*                 SCHEDULE.DATE     - Date of the schedule.             *
*                                                                       *
*                 BUSINESS.CENTRES  - List of country/region codes for  *
*                                     working day calculation.          *
*                                                                       *
*                 DAY.CONVENTION    - FOLLOWING, MODIFIED, PRECEDING,   *
*                                     or null.                          *
*                                                                       *
*                 DATE.ADJUSTMENT   - VALUE, PERIOD, or null.           *
*                                                                       *
*                 Arguments returned are as follows :                   *
*                                                                       *
*                 PROCESS.DATE      - Date to process the schedule.     *
*                                                                       *
*                 ENTRY.DATE        - Entry date of the entries.        *
*                                                                       *
*                 EFFECTIVE.DATE    - Period end date of the schedule.  *
*                                                                       *
*************************************************************************
*                                                                       *
*  Modifications :                                                      *
*                                                                       *
* 19/02/07 - BG_100013039
*            Initial Version for conversion processing.
*                                                                       *
*************************************************************************
*
******************
*  Insert Files.
******************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CONV.SWAP
    $INSERT I_SW.COMMON
*
************************************************************
*  Determine the date when the schedules should be         *
*  processed.  Then depending on the date adjustment,      *
*  calculate the value date and period end date.           *
************************************************************
*
*************
MAIN.PROCESS:
*************
*
    GOSUB DETERMINE.PROCESS.DATE
*
    NOT.WORK.DAY = ""         ;* CI_10001241 S
    RETURN.CODE = ""
    CALL WORKING.DAY("",R$SWAP<SW.MATURITY.DATE>,"",0,"",COUNTRY.CODE,REGION.CD,"",RETURN.CODE,NOT.WORK.DAY)
*
*  If next interest period is beyond maturity then set it to maturity
*
    IF R$SWAP<SW.MATURITY.DATE> AND (ID.NEW[1,2] EQ 'SW') AND NOT(RUNNING.UNDER.BATCH) THEN         ;* BG_100000891S/E ;* CI_10040679 S/E
        IF SCHEDULE.DATE GT R$SWAP<SW.MATURITY.DATE> THEN
            SCHEDULE.DATE = R$SWAP<SW.MATURITY.DATE>
        END         ;* CI_10001241 E
    END   ;* BG_100000891S/E
*
    BEGIN CASE
    CASE DATE.ADJUSTMENT = ""
        ENTRY.DATE = SCHEDULE.DATE
        EFFECTIVE.DATE = SCHEDULE.DATE
    CASE DATE.ADJUSTMENT = "VALUE"
        ENTRY.DATE = PROCESS.DATE
        EFFECTIVE.DATE = SCHEDULE.DATE
    CASE DATE.ADJUSTMENT = "PERIOD"
        ENTRY.DATE = PROCESS.DATE
        EFFECTIVE.DATE = PROCESS.DATE
    END CASE
*
    RETURN
*
************************************************************
*  Based on the day convention and the business centres,   *
*  determine the date when the schedules should be         *
*  processed.                                              *
*                                                          *
*  If DAY.CONVENTION                                       *
*  is :               then, :                              *
*                                                          *
*     null            the process date is the same as the  *
*                     schedule date.                       *
*                                                          *
*     "FOLLOWING"     the process date will be the first   *
*                     following day that is a business     *
*                     day.                                 *
*                                                          *
*     "PRECEDING"     the process date will be the first   *
*                     preceding day that is a business     *
*                     day.                                 *
*                                                          *
*     "MODIFIED"      the process date will be the first   *
*                     following day that is a business day *
*                     unless the day falls in the next     *
*                     calendar month, in which case the    *
*                     process date will be the first       *
*                     preceding day that is a business     *
*                     day.                                 *
************************************************************
*
***********************
DETERMINE.PROCESS.DATE:
***********************
*
    CAL.TYPE = ""
    SIGN = ""
    DISPLACEMENT = ""
    COUNTRY.CODE = ""
    REGION.CD = ""
    RETURN.DATE = ""
    RETURN.CODE = ""
    RETURN.DISPLACEMENT = ""
*
    START.DATE = SCHEDULE.DATE
*
* allow region code in BUSINESS.CENTRES
*
    FOR YI = 1 TO DCOUNT(BUSINESS.CENTRES, VM)
        BUS.CENTRE = BUSINESS.CENTRES<1,YI>
        COUNTRY.CODE<YI> = BUS.CENTRE[1,2]
        IF LEN(BUS.CENTRE) = 4 THEN
            REGION.CD<YI> = BUS.CENTRE[3,2]
        END ELSE
            REGION.CD<YI> = "00"
        END
    NEXT YI
*
    BEGIN CASE
*
    CASE DAY.CONVENTION = ""
        RETURN.DATE = SCHEDULE.DATE
*
    CASE DAY.CONVENTION = "FOLLOWING"
        FOR.BACK.IND = "F"
        GOSUB GET.NEXT.BUSINESS.DAY
*
    CASE DAY.CONVENTION = "PRECEDING"
        FOR.BACK.IND = "B"
        GOSUB GET.NEXT.BUSINESS.DAY
*
    CASE DAY.CONVENTION = "MODIFIED"
        FOR.BACK.IND = "F"
        GOSUB GET.NEXT.BUSINESS.DAY
*
*******************************************
*  Check to see if the next business day  *
*  falls in the next calendar month.      *
*  If that is the case obtain the first   *
*  preceding business day.                *
*******************************************
*
        IF RETURN.DATE[5,2] > START.DATE[5,2] THEN
            NEXT.CAL.MONTH = 1
        END ELSE
            IF RETURN.DATE[1,4] > START.DATE[1,4] THEN
                NEXT.CAL.MONTH = 1
            END ELSE
                NEXT.CAL.MONTH = 0
            END
        END
*
        IF NEXT.CAL.MONTH THEN
            FOR.BACK.IND = "B"
            GOSUB GET.NEXT.BUSINESS.DAY
        END
*
    END CASE
*
    PROCESS.DATE = RETURN.DATE
*
    RETURN
*
************************************************************
*  Call routine WORKING.DAY to obtain next business day.   *
************************************************************
*
**********************
GET.NEXT.BUSINESS.DAY:
**********************
*
    CALL WORKING.DAY(CAL.TYPE, START.DATE, SIGN, DISPLACEMENT, FOR.BACK.IND, COUNTRY.CODE, REGION.CD, RETURN.DATE, RETURN.CODE, RETURN.DISPLACEMENT)
*
    IF RETURN.CODE = "ERR" THEN
*
* no holiday record, set return.date to start.date
*
        RETURN.DATE = START.DATE
    END
*
    RETURN
*
********************
*  Error handling.
********************
*
************
FATAL.ERROR:
************
*
    TEXT = ETEXT
    CALL FATAL.ERROR("EB.DETERMINE.PROCESS.DATE")
*
    RETURN
*
********************
*  End Of Routine.
********************
*
    RETURN
*
END
