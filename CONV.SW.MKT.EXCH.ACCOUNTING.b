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

* Version 1 11/08/05  GLOBUS Release No. 200512 09/12/05
*-----------------------------------------------------------------------------
* <Rating>-124</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SW.Foundation
    SUBROUTINE CONV.SW.MKT.EXCH.ACCOUNTING(LEG.TYPE,AMOUNT,VALUE.DATE,PROCESS.DATE,NARRATIVE,REVERSAL,RECALCULATE)
************************************************************************
*  Routine     :  CONV.SW.MKT.EXCH.ACCOUNTING                               *
************************************************************************
*  Description :  This routine will create all accounting and crf      *
*                 entries for swap contracts.  It will be called for   *
*                 each schedule event in the swap, both asset and      *
*                 liability, to create the entries and 'append' them   *
*                 to an array of entries, held in common (I_SW.COMMON).*
*                 Accounting entries will be appended to the entry     *
*                 array SW.ACCOUNTING.ENTRIES, and Forward entries to  *
*                 the entry array SW.FORWARD.ENTRIES.                  *
*                 They will then be passed to EB.ACCOUNTING by the     *
*                 calling routine.                                     *
*                                                                      *
*                 The arguments supplied to this routine are as follows*
*                                                                      *
*                 o LEG.TYPE        -  Leg being processed.            *
*                                      Asset or Liability (A or L).    *
*                                                                      *
*                 o AMOUNT<1>          -  Amount to be post (unsigned)    *
*                                      and in the correct currency.    *
*                 o AMOUNT<2>          -  Amount already accrued in the balance    *
*                                      and in the correct currency. This value will be available   *
*                                     only if an IP has already been processed.
*                                                                      *
*                 o VALUE.DATE      -  Value Date of schedule.         *
*                                      Default today.                  *
*                                                                      *
*                 o PROCESS.DATE    -  Process date of underlying      *
*                                      schedule (ie. Forward or Real   *
*                                      entry).  Default today.         *
*                                                                      *
*                 o NARRATIVE       -  Narrative to be included on the *
*                                      entry (1 or 0).                 *
*                                                                      *
*                 o REVERSAL        -  Flag to indicate entries are    *
*                                      reversals.                      *
*                                                                      *
*                 o RECALCULATE     -  Flag to indicate whether posting*
*                                      is required after reversal      *
*************************************************************************
*  Modifications :                                                      *
*
* 19/02/07 - BG_100013039
*            Initial Version for conversion processing.
*
* 22/09/08 - BG_100020085
*            Rating Reduction for SWAP routines.
*
*************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.ACCOUNT.CLASS
    $INSERT I_F.DATES
    $INSERT I_F.DEALER.DESK
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.CONV.SWAP
    $INSERT I_F.CONV.SWAP.BALANCES
    $INSERT I_F.SWAP.PARAMETER
    $INSERT I_F.SWAP.SCHEDULE.TYPE
    $INSERT I_F.SWAP.TYPE
    $INSERT I_SW.COMMON
    $INSERT I_SW.TRANSACTION.CODES
*
*************************************************************************
*
    GOSUB INITIALISATION
    GOSUB RAISE.MKT.EXCH.PL
    RETURN

