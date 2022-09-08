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
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SL.BuySell
    SUBROUTINE CONV.SL.BS.AMORT.DTLS.200605(AM0RT.ID, AMORT.REC, SLL.FILE)

    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    EQU SL.AMOR.TOT.AMT.TO.AMORT TO 3
    EQU SL.AMOR.NEXT.AMORT.DATE TO 4
    EQU SL.AMOR.AMORTISED.AMT TO 5
    EQU SL.AMOR.AMORTISE.FREQ TO 6
    EQU SL.AMOR.AMT.PREMIUM TO 8
    EQU SL.AMOR.AMT.DISCOUNT TO 9
    EQU SL.AMOR.AMORT.DIS.AMT TO 10
*
    AMORT.REC<SL.AMOR.AMORTISE.FREQ> = AMORT.REC<SL.AMOR.NEXT.AMORT.DATE>:"M0131"
    IF AMORT.REC<SL.AMOR.TOT.AMT.TO.AMORT> GE 0 THEN
        AMORT.REC<SL.AMOR.AMT.PREMIUM> = AMORT.REC<SL.AMOR.TOT.AMT.TO.AMORT>
    END ELSE
        AMORT.REC<SL.AMOR.AMT.DISCOUNT> = AMORT.REC<SL.AMOR.TOT.AMT.TO.AMORT>
        AMORT.REC<SL.AMOR.AMORT.DIS.AMT> = AMORT.REC<SL.AMOR.AMORTISED.AMT>
        AMORT.REC<SL.AMOR.AMORTISED.AMT> = ''
    END

    RETURN
END
