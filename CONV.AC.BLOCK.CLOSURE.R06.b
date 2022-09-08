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
* <Rating>306</Rating>
*-----------------------------------------------------------------------------
      $PACKAGE AC.AccountClosure
      SUBROUTINE CONV.AC.BLOCK.CLOSURE.R06
*-----------------------------------------------------------------------------
* Change file id & file layout for AC.BLOCK.CLOSURE. The key is a flaw which
* produces throughput problems, the layout is a problem as the record gets
* huge.
*-----------------------------------------------------------------------------
* Modification History:
*
* 03/11/05 - GLOBUS_CI_10036088
*            Change id & layout of AC.BLOCK.CLOSURE
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.DATES

* Equate field numbers to position manually, do no use $INSERT
      EQU SUFFIXES TO 3
      EQU FILE.CONTROL.CLASS TO 6

      SAVE.ID.COMPANY = ID.COMPANY

      GOSUB INITIALISATION      ;* open files etc

      GOSUB GET.FILE.CLASSIFICATION       ;* get file classification

      LOOP
         REMOVE K.COMPANY FROM COMPANIES SETTING MORE.COMPANIES
      WHILE K.COMPANY:MORE.COMPANIES

         IF K.COMPANY NE ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
         END

         GOSUB COMPANY.INITIALISATION    ;* specific COMPANY initialisation

         GOSUB PROCESS.FILE    ;* perform required action on company file

         IF UNAUTH.REQD THEN
            F.FILENAME = F.FILENAME$NAU
            GOSUB PROCESS.FILE          ;* perform required action on company file
         END

         IF HIST.REQD THEN
            F.FILENAME = F.FILENAME$HIS
            GOSUB PROCESS.FILE          ;* perform required action on company file
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
            IF COUNT(K.ID,'.') = 0 THEN
               CALL SF.CLEAR(1,10,"CONVERTING ":K.ID)
* record has not been converted yet.
               HIS.NO = FIELD(K.ID,';',2)
               ACCOUNT.NUMBER = FIELD(K.ID,';',1)
* perform specific file conversion here
               REASON.LIST = R.RECORD<1>
               SYSTEM.CODE.LIST = R.RECORD<2>
               LOOP
                  REMOVE YREASON FROM REASON.LIST SETTING MORE.CONS
                  REMOVE YSYSTEM.CODE FROM SYSTEM.CODE.LIST SETTING DUMMY
               WHILE YREASON:MORE.CONS
                  IF YSYSTEM.CODE = '' THEN
                     GOSUB GENERATE.UNIQUE.ID
                  END
                  NEW.REC = ''
                  NEW.REC<1> = ACCOUNT.NUMBER   ;* Account
                  NEW.REC<2> = YSYSTEM.CODE     ;* txn Id
                  NEW.REC<3> = YREASON          ;* reason
                  FOR X = 4 TO 17
                     NEW.REC<X> = R.RECORD<X>  ;* reserved/audit fields
                  NEXT X
                  NEW.ID = ACCOUNT.NUMBER:'.':YSYSTEM.CODE
                  IF HIS.NO THEN
                     NEW.ID := ';':HIS.NO
                  END
                  WRITE NEW.REC ON F.FILENAME,NEW.ID
               REPEAT
               DELETE F.FILENAME,K.ID
            END
         END

      REPEAT

      RETURN

*-----------------------------------------------------------------------------
GENERATE.UNIQUE.ID:
* generate a new key for use

      PREFIX = 'ACBLK'
      YSYSTEM.CODE = PREFIX:R.DATES(EB.DAT.JULIAN.DATE)[3,5]:SEQ.NO "R%5"
      FND = @FALSE
      LOOP
         TEST.ID = ACCOUNT.NUMBER:'.':YSYSTEM.CODE
         IF HIS.NO THEN
            TEST.ID := ';':HIS.NO
         END
         READ TEST.REC FROM F.FILENAME,TEST.ID ELSE FND = @TRUE
         SEQ.NO += 1
      UNTIL FND
         YSYSTEM.CODE = PREFIX:R.DATES(EB.DAT.JULIAN.DATE)[3,5]:SEQ.NO "R%5"
      REPEAT

      RETURN

*-----------------------------------------------------------------------------
COMPANY.INITIALISATION:
* specific COMPANY initialisation
* open files and read records specific to each company

      UNAUTH.REQD = 0
      HIST.REQD = 0

      ID = 'F.':PGM.NAME        ;* set the name of the file to be converted, without prefix
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

      SEQ.NO = 1

      RETURN

*-----------------------------------------------------------------------------
GET.FILE.CLASSIFICATION:
* get file classification
* read from FILE.CONTROL and get list of companies to be converted

      R.FILE.CONTROL = ''
      READ R.FILE.CONTROL FROM F.FILE.CONTROL,PGM.NAME ELSE
         CALL FATAL.ERROR('CONV.AC.BLOCK.CLOSURE.R06')
      END

      CLASSIFICATION = R.FILE.CONTROL<FILE.CONTROL.CLASS>
      CALL GET.CONVERSION.COMPANIES(CLASSIFICATION,PGM.NAME,COMPANIES)

      RETURN

*-----------------------------------------------------------------------------
INITIALISATION:
* open files etc

      PGM.NAME = 'AC.BLOCK.CLOSURE'       ;* set the name of the application to be converted

      RETURN

   END
