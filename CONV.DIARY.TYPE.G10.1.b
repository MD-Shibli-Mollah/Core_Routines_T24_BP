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
* <Rating>620</Rating>
*-----------------------------------------------------------------------------
* Version 4 30/10/00  GLOBUS Release No. 200508 30/06/05
*
    $PACKAGE SC.SccEventCapture
      SUBROUTINE CONV.DIARY.TYPE.G10.1(ID.DIARY, R.DIARY, FN.DIARY)
*
*************************************************************************
*                                                                       *
*  Routine     :  CONV.DIARY.TYPE.G10.1                                *
*                                                                       *
*************************************************************************
*                                                                       *
* This routine will transfer data from DIARY.TYPE records to EB.ACTIVITY
*
*  Description :
*                                                                       *
*                 Supplied arguments :                                  *
*                                                                       *
*                                                                       *
*************************************************************************
*                                                                       *
*  Modifications :                                                      *
*                                                                       *
*  11/03/96   -   GB9501201                                               *
*                 Initial Version.                                      *
*                                                                       *
* 23/03/00    -   GB0000612
*                 R.DIARY is a dynamic array, it is replaced as dynamic
*                 array where ever it is used as the dimensioned array.
*
*************************************************************************
*
******************
*  Insert Files.
******************
*
$INSERT I_COMMON
$INSERT I_EQUATE
*
* copy in the inserts for diary type and eb advices al la G10.1
*
      EQU SC.DRY.EVENT.DESC TO 1, SC.DRY.CASH TO 2,
         SC.DRY.SECURITY.UPDATE TO 3, SC.DRY.NEW.SECURITIES TO 4,
         SC.DRY.OPTIONS TO 5, SC.DRY.REINVEST TO 6,
         SC.DRY.RIGHTS TO 7, SC.DRY.FREE.SECURITIES TO 8,
         SC.DRY.RETAIN.ORIGINAL TO 9, SC.DRY.ADVICE TO 10,
         SC.DRY.ADVICE.FORMAT TO 11, SC.DRY.OVERDUE.DAYS TO 12,
         SC.DRY.OVERDUE.DATE TO 13, SC.DRY.COMMISSION.TYPE TO 14,
         SC.DRY.TRANSACTION.TYPE TO 15, SC.DRY.TRANSACTION.BOND TO 16,
         SC.DRY.TRANSACTION.SHARE TO 17, SC.DRY.EXCHANGE.PL.CAT TO 18,
         SC.DRY.EXCHANGE.PL.CR.CD TO 19, SC.DRY.EXCHANGE.PL.DB.CD TO 20,
         SC.DRY.FGN.CHGES.CAT TO 21, SC.DRY.FGN.CHGES.CR.CODE TO 22,
         SC.DRY.ROUND.DOWN.ONLY TO 23, SC.DRY.CASH.REMAIN TO 24,
         SC.DRY.SUSPENSE.ACCOUNT TO 25, SC.DRY.UPDATE.NOSTRO TO 26,
         SC.DRY.VERIFY.REQUIRED TO 27, SC.DRY.XT.PROCESS TO 28,
         SC.DRY.ADVICE.TYPES TO 29, SC.DRY.TAXABLE TO 30,
         SC.DRY.DEMERGE.BOOK.COST TO 31, SC.DRY.FGN.CHG.TAX.CODE TO 32,
         SC.DRY.DP.FOR.CATEGORY TO 33, SC.DRY.DP.FOR.DR.CODE TO 34,
         SC.DRY.REALLOWANCE.PL.CAT TO 35, SC.DRY.REALLOWANCE.PL.CR TO 36,
         SC.DRY.REALLOWANCE.PL.DB TO 37, SC.DRY.REDENOMINATION TO 38,
         SC.DRY.COPY.ISIN TO 39, SC.DRY.DENOM.LEVEL TO 40,
         SC.DRY.NOM.ROUNDING.METHD TO 41, SC.DRY.FACTOR.PAYMENT TO 42,
         SC.DRY.PRE.ADVICE.REQ TO 43, SC.DRY.CONFIRM.REQ TO 44,
         SC.DRY.SWIFT.CAEV TO 45, SC.DRY.BLOCK.POSITION TO 46,
         SC.DRY.RECORD.STATUS TO 47, SC.DRY.CURR.NO TO 48,
         SC.DRY.INPUTTER TO 49, SC.DRY.DATE.TIME TO 50,
         SC.DRY.AUTHORISER TO 51, SC.DRY.CO.CODE TO 52,
         SC.DRY.DEPT.CODE TO 53, SC.DRY.AUDITOR.CODE TO 54,
         SC.DRY.AUDIT.DATE.TIME TO 55
