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
    $PACKAGE SC.ScfSafekeepingFees
      SUBROUTINE CONV.SAFECUSTODY.EXT.9206
*
*     Written by Peter Ryan (May 1992) as part of PIF GB9200428 to
*     add an extra field of "CLOSING.NOMINAL" to file SAFECUSTODY.EXTRACT
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SAFECUSTODY.EXTRACT RECORDS.
* ALSO ADD NEW FIELDS :-
*   CLOSING.NOMINAL
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
**************************
      PRINT @(10,10):'CONVERTING SAFECUSTODY.EXTRACT RECORDS ......PLEASE WAIT'
      F.STK.EXC.LOCAL = ''
      CALL OPF('F.STK.EXC.LOCAL',F.STK.EXC.LOCAL)
      K.LOCAL = ID.COMPANY
      READ R.LOCAL FROM F.STK.EXC.LOCAL,K.LOCAL ELSE
         E = 'STOCK EXC LOCAL RECORD NOT FOUND '
         GOTO FATAL.ERR
      END
      F.SAFECUSTODY.EXTRACT = ''
      YFILE.NAME1 = 'F.SAFECUSTODY.EXTRACT'
      CALL OPF(YFILE.NAME1,F.SAFECUSTODY.EXTRACT)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.SAFECUSTODY.EXTRACT$NAU'
      CALL OPF(YFILE.NAME2,F.SAFECUSTODY.EXTRACT)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.SAFECUSTODY.EXTRACT$HIS'
      CALL OPF(YFILE.NAME3,F.SAFECUSTODY.EXTRACT)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SAFECUSTODY.EXTRACT
      LOOP
         READNEXT K.SAFECUSTODY.EXTRACT ELSE NULL
      WHILE K.SAFECUSTODY.EXTRACT DO
         READU R.SAFECUSTODY.EXTRACT FROM F.SAFECUSTODY.EXTRACT,K.SAFECUSTODY.EXTRACT ELSE
            E = 'OPEN ORDER "':K.SAFECUSTODY.EXTRACT:'" MISSING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.SAFECUSTODY.EXTRACT,FM) + (R.SAFECUSTODY.EXTRACT # '')
         IF NO.OF.FIELDS < 16 THEN
*
            INS '' BEFORE R.SAFECUSTODY.EXTRACT<7>
*
         END
*
         WRITE R.SAFECUSTODY.EXTRACT TO F.SAFECUSTODY.EXTRACT,K.SAFECUSTODY.EXTRACT
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SAFECUSTODY.EXTRACT.9206')
********
   END
