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
* <Rating>-40</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Logging
      SUBROUTINE CONV.TEC.ITEMS.R07(YID,YREC,YFILE)

* This is the record rotuine for the conversion CONV.TEC.ITEMS.R07
* Purpose of this routine is to populate value to the new field 
* RAISE.EVENT in TEC.ITEMS from TEC.THRESHOLD.
*-----------------------------------------------------------------------------
* Modification History :
* -------------
* 27/09/06 - EN_10003086
*            Creation
*            Ref: SAR-2005-08-18-0008
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

      COM/CONV.TEC.ITEMS.R07/TEC$THRESHOLD.ID, TEC$THRESHOLD.REC,FN$TEC.THRESHOLD,F$TEC.THRESHOLD


      GOSUB INITIALISE
      GOSUB POPULATE
*-----------------------------------------------------------------------------
INITIALISE:

      RETURN
*-----------------------------------------------------------------------------
POPULATE:


      TEC.THRESHOLD.LIST = YREC <4>     ; * list of TEC.THRESHOLDs
      NO.OF.THRESHOLD = DCOUNT(TEC.THRESHOLD.LIST,VM)
      FOR THRESHOLD.CNT = 1 TO NO.OF.THRESHOLD  ; * for every value in the m/v list
         TEC.THRESHOLD.ID = TEC.THRESHOLD.LIST<1,THRESHOLD.CNT>
         IF TEC.THRESHOLD.ID THEN
            LOCATE TEC.THRESHOLD.ID IN TEC$THRESHOLD.ID<1,1> SETTING POS ELSE  ; * if not in cache
               GOSUB READ.THE.REC      ; * go and read the rec
            END
            R.TEC.THRESHOLD = RAISE(TEC$THRESHOLD.REC<POS>)    ; * thw values will be lowered so raise
            IF R.TEC.THRESHOLD<5> ='YES' THEN     ; * if RAISE.EVENT is set 
               YREC<6,THRESHOLD.CNT> = R.TEC.THRESHOLD<5> ; * populate the same in TEC.ITEMS
            END
         END
      NEXT THRESHOLD.CNT
      RETURN

*-----------------------------------------------------------------------------
READ.THE.REC:

      IF NOT(FN$TEC.THRESHOLD) THEN    ; * if not already opened in this session
         FN$TEC.THRESHOLD = 'F.TEC.THRESHOLD'
         F$TEC.THRESHOLD = ''
         OPEN '',FN$TEC.THRESHOLD TO F$TEC.THRESHOLD ELSE   ; * nothing much i can do now
            RETURN
         END
      END

      R.TEC.THRESHOLD = ''
      READ R.TEC.THRESHOLD FROM F$TEC.THRESHOLD, TEC.THRESHOLD.ID THEN  ;* read
         TEC$THRESHOLD.REC<POS> = LOWER(R.TEC.THRESHOLD)    ; * populate the common
      END

      RETURN
*-----------------------------------------------------------------------------
   END
