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

* Version 2 22/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>157</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoPortfolioMaintenance
      SUBROUTINE CONV.SEC.ACC.MASTER.11.2
*
*     Amended October 1992 as part of PIF GB9200915 to change field
*     6 of SEC.ACC.MASTER from STATEMENT.FREQ to VALUATION.CURRENCY.
*     This routine is designed to clear field six of every SEC.ACC.MASTER
*     record and replace it with the portfolio's REFERENCE.CURRENCY.
*
**************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.SEC.ACC.MASTER
**************************
      PRINT @(10,10):'CONVERTING SEC.ACC.MASTER RECORDS ...PLEASE WAIT'
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
            E = 'OPEN ORDER "':K.SEC.ACC.MASTER:'" MISSING FROM FILE'
            GOTO FATAL.ERR
         END
         R.SEC.ACC.MASTER<SC.SAM.VALUATION.CURRENCY> = R.SEC.ACC.MASTER<SC.SAM.REFERENCE.CURRENCY>
*
         WRITE R.SEC.ACC.MASTER TO F.SEC.ACC.MASTER,K.SEC.ACC.MASTER
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SEC.ACC.MASTER.11.2')
********
   END