***************
INITIALISATION:
***************
    Y.CUR.CUST.RATE = '' ; Y.CUR.TRSY.RATE = '' ; REVAL.DEPT = ''
    PL.CATEGORY = '' ; PROD.CATEGORY = '' ; TRANSACTION.CODE = ''
    EXCH.RATE = '' ; LCY.AMOUNT = '' ; FCY.AMOUNT = '' ; R.DEALER.DESK = ''
    OUTS.PRIN.LCY = '' ; TRANSACTION.CODE = '' ; Y.TOT.MKT.EX.INT.AMT = ''
    IP.PROCESSED = 0 ; Y.TOT.ACCRUED.AMT = 0 ; REM.MKT.EXCH.AMT = 0

    BASE.CURRENCY = R$SWAP<SW.BASE.CURRENCY>
    IF LEG.TYPE = 'A' THEN
        LEG.CCY = R$SW.ASSET.BALANCES<SW.BAL.CURRENCY>

        IF R$SW.ASSET.BALANCES<SW.BAL.TOT.MKT.INT.AMT> THEN
            Y.TOT.MKT.EX.INT.AMT = R$SW.ASSET.BALANCES<SW.BAL.TOT.MKT.INT.AMT>
        END

        Y.CUR.CUST.RATE = R$SWAP<SW.AS.CURRENT.RATE>
        Y.CUR.TRSY.RATE = R$SWAP<SW.AS.CUR.TRSRY.RATE>
    END ELSE
        LEG.CCY = R$SW.LIABILITY.BALANCES<SW.BAL.CURRENCY>

        IF R$SW.LIABILITY.BALANCES<SW.BAL.TOT.MKT.INT.AMT> THEN
            Y.TOT.MKT.EX.INT.AMT = R$SW.LIABILITY.BALANCES<SW.BAL.TOT.MKT.INT.AMT>
        END

        Y.CUR.CUST.RATE = R$SWAP<SW.LB.CURRENT.RATE>
        Y.CUR.TRSY.RATE = R$SWAP<SW.LB.CUR.TRSRY.RATE>
    END


    IF AMOUNT<2> THEN         ;* Will be present for TOT.MKT.EXCH and when an amendment is made after any IP has already been processed
        Y.TOT.ACCRUED.AMT = ABS(AMOUNT<2>)
        AMOUNT = AMOUNT<1>
        REM.MKT.EXCH.AMT = Y.TOT.MKT.EX.INT.AMT - Y.TOT.ACCRUED.AMT + 0
        IP.PROCESSED = 1
    END

    CALL CACHE.READ('F.DEALER.DESK', R$SWAP<SW.DEALER.DESK>, R.DEALER.DESK, "")
    REVAL.DEPT = R.DEALER.DESK<FX.DD.DEPT>
    REVAL.DEPT = FMT(REVAL.DEPT,'4"0"R')

    RESERVE.DR.CODE = R$SWAP.PARAMETER<SW.PARAM.MKT.EX.DR.CODE>
    RESERVE.CR.CODE = R$SWAP.PARAMETER<SW.PARAM.MKT.EX.CR.CODE>
    RETURN
*
****************
REVERSE.AMOUNTS:
****************
*
*  Revese signs of lcy.amount and fcy.amount
*
    LCY.AMOUNT = -LCY.AMOUNT
    IF FCY.AMOUNT THEN
        FCY.AMOUNT = -FCY.AMOUNT
    END
*
    RETURN

**********************
DETERMINE.CCY.AMOUNTS:
**********************
*
*  Foreign CCY / Local CCY Conversion.
*
    IF LEG.CCY = LCCY THEN
        LCY.AMOUNT = AMOUNT
        FCY.AMOUNT = ""
    END ELSE
        FCY.AMOUNT = AMOUNT
        CALL MIDDLE.RATE.CONV.CHECK(FCY.AMOUNT,LEG.CCY,EXCH.RATE,"1",LCY.AMOUNT,"","")
        CALL EB.ROUND.AMOUNT(LCCY, LCY.AMOUNT, "", "")
    END
*
    RETURN

********************
APPEND.LIVE.ENTRIES:
********************
***************************************************************************
* Append accounting entries to an array of entries (C$ACCOUNTING.ENTRIES) *
* held in common(I_SW.COMMON). They will all be held here and then passed *
* to EB.ACCOUNTING by the calling routine.                                *
***************************************************************************
    IF REVERSAL THEN
        ENTRY<AC.STE.AMOUNT.LCY> = -ENTRY<AC.STE.AMOUNT.LCY>
        IF ENTRY<AC.STE.AMOUNT.FCY> THEN
            ENTRY<AC.STE.AMOUNT.FCY> = -ENTRY<AC.STE.AMOUNT.FCY>
        END
    END

    C$ACCOUNTING.ENTRIES<-1> = LOWER(ENTRY)
    RETURN
