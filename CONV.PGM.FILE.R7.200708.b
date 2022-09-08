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
* <Rating>-29</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Foundation
      SUBROUTINE CONV.PGM.FILE.R7.200708
*-----------------------------------------------------------------------------
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* where ever possible use the RECORD.ROUTINE to convert/populate record data fields.
*
* Remove obsolete records from PGM.FILE if they exist.
*
*-----------------------------------------------------------------------------
* Modification History:
*
* 30/03/07 - EN_10003307
*            DX.RV.SERVICE to run from a service activation file.
*            Remove DX.COB.START.SERVICE from PGM.FILE
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

         GOSUB PROCESS.FILE   ; * perform required action on company file

         IF UNAUTH.REQD THEN
            F.PGM.FILE = F.PGM.FILE$NAU
            GOSUB PROCESS.FILE   ; * perform required action on company file
         END

         IF HIST.REQD THEN
            F.PGM.FILE = F.PGM.FILE$HIS
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

* look for obsolete records.

      OBSOLETE.RECORDS = "DX.COB.START.SERVICE"

      SELECT F.PGM.FILE
      END.OF.LIST = 0

      LOOP
         READNEXT K.ID ELSE
            END.OF.LIST = 1
         END
      UNTIL END.OF.LIST
         FOR OB.REC = 1 TO 2  
            IF FIELD(K.ID,";",1) = OBSOLETE.RECORDS<OB.REC> THEN
         
* use READ, not F.READ
               READ R.RECORD FROM F.PGM.FILE,K.ID THEN
* preform specific file conversion here

* Just delete the record as it is obsolete.

                  DELETE F.PGM.FILE, K.ID

               END

            END
         NEXT OB.REC

      REPEAT

      RETURN

*-----------------------------------------------------------------------------
COMPANY.INITIALISATION:
* specific COMPANY initialisation
* open files and read records specific to each company

      UNAUTH.REQD = 0
      HIST.REQD = 0

      F.PGM.FILE = ''
      CALL OPF(ID,F.PGM.FILE)

      LOCATE "$NAU" IN R.FILE.CONTROL<SUFFIXES,1> SETTING YPOS THEN
         UNAUTH.REQD = 1
         F.PGM.FILE$NAU = ''
         ID.NAU = ID:"$NAU"
         CALL OPF(ID.NAU,F.PGM.FILE$NAU)
      END

      LOCATE "$HIS" IN R.FILE.CONTROL<SUFFIXES,1> SETTING YPOS THEN
         HIST.REQD = 1
         F.PGM.FILE$HIS = ''
         ID.HIS = ID:"$HIS"
         CALL OPF(ID.HIS,F.PGM.FILE$HIS)
      END

      RETURN

*-----------------------------------------------------------------------------
GET.FILE.CLASSIFICATION:
* get file classification
* read from FILE.CONTROL and get list of companies to be converted
      
      R.FILE.CONTROL = ''
      READ R.FILE.CONTROL FROM F.FILE.CONTROL,PGM.NAME ELSE
         CALL FATAL.ERROR('CONV.PGM.FILE.R7.200708')
      END

      CLASSIFICATION = R.FILE.CONTROL<FILE.CONTROL.CLASS>
      CALL GET.CONVERSION.COMPANIES(CLASSIFICATION,PGM.NAME,COMPANIES)
      
      RETURN
      
*-----------------------------------------------------------------------------
INITIALISATION:
* open files etc
      
      PGM.NAME = 'PGM.FILE'   ; * set the name of the application to be converted
      ID = 'F.':PGM.NAME   ; * set the name of the file to be converted, without prefix

      RETURN
      
   END
