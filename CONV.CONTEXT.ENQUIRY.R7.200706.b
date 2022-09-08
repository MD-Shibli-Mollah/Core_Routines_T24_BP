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

*
*-----------------------------------------------------------------------------
* <Rating>-91</Rating>
*-----------------------------------------------------------------------------
      SUBROUTINE CONV.CONTEXT.ENQUIRY.R7.200706
*-----------------------------------------------------------------------------
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* where ever possible use the RECORD.ROUTINE to convert/populate record data fields.
*
* 15/03/07 - EN_10003239
*            Remove obsolete CONTEXT.ENQUIRY record.
*
*-----------------------------------------------------------------------------
* Modification History:
*
*
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

* Equate field numbers to position manually, do no use $INSERT
      EQU SUFFIXES TO 3
      EQU FILE.CONTROL.CLASS TO 6

      SAVE.ID.COMPANY = ID.COMPANY

      GOSUB INITIALISATION   ; * open files etc
      
      GOSUB GET.FILE.CLASSIFICATION   ; * get file classification

      LOOP
         REMOVE K.COMPANY FROM COMPANIES SETTING MORE.COMPANIES
      WHILE K.COMPANY:MORE.COMPANIES

         IF K.COMPANY NE ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
         END

         GOSUB COMPANY.INITIALISATION   ; * specific COMPANY initialisation

         PROCESSING.LIVE = 1

         GOSUB PROCESS.FILE   ; * perform required action on company file
         
         PROCESSING.LIVE = 0

         IF UNAUTH.REQD THEN
            F.CONTEXT.ENQUIRY = F.CONTEXT.ENQUIRY$NAU
            GOSUB PROCESS.FILE   ; * perform required action on company file
         END

         IF HIST.REQD THEN
            F.CONTEXT.ENQUIRY = F.CONTEXT.ENQUIRY$HIS
            GOSUB PROCESS.FILE   ; * perform required action on company file
         END

      REPEAT

      IF ID.COMPANY NE SAVE.ID.COMPANY THEN
         CALL LOAD.COMPANY(SAVE.ID.COMPANY)
      END
      
      RETURN

*-----------------------------------------------------------------------------
PROCESS.FILE:
* perform required action on company specific file

* if processing the live file copy the obsolete records to history before deletion
* delete the obsolete records from the live & $NAU files.

      LOOP
      REMOVE OBSOLETE.ID FROM OBSOLETE.LIST SETTING OBSOLETE.MARK
      WHILE OBSOLETE.ID : OBSOLETE.MARK DO
         R.RECORD = ''
         YERR = ''
         CALL F.READ(FN.CONTEXT.ENQUIRY,OBSOLETE.ID,R.RECORD,F.CONTEXT.ENQUIRY,YERR)
         IF NOT(YERR) THEN
            IF PROCESSING.LIVE THEN
               GOSUB WRITE.HISTORY.REC
            END
            CALL F.DELETE(FN.CONTEXT.ENQUIRY,OBSOLETE.ID)
         END
      REPEAT

      RETURN

*-----------------------------------------------------------------------------
WRITE.HISTORY.REC:
* write the live record to the history file

      MAT R.CONTEXT.ENQUIRY = ''
      MATPARSE R.CONTEXT.ENQUIRY FROM R.RECORD
      CALL EB.HIST.REC.WRITE(FN.CONTEXT.ENQUIRY,OBSOLETE.ID,MAT R.CONTEXT.ENQUIRY,C$SYSDIM)
      
      RETURN
*-----------------------------------------------------------------------------
COMPANY.INITIALISATION:
* specific COMPANY initialisation
* open files and read records specific to each company

      UNAUTH.REQD = 1
      HIST.REQD = 0
      PROCESSING.LIVE = 0

      F.CONTEXT.ENQUIRY = ''
      CALL OPF(FN.CONTEXT.ENQUIRY,F.CONTEXT.ENQUIRY)

      LOCATE "$NAU" IN R.FILE.CONTROL<SUFFIXES,1> SETTING YPOS THEN
         UNAUTH.REQD = 1
         F.CONTEXT.ENQUIRY$NAU = ''
         FN.CONTEXT.ENQUIRY.NAU = FN.CONTEXT.ENQUIRY:"$NAU"
         CALL OPF(FN.CONTEXT.ENQUIRY.NAU,F.CONTEXT.ENQUIRY$NAU)
      END

      LOCATE "$HIS" IN R.FILE.CONTROL<SUFFIXES,1> SETTING YPOS THEN
         HIST.REQD = 1
         F.CONTEXT.ENQUIRY$HIS = ''
         FN.CONTEXT.ENQUIRY.HIS = FN.CONTEXT.ENQUIRY:"$HIS"
         CALL OPF(FN.CONTEXT.ENQUIRY.HIS,F.CONTEXT.ENQUIRY$HIS)
      END

      RETURN

*-----------------------------------------------------------------------------
GET.FILE.CLASSIFICATION:
* get file classification
* read from FILE.CONTROL and get list of companies to be converted
      
      R.FILE.CONTROL = ''
      READ R.FILE.CONTROL FROM F.FILE.CONTROL,PGM.NAME ELSE
         CALL FATAL.ERROR('CONV.CONTEXT.ENQUIRY.R7.200706')
      END

      CLASSIFICATION = R.FILE.CONTROL<FILE.CONTROL.CLASS>
      CALL GET.CONVERSION.COMPANIES(CLASSIFICATION,PGM.NAME,COMPANIES)
      
      RETURN
      
*-----------------------------------------------------------------------------
INITIALISATION:
* open files etc

      PGM.NAME = 'CONTEXT.ENQUIRY'   ; * set the name of the application to be converted
      FN.CONTEXT.ENQUIRY = 'F.':PGM.NAME   ; * set the name of the file to be converted, without prefix

*** Add any obsolete CONTEXT.ENQUIRY records to be deleted into the list below:

      OBSOLETE.LIST = ""
      OBSOLETE.LIST<1> = "AM.COMPARE-LINKED.TO"

*** End of list

      DIM R.CONTEXT.ENQUIRY(C$SYSDIM)

      RETURN
      
   END
