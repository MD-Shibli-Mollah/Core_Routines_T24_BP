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

* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>157</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityMasterMaintenance
      SUBROUTINE CONV.SEC.MASTER.8912
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SECURITY.MASTER RECORDS.
* ALSO ADD NEW FIELDS :-
*   RATING
*   ISSUE.DATE
*   CALCULATE.COUPON
*   RATE.CH.DATE
*   STK.EXCH.PRICE
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING SECURITY.MASTER RECORDS ......PLEASE WAIT'
      F.SECURITY.MASTER = ''
      YFILE.NAME1 = 'F.SECURITY.MASTER'
      CALL OPF(YFILE.NAME1,F.SECURITY.MASTER)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.SECURITY.MASTER$NAU'
      CALL OPF(YFILE.NAME2,F.SECURITY.MASTER)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.SECURITY.MASTER$HIS'
      CALL OPF(YFILE.NAME3,F.SECURITY.MASTER)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SECURITY.MASTER
      LOOP
         READNEXT K.SECURITY.MASTER ELSE NULL
      WHILE K.SECURITY.MASTER DO
         READU R.SECURITY.MASTER FROM F.SECURITY.MASTER,K.SECURITY.MASTER ELSE
            E = 'OPEN ORDER "':K.SECURITY.MASTER:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.SECURITY.MASTER,FM) + (R.SECURITY.MASTER # '')
*
         ACC.ST.DATE = R.SECURITY.MASTER<60>
         NEXT.CPN.DATE = R.SECURITY.MASTER<61>
         STOCK.EXCH = R.SECURITY.MASTER<16>
         IF NO.OF.FIELDS < 76 THEN
            INS '' BEFORE R.SECURITY.MASTER<62>
            INS '' BEFORE R.SECURITY.MASTER<62>
            DEL R.SECURITY.MASTER<61>
            DEL R.SECURITY.MASTER<60>
            INS ACC.ST.DATE BEFORE R.SECURITY.MASTER<26>
            INS NEXT.CPN.DATE BEFORE R.SECURITY.MASTER<26>
            INS '' BEFORE R.SECURITY.MASTER<22>
            INS '' BEFORE R.SECURITY.MASTER<21>
            INS STOCK.EXCH BEFORE R.SECURITY.MASTER<17>
         END
         IF R.SECURITY.MASTER<28> THEN
            R.SECURITY.MASTER<31> = R.SECURITY.MASTER<28>
         END ELSE
            R.SECURITY.MASTER<31> = R.SECURITY.MASTER<29>
         END
*
         WRITE R.SECURITY.MASTER TO F.SECURITY.MASTER,K.SECURITY.MASTER
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SEC.MASTER.8912')
********
* END
********
   END
