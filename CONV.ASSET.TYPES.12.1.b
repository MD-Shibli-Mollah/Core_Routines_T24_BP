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

* Version 7 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>494</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.Config
      SUBROUTINE CONV.ASSET.TYPES.12.1
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
$INSERT I_F.CONSOL.ENT.TODAY
*
** The insert of the file being converted should be added here
*
$INSERT I_F.CONSOLIDATE.ASST.LIAB
$INSERT I_F.CONSOLIDATE.COND
$INSERT I_F.RE.CONSOL.ASSET.LINE
$INSERT I_F.RE.STAT.LINE.CONT
$INSERT I_F.RE.STAT.NAME
$INSERT I_F.RE.STAT.RANGE
$INSERT I_F.RE.STAT.REP.LINE
*
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

         YFILE='F.CONSOLIDATE.ASST.LIAB' ; A$=RE.ASL.TYPE
         GOSUB FILE.CONTROL

         YFILE='F.CONSOLIDATE.COND' ; A$=RE.CON.FWD.REV.TYPE
         GOSUB FILE.CONTROL

         YFILE='F.RE.CONSOL.ASSET.LINE' ; A$=RE.CAL.TYPE
         GOSUB FILE.CONTROL

         YFILE='F.RE.STAT.LINE.CONT' ; A$=RE.SLC.ASSET.TYPE
         GOSUB FILE.CONTROL

         YFILE='F.RE.STAT.NAME' ; A$=RE.SNM.TYPE
         GOSUB FILE.CONTROL

         YFILE='F.RE.STAT.RANGE' ; A$=''
         GOSUB FILE.CONTROL
*
         YFILE='F.RE.STAT.REP.LINE' ; A$=RE.SRL.ASSET.TYPE
         GOSUB FILE.CONTROL
*
         YFILE='F.CONSOL.ENT.TODAY' ; A$=RE.CET.TYPE
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
         IF A$ THEN GOSUB YREC ELSE
            GOSUB RE.STAT.RANGE
         END
*
         WRITE YREC TO F.FILE, YID
*
      REPEAT
      SUMMARY.REPORT<-1> = FMT(YFILE,'30L'):FMT(V$COUNT,'6R0,')
      RETURN
*
*-----RE STAT RANGE------------------------------------------------------
*
RE.STAT.RANGE:
      LOCATE 'ASSET.TYPE' IN YREC<RE.RNG.CONSOL.FIELD,1> SETTING V$ THEN
         A$=RE.RNG.START.RANGE ; GOSUB YREC
         A$=RE.RNG.END.RANGE ; GOSUB YREC
      END
      RETURN
*
*-----YREC---------------------------------------------------------------
*
YREC:
      YREC.ASSET.TYPES=YREC<A$> ; ASSET.TYPES=''
      LOOP
         REMOVE ASSET.TYPE FROM YREC.ASSET.TYPES SETTING REMOVE$
         GOSUB ASSET.TYPE.BL ; ASSET.TYPES:=ASSET.TYPE
      WHILE REMOVE$ DO
         ASSET.TYPES:=CHARX(256-REMOVE$)
      REPEAT
      YREC<A$>=ASSET.TYPES
      RETURN
*
*-----ASSET TYPE (BL)----------------------------------------------------
*
ASSET.TYPE.BL:
      IF ASSET.TYPE[2]='BL' THEN
         ASSET.TYPE=ASSET.TYPE[1,LEN(ASSET.TYPE)-2]
         GOSUB ASSET.TYPE
         ASSET.TYPE:='BL'
      END ELSE
         GOSUB ASSET.TYPE
      END
      RETURN
*
*-----ASSET TYPE---------------------------------------------------------
*
ASSET.TYPE:
      BEGIN CASE
         CASE ASSET.TYPE='FXFWINTSELL' ; ASSET.TYPE='FXFWINTSEL'
         CASE ASSET.TYPE='FXSPINTSELL' ; ASSET.TYPE='FXSPINTSEL'
         CASE ASSET.TYPE='FWDCONTDR' ; ASSET.TYPE='FWDCONTDB'
         CASE ASSET.TYPE='CONTDR' ; ASSET.TYPE='CONTDB'
      END CASE
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
