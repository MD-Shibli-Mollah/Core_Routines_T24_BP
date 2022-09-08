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
* <Rating>1089</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.SystemTables
      SUBROUTINE CONV.STATIC.TEXT.G7
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
** 05/023/96 - GB9600145
**             Do not give an override if already converted simply continue
**
** 15/02/96 - GB9600190
**            Update RUN.INFO with the details and not the description
**            Convert $ARC file and F.RELEASE.DATA
*
* 23/08/02 - GLOBUS_EN_10000971
*          Conversion Of all Error Messages to Error Codes
*************************************************************************
INITIALISE:
*
      EQU TRUE TO 1, FALSE TO ''
      TEXT = ''
      ETEXT = ''
      CLS = ''                           ; * Clear Screen
      ABORT.FLAG = ""
      FOR X = 4 TO 16
         CLS := @(0,X):@(-4)
      NEXT X
      CLS := @(0,4)
      YFILE = "F.STATIC.TEXT"            ; * File to be converted
      ORIGINAL.FILE = YFILE              ; * Store this it will changed
      COMPANY.CODE.POS = ""              ; * Position of new XX.CO.CODE in the file
      INPUTTER.POS = ""                  ; * Position of INPUTTER to store conversion id
      F.DYNAMIC.TEXT = ''
      CALL OPF('F.DYNAMIC.TEXT',F.DYNAMIC.TEXT)
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
*      IF R.PGM.FILE<EB.PGM.RUN.INFO> THEN
*         TEXT = "THIS CONVERSION HAS ALREADY BEEN RUN. CONTINUE"
*      END ELSE
*         TEXT = "DO YOU WANT TO RUN THIS CONVERSION"
*      END
*      CALL OVE
*      IF TEXT EQ "Y" THEN
      SUMMARY.REPORT = R.USER<EB.USE.USER.NAME>:' ':TIMEDATE()         ; * Summary of files & number of records converted.
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
               GOSUB MODIFY.FILE
            END
         REPEAT
      END ELSE                           ; * Internal File.
         FILE.NAME=YFILE ; GOSUB MODIFY.FILE
      END
*
      IF NOT(ABORT.FLAG) THEN
* This subroutine will maintain the correct field numbers in any
* ENQUIRYs, REPGENs, STATIC.TEXT, and VERSIONs
*            CALL MODIFY.DATA(YFILE,ADD.FIELD,CANCEL.FIELD,SUMMARY.REPORT)
      END
*
      GOSUB PRINT.SUMMARY
      PRINT
      TEXT = 'CONVERSION COMPLETE'
      CALL REM
*      END                                ; * OK to run Conversion.

      RETURN                             ; * Exit Program.
*
*************************************************************************
*
MODIFY.FILE:
*
      CALL SF.CLEAR.STANDARD
      TEXT = ""
*
** Some files may have a $ARC file. This loop is currently set to 3
** intentionally so that the $ARC file is ignored as it may be huge
** If you need to include the $ARC file set the loop to 4
*
      FOR FILE.TYPE = 1 TO 1
         BEGIN CASE
            CASE FILE.TYPE EQ 1
               SUFFIX = ""
         END CASE
         YFILE = FILE.NAME:SUFFIX
         F.FILE = ""
         OPEN '',YFILE TO F.FILE THEN
            GOSUB MODIFY.FILE.START
         END
      NEXT FILE.TYPE
      YFILE = ORIGINAL.FILE

      RETURN
*
*************************************************************************
*
MODIFY.FILE.START:
*
      CALL SF.CLEAR(1,5,"CONVERTING:         ":YFILE)
*
      V$COUNT = 0                        ; * Initialise.
      ALREADY.CONV = 0                   ; * Already converted counter
      SELECT F.FILE
      END.OF.FILE = FALSE
      ABORT.FLAG = FALSE
      LOOP
         IF NOT(END.OF.FILE) THEN
            READNEXT YID ELSE END.OF.FILE = TRUE
         END
      UNTIL END.OF.FILE
*
         IF YFILE NE "F.RELEASE.DATA" OR YID[">",1,1] = ORIGINAL.FILE THEN
*
            READ YREC FROM F.FILE, YID ELSE GOTO FATAL.ERROR
            CALL SF.CLEAR(1,7,"CONVERTING RECORD:  ":YID)
            V$COUNT += 1                 ; * Count sucessful conversions.
