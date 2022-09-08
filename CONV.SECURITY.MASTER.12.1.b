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
* <Rating>245</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityMasterMaintenance
      SUBROUTINE CONV.SECURITY.MASTER.12.1
*
*     Last updated by DEV (Andreas) at 16:17:06 on 02/11/93
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SECURITY.MASTER RECORDS.
*
* AK - 11/02/93.
*
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
*
$INSERT I_F.PRICE.TYPE
**************************
      DATE.TODAY = TODAY
      DATE.TODAY = DATE.TODAY[7,2]:'/':DATE.TODAY[5,2]:'/':DATE.TODAY[1,4]
      DATE.TODAY = ICONV(DATE.TODAY,'D2/E')
      PRINT @(10,10):'CONVERTING SECURITY.MASTER RECORDS ......PLEASE WAIT'
      F.SCM.FILE = ''
      CALC.YIELD = 1
      YFILE.NAME1 = 'F.SECURITY.MASTER'
      CALL OPF(YFILE.NAME1,F.SCM.FILE)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      CALC.YIELD = 0
      YFILE.NAME2 = 'F.SECURITY.MASTER$NAU'
      CALL OPF(YFILE.NAME2,F.SCM.FILE)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME2 = 'F.SECURITY.MASTER$HIS'
      CALL OPF(YFILE.NAME2,F.SCM.FILE)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SCM.FILE
      LOOP
         READNEXT K.SCM.FILE ELSE NULL
      WHILE K.SCM.FILE DO
         READU R.SCM.FILE FROM F.SCM.FILE,K.SCM.FILE ELSE
            E = 'SECURITY MASTER "':K.SCM.FILE:'" MISSING FROM FILE'
            GOTO FATAL.ERR
         END
         IF NOT(R.SCM.FILE<75> MATCHES '2A7N') THEN
            INS '' BEFORE R.SCM.FILE<12>
            IF CALC.YIELD AND R.SCM.FILE<8> = 'B' THEN GOSUB UPDATE.YIELD
            INS '' BEFORE R.SCM.FILE<68>           ; * Change for GB9300255
         END
         WRITE R.SCM.FILE TO F.SCM.FILE,K.SCM.FILE
      REPEAT
      RETURN                             ; * EXIT PROGRAM
*
*************
UPDATE.YIELD:
*************
      PRICE.TYPE = R.SCM.FILE<11>
      CALC.METHOD = ''
      CALL DBR('PRICE.TYPE':FM:SC.PRT.CALCULATION.METHOD,PRICE.TYPE,CALC.METHOD)
      IF CALC.METHOD = 'DISCOUNT' OR CALC.METHOD = 'YIELD' THEN
         LAST.PRICE = R.SCM.FILE<13>
         INT.DAY.BASIS = R.SCM.FILE<24>
         BEGIN CASE
            CASE INT.DAY.BASIS[1,1] = 'A' OR INT.DAY.BASIS[1,1] = 'B'
               YEAR.DAYS = 36000
            CASE INT.DAY.BASIS[1,1] = 'E' OR INT.DAY.BASIS[1,1] = 'F'
               YEAR.DAYS = 36500
            CASE INT.DAY.BASIS[1,1] = 'C' OR INT.DAY.BASIS[1,1] = 'D'
               YEAR.DAYS = 36500
            CASE 1
               YEAR.DAYS = 0
         END CASE
         MAT.DATE = R.SCM.FILE<26>
         MAT.DATE = MAT.DATE[7,2]:'/':MAT.DATE[5,2]:'/':MAT.DATE[1,4]
         MAT.DATE = ICONV(MAT.DATE,'D2/E')
         DAYS.TO.GO = MAT.DATE - DATE.TODAY
         IF YEAR.DAYS AND DAYS.TO.GO > 0 AND LAST.PRICE THEN
            IF CALC.METHOD = 'YIELD' THEN
               YLD.PERC = ((100/LAST.PRICE)-1) * (YEAR.DAYS/DAYS.TO.GO)
            END ELSE
               YLD.PERC = (1-(LAST.PRICE/100)) * (YEAR.DAYS/DAYS.TO.GO)
            END
            YLD.PERC = OCONV(ICONV(YLD.PERC,'MD6'),'MD6')
            R.SCM.FILE<12> = YLD.PERC
         END
      END
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SECURITY.MASTER.12.1.0')
********
* END
********
   END
