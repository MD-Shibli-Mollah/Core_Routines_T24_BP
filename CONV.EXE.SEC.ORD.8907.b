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
* <Rating>159</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctOrderExecution
      SUBROUTINE CONV.EXE.SEC.ORD.8907
*
*     Last updated by dev.run (dev) at 10:44:14 on 09/08/79
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING CUSTOMER.SECURITY RECORDS.
* ALSO ADD NEW FIELDS :-
* 1. ORDER.BROKER
* 2. AMT.TO.BROKER
* 3. EXE.BY.BROKER
*
*
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING SC.EXE.SEC.ORDERS RECORDS ......PLEASE WAIT'
      F.SC.EXE.SEC.ORDERS = ''
      YFILE.NAME1 = 'F.SC.EXE.SEC.ORDERS'
      CALL OPF(YFILE.NAME1,F.SC.EXE.SEC.ORDERS)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.SC.EXE.SEC.ORDERS
      LOOP
         READNEXT K.SC.EXE.SEC.ORDERS ELSE NULL
      WHILE K.SC.EXE.SEC.ORDERS DO
         READU R.SC.EXE.SEC.ORDERS FROM F.SC.EXE.SEC.ORDERS,K.SC.EXE.SEC.ORDERS ELSE
            E = 'OPEN ORDER "':K.SC.EXE.SEC.ORDERS:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.SC.EXE.SEC.ORDERS,FM) + (R.SC.EXE.SEC.ORDERS # '')
         IF NO.OF.FIELDS < 29 THEN
            INS '' BEFORE R.SC.EXE.SEC.ORDERS<18>
            INS '' BEFORE R.SC.EXE.SEC.ORDERS<18>
            INS '' BEFORE R.SC.EXE.SEC.ORDERS<18>
         END
         WRITE R.SC.EXE.SEC.ORDERS TO F.SC.EXE.SEC.ORDERS,K.SC.EXE.SEC.ORDERS
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.SC.EXE.SEC.ORDERS.8907')
********
* END
********
   END
