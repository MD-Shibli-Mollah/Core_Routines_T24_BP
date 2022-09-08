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
* <Rating>-35</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctOrderExecution
      SUBROUTINE CONV.EXECUTED.ORDER.G11.0.00
*-----------------------------------------------------------------------------
* Reformat EXECUTED.ORDER file from multi-line records containing
* transaction ID's keyed by company ID to single-line records keyed by
* company.transaction.
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

      GOSUB INITIALISE

      GOSUB SELECT.RECORDS

      LOOP
         REMOVE EXECUTED.ORDER.ID FROM STT.ID.LIST SETTING POS
      WHILE EXECUTED.ORDER.ID : POS
         GOSUB PROCESS.RECORD
      REPEAT

      RETURN

*
*-----------------------------------------------------------------------------
*

INITIALISE:
*
* Open file
*
      FN.EXECUTED.ORDER = "F.EXECUTED.ORDER"
      F.EXECUTED.ORDER = ""
      CALL OPF(FN.EXECUTED.ORDER,F.EXECUTED.ORDER)
*
      STT.ID.LIST = ""
*
      RETURN

*
*-----------------------------------------------------------------------------
*
SELECT.RECORDS:
*
* Select only old format records (no "." in record ID)
*
      CMD = "SELECT " : FN.EXECUTED.ORDER
      CMD := " WITH @ID UNLIKE ...*..."
      CALL EB.READLIST(CMD,STT.ID.LIST,"","","")
      RETURN
*
*-----------------------------------------------------------------------------
*
PROCESS.RECORD:
*
* Use READU and WRITEU to avoid JOURNAL issues
*
      R.EXECUTED.ORDER = ""
      ERRFLAG = ""
      READU R.EXECUTED.ORDER FROM F.EXECUTED.ORDER,EXECUTED.ORDER.ID ELSE
         R.EXECUTED.ORDER = ""
      END

      NO.OF.FIELDS = DCOUNT(R.EXECUTED.ORDER,FM)
      FOR FCNT = 1 TO NO.OF.FIELDS
         TRANS.ID = R.EXECUTED.ORDER<FCNT>
         NEW.STT.ID = EXECUTED.ORDER.ID:"*":TRANS.ID
         NEW.STT.REC = TRANS.ID
         WRITE NEW.STT.REC ON F.EXECUTED.ORDER,NEW.STT.ID
      NEXT FCNT
*
* Remove old record
*
      DELETE F.EXECUTED.ORDER,EXECUTED.ORDER.ID
*
*
      RETURN
*
*-----------------------------------------------------------------------------
*

   END
