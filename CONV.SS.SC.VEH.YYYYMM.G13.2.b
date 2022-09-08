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

* Version 14 15/05/01  GLOBUS Release No. G13.2.00 12/02/03
*-----------------------------------------------------------------------------
* <Rating>286</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.ValuationHistorical
      SUBROUTINE CONV.SS.SC.VEH.YYYYMM.G13.2
*
* 04/01/03 - EN_10001550
*            Enhancement to add Dividend Accruals in Valuation,
*            Performance and Fees.
*            Conversion to update the Standard Selection of the
*            existing SC.VEH.YYYYMM files.
*
* 18/02/03 - BG_100003497
*            Bug Fix for Dividend Accrual Enhancement.
*
* 26/02/03 - BG_100003626
*            Inclusion of No.Fatal.Error to the CALL OPFs.
*
* 07/03/03 - CI_10007273
*            Checking for Consolidation mark while selecting
*            Multi companies.
*
* 08/12/08 - BG_100021204
*            Conversion should call journal updates
*************************************************************************
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
$INSERT I_F.DATES
$INSERT I_F.FILE.CONTROL
$INSERT I_F.AM.PARAMETER
$INSERT I_F.SC.VALUATION.EXTRACT.HIST ; * BG_100003626
*
      GOSUB INITIALISE
      GOSUB MAIN.PROC
      RETURN
*
***********
INITIALISE:
***********
*
* BG_100003626 - Start
      FN.COMPANY = 'F.COMPANY' ; F.COMPANY = ''
      CALL OPF(FN.COMPANY,F.COMPANY)
* BG_100003626 - End
*
      SEL.QUER = ''
      SEL.ARR = ''
      NO.OF.REC = ''
      SEL.ERR = '' ; READ.ERR = '' ; ER = ''
      SEL.POS = ''
      SC.VEH.ID = '' ; SVE.HIST = ''
      R.FILE.CTRL = '' ; HIST.FILES = ''
      FN.STD.SELN = 'F.STANDARD.SELECTION' ; F.STD.SELN = ''
      CALL OPF(FN.STD.SELN,F.STD.SELN)
*
      FN.STD.SELN.NAU = 'F.STANDARD.SELECTION$NAU'
      F.STD.SELN.NAU = ''                ; * BG_100003626
      CALL OPF(FN.STD.SELN.NAU,F.STD.SELN.NAU)
*
* BG_100003497 - Start
      F.AM.PARAMETER = ''
      FN.AM.PARAMETER = 'F.AM.PARAMETER'
* BG_100003626 - Start
      CALL OPF(FN.AM.PARAMETER:FM:'NO.FATAL.ERROR',F.AM.PARAMETER)
*
      FN.FILE.CTRL = 'F.FILE.CONTROL' ; FP.FILE.CTRL = ''
      CALL OPF(FN.FILE.CTRL, FP.FILE.CTRL)
* BG_100003626 - End
* BG_100003497 - End
*
      RETURN
*
**********
MAIN.PROC:
**********

      ORIG.COMPANY = ID.COMPANY
      SEL.CMD = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'     ; * CI_10007273
      COM.LIST = ''
      YSEL = 0
      CALL EB.READLIST(SEL.CMD,COM.LIST,'',YSEL,'')
      LOOP
         REMOVE K.COMPANY FROM COM.LIST SETTING END.OF.COMPANIES
      WHILE K.COMPANY:END.OF.COMPANIES
         COMPANY.REC = ''
         READ COMPANY.REC FROM F.COMPANY,K.COMPANY THEN
            MNEMONIC = COMPANY.REC<EB.COM.MNEMONIC>
*
            CALL LOAD.COMPANY(K.COMPANY)
            GOSUB GET.AM.PARAMETER       ; * BG_100003497
            IF HIST EQ 'YES' THEN        ; * BG_100003626
               GOSUB UPDATE.SS.SC.VEH.YYYYMM
            END                          ; * BG_100003626
         END
      REPEAT
      CALL JOURNAL.UPDATE('')
