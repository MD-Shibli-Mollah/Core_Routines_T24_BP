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
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Reports
      SUBROUTINE CONV.ACCT.STMT(IN.ARR1, IN.ARR2, RET.IDS, RET.FILE)
*-----------------------------------------------------------------------------
* Program used in XML.EXTRACTOR record
*-------------------------------------------------------------------------------
*  Modifications
*  12-Feb-2003 : CI_10007446
*                Set start-date from Common Variable
*
*  08-Apr-2003 : CI_10008100
*                Sort by account.number
*
*  19-May-2003 : CI_10010076
*                a. Clear Workfile statement moved from am.port.acct.stmt
*                b. Change select statement
*
*  16-Jan-2004 : CI_10016350
*                Pass template id and ext.days
*
* 13/04/04 - GLOBUS_BG_100006451
*            Code review changes, inorder to remove the journal.update in
*            AM.PORT.ACCT.STMT add an additional subroutine parameter.
*            Standards changes, used F.DELETE not DELETE
*-------------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_AM.VAL.COMMON
*
      SAM.ID = AM$ID
      END.DATE = AM$STMT.DATE
      
*CI_10010076 -Start
      FN.WORKFILE = 'F.AM.AC.STMT.WORKFILE'
      F.WORKFILE = ''
      CALL OPF(FN.WORKFILE, F.WORKFILE)
      IF NOT(RUNNING.UNDER.BATCH) THEN
         SEL.COM = 'SELECT ' : FN.WORKFILE : ' WITH PORTFOLIO.ID EQ ' : SAM.ID
         CALL EB.READLIST(SEL.COM, RET.IDS, '', TOT.SEL, SEL.ERR)
         LOOP
         UNTIL RET.IDS<1> EQ ''
            CALL F.DELETE(FN.WORKFILE,RET.IDS<1>)   ; * BG_100006451
            DEL RET.IDS<1>
         REPEAT
      END
      SEL.COM = ''
      RET.IDS = ''
      TOT.SEL = ''
      SEL.ERR = ''
*CI_10010076 -End
*CI_10007446 - S
      IN.PAR = AM$STMT.DATE
      CALL CDT('',IN.PAR,'-90C')
      START.DATE = IN.PAR
      START.DATE = AM$BEGIN.DATE
*CI_10007446 - E
      
      RG.DATES = '2':FM:START.DATE:VM:END.DATE
      
*CI_10016350 -Start
      RG.DATES<4> = AM$ID
      RE.DATE = END.DATE[1,6]
      RG.DATES<5> = AM$TEMPLATE.ID
      IF NOT(RUNNING.UNDER.BATCH) THEN
         RG.DATES<6> = AM$EXT.STMT.DATE
      END
* CI_10016350  End
      
      CALL AM.PORT.ACCT.STMT(SAM.ID, RG.DATES, RET.IDS)   ; * BG_100006451
      RET.FILE = 'AM.AC.STMT.WORKFILE'

      RETURN
*-----------(Main)
      
   END
*-----(EndofRoutine:ConvAcctStmt)
