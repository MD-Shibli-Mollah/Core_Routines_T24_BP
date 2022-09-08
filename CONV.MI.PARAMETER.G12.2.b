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
* <Rating>198</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MI.Entries
      SUBROUTINE CONV.MI.PARAMETER.G12.2(ID,REC,FILE)
*******************************************************
* This Routine populates values into ENTRY.TYPE.DR and
* ENTRY.TYPE.CR in MI.PARAMETER, if their values are
* null. Once it is populated the routine updates the
* concat file ENTRY.TYPE.CONCAT with these values to
* avoid duplication
* 26/02/2002 - GLOBUS_EN_10000399
*
*13/02/2002 - GLOBUS_BG_100000705
*Used WRITE instead of F.WRITE
*
*******************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.MI.ENTRY.TYPE
*
* DO the conversion only for Live and NAU File
      IF (INDEX(FILE,'$HIS',1)) THEN RETURN
      IF (INDEX(FILE,'$NAU',1)) THEN RETURN
      FN.ENTRY.TYPE.CONCAT = 'F.ENTRY.TYPE.CONCAT'
*INIT
      F.ENTRY.TYPE.CONCAT = ''
      CALL OPF(FN.ENTRY.TYPE.CONCAT,F.ENTRY.TYPE.CONCAT)
      IF REC<18> ELSE
         REC<18> = 'COFC'
      END
      WRITE 'COST OF FUNDS CR' ON F.ENTRY.TYPE.CONCAT,REC<18>    ; * BG_100000705 S/E
      IF REC<19> ELSE
         REC<19> = 'COFD'
      END
      WRITE 'COST OF FUNDS DR' ON F.ENTRY.TYPE.CONCAT,REC<19>     ; * BG_100000705 S/E
   END
