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
* <Rating>-48</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.ModellingScenario
      SUBROUTINE CONV.AM.SCE.SAVED.R7.200708(AM.SCENARIO.SAVED.ID,R.AM.SCENARIO.SAVED,FN.AM.SCENARIO.SAVED)
*-----------------------------------------------------------------------------
* This record routine is used to modify AM.SCENARIO.SAVED to bring it in line
* with AM.SCENARIO now that they share the same field definitions. The two files
* have become out of sync due to enhancements EN_10003324 and EN_10003239.
*
* 18/06/07 - BG_100014241
*            Bring AM.SCENARIO.SAVED into line with AM.SCENARIO as we are now
*            sharing field definitions.
*-----------------------------------------------------------------------------
* Modification History:
*
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

      GOSUB INITIALISE

      IF PROCESS.THIS.RECORD THEN
         GOSUB INSERT.NEW.FIELDS
         GOSUB SET.SESSION.FIELD
         GOSUB SET.VIOLATION.FIELD
      END

*... blat autid fields if present
      AM.SCSVD.OVERRIDE = 69
      R.AM.SCENARIO.SAVED = FIELD(R.AM.SCENARIO.SAVED, @FM,1, AM.SCSVD.OVERRIDE)

      RETURN

*-----------------------------------------------------------------------------
INITIALISE:

      E = '' ; * Clear error flag otherwise it won't write anything

* Set field number to position manually, do no use $INSERT
      AM.SCSVD.SAM.CODE = 4
      ID.SAM.CODE = FIELD(AM.SCENARIO.SAVED.ID, '.', 2)
      REC.SAM.CODE = R.AM.SCENARIO.SAVED<AM.SCSVD.SAM.CODE>

*... Records that have been converted have the Security
*... Account Master code in field 4 so if it is not there we know
*... that it still needs to be converted.
      PROCESS.THIS.RECORD = NOT(ID.SAM.CODE EQ REC.SAM.CODE)

      RETURN

*-----------------------------------------------------------------------------
INSERT.NEW.FIELDS:


      FIELD.NUMBERS = '46 44 37 36 23 22 4 3'
      CONVERT ' ' TO @FM IN FIELD.NUMBERS
      FIELDS.TO.ADD = '3 3 3 3 3 3 3 1'
      CONVERT ' ' TO @FM IN FIELDS.TO.ADD

      NUM.FIELDS = DCOUNT(FIELD.NUMBERS, @FM)
      FOR FLD.NUM = 1 TO NUM.FIELDS
         THIS.FIELD.NUMBER = FIELD.NUMBERS<FLD.NUM>
         NUM.TO.ADD = FIELDS.TO.ADD<FLD.NUM>
         FOR INS.FLD = 1 TO NUM.TO.ADD
            INS '' BEFORE R.AM.SCENARIO.SAVED<THIS.FIELD.NUMBER>
         NEXT INS.FLD
      NEXT FLD.NUM

      RETURN

*-----------------------------------------------------------------------------
SET.SESSION.FIELD:

      AM.SCSVD.SESSION = 3
      SESSION.NUM = FIELD(AM.SCENARIO.SAVED.ID,".",1)

      IF R.AM.SCENARIO.SAVED<AM.SCSVD.SESSION> = "" THEN
         R.AM.SCENARIO.SAVED<AM.SCSVD.SESSION> = SESSION.NUM
      END

      RETURN

*-----------------------------------------------------------------------------
SET.VIOLATION.FIELD:
      AM.SCSVD.SC.VIOLATION = 25
      AM.SCSVD.VIOL.LIST = 26
      SC.VIOLATION.FIELD.CONTENTS = R.AM.SCENARIO.SAVED<AM.SCSVD.SC.VIOLATION>
      VIOL.LIST.FIELD.CONTENTS = ""

      NUM.VALUES = DCOUNT(SC.VIOLATION.FIELD.CONTENTS, @VM)

      FOR THIS.VALUE = 1 TO NUM.VALUES
* Loop through each MULTIVALUE
         NUM.ITEMS = DCOUNT(SC.VIOLATION.FIELD.CONTENTS<1,THIS.VALUE>, " ")
         FOR THIS.ITEM = 1 TO NUM.ITEMS
* Loop through each space delimited list
            VIOL.LIST.FIELD.CONTENTS<1,THIS.VALUE,THIS.ITEM> = FIELD(SC.VIOLATION.FIELD.CONTENTS<1,THIS.VALUE>, " ", THIS.ITEM)
         NEXT THIS.ITEM
      NEXT THIS.VALUE

      R.AM.SCENARIO.SAVED<AM.SCSVD.VIOL.LIST> = VIOL.LIST.FIELD.CONTENTS

      RETURN
*-----------------------------------------------------------------------------

   END
