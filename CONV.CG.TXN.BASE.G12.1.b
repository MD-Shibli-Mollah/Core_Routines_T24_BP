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
    $PACKAGE SC.SctCapitalGains
      SUBROUTINE CONV.CG.TXN.BASE.G12.1
*
$INSERT I_COMMON
$INSERT I_EQUATE
*
      YFILE.CONTROL = "F.FILE.CONTROL"
      YFILE = 'CG.TXN.BASE'
      READ Y.FILE.CONTROL FROM F.FILE.CONTROL, YFILE THEN
         IF Y.FILE.CONTROL<3> <> '' THEN
            TEXT = "CONVERSION ALREADY DONE"
         END ELSE
            IF YFILE THEN
               Y.FILE.CONTROL<3,1> = '$NAU'
               Y.FILE.CONTROL<3,2> = '$HIS'
               WRITE Y.FILE.CONTROL TO F.FILE.CONTROL, YFILE
               YERR = ""
               CALL EBS.CREATE.FILE("CG.TXN.BASE", "", YERR)
            END
         END
      END
*
      RETURN
   END
