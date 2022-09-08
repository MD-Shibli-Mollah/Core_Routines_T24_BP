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
    $PACKAGE EB.SystemTables
      SUBROUTINE CONV.PGM.FILE.G12.2

* Delete EXCEPTION record from PGM.FILE.

$INSERT I_COMMON
$INSERT I_EQUATE

      FN.PGM.FILE = 'F.PGM.FILE'
      F.PGM.FILE = ''
      CALL OPF(FN.PGM.FILE,F.PGM.FILE)

      DELETE F.PGM.FILE, 'EXCEPTION'
      RETURN
   END
