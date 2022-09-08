* @ValidationCode : MjotMTI1NTkzNTAyNTpDcDEyNTI6MTU2NDU3MDYzODA0MDpzcmF2aWt1bWFyOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDguMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:27:18
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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CQ.ChqConfig
    SUBROUTINE CONV.CQ.PAR.G12.2

*      Conversion routine to select the SYSTEM record from the  STOCK.PARAMETER file
*      update the CQ.PARAMETER.
**********************************************************
* 26/02/02 - GLOBUS_EN_10000496
*            Introducing CQ.PARAMETER
*
* 11/03/02 - GLOBUS_BG_100000691
*      Fixing the bug in converstion routine
*
* 12/12/08 - BG_100021277
*            F.READ, F.WRITE, F.DELETE and F.RELEASE are changed to READ, WRITE,
*            DELETE and RELEASE respectively.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Config as ST_ChqConfig and include $PACKAGE
*	
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
**********************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE

* GLOBUS_BG_100000691-S
*     EQU CQ.PAR.CHEQUE.REGISTER TO 1, CQ.PAR.CHQ.DEP.TXN TO 2,
*       CQ.PAR.DEF.COLL.SUSP TO 3, CQ.PAR.CHQ.COL.TXN TO 4,
*        CQ.PAR.CHQ.RET.TXN TO 5, CQ.PAR.DEF.RET.SUSP TO 6,
*        CQ.PAR.RETURN.TXNS TO 7, CQ.PAR.RETURN.SUSP.CAT TO 8,
*        CQ.PAR.TELLER.ID TO 9, CQ.PAR.DAO.ID TO 10,
*        CQ.PAR.AUTO.CLEAR TO 11, CQ.PAR.RECORD.STATUS TO 12,
*        CQ.PAR.CURR.NO TO 13, CQ.PAR.INPUTTER TO 14,
*        CQ.PAR.DATE.TIME TO 15, CQ.PAR.AUTHORISER TO 16,
*        CQ.PAR.CO.CODE TO 17, CQ.PAR.DEPT.CODE TO 18,
*        CQ.PAR.AUDITOR.CODE TO 19, CQ.PAR.AUDIT.DATE.TIME TO 20

* GLOBUS_BG_100000691 - E

    FN.STO.PAR = "F.STOCK.PARAMETER"
    FV.STO.PAR = " "
    CALL OPF(FN.STO.PAR,FV.STO.PAR)

    FN.CQ.PAR = "F.CQ.PARAMETER"
    FV.CQ.PAR = " "
    CALL OPF(FN.CQ.PAR,FV.CQ.PAR)



    READ STO.PAR.REC FROM FV.STO.PAR, "SYSTEM" ELSE
        STO.PAR.REC = ""
    END
    READU CQ.PAR.REC FROM FV.CQ.PAR, "SYSTEM" ELSE
        CQ.PAR.REC = ""
    END

    CQ.PAR.REC<1> = STO.PAR.REC<5>
    CQ.PAR.REC<2> = STO.PAR.REC<6>
    CQ.PAR.REC<3> = STO.PAR.REC<7>
    CQ.PAR.REC<4> = STO.PAR.REC<8>
    CQ.PAR.REC<5> = STO.PAR.REC<9>
    CQ.PAR.REC<6> = STO.PAR.REC<10>
    CQ.PAR.REC<7> = STO.PAR.REC<11>
    CQ.PAR.REC<8> = STO.PAR.REC<12>
    CQ.PAR.REC<9> = STO.PAR.REC<13>
    CQ.PAR.REC<10> = STO.PAR.REC<14>

    WRITE CQ.PAR.REC TO FV.CQ.PAR, "SYSTEM"
    RETURN
END
