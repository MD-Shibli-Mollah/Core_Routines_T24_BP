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
* <Rating>-37</Rating>
*-----------------------------------------------------------------------------
* Version n dd/mm/yy  GLOBUS Release No. 200511 31/10/05
*
    $PACKAGE AM.Valuation
      SUBROUTINE CONV.AM.VAL.PARAMETER.200603(AM.VAL.PARAMETER.ID,R.AM.VAL.PARAMETER,FN.AM.VAL.PARAMETER)
*-----------------------------------------------------------------------------
* Template record routine, to be used as a basis for building a RECORD.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
*
* Convert AM.VAL.PARAMETER to clear all but first subvalues of drilldown
* information as this is being rationalised so that:
*     First subvalue relates to VIEW function
*     Second subvalue relates to EDIT function
*     Third subvalue relates to NEW function
*     Fourth subvalue relates to EDIT PRICE function
*     Fifth subvalue relates to CONTRACT DEFINITION (see) function
*
* Therefore necessary to convert drilldowns such that first subvalue relates
* to see mode.  Other suvalues cleared and should be set up manually.
*-----------------------------------------------------------------------------
* Modification History:
*
* 11/02/2008 - BG_100017064
*              Stop attempted write to AM.VAL.PARAMETER$NAU$HIS for unauthorised files.
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

      IF FN.AM.VAL.PARAMETER[-4,4] # "$HIS" THEN

         GOSUB S100.INITIALISATION

         GOSUB S200.WRITE.HISTORY.REC

         GOSUB S300.CONVERSION.PROCESSING

      END

      RETURN

*-----------------------------------------------------------------------------
S100.INITIALISATION:

      E = '' ; * Clear error flag otherwise it won't write anything

* Set field numbers to positions manually, instead of using $INSERT

      GRP.CODE = 9

      MNEMONIC = 13
      DD.LABEL = 14
      ENQ.VER.ID = 15
      AVAILABLE = 16
      VER.FUNCTION = 17
      DD.ID.FIELD = 18

      DIM R.DIM.AM.VAL.PARAMETER(C$SYSDIM)

      RETURN

*-----------------------------------------------------------------------------
S200.WRITE.HISTORY.REC:

* Write history record for authorised records only.
      IF FN.AM.VAL.PARAMETER[-4,4] NE "$NAU" THEN
         MATPARSE R.DIM.AM.VAL.PARAMETER FROM R.AM.VAL.PARAMETER
         CALL EB.HIST.REC.WRITE(FN.AM.VAL.PARAMETER,AM.VAL.PARAMETER.ID,MAT R.DIM.AM.VAL.PARAMETER,C$SYSDIM)
      END

      RETURN

*-----------------------------------------------------------------------------
S300.CONVERSION.PROCESSING:

      NUM.GROUPS = DCOUNT(R.AM.VAL.PARAMETER<GRP.CODE>,VM)

      FOR GROUP.SET = 1 TO NUM.GROUPS ; * For each group code multivalue set

         FOR CLEANUP.FIELD = MNEMONIC TO DD.ID.FIELD ; * Remove all but first value

            IF CLEANUP.FIELD = VER.FUNCTION THEN ; * This is always SEE
               R.AM.VAL.PARAMETER<CLEANUP.FIELD,GROUP.SET> = "S"
            END ELSE ; * Take value of old first subvalue
               NEW.DATA = R.AM.VAL.PARAMETER<CLEANUP.FIELD,GROUP.SET,1>
               R.AM.VAL.PARAMETER<CLEANUP.FIELD,GROUP.SET> = NEW.DATA
            END

         NEXT CLEANUP.FIELD

      NEXT GROUP.SET

      RETURN

*-----------------------------------------------------------------------------
   END
