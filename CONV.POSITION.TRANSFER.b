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

* Version 3 16/05/01  GLOBUS Release No. 200512 09/12/05
*-----------------------------------------------------------------------------
* <Rating>3718</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctPositionTransfer
      SUBROUTINE CONV.POSITION.TRANSFER
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
$INSERT I_CONV.COMMON
$INSERT I_F.SC.STD.POS.TRANSF
$INSERT I_F.PRICE.TYPE
$INSERT I_F.SECURITY.TRANS
$INSERT I_F.SECURITY.POSITION
$INSERT I_F.SECURITY.MASTER
*
** The insert of the file being converted should NOT be added
** Field names should never be used during conversions as this may cause
** errors when a customer receives several releases at once and the a
** file is being converted more than once.
*
* 02/05/00 - GB0001135
*            Check the application installed each company before continue
*            the conversion process
*
*************************************************************************
INITIALISE:
*
      EQU TRUE TO 1, FALSE TO ''
      TEXT = ''
      ETEXT = ''
      CLS = ''                           ; * Clear Screen
      ABORT.FLAG = ""
      YFILE = 'F.POSITION.TRANSFER'
      ORIGINAL.FILE = YFILE              ; * Store this it will changed
      COMPANY.CODE.POS = ""              ; * Position of new XX.CO.CODE in the file
      INPUTTER.POS = ""                  ; * Position of INPUTTER to store conversion id
      F.PGM.FILE = ''
      CALL OPF('F.PGM.FILE',F.PGM.FILE)

      READ R.PGM.FILE FROM F.PGM.FILE,APPLICATION ELSE
         R.PGM.FILE = ""
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
      FILE.SECURITY.TRANS = ''
      CALL OPF('F.SECURITY.TRANS',FILE.SECURITY.TRANS)
      FILE.SEC.POSITION = ''
      CALL OPF('F.SECURITY.POSITION',FILE.SEC.POSITION)
      F.POS.CON.SCAC = ''
      CALL OPF('F.POS.CON.SCAC',F.POS.CON.SCAC)
      F.POS.CON.SEC = ''
      CALL OPF('F.POS.CON.SEC',F.POS.CON.SEC)
      F.POS.CON.DP = ''
      CALL OPF('F.POS.CON.DP',F.POS.CON.DP)
      F.SC.STD.POS.TRANSF = ''
      CALL OPF('F.SC.STD.POS.TRANSF',F.SC.STD.POS.TRANSF)
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
**    CANCEL.FIELD<1,1> = ""            ;* Position to cancel from.
**    CANCEL.FIELD<2,1> = ""            ;* Number of fields to cancel.
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
      ADD.FIELD = ""
**    ADD.FIELD<1,1> = ""                ; * Position to add from (New field number)
**    ADD.FIELD<2,1> = ""                ; * Number of fields to add.
*
*************************************************************************
*
** Take description of what the program will do from the PGM.FILE file
** and give the user the opportunity to quit.
*
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
            COMPANY.REC = ''
            READ COMPANY.REC FROM F.COMPANY,K.COMPANY THEN
               MNEMONIC = COMPANY.REC<EB.COM.MNEMONIC>
*GB0001135S - Check the application installed at this stage
*             If the application in view is not installed for this company
*             skip the conversion for the file in this company.
*
               LOCATE R.FILE.CONTROL<EB.FILE.CONTROL.APPLICATION> IN COMPANY.REC<EB.COM.APPLICATIONS,1> SETTING APPL.POSN THEN
                  R.STD = ''
                  READ R.STD FROM F.SC.STD.POS.TRANSF,K.COMPANY ELSE
                     ID = K.COMPANY
                     YFILE = 'F.SC.STD.POS.TRANSF'
                     GOTO FATAL.ERROR
                  END
                  FILE.NAME = 'F':MNEMONIC:'.':FIELD(YFILE,'.',2,99)
                  GOSUB MODIFY.FILE
               END                       ; * GB0001135 S/E
            END
         REPEAT
      END ELSE                           ; * Internal File.
         R.STD = ''
         READ R.STD FROM F.SC.STD.POS.TRANSF,ID.COMPANY ELSE
            ID = K.COMPANY
            YFILE = 'F.SC.STD.POS.TRANSF'
            GOTO FATAL.ERROR
         END
         FILE.NAME=YFILE ; GOSUB MODIFY.FILE
      END
