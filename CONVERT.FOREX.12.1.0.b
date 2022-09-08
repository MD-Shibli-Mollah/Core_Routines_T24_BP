* @ValidationCode : MjoyMDU2MzI5ODE3OkNwMTI1MjoxNTQyMDE0Njc0NjYwOmtiaGFyYXRocmFqOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgxMS4yMDE4MTAyMi0xNDA2Oi0xOi0x
* @ValidationInfo : Timestamp         : 12 Nov 2018 14:54:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>9</Rating>
*-----------------------------------------------------------------------------
$PACKAGE FX.Contract
SUBROUTINE CONVERT.FOREX.12.1.0  
*
*     FOREIGN EXCHANGE FILE CONVERSION (12.1.0)
*     =========================================
*
*     Fills new fields created for modified accrual processing:
*
*        TOTAL.INT.BOUGHT
*        TOTAL.INT.SOLD
*        EQUIV.INT.BOUGHT
*        EQUIV.INT.SOLD
*        INT.BASIS.BOUGHT
*        INT.BASIS.SOLD
*
* Modification History:
*
* 08/11/18 - Enhancement 2822493 / Task 2845894
*            Componentization - II - Treasury - fix issues raised during strict compilation mode
*----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CURRENCY
*
    DIM FOREX(114)
*
    EQU CCY.BOUGHT TO 6
    EQU VAL.DATE.BUY TO 8
    EQU CCY.SOLD TO 9
    EQU VAL.DATE.SELL TO 11
    EQU REVAL.TYPE TO 25
    EQU SPOT.DATE TO 26
    EQU OPTION.DATE TO 32
    EQU BUY.LCY.EQUIV TO 55
    EQU SEL.LCY.EQUIV TO 56
    EQU BUY.DAILY.ACC.L TO 57
    EQU BUY.DAILY.ACC.F TO 59
    EQU SEL.DAILY.ACC.L TO 61
    EQU SEL.DAILY.ACC.F TO 63
    EQU TOTAL.INT.BOUGHT TO 94
    EQU TOTAL.INT.SOLD TO 95
    EQU EQUIV.INT.BOUGHT TO 96
    EQU EQUIV.INT.SOLD TO 97
    EQU INT.BASIS.BOUGHT TO 98
    EQU INT.BASIS.SOLD TO 99
*
*-----LOCAL FORMAT-------------------------------------------------------
*
    LOCAL.FORMAT='' ; CALL DBR('CURRENCY':@FM:EB.CUR.NO.OF.DECIMALS,LCCY,LOCAL.FORMAT)
    LOCAL.FORMAT='MD':LOCAL.FORMAT
*
*=====MAIN CONTROL========================================================
*
    CALL SF.CLEAR.STANDARD
    FOREX.FILE='F.FOREX' ; F.FOREX=''
    CALL OPF(FOREX.FILE,F.FOREX)
    GOSUB FOREX.ID
    FOREX.FILE='F.FOREX$NAU' ; F.FOREX=''
    CALL OPF(FOREX.FILE,F.FOREX)
    GOSUB FOREX.ID
RETURN
*
*-----FOREX ID------------------------------------------------------------
*
FOREX.ID:
    CALL SF.CLEAR(1,5,"FILE RUNNING:  ":FOREX.FILE)
    SELECT F.FOREX
    LOOP
        READNEXT FOREX.ID ELSE FOREX.ID=''
    UNTIL FOREX.ID='' DO
        GOSUB FOREX
    REPEAT
RETURN
*
*-----FOREX---------------------------------------------------------------
*
FOREX:
    MATREAD FOREX FROM F.FOREX,FOREX.ID THEN
        PRINT @(1,7):FMT('CONVERTING ':FOREX.ID,'60L'):
        BEGIN CASE
            CASE FOREX(REVAL.TYPE)='IN'
                GOSUB INTEREST.METHOD
                MATWRITE FOREX TO F.FOREX,FOREX.ID
            CASE FOREX(REVAL.TYPE)='SL'
                GOSUB STRAIGHT.LINE
                MATWRITE FOREX TO F.FOREX,FOREX.ID
        END CASE
    END
RETURN
*
*-----INTEREST METHOD-----------------------------------------------------
*
INTEREST.METHOD:
    GOSUB TOTAL.NO.OF.DAYS ; GOSUB BUY.FORMAT ; GOSUB SELL.FORMAT
    FOREX(TOTAL.INT.BOUGHT)=OCONV(ICONV(FOREX(BUY.DAILY.ACC.F)*TOTAL.NO.OF.DAYS,BUY.FORMAT),BUY.FORMAT)
    FOREX(TOTAL.INT.SOLD)=OCONV(ICONV(FOREX(SEL.DAILY.ACC.F)*TOTAL.NO.OF.DAYS,SELL.FORMAT),SELL.FORMAT)
    FOREX(EQUIV.INT.BOUGHT)=OCONV(ICONV(FOREX(BUY.DAILY.ACC.L)*TOTAL.NO.OF.DAYS,LOCAL.FORMAT),LOCAL.FORMAT)
    FOREX(EQUIV.INT.SOLD)=OCONV(ICONV(FOREX(SEL.DAILY.ACC.L)*TOTAL.NO.OF.DAYS,LOCAL.FORMAT),LOCAL.FORMAT)
    GOSUB ADJUSTMENT
