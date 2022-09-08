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

* Version 4 15/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>108</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.AC.RATES(INT.CODE, CCY, BASIS, ASST.LIAB, RATE)

* This routine will return the account interest rates applicable to an
* an interet rate code stored on the PM.DLY.POSN.CLASS or the
* PM.TRAN.,ACTIVITY file.

* INPUT
* =====
* INT.CODE       : INT.CODE as recorded on PM.DLY.POSN.CLASS
* CCY            : Currency being processed.
* BASIS          : Interest basis for the currency in question ie A, B etc
* ASST.LIAB      ; Indicates if the amount for which the rate is
*                  required is an asset or liability, 1 = liab.
*
* OUTPUT
* ======
* RATE           : Interest rate applicable for the INT.CODE passed

***************************************************
* MODIFICATION HISTORY:
*---------------------
*
* 29/11/02 - GLOBUS_CI_10005089
*            Incorrect RATE populated in PM.GAP enquiry
*            Jbase error. so changed the BASE.KEY built
*            in this routine.
*
* 03/12/04 - BG_100008660
*            Locate CR/DR dates in fields 3 & 4 instead of
*            reading 1 & 2
*
* 24/01/07 - CI_10046838
*            cater for multi valued banded interest rates related to amount
*
* 05/03/07 - CI_10047615
*            Multiply operand is not correctly processed
*
* 28/04/10 - Defect 41104 /Task 44152
*            The interest rate in enquiry PM.GAP not displayed correctly
*            for multiply option
*
* 26/10/15 - EN_1226121 / Task 1511358
*	      	 Routine incorporated
*
*******************************************************************************

    $USING IC.Config
    $USING IC.InterestAndCapitalisation
    $USING ST.ExchangeRate
    $USING EB.DataAccess
    $USING ST.RateParameters
    $USING PM.Reports
    $USING EB.SystemTables

*-----------------------------------------------------------------------------

    GOSUB INITIALISE

* Read account record

    IF INT.CODE = "SETUP" THEN
        RETURN
    END

    CODE.TYPE = INT.CODE[1,1]
    RATE.KEY = FIELD(INT.CODE,'*',1)
    RATE.KEY = TRIM(RATE.KEY[2,99],0,'L') ;* CI_10005089 s


    OLD.BASIS = ''
    BEGIN CASE
        CASE NUM(CODE.TYPE)
            RATE = FIELD(INT.CODE,'*',1)
            OLD.BASIS = FIELD(INT.CODE,'*',2)

        CASE CODE.TYPE = 'F'
            RATE = FIELD(INT.CODE,'*',2)

        CASE CODE.TYPE = 'B'
            SPREAD = FIELD(INT.CODE,'*',2)
            OPER = SPREAD[1,1]
            IF OPER = '-' OR OPER = '+' OR OPER = 'M' THEN
                SPREAD = SPREAD[2,99]
            END ELSE
                SPREAD = SPREAD[1,99]
                OPER ='+'
            END
            IF NOT(NUM(SPREAD)) THEN
                SPREAD = 0
            END
            BASE.KEY = RATE.KEY * 1
            GOSUB GET.FLOATING.RATE
            BEGIN CASE
                CASE SPREAD = 0
                CASE OPER = '+'
                    RATE = RATE + SPREAD
                CASE OPER = '-'
                    RATE = RATE - SPREAD
                CASE OPER = 'M'
                    RATE = RATE + ((RATE/100) * SPREAD)
            END CASE

        CASE CODE.TYPE = 'G'
            GRP.ID = RATE.KEY * 1
            GRP.ID := CCY
            GOSUB READ.INT.DETAILS
            GOSUB CALC.RATE
            OLD.BASIS = FIELD(INT.CODE, "*" ,3)

        CASE CODE.TYPE = "P"
            RATE = ""
            IF ASST.LIAB = 1 THEN
                BID.OFFER = "O"
            END ELSE
                BID.OFFER = "B"
            END
            ST.ExchangeRate.Termrate("",RATE.KEY,"",CCY,"",BID.OFFER,1,"","NO",RATE,"","","","","")

    END CASE

    IF OLD.BASIS THEN
        GOSUB ADJUST.FOR.BASIS
    END
    IF NOT(RATE) THEN
        RATE = 0
    END

    RETURN