*
******************
RAISE.MKT.EXCH.PL:
******************
    AMOUNT = ABS(AMOUNT)
    PL.CATEGORY = R$SWAP.PARAMETER<SW.PARAM.MKT.EX.PL.PR.CAT>
    PROD.CATEGORY = R$SWAP.PARAMETER<SW.PARAM.MKT.EX.PRD.PR.CAT>

    IF LEG.TYPE = 'A' THEN
        IF Y.CUR.CUST.RATE LT Y.CUR.TRSY.RATE THEN          ;* Market Exchange Loss
            AMOUNT = 0 - AMOUNT
            IF IP.PROCESSED THEN
                REM.MKT.EXCH.AMT = 0 - (Y.TOT.MKT.EX.INT.AMT - Y.TOT.ACCRUED.AMT)
            END
            Y.TOT.MKT.EX.INT.AMT = 0 - Y.TOT.MKT.EX.INT.AMT
            Y.TOT.ACCRUED.AMT = 0 - Y.TOT.ACCRUED.AMT
            PL.CATEGORY = R$SWAP.PARAMETER<SW.PARAM.MKT.EX.PL.LO.CAT>
            PROD.CATEGORY = R$SWAP.PARAMETER<SW.PARAM.MKT.EX.PRD.LO.CAT>
        END
    END ELSE        ;* LEG.TYPE = 'L'
        IF Y.CUR.CUST.RATE GT Y.CUR.TRSY.RATE THEN          ;* Market Exchange Loss
            AMOUNT = 0 - AMOUNT
            IF IP.PROCESSED THEN
                REM.MKT.EXCH.AMT = 0 - (Y.TOT.MKT.EX.INT.AMT - Y.TOT.ACCRUED.AMT)
            END
            Y.TOT.MKT.EX.INT.AMT = 0 - Y.TOT.MKT.EX.INT.AMT
            Y.TOT.ACCRUED.AMT = 0 - Y.TOT.ACCRUED.AMT
            PL.CATEGORY = R$SWAP.PARAMETER<SW.PARAM.MKT.EX.PL.LO.CAT>
            PROD.CATEGORY = R$SWAP.PARAMETER<SW.PARAM.MKT.EX.PRD.LO.CAT>
        END
    END
    GOSUB RAISE.MKT.EXCH.ENTRIES        ;* OLD AMOUNT REVERSAL IS BEING DONE.

    IF RECALCULATE THEN       ;* RECALCULATION OF NEW AMOUNT
        IF NOT(IP.PROCESSED) THEN       ;* No IP processed then

            AMOUNT = Y.TOT.MKT.EX.INT.AMT         ;* Just post the new amount
            LCY.AMOUNT = '' ; EXCH.RATE = '' ; REVERSAL = ''
            GOSUB RAISE.MKT.EXCH.ENTRIES

        END ELSE
* this case is specific to an amendment being made between IPs.

            AMOUNT = Y.TOT.ACCRUED.AMT  ;* Amount already taken from customer or already accrued
            LCY.AMOUNT = '' ; EXCH.RATE = '' ; REVERSAL = ''
            GOSUB RAISE.MKT.EXCH.ENTRIES

            AMOUNT = REM.MKT.EXCH.AMT   ;* New amount that has been calculated from the the current period start.date to mat date
            LCY.AMOUNT = '' ; EXCH.RATE = '' ; REVERSAL = ''
            GOSUB RAISE.MKT.EXCH.ENTRIES
        END

    END

    RETURN
*
***********************
RAISE.MKT.EXCH.ENTRIES:
***********************
    LCY.AMOUNT = '' ; EXCH.RATE = ''

* To raise Market Exchange P/L
    IF NOT(PL.CATEGORY) THEN
        ETEXT = 'SW-MISS.MKT.EXCH.PL.CATEGORY'
        GOSUB FATAL.ERROR
    END ELSE
        GOSUB DETERMINE.CCY.AMOUNTS
        GOSUB RAISE.CATEG.ENTRY
    END

* To raise Market Exchange Suspence Amount(contra entry of P/L).
    IF NOT(PROD.CATEGORY) THEN
        ETEXT = 'SW-MISS.MKT.EXCH.PROD.CATEGORY'
        GOSUB FATAL.ERROR
    END ELSE
        RESERVE.ACCOUNT.NUMBER = LCCY:PROD.CATEGORY:REVAL.DEPT
        OUTS.PRIN.LCY = LCY.AMOUNT
        GOSUB RAISE.RESERVE.ENTRY
    END
    RETURN
*
********************
RAISE.RESERVE.ENTRY:
********************
*
    LCY.AMOUNT = -LCY.AMOUNT
    IF LCY.AMOUNT < 0 THEN
        TRANSACTION.CODE = RESERVE.DR.CODE
    END ELSE
        TRANSACTION.CODE = RESERVE.CR.CODE
    END
