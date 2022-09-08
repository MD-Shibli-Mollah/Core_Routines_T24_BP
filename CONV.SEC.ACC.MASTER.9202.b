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

* Version 4 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>156</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoPortfolioMaintenance
      SUBROUTINE CONV.SEC.ACC.MASTER.9202
*
*     Last updated by dev.run (dev) at 10:44:14 on 09/08/79
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SEC.ACC.MASTER RECORDS.
* ALSO ADD NEW FIELDS :-
* SUSPENSE UNREALISED CATEGORY
* POST UNREALISED (Y/N)
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING SEC.ACC.MASTER RECORDS ......PLEASE WAIT'
      F.SEC.ACC.MASTER = ''
      YFILE.NAME1 = 'F.SEC.ACC.MASTER'
      CALL OPF(YFILE.NAME1,F.SEC.ACC.MASTER)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.SEC.ACC.MASTER$NAU'
      CALL OPF(YFILE.NAME2,F.SEC.ACC.MASTER)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.SEC.ACC.MASTER$HIS'
      CALL OPF(YFILE.NAME3,F.SEC.ACC.MASTER)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SEC.ACC.MASTER
      LOOP
         READNEXT K.SEC.ACC.MASTER ELSE NULL
      WHILE K.SEC.ACC.MASTER DO
         READU R.SEC.ACC.MASTER FROM F.SEC.ACC.MASTER,K.SEC.ACC.MASTER ELSE
            E = 'OPEN ORDER "':K.SEC.ACC.MASTER:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.SEC.ACC.MASTER,FM) + (R.SEC.ACC.MASTER # '')
*
** Check the company code (position 61)
*
         IF NO.OF.FIELDS < 64 AND NOT(R.SEC.ACC.MASTER<61> MATCHES "2A7N") THEN
            INS '' BEFORE R.SEC.ACC.MASTER<50>
            INS '' BEFORE R.SEC.ACC.MASTER<50>
         END
*
         WRITE R.SEC.ACC.MASTER TO F.SEC.ACC.MASTER,K.SEC.ACC.MASTER
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SEC.ACC.MASTER.9002')
********
* END
********
   END