********************************************************************************
READ.INT.DETAILS:
*****************

    NOT.FOUND = 0
    IF FIELD(INT.CODE, "*", 2,1) = "CREDIT" THEN

        GOSUB GROUP.CREDIT    ;* Get credit details

    END ELSE

        GOSUB GROUP.DEBIT     ;* Get debit details

    END

    RETURN

*******************************************************************************
GROUP.CREDIT:
*************

    GRP.DTS.REC = IC.InterestAndCapitalisation.GroupDate.CacheRead(GRP.ID, ER)
* Before incorporation : CALL CACHE.READ("F.GROUP.DATE",GRP.ID, GRP.DTS.REC, ER)
    IF GRP.DTS.REC THEN
        LOCATE EB.SystemTables.getToday() IN GRP.DTS.REC<IC.InterestAndCapitalisation.GroupDate.AcGrdCreditDates,1> BY "AR" SETTING CREDIT.DATE.IDX ELSE
        NOT.FOUND = 1     ;* BG_100008660S/E
    END
    IF CREDIT.DATE.IDX > 1 AND NOT.FOUND THEN
        CREDIT.DATE.IDX = CREDIT.DATE.IDX - 1
    END
    GCI.ID = GRP.ID:GRP.DTS.REC<IC.InterestAndCapitalisation.GroupDate.AcGrdCreditDates,CREDIT.DATE.IDX>
    CREDIT.REC = IC.Config.GroupCreditInt.CacheRead(GCI.ID, ER)
* Before incorporation : CALL CACHE.READ("F.GROUP.CREDIT.INT",GCI.ID,CREDIT.REC,ER)
    END

    NO.RATES = DCOUNT(CREDIT.REC<IC.Config.GroupCreditInt.GciCrIntRate>,@VM)    ;* check for banded rates
    IF NOT(NO.RATES) THEN
        NO.RATES = 1
    END
    IF NO.RATES GT 1 AND AMT THEN       ;* amt passed so get the correct 1 otherwise just pick up the last 1
        FOR I = 1 TO NO.RATES
            IF AMT LE CREDIT.REC<IC.Config.GroupCreditInt.GciCrLimitAmt,I> THEN
                NO.RATES = I
                EXIT
            END
        NEXT I
    END

    RATE = CREDIT.REC<IC.Config.GroupCreditInt.GciCrIntRate,NO.RATES>
    OPER = CREDIT.REC<IC.Config.GroupCreditInt.GciCrMarginOper,NO.RATES>
    SPREAD = CREDIT.REC<IC.Config.GroupCreditInt.GciCrMarginRate,NO.RATES>
    BASE.KEY = CREDIT.REC<IC.Config.GroupCreditInt.GciCrBasicRate,NO.RATES>

    RETURN

*****************************************************************************
GROUP.DEBIT:
************

    GRP.DTS.REC = IC.InterestAndCapitalisation.GroupDate.CacheRead(GRP.ID, ER)
* Before incorporation : CALL CACHE.READ("F.GROUP.DATE",GRP.ID, GRP.DTS.REC , ER)
    IF GRP.DTS.REC THEN
        LOCATE EB.SystemTables.getToday() IN GRP.DTS.REC<IC.InterestAndCapitalisation.GroupDate.AcGrdDebitDates,1> BY "AR" SETTING DEBIT.DATE.IDX ELSE
        NOT.FOUND = 1     ;* BG_100008660S/E
    END
    IF DEBIT.DATE.IDX > 1 AND NOT.FOUND THEN
        DEBIT.DATE.IDX = DEBIT.DATE.IDX - 1
    END
    GDI.ID = GRP.ID:GRP.DTS.REC<IC.InterestAndCapitalisation.GroupDate.AcGrdDebitDates,DEBIT.DATE.IDX>          ;* BG_100008660S/E
    DEBIT.REC = IC.Config.GroupDebitInt.CacheRead(GDI.ID, ER)
