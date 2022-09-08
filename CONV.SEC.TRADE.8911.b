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
    $PACKAGE SC.SctTrading
      SUBROUTINE CONV.SEC.TRADE.8911
*
*     Last updated by dev.run (dev) at 10:44:14 on 09/08/79
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SEC.TRADE RECORDS.
* ALSO ADD NEW FIELDS :-
* 1.XX-CU.DELIV.INSTR
* 2 XX-BR.DELIV.INSTR
* DELETE THE OLD FIELD:-
* DELIVERY.INSTR
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING SEC.TRADE RECORDS ......PLEASE WAIT'
      F.SEC.TRADE = ''
      YFILE.NAME1 = 'F.SEC.TRADE'
      CALL OPF(YFILE.NAME1,F.SEC.TRADE)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.SEC.TRADE$NAU'
      CALL OPF(YFILE.NAME2,F.SEC.TRADE)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.SEC.TRADE$HIS'
      CALL OPF(YFILE.NAME3,F.SEC.TRADE)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SEC.TRADE
      LOOP
         READNEXT K.SEC.TRADE ELSE NULL
      WHILE K.SEC.TRADE DO
         READU R.SEC.TRADE FROM F.SEC.TRADE,K.SEC.TRADE ELSE
            E = 'OPEN ORDER "':K.SEC.TRADE:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.SEC.TRADE,FM) + (R.SEC.TRADE # '')
         CU.DELIV.KEY = '' ; BR.DELIV.KEY = ''
         IF NO.OF.FIELDS < 94 THEN
            DELIV.INSTR = R.SEC.TRADE<10>
            NO.OF.CUST = COUNT(R.SEC.TRADE<19>,VM) + (R.SEC.TRADE<19> # '')
            FOR I = 1 TO NO.OF.CUST
               CU.DELIV.KEY<1,-1> = DELIV.INSTR
            NEXT I
*
            NO.OF.BRKR = COUNT(R.SEC.TRADE<50>,VM) + (R.SEC.TRADE<50> # '')
            FOR I = 1 TO NO.OF.BRKR
               BR.DELIV.KEY<1,-1> = DELIV.INSTR
            NEXT I
*
            INS BR.DELIV.KEY BEFORE R.SEC.TRADE<71>
            INS CU.DELIV.KEY BEFORE R.SEC.TRADE<45>
            DEL R.SEC.TRADE<10>
         END
*
         WRITE R.SEC.TRADE TO F.SEC.TRADE,K.SEC.TRADE
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SEC.TRADE.8911')
********
* END
********
   END
