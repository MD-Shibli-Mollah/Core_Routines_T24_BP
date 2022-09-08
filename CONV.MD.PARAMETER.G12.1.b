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
* <Rating>100</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MD.Foundation
      SUBROUTINE CONV.MD.PARAMETER.G12.1(MD.ID,MD.REC,MD.FILE)

$INSERT I_COMMON
$INSERT I_EQUATE
*******************************************************************


      EQU MD.PAR.INCLUDE.PROVISION TO 21, MD.PAR.PROV.CATEGORY TO 22,
         MD.PAR.TR.PROV.CODE.DR TO 23, MD.PAR.TR.PROV.CODE.CR TO 24,
         MD.PAR.EXPIRY.MODE TO 25, MD.PAR.PART.CSN.ACC TO 26,
         MD.PAR.BACKWARD.DELIVERY TO 27, MD.PAR.MD.CLASS.TYPE TO 28,
         MD.PAR.EB.CLASS.TYPE TO 29, MD.PAR.RESERVED.5 TO 30,
         MD.PAR.RESERVED.4 TO 31, MD.PAR.RESERVED.3 TO 32,
         MD.PAR.RESERVED.2 TO 33, MD.PAR.RESERVED.1 TO 34

      IF FILE.TYPE NE 1 THEN RETURN
*
      MD.REC<MD.PAR.BACKWARD.DELIVERY> = 'YES'
      MD.REC<MD.PAR.INCLUDE.PROVISION> = ''
      MD.REC<MD.PAR.PROV.CATEGORY> = ''
      MD.REC<MD.PAR.TR.PROV.CODE.DR> = ''
      MD.REC<MD.PAR.TR.PROV.CODE.CR> = ''
      MD.REC<MD.PAR.MD.CLASS.TYPE> = ''
      MD.REC<MD.PAR.EB.CLASS.TYPE> = ''
      MD.REC<MD.PAR.EXPIRY.MODE> = 'AUTOMATIC'
      MD.REC<MD.PAR.PART.CSN.ACC> = ''
      MD.REC<MD.PAR.RESERVED.5> = ''
      MD.REC<MD.PAR.RESERVED.4> = ''
      MD.REC<MD.PAR.RESERVED.3> = ''
      MD.REC<MD.PAR.RESERVED.2> = ''
      MD.REC<MD.PAR.RESERVED.1> = ''
*
      RETURN
************************************************************************
   END
