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
* <Rating>400</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MI.Entries
      SUBROUTINE CONV.MI.COF.ENTRIES.G12.2(ID,REC,FILE)
**********************************************************
* This routine populates values into MI.COF.ENTRIES whose MI.ENTRY.
* TYPE is null. If amount is -ve it COFD is populated, if +ve COFC is populated  -   GLOBUS_EN_10000399
**********************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
      IF REC<15> = '' THEN
         IF REC<13> THEN
            IF REC<13> < 0 THEN REC<15> = 'COFD' ELSE REC<15> = 'COFC'
         END ELSE
            IF REC<11> < 0 THEN REC<15> = 'COFD' ELSE REC<15> = 'COFC'
         END
      END
      RETURN
   END
