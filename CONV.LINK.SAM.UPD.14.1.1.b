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

* Version 4 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>729</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoPortfolioMaintenance
      SUBROUTINE CONV.LINK.SAM.UPD.14.1.1
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
** The insert of the file being converted should NOT be added
** Field names should never be used during conversions as this may cause
** errors when a customer receives several releases at once and the a
** file is being converted more than once.
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
      CFILE = "F.LINK.SEC.MASTER"        ; * File to be converted
      YFILE = 'F.SEC.ACC.MASTER'
      COMPANY.CODE.POS = ""              ; * Position of new XX.CO.CODE in the file
      F.PGM.FILE = ''
      CALL OPF('F.PGM.FILE',F.PGM.FILE)

      READ R.PGM.FILE FROM F.PGM.FILE,APPLICATION ELSE
         ID = APPLICATION
         YFILE = 'F.PGM.FILE'
         GOTO FATAL.ERROR
      END
      DESCRIPTION = R.PGM.FILE<EB.PGM.DESCRIPTION>

      ID = FIELD(YFILE,'.',2,99)
      READ R.FILE.CONTROL FROM F.FILE.CONTROL,ID ELSE
         YFILE = 'F.FILE.CONTROL'
         GOTO FATAL.ERROR
      END
      MULTI.COMPANY.FILE = (R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> NE 'INT')
      F.COMPANY = ''
      CALL OPF('F.COMPANY',F.COMPANY)
*
** If any fields are to be removed from the file add these here
** If several sets of fields are to be removed these should be added
** in multi values 2 and onwards.
** NB. That if more than one set of numbers is used then. Fields should
** be deleted starting from the bottom of the record, and thus the
** highest numbered positions should be input first.
*
** Field names should never be used during conversions as this may cause
** errors when a customer receives several releases at once and the a
** file is being converted more than once.
      CANCEL.FIELD = ""
**      CANCEL.FIELD<1,1> = ""            ;* Position to cancel from.
**      CANCEL.FIELD<2,1> = ""            ;* Number of fields to cancel.
*
** Add the position where new fields start, plus the number of fields
** required.
** If several sets of fields are to be added these should be added
** in multi values 2 and onwards.
** NB. That if more than one set of numbers is used then. Fields should
** be added starting from the bottom of the record, and thus the
** highest numbered positions should be input first.
*
** Field names should never be used during conversions as this may cause
** errors when a customer receives several releases at once and the a
** file is being converted more than once.
      ADD.FIELD = ''
*      ADD.FIELD<1,1> = ""               ;* Position to add from. (New field number)
*      ADD.FIELD<2,1> = ""               ;* Number of fields to add.
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
         IF MULTI.COMPANY.FILE THEN
            SEL.CMD = 'SSELECT F.COMPANY'
            COM.LIST = ''
            YSEL = 0
            CALL EB.READLIST(SEL.CMD,COM.LIST,'',YSEL,'')
            LOOP
               REMOVE K.COMPANY FROM COM.LIST SETTING END.OF.COMPANIES
            WHILE K.COMPANY:END.OF.COMPANIES
               READV MNEMONIC FROM F.COMPANY,K.COMPANY,EB.COM.MNEMONIC THEN
                  FILE.NAME = 'F':MNEMONIC:'.':FIELD(YFILE,'.',2,99)
                  CFILE.NAME = 'F':MNEMONIC:'.':FIELD(CFILE,'.',2,99)
                  GOSUB MODIFY.FILE
               END
            REPEAT
         END ELSE                        ; * Internal File.
            FILE.NAME=YFILE
            CFILE.NAME=CFILE
            GOSUB MODIFY.FILE
         END
*
         GOSUB PRINT.SUMMARY
         PRINT
         TEXT = 'CONVERSION COMPLETE'
         CALL REM
      END                                ; * OK to run Conversion.

      RETURN                             ; * Exit Program.
*
*************************************************************************
*
MODIFY.FILE:
*
      CALL SF.CLEAR.STANDARD
      TEXT = ""
      YFILE = FILE.NAME
      CFILE = CFILE.NAME
      F.FILE = "" ; F.CFILE = ''
      OPEN '',YFILE TO F.FILE THEN
         OPEN '',CFILE TO F.CFILE THEN
            GOSUB MODIFY.FILE.START
         END
      END

      RETURN
*
*************************************************************************
*
MODIFY.FILE.START:
*
      CALL SF.CLEAR(1,5,"CONVERTING:         ":YFILE)
*
      V$COUNT = 0                        ; * Initialise.
      DUPLICATES.FOUND = ''
      SELECT F.FILE
      END.OF.FILE = FALSE
      ABORT.FLAG = FALSE
      LOOP
         IF NOT(END.OF.FILE) THEN
            READNEXT YID ELSE END.OF.FILE = TRUE
         END
      UNTIL END.OF.FILE
*
         READ YREC FROM F.FILE, YID ELSE GOTO FATAL.ERROR
         LINK.SCM = YREC<62>
         CONVERT "," TO "ý" IN LINK.SCM
         YREC<62> = LINK.SCM
         NO.LINKS = DCOUNT(YREC<62>,VM)
         FOR LNK = 1 TO NO.LINKS
            K.LINK = YREC<62,LNK>
            READ R.LINK FROM F.CFILE,K.LINK ELSE R.LINK = ''
            IF R.LINK = '' THEN
               R.LINK = YID
               WRITE R.LINK TO F.CFILE,K.LINK
            END ELSE DUPLICATES.FOUND<1,-1> = K.LINK
         NEXT LNK
         IF YREC<62> NE "" THEN WRITE YREC TO F.FILE, YID
*
         V$COUNT += 1
*
      REPEAT
*
      SUMMARY.REPORT<-1> = FMT(YFILE,'30L'):FMT(V$COUNT,'6R0,')
      IF DUPLICATES.FOUND THEN
         SUMMARY.MATRIX<-1> = "THE FOLLOWING SECURITIES WERE FOUND ON MORE THAN ONE PORTFOLIO :-"
         CONVERT VM TO ',' IN DUPLICATES.FOUND
         SUMMARY.REPORT<-1> = DUPLICATES.FOUND
      END
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
