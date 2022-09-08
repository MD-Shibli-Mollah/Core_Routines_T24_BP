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
* <Rating>157</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctOffMarketTrades
      SUBROUTINE CONV.SECURITY.TRANSFER.11.2
*
*     Amended July 1992 as part of PIF GB9203104 to add new field
*     of 'LOCAL.TAX' to file F.SECURITY.TRANSFER.
*
*     Also LOCAL.REF (18.08/92).
**************************************************************
* SUBROUTINE TO CONVERT EXISTING SC.STD.SEC.TRADE RECORDS.
* ALSO ADD NEW FIELDS :-
*   LOCAL.TAX
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
**************************
      PRINT @(10,10):'CONVERTING SECURITY.TRANSFER RECORDS ...PLEASE WAIT'
      F.SECURITY.TRANSFER = ''
      CALL OPF('F.SECURITY.TRANSFER',F.SECURITY.TRANSFER)
      F.SECURITY.TRANSFER = ''
      YFILE.NAME1 = 'F.SECURITY.TRANSFER'
      CALL OPF(YFILE.NAME1,F.SECURITY.TRANSFER)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.SECURITY.TRANSFER$NAU'
      CALL OPF(YFILE.NAME2,F.SECURITY.TRANSFER)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.SECURITY.TRANSFER$HIS'
      CALL OPF(YFILE.NAME3,F.SECURITY.TRANSFER)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SECURITY.TRANSFER
      LOOP
         READNEXT K.SECURITY.TRANSFER ELSE NULL
      WHILE K.SECURITY.TRANSFER DO
         READU R.SECURITY.TRANSFER FROM F.SECURITY.TRANSFER,K.SECURITY.TRANSFER ELSE
            E = 'OPEN ORDER "':K.SECURITY.TRANSFER:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = DCOUNT(R.SECURITY.TRANSFER,FM)
         IF NO.OF.FIELDS < 51 THEN
            INS '' BEFORE R.SECURITY.TRANSFER<15>
         END
         IF NO.OF.FIELDS < 52 THEN
            INS '' BEFORE R.SECURITY.TRANSFER<41>
         END
*
         WRITE R.SECURITY.TRANSFER TO F.SECURITY.TRANSFER,K.SECURITY.TRANSFER
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SECURITY.TRANSFER.11.2')
********
   END
