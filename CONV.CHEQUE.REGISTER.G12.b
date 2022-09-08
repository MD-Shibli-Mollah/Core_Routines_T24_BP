* @ValidationCode : MjotMTQ0ODQ0MDE1MzpDcDEyNTI6MTU2NDU3ODAzMTM5MTpzcmF2aWt1bWFyOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDguMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 Jul 2019 18:30:31
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

*-----------------------------------------------------------------------------
* <Rating>-22</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqSubmit
SUBROUTINE CONV.CHEQUE.REGISTER.G12
* 07/11/01 - CI_10000488
*            In CHEQUE.REGISTER record company code is not updated.
*            Because of this conversion is not done properly.
*            SO this routine is added as pre-routine to add the
*            company code in all cheque register.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Submit as ST_ChqSubmit and include $PACKAGE
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CHEQUE.REGISTER
    $INSERT I_F.COMPANY
    F.CHEQUE.REGISTER = 'F.CHEQUE.REGISTER'
    F.CHEQUE.REGISTER.FILE = ''
    F.CHEQUE.REGISTER$NAU = 'F.CHEQUE.REGISTER$NAU'
    F.CHEQUE.REGISTER$NAU.FILE = ''
    CALL OPF(F.CHEQUE.REGISTER,F.CHEQUE.REGISTER.FILE)
    CALL OPF(F.CHEQUE.REGISTER$NAU,F.CHEQUE.REGISTER$NAU.FILE)

* Processing authorise records
    SELECTED = '' ; SELECTED.REC = '' ; ER = ''
    SEL.CMD = 'SSELECT ' : F.CHEQUE.REGISTER : ' WITH CO.CODE EQ ""'
    CALL EB.READLIST(SEL.CMD,SELECT.REC,'',SELECTED,ER)
    FOR I = 1 TO SELECTED
        CALL F.READU('F.CHEQUE.REGISTER',SELECT.REC<I>,CHQ.REG.REC,F.CHEQUE.REGISTER,ER,'')
        CHQ.REG.REC<20> = ID.COMPANY
        CALL F.WRITE('F.CHEQUE.REGISTER',SELECT.REC<I>,CHQ.REG.REC)
        CALL JOURNAL.UPDATE(SELECT.REC<I>)
    NEXT I

* Processing Unauth records
    SELECTED = '' ; SELECTED.REC = '' ; ER = ''
    SEL.CMD = 'SSELECT ' : F.CHEQUE.REGISTER$NAU : ' WITH CO.CODE EQ ""'
    CALL EB.READLIST(SEL.CMD,SELECT.REC,'',SELECTED,ER)
    FOR I = 1 TO SELECTED
        CALL F.READU('F.CHEQUE.REGISTER$NAU',SELECT.REC<I>,CHQ.REG.REC,F.CHEQUE.REGISTER$NAU,ER,'')
        CHQ.REG.REC<20> = ID.COMPANY
        CALL F.WRITE('F.CHEQUE.REGISTER$NAU',SELECT.REC<I>,CHQ.REG.REC)
        CALL JOURNAL.UPDATE(SELECT.REC<I>)
    NEXT I
RETURN
END
