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
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Versions
      SUBROUTINE CONV.VERSION.G12.1(VER.ID,VER.REC,VER.FILE)
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.PGM.FILE
$INSERT I_F.USER
***********************************************************************
*MODIFICATIONS
**************
* 16/12/02 - GLOBUS_CI_10005523
*  The Routine is Modified to Build PGM.FILE$NAU
*
* 24/12/02 - GLOBUS_CI_10005919
*            Conversion Routine CONV.VERSION.G12.1 is modified
*            to Update PGM.FILE$NAU Correctly
**********************************************************************
      FN.PGM = 'F.PGM.FILE$NAU'
      FV.PGM = ''
      CALL OPF(FN.PGM,FV.PGM)

      FN.PGM.FILE = 'F.PGM.FILE'
      FV.PGM.FILE = ''
      CALL OPF(FN.PGM.FILE,FV.PGM.FILE)

      VAL.RTN.CNT = DCOUNT(VER.REC<52>,VM)
      FOR I = 1 TO VAL.RTN.CNT
         IF VER.REC<52,I> NE '' THEN
            IF VER.REC<52,I>[1,1] NE '@' THEN
               VER.REC<52,I> = '@':VER.REC<52,I>
            END
         END
         Y.APPLICATION = FIELD(VER.ID,',',1)
         CALL F.READ(FN.PGM.FILE,Y.APPLICATION,R.PGM.REC,FV.PGM.FILE,PGM.FILE.ERR)
         Y.PRODUCT = R.PGM.REC<EB.PGM.PRODUCT>
         Y.PGM.ID = FIELD(VER.REC<52,I>,'@',2)
         CALL F.READ(FN.PGM,Y.PGM.ID,R.PGM,FV.PGM,PGM.ERR)
         IF PGM.ERR THEN
            R.PGM<EB.PGM.TYPE> = 'S'
            R.PGM<EB.PGM.SCREEN.TITLE> = Y.PGM.ID
            R.PGM<EB.PGM.PRODUCT> = Y.PRODUCT
            R.PGM<EB.PGM.APPL.FOR.SUBR> = Y.APPLICATION
            R.PGM<EB.PGM.RECORD.STATUS> = 'INAU'
            R.PGM<EB.PGM.CURR.NO> = 1
            R.PGM<EB.PGM.INPUTTER> = TNO:"_":OPERATOR
            X = OCONV(DATE(),"D-")
            X = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
            R.PGM<EB.PGM.DATE.TIME> = X
            R.PGM<EB.PGM.CO.CODE> = ID.COMPANY
            R.PGM<EB.PGM.DEPT.CODE> = R.USER<EB.USE.DEPARTMENT.CODE>
            R.PGM<EB.PGM.AUDITOR.CODE> = ''
            R.PGM<EB.PGM.AUDIT.DATE.TIME> = ''
         END ELSE                        ; * GLOBUS_CI_10005919  /S
            LOCATE Y.APPLICATION IN R.PGM<EB.PGM.APPL.FOR.SUBR,1> SETTING RTN.POS ELSE
               R.PGM<EB.PGM.APPL.FOR.SUBR,-1> = Y.APPLICATION
            END
*    GLOBUS_CI_10005919 /E
         END
         CALL F.WRITE(FN.PGM,Y.PGM.ID,R.PGM)
         CALL JOURNAL.UPDATE(Y.PGM.ID)
      NEXT I
   END