*
** There may be records to be released whihc should be converted these
** may not be in the current format, so should be checked in F.RELEASE
** DATA and converted where required.
**
** This SHOULDN'T have to be done as this is now carried out
** in the release procedures. Code left in case this process
** is removed from release data.
*
*     IF NOT(ABORT.FLAG) THEN
*        GOSUB MODIFY.RELEASE.DATA
*     END
*
*     IF NOT(ABORT.FLAG) THEN
* This subroutine will maintain the correct field numbers in any
* ENQUIRYs, REPGENs, STATIC.TEXT, and VERSIONs
*        CALL MODIFY.DATA(YFILE,ADD.FIELD,CANCEL.FIELD,SUMMARY.REPORT)
*     END
*
      GOSUB PRINT.SUMMARY
*     END                                ; * OK to run Conversion.

      RETURN                             ; * Exit Program.
*
*************************************************************************
*
MODIFY.FILE:
*
      TEXT = ""
*
** Some files may have a $ARC file. This loop is currently set to 3
** intentionally so that the $ARC file is ignored as it may be huge
** If you need to include the $ARC file set the loop to 4
*
      SUFFIX = '$NAU'
      YFILE = FILE.NAME:SUFFIX
      F.FILE = ""
      OPEN '',YFILE TO F.FILE THEN
         GOSUB MODIFY.FILE.START
      END
      YFILE = ORIGINAL.FILE

      RETURN
*
************************************************************************
*
MODIFY.RELEASE.DATA:
*
      YFILE = "F.RELEASE.DATA"
      F.FILE = ""
      OPEN '',YFILE TO F.FILE THEN
         GOSUB MODIFY.FILE.START
      END
      YFILE = ORIGINAL.FILE
*
      RETURN
*
*************************************************************************
*
MODIFY.FILE.START:
*
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
            IF YREC<COMPANY.CODE.POS> MATCHES "2A7N" THEN
               ALREADY.CONV += 1
*
** If overrides are required uncomment the next few lines of code
** In most cases there should be no override
*
***!            TEXT = "CONVERSION ALREADY DONE... ABORT ?"
***!            CALL OVE
***!            IF TEXT EQ "Y" THEN
***!               END.OF.FILE = TRUE
***!               ABORT.FLAG = TRUE
***!            END
            END ELSE
               V$COUNT += 1              ; * Count sucessful conversions.
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
* Modify fields - populate values to SECURITY.ACCT to PRICE if unauthorise
*
               IF YREC<37> = "INAU" THEN
                  GOSUB MODIFY.FIELDS
               END
*
* Add the conversion name for reference
*
               IF INPUTTER.POS THEN YREC<INPUTTER.POS,-1> = TNO:"_":APPLICATION
*
               WRITE YREC TO F.FILE, YID
*
*              GOSUB DELETE.UNAU.RECORDS
            END                          ; * Valid Record.
*
         END
*
      REPEAT
*     SUMMARY.REPORT<-1> = FMT(YFILE,'30L'):" CONVERTED         ":FMT(COUNT,'6R0,')
*     SUMMARY.REPORT<-1> = FMT(YFILE,'30L'):" ALREADY CONVERTED ":FMT(ALREADY.CONV,'6R0,')
      RETURN
*
*************************************************************************
*
PRINT.SUMMARY:
      LINE.NO = 0

      R.PGM.FILE<EB.PGM.DESCRIPTION,-1> = TRIM(LOWER(SUMMARY.REPORT))
      WRITE R.PGM.FILE TO F.PGM.FILE,APPLICATION

      RETURN
**
DELETE.UNAU.RECORDS:
**
      RETURN
