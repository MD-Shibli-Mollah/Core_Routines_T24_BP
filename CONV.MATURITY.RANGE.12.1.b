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

* Version 6 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>393</Rating>
*-----------------------------------------------------------------------------
      $PACKAGE RE.Consolidation
      SUBROUTINE CONV.MATURITY.RANGE.12.1
*
** Where REL.NO is the major release number and not the dot release
** eg 12.1 but not 12.1.2
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
$INSERT I_F.FILE.CONTROL
$INSERT I_F.PGM.FILE
$INSERT I_F.USER
*
** The insert of the file being converted should be added here
*
$INSERT I_F.RE.CONSOL.ASSET.LINE
$INSERT I_F.RE.STAT.LINE.CONT
$INSERT I_F.RE.STAT.REP.LINE
*
* 23/06/93 - GB9301113
*            Conversion was using the letter "O" rather than zero
*            in RE.STAT.REP.LINE
*************************************************************************
INITIALISE:
*
      EQU TRUE TO 1, FALSE TO ''
      CLS = ''                           ; * Clear Screen
      FOR X = 4 TO 16
         CLS := @(0,X):@(-4)
      NEXT X
      CLS := @(0,4)
      F.PGM.FILE = ''
      CALL OPF('F.PGM.FILE',F.PGM.FILE)

      READ R.PGM.FILE FROM F.PGM.FILE,APPLICATION ELSE
         ID = APPLICATION
         YFILE = 'F.PGM.FILE'
         GOTO FATAL.ERROR
      END
      DESCRIPTION = R.PGM.FILE<EB.PGM.DESCRIPTION>

      F.COMPANY = ''
      CALL OPF('F.COMPANY',F.COMPANY)

*
*************************************************************************
*
** Take description of what the program will do from the PGM.FILE file
** and give the user the opportunity to quit.
*
      PRINT @(5,4):"Reason:"
      LOOP
         REMOVE LINE FROM DESCRIPTION SETTING MORE
         PRINT SPACE(5):LINE
      WHILE MORE
      REPEAT
      PRINT
      TEXT = "DO YOU WANT TO RUN THIS CONVERSION"
      CALL OVE
      IF TEXT EQ "Y" THEN
         SUMMARY.REPORT = R.USER<EB.USE.USER.NAME>:' ':TIMEDATE()      ; * Summary of files & number of records converted.

         YFILE='F.RE.STAT.LINE.CONT' ; A$=RE.SLC.MAT.RANGE
         GOSUB FILE.CONTROL

         YFILE='F.RE.STAT.REP.LINE' ; A$=''
         GOSUB FILE.CONTROL

         YFILE='F.RE.CONSOL.ASSET.LINE' ; A$=RE.CAL.MAT.DATE.RAN
         GOSUB FILE.CONTROL

         GOSUB PRINT.SUMMARY
         PRINT
         TEXT = 'CONVERSION COMPLETE'
         CALL OVE
      END                                ; * OK to run Conversion.

      RETURN                             ; * Exit Program.
*
*-----FILE CONTROL-------------------------------------------------------
*
FILE.CONTROL:
      ID = FIELD(YFILE,'.',2,99)
      READ R.FILE.CONTROL FROM F.FILE.CONTROL,ID ELSE
         YFILE = 'F.FILE.CONTROL'
         GOTO FATAL.ERROR
      END
      MULTI.COMPANY.FILE = (R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> NE 'INT')
      IF MULTI.COMPANY.FILE THEN
         SSELECT F.COMPANY
         COMPANY.IDS='' ; OK='' ; CALL EB.READLIST('',COMPANY.IDS,'',OK,'')
         IF OK THEN
            LOOP
               REMOVE K.COMPANY FROM COMPANY.IDS SETTING COMPANY.ID.REMOVE
               READV MNEMONIC FROM F.COMPANY,K.COMPANY,EB.COM.MNEMONIC THEN
                  FILE.NAME = 'F':MNEMONIC:'.':FIELD(YFILE,'.',2,99)
                  GOSUB MODIFY.FILE
               END
            WHILE COMPANY.ID.REMOVE DO
            REPEAT
         END ELSE
            TEXT='EB.READLIST ERROR: FILE=&':FM:'COMPANY'
            CALL FATAL.ERROR('CONV.ASSET.TYPES.12.1')
         END
      END ELSE                           ; * Internal File.
         FILE.NAME=YFILE ; GOSUB MODIFY.FILE
      END
      RETURN
