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

* Version 1 16/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>142</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RP.Contract
      SUBROUTINE CONV.REPO.POSITION.SUB
*
*
*********************************************************
*
* This is a conversion program run by CONVERSION.DETAILS
* program CONV.REPO.POSITION.
* This program converts the ID of all the existing
* REPO.POSITION records to include the SUB.ACCOUNT in
* the key of the REPO.POSITION record.
* Update REPO.POS.CONCAT concat file
*
* author : P.LABE
*
*********************************************************
*
*
* 21/09/02 - EN_10001189
*            Conversion of error messages to error codes.

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.REPO.POSITION


      EQU TRUE TO 1, FALSE TO 0

*====================================================
* Main controlling section
*====================================================

      GOSUB OPEN.FILES
*
* Select list
*
      RP.LIST = ''
      SELECT.RP = 'SSELECT ':FN.REPO.POSITION
      CALL EB.READLIST(SELECT.RP,RP.LIST,'','','')
      IF NOT(RP.LIST) THEN
         E ='RP.RTN.NO.LIST'
         RETURN
      END
*
* Main loop (process REPO.POSITION keys and use it to convert
*            REPO.POS.CONCAT)
*
      LOOP
         REMOVE RP.CODE FROM RP.LIST SETTING MORE
*
      WHILE RP.CODE DO
*
         CALL F.READU(FN.REPO.POSITION,RP.CODE,R.REPO.POSITION,F.REPO.POSITION,ER,'R 05 12')
         IF ER THEN
            E = 'RP.RTN.REC.NOT.FOUND.ON.FILE.F.REPO.POSITION':FM:RP.CODE:VM:'F.REPO.POSITION'
            GOTO FATAL.ERROR
         END

         RP.CODE.NEW = RP.CODE:'.'       ; *add '.' (dot) to the key

         CALL F.WRITE(FN.REPO.POSITION,RP.CODE.NEW,R.REPO.POSITION)    ; *write the new key
         CALL F.DELETE(FN.REPO.POSITION,RP.CODE)   ; *delete the old one

* Process REPO.POS.CONCAT file

         CALL F.READU(FN.REPO.POS.CONCAT,RP.CODE,R.REPO.POS.CONCAT,F.REPO.POS.CONCAT,ER,'R 05 12')
         IF ER THEN
            E = 'RP.RTN.REC.NOT.FOUND.ON.FILE.F.REPO.POS.CONCAT':FM:RP.CODE:VM:'F.REPO.POS.CONCAT'
            GOTO FATAL.ERROR
         END
         CALL F.WRITE(FN.REPO.POS.CONCAT,RP.CODE.NEW,R.REPO.POS.CONCAT)
         CALL F.DELETE(FN.REPO.POS.CONCAT,RP.CODE)
*
         CALL JOURNAL.UPDATE(RP.CODE.NEW)
*
      REPEAT
*
      RETURN

*****************************************************************
OPEN.FILES:
*****************************************************************

*
      FN.REPO.POSITION = 'F.REPO.POSITION'
      F.REPO.POSITION = ''
      CALL OPF(FN.REPO.POSITION,F.REPO.POSITION)
*
      FN.REPO.POS.CONCAT = 'F.REPO.POS.CONCAT'
      F.REPO.POS.CONCAT = ''
      CALL OPF(FN.REPO.POS.CONCAT,F.REPO.POS.CONCAT)
*
      RETURN

******************************************************************
******************************************************************

FATAL.ERROR:

      TEXT = E
      CALL FATAL.ERROR('CONV.REPO.POSITION.SUB')


   END
