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
    $PACKAGE EB.SystemTables
      SUBROUTINE CONV.EB.PRODUCT.R7.200610
*-----------------------------------------------------------------------------
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* where ever possible use the RECORD.ROUTINE to convert/populate record data fields.
*
* Remove product 'FF' from EB.PRODUCT if it exists.
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

         GOSUB PROCESS.FILE   ; * perform required action on company file

         IF UNAUTH.REQD THEN
            F.EB.PRODUCT = F.EB.PRODUCT$NAU
            GOSUB PROCESS.FILE   ; * perform required action on company file
         END

         IF HIST.REQD THEN
            F.EB.PRODUCT = F.EB.PRODUCT$HIS
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

* look for 'FF' only.

      K.ID = 'FF'
         
* use READ, not F.READ
      READ R.RECORD FROM F.EB.PRODUCT,K.ID THEN
* preform specific file conversion here

* Just delete the record as there is no code against this product anyway, so
* there is no point in keeping the EB.PRODUCT record if it exists.

         DELETE F.EB.PRODUCT, K.ID

      END

      RETURN

*-----------------------------------------------------------------------------
COMPANY.INITIALISATION:
* specific COMPANY initialisation
* open files and read records specific to each company

      UNAUTH.REQD = 0
      HIST.REQD = 0

      F.EB.PRODUCT = ''
      CALL OPF(ID,F.EB.PRODUCT)

      LOCATE "$NAU" IN R.FILE.CONTROL<SUFFIXES,1> SETTING YPOS THEN
         UNAUTH.REQD = 1
         F.EB.PRODUCT$NAU = ''
         ID.NAU = ID:"$NAU"
         CALL OPF(ID.NAU,F.EB.PRODUCT$NAU)
      END

      LOCATE "$HIS" IN R.FILE.CONTROL<SUFFIXES,1> SETTING YPOS THEN
         HIST.REQD = 1
         F.EB.PRODUCT$HIS = ''
         ID.HIS = ID:"$HIS"
         CALL OPF(ID.HIS,F.EB.PRODUCT$HIS)
      END

      RETURN

*-----------------------------------------------------------------------------
GET.FILE.CLASSIFICATION:
* get file classification
* read from FILE.CONTROL and get list of companies to be converted
      
      R.FILE.CONTROL = ''
      READ R.FILE.CONTROL FROM F.FILE.CONTROL,PGM.NAME ELSE
         CALL FATAL.ERROR('CONV.EB.PRODUCT.R7.200610')
      END

      CLASSIFICATION = R.FILE.CONTROL<FILE.CONTROL.CLASS>
      CALL GET.CONVERSION.COMPANIES(CLASSIFICATION,PGM.NAME,COMPANIES)
      
      RETURN
      
*-----------------------------------------------------------------------------
INITIALISATION:
* open files etc
      
      PGM.NAME = 'EB.PRODUCT'   ; * set the name of the application to be converted
      ID = 'F.':PGM.NAME   ; * set the name of the file to be converted, without prefix

      RETURN
      
   END