* Before incorporation : CALL CACHE.READ("F.GROUP.DEBIT.INT", GDI.ID, DEBIT.REC, ER)
    END

    NO.RATES = DCOUNT(DEBIT.REC<IC.Config.GroupDebitInt.GdiDrIntRate>,@VM)     ;* check for banded rates
    IF NOT(NO.RATES) THEN
        NO.RATES = 1
    END
    IF NO.RATES GT 1 AND AMT THEN       ;* amt passed so get the correct 1 otherwise just pick up the last 1
        FOR I = 1 TO NO.RATES
            IF AMT LE DEBIT.REC<IC.Config.GroupDebitInt.GdiDrLimitAmt,I> THEN
                NO.RATES = I
                EXIT
            END
        NEXT I
    END
    RATE = DEBIT.REC<IC.Config.GroupDebitInt.GdiDrIntRate,NO.RATES>
    OPER = DEBIT.REC<IC.Config.GroupDebitInt.GdiDrMarginOper,NO.RATES>
    SPREAD = DEBIT.REC<IC.Config.GroupDebitInt.GdiDrMarginRate,NO.RATES>
    BASE.KEY = DEBIT.REC<IC.Config.GroupDebitInt.GdiDrBasicRate,NO.RATES>

    RETURN

***************************************************************************
CALC.RATE:
**********

    IF BASE.KEY THEN
        GOSUB GET.FLOATING.RATE
    END

    IF SPREAD THEN
        BEGIN CASE
            CASE OPER = "ADD"
                RATE += SPREAD
            CASE OPER = "SUBTRACT"
                RATE -= SPREAD
            CASE OPER = "MULTIPLY"
                RATE = RATE + ((RATE/100) * SPREAD)
        END CASE
    END

    RETURN

******************************************************************************
GET.FLOATING.RATE:
******************

    START.DATE = ""
    ST.RateParameters.EbGetFloatingRateChanges(CCY,BASE.KEY,START.DATE,EFF.DATE,EFF.RATE)

    LOCATE EB.SystemTables.getToday() IN EFF.DATE<1> BY "DR" SETTING POS ELSE
    NULL
    END
    IF POS > 1 AND EB.SystemTables.getToday() = EFF.DATE<1,POS-1> THEN
        RATE = EFF.RATE<1,POS-1>
    END ELSE
        LOOP UNTIL EFF.DATE<1,POS> LE EB.SystemTables.getToday()
            POS += 1          ;* should never be more than 1 iteration
        REPEAT
        RATE = EFF.RATE<1,POS>
    END

    RETURN


***************************************************************************************
ADJUST.FOR.BASIS:
*****************

    IF OLD.BASIS THEN
        BEGIN CASE
            CASE OLD.BASIS EQ "B"
                RATE = RATE * (360 / 366)
            CASE OLD.BASIS EQ "E"
                RATE = RATE * (365 / 366)
            CASE OLD.BASIS EQ "F"
                RATE = RATE * (365 / 360)
        END CASE

        BEGIN CASE
            CASE BASIS EQ 'B'
                RATE = RATE * (366 / 360)
            CASE BASIS EQ 'E'
                RATE = RATE * (366 / 365)
            CASE BASIS EQ 'F'
                RATE = RATE * (360 / 365)
        END CASE
    END

    RETURN

********************************************************************************************
INITIALISE:
***********

    AMT = ABS(INT.CODE<2>) + 0          ;* could be passed for banded rates
    INT.CODE = INT.CODE<1>

    DEBIT.REC = ''
    CREDIT.REC = ''

    RETURN

    END
