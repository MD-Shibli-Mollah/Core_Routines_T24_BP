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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityMasterMaintenance
      SUBROUTINE CONV.ALTERNATE.INDEX.200612(YID,YREC,YFILE)
*-----------------------------------------------------------------------------
* Correction/conversion routine for ALTERNATE.INDEX
* the data in this record was wrong and is corrected here.
*-----------------------------------------------------------------------------
* Modification History:
*
* 14/12/06 - GLOBUS_BG_100012595
*            New subroutine
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

* Correct the field name from I.S.I.N to I.S.I.N. to match the correct field
* name in security.master
      LOCATE "I.S.I.N" IN YREC<1,1> SETTING POS ELSE
         POS = 0
      END
      IF POS THEN
         YREC<1,POS> = "I.S.I.N."
      END

      RETURN
*-----------------------------------------------------------------------------
   END
