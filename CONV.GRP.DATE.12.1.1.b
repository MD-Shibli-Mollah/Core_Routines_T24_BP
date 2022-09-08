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
* <Rating>19</Rating>
*-----------------------------------------------------------------------------
* Version 3 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*
***************************************************************************
*
    $PACKAGE ST.ChargeConfig
      SUBROUTINE CONV.GRP.DATE.12.1.1
*
***************************************************************************
*
$INSERT I_COMMON
$INSERT I_EQUATE
*
***************************************************************************
*
MAIN:
* 
* Main control
*
      GOSUB VERIFY

      IF CONT THEN

         GOSUB INITIALISE

         GOSUB PROCESS

      END

      RETURN
*
***************************************************************************
*
VERIFY: 
*
      PRINT @(10,7):'This program will convert GROUP.DATE file'
      PRINT @(15,10):' Continue Y/N : ':

      INPUT CONT
      
      IF CONT NE 'Y' THEN
         CONT = ''
      END

      RETURN
*
***************************************************************************
*
INITIALISE:
*
      F.GROUP.DATE.NAME = 'F.GROUP.DATE' ; F.GROUP.DATE = ''
      CALL OPF(F.GROUP.DATE.NAME,F.GROUP.DATE)

      F.GROUP.DEBIT.INT.NAME = 'F.GROUP.DEBIT.INT' ; F.GROUP.DEBIT.INT = ''
      CALL OPF(F.GROUP.DEBIT.INT.NAME,F.GROUP.DEBIT.INT)

      F.GROUP.CREDIT.INT.NAME = 'F.GROUP.CREDIT.INT' ; F.GROUP.CREDIT.INT = ''
      CALL OPF(F.GROUP.CREDIT.INT.NAME,F.GROUP.CREDIT.INT)

      GRP.REC = ''

      RETURN
*
***************************************************************************
*
PROCESS:
*
      EX.STMT     = 'SELECT ':F.GROUP.DATE.NAME
      GRP.LST     = ''
       
      CALL EB.READLIST(EX.STMT.GRP.LST,'','','',RET)

      SELECT F.GROUP.CREDIT.INT
      GOSUB UPDATE.GRP.LST

      SELECT F.GROUP.DEBIT.INT
      GOSUB UPDATE.GRP.LST

      GOSUB WRITE.GRP.DATE.REC

      RETURN
*
***************************************************************************
*
UPDATE.GRP.LST:
*
      LOOP 
         READNEXT ID ELSE ID = ''
      WHILE ID
         GRP.ID = ID[1,LEN(ID)-8]
         LOCATE GRP.ID IN GRP.LST<1> SETTING POS ELSE
            IF GRP.LST THEN
               GRP.LST := FM:GRP.ID
            END ELSE
               GRP.LST  = GRP.ID
            END
         END
      REPEAT
       
      RETURN
*
***************************************************************************
*
WRITE.GRP.DATE.REC:
*
      LOOP 
         REMOVE GRP.ID FROM GRP.LST SETTING DELIM
      WHILE GRP.ID:DELIM
         READ GRP.REC FROM F.GROUP.DATE, GRP.ID ELSE
            WRITE '' TO F.GROUP.DATE, GRP.ID
         END
      REPEAT

      RETURN
*
***************************************************************************
*
   END