*
** Delete the fields specified here
*
            X = 0
            LOOP X += 1 UNTIL CANCEL.FIELD<1,X> = ""
               POS = CANCEL.FIELD<1,X>
               NOF = CANCEL.FIELD<2,X>
               FOR Y = 1 TO NOF
                  DEL YREC<POS>
               NEXT Y
            REPEAT
*
** Add the fields specified here
*
            X = 0
            LOOP X += 1 UNTIL ADD.FIELD<1,X> = ''
               POS = ADD.FIELD<1,X>
               NOF = ADD.FIELD<2,X>
               FOR Y = 1 TO NOF
                  INS "" BEFORE YREC<POS>
               NEXT Y
            REPEAT
*
** Add the conversion name for reference
*
            IF INPUTTER.POS THEN YREC<INPUTTER.POS,-1> = TNO:"_":APPLICATION
            READ PGM.REC FROM F.PGM.FILE, YID THEN
               IF PGM.REC<EB.PGM.TYPE>[1 , 1] MATCHES 'H':VM:'U':VM:'L':VM:'T':VM:'W' THEN
                  TOTAL.FIELDS = DCOUNT(YREC<1> , @VM)
                  FOR IDX = 1 TO TOTAL.FIELDS
                     TXT.FLD = YREC<1 , IDX>
                     GOSUB STRIP.OUT.FIELD

                     DYNAMIC.ID = YID:'*':TXT.FLD
                     READ DYNAMIC.REC FROM F.DYNAMIC.TEXT, DYNAMIC.ID ELSE
                        CNTR = 1
                        FOR CNTR = 1 TO 12
                           IF YREC<CNTR , IDX> NE '' THEN
                              TXT.FLD = YREC<CNTR , IDX>
                              GOSUB STRIP.OUT.FIELD
                              DYNAMIC.REC<CNTR> = TXT.FLD
                           END
                        NEXT CNTR
                     END
*
                     DYNAMIC.REC<13> = ""          ; * RECORD.STATUS
                     DYNAMIC.REC<14> = 1           ; * CURR.NO
                     DYNAMIC.REC<15> = TNO:"_":OPERATOR      ; * INPUTTER
                     CURRENT.DATE = OCONV(DATE(),'DYMD[4,2,2]')
                     CURRENT.DATE = CURRENT.DATE[1,4]: CURRENT.DATE[6,2]: CURRENT.DATE[9,2]
                     CURRENT.TIME = OCONV(TIME(),'MT')
                     CURRENT.TIME = CURRENT.TIME[1,2]: CURRENT.TIME[4,2]
                     DYNAMIC.REC<16> = CURRENT.DATE: CURRENT.TIME      ; * DATE.TIME
                     DYNAMIC.REC<17> = TNO:"_":"CONV.STATIC.TEXT.G7"   ; * AUTHORISER
                     DYNAMIC.REC<18> = ID.COMPANY  ; * CO.CODE
                     DYNAMIC.REC<19> = ""          ; * DEPT.CODE
                     DYNAMIC.REC<20> = ""          ; * AUDITOR.CODE
                     DYNAMIC.REC<21> = ""          ; * AUDIT.DATE.TIME
*
                     WRITE DYNAMIC.REC TO F.DYNAMIC.TEXT, DYNAMIC.ID
*
                  NEXT IDX
               END
            END
         END

      REPEAT
      SUMMARY.REPORT<-1> = FMT(YFILE,'30L'):" CONVERTED         ":FMT(V$COUNT,'6R0,')
      SUMMARY.REPORT<-1> = FMT(YFILE,'30L'):" ALREADY CONVERTED ":FMT(ALREADY.CONV,'6R0,')
      RETURN
*
*************************************************************************
*
STRIP.OUT.FIELD:
*****************

      BEGIN CASE
         CASE TXT.FLD[1 , 9] MATCHES "'XX'1X'XX'1X'LL.'"
            TXT.FLD = TXT.FLD[10 , 99]
         CASE TXT.FLD[1 , 6] MATCHES "'XX'1X'LL.'"
            TXT.FLD = TXT.FLD[7 , 99]
         CASE TXT.FLD[1 , 5] MATCHES "'XX'1X'XX'"
            TXT.FLD = TXT.FLD[6 , 99]
         CASE TXT.FLD[1 , 3] MATCHES "'XX'1X"
            TXT.FLD = TXT.FLD[4 , 99]
      END CASE

      RETURN

*
***********************************************
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
      ETEXT ="EB.RTN.WHY.PROGRAM.ABORTED.18"       ; * Used to update F.CONVERSION.PGMS
      CALL PGM.BREAK
*
*************************************************************************
   END
