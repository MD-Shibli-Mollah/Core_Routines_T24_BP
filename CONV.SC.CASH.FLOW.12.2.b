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

* Version 5 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>1384</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScvCashAndFundFlow
      SUBROUTINE CONV.SC.CASH.FLOW.12.2
*
*     Last updated by ANDREAS (DEV) at 13:45:41 on 02/08/93
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING CASH FLOW RECORDS AND
* CREATE ASSOCIATED CONCAT FILE RECORDS BY SECURITIES ACCOUNT
*
* AK - 02/08/93.
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT(). 
*
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
**************************
      F.COMP = ''
      CALL OPF("F.COMPANY",F.COMP)
      COMP.MNEMS = ''
      SELECT F.COMP
      LOOP
         READNEXT K.COMP ELSE NULL
      WHILE K.COMP DO
         READ R.COMP FROM F.COMP,K.COMP ELSE R.COMP = ''
         LOCATE 'SC' IN R.COMP<EB.COM.APPLICATIONS,1> SETTING POS ELSE POS = 0
         IF R.COMP<EB.COM.CONSOLIDATION.MARK> = 'N' AND POS THEN COMP.MNEMS<-1> = R.COMP<EB.COM.MNEMONIC>
      REPEAT
      NO.COMPS = DCOUNT(COMP.MNEMS,FM)
*
      F.PGM = ''
      CALL OPF("F.PGM.FILE",F.PGM)
      PRINT @(10,10):'CONVERTING SC.CASH.FLOW RECORDS ......PLEASE WAIT'
      FOR MTH = 1 TO 12
*
         YFILE.VAR = ''
         YFNAME = 'F.SC.CASH.FLOW':FMT(MTH,'2"0"R')
         CALL OPF(YFNAME,YFILE.VAR)
         IF MTH NE TODAY[5,2] THEN
            GOSUB UPDATE.RECORDS         ; * LIVE RECORDS
         END ELSE
            CALL HUSHIT(1)
            EXECUTE "CLEAR.FILE ":YFNAME
            CALL HUSHIT(0)
         END
      NEXT MTH
      DELETE F.PGM,"CONV.SC.CASH.FLOW.12.2"
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT YFILE.VAR
      LOOP
         READNEXT K.CSH.FL ELSE NULL
      WHILE K.CSH.FL DO
         K.SEC.ACC = FIELD(K.CSH.FL,".",1)
         FOR XX = 1 TO NO.COMPS
            MNEM = COMP.MNEMS<XX>
            OPEN '','F':MNEM:'.SEC.ACC.MASTER' TO F.SEC.ACC ELSE STOP 'CANNOT OPEN SEC.ACC.MASTER'
            R.SAM = '' ; SAM.FOUND = 1
            READ R.SAM FROM F.SEC.ACC,K.SEC.ACC ELSE SAM.FOUND = 0
            IF SAM.FOUND THEN
               YCONCAT = 'F':MNEM:'.SCAC.VAL.SUM':FMT(MTH,'2"0"R')
               OPEN '',YCONCAT TO CFILE.VAR ELSE STOP 'CANNOT OPEN FILE SCAC.VAL.SUM'
               YCONCAT2 = 'F':MNEM:'.SC.VAL.SUM':FMT(MTH,'2"0"R')
               CALL HUSHIT(1)
               EXECUTE "CLEAR.FILE ":YCONCAT2
               CALL HUSHIT(0)
               XX = NO.COMPS
            END
         NEXT XX
         IF SAM.FOUND THEN
            READU R.CSH FROM YFILE.VAR,K.CSH.FL ELSE
               E = 'CASH FLOW "':K.CSH.FL:'" MISSING FROM THE FILE'
               GOTO FATAL.ERR
            END
            NO.FLDS = COUNT(R.CSH,FM)+1
            IF NO.FLDS < 44 THEN
               NEW.CSH.REC = ''
               NEW.CSH.REC<1> = R.CSH<1>
               NEW.CSH.REC<2> = R.CSH<4>
               NEW.CSH.REC<3> = R.CSH<3>
               NEW.CSH.REC<4> = R.CSH<2>
               NEW.CSH.REC<5> = R.CSH<14>
               NEW.CSH.REC<6> = R.CSH<15>
               NEW.CSH.REC<7> = R.CSH<16>
               NEW.CSH.REC<8> = R.CSH<20>
               NEW.CSH.REC<9> = R.CSH<18>
               NEW.CSH.REC<10> = R.CSH<21>
               NEW.CSH.REC<11> = R.CSH<17>
               NEW.CSH.REC<12> = R.CSH<22>
               NEW.CSH.REC<13> = R.CSH<23>
               NEW.CSH.REC<14> = R.CSH<24>
               NEW.CSH.REC<15> = R.CSH<25>
               NEW.CSH.REC<16> = R.CSH<26>
               NEW.CSH.REC<17> = R.CSH<27>
               NEW.CSH.REC<18> = R.CSH<28>
               NEW.CSH.REC<19> = R.CSH<29>
               NEW.CSH.REC<20> = R.CSH<30>
               NEW.CSH.REC<21> = R.CSH<31>
               NEW.CSH.REC<25> = R.CSH<32>
               NEW.CSH.REC<26> = R.CSH<33>
               NEW.CSH.REC<27> = R.CSH<34>
               NEW.CSH.REC<28> = R.CSH<35>
               NEW.CSH.REC<29> = R.CSH<36>
               NEW.CSH.REC<30> = R.CSH<38>
               NEW.CSH.REC<31> = R.CSH<39>
               NEW.CSH.REC<34> = R.CSH<5>
               NEW.CSH.REC<35> = R.CSH<6>
               NEW.CSH.REC<36> = R.CSH<7>
               NEW.CSH.REC<37> = R.CSH<8>
               NEW.CSH.REC<38> = R.CSH<9>
               NEW.CSH.REC<39> = R.CSH<10>
               NEW.CSH.REC<40> = R.CSH<11>
               NEW.CSH.REC<41> = R.CSH<12>
               NEW.CSH.REC<42> = R.CSH<13>
               NEW.CSH.REC<43> = R.CSH<19>
               NEW.CSH.REC<44> = R.CSH<37>
               R.CSH = NEW.CSH.REC
            END
            READU R.CONCAT FROM CFILE.VAR,K.SEC.ACC ELSE R.CONCAT = ''
            LOCATE K.CSH.FL IN R.CONCAT<1> BY "AL" SETTING POS ELSE
               INS K.CSH.FL BEFORE R.CONCAT<POS>
            END
            WRITE R.CONCAT TO CFILE.VAR,K.SEC.ACC
            WRITE R.CSH TO YFILE.VAR,K.CSH.FL
         END
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SC.CASH.FLOW.12.2')
********
* END
********
   END