*
*************************************************************************
*
MODIFY.FILE:
*
      CALL SF.CLEAR.STANDARD
      TEXT = ""
      FOR FILE.TYPE = 1 TO 3
         BEGIN CASE
            CASE FILE.TYPE EQ 1
               SUFFIX = ""
            CASE FILE.TYPE EQ 2
               SUFFIX = "$NAU"
            CASE FILE.TYPE EQ 3
               SUFFIX = "$HIS"
         END CASE
         YFILE = FILE.NAME:SUFFIX
         F.FILE = ""
         OPEN '',YFILE TO F.FILE THEN
            GOSUB MODIFY.FILE.START
         END
      NEXT FILE.TYPE
      YFILE = FIELD(YFILE,'$',1)

      RETURN
*
*************************************************************************
*
MODIFY.FILE.START:
*
      CALL SF.CLEAR(1,5,"CONVERTING:         ":YFILE)
*
      V$COUNT = 0                        ; * Initialise.
      SELECT F.FILE
      END.OF.FILE = FALSE
      LOOP
         IF NOT(END.OF.FILE) THEN
            READNEXT YID ELSE END.OF.FILE = TRUE
         END
      UNTIL END.OF.FILE
*
         READ YREC FROM F.FILE, YID ELSE ID=YID ; GOTO FATAL.ERROR
         CALL SF.CLEAR(1,7,"CONVERTING RECORD:  ":YID)
         V$COUNT+=1
*
         IF A$ THEN
            GOSUB YREC
         END ELSE
            GOSUB STAT.REP.LINE
         END
*
         WRITE YREC TO F.FILE, YID
*
      REPEAT
      SUMMARY.REPORT<-1> = FMT(YFILE,'30L'):FMT(V$COUNT,'6R0,')
      RETURN
*
*------------------------------------------------------------------------
*
YREC:
      YREC.ASSET.TYPES=YREC<A$> ; MAT.RANGES=''
      LOOP
         REMOVE MAT.RANGE FROM YREC.ASSET.TYPES SETTING REMOVE$
         GOSUB MAT.DATE.RANGE
         MAT.RANGES:=MAT.RANGE
      WHILE REMOVE$ DO
         MAT.RANGES:=CHARX(256-REMOVE$)
      REPEAT
      YREC<A$>=MAT.RANGES
      RETURN
*
*-----MAT.DATE.RANGE (STAT LINE CONT, RE.CONSOL.ASSET.LINE)-------------
*
MAT.DATE.RANGE:
      BEGIN CASE
         CASE MAT.RANGE = "0"
            MAT.RANGE = "0D"
         CASE MAT.RANGE["\",1,1] = "0"
            MAT.RANGE = "0D\":MAT.RANGE["\",2,1]
         CASE MAT.RANGE["\",2,1] = "0"
            MAT.RANGE = MAT.RANGE["\",1,1]:"\0D"
      END CASE
      RETURN
*
*------RE STAT LINE CONT------------------------------------------------
*
STAT.REP.LINE:
      YREC.ASSET.TYPES=YREC<RE.SRL.MAT.DATE.TO> ; MAT.RANGES = ""
      LOOP
         REMOVE MAT.RANGE FROM YREC.ASSET.TYPES SETTING REMOVE$
         IF MAT.RANGE = "0" THEN
            MAT.RANGE = "0D"
         END
         MAT.RANGES:=MAT.RANGE
      WHILE REMOVE$ DO
         MAT.RANGES:=CHARX(256-REMOVE$)
      REPEAT
      YREC<RE.SRL.MAT.DATE.TO> = MAT.RANGES
      RETURN
*
*************************************************************************
*
PRINT.SUMMARY:
      LINE.NO = 0
      PRINT CLS:                         ; * Clear Screen
      LOOP
         REMOVE LINE FROM SUMMARY.REPORT SETTING MORE
         PRINT LINE
         LINE.NO += 1
         IF NOT(MOD(LINE.NO,16)) THEN    ; * One Screen EQ 16 lines.
            TEXT = 'CONTINUE'
            CALL OVE
            IF TEXT NE 'Y' THEN
               MORE = FALSE
            END ELSE
               PRINT CLS:                ; * Clear Screen
            END
         END
      WHILE MORE
      REPEAT

      R.PGM.FILE<EB.PGM.DESCRIPTION,-1> = TRIM(LOWER(SUMMARY.REPORT))
      WRITE R.PGM.FILE TO F.PGM.FILE,APPLICATION

      RETURN
*
*************************************************************************
*
FATAL.ERROR:
*
      CALL SF.CLEAR(8,22,"RECORD ":ID:" MISSING FROM ":YFILE:" FILE")
      CALL PGM.BREAK
*
*************************************************************************
   END