**
MODIFY.FIELDS:
**
      BEGIN CASE
         CASE YREC<4> <> ''
            FILENAME = 'POS.CON.SCAC'
            FILE.POS.CON = F.POS.CON.SCAC
            K.POS.CON = YREC<4>
         CASE YREC<8> NE ""
            FILENAME = 'POS.CON.SEC'
            FILE.POS.CON = F.POS.CON.SEC
            K.POS.CON = YREC<8>
         CASE YREC<6> <> ''
            FILENAME = 'POS.CON.DP'
            FILE.POS.CON = F.POS.CON.DP
            K.POS.CON = YREC<6>
      END CASE
      POSITION.KEYS = ''
      SEQ.NO = 0
      READ POSITION.KEYS FROM FILE.POS.CON,K.POS.CON ELSE
         ID = K.POS.CON
         YFILE = FILENAME
         GOTO FATAL.ERROR
      END
      NO.POS.KEYS = DCOUNT(POSITION.KEYS,FM)
      IF YREC<8> THEN
         MY.POS.KEYS = POSITION.KEYS
         POSITION.KEYS = ''
         FOR K.POS = 1 TO NO.POS.KEYS
            IF YREC<8> = FIELD(MY.POS.KEYS<K.POS>,'.',2) THEN
               IF YREC<3> <> '' THEN
                  IF YREC<3> = FIELD(MY.POS.KEYS<K.POS>,'-',1) THEN
                     POSITION.KEYS<-1> = MY.POS.KEYS<K.POS>
                  END
               END ELSE
                  POSITION.KEYS<-1> = MY.POS.KEYS<K.POS>
               END
            END
         NEXT K.POS
         NO.POS.KEYS = DCOUNT(POSITION.KEYS,FM)
      END ELSE
         IF YREC<3> <> '' THEN
            MY.POS.KEYS = POSITION.KEYS
            POSITION.KEYS = ''
            FOR K.POS = 1 TO NO.POS.KEYS
               IF YREC<3> = FIELD(MY.POS.KEYS<K.POS>,'-',1) THEN
                  POSITION.KEYS<-1> = MY.POS.KEYS<K.POS>
               END
            NEXT K.POS
            NO.POS.KEYS = DCOUNT(POSITION.KEYS,FM)
         END
      END
