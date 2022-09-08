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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>456</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoPortfolioMaintenance
      SUBROUTINE CONV.SEC.ACC.MASTER.12.1
*
* WRITTEN BY A. KYRIACOU
* DATE  05/03/93.
*
*     Amended March 1993 as part of PIF GB9200236 to add fields,
*     LINEAR.COMP.ACCR, REVALUATION, REVAL.FREQ, CHG.DISC.BONDS AND
*     POST.DISC.UPFRONT .
*
**************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING SEC.ACC.MASTER RECORDS ...PLEASE WAIT'
      INSERT.VALS = 0
      F.SEC.ACC.MASTER = ''
      UNAUTH.FILE = 1
      YFILE.NAME2 = 'F.SEC.ACC.MASTER$NAU'
      CALL OPF(YFILE.NAME2,F.SEC.ACC.MASTER)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      UNAUTH.FILE = 0
      YFILE.NAME3 = 'F.SEC.ACC.MASTER$HIS'
      CALL OPF(YFILE.NAME3,F.SEC.ACC.MASTER)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      INSERT.VALS = 1
      YFILE.NAME1 = 'F.SEC.ACC.MASTER'
      CALL OPF(YFILE.NAME1,F.SEC.ACC.MASTER)
      YFILE.NAME2 = 'F.SEC.ACC.MASTER$NAU'
      F.NAU = ''
      CALL OPF(YFILE.NAME2,F.NAU)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SEC.ACC.MASTER
      LOOP
         READNEXT K.SEC.ACC.MASTER ELSE NULL
      WHILE K.SEC.ACC.MASTER DO
         READU R.SEC.ACC.MASTER FROM F.SEC.ACC.MASTER,K.SEC.ACC.MASTER ELSE
            E = 'SEC ACC MASTER "':K.SEC.ACC.MASTER:'" MISSING FROM FILE'
            GOTO FATAL.ERR
         END
         IF NOT(R.SEC.ACC.MASTER<71> MATCHES '2A7N') THEN
            INS '' BEFORE R.SEC.ACC.MASTER<51>
            INS '' BEFORE R.SEC.ACC.MASTER<51>
            INS '' BEFORE R.SEC.ACC.MASTER<51>
            INS '' BEFORE R.SEC.ACC.MASTER<51>
            INS '' BEFORE R.SEC.ACC.MASTER<51>
            INS '' BEFORE R.SEC.ACC.MASTER<60>
            INS '' BEFORE R.SEC.ACC.MASTER<60>
            INS '' BEFORE R.SEC.ACC.MASTER<60>
            INS '' BEFORE R.SEC.ACC.MASTER<60>
            INS '' BEFORE R.SEC.ACC.MASTER<60>     ; * Change for GB9300255
            R.SEC.ACC.MASTER<56> = ''
            IF UNAUTH.FILE THEN R.SEC.ACC.MASTER<66> = 'IHLD'
            IF INSERT.VALS THEN
               IF R.SEC.ACC.MASTER<35> NE '' THEN
                  READU R.NAU FROM F.NAU,K.SEC.ACC.MASTER ELSE R.NAU = ''
                  R.NAU = R.SEC.ACC.MASTER
                  R.NAU<66> = 'IHLD'
                  R.NAU<67> = R.SEC.ACC.MASTER<67> + 1
                  WRITE R.NAU TO F.NAU,K.SEC.ACC.MASTER
               END
            END
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
      CALL FATAL.ERROR('CONV.SEC.ACC.MASTER.12.1')
********
   END
