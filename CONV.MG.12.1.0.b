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
* <Rating>707</Rating>
*-----------------------------------------------------------------------------
* Version 7 15/05/01  GLOBUS Release No. 200511 31/10/05
*
* Modifications...
* 27/03/00 - GB0000601
*            jBASE changes.
*            Jbase expects the key words in the commands to be in UPPER case.
*            The key word PRINT must be in capitals.
****************************************************************************
*
    $PACKAGE MG.Contract
      SUBROUTINE CONV.MG.12.1.0
*
****************************************************************************
*
* This program will convert the mortgage files MG.MORTGAGE, MG.BALANCES,
* MG.BALNCES.HIST, MG.PAYMENT, MG.RATE.CONTROL, and MG.INTEREST.KEY.
* It will add the new currency fields and populate them with the local currency.
*
****************************************************************************
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
*
****************************************************************************
*
      GOSUB VERIFY

      IF CONT THEN

         GOSUB INITIALISE

         FILE.NAME = 'F.MG.MORTGAGE'
         V$FIELD = 4 ; V$FIELD<1,3> = LCCY
         V$FIELD<2> = 57 ; V$FIELD<2,3> = LCCY
         V$FIELD<2,2> = 56
         V$FIELD<3> = 14 ; V$FIELD<3,3> = 'A'
         CHECK.FIELD = 81
         GOSUB DO.FILES

         FILE.NAME = 'F.MG.BALANCES'
         V$FIELD = 3 ; V$FIELD<1,3> = LCCY
         V$FIELD<1,2> = 4
         CHECK.FIELD = 'BALANCES'
         GOSUB DO.FILES

         FILE.NAME = 'F.MG.BALANCES.HIST'
         V$FIELD = 3 ; V$FIELD<1,3> = LCCY
         V$FIELD<1,2> = 4
         CHECK.FIELD = 'BALANCES'
         GOSUB DO.FILES

         FILE.NAME = 'F.MG.BALANCES.SAVE'
         V$FIELD = 3 ; V$FIELD<1,3> = LCCY
         V$FIELD<1,2> = 4
         CHECK.FIELD = 'BALANCES'
         GOSUB DO.FILES

         FILE.NAME = 'F.MG.PAYMENT'
         V$FIELD = 11 ; V$FIELD<1,3> = LCCY
         V$FIELD<1,2> = 10
         CHECK.FIELD = 25
         GOSUB DO.FILES


         FILE.NAME = 'F.MG.RATE.CONTROL'
         GOSUB DO.CONCAT.FILES

         FILE.NAME = 'F.MG.INTEREST.KEY'
         GOSUB DO.CONCAT.FILES

      END

      RETURN
*
****************************************************************************
*
VERIFY:
*
      PRINT @(10,7):'This program will convert the MORTGAGE files and add'
      PRINT @(10,8):'currency fields'    ; * GB0000601
      PRINT @(15,10):' Continue Y/N : ':
      INPUT CONT
      IF CONT EQ 'Y' THEN
         CONT = 1
      END ELSE
         CONT = ''
      END

      RETURN
*
****************************************************************************
*
INITIALISE:
*
      RETURN
*
****************************************************************************
*
DO.FILES:
*
      EXT = '' ; NO.MORE = '' ; TEXT = ''

      LOOP UNTIL NO.MORE OR TEXT = 'NO'
         GOSUB MODIFY.FILE
         BEGIN CASE
            CASE EXT EQ '' ; EXT = '$NAU'
            CASE EXT EQ '$NAU' ; EXT = '$HIS'
            CASE EXT EQ '$HIS' ; NO.MORE = 1
         END CASE
      REPEAT

      RETURN
*
****************************************************************************
*
DO.CONCAT.FILES:
*
      F.FILE = ''
      CALL OPF(FILE.NAME,F.FILE)

      SELECT F.FILE

      LOOP
         READNEXT ID ELSE ID = ''
      WHILE ID
         IF NUM(ID) THEN
            NEW.ID = ID:LCCY
            READ REC FROM F.FILE,ID THEN
               DELETE F.FILE, ID
               WRITE REC TO F.FILE, NEW.ID
            END
         END
      REPEAT

      RETURN
*
****************************************************************************
*
MODIFY.FILE:
*
      FILE = FILE.NAME:EXT ; F.FILE = ''
      CALL OPF(FILE:FM:'NO.FATAL.ERROR',F.FILE)

      IF NOT(ETEXT) THEN

         SELECT F.FILE

         LOOP
            READNEXT ID ELSE ID = ''
         WHILE ID
            READ REC FROM F.FILE,ID ELSE NULL
            IF CHECK.FIELD EQ 'BALANCES' THEN
               IF NOT(NUM(REC<3,1>)) THEN
                  GOTO NEXT.REC
               END
            END ELSE
               IF REC<CHECK.FIELD> EQ ID.COMPANY THEN
                  GOTO NEXT.REC
               END
            END
            X = 0
            LOOP
               X += 1
            UNTIL V$FIELD<X> EQ ''
               POS = V$FIELD<X,1>        ; * Position to modify
               NOS = V$FIELD<X,2>        ; * Multivalue field grouped with
               DEF = V$FIELD<X,3>        ; * Value to place in new position
               REC = INSERT(REC,POS,0,0,'')
               IF EXT NE '$HIS' THEN
                  IF NOS THEN
                     CNT = DCOUNT(REC<NOS>,VM)
                     FOR I = 1 TO CNT
                        REC<POS,I> = DEF
                     NEXT I
                  END ELSE
                     REC<POS> = DEF
                  END
               END
            REPEAT
            WRITE REC TO F.FILE, ID
NEXT.REC:
         REPEAT

      END

      RETURN
*
****************************************************************************
*
   END
*
****************************************************************************
*
