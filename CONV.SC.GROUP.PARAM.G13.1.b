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
    $PACKAGE SC.SctOrderGrouping
      SUBROUTINE CONV.SC.GROUP.PARAM.G13.1(YID,YREC,YFILE)
*---------------------------------------
* routine will be run as the RECORD.ROUTINE from CONVERSION.DETAILS>CONV.SC.GROUP.PARAM.G13.1
* it will add the new SYS.FIELD CUM.EX.IND to all records.
* the SYSTEM record should have been released as a record and will already contain CUM.EX.IND,
* however we don't need to exclude it programatically.

      LOCATE "CUM.EX.IND" IN YREC<1,1> SETTING YPOS ELSE
         YREC<1,-1> = "CUM.EX.IND"
      END

      RETURN

   END
