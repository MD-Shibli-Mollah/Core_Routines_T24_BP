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

* Version 1 30/05/03  GLOBUS Release No. G14.0.00 30/05/03
*-----------------------------------------------------------------------------
* <Rating>349</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Group
      SUBROUTINE CONV.AM.VEH.GRP.YYYYMM.G14
*
* 20/05/03 - EN_10001853
*            Enhancement to add Recoverable Tax in Valuation,
*            Performance and Fees.
*            Conversion to update the Standard Selection of the
*            existing AM.VEH.GRP.YYYYMM files.
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
*
      GOSUB INITIALISE
      GOSUB MAIN.PROC
      RETURN
*
***********
INITIALISE:
***********
*
      FN.COMPANY = 'F.COMPANY' ; F.COMPANY = ''
      CALL OPF(FN.COMPANY,F.COMPANY)

      R.FILE.CTRL = ''
      R.AVE.GRP.CONS = ''
*
      AM.VEH.GRP.ID = '' ; AVE.GRP.CONS = ''
      FN.STD.SELN = 'F.STANDARD.SELECTION' ; F.STD.SELN = ''
      CALL OPF(FN.STD.SELN,F.STD.SELN)
*
      FN.STD.SELN.NAU = 'F.STANDARD.SELECTION$NAU'
      F.STD.SELN.NAU = ''
      CALL OPF(FN.STD.SELN.NAU,F.STD.SELN.NAU)
*
      F.AM.PARAMETER = ''
      FN.AM.PARAMETER = 'F.AM.PARAMETER'
      CALL OPF(FN.AM.PARAMETER:FM:'NO.FATAL.ERROR',F.AM.PARAMETER)
*
      FN.FILE.CTRL = 'F.FILE.CONTROL' ; FP.FILE.CTRL = ''
      CALL OPF(FN.FILE.CTRL, FP.FILE.CTRL)
      DIM R.STD.SEL(500)
*
      RETURN
*
**********
MAIN.PROC:
**********
      ORIG.COMPANY = ID.COMPANY
      SEL.CMD = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
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
            GOSUB GET.AM.PARAMETER
            IF HIST EQ 'YES' THEN
               GOSUB UPDATE.AM.VEH.GRP.YYYYMM
            END
         END
      REPEAT
      CALL JOURNAL.UPDATE('')
*
      IF ORIG.COMPANY NE ID.COMPANY THEN
         CALL LOAD.COMPANY(ORIG.COMPANY)
      END
      RETURN
*
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
*************************
UPDATE.AM.VEH.GRP.YYYYMM:
*************************
*
      AVE.GRP.CONS = 'AM.VALUATION.EXT.GRP.CONS'
      CALL F.READ(FN.STD.SELN,AVE.GRP.CONS,R.AVE.GRP.CONS,F.STD.SELN,READ.ERR)
      TODAY.YYYYMM = R.DATES(EB.DAT.TODAY)[1,6]
      YYYY = R.DATES(EB.DAT.TODAY)[1,4]
      MM = R.DATES(EB.DAT.TODAY)[5,2]
      AM.VEH.GRP.ID = 'AM.VEH.GRP.':TODAY.YYYYMM
      CALL F.READ(FN.FILE.CTRL, AM.VEH.GRP.ID, R.FILE.CTRL, FP.FILE.CTRL, READ.ERR)
      IF NOT(READ.ERR) THEN
         CALL F.WRITE(FN.STD.SELN.NAU,AM.VEH.GRP.ID,R.AVE.GRP.CONS)
         GOSUB BUILD.DICT
      END
      FOR I = 1 TO HIST.FILES
         MM -= 1
         IF MM EQ 0 THEN YYYY -= 1 ; MM = 12
            ELSE IF MM LT 10 THEN MM = '0':MM
         YYYYMM = YYYY : MM
         AM.VEH.GRP.ID = 'AM.VEH.GRP.' : YYYYMM
         CALL F.READ(FN.FILE.CTRL, AM.VEH.GRP.ID, R.FILE.CTRL, FP.FILE.CTRL, READ.ERR)
         IF NOT(READ.ERR) THEN
            CALL F.WRITE(FN.STD.SELN.NAU,AM.VEH.GRP.ID,R.AVE.GRP.CONS)
            GOSUB BUILD.DICT
         END
      NEXT I
      RETURN
**************
BUILD.DICT:
**************

      EX.PGM.NAME = 'F.':AM.VEH.GRP.ID
      F.EX.PGM.NAME = ''
      CALL OPF(EX.PGM.NAME:FM:'NO.FATAL.ERROR',F.EX.PGM.NAME)

      OPEN "DICT" ,EX.PGM.NAME TO F.DICT.FILE ELSE NULL
      MATPARSE R.STD.SEL FROM R.AVE.GRP.CONS
      ERRMSG = ''
      CALL BUILD.DICTIONARY(MAT R.STD.SEL, EX.PGM.NAME,F.DICT.FILE,ERRMSG)

      RETURN

   END