*
* WHEN DEPOSITORY FROM IS ENTERED CHECK FOR DEPOSITORY CODE
* IS SAME AS THE DEPOSITORY FROM ENTERED
*
      IF YREC<6> <> '' THEN
         FOR Q = 1 TO NO.POS.KEYS
            IF FIELD(POSITION.KEYS<Q>,'.',3) <> YREC<6> THEN
               DEL POSITION.KEYS<Q>
               Q -= 1
               NO.POS.KEYS -= 1
            END
         NEXT Q
         NO.POS.KEYS = DCOUNT(POSITION.KEYS,FM)
      END
      IF POSITION.KEYS = '' THEN GOTO FINISH.MODIFY.FIELDS
      FOR POS.KEY = 1 TO NO.POS.KEYS
         K.SECURITY.POSITION = POSITION.KEYS<POS.KEY>
         IF FIELD(FIELD(K.SECURITY.POSITION,'.',1),'-',2) = '999' THEN GOTO NEXT.POS
         READ R.SECURITY.POSITION FROM FILE.SEC.POSITION,K.SECURITY.POSITION ELSE
            ID = K.SECURITY.POSITION
            YFILE = 'F.SECURITY.POSITION'
            GOTO FATAL.ERROR
         END
         IF ((R.SECURITY.POSITION<SC.SCP.CLOSING.BAL.NO.NOM> > 0) OR (R.STD<SC.SPT.SHORT.TRANSFER> = 'YES')) AND R.SECURITY.POSITION<SC.SCP.CLOSING.BAL.NO.NOM> THEN
            IF R.SECURITY.POSITION<SC.SCP.SECURITY.ACCOUNT> = '' THEN MY.VAR = ' ' ELSE MY.VAR = R.SECURITY.POSITION<SC.SCP.SECURITY.ACCOUNT>
            YREC<13> = INSERT(YREC<13>,1,-1,0,MY.VAR)
            CONVERT ' ' TO '' IN YREC<13>
            IF R.SECURITY.POSITION<SC.SCP.SECURITY.NUMBER> = '' THEN MY.VAR = ' ' ELSE MY.VAR = R.SECURITY.POSITION<SC.SCP.SECURITY.NUMBER>
            YREC<14> = INSERT(YREC<14>,1,-1,0,MY.VAR)
            CONVERT ' ' TO '' IN YREC<14>
            IF R.SECURITY.POSITION<SC.SCP.DEPOSITORY> = '' THEN MY.VAR = ' ' ELSE MY.VAR = R.SECURITY.POSITION<SC.SCP.DEPOSITORY>
            YREC<15> = INSERT(YREC<15>,1,-1,0,MY.VAR)
            CONVERT ' ' TO '' IN YREC<15>
            IF R.SECURITY.POSITION<SC.SCP.NOMINEE.CODE> = '' THEN MY.VAR = ' ' ELSE MY.VAR = R.SECURITY.POSITION<SC.SCP.NOMINEE.CODE>
            YREC<16> = INSERT(YREC<16>,1,-1,0,MY.VAR)
            CONVERT ' ' TO '' IN YREC<16>
            IF R.SECURITY.POSITION<SC.SCP.MATURITY.DATE> = '' THEN MY.VAR = ' ' ELSE MY.VAR = R.SECURITY.POSITION<SC.SCP.MATURITY.DATE>
            YREC<17> = INSERT(YREC<17>,1,-1,0,MY.VAR)
            CONVERT ' ' TO '' IN YREC<17>
            IF R.SECURITY.POSITION<SC.SCP.INTEREST.RATE> = '' THEN MY.VAR = ' ' ELSE MY.VAR = R.SECURITY.POSITION<SC.SCP.INTEREST.RATE>
            YREC<18> = INSERT(YREC<18>,1,-1,0,MY.VAR)
            CONVERT ' ' TO '' IN YREC<18>
            IF YREC<9> <> '' THEN
               MY.VAR = YREC<9>
            END ELSE
               IF R.SECURITY.POSITION<SC.SCP.CLOSING.BAL.NO.NOM> = '' THEN MY.VAR = ' ' ELSE MY.VAR = R.SECURITY.POSITION<SC.SCP.CLOSING.BAL.NO.NOM>
            END
            YREC<19> = INSERT(YREC<19>,1,-1,0,MY.VAR)
            CONVERT ' ' TO '' IN YREC<19>
            COST.INVST.SEC.CCY = R.SECURITY.POSITION<SC.SCP.COST.INVST.SEC.CCY>
            MY.PRICE.TYPE = ''
            CALL DBR('SECURITY.MASTER':FM:SC.SCM.PRICE.TYPE,
               R.SECURITY.POSITION<SC.SCP.SECURITY.NUMBER>,MY.PRICE.TYPE)
            PERC.FACTOR = ''
            CALL DBR('PRICE.TYPE':FM:SC.PRT.PERCENTAGE,
               MY.PRICE.TYPE,PERC.FACTOR)
            IF PERC.FACTOR = 'Y' THEN PERC.FACTOR = 100 ELSE PERC.FACTOR = 1
            MULT.FACTOR = ''
            CALL DBR('PRICE.TYPE':FM:SC.PRT.MULTIPLY.FACTOR,
               MY.PRICE.TYPE,MULT.FACTOR)
            NOMINAL = R.SECURITY.POSITION<SC.SCP.CLOSING.BAL.NO.NOM>
            MY.VAR = COST.INVST.SEC.CCY * PERC.FACTOR / (NOMINAL * MULT.FACTOR)
            YREC<20> = INSERT(YREC<20>,1,-1,0,MY.VAR)
            CONVERT ' ' TO '' IN YREC<20>
         END
NEXT.POS:
      NEXT POS.KEY
      FOR MM = 13 TO 20
         YREC<MM> = TRIM(YREC<MM>)
      NEXT MM
FINISH.MODIFY.FIELDS:
      RETURN
**
*************************************************************************
*
FATAL.ERROR:
*
      CALL SF.CLEAR(8,22,"RECORD ":ID:" MISSING FROM ":YFILE:" FILE")
      ETEXT = "Why program aborted"      ; * Used to update F.CONVERSION.PGMS
      CALL PGM.BREAK
*
*************************************************************************
   END
