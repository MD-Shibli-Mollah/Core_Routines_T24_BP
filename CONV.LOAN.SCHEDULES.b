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
* <Rating>1255</Rating>
*-----------------------------------------------------------------------------
* Version n dd/mm/yy  GLOBUS Release No. G14.1.00 20/10/03
*
    $PACKAGE SL.Contract
    SUBROUTINE CONV.LOAN.SCHEDULES
*
**********************************************************
* Conversion details for sl.loan schedules and balances file.
*
***************************************************
* 25/08/03 - EN_10001958
*            Conversion routine is introduced.
* 11/10/03 - BG_100005395
*            F.WRITE is replaced with WRITE statement.
* 15/12/08 - BG_100021299
*            Conversion fails while running RUN.CONVERSION.PGMS
**********************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FACILITY
    $INSERT I_F.SL.LOANS
    $INSERT I_SL.COMMON
    $INSERT I_F.SL.LOAN.SCHEDULES
    $INSERT I_F.SL.FACILITY.LOANS
    $INSERT I_F.SL.LOAN.BALANCES
    $INSERT I_F.SL.LOAN.PART.BALANCES
    $INSERT I_F.SL.FACI.BALANCES
    $INSERT I_F.SL.FACI.PART.BALANCES
*
***********************************************************
*  Main Program.
*
    GOSUB INITIALISE
*
    GOSUB PROCESS.FACILITY
*
    RETURN
************************************************************
INITIALISE:
*
    F$FACILITY.FILE = "F.FACILITY"
    F$FACILITY.VAR = ""
    CALL OPF(F$FACILITY.FILE, F$FACILITY.VAR)
*
    F$SL.FAC.LOANS.FILE = 'F.SL.FACILITY.LOANS'
    F$SL.FAC.LOANS.VAR = ''
    CALL OPF(F$SL.FAC.LOANS.FILE,F$SL.FAC.LOANS.VAR)
*
    F$SL.FAC.BAL.FILE = 'F.SL.FACI.BALANCES'
    F$SL.FAC.BAL.VAR = ''
    CALL OPF(F$SL.FAC.BAL.FILE, F$SL.FAC.BAL.VAR)
*
    F$SL.PART.BAL.FILE = 'F.SL.FACI.PART.BALANCES'
    F$SL.PART.BAL.VAR = ''
    CALL OPF(F$SL.PART.BAL.FILE, F$SL.PART.BAL.VAR)
*
    F$SL.LOANS.FILE = 'F.SL.LOANS'
    F$SL.LOANS.VAR = ''
    CALL OPF(F$SL.LOANS.FILE, F$SL.LOANS.VAR)
*
    F$SL.LOAN.BAL.FILE = 'F.SL.LOAN.BALANCES'
    F$SL.LOAN.BAL.VAR = ''
    CALL OPF(F$SL.LOAN.BAL.FILE,F$SL.LOAN.BAL.VAR)
*
    F$SL.LOAN.PART.BAL.FILE = 'F.SL.LOAN.PART.BALANCES'
    F$SL.LOAN.PART.BAL.VAR = ''
    CALL OPF(F$SL.LOAN.PART.BAL.FILE,F$SL.LOAN.PART.BAL.VAR)
*
    FN.SL.LOAN.SCHED = 'F.SL.LOAN.SCHEDULES'
    FV.SL.LOAN.SCHED = ''
    CALL OPF(FN.SL.LOAN.SCHED,FV.SL.LOAN.SCHED)
*
    RETURN
***********************************************************
PROCESS.FACILITY:
*
    CSTATUS = 'LIQ'
    SEL.CMD = "SELECT ":F$FACILITY.FILE:" WITH CONTRACT.STATUS NE ":CSTATUS
*
    CALL EB.READLIST(SEL.CMD,ID.LIST,'','',SYS.ERROR)
*
    LOOP
        REMOVE C$FACILITY.ID FROM ID.LIST SETTING FOUND
    UNTIL C$FACILITY.ID EQ ""
* Update the facility balances.
        R$FACILITY = ''
        READ  R$FACILITY FROM F$FACILITY.VAR,C$FACILITY.ID SETTING R.FAC.ERR ELSE
            R$FACILITY = ''
        END
*
        R$SL.FAC.BAL = ''
        R.FAC.BAL.ERR = ''
        C$SL.FAC.BAL.IDS = ""
        READ R$SL.FAC.BAL FROM F$SL.FAC.BAL.VAR, C$FACILITY.ID SETTING R.FAC.BAL.ERR ELSE
             R$SL.FAC.BAL=''
        END
