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
* <Rating>-12</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Performance
    SUBROUTINE CONV.HIST.PERF(IN.ARR1,IN.ARR2,RET.IDS,RET.FILE)
*--------------------------------------------------------------------------------
*  Modifications
*  12-Feb-03 : CI_10006380
*              Check if benchmark index is required or not
*
*  08-Apr-03 : CI_10008100
*              Get historical peformance to <n> years
*              <n> is taken from am.sub.report
*              Sort by @ID (i.e., year)
*
*  18-Jun-03 : CI_10010076
*              a. Pass End.Date to calculate perf till stmt.date and not today
*              b. Select record for Portfolo.id
*              c. Delete previous records
*
*  16-Jan-04 : CI_10016350
*              Display performance for <n> years, value set in am.sub.report
*
* 20-JAN-2004 - EN_10002106
*               New arguement passed while calling CALC.DAILY.DEITZ.PERF.
*               The GROSS.NET option has been replaced with PERF.TYPE.
* 27/04/04    - EN_10002250
*               Annualised Deitz Performance
*               Change AM.GET.ENQ.PARAMS parameter array.
*
* 15/02/05    - CI_10027369
*             - Wrong data in performance extraction.
*
* 28/03/05    - CI_10028664
*             - Wrong data in performance extraction - Refix
*
* 28/03/07    - CI_10048083
*               Uninitialised variable found
*-------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AM.VAL.COMMON
    $INSERT I_F.SEC.ACC.MASTER          ;*CI_10008100
*

    SAM.NO = AM$ID
*CI_10006380
*CI_10008100 -s
*-      BENCH.INDX = AM$REP.PARAMS<4>
*-      CALL CALC.PERF.1YEAR.XML(SAM.NO,BENCH.INDX,,,'','','','')
    BENCH.INDX = ''
    CALC.METHOD = ''
    BENCH.ID = ''
    DECIMAL = ''
    GROSS.NET = ''
    START.DATE = ''
    END.DATE = ''
    PERF.YEARS = ''
    DISPLAY.PERF = ''         ;*CI_10016350

* check if Benchmark performance is required
    FIND 'BENCHMARK' IN AM$REP.PARAMS<2> SETTING AFM, AVM, ASM THEN
        BENCH.INDX = AM$REP.PARAMS<4,AVM>
    END

*  Calc.Method
    FIND 'CALC.METHOD' IN AM$REP.PARAMS<2> SETTING AFM, AVM, ASM THEN
        CALC.METHOD = AM$REP.PARAMS<4,AVM>
    END

*  Benchmark ID
    FIND 'BENCH.ID' IN AM$REP.PARAMS<2> SETTING AFM, AVM, ASM THEN
        BENCH.ID = AM$REP.PARAMS<4,AVM>
    END

*  Decimal
    FIND 'DECIMAL' IN AM$REP.PARAMS<2> SETTING AFM, AVM, ASM THEN
        DECIMAL = AM$REP.PARAMS<4,AVM>
    END
* EN_10002106 - S
*  Gross.or.Net
    PERF.TYPE = 'NET' ; * CI_10048083 - S/E
    FIND 'PERF.TYPE' IN AM$REP.PARAMS<2> SETTING AFM, AVM, ASM THEN
        PERF.TYPE = AM$REP.PARAMS<4,AVM>
    END
* EN_10002106 - E


*  Performance <n> years
    FIND 'PERF.YEARS' IN AM$REP.PARAMS<2> SETTING AFM, AVM, ASM THEN
        PERF.YEARS = AM$REP.PARAMS<4,AVM>
    END

    END.DATE = AM$STMT.DATE   ;* CI_10010076 s/e

*CI_10008100 -e
*  Display perf for <n> years                          ;*CI_10016350 Begins
    FIND 'DISPLAY.PERF' IN AM$REP.PARAMS<2> SETTING AFM, AVM, ASM THEN
        DISPLAY.PERF = AM$REP.PARAMS<4,AVM>
    END   ;*CI_10016350 Ends

    FN.AM.WORKFILE = 'F.AM.PERF.WORKFILE'
    F.AM.WORKFILE = ''
    CALL OPF(FN.AM.WORKFILE, F.AM.WORKFILE)

*CI_10010076 -Start
    SEL.COM = 'SELECT ' : FN.AM.WORKFILE : ' WITH @ID LIKE 0X.0N-0N.':TNO ;*CI_10028664 S/E
    CALL EB.READLIST(SEL.COM, RET.IDS, '', TOT.SEL, SEL.ERR)
    LOOP
    UNTIL RET.IDS<1> EQ ''
*        DELETE FV.AM.WORKFILE, RET.IDS<1>
        CALL F.DELETE(FN.AM.WORKFILE,RET.IDS<1>)
        DEL RET.IDS<1>
    REPEAT
    SEL.COM = ''
    RET.IDS = ''
    TOT.SEL = ''
    SEL.ERR = ''
    CALL CALC.PERF.1YEAR.XML(SAM.NO,BENCH.INDX,START.DATE,END.DATE,CALC.METHOD,DECIMAL,BENCH.ID,PERF.TYPE,PERF.YEARS,DISPLAY.PERF) ;*CI_10016350 * EN_10002106


*CI_10010076 -End
    RET.IDS = ''
    NO.SEL = ''
    SEL.COMM = 'SELECT ' : FN.AM.WORKFILE : ' WITH @ID LIKE 0X.0N-0N.':TNO ;*CI_10028664 S/E
    CALL EB.READLIST(SEL.COMM, RET.IDS, '', NO.SEL, ERR1)
    RET.FILE = 'AM.PERF.WORKFILE'
    RETURN

END
*-----(Endofroutine:ConvHistPerf)
