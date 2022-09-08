* @ValidationCode : Mjo0MTEwMzQ1OTE6Q3AxMjUyOjE1NjQ1NzIzNjQzNjg6c3JhdmlrdW1hcjotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTA4LjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:56:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* This routine is to convert the existing PS.STOP into chequenos*chequetype
*-----------------------------------------------------------------------------
* <Rating>255</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CQ.ChqPaymentStop
    SUBROUTINE CONV.PS.PS.STOP.G13.1(PS.ID,PS.STP.REC,FV.PS.STP)
*
***************************************************************************
*
* 03/11/03 - BG_100005581
*            Length of the cheque number is validated
*
* 01/06/07 - CI_10049495
*            READU & WRITE are used instead of F.READ & F.WRITE, to avoid READ_ERROR.
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
***************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.PAYMENT.STOP
    $INSERT I_F.PS.STOP
*
    GOSUB INITIALISATION

    NEW.STOP.REC = ''

    RAI.PS.STOP.TYPE = RAISE(PS.STP.REC<AC.PAY.PAYM.STOP.TYPE>)
    RAI.PS.DATE = RAISE(PS.STP.REC<AC.PAY.APPLY.DATE>)
    RAI.FIR.CHQ.NO = RAISE(PS.STP.REC<AC.PAY.FIRST.CHEQUE.NO>)
    RAI.LAS.CHQ.NO = RAISE(PS.STP.REC<AC.PAY.LAST.CHEQUE.NO>)
    RAI.AMT.FR = RAISE(PS.STP.REC<AC.PAY.AMOUNT.FROM>)
    RAI.AMT.TO = RAISE(PS.STP.REC<AC.PAY.AMOUNT.TO>)
    RAI.CHQ.TYP = RAISE(PS.STP.REC<AC.PAY.CHEQUE.TYPE>)
*
    LOOP
*
        REMOVE PS.TYPE FROM RAI.PS.STOP.TYPE SETTING GID
        REMOVE PS.DATE FROM RAI.PS.DATE SETTING DAT
        REMOVE FIR.CHQ FROM RAI.FIR.CHQ.NO SETTING FIR
        REMOVE LAS.CHQ FROM RAI.LAS.CHQ.NO SETTING LAS
        REMOVE AMT.FR FROM RAI.AMT.FR SETTING AMFR
        REMOVE AMT.TO FROM RAI.AMT.TO SETTING AMTO
        REMOVE CHQ.TYP FROM RAI.CHQ.TYP SETTING CHTYP
*
    UNTIL PS.TYPE EQ '' DO
        IF PS.DATE THEN
            PS.REC2 = FIR.CHQ:"*":LAS.CHQ:"*":AMT.FR:"*":AMT.TO
            PS.STOP.ID = PS.DATE:'.':PS.ID
            PS.STOP.REC = ''
            READU PS.STOP.REC FROM FP.STOP, PS.STOP.ID THEN ;* CI_10049495 S/E
            END
            LOCATE PS.REC2 IN PS.STOP.REC<1,1> SETTING POS THEN
                CHQ.FIRST.ONE = FIELD(PS.REC2,'*',1)
                CHQ.LAST.ONE = FIELD(PS.REC2,'*',2)
                IF CHQ.FIRST.ONE AND CHQ.LAST.ONE THEN
                    CLEN = LEN(CHQ.FIRST.ONE)
* BG_100005581 - Start
*                  FOR CHQ.NO = CHQ.FIRST.ONE TO CHQ.LAST.ONE
*                     XXN = CLEN:'"0"':'R'
*                     CHQ.NO = FMT(CHQ.NO,XXN)
                    LOOP
                    UNTIL CHQ.FIRST.ONE GT CHQ.LAST.ONE DO
                        CHK.FIRST.ONE = CHQ.FIRST.ONE
                        CHQ.NO = CHQ.FIRST.ONE
                        NEW.STOP.REC<1,-1> = CHQ.NO:'*':CHQ.TYP:'*':AMT.FR:'*':AMT.TO
                        CHQ.FIRST.LEN = LEN(CHQ.FIRST.ONE)
                        CHQ.FIRST.ONE += 1
                        IF CHK.FIRST.ONE[1,1] EQ '0' THEN
                            LOOP
                                CHQ.FST.LNE = LEN(CHQ.FIRST.ONE)
                            UNTIL CHQ.FIRST.LEN EQ CHQ.FST.LNE
                                CHQ.FIRST.ONE = '0':CHQ.FIRST.ONE
                            REPEAT
                        END
                    REPEAT
*                  NEXT CHQ.NO
* BG_100005581 - End
                END ELSE
                    IF CHQ.FIRST.ONE THEN
                        NEW.STOP.REC<1,-1> = CHQ.FIRST.ONE:'*':CHQ.TYP:'*':AMT.FR:'*':AMT.TO
                    END
                END
            END
        END
    REPEAT
    GOSUB WRITE.PS.STOP
*      REPEAT

    RETURN

INITIALISATION:
*
    FP.PS.STP = ''
    CALL OPF(FV.PS.STP,FP.PS.STP)
    COM.MNE = FV.PS.STP[2,3]
    FV.STOP = 'F':COM.MNE:'.PS.STOP'
    FP.STOP = ''
    CALL OPF(FV.STOP,FP.STOP)
    RETURN
*
    RETURN

WRITE.PS.STOP:
*
    WRITE NEW.STOP.REC ON FP.STOP, PS.STOP.ID     ;* CI_10049495 S/E
    RETURN
END