*
    GOSUB BUILD.BASE.ENTRY
*
    ENTRY<AC.STE.ACCOUNT.NUMBER> = RESERVE.ACCOUNT.NUMBER
    ENTRY<AC.STE.AMOUNT.LCY> = LCY.AMOUNT
    ENTRY<AC.STE.AMOUNT.FCY> = ''
    ENTRY<AC.STE.EXCHANGE.RATE> = ''
    ENTRY<AC.STE.CURRENCY> = LCCY
*
    GOSUB APPEND.LIVE.ENTRIES
*
    RETURN
*
******************
RAISE.CATEG.ENTRY:
******************
*
*  Only live categ.entry
*
    GOSUB BUILD.BASE.ENTRY
*
    ENTRY<AC.STE.AMOUNT.LCY> = LCY.AMOUNT
    ENTRY<AC.STE.PL.CATEGORY> = PL.CATEGORY

    IF FCY.AMOUNT NE 0 AND FCY.AMOUNT NE '' THEN
        ENTRY<AC.STE.AMOUNT.FCY> = FCY.AMOUNT
        ENTRY<AC.STE.EXCHANGE.RATE> = EXCH.RATE
    END
*
    GOSUB APPEND.LIVE.ENTRIES
*
    RETURN
*
*****************
BUILD.BASE.ENTRY:
*****************
*
***********************************************************
*  Build base STMT.ENTRY entry fields.                    *
***********************************************************
*
    ENTRY = ""
*
    ENTRY<AC.STE.ACCOUNT.NUMBER> = ""
    ENTRY<AC.STE.COMPANY.CODE> = ID.COMPANY
    ENTRY<AC.STE.AMOUNT.LCY> = 0
    ENTRY<AC.STE.TRANSACTION.CODE> = TRANSACTION.CODE
    ENTRY<AC.STE.THEIR.REFERENCE> = R$SWAP<SW.CUSTOMER.REF>
    ENTRY<AC.STE.NARRATIVE> = NARRATIVE
    ENTRY<AC.STE.PL.CATEGORY> = ""
    ENTRY<AC.STE.CUSTOMER.ID> = R$SWAP<SW.CUSTOMER>
    ENTRY<AC.STE.ACCOUNT.OFFICER> = R$SWAP<SW.ACCOUNT.OFFICER>
    ENTRY<AC.STE.PRODUCT.CATEGORY> = R$SWAP<SW.PRODUCT.CATEGORY>
    ENTRY<AC.STE.VALUE.DATE> = VALUE.DATE
    ENTRY<AC.STE.CURRENCY> = LEG.CCY
    ENTRY<AC.STE.AMOUNT.FCY> = ""
    ENTRY<AC.STE.EXCHANGE.RATE> = ""
    ENTRY<AC.STE.POSITION.TYPE> = R$SWAP<SW.POSITION.TYPE>
    ENTRY<AC.STE.OUR.REFERENCE> = C$SWAP.ID:".":LEG.TYPE
    ENTRY<AC.STE.CURRENCY.MARKET> = R$SWAP<SW.CURRENCY.MARKET>
    ENTRY<AC.STE.DEPARTMENT.CODE> = R$SWAP<SW.ACCOUNT.OFFICER>
    ENTRY<AC.STE.TRANS.REFERENCE> = C$SWAP.ID:";":R$SWAP<SW.CURR.NO>+1
    ENTRY<AC.STE.SYSTEM.ID> = "SW"
    ENTRY<AC.STE.BOOKING.DATE> = TODAY
    ENTRY<AC.STE.CRF.TYPE> = ""
    ENTRY<AC.STE.CRF.TXN.CODE> = ""
    ENTRY<AC.STE.CRF.MAT.DATE> = ""
    ENTRY<AC.STE.DEALER.DESK> = R$SWAP<SW.DEALER.DESK>
*
    IF REVERSAL THEN
        ENTRY<AC.STE.REVERSAL.MARKER> = "R"
    END ELSE
        ENTRY<AC.STE.REVERSAL.MARKER> = ""
    END
*
    RETURN
*
************
FATAL.ERROR:
************
    TEXT = ETEXT
    CALL FATAL.ERROR('SW.MKT.EXCH.ACCOUNTING')
    RETURN
END