*
        LOCATE R$FACILITY<FAC.VALUE.DATE> IN R$SL.FAC.BAL<SFB.AMT.EFF.DATE,1> BY "DR" SETTING OUT.POS ELSE
            INS R$FACILITY<FAC.SL.AMOUNT> BEFORE R$SL.FAC.BAL<SFB.SL.OUTS.AMT,OUT.POS>
            INS 0 BEFORE R$SL.FAC.BAL<SFB.SL.AMT.MOVED,OUT.POS>
            INS R$FACILITY<FAC.VALUE.DATE> BEFORE R$SL.FAC.BAL<SFB.AMT.EFF.DATE,OUT.POS>
        END
        NO.OF.TRS = DCOUNT(R$SL.FAC.BAL<SFB.TRANCHE.CODE>,VM)
        FOR TR.NO = 1 TO NO.OF.TRS
            LOCATE R$SL.FAC.BAL<SFB.TRANCHE.CODE,TR.NO> IN R$FACILITY<FAC.TRANCHE.CODE,1> SETTING TR.FOUND THEN
                VALUE.DATE = R$FACILITY<FAC.TRANCHE.ST.DT,TR.FOUND>
                LOCATE VALUE.DATE IN R$SL.FAC.BAL<SFB.TR.AMT.MV.DT,TR.NO,1> BY "DR" SETTING OUT.POS ELSE
                    INS R$FACILITY<FAC.TRANCHE.AMT,TR.FOUND> BEFORE R$SL.FAC.BAL<SFB.TR.OUTS.AMT,TR.NO,OUT.POS>
                    INS 0 BEFORE R$SL.FAC.BAL<SFB.TR.AMT.MOVED,TR.NO,OUT.POS>
                    INS VALUE.DATE BEFORE R$SL.FAC.BAL<SFB.TR.AMT.MV.DT,TR.NO,OUT.POS>
                END
            END
        NEXT TR.NO
        WRITE R$SL.FAC.BAL TO F$SL.FAC.BAL.VAR,C$FACILITY.ID          ;* BG_100005359
*
        SL.FAC.BAL.REC = R$SL.FAC.BAL
        CALL EB.READLIST(SEL.CMD,C$SL.PART.BAL.IDS,'','',SYS.ERROR)
* Update the facility part balances.
        SEL.CMD = "SSELECT ":F$SL.PART.BAL.FILE:" WITH @ID LIKE ":C$FACILITY.ID:"..."
        CALL EB.READLIST(SEL.CMD,C$SL.PART.BAL.IDS,'','',SYS.ERROR)
        IF C$SL.PART.BAL.IDS THEN
            SL.PART.BAL.ID = ""
            LOOP
                REMOVE SL.PART.BAL.ID FROM C$SL.PART.BAL.IDS SETTING POS
            UNTIL SL.PART.BAL.ID EQ ''
                SL.PART.BAL.REC = ""
                READ SL.PART.BAL.REC FROM F$SL.PART.BAL.VAR,SL.PART.BAL.ID SETTING R.PART.BAL.ERR ELSE
                       SL.PART.BAL.REC=''
                END
*
                LOCATE R$FACILITY<FAC.VALUE.DATE> IN SL.PART.BAL.REC<SFP.PART.AMT.EFF.DT,1> BY "DR" SETTING OUT.POS ELSE
                    INS SUM(SL.PART.BAL.REC<SFP.PART.TOT.AMT>) BEFORE SL.PART.BAL.REC<SFP.PART.OUTS.AMT,OUT.POS>
                    INS 0 BEFORE SL.PART.BAL.REC<SFP.PART.AMT.MOVED,OUT.POS>
                    INS R$FACILITY<FAC.VALUE.DATE> BEFORE SL.PART.BAL.REC<SFP.PART.AMT.EFF.DT,OUT.POS>
                END
                NO.OF.TRS = DCOUNT(SL.PART.BAL.REC<SFP.TRANCHE.CODE>,VM)
                FOR TR.NO = 1 TO NO.OF.TRS
                    LOCATE SL.PART.BAL.REC<SFB.TRANCHE.CODE,TR.NO> IN R$FACILITY<FAC.TRANCHE.CODE,1> SETTING TR.FOUND THEN
                        VALUE.DATE = R$FACILITY<FAC.TRANCHE.ST.DT,TR.FOUND>
                        LOCATE VALUE.DATE IN SL.PART.BAL.REC<SFP.AMT.EFF.DATE,TR.NO,1> BY "DR" SETTING OUT.POS ELSE
                            INS SL.PART.BAL.REC<SFP.TR.PART.AMT,TR.NO> BEFORE SL.PART.BAL.REC<SFP.TR.OUTS.AMT,TR.NO,OUT.POS>
                            INS 0 BEFORE SL.PART.BAL.REC<SFP.AMT.MOVED,TR.NO,OUT.POS>
                            INS VALUE.DATE BEFORE SL.PART.BAL.REC<SFP.AMT.EFF.DATE,TR.NO,OUT.POS>
                        END
                    END
                NEXT TR.NO
                WRITE SL.PART.BAL.REC TO F$SL.PART.BAL.VAR,SL.PART.BAL.ID       ;* BG_100005359