*
* EB.ADVICES G10.1.00 FIELDS actually g9.2.00
*
      EQU EB.ADV.DESCRIPTION TO 1, EB.ADV.MESSAGE.TYPE TO 2,
         EB.ADV.MSG.CLASS TO 3, EB.ADV.MAPPING.KEY TO 4,
         EB.ADV.EXTRA.ADVICE TO 5, EB.ADV.PRINT.FORMAT TO 6,
         EB.ADV.DEAL.SLIP TO 7, EB.ADV.USER.ROUTINE TO 8,
         EB.ADV.USE.RECORD TO 9, EB.ADV.RESERVED.4 TO 10,
         EB.ADV.RESERVED.3 TO 11, EB.ADV.RESERVED.2 TO 12,
         EB.ADV.RESERVED.1 TO 13, EB.ADV.LOCAL.REF TO 14,
         EB.ADV.RECORD.STATUS TO 15, EB.ADV.CURR.NO TO 16,
         EB.ADV.INPUTTER TO 17, EB.ADV.DATE.TIME TO 18,
         EB.ADV.AUTHORISER TO 19, EB.ADV.CO.CODE TO 20,
         EB.ADV.DEPT.CODE TO 21, EB.ADV.AUDITOR.CODE TO 22,
         EB.ADV.AUDIT.DATE.TIME TO 23
*
*************************************************************************
*
*************
MAIN.PROCESS:
*************
*
      IF FIELD(FN.DIARY,'$',2) THEN RETURN         ; * convert live file only
*
      IF R.DIARY<SC.DRY.ADVICE> = "" THEN RETURN   ; * No advices defined- GB0000612
*
      GOSUB INITIALISATION
*
      GOSUB PROCESS.ADVICES
*
*
      R.DIARY<SC.DRY.ADVICE> = ""
      R.DIARY<SC.DRY.ADVICE.FORMAT> = ""
*
MAIN.PROCESS.EXIT:
*
      RETURN
*
*************************************************************************
PROCESS.ADVICES:
*
* Confirmation
      ADVICE.KEY = "SC-0102-":ID.DIARY
      GOSUB PROCESS.ADVICE
* Entitlement Reversal
      ADVICE.KEY = "SC-0103-":ID.DIARY
      GOSUB PROCESS.ADVICE
* Diary reversal
      ADVICE.KEY = "SC-0104-":ID.DIARY
      GOSUB PROCESS.ADVICE
*
      RETURN
*************************************************************************
PROCESS.ADVICE:
*
      R.ADVICES = ""
      READ R.ADVICES FROM F.EB.ADVICES, ADVICE.KEY ELSE R.ADVICES = ""
*
      NUM.ADVICES = DCOUNT(R.DIARY<SC.DRY.ADVICE>,VM)
      FOR I = 1 TO NUM.ADVICES
         EBVN = DCOUNT(R.ADVICES<EB.ADV.MESSAGE.TYPE>,VM)+ 1
         DRY.ADVICE = R.DIARY<SC.DRY.ADVICE,I>
         LOCATE DRY.ADVICE IN R.ADVICES<EB.ADV.MESSAGE.TYPE,1> SETTING EBV ELSE EBV = EBVN
         EBSN = DCOUNT(R.ADVICES<EB.ADV.MESSAGE.TYPE,EBV>,SM)+ 1
         LOCATE "ADVICE" IN R.ADVICES<EB.ADV.MSG.CLASS,EBV,1> SETTING EBS ELSE EBS = EBSN
         R.ADVICES<EB.ADV.MESSAGE.TYPE,EBV> = R.DIARY<SC.DRY.ADVICE,I>
         R.ADVICES<EB.ADV.MSG.CLASS,EBV,EBS> = "ADVICE"
         R.ADVICES<EB.ADV.MAPPING.KEY,EBV> = DRY.ADVICE:".SC.003"
         R.ADVICES<EB.ADV.PRINT.FORMAT,EBV> = R.DIARY<SC.DRY.ADVICE.FORMAT,I>
      NEXT I
*
      R.ADVICES<1> = ID.DIARY            ; * description
      R.ADVICES<16> += 1                 ; * curr no
      R.ADVICES<17> = TNO:"_":APPLICATION          ; * Inputter
      TIME.DATE.INFO = OCONV(DATE(),"D-")
      TIME.DATE.INFO = TIME.DATE.INFO[9,2]:TIME.DATE.INFO[1,2]:TIME.DATE.INFO[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
      R.ADVICES<18> = TIME.DATE.INFO
      R.ADVICES<19> = TNO:"_":APPLICATION          ; * Inputter
      R.ADVICES<20> = R.DIARY<52>        ; * company code
      R.ADVICES<21> = R.DIARY<53>        ; * dept code
      R.ADVICES<22> = ""                 ; * auditor code
      R.ADVICES<23> = ""                 ; * audit date time
*
      R.DIARY<SC.DRY.CONFIRM.REQ> = "YES"
      R.DIARY<SC.DRY.PRE.ADVICE.REQ> = "NO"
*
      WRITE R.ADVICES TO F.EB.ADVICES, ADVICE.KEY
*
      RETURN
*************************************************************************
*
***************
INITIALISATION:
***************
*
      CALL OPF("F.EB.ADVICES",F.EB.ADVICES)
      IF ETEXT THEN GOSUB FATAL.ERROR
*
      ADVICE.KEY = "SC-0102-":ID.DIARY
      R.ADVICES = ""
      READ R.ADVICES FROM F.EB.ADVICES, ADVICE.KEY ELSE R.ADVICES = ""
      RETURN
*
*************************************************************************
*
*************************************************************************
*
************
FATAL.ERROR:
************
*
      TEXT = ETEXT
      CALL FATAL.ERROR("CONV.DIARY.TYPE.G10.1")
*
      RETURN
*
*************************************************************************
*
   END
