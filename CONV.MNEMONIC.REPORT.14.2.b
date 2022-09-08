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

* Version 2 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>1407</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DE.Config
      SUBROUTINE CONV.MNEMONIC.REPORT.14.2
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
$INSERT I_F.PGM.FILE
$INSERT I_F.COMPANY.CHECK
$INSERT I_F.DATES
$INSERT I_F.FILE.CONTROL
*
** MNEMONIC.REPORT was released as a FIN file. It should have been
** INT.
** In a single company
** set up all records will be copied from the old Fxxx. to the
** F. file. In a multi company set up there will probably
** be problems
*
*****************************************************************
* 24/09/02 - GLOBUS_EN_10001221
*          Conversion Of all Error Messages to Error Codes
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT(). 
*
*****************************************************************
      F.PGM.FILE = ''
      CALL OPF('F.PGM.FILE',F.PGM.FILE)

      READ R.PGM.FILE FROM F.PGM.FILE,APPLICATION ELSE
         ID = APPLICATION
         YFILE = 'F.PGM.FILE'
         GOTO FATAL.ERROR
      END
      DESCRIPTION = R.PGM.FILE<EB.PGM.DESCRIPTION>
      PRINT @(5,4):"Reason:"
      LOOP
         REMOVE LINE FROM DESCRIPTION SETTING MORE
         PRINT SPACE(5):LINE
      WHILE MORE
      REPEAT
      PRINT
      TEXT = "DO YOU WANT TO RUN THIS CONVERSION"
      CALL OVE
      IF TEXT NE 'Y' THEN RETURN
*
** Read the FILE CONTROL record for MNEMONIC.REPORT
*
      READU YFILE.CONT.REC FROM F.FILE.CONTROL, "MNEMONIC.REPORT" THEN
         IF YFILE.CONT.REC<EB.FILE.CONTROL.CLASS> = "INT" THEN
            TEXT = "CONVERSION ALREADY RUN"
            CALL REM
            RELEASE F.FILE.CONTROL,"MNEMONIC.REPORT"
            RETURN
         END ELSE
            YFILE.CONT.REC<EB.FILE.CONTROL.CLASS> = "INT"
            WRITE YFILE.CONT.REC TO F.FILE.CONTROL, "MNEMONIC.REPORT"
         END
      END ELSE
         TEXT = "CANNOT READ FILE CONTROL FOR MNEMONIC REPORT"
      END
*
      NUL = ""
      IF R.INTERCO.PARAMETER THEN        ; * Multi co
*
* Rebuild F.MNEMONIC.REPORT from scratch.
*
         ORIG.COMP = ID.COMPANY          ; * Save for resetting at the end
         F.COMPANY.CHECK = ""
         CALL OPF("F.COMPANY.CHECK",F.COMPANY.CHECK)
         READ YFIN.COMPANIES FROM F.COMPANY.CHECK, "FINANCIAL" THEN
            YCO.IDS = YFIN.COMPANIES<EB.COC.COMPANY.CODE>
            YCO.IDS := VM:YFIN.COMPANIES<EB.COC.USING.COM>
            CONVERT SM TO VM IN YCO.IDS
            LOOP
               REMOVE YCO.CODE FROM YCO.IDS SETTING YDELIM
               IF YCO.CODE THEN
                  CALL LOAD.COMPANY(YCO.CODE)
*
** Create the file for the company
*
                  YERR = ""
                  CALL EBS.CREATE.FILE("MNEMONIC.REPORT", "", YERR)
                  IF YERR THEN
                     CRT @(8,22):YERR
                  END ELSE
*
                     OPEN "","F":R.COMPANY(EB.COM.MNEMONIC):".MNEMONIC.REPORT" TO OLD.MNRP ELSE RETURN
                     F.MNEMONIC.REPORT = ""
                     CALL OPF("F.MNEMONIC.REPORT",F.MNEMONIC.REPORT)
*
                     CALL HUSHIT(1)
*                     EXECUTE "SELECT F.MNEMONIC.REPORT"
                     YSENTENCE = "SELECT F":R.COMPANY(EB.COM.MNEMONIC):".MNEMONIC.REPORT"
                     EXECUTE YSENTENCE
                     EXECUTE "SAVE.LIST MR":ID.COMPANY
                     CALL HUSHIT(0)
*
                     PRINT @(5,5):"Processing company ":ID.COMPANY
                     YMR.REPORTS = ""
                     CALL EB.READLIST(YSENTENCE,YMR.REPORTS,"MNEMONIC.REPORT","","")
                     IF YMR.REPORTS THEN
                        LOOP
                           REMOVE YMR.ID FROM YMR.REPORTS SETTING YD2
                           CRT @(5,7):"Report ID ":YMR.ID
                           READ YMR.REC FROM OLD.MNRP , YMR.ID THEN
                              WRITE YMR.REC TO F.MNEMONIC.REPORT,YMR.ID
                           END ELSE NULL
                        WHILE YD2
                        REPEAT
                     END
                  END
                  CLEARFILE OLD.MNRP
*
               END
            WHILE YDELIM
            REPEAT
*
            CALL LOAD.COMPANY(ORIG.COMP)
*            CLEARFILE OLD.MNRP
*
         END ELSE NULL
*
      END ELSE
*
         OPEN "","F":R.COMPANY(EB.COM.MNEMONIC):".MNEMONIC.REPORT" TO OLD.MNRP ELSE RETURN
         CALL HUSHIT(1)
         YSENTENCE = "SELECT F":R.COMPANY(EB.COM.MNEMONIC):".MNEMONIC.REPORT"
         EXECUTE YSENTENCE
         EXECUTE "SAVE.LIST MNRPT"
         CALL HUSHIT(0)
*
         YIDS = ""
         CALL EB.READLIST(YSENTENCE,YIDS,"MNEMONIC.REPORT","","")
*
         YERR = ""
         CALL EBS.CREATE.FILE("MNEMONIC.REPORT", "", YERR)
         IF YERR THEN
            CRT @(8,22):YERR
         END ELSE
*
            F.MNEMONIC.REPORT = ""
            CALL OPF("F.MNEMONIC.REPORT",F.MNEMONIC.REPORT)
*
            IF YIDS THEN
               LOOP
                  REMOVE YMR.ID FROM YIDS SETTING YD
                  READ YREC FROM OLD.MNRP, YMR.ID THEN
                     CRT @(5,5):"Processing ":@(-4):YMR.ID
                     WRITE YREC TO F.MNEMONIC.REPORT, YMR.ID           ; * Add to new file
                     DELETE OLD.MNRP, YMR.ID       ; * Delete from old file
                  END ELSE NULL
               WHILE YD
               REPEAT
            END
         END
*
      END
*
      RETURN
*
FATAL.ERROR:
*
      CALL SF.CLEAR(8,22,"RECORD ":ID:" MISSING FROM ":YFILE:" FILE")
      ETEXT ="DE.RTN.WHY.PROGRAM.ABORTED.4"        ; * Used to update F.CONVERSION.PGMS
      CALL PGM.BREAK
*
   END
