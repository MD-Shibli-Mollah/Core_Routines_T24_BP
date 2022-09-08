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
    $PACKAGE SC.SctModelling
      SUBROUTINE CONV.POLICY.PARAM.9006
*
**************************************************************
* SUBROUTINE TO CONVERT EXISTING POLICY.PARAMETER RECORDS.
* ALSO ADD NEW FIELDS :-
**  IND FIELDS ADDED
*************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
**************************
      PRINT @(10,10):'CONVERTING POLICY.PARAMETER RECORDS ......PLEASE WAIT'
      F.POLICY.PARAMETER = ''
      YFILE.NAME1 = 'F.POLICY.PARAMETER'
      CALL OPF(YFILE.NAME1,F.POLICY.PARAMETER)
      GOSUB UPDATE.RECORDS               ; * LIVE RECORDS
      YFILE.NAME2 = 'F.POLICY.PARAMETER$NAU'
      CALL OPF(YFILE.NAME2,F.POLICY.PARAMETER)
      GOSUB UPDATE.RECORDS               ; * UNAUTH. RECORDS
      YFILE.NAME3 = 'F.POLICY.PARAMETER$HIS'
      CALL OPF(YFILE.NAME3,F.POLICY.PARAMETER)
      GOSUB UPDATE.RECORDS               ; * HISTORY RECORDS
      RETURN
***************
UPDATE.RECORDS:
***************
*
      SELECT F.POLICY.PARAMETER
      LOOP
         READNEXT K.POLICY.PARAMETER ELSE NULL
      WHILE K.POLICY.PARAMETER DO
         READU R.POLICY.PARAMETER FROM F.POLICY.PARAMETER,K.POLICY.PARAMETER ELSE
            E = 'OPEN ORDER "':K.POLICY.PARAMETER:'" MISING FROM FILE'
            GOTO FATAL.ERR
         END
         NO.OF.FIELDS = COUNT(R.POLICY.PARAMETER,FM) + (R.POLICY.PARAMETER # '')
         IF NO.OF.FIELDS < 16 THEN
            INS '' BEFORE R.POLICY.PARAMETER<5>
            INS '' BEFORE R.POLICY.PARAMETER<6>
            INS '' BEFORE R.POLICY.PARAMETER<7>
         END
         WRITE R.POLICY.PARAMETER TO F.POLICY.PARAMETER,K.POLICY.PARAMETER
      REPEAT
      RETURN
*
************
FATAL.ERR:
************
      TEXT = E
      CALL FATAL.ERROR('CONV.POLICY.PARAM.9006')
********
* END
********
   END
