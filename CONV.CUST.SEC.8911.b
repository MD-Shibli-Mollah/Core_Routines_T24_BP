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
    $PACKAGE SC.Config
      SUBROUTINE CONV.CUST.SEC.8911
*
*     Last updated by dev.run (dev) at 10:44:14 on 09/08/79
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING CUSTOMER.SECURITY RECORDS.
* ALSO ADD NEW FIELDS :-
*  1 XX.SEC.ACC.DEF
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING CUSTOMER.SECURITY RECORDS ......PLEASE WAIT'
      F.CUSTOMER.SECURITY = ''
      YFILE.NAME1 = 'F.CUSTOMER.SECURITY'
      CALL OPF(YFILE.NAME1,F.CUSTOMER.SECURITY)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.CUSTOMER.SECURITY$NAU'
      CALL OPF(YFILE.NAME2,F.CUSTOMER.SECURITY)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.CUSTOMER.SECURITY$HIS'
      CALL OPF(YFILE.NAME3,F.CUSTOMER.SECURITY)
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
            E = 'OPEN ORDER "':K.CUSTOMER.SECURITY:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.CUSTOMER.SECURITY,FM) + (R.CUSTOMER.SECURITY # '')
*
         IF NO.OF.FIELDS < 23 THEN
            INS '' BEFORE R.CUSTOMER.SECURITY<13>
         END
*
         WRITE R.CUSTOMER.SECURITY TO F.CUSTOMER.SECURITY,K.CUSTOMER.SECURITY
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.CUST.SEC.8911')
********
* END
********
   END
