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

* Version n dd/mm/yy  GLOBUS Release No. G12.1.01 11/12/01
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SccEventCapture
      SUBROUTINE CONV.DIARY.TYPE.G12.2(YID,YREC,YFILE)

* EN_10000325

*This Conversion routine is used default some new fields into DIARY.TYPE

$INSERT I_COMMON
$INSERT I_EQUATE

      YREC<58> = "NO"
      YREC<59> = ""
      YREC<60> = ""
      YREC<61> = ""

      YREC<54> = "NO"
      YREC<55> = ""
      YREC<56> = ""
      YREC<57> = ""

      YREC<62> = "NO"
      YREC<63> = ""
      YREC<64> = ""
      YREC<65> = ""


      IF YREC<51> = "" THEN
         YREC<51> = "YES"
      END

      IF YREC<50> = "" THEN
         YREC<50> = "AUT"
      END

      RETURN
   END
