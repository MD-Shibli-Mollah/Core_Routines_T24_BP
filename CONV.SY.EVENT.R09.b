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
* <Rating>-51</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SY.Event
      SUBROUTINE CONV.SY.EVENT.R09(SY.EVENT.ID,R.SY.EVENT,FN.SY.EVENT)
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc> </desc>
* This routine amends the field COB.PHASE where it contains the value
* 'End of Day' to the value 'Close of Business' as this is in line with T24/
* Temenos Nomenclature.
* 
*
*
* Note that this conversion will run for SY.EVENT.DEFINITION, SY.EVENT and
* SY.EVENT.LOG.
*
* Field numbers are (as of 200810.2):
*
*     COB.PHASE = 14
*
*
* N.B. if these have changed, please change them in EQUATE.FIELDS section.
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc> </desc>
*-----------------------------------------------------------------------------
* Modification History:
*-----------------------------------------------------------------------------
*
* 26/09/08 - BG_100020155 - aleggett@temenos.com
*            Created as part of record conversion for SY.EVENT (ref TTS0803583)
*
* 08/09/08 - EN_10003870 - aleggett@temenos.com
*            Placement of field COB.PHASE moved from 14 to 24 due to insertion
*            of reserved fields (ref SAR-2008-07-23-0003).
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>
$INSERT I_COMMON
$INSERT I_EQUATE

*** </region>

      GOSUB EQUATE.FIELDS
      GOSUB CLEAR.FIELDS
      GOSUB CONVERT.FIELDS

      RETURN
*-----------------------------------------------------------------------------
*** <region name= EQUATE.FIELDS>
*** <desc>Set local field equates here as this is a conversion.</desc>
EQUATE.FIELDS:

      EQUATE COB.PHASE TO 24
   
      RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= CLEAR.FIELDS>
*** <desc>Clear the obsolete fields.</desc>
CLEAR.FIELDS:

* Nothing to do

      RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= CONVERT.FIELDS>
*** <desc>Convert field values as applicable.</desc>
CONVERT.FIELDS:

* Change field content from [End of Day] to [Close of Business]...

      changeFrom = 'End of Day'
      changeTo = 'Close of Business'

* ...for field [COB.PHASE]

      fieldNo = COB.PHASE
      GOSUB changeField

      RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= changeField>
*** <desc>Change field value from one value to another</desc>
changeField:

     IF R.SY.EVENT<fieldNo> = changeFrom THEN
        R.SY.EVENT<fieldNo> = changeTo
     END

     RETURN

*** </region>
*-----------------------------------------------------------------------------
   END
