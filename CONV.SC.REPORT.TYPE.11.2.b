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

* Version 2 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>157</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScvReports
      SUBROUTINE CONV.SC.REPORT.TYPE.11.2
*
*     Amended November 1992 as part of PIF GB9200646 to add new field
*     of 'SC.RAT.VAL.PARAM.ID' to file F.SC.REPORT.TYPE.
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SC.REPORT.TYPE RECORDS.
* ALSO ADD NEW FIELDS :-
*   SC.RAT.VAL.PARAM.ID
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
**************************
      PRINT @(10,10):'CONVERTING SC.REPORT.TYPE RECORDS ...PLEASE WAIT'
      F.SC.REPORT.TYPE = ''
      YFILE.NAME1 = 'F.SC.REPORT.TYPE'
      CALL OPF(YFILE.NAME1,F.SC.REPORT.TYPE)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.SC.REPORT.TYPE$NAU'
      CALL OPF(YFILE.NAME2,F.SC.REPORT.TYPE)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.SC.REPORT.TYPE$HIS'
      CALL OPF(YFILE.NAME3,F.SC.REPORT.TYPE)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SC.REPORT.TYPE
      LOOP
         READNEXT K.SC.REPORT.TYPE ELSE NULL
      WHILE K.SC.REPORT.TYPE DO
         READU R.SC.REPORT.TYPE FROM F.SC.REPORT.TYPE,K.SC.REPORT.TYPE ELSE
            E = 'REPORT TYPE "':K.SC.REPORT.TYPE:'" MISSING FROM FILE'
            GOTO FATAL.ERR
         END
         LOOP
            NO.OF.FIELDS = DCOUNT(R.SC.REPORT.TYPE,FM)
         UNTIL NO.OF.FIELDS GE 13 DO
            INS '' BEFORE R.SC.REPORT.TYPE<4>
         REPEAT
*
         WRITE R.SC.REPORT.TYPE TO F.SC.REPORT.TYPE,K.SC.REPORT.TYPE
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SC.REPORT.TYPE.11.2')
********
   END
