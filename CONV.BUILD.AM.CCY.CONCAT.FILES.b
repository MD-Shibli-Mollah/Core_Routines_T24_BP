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
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Foundation
    SUBROUTINE CONV.BUILD.AM.CCY.CONCAT.FILES
*
* 28/09/2003 - EN_10001920
*
* A converiosn routine to build the two new concat files
* for the existing AM.CCY.RATE records.
*
***********************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AM.CCY.RATE
*
    FN.AM.CCY.RATE = 'F.AM.CCY.RATE'
    FP.AM.CCY.RATE = ''
    CALL OPF(FN.AM.CCY.RATE,FP.AM.CCY.RATE)
*
    FN.AM.CCY.BANK.DATE.CON = 'F.AM.CCY.BANK.DATE.CON'
    FP.AM.CCY.BANK.DATE.CON = ''
    CALL OPF(FN.AM.CCY.BANK.DATE.CON,FP.AM.CCY.BANK.DATE.CON)
*
    FN.AM.CCY.DATE.RATE.CON = 'F.AM.CCY.DATE.RATE.CON'
    FP.AM.CCY.DATE.RATE.CON = ''
    CALL OPF(FN.AM.CCY.DATE.RATE.CON,FP.AM.CCY.DATE.RATE.CON)
*
    SEL.CMD = 'SELECT ':FN.AM.CCY.RATE
    CALL EB.READLIST(SEL.CMD, SEL.LIST, '', NOR, SEL.ERR)
    IF SEL.LIST THEN
        LOOP
            REMOVE AM.CCY.ID FROM SEL.LIST SETTING SEL.POS
        WHILE AM.CCY.ID:SEL.POS

            CALL F.READ(FN.AM.CCY.RATE, AM.CCY.ID, AM.CCY.REC, FP.AM.CCY.RATE, AM.CCY.ERR)
            CCY.ID = FIELD(AM.CCY.ID,'.',1)
            DATE.ID = FIELD(AM.CCY.ID,'.',2)

            MULTI.CTR = DCOUNT(AM.CCY.REC<AM.CCY.RATE.BANK.DATE>,VM)
            FOR MULTI.CNT = 1 TO MULTI.CTR
                BANK.DATE = AM.CCY.REC<AM.CCY.RATE.BANK.DATE, MULTI.CNT>
                GOSUB UPDATE.BANK.DATE
            NEXT MULTI.CNT

        NEW.RATE = AM.CCY.REC<AM.CCY.RATE.NEW.EXCH.RATE, MULTI.CTR>
        GOSUB UPDATE.DATE.RATE

        REPEAT
    END
    RETURN
****************
UPDATE.BANK.DATE:
****************

    CALL CONCAT.FILE.UPDATE(FN.AM.CCY.BANK.DATE.CON,BANK.DATE,AM.CCY.ID,'I','AL')

    RETURN
****************
UPDATE.DATE.RATE:
****************
    CALL F.READ(FN.AM.CCY.DATE.RATE.CON, CCY.ID, R.CON, FP.AM.CCY.DATE.RATE.CON, CON.ERR)
    IF R.CON THEN
        LOCATE DATE.ID IN R.CON<1,1> BY 'DR' SETTING DT.POS THEN
            R.CON<2,DT.POS> = NEW.RATE
        END ELSE
            INS DATE.ID BEFORE R.CON<1,DT.POS>
            INS NEW.RATE BEFORE R.CON<2,DT.POS>
        END
    END ELSE
        R.CON<1,1> = DATE.ID
        R.CON<2,1> = NEW.RATE
    END
    WRITE R.CON TO FP.AM.CCY.DATE.RATE.CON, CCY.ID

    RETURN

END
