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
* <Rating>257</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.Config
      SUBROUTINE CONV.SC.STD.POS.TRANSF.11.2
*
*     Amended July 1992 as part of PIF GB9200631 to add new field
*     of 'LOCAL.TAX.RATE' to file F.SC.STD.POS.TRANSF.
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SC.STD.POS.TRANSF RECORDS.
* ALSO ADD NEW FIELDS :-
*   TTYP... (6 fields)
*   LOCAL.TAX.RATE (4 fields)
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
**************************
      PRINT @(10,10):'CONVERTING SC.STD.POS.TRANSF RECORDS ...PLEASE WAIT'
      F.SC.STD.POS.TRANSF = ''
      CALL OPF('F.SC.STD.POS.TRANSF',F.SC.STD.POS.TRANSF)
      K.LOCAL = ID.COMPANY
      READ R.LOCAL FROM F.SC.STD.POS.TRANSF,K.LOCAL ELSE
         E = 'SC.STD.POS.TRANSF COMPANY RECORD NOT FOUND '
         GOTO FATAL.ERR
      END
      F.SC.STD.POS.TRANSF = ''
      YFILE.NAME1 = 'F.SC.STD.POS.TRANSF'
      CALL OPF(YFILE.NAME1,F.SC.STD.POS.TRANSF)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.SC.STD.POS.TRANSF$NAU'
      CALL OPF(YFILE.NAME2,F.SC.STD.POS.TRANSF)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.SC.STD.POS.TRANSF$HIS'
      CALL OPF(YFILE.NAME3,F.SC.STD.POS.TRANSF)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SC.STD.POS.TRANSF
      LOOP
         READNEXT K.SC.STD.POS.TRANSF ELSE NULL
      WHILE K.SC.STD.POS.TRANSF DO
         READU R.SC.STD.POS.TRANSF FROM F.SC.STD.POS.TRANSF,K.SC.STD.POS.TRANSF ELSE
            E = 'RECORD "':K.SC.STD.POS.TRANSF:'" MISSING FROM FILE'
            GOTO FATAL.ERR
         END
         LOOP
            NO.OF.FIELDS = DCOUNT(R.SC.STD.POS.TRANSF,FM)
         UNTIL NO.OF.FIELDS GE 27 DO
            INS '' BEFORE R.SC.STD.POS.TRANSF<9>
         REPEAT
*
         WRITE R.SC.STD.POS.TRANSF TO F.SC.STD.POS.TRANSF,K.SC.STD.POS.TRANSF
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SC.STD.POS.TRANSF.11.2')
********
   END
