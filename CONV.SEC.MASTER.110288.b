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

* Version 3 16/05/01  GLOBUS Release No. 200508 29/07/05
*-----------------------------------------------------------------------------
* <Rating>230</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityMasterMaintenance
      SUBROUTINE CONV.SEC.MASTER.110288
*************************************************************************
*
$INSERT I_EQUATE
$INSERT I_COMMON
$INSERT I_SCREEN.VARIABLES
$INSERT I_F.SECURITY.MASTER
*
*-----------------------------------------------------------------------
*
*    Subroutine - to convert the security master record
*      convertion is due to introduction of a new concat file -
*      SC.TELEKURS.CODE  ,which is essential for TELEKURS interface
*      for XT module .
*      Concat file is attached to the SWISS.CODE filed in the
*      security master  & the program creates the concat file entry if
*      and only if the security is a base security , i.e
*      if the filed after '-' in the security id is '000'
*
*      DATE  = 11th FEBRAUARY 1988
*
*  THIS PROGRAM IS TO BE RUN IMMEDIATELY AFTER THE INSTALLATION OF THE
*   NEW SECURITY MASTER PROGRAM WITH THE CONCAT FILE DEFINITION
*
*------------------------------------------------------------------------
*
*
MAIN.PGM:
      F.SECURITY.MASTER = '' ; F.SC.TELEKURS.CODE = ''
      SEC.REC = '' ; REC.TELE = '' ; V$KEY = '' ; TELE.CODE = ''
*
      CALL OPF('F.SECURITY.MASTER',F.SECURITY.MASTER)
      CALL OPF('F.SC.TELEKURS.CODE',F.SC.TELEKURS.CODE)
*
      SELECT F.SECURITY.MASTER
*
      LOOP
         READNEXT V$KEY ELSE V$KEY = ''
      UNTIL NOT(V$KEY) DO
         IF FIELD(V$KEY,'-',2) # '000' THEN GOTO NXT.REC
         PRINT @(0,10):S.CLEAR.EOL:@(5):'Processing - ':V$KEY:
*
         READ SEC.REC FROM F.SECURITY.MASTER, V$KEY ELSE
            PRINT @(0,12):S.CLEAR.EOL:@(5):'SECURITY RECORD FOR THE KEY = ':V$KEY:' NOT FOUND':
         END
         TELE.CODE = FMT(FIELD(V$KEY,'-',1):'0','10"0"R')
         IF NOT(SEC.REC<SC.SCM.SWISS.NO>) THEN
            SEC.REC<SC.SCM.SWISS.NO> = TELE.CODE
            WRITE SEC.REC TO F.SECURITY.MASTER , V$KEY
*
            WRITE V$KEY TO F.SC.TELEKURS.CODE , TELE.CODE
         END
*
NXT.REC:
      REPEAT
*
      PRINT @(0,12):S.CLEAR.EOL:
      PRINT @(0,10):S.CLEAR.EOL:@(5):'Conversion over , press <CR> ': ; INPUT NL:
      RETURN
*
   END
