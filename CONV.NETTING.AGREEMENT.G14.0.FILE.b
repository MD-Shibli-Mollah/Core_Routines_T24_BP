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
* <Rating>167</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.PaymentNetting
      SUBROUTINE CONV.NETTING.AGREEMENT.G14.0.FILE
*-----------------------------------------------------------------------------
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* where ever possible use the RECORD.ROUTINE to convert/populate record data fields.
*-----------------------------------------------------------------------------
* M O D I F I C A T I O N S
*-----------------------------------------------------------------------------
* 03/04/03 - GLOBUS_EN_10001681 - Netting of REPO Contracts
*            The field SYSTEM.ID will be removed & made part of the key, ie if there is FX & FT
*            in the SYSTEM.ID field for record 100500, then 2 new records will be created
*            100500.FT & 100500.FX, both containing the same data as the original except the
*            SYSTEM.ID field which will be nulled. The original record will be deleted.
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

* Equate field numbers to position manually, do no use $INSERT
      EQU SUFFIXES TO 3
      EQU FILE.CONTROL.CLASS TO 6

      SAVE.ID.COMPANY = ID.COMPANY

      GOSUB INITIALISATION               ; * open files etc

      GOSUB GET.FILE.CLASSIFICATION      ; * get file classification

      LOOP
         REMOVE K.COMPANY FROM COMPANIES SETTING MORE.COMPANIES
      WHILE K.COMPANY:MORE.COMPANIES

         IF K.COMPANY NE ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
         END

         GOSUB COMPANY.INITIALISATION    ; * specific COMPANY initialisation

         GOSUB PROCESS.FILE              ; * perform required action on company file

         IF UNAUTH.REQD THEN
            F.FILENAME = F.FILENAME$NAU
            GOSUB PROCESS.FILE           ; * perform required action on company file
         END

         IF HIST.REQD THEN
            F.FILENAME = F.FILENAME$HIS
            PROCESSING.HIST = @TRUE
            GOSUB PROCESS.FILE           ; * perform required action on company file
         END

      REPEAT

      IF ID.COMPANY NE SAVE.ID.COMPANY THEN
         CALL LOAD.COMPANY(SAVE.ID.COMPANY)
      END

      RETURN

*-----------------------------------------------------------------------------
PROCESS.FILE:
* perform required action on company specific file

* do not use EB.READLIST as large volumes can cause hanging
      SELECT F.FILENAME
      END.OF.LIST = 0

      LOOP
         READNEXT K.ID ELSE END.OF.LIST = 1
      UNTIL END.OF.LIST

* use READ, not F.READ
         READ R.RECORD FROM F.FILENAME,K.ID THEN
* preform specific file conversion here

            APPLICATION.LIST = R.RECORD<OLD.SYSTEM.ID>       ; * the program will loop through each application
            IF APPLICATION.LIST THEN
               R.RECORD<OLD.SYSTEM.ID> = ''        ; * This field will be set to reserved so set it to null
               LOOP
                  REMOVE K.SYSTEM.ID FROM APPLICATION.LIST SETTING MORE.RECORDS
               WHILE K.SYSTEM.ID:MORE.RECORDS DO
                  IF PROCESSING.HIST THEN
                     K.MAIN.ID = FIELD(K.ID, ';', 1)
                     K.HIST.ID = FIELD(K.ID, ';', 2)
                     NEW.ID = K.MAIN.ID:'.':K.SYSTEM.ID:';':K.HIST.ID
                  END ELSE
                     NEW.ID = K.ID:'.':K.SYSTEM.ID
                  END
                  WRITE R.RECORD ON F.FILENAME, NEW.ID       ; * Write the new record
               REPEAT
               DELETE F.FILENAME, K.ID   ; * Delete the Old Record
            END
         END

      REPEAT

      RETURN

*-----------------------------------------------------------------------------
COMPANY.INITIALISATION:
* specific COMPANY initialisation
* open files and read records specific to each company

      UNAUTH.REQD = 0
      HIST.REQD = 0

      F.FILENAME = ''
      CALL OPF(ID,F.FILENAME)

      LOCATE "$NAU" IN R.FILE.CONTROL<SUFFIXES,1> SETTING YPOS THEN
         UNAUTH.REQD = 1
         F.FILENAME$NAU = ''
         ID.NAU = ID:"$NAU"
         CALL OPF(ID.NAU,F.FILENAME$NAU)
      END

      LOCATE "$HIS" IN R.FILE.CONTROL<SUFFIXES,1> SETTING YPOS THEN
         HIST.REQD = 1
         F.FILENAME$HIS = ''
         ID.HIS = ID:"$HIS"
         CALL OPF(ID.HIS,F.FILENAME$HIS)
      END

      RETURN

*-----------------------------------------------------------------------------
GET.FILE.CLASSIFICATION:
* get file classification
* read from FILE.CONTROL and get list of companies to be converted

      R.FILE.CONTROL = ''
      READ R.FILE.CONTROL FROM F.FILE.CONTROL,PGM.NAME ELSE
         CALL FATAL.ERROR('CONV.FILE.ROUTINE.TEMPLATE')
      END

      CLASSIFICATION = R.FILE.CONTROL<FILE.CONTROL.CLASS>
      CALL GET.CONVERSION.COMPANIES(CLASSIFICATION,PGM.NAME,COMPANIES)

      RETURN

*-----------------------------------------------------------------------------
INITIALISATION:
* open files etc

      PGM.NAME = 'NETTING.AGREEMENT'     ; * set the name of the application to be converted
      ID = 'F.':PGM.NAME                 ; * set the name of the file to be converted, without prefix

      OLD.SYSTEM.ID = 5
      PROCESSING.HIST = @FALSE

      RETURN

*-----------------------------------------------------------------------------
   END
