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

* Version 9 07/06/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>925</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DE.Config
      SUBROUTINE CONV.DE.FORMAT.PRINT.14.1
*
** Where REL.NO is the major release number and not the dot release
** eg 12.1 but not 12.1.2
*
! 29.04.94 - GB9400563
!            The AUDITOR fields should not be set when writing to
!            REPORT.CONTROL. Also, the DATE.TIME field being copied
!            from DE.FORMAT.PRINT is null sometimes (cant think why )
!            If this happens then take the current DATE.TIME.
!
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
$INSERT I_F.FILE.CONTROL
$INSERT I_F.PGM.FILE
$INSERT I_F.USER
$INSERT I_F.SPF
*
$INSERT I_F.DE.FORMAT.PRINT
$INSERT I_F.DE.FORM.TYPE
$INSERT I_F.REPORT.CONTROL
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
      YFILE = "F.DE.FORMAT.PRINT"
      YTARGETFILE = "F.REPORT.CONTROL"   ; * File to be converted
      F.PGM.FILE = ''
      CALL OPF('F.PGM.FILE',F.PGM.FILE)

      F.DE.FORM.TYPE = ''
      CALL OPF("F.DE.FORM.TYPE",F.DE.FORM.TYPE)
*
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
                  TARGETFILE.NAME = 'F':MNEMONIC:'.':FIELD(YTARGETFILE,'.',2,99)
                  GOSUB MODIFY.FILE
               END
            REPEAT
         END ELSE                        ; * Internal File.
            TARGETFILE.NAME = YTARGETFILE ; FILE.NAME=YFILE ; GOSUB MODIFY.FILE
         END
*
*         IF NOT(ABORT.FLAG) THEN
* This subroutine will maintain the correct field numbers in any
* ENQUIRYs, REPGENs, STATIC.TEXT, and VERSIONs
*            CALL MODIFY.DATA(YFILE,ADD.FIELD,CANCEL.FIELD,SUMMARY.REPORT)
*         END
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
      F.FILE = ""
*
      YTARGETFILE = TARGETFILE.NAME
      F.REPORT.CONTROL = ''
*
      OPEN '',YTARGETFILE TO F.REPORT.CONTROL THEN
         OPEN '',YFILE TO F.FILE THEN
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
      TYPES.LIST = ''
      V$COUNT = 0                        ; * Initialise.
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
         YID = '%':YID
         READV TEMP.ID FROM F.REPORT.CONTROL,YID,0 ELSE
            CALL SF.CLEAR(1,7,"CONVERTING RECORD:  ":YID)
            V$COUNT += 1                 ; * Count sucessful conversions.
*
            RC.REC = ''
            RC.REC<RCF.DESC> = YREC<DE.PRT.DESCRIPTION>
            RC.REC<RCF.SHORT.DESC> = YREC<DE.PRT.DESCRIPTION>
            RC.REC<RCF.FORM.NAME> = YREC<DE.PRT.FORM.TYPE>
            IF RC.REC<RCF.FORM.NAME> = '' THEN
               RC.REC<RCF.FORM.NAME> = 'DEFAULT'
            END
            IF R.SPF.SYSTEM<SPF.MICROFICHE.OUTPUT>[1,1] MATCHES 'D':VM:'Y' THEN
               RC.REC<RCF.MICROFICHE.OUTPUT> = 'Y'
            END ELSE
               RC.REC<RCF.MICROFICHE.OUTPUT> = 'N'
            END
            RC.REC<RCF.CURR.NO> = 1
            RC.REC<RCF.INPUTTER> = "SY_DE.FORMAT.PRINT"
            RC.REC<RCF.DATE.TIME> = YREC<DE.PRT.DATE.TIME>
            IF RC.REC<RCF.DATE.TIME> = '' THEN
               YX = OCONV(DATE(),"D-")
               YX = YX[9,2]:YX[1,2]:YX[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
               RC.REC<RCF.DATE.TIME> = YX
            END
            RC.REC<RCF.AUTHORISER> = 'SY_CONVERSION.14.1'
            RC.REC<RCF.DEPT.CODE> =YREC<DE.PRT.DEPT.CODE>
            IF RC.REC<RCF.DEPT.CODE> = '' THEN
               RC.REC<RCF.DEPT.CODE> = R.USER<EB.USE.DEPARTMENT.CODE>
            END
            RC.REC<RCF.AUDITOR.CODE> = ''
            RC.REC<RCF.CO.CODE> = ID.COMPANY
            RC.REC<RCF.AUDIT.DATE.TIME> = ''
            WRITE RC.REC TO F.REPORT.CONTROL, YID
*
* Check FORM.TYPE RECORD and update option field if necessary.
*
            LOCATE RC.REC<RCF.FORM.NAME> IN TYPES.LIST<1> SETTING POSN ELSE
               TYPES.LIST = RC.REC<RCF.FORM.NAME>:@FM:TYPES.LIST
               READ R.FORM.TYPE FROM F.DE.FORM.TYPE,RC.REC<RCF.FORM.NAME> THEN
                  OPT.COUNT = DCOUNT(R.FORM.TYPE<DE.TYP.OPTIONS>,VM)
                  FOR X = 1 TO OPT.COUNT
                     IF R.FORM.TYPE<DE.TYP.OPTIONS,X> EQ "FORM ":RC.REC<RCF.FORM.NAME> THEN
                        X = OPT.COUNT + 1
                     END
                     IF X = OPT.COUNT THEN
                        R.FORM.TYPE<DE.TYP.OPTIONS,X+1> = "FORM ":RC.REC<RCF.FORM.NAME>
                        WRITE R.FORM.TYPE TO F.DE.FORM.TYPE,RC.REC<RCF.FORM.NAME>
                     END
                  NEXT X
               END
            END
*
         END
*
      REPEAT
      SUMMARY.REPORT<-1> = FMT(YFILE,'30L'):FMT(V$COUNT,'6R0,')
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