*
            REPEAT
        END
        R$SL.FAC.LOANS = ""
        READ R$SL.FAC.LOANS FROM  F$SL.FAC.LOANS.VAR, C$FACILITY.ID SETTING SYS.ERR ELSE
               R$SL.FAC.LOANS =''
        END
*
        GOSUB PROCESS.LOAN.BAL.AND.SCHEDULES
*
    REPEAT
*
    RETURN
*********************************************************
PROCESS.LOAN.BAL.AND.SCHEDULES:
*
    NO.OF.LOANS = DCOUNT(R$SL.FAC.LOANS<SLFL.LOAN.ID>,VM)
    FOR LOAN.I = 1 TO NO.OF.LOANS
        C$SL.LOAN.IDS = R$SL.FAC.LOANS<SLFL.LOAN.ID,LOAN.I>
        R$SL.LOANS = ""
        READ R$SL.LOANS FROM F$SL.LOANS.VAR,C$SL.LOAN.IDS SETTING R.SL.LOANS.ERR ELSE
              R$SL.LOANS=''
        END
*
        R.LOAN.BAL.ERR = ''
        R$SL.LOAN.BAL = ''
        READ R$SL.LOAN.BAL FROM F$SL.LOAN.BAL.VAR,C$SL.LOAN.IDS SETTING R.LOAN.BAL.ERR ELSE
            R$SL.LOAN.BAL=''
        END
*
        LOCATE R$SL.LOANS<SL.LN.VALUE.DATE> IN R$SL.LOAN.BAL<SLB.AMT.EFF.DATE,1> BY "DR" SETTING OUT.POS ELSE
            INS R$SL.LOAN.BAL<SLB.SL.LOAN.INIT.AMT> BEFORE R$SL.LOAN.BAL<SLB.OUTS.CURR.AMT,OUT.POS>
            INS 0 BEFORE R$SL.LOAN.BAL<SLB.AMT.MOVED,OUT.POS>
            INS R$SL.LOANS<SL.LN.VALUE.DATE> BEFORE R$SL.LOAN.BAL<SLB.AMT.EFF.DATE,OUT.POS>
        END
        WRITE R$SL.LOAN.BAL TO F$SL.LOAN.BAL.VAR,C$SL.LOAN.IDS        ;* BG_100005359
*

        SEL.CMD = "SSELECT ":F$SL.LOAN.PART.BAL.FILE:" WITH @ID LIKE ":C$SL.LOAN.IDS:"..."
*
        CALL EB.READLIST(SEL.CMD,C$SL.LOAN.PART.BAL.IDS,'','',SYS.ERROR)
*
        IF C$SL.LOAN.PART.BAL.IDS THEN
            SL.LOAN.PART.BAL.ID = ""
            LOOP
                REMOVE SL.LOAN.PART.BAL.ID FROM C$SL.LOAN.PART.BAL.IDS SETTING POS
            UNTIL SL.LOAN.PART.BAL.ID EQ ''
                SL.LOAN.PART.BAL.REC = ""
                READ SL.LOAN.PART.BAL.REC FROM F$SL.LOAN.PART.BAL.VAR, SL.LOAN.PART.BAL.ID SETTING R.PART.BAL.ERR ELSE
                         SL.LOAN.PART.BAL.REC=''
                END
                LOCATE R$SL.LOANS<SL.LN.VALUE.DATE> IN SL.LOAN.PART.BAL.REC<SLP.PR.AMT.EFF.DATE,1> BY "DR" SETTING OUT.POS ELSE
                    INS SL.LOAN.PART.BAL.REC<SLP.PART.INIT.LO.AMT> BEFORE SL.LOAN.PART.BAL.REC<SLP.PR.OUTS.AMT,OUT.POS>
                    INS 0 BEFORE SL.LOAN.PART.BAL.REC<SLP.PR.AMT.MOVED,OUT.POS>
                    INS R$SL.LOANS<SL.LN.VALUE.DATE> BEFORE SL.LOAN.PART.BAL.REC<SLP.PR.AMT.EFF.DATE,OUT.POS>
                END
                WRITE SL.LOAN.PART.BAL.REC TO F$SL.LOAN.PART.BAL.VAR,SL.LOAN.PART.BAL.ID  ;* BG_100005359
            REPEAT
        END
