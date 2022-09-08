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
* <Rating>347</Rating>
*-----------------------------------------------------------------------------
* Version 4 29/09/00  GLOBUS Release No. 200508 30/06/05
*
******************************************************************************
*
      $PACKAGE AC.AccountOpening
      SUBROUTINE CONV.AC.12.1.0
*
******************************************************************************
*
* This program will convert the ACCOUNT file for the PM/AC On line link
* changes.  It will insert the new fields
*
******************************************************************************
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.ACCOUNT
*
******************************************************************************
*
      GOSUB VERIFY

      IF CONT THEN

         FILE.NAME = 'F.ACCOUNT'
         CMP.FLD = 110                   ; * Company code field
         V$FIELD = 85                    ; * Position to Add/Del field
         V$FIELD<1,2> = 16               ; * Number of fields to Add/Del
         GOSUB DO.FILES

      END

      RETURN
*
******************************************************************************
*
VERIFY:
*
      PRINT @(10,7):'This program will convert the ACCOUNT file.'
      PRINT @(15,10):' Continue Y/N : ':

      INPUT CONT

      IF CONT NE 'Y' THEN
         CONT = ''
      END

      RETURN
*
******************************************************************************
*
DO.FILES:
*
      EXT = '' ; NO.MORE = '' ; TEXT = ''

      LOOP UNTIL NO.MORE OR TEXT EQ 'NO'
         GOSUB MODIFY.FILE
         BEGIN CASE
            CASE EXT EQ '' ; EXT = '$NAU'
            CASE EXT EQ '$NAU' ; EXT = '$HIS'
            CASE EXT EQ '$HIS' ; NO.MORE = 1
         END CASE
      REPEAT

      RETURN
*
******************************************************************************
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

            READ REC FROM F.FILE, ID ELSE NULL
            IF REC<CMP.FLD> NE ID.COMPANY THEN
               X = 0
               LOOP
                  X += 1
               UNTIL V$FIELD<X> EQ ''
                  POS = V$FIELD<X,1>
                  NOF = V$FIELD<X,2>
                  CNT = ABS(NOF)

                  FOR I = 1 TO CNT
                     IF NOF LT 0 THEN
                        REC = DELETE(REC,POS,0,0)
                     END ELSE
                        REC = INSERT(REC,POS,0,0,'')
                     END
                  NEXT I
               REPEAT
               WRITE REC TO F.FILE,ID
            END
         REPEAT

      END

      RETURN
*
******************************************************************************
*
   END
