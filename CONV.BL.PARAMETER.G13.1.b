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
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE BL.Foundation
      SUBROUTINE CONV.BL.PARAMETER.G13.1
$INSERT I_EQUATE
$INSERT I_COMMON
$INSERT I_F.COMPANY
*********************************************************
* Routine to select all the company names and write the
* BL.PARAMETER for all COMPANY. Finally delete the
* SYSTEM record from BL.PARAMETER
* 14/11/02 - BG_100002718
*	      BL.PARAMETER should be copied only if SYSTEM record
*	      NE NULL
* 03/01/03 - GLOBUS_CI_10005981
*            On verifying the RUN.CONVERSION.PGMS BL.PARAMETER records
*            are converted, written but updation is not done.
* 21/03/03 - GLOBUS_BG_100004079
*            Unauthorised BL.PARAMETER unauthorised records are not converted.
*********************************************************

      GOSUB INITALISE
*
      CALL F.READ(FN.BL.PARAMETER,'SYSTEM',BLP.REC,FV.BL.PARAMETER,BL.ERR)
      CALL F.READ(FN.BL.PARAMETER$NAU,'SYSTEM',BLP.REC$NAU,FV.BL.PARAMETER$NAU,BL.ERR$NAU)           ; * BG_100004079 S/E
*
      IF BL.ERR EQ '' THEN
         GOSUB CONVERT.RECORDS
      END

      IF BL.ERR$NAU EQ '' THEN
         BLP.REC = BLP.REC$NAU
         FN.BL.PARAMETER = FN.BL.PARAMETER$NAU
         GOSUB CONVERT.RECORDS
      END                                ; * BG_100004079 E

      IF (BL.ERR EQ '') OR (BL.ERR$NAU EQ '') THEN
         CALL JOURNAL.UPDATE(ID.NEW)     ; * GLOBUS_CI_10005981 S/E
      END

      RETURN

CONVERT.RECORDS:
***************
      SEL.CMD = 'SELECT ' : FN.COMPANY
      CALL EB.READLIST(SEL.CMD,SEL.RECORDS,'',NO.OF.RECS,SYS.RET.CODE)
      FOR NO.I = 1 TO NO.OF.RECS
         BL.PAR.ID = SEL.RECORDS<NO.I>
         COMP.REC = '' ; COMP.ERR = ''   ; * CI_10005981 S
         CALL F.READ(FN.COMPANY,BL.PAR.ID,COMP.REC,FV.COMPANY,COMP.ERR)
         LOCATE 'BL' IN COMP.REC<EB.COM.APPLICATIONS,1> SETTING COMP.POS THEN    ; * CI_10005981 E
            CALL F.WRITE(FN.BL.PARAMETER,BL.PAR.ID,BLP.REC)
         END                             ; * CI_10005981 S/E
      NEXT NO.I
      CALL F.DELETE(FN.BL.PARAMETER,'SYSTEM')
      RETURN

INITALISE:
*********
      FN.COMPANY = 'F.COMPANY'
      FV.COMPANY = ''
      CALL OPF(FN.COMPANY,FV.COMPANY)
      FN.BL.PARAMETER = 'F.BL.PARAMETER'
      FV.BL.PARAMETER = ''
      CALL OPF(FN.BL.PARAMETER,FV.BL.PARAMETER)
*
      FN.BL.PARAMETER$NAU = 'F.BL.PARAMETER$NAU'   ; * BG_100004079 S
      FV.BL.PARAMETER$NAU = ''
      CALL OPF(FN.BL.PARAMETER$NAU,FV.BL.PARAMETER$NAU)      ; * BG_100004079 E
*
      SEL.RECORDS = ''
      NO.OF.RECS = ''
      SYS.RET.CODE = ''
      BL.ERR = ''
      BLP.REC = ''
      BL.ERR$NAU = ''                    ; * BG_100004079 S
      BLP.REC$NAU = ''                   ; * BG_100004079 E
      RETURN
   END
