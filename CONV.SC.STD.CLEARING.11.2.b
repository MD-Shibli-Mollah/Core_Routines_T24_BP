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

* Version 4 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>156</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.Config
      SUBROUTINE CONV.SC.STD.CLEARING.11.2
*
*     Amended September 1992 as part of PIF GB9200891 to add new field
*     of 'SC.BSD.BNB.REF' to file F.SC.STD.CLEARING.
*
* 02/09/94 - GB9400980
*            Amended to correct errors from when upgrading Fuji from
*            release 10.4 to 14.1.4
*            Amended so that FATAL.ERROR is not called if the company
*            record is not on the SC.STD.CLEARING file.  Instead, the
*            message is just displayed
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SC.STD.CLEARING RECORDS.
* ALSO ADD NEW FIELDS :-
*   SC.BSD.BNB.REF
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
**************************
      PRINT @(10,10):'CONVERTING SC.STD.CLEARING RECORDS ...PLEASE WAIT'
      F.SC.STD.CLEARING = ''
      CALL OPF('F.SC.STD.CLEARING',F.SC.STD.CLEARING)
      K.LOCAL = ID.COMPANY
      READ R.LOCAL FROM F.SC.STD.CLEARING,K.LOCAL ELSE
         PRINT 'SC.STD.CLEARING COMPANY RECORD NOT FOUND '
****         GOTO FATAL.ERR
      END
      F.SC.STD.CLEARING = ''
      YFILE.NAME1 = 'F.SC.STD.CLEARING'
      CALL OPF(YFILE.NAME1,F.SC.STD.CLEARING)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.SC.STD.CLEARING$NAU'
      CALL OPF(YFILE.NAME2,F.SC.STD.CLEARING)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.SC.STD.CLEARING$HIS'
      CALL OPF(YFILE.NAME3,F.SC.STD.CLEARING)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SC.STD.CLEARING
      LOOP
         READNEXT K.SC.STD.CLEARING ELSE NULL
      WHILE K.SC.STD.CLEARING DO
         READU R.SC.STD.CLEARING FROM F.SC.STD.CLEARING,K.SC.STD.CLEARING ELSE
            E = 'OPEN ORDER "':K.SC.STD.CLEARING:'" MISSING FROM FILE'
            GOTO FATAL.ERR
         END
         LOOP
            NO.OF.FIELDS = DCOUNT(R.SC.STD.CLEARING,FM)
         UNTIL NO.OF.FIELDS GE 15 DO
            INS '' BEFORE R.SC.STD.CLEARING<5>
         REPEAT
*
         WRITE R.SC.STD.CLEARING TO F.SC.STD.CLEARING,K.SC.STD.CLEARING
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SC.STD.CLEARING.11.2')
********
   END
