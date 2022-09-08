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
* <Rating>167</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.Config
      SUBROUTINE CONV.CUST.SECURITY.9204
*
*     Last updated by dev.run (dev) at 12:48:16 on 04/29/92
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING CUSTOMER.SECURITY RECORDS.
* ALSO ADD NEW FIELDS :-
* DIV.COMM.TYPE
* RED.COMM.TYPE
* STOCK.COMM.TYPE
*
*
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(-1):@(10,10):'CONVERTING CUSTOMER.SECURITY RECORDS ......PLEASE WAIT'
      F.CUSTOMER.SECURITY = ''
      YFILE.NAME = 'F.CUSTOMER.SECURITY'
      CALL OPF(YFILE.NAME,F.CUSTOMER.SECURITY)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME = 'F.CUSTOMER.SECURITY$NAU'
      CALL OPF(YFILE.NAME,F.CUSTOMER.SECURITY)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME = 'F.CUSTOMER.SECURITY$HIS'
      CALL OPF(YFILE.NAME,F.CUSTOMER.SECURITY)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
      SELECT F.CUSTOMER.SECURITY
      LOOP
         READNEXT K.CUSTOMER.SECURITY ELSE NULL
      WHILE K.CUSTOMER.SECURITY DO
         READU R.CUSTOMER.SECURITY FROM F.CUSTOMER.SECURITY,K.CUSTOMER.SECURITY ELSE
            E = "RECORD ":K.CUSTOMER.SECURITY:" MISING FROM ":YFILE.NAME
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.CUSTOMER.SECURITY,FM) + (R.CUSTOMER.SECURITY # '')
         IF NO.OF.FIELDS LT 31 THEN
            INS '' BEFORE R.CUSTOMER.SECURITY<14>
            INS '' BEFORE R.CUSTOMER.SECURITY<14>
            INS '' BEFORE R.CUSTOMER.SECURITY<14>
         END
         WRITE R.CUSTOMER.SECURITY TO F.CUSTOMER.SECURITY,K.CUSTOMER.SECURITY
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.CUSTOMER.SECURITY.9003')
********
* END
********
   END
