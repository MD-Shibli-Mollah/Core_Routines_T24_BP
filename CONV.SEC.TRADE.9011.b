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
* <Rating>155</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctTrading
      SUBROUTINE CONV.SEC.TRADE.9011
*
*     LAST UPDATED BY DEV.RUN (DEV) AT 10:44:14 ON 09/08/79
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SEC.TRADE RECORDS.
* ALSO ADD NEW FIELDS :-
* BR.COMMSSION      ; *  FOR CLIENT WITH OUT PORTFOLIO
* DEP.DELIV.REP     ; *  CEDEL RELATED REF
* SETTL INSTR       ; *  OPEN ORDER SETTL INSTRUCTION
* LOCAL.REF         ; *  LOCAL REF FIELD
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
            E = 'SEC TRADE "':K.SEC.TRADE:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.SEC.TRADE,FM) + (R.SEC.TRADE # '')
**         IF NO.OF.FIELDS < 105 THEN
         IF NO.OF.FIELDS < 104 THEN
            INS '' BEFORE R.SEC.TRADE<91>
            INS '' BEFORE R.SEC.TRADE<91>
            INS '' BEFORE R.SEC.TRADE<91>
**            INS '' BEFORE R.SEC.TRADE<71>
         END
         WRITE R.SEC.TRADE TO F.SEC.TRADE,K.SEC.TRADE
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SEC.TRADE.9011')
   END
