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
    $PACKAGE SC.ScvValuationUpdates
      SUBROUTINE CONV.SEC.TRADES.TODAY.G11.0.00
*-----------------------------------------------------------------------------
* Reformat SEC.TRADES.TODAY file from multi-line records containing
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
         REMOVE SEC.TRADES.TODAY.ID FROM STT.ID.LIST SETTING POS
      WHILE SEC.TRADES.TODAY.ID : POS
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
      FN.SEC.TRADES.TODAY = "F.SEC.TRADES.TODAY"
      F.SEC.TRADES.TODAY = ""
      CALL OPF(FN.SEC.TRADES.TODAY,F.SEC.TRADES.TODAY)
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
      CMD = "SELECT " : FN.SEC.TRADES.TODAY
      CMD := " WITH @ID UNLIKE ...*..."
      CALL EB.READLIST(CMD,STT.ID.LIST,"","","")
      RETURN
*
*-----------------------------------------------------------------------------
*
PROCESS.RECORD:
*
* Use READU and WRITE to avoid JOURNAL issues
*
      R.SEC.TRADES.TODAY = ""
      ERRFLAG = ""
      READU R.SEC.TRADES.TODAY FROM F.SEC.TRADES.TODAY,SEC.TRADES.TODAY.ID ELSE
         R.SEC.TRADES.TODAY = ""
      END

      NO.OF.FIELDS = DCOUNT(R.SEC.TRADES.TODAY,FM)
      FOR FCNT = 1 TO NO.OF.FIELDS
         TRANS.ID = R.SEC.TRADES.TODAY<FCNT>
         NEW.STT.ID = SEC.TRADES.TODAY.ID:"*":TRANS.ID
         NEW.STT.REC = TRANS.ID
         WRITE NEW.STT.REC ON F.SEC.TRADES.TODAY,NEW.STT.ID
      NEXT FCNT
*
* Remove old record
*
      DELETE F.SEC.TRADES.TODAY,SEC.TRADES.TODAY.ID
*
*
      RETURN
*
*-----------------------------------------------------------------------------
*

   END
