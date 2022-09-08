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

* Version 1 12/11/92  GLOBUS Release No. 11.2.0 13/11/92
*-----------------------------------------------------------------------------
* <Rating>146</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DC.Contract
      SUBROUTINE CONV.ENTRY.HOLD.11.2.0
*
* Subroutine to convert DC entry hold records to @VM instead of @FM.
* New format introduced for EB.ACCOUNTING.
*
*-----------------------------------------------------------------------
*
      PRINT @(1,7):
      F.ENTRY.HOLD.NAME = "F.ENTRY.HOLD"
      CALL OPF(F.ENTRY.HOLD.NAME,F.ENTRY.HOLD)
      CONVERTED = 0
      CNT = 0
*
      EXECUTE "SELECT ": F.ENTRY.HOLD.NAME: " WITH @ID LIKE DC..."
*
      LOOP READNEXT ID ELSE ID = "" WHILE ID
         CNT +=1
         PRINT @(5,5): "PROCESSED ": FMT(CNT,"5'0'R"):
         READ R.ENTRY.HOLD FROM F.ENTRY.HOLD, ID ELSE
            GOTO NEXT.ID
         END
         FIELD.COUNT = DCOUNT(R.ENTRY.HOLD,@FM)
         IF FIELD.COUNT > 2 THEN        ;* Old format
            BAL.MKR = R.ENTRY.HOLD<FIELD.COUNT>   ;* Last field
            DEL R.ENTRY.HOLD<FIELD.COUNT>         ;* Delete it
            R.ENTRY.HOLD = LOWER(R.ENTRY.HOLD)    ;* @fm to @vm
            R.ENTRY.HOLD<2> = BAL.MKR
            WRITE R.ENTRY.HOLD TO F.ENTRY.HOLD, ID
            CONVERTED +=1
            PRINT @(5,6): "CONVERTED ": FMT(CONVERTED,"5'0'R"):
         END
NEXT.ID: 
      REPEAT
*
      TEXT = "CONVERSION COMPLETE"
      CALL REM
*
      RETURN
*
*------------------------------------------------------------------------
   END
