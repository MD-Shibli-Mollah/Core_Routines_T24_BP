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

* Version 16 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Display
      SUBROUTINE INP (YTEXT,C2,L2,N1,T1)
*=========================================================================
* Routine to prompt for input and validate.
* Determine if we're running GUI and invoke the correct routine.
*
*=========================================================================
$INSERT I_COMMON
$INSERT I_EQUATE
*=========================================================================
*
      IF INDEX(TTYPE,"GUI",1) THEN
         CALL S.INP(YTEXT,N1,T1)
      END ELSE
         CALL T.INP(YTEXT,C2,L2,N1,T1)
      END
*
      RETURN
*
*=========================================================================
   END
