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
    $PACKAGE AM.Group
    SUBROUTINE CONV.AM.VEH.GRP.YYYYMM.G15

    $INSERT I_COMMON
    $INSERT I_EQUATE

    SOURCE.FILE = 'F.AM.VEH.GRP'
    DEST.FILE = 'F.AM.VEH.GRP'
    ERR.CODE = ''
    CALL AM.COPY.VEH.YYYYMM(SOURCE.FILE,DEST.FILE,ERR.CODE)

  RETURN
*=======================================================
  END
