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

*
*-----------------------------------------------------------------------------
* <Rating>-68</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Foundation
      SUBROUTINE CONV.DX.EVENT.TYPE.R08(DX.EVENT.TYPE.ID,R.DX.EVENT.TYPE,FN.DX.EVENT.TYPE)
*-----------------------------------------------------------------------------
* This routine copies the records with the key commencing 'XO' to a new key
* separating following characters with delimiter '-'

*-----------------------------------------------------------------------------
* Modification History:
*
* 13/11/07 - BG_100015747 - aleggett@temenos.com
*            Created
*
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

      GOSUB EQUATE.FIELD.POSITIONS

      recordIdChange = @FALSE
      
      GOSUB CHECK.REC.ID.CHANGE
      
      IF recordIdChange THEN
         GOSUB OPEN.FILES ; * no need to do this unless we are doing any IO.
         GOSUB DELETE.OLD.REC.ID
         GOSUB CHANGE.NEW.REC.ID
      END

      RETURN

*-----------------------------------------------------------------------------
EQUATE.FIELD.POSITIONS:

* Equate the field positions - don't use inserts

      EQU recordStatusPos TO 18
      EQU currNoPos TO 19
      EQU inputterPos TO 20
      EQU dateTimePos TO 21
      EQU authoriserPos TO 22
      
      RETURN

*-----------------------------------------------------------------------------
CHECK.REC.ID.CHANGE:

* Check whether we are changing the record id

      eventCode = DX.EVENT.TYPE.ID     
      
      GOSUB MODIFY.EVENT.CODE
      
      IF eventCode NE DX.EVENT.TYPE.ID THEN
         recordIdChange = @TRUE
      END

      RETURN

*-----------------------------------------------------------------------------
OPEN.FILES:

* Open the file .

      F.DX.EVENT.TYPE = '' ; * FN.DX.EVENT.TYPE already passed in.
      CALL OPF(FN.DX.EVENT.TYPE,F.DX.EVENT.TYPE)
      
      RETURN
      
*-----------------------------------------------------------------------------
DELETE.OLD.REC.ID:

* Delete the record from the old id

      DELETE F.DX.EVENT.TYPE,DX.EVENT.TYPE.ID
      
      RETURN
      
*-----------------------------------------------------------------------------
CHANGE.NEW.REC.ID:

* Change the record id to the new id

      DX.EVENT.TYPE.ID = eventCode
      
      RETURN

*-----------------------------------------------------------------------------
MODIFY.EVENT.CODE:

* If the event code starts with XO then delimit from the remainder with a dash.

      eventCode.length = LEN(eventCode)
      eventCode.main = eventCode[1,2]
      eventCode.suffix.length = eventCode.length-2

      IF eventCode.main = 'XO' AND eventCode.suffix.length THEN
         delimiter = '-'
         eventCode.suffix = eventCode[3,eventCode.suffix.length]
         IF eventCode.suffix[1,1] NE delimiter AND eventCode.suffix[1,1] NE ';' THEN
            eventCode = eventCode.main:delimiter:eventCode.suffix
         END
      END

      RETURN

*-----------------------------------------------------------------------------
   END
