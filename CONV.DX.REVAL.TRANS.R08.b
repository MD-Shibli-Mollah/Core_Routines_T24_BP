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
* <Rating>-35</Rating>
*-----------------------------------------------------------------------------
*
    $PACKAGE DX.Revaluation
      SUBROUTINE CONV.DX.REVAL.TRANS.R08(DX.REVAL.TRANSACTION.ID,R.DX.REVAL.TRANSACTION,FN.DX.REVAL.TRANSACTION)
*-----------------------------------------------------------------------------
* Template record routine, to be used as a basis for building a RECORD.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
*
* Conversion of DX.REVAL.TRANSACTION
*
* Renames contents of EVENT.TYPE and ACT.EVENT.TYPE fields from
* XOvar TO XO-var where var is the exotic option type.  
* N.B. if event type is XO or begins with other characters, no change is made
* here.
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
      EQU eventFldPosTwo TO 99

      RETURN

*-----------------------------------------------------------------------------
AMEND.FIELD.DATA:

* Change the data in the fields

* Change data for field EVENT.TYPE

      eventCodeList = R.DX.REVAL.TRANSACTION<eventFldPos>
      eventCodeCount = DCOUNT(eventCodeList,VM)

      FOR eventCodeNo = 1 TO eventCodeCount
         eventCode = eventCodeList<1,eventCodeNo>
         GOSUB MODIFY.EVENT.CODE
         R.DX.REVAL.TRANSACTION<eventFldPos,eventCodeNo> = eventCode
      NEXT eventCodeNo

* Change data for field ACT.EVENT.TYPE

      eventCodeList = R.DX.REVAL.TRANSACTION<eventFldPosTwo>
      eventCodeCount = DCOUNT(eventCodeList,VM)

      FOR eventCodeNo = 1 TO eventCodeCount
         eventCode = eventCodeList<1,eventCodeNo>
         GOSUB MODIFY.EVENT.CODE
         R.DX.REVAL.TRANSACTION<eventFldPosTwo,eventCodeNo> = eventCode
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
