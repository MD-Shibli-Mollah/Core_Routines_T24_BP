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
* <Rating>235</Rating>
*-----------------------------------------------------------------------------
* Version n dd/mm/yy  GLOBUS Release No. 200511 21/10/05
*********************************************************************
    $PACKAGE EU.ApplicationEuroConversion
    SUBROUTINE CONV.SC.PERF.DETAIL(SAM.ID,OLD.CCY,NEW.CCY)
*********************************************************************
* This routine is called from EOD.SC.CONV.REF.CCY used to convert
* the data file SC.PERF.DETAIL. When ever the reference currency of a
* Portfolio is changed from any of the euro in currencies to EUR, this
* program will convert all previous data to EUR.
***********************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SC.PERF.DETAIL
    $INSERT I_F.SPF
    GOSUB INITIALISE
    IF R.SC.PERF.DETAIL.CONCAT THEN
        GOSUB PROCESS.SC.PERF.DETAIL
    END
    RETURN
*************
INITIALISE:
*************
    FN.SC.PERF.DETAIL = 'F.SC.PERF.DETAIL'
    FV.SC.PERF.DETAIL = ''
    CALL OPF(FN.SC.PERF.DETAIL,FV.SC.PERF.DETAIL)
    FN.SC.PERF.DETAIL.CONCAT = 'F.SC.PERF.DETAIL.CONCAT'
    FV.SC.PERF.DETAIL.CONCAT = ''
    CALL OPF(FN.SC.PERF.DETAIL.CONCAT,FV.SC.PERF.DETAIL.CONCAT)
    R.SC.PERF.DETAIL.CONCAT = ''
    ERR.CONCAT = ''
    CALL F.READ(FN.SC.PERF.DETAIL.CONCAT,
    SAM.ID,
    R.SC.PERF.DETAIL.CONCAT,
    FV.SC.PERF.DETAIL.CONCAT,
    ERR.CONCAT)
    SC.PERF.DETAIL.ID = ''
    NO.PERF.DATE = ''
    CAC.SIZE = ''
    CALL DBR("SPF":FM:SPF.CACHE.SIZE,'SYSTEM',CAC.SIZE)
    CAC.SIZE = CAC.SIZE - 10
    REC.NO = 0
    RETURN
****************************
PROCESS.SC.PERF.DETAIL:
****************************
    FOR COUNTER1 = 1 TO COUNT(R.SC.PERF.DETAIL.CONCAT,FM)+1
        SC.PERF.DETAIL.ID = R.SC.PERF.DETAIL.CONCAT<COUNTER1>
        R.SC.PERF.DETAIL = ''
        ERR.TRANS = ''
        CALL F.READ(FN.SC.PERF.DETAIL,
        SC.PERF.DETAIL.ID,
        R.SC.PERF.DETAIL,
        FV.SC.PERF.DETAIL,
        ERR.TRANS)
        IF R.SC.PERF.DETAIL THEN
            OLD.AMT = R.SC.PERF.DETAIL<SC.PERF.BEGIN.VALUE>
            NEW.AMT = ''
            EX.RATE = ''
            GOSUB INV.EXCHRATE
            R.SC.PERF.DETAIL<SC.PERF.BEGIN.VALUE> = NEW.AMT
            NO.PERF.DATE = COUNT(R.SC.PERF.DETAIL<SC.PERF.PERF.DATE>,VM)+1
            FOR COUNTER2 = 1 TO NO.PERF.DATE
                OLD.AMT = R.SC.PERF.DETAIL<SC.PERF.IN.FLOW,COUNTER2>
                NEW.AMT = ''
                EX.RATE = ''
                GOSUB INV.EXCHRATE
                R.SC.PERF.DETAIL<SC.PERF.IN.FLOW,COUNTER2> = NEW.AMT
                OLD.AMT = R.SC.PERF.DETAIL<SC.PERF.OUT.FLOW,COUNTER2>
                NEW.AMT = ''
                EX.RATE = ''
                GOSUB INV.EXCHRATE
                R.SC.PERF.DETAIL<SC.PERF.OUT.FLOW,COUNTER2> = NEW.AMT
                OLD.AMT = R.SC.PERF.DETAIL<SC.PERF.VALUE.END.DAY,COUNTER2>
                NEW.AMT = ''
                EX.RATE = ''
                GOSUB INV.EXCHRATE
                R.SC.PERF.DETAIL<SC.PERF.VALUE.END.DAY,COUNTER2> = NEW.AMT
                OLD.AMT = R.SC.PERF.DETAIL<SC.PERF.SFKFEE.OUTFLOW,COUNTER2>
                NEW.AMT = ''
                EX.RATE = ''
                GOSUB INV.EXCHRATE
                R.SC.PERF.DETAIL<SC.PERF.SFKFEE.OUTFLOW,COUNTER2> = NEW.AMT
                OLD.AMT = R.SC.PERF.DETAIL<SC.PERF.MGTFEE.OUTFLOW,COUNTER2>
                NEW.AMT = ''
                EX.RATE = ''
                GOSUB INV.EXCHRATE
                R.SC.PERF.DETAIL<SC.PERF.MGTFEE.OUTFLOW,COUNTER2> = NEW.AMT
                OLD.AMT = R.SC.PERF.DETAIL<SC.PERF.DIV.ACC.AMT,COUNTER2>
                NEW.AMT = ''
                EX.RATE = ''
                GOSUB INV.EXCHRATE
                R.SC.PERF.DETAIL<SC.PERF.DIV.ACC.AMT,COUNTER2> = NEW.AMT
                OLD.AMT = R.SC.PERF.DETAIL<SC.PERF.REC.TAX.AMT,COUNTER2>
                NEW.AMT = ''
                EX.RATE = ''
                GOSUB INV.EXCHRATE
                R.SC.PERF.DETAIL<SC.PERF.REC.TAX.AMT,COUNTER2> = NEW.AMT
            NEXT COUNTER2
            GOSUB WRITE.SC.PERF.DETAIL
        END
    NEXT COUNTER1
    CALL JOURNAL.UPDATE("SC.PERF.DETAIL")
    RETURN
*******************
INV.EXCHRATE:
*******************
    ERR.CODE = ''
    CALL EXCHRATE("1",
    OLD.CCY,
    OLD.AMT,
    NEW.CCY,
    NEW.AMT,
    "",
    EX.RATE,
    "",
    "",
    ERR.CODE)
    IF NEW.AMT = '' THEN
        NEW.AMT = '0'
    END
    IF OLD.AMT = '' THEN
        OLD.AMT = '0'
    END
    RETURN
*****************************
WRITE.SC.PERF.DETAIL:
*****************************
    CALL F.WRITE(FN.SC.PERF.DETAIL,
    SC.PERF.DETAIL.ID,
    R.SC.PERF.DETAIL)
    REC.NO += 1
    IF REC.NO > CAC.SIZE THEN
        CALL JOURNAL.UPDATE("SC.PERF.DETAIL")
        REC.NO = 0
    END
    RETURN
END
