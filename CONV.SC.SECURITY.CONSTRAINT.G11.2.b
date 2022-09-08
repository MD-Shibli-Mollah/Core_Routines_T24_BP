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
* <Rating>167</Rating>
*-----------------------------------------------------------------------------
* Version 2 16/02/01  GLOBUS Release No. 200508 30/06/05
*
    $PACKAGE SC.SctConstraints
      SUBROUTINE CONV.SC.SECURITY.CONSTRAINT.G11.2
*
**********************************************************************
*
* 14/02/01 - GB0100319
*            Conversion routine to convert SC.SECURITY.CONSTRAINT
*            from INT file type to FIN file type
*
**********************************************************************
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.FILE.CONTROL
**********************************************************************
*
      GOSUB INITIALISATION
*
      IF FTYPE <> 'INT' AND FTYPE <> '' THEN
         GOSUB PROCESS.INT.FILE
      END
      RETURN
*
*
INITIALISATION:
*
*      F.CONTROL = ''
*      FN.CONTROL = 'F.FILE.CONTROL'
      FTYPE = ''
      CALL DBR('FILE.CONTROL':FM:EB.FILE.CONTROL.CLASS,'SC.SECURITY.CONSTRAINT',FTYPE)
*
      RETURN
*
PROCESS.INT.FILE:
*
      SUFFIX = ''
      GOSUB CONVERT.INT.FILE
      SUFFIX = '$NAU'
      GOSUB CONVERT.INT.FILE
      SUFFIX = '$HIS'
      GOSUB CONVERT.INT.FILE
      RETURN
*
*
CONVERT.INT.FILE:
*
      F.CONSTRAINT = ''
      FN.CONSTRAINT = ''
      FN.CONSTRAINT<1> = 'F.SC.SECURITY.CONSTRAINT':SUFFIX
      FN.CONSTRAINT<2> = 'NO.FATAL.ERROR'
      CALL OPF(FN.CONSTRAINT,F.CONSTRAINT)
      F.INT.FILE = ''
      INT.FILE= 'F.SC.SECURITY.CONSTRAINT':SUFFIX
      OPEN '',INT.FILE TO F.INT.FILE THEN
         SELECT.STATEMENT = 'SSELECT F.SC.SECURITY.CONSTRAINT':SUFFIX
         CALL EB.READLIST(SELECT.STATEMENT,REC.LIST,'','','')
         IF REC.LIST THEN
            LOOP
               REMOVE ID.LIST FROM REC.LIST SETTING MORE
            WHILE ID.LIST DO
               READ R.REC FROM F.INT.FILE, ID.LIST ELSE R.REC = ''
               IF R.REC THEN
                  CALL F.WRITE(FN.CONSTRAINT, ID.LIST,R.REC)
                  CALL JOURNAL.UPDATE('SC.SECURITY.CONSTRAINT')
               END
            REPEAT
         END
      END
*
*
      RETURN
   END