*
      IF ORIG.COMPANY NE ID.COMPANY THEN
         CALL LOAD.COMPANY(ORIG.COMPANY)
      END
      RETURN
*
* BG_100003497 - Start
*****************
GET.AM.PARAMETER:
*****************
      ER = ''
      R.AM.PARAMETER = ''
      CALL F.READ(FN.AM.PARAMETER,ID.COMPANY,R.AM.PARAMETER,F.AM.PARAMETER,ER)
      IF NOT(ER) THEN
         HIST = R.AM.PARAMETER<AM.PAR.HISTORIC>
         IF HIST = 'YES' THEN
            IF R.AM.PARAMETER<AM.PAR.HIST.PERIOD> = 'MONTHLY' THEN
               HIST.FILES = R.AM.PARAMETER<AM.PAR.HIST.DURATION>
            END ELSE
               HIST.FILES = R.AM.PARAMETER<AM.PAR.HIST.DURATION> * 12
            END
         END
      END
      RETURN
*
* BG_100003497 - End
*
************************
UPDATE.SS.SC.VEH.YYYYMM:
************************
*
      SVE.HIST = 'SC.VALUATION.EXTRACT.HIST'
      CALL F.READ(FN.STD.SELN,SVE.HIST,R.SVE.HIST,F.STD.SELN,READ.ERR)
* BG_100003497 - Start
      TODAY.YYYYMM = R.DATES(EB.DAT.TODAY)[1,6]
      YYYY = R.DATES(EB.DAT.TODAY)[1,4]
      MM = R.DATES(EB.DAT.TODAY)[5,2]
      SC.VEH.ID = 'SC.VEH.' : TODAY.YYYYMM
      GOSUB CONVERT.SS.AND.RECORDS       ; * BG_100003626
      FOR I = 1 TO HIST.FILES
         MM -= 1
         IF MM EQ 0 THEN YYYY -= 1 ; MM = 12
            ELSE IF MM LT 10 THEN MM = '0':MM
         YYYYMM = YYYY : MM
         SC.VEH.ID = 'SC.VEH.' : YYYYMM
         GOSUB CONVERT.SS.AND.RECORDS    ; * BG_100003626
      NEXT I
* BG_100003497 - End
      RETURN
*
* BG_100003626 - Start
***********************
CONVERT.SS.AND.RECORDS:
***********************
      CALL F.READ(FN.FILE.CTRL, SC.VEH.ID, R.FILE.CTRL, FP.FILE.CTRL, READ.ERR)
      IF NOT(READ.ERR) THEN
         CALL F.WRITE(FN.STD.SELN.NAU,SC.VEH.ID,R.SVE.HIST)
         FN.SC.VEH = 'F.':SC.VEH.ID ; FV.SC.VEH = ''
         CALL OPF(FN.SC.VEH:FM:'NO.FATAL.ERROR',FV.SC.VEH)
         IF NOT(ETEXT) THEN
            SEL.CMD1 = 'SELECT ':FN.SC.VEH
            SEL.LIST1 = ''
            CALL EB.READLIST(SEL.CMD1,SEL.LIST1,'',NO.OF.REC,'')
            LOOP
               REMOVE VEH.ID FROM SEL.LIST1 SETTING SEL.POS
            WHILE VEH.ID:SEL.POS
               READ VEH.REC FROM FV.SC.VEH,VEH.ID THEN
                  INS.POS = 84
                  INS '' BEFORE VEH.REC<INS.POS>
                  INS '' BEFORE VEH.REC<INS.POS>
                  VEH.REC<SC.VEH.BACKVALUE.DATE> = VEH.REC<INS.POS-1>
                  VEH.REC<INS.POS-1> = ''
               END
            REPEAT
         END
      END
      RETURN
* BG_100003626 - End
*
   END
