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

*-----------------------------------------------------------------------------
* <Rating>-33</Rating>
*-----------------------------------------------------------------------------
*
    $PACKAGE DX.Reports
      SUBROUTINE CONV.DX.TXN.ACTIVITY.R08(DX.TXN.ACTIVITY.ID,R.DX.TXN.ACTIVITY,FN.DX.TXN.ACTIVITY)
*-----------------------------------------------------------------------------
* Template record routine, to be used as a basis for building a RECORD.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
*
* Conversion of DX.TXN.ACTIVITY
*
* Renames contents of EVENT field from XOvar TO XO-var where var is the exotic
* option type.  N.B. if event type is XO or begins with other characters, no
* change is made here.
*
*-----------------------------------------------------------------------------
* Modification History:
*
* 13/11/07 - BG_100015747 - aleggett@temenos.com
*            Created
*
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

      GOSUB EQUATE.FIELDS
      GOSUB AMEND.FIELD.DATA

      RETURN
      
*-----------------------------------------------------------------------------
EQUATE.FIELDS:

* Equate field numbers to position manually, do no use $INSERT

      EQU eventFldPos TO 11

      RETURN

*-----------------------------------------------------------------------------
AMEND.FIELD.DATA:

* Change data for field

      eventCodeList = R.DX.TXN.ACTIVITY<eventFldPos>
      eventCodeCount = DCOUNT(eventCodeList,VM)

      FOR eventCodeNo = 1 TO eventCodeCount
         eventCode = eventCodeList<1,eventCodeNo>
         GOSUB MODIFY.EVENT.CODE
         R.DX.TXN.ACTIVITY<eventFldPos,eventCodeNo> = eventCode
      NEXT eventCodeNo

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
         IF eventCode.suffix[1,1] NE delimiter THEN
            eventCode = eventCode.main:delimiter:eventCode.suffix
         END
      END

      RETURN
*-----------------------------------------------------------------------------
   END
