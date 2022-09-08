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
* <Rating>428</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Limits
      SUBROUTINE CONV.DR.UPD.LIMITS(DR.ID)
*
*06/02/2000  - GB0000130
*              Call this program as a part of conversion routine
*27/05/2002 - BG_100001162
*             Removed unwanted DIM R.SAVE.NEW from INITIALISE para
*
********************************************************************
$INSERT I_EQUATE
$INSERT I_COMMON
$INSERT I_LC.COMMON
$INSERT I_F.ACCOUNT
$INSERT I_F.CUSTOMER

      S.ROB=RUNNING.UNDER.BATCH
      EQU TF.DR.DRAWING.TYPE TO 1
      EQU TF.DR.DRAW.CURRENCY TO 2
      EQU TF.DR.LIMIT.REFERENCE TO 68
      EQU TF.DR.DOCUMENT.AMOUNT TO 3
      EQU TF.DR.PROV.REL.DOC.CCY TO 162
      EQU TF.DR.MATURITY.REVIEW TO 7
      EQU TF.DR.VALUE.DATE TO 11
      EQU TF.LC.PROVIS.ACC TO 140
      EQU TF.LC.LC.CURRENCY TO 20
      EQU TF.LC.LC.TYPE TO 2
      EQU TF.LC.CON.CUS.LINK TO 18
      RUNNING.UNDER.BATCH=1
*      GOSUB INIT
      GOSUB PROCESS.LIMITS
!      CALL JOURNAL.UPDATE(ID.NEW)
      RUNNING.UNDER.BATCH=S.ROB
      RETURN
*********************************************************************
INIT:

      F.DRAWINGS = 'F.DRAWINGS'
      F.DR = ''
      CALL OPF(F.DRAWINGS,F.DR)
      SEL.CMD = 'SSELECT ':F.DRAWINGS
!OPEN DRAWING FILE AND SELECT ONLY LIVE AC DR HERE
      F.LETTER.OF.CREDIT = 'F.LETTER.OF.CREDIT'
      F.LC = ''
      CALL OPF(F.LETTER.OF.CREDIT,F.LC)
      RETURN
*********************************************************************
PROCESS.LIMITS:
! NOW FOR EACH SELECTED DR REV THE LIMIT AND CREATE NEW LIMIT
*      CALL EB.READLIST(SEL.CMD,LC.LISTS,'',SELECTED,RET.ERR)
*      LOOP
*         REMOVE ID FROM LC.LISTS SETTING CODE
*      WHILE ID
*         ID.NEW=ID
*         CALL F.MATREADU('F.DRAWINGS',ID.NEW,MAT R.NEW,V.DR,F.DRAWINGS,ETEXT,"")
*         IF ETEXT THEN
*            ETEXT = 'MISSING FILE = F.DRAWINGS = ':ID.NEW
*            GOTO EXIT
*         END
**Read LC Record
*         DIM LC.REC(500)
*         LC.ID = ID.NEW[1,12]
*         V.LC = TF.LC.AUDIT.DATE.TIME
*         CALL F.MATREADU('F.LETTER.OF.CREDIT',LC.ID,MAT LC.REC,V.LC,F.LETTER.OF.CREDIT,ETEXT,"")
*         IF ETEXT THEN
*            ETEXT = 'MISSING FILE = F.LETTER.OF.CREDIT = ':LC.ID
*            GOTO EXIT
*         END
      GOSUB SET.LIMIT.PARAM
      IF R.NEW(TF.DR.DRAWING.TYPE) NE 'AC' OR R.NEW(TF.DR.DRAWING.TYPE) NE 'DP' THEN RETURN
      PROVISION.ACCOUNT = LC.REC(TF.LC.PROVIS.ACC)
      IF PROVISION.ACCOUNT EQ '' THEN RETURN
      PROV.CCY = ''
      CALL DBR('ACCOUNT':FM:AC.CURRENCY,PROVISION.ACCOUNT,PROV.CCY)
      IF PROV.CCY EQ LC.REC(TF.LC.LC.CURRENCY) THEN RETURN
      IF R.NEW(TF.DR.LIMIT.REFERENCE) THEN
         LIMIT.AMOUNT = R.NEW(TF.DR.DOCUMENT.AMOUNT)
         IF LIMIT.AMOUNT GT 0 THEN
            CALL LIMIT.CHECK(LIAB.NO,CUSTOMER.NUMBER,REF.NO,SERIAL.NO,LIMIT.KEY,
               NEW.MAT.DAT,DRAW.CCY,-LIMIT.AMOUNT,'','','','','','',LC.YCURR.NO,
               '','','DEL',RETURN.CODE)
            IF RETURN.CODE THEN GOSUB V$EXIT
         END
      END
      IF R.NEW(TF.DR.LIMIT.REFERENCE) THEN
         PROVISION.AMT = R.NEW(TF.DR.PROV.REL.DOC.CCY)
         LIMIT.AMOUNT = R.NEW(TF.DR.DOCUMENT.AMOUNT) - PROVISION.AMT
         IF LIMIT.AMOUNT GT 0 THEN
            CALL LIMIT.CHECK(LIAB.NO,CUSTOMER.NUMBER,REF.NO,SERIAL.NO,DR.ID,NEW.MAT.DAT,R.NEW(TF.DR.DRAW.CURRENCY),-LIMIT.AMOUNT,'','','','','','',LC.YCURR.NO,'','','VAL',RETURN.CODE)
            IF RETURN.CODE THEN GOSUB V$EXIT
         END
      END
*      REPEAT
      RETURN
*********************************************************************
SET.LIMIT.PARAM:
*
INITIALISE:
*
* set AF to LIMIT.REFERENCE before calling LIMIT.CHECKS on-line
*
      LIAB.NO = ""
      IMPORT.LC = ''
      EXPORT.LC = ''
      RETURN.CODE = ''

      CALL LC.IMP.EXP(LC.REC(TF.LC.LC.TYPE), IMPORT.LC, EXPORT.LC , "" )

      CUSTOMER.NUMBER = LC.REC(TF.LC.CON.CUS.LINK)
      LIMIT.KEY = DR.ID
      ID.SAVE.NEW = ''
*
* Set up liability number
*
      CALL DBR("CUSTOMER":FM:EB.CUS.CUSTOMER.LIABILITY,
         CUSTOMER.NUMBER,LIAB.NO)

! THIS IS DRAWING LIMIT REF
      POS = INDEX(R.NEW(TF.DR.LIMIT.REFERENCE),'.',1)
      REF.NO = R.NEW(TF.DR.LIMIT.REFERENCE)[1,POS-1]
      SERIAL.NO = R.NEW(TF.DR.LIMIT.REFERENCE)[POS+1,9]

      NEW.MAT.DAT = R.NEW(TF.DR.MATURITY.REVIEW)
      IF NOT(NEW.MAT.DAT) THEN
         NEW.MAT.DAT = R.NEW(TF.DR.VALUE.DATE)
      END
*


      RETURN
*********************************************************************
V$EXIT:
      CALL FATAL.ERROR(ETEXT)
      RETURN
   END
