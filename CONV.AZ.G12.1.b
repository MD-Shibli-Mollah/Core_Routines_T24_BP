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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.Contract
      SUBROUTINE CONV.AZ.G12.1(AZ.ID,R.AZ.ACCOUNT,FV.AZ)

* This is the conversion routine to convert all the I scheudle
* dates as a combination of I and N schedule .
$INSERT I_COMMON
$INSERT I_EQUATE

      EQU AZ.TYPE.OF.SCHDLE TO 39
      NO.SCH = DCOUNT(R.AZ.ACCOUNT<AZ.TYPE.OF.SCHDLE>,VM)
      FOR NO.REP = 1 TO NO.SCH
         IF R.AZ.ACCOUNT<AZ.TYPE.OF.SCHDLE,NO.REP> = 'I' THEN
            R.AZ.ACCOUNT<AZ.TYPE.OF.SCHDLE,NO.REP> = 'IN'
         END
      NEXT NO.REP
      RETURN
   END
