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
* <Rating>-80</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE IC.OtherInterest
      SUBROUTINE CONV.FILE.CONTROL.200708
*-----------------------------------------------------------------------------
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* where ever possible use the RECORD.ROUTINE to convert/populate record data fields.
*
* Remove SA.PREMIUM.INTEREST.WRK and SA.PRM.INTEREST.WRK
* from FILE.CONTROL if they exist
*
* NB. F.FILE.CONTROL.TEMP is common, so F.FILE.CONTROL.TEMP used here instead
*
*-----------------------------------------------------------------------------
* Modification History:
*
* 20/06/07 - EN_10003366
*            Created.
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

      IF COMPANIES = '' THEN
         COMPANIES = ID.COMPANY
      END

      LOOP
         REMOVE K.COMPANY FROM COMPANIES SETTING MORE.COMPANIES
      WHILE K.COMPANY:MORE.COMPANIES

         IF K.COMPANY NE ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
         END

         GOSUB COMPANY.INITIALISATION   ; * specific COMPANY initialisation

         K.ID = 'SA.PREMIUM.INTEREST.WRK'

         F.FILE.CONTROL.TEMP = F.FILE.CONTROL.TEMP$FULL
         GOSUB PROCESS.FILE   ; * perform required action on company file

         IF UNAUTH.REQD THEN
            F.FILE.CONTROL.TEMP = F.FILE.CONTROL.TEMP$NAU
            GOSUB PROCESS.FILE   ; * perform required action on company file
         END

         IF HIST.REQD THEN
            F.FILE.CONTROL.TEMP = F.FILE.CONTROL.TEMP$HIS
            GOSUB PROCESS.FILE   ; * perform required action on company file
         END

         F.FILE.CONTROL.TEMP = F.FILE.CONTROL.TEMP$FULL
         K.ID = 'SA.PRM.INTEREST.WRK'

         GOSUB PROCESS.FILE   ; * perform required action on company file

         IF UNAUTH.REQD THEN
            F.FILE.CONTROL.TEMP = F.FILE.CONTROL.TEMP$NAU
            GOSUB PROCESS.FILE   ; * perform required action on company file
         END

         IF HIST.REQD THEN
            F.FILE.CONTROL.TEMP = F.FILE.CONTROL.TEMP$HIS
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

* use READ, not F.READ
      READ R.RECORD FROM F.FILE.CONTROL.TEMP,K.ID THEN
* preform specific file conversion here

         DELETE F.FILE.CONTROL.TEMP,K.ID

      END

      RETURN

*-----------------------------------------------------------------------------
COMPANY.INITIALISATION:
* specific COMPANY initialisation
* open files and read records specific to each company

      UNAUTH.REQD = 0
      HIST.REQD = 0

      F.FILE.CONTROL.TEMP$FULL = ''
      CALL OPF(ID,F.FILE.CONTROL.TEMP$FULL)

      LOCATE "$NAU" IN R.FILE.CONTROL<SUFFIXES,1> SETTING YPOS THEN
         UNAUTH.REQD = 1
         F.FILE.CONTROL.TEMP$NAU = ''
         ID.NAU = ID:"$NAU"
         CALL OPF(ID.NAU,F.FILE.CONTROL.TEMP$NAU)
      END

      LOCATE "$HIS" IN R.FILE.CONTROL<SUFFIXES,1> SETTING YPOS THEN
         HIST.REQD = 1
         F.FILE.CONTROL.TEMP$HIS = ''
         ID.HIS = ID:"$HIS"
         CALL OPF(ID.HIS,F.FILE.CONTROL.TEMP$HIS)
      END

      RETURN

*-----------------------------------------------------------------------------
GET.FILE.CLASSIFICATION:
* get file classification
* read from FILE.CONTROL and get list of companies to be converted
      
      R.FILE.CONTROL = ''
      READ R.FILE.CONTROL FROM F.FILE.CONTROL,PGM.NAME ELSE
         CALL FATAL.ERROR('CONV.FILE.CONTROL.200708')
      END

      CLASSIFICATION = R.FILE.CONTROL<FILE.CONTROL.CLASS>
      CALL GET.CONVERSION.COMPANIES(CLASSIFICATION,PGM.NAME,COMPANIES)
      
      RETURN
      
*-----------------------------------------------------------------------------
INITIALISATION:
* open files etc
      
      PGM.NAME = 'FILE.CONTROL'   ; * set the name of the application to be converted
      ID = 'F.':PGM.NAME   ; * set the name of the file to be converted, without prefix

      RETURN
      
   END