RETURN
*
*-----STRAIGHT-LINE-------------------------------------------------------
*
STRAIGHT.LINE:
    EQUIV.INT=FOREX(BUY.LCY.EQUIV)+FOREX(SEL.LCY.EQUIV)
    IF EQUIV.INT LT 0 THEN
        FOREX(EQUIV.INT.BOUGHT)=OCONV(ICONV(ABS(EQUIV.INT),LOCAL.FORMAT),LOCAL.FORMAT)
    END ELSE
        FOREX(EQUIV.INT.SOLD)=OCONV(ICONV(EQUIV.INT,LOCAL.FORMAT),LOCAL.FORMAT)
    END
RETURN
*
*-----TOTAL NO OF DAYS---------------------------------------------------
*
TOTAL.NO.OF.DAYS:
    BEGIN CASE
        CASE FOREX(OPTION.DATE)#''
            VALUE.DATE=FOREX(OPTION.DATE)
        CASE FOREX(VAL.DATE.BUY) GE FOREX(VAL.DATE.SELL)
            VALUE.DATE=FOREX(VAL.DATE.SELL)
        CASE 1
            VALUE.DATE=FOREX(VAL.DATE.BUY)
    END CASE
    IF VALUE.DATE GT FOREX(SPOT.DATE) THEN
        TOTAL.NO.OF.DAYS=ICONV(VALUE.DATE[7,2]:'/':VALUE.DATE[5,2]:'/':VALUE.DATE[3,2],'D2/E')-ICONV(FOREX(SPOT.DATE)[7,2]:'/':FOREX(SPOT.DATE)[5,2]:'/':FOREX(SPOT.DATE)[3,2],'D2/E')
    END ELSE
        TOTAL.NO.OF.DAYS=1
    END
RETURN
*
*-----BUY FORMAT----------------------------------------------------------
*
BUY.FORMAT:
    IF FOREX(CCY.BOUGHT)#LCCY THEN
        BUY.FORMAT='' ; CALL DBR('CURRENCY':@FM:EB.CUR.NO.OF.DECIMALS,FOREX(CCY.BOUGHT),BUY.FORMAT)
        BUY.FORMAT='MD':BUY.FORMAT
    END ELSE
        BUY.FORMAT=LOCAL.FORMAT
    END
RETURN
*
*-----SELL FORMAT---------------------------------------------------------
*
SELL.FORMAT:
    IF FOREX(CCY.SOLD)#LCCY THEN
        SELL.FORMAT='' ; CALL DBR('CURRENCY':@FM:EB.CUR.NO.OF.DECIMALS,FOREX(CCY.SOLD),SELL.FORMAT)
        SELL.FORMAT='MD':SELL.FORMAT
    END ELSE
        SELL.FORMAT=LOCAL.FORMAT
    END
RETURN
*
*-----ADJUSTMENT----------------------------------------------------------
*
ADJUSTMENT:
    ADJ=FOREX(EQUIV.INT.BOUGHT)-FOREX(EQUIV.INT.SOLD)+FOREX(BUY.LCY.EQUIV)+FOREX(SEL.LCY.EQUIV)
    IF ADJ THEN
        IF FOREX(EQUIV.INT.BOUGHT) GE FOREX(EQUIV.INT.SOLD) THEN
            FOREX(EQUIV.INT.BOUGHT)=OCONV(ICONV(FOREX(EQUIV.INT.BOUGHT)-ADJ,LOCAL.FORMAT),LOCAL.FORMAT)
            FOREX(TOTAL.INT.BOUGHT)=OCONV(ICONV(FOREX(TOTAL.INT.BOUGHT)-(ADJ*FOREX(BUY.DAILY.ACC.F)/FOREX(BUY.DAILY.ACC.L)),BUY.FORMAT),BUY.FORMAT)
        END ELSE
            FOREX(TOTAL.INT.SOLD)=OCONV(ICONV(FOREX(TOTAL.INT.SOLD)+(ADJ*FOREX(SEL.DAILY.ACC.F)/FOREX(SEL.DAILY.ACC.L)),SELL.FORMAT),SELL.FORMAT)
            FOREX(EQUIV.INT.SOLD)=OCONV(ICONV(FOREX(EQUIV.INT.SOLD)+ADJ,LOCAL.FORMAT),LOCAL.FORMAT)
        END
    END
RETURN
END
