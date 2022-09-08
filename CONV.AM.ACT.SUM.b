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

*
*-----------------------------------------------------------------------------
* <Rating>94</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Reports
      SUBROUTINE CONV.AM.ACT.SUM(IN.ARR1,IN.ARR2,RET.IDS,RET.FILE)
*-------------------------------------------------------------------------------------------
*  Modification
*  18 Jun 2003 : CI_10010076
*                A. Select record for Portfolio.ID (new field)
*                B. Delete records for the given portfolio.id
*
*  16 Jan 2004 : CI_10016350
*                If listing is based on TRADE.DATE, pass parameter from am.sub.report
*
* 03/03/04 - GLOBUS_BG_100006284
*            Code review changes, remove SELECT statement, Id's now passed back by called routine
*            PROCESS.ACT.SUM. Standards changes.
*-------------------------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_AM.VAL.COMMON
*
      SAM.NO = AM$ID
      
      FN.AM.ACT.WORKFILE = 'F.AM.ACT.WORKFILE'   ; * BG_100006284 s
      F.AM.ACT.WORKFILE = ''
      CALL OPF(FN.AM.ACT.WORKFILE, F.AM.ACT.WORKFILE)   ; * BG_100006284 e
      
*CI_10010076 -Start
      IF NOT(RUNNING.UNDER.BATCH) THEN
         SEL.COM = 'SELECT ' : FN.AM.ACT.WORKFILE : ' WITH PORTFOLIO.ID EQ ' : SAM.NO   ; * BG_100006284
         CALL EB.READLIST(SEL.COM, RET.IDS, '', TOT.SEL, SEL.ERR)
         LOOP
         UNTIL RET.IDS<1> EQ ''
            CALL F.DELETE(FN.AM.ACT.WORKFILE,RET.IDS<1>)   ; * BG_100006284
            DEL RET.IDS<1>
         REPEAT
      END

      RET.IDS = ''
*CI_10010076 -End
*CI_10016350  s
*  If list is based on TRADE.DATE, to capture backdated transactions
*  and suppress entries reported in previous reportin.period, pass
*  YES in AM.Sub.Report
*  Pass is to SAM.NO<2>
      TR.DATE.LIST = ''
      FIND 'TRADE.DATE.ENTRY' IN AM$REP.PARAMS<2> SETTING AFM, AVM, ASM THEN
         TR.DATE.LIST = AM$REP.PARAMS<4,AVM>
         IF TR.DATE.LIST <> 'YES' THEN TR.DATE.LIST = ''
      END
      SAM.NO<2>= TR.DATE.LIST
*CI_10016350 e
      
      CALL PROCESS.ACT.SUM(SAM.NO,RET.IDS)   ; * BG_100006284

      RET.FILE = 'AM.ACT.WORKFILE'
      
      RETURN
      
   END
*-----(EndOfRoutine:ConvAmActSum)