*
        SEL.CMD = 'SELECT ' : FN.SL.LOAN.SCHED : ' WITH @ID LIKE ' : C$SL.LOAN.IDS : '...'
        CALL EB.READLIST(SEL.CMD,SCHED.ID.LIST,'',NO.OF.SCHED,SCHED.RET.CODE)
        FOR SCH.I = 1 TO NO.OF.SCHED
            SCHED.ID = SCHED.ID.LIST<SCH.I>
            READ  SCHED.REC FROM FV.SL.LOAN.SCHED,SCHED.ID SETTING SCHED.RET.CODE ELSE
                    SCHED.REC=''
            END
*
            LOCATE 'PR' IN SCHED.REC<SLLS.SCH.TYPE,1> SETTING SCH.POS THEN
                PR.AMOUNT = SCHED.REC<SLLS.SCH.AMOUNT,SCH.POS>
                NO.PART = DCOUNT(R$SL.LOANS<SL.LN.PARTICIPANT>,VM)
                FOR PART.I = 1 TO NO.PART
                    SCHED.REC<SLLS.PART.ID,SCH.POS,PART.I> = R$SL.LOANS<SL.LN.PARTICIPANT,PART.I>
                    PART.SHARE = R$SL.LOANS<SL.LN.PART.AMT.B.CCY,PART.I> / R$SL.LOANS<SL.LN.BASE.CCY.AMT>
                    PART.SHARE = PART.SHARE * 100
                    PART.AMT = PR.AMOUNT * PART.SHARE /100
                    SCHED.REC<SLLS.PART.AMT,SCH.POS,PART.I> = PART.AMT
                    IF R$SL.LOANS<SL.LN.DEAL.CURRENCY> NE R$FACILITY<FAC.SL.CURRENCY> THEN
                        BUY.CCY = R$SL.LOANS<SL.LN.DEAL.CURRENCY>     ;* CI_10014064
                        BUY.AMT = PART.AMT
                        SELL.CCY = R$FACILITY<FAC.SL.CURRENCY>
                        CUST.RATE = R$SL.LOANS<SL.LN.BASE.CCY.CONV>
                        SELL.AMT = ''
* BG_100005359
                        TR.RATE = ''
                        SPREAD.PCT = ''
                        CUST.SPREAD = ''
                        BASE.CCY = ''
                        LOCAL.CCY.BUY = ''
                        LOCAL.CCY.SELL = ''
                        RET.CODE = ''
* BG_100005359
                        CALL CUSTRATE('1', BUY.CCY, BUY.AMT, SELL.CCY, SELL.AMT, BASE.CCY, TR.RATE,CUST.RATE, CUST.SPREAD, SPREAD.PCT, LOCAL.CCY.BUY, LOCAL.CCY.SELL,RET.CODE)
                        SCHED.REC<SLLS.PART.FAC.AMT,SCH.POS,PART.I> = SELL.AMT
                    END ELSE
                        SCHED.REC<SLLS.PART.FAC.AMT,SCH.POS,PART.I> = PART.AMT
                    END
                NEXT PART.I
            END
*
            LOCATE 'FWD.DD' IN SCHED.REC<SLLS.SCH.TYPE,1> SETTING SCH.POS THEN
                SCHED.REC<SLLS.SCH.AMOUNT,SCH.POS> = R$SL.LOANS<SL.LN.AMOUNT>
                NO.PART = DCOUNT(R$SL.LOANS<SL.LN.PARTICIPANT>,VM)
                FOR PART.I = 1 TO NO.PART
                    SCHED.REC<SLLS.PART.ID,SCH.POS,PART.I> = R$SL.LOANS<SL.LN.PARTICIPANT,PART.I>
                    SCHED.REC<SLLS.PART.AMT,SCH.POS,PART.I> = R$SL.LOANS<SL.LN.PART.AMT,PART.I>
                    SCHED.REC<SLLS.PART.FAC.AMT,SCH.POS,PART.I> = R$SL.LOANS<SL.LN.PART.AMT.B.CCY,PART.I>
                NEXT PART.I
            END
*
            WRITE SCHED.REC TO FV.SL.LOAN.SCHED,SCHED.ID
        NEXT SCH.I
*
    NEXT LOAN.I
    RETURN
**************************************************************
END
