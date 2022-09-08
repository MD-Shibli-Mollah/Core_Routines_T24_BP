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

* Version n dd/mm/yy  GLOBUS Release No. R05.007 30/05/06
*-----------------------------------------------------------------------------
* <Rating>1248</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Foundation
      SUBROUTINE CONV.AM.BATCH.FILE.LEVEL.R08
*
****************************************************************************
* Convert the following AM batch files from single company to multi-company
*
* AM.GROUP.PERF
* AM.REP.EXTRACTION
* EOD.BENCHMARK.PERF
*
* If the record exists only for the master company or as non-company,
* copy it to XXX/jobname where XXX is company mnemonic for each company.
*
****************************************************************************
* Modifications
*
* 08/07/06 - BG_100014142
*            Remove condition on contents of INPUTTER field so that INAU
*            record can be copied to secondary company.
*
****************************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.BATCH
$INSERT I_F.COMPANY
$INSERT I_F.COMPANY.CHECK
*
* This conversion will create AM batch records
* in each company in a multi-co site. The job has effectively moved
* from INT to FIN as BATCH.NEW.COMPANY record was not released.
*
      F.BATCH = ''
      CALL OPF("F.BATCH", F.BATCH)
      F.BATCH$HIS = ""
      CALL OPF("F.BATCH$HIS", F.BATCH$HIS)

* BG_100005037 S
      F.BATCH$NAU = ''
      CALL OPF("F.BATCH$NAU", F.BATCH$NAU)
* BG_100005037 E

      F.COMPANY = ''
      CALL OPF("F.COMPANY", F.COMPANY)
      F.COMPANY.CHECK = ''
      CALL OPF("F.COMPANY.CHECK", F.COMPANY.CHECK)
*
      MASTER.CO.REC = ''
      READ MASTER.CO.REC FROM F.COMPANY.CHECK, "MASTER" ELSE MASTER.CO.REC = ''
      MASTER.CO.MNE = MASTER.CO.REC<EB.COC.COMPANY.MNE>
      IF MASTER.CO.MNE = '' THEN MASTER.CO.MNE = "BNK"
*
      ID.LIST = "AM.GROUP.PERF":FM:"AM.REP.EXTRACTION":FM:"EOD.BENCHMARK.PERF"
*
      TIME.STAMP = TIMEDATE()
      X = OCONV(DATE(),"D-")
      X = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]         ; * Date time for Write
*
      LOOP
         REMOVE BATCH.ID FROM ID.LIST SETTING YD
      WHILE BATCH.ID:YD
         MAIN.BATCH = '' ; R.MAIN.BATCH = '' ; R.MAIN.NAU.BATCH = ''
         DO.CONVERT = 0
         MB.ID = BATCH.ID
         READ R.MAIN.BATCH FROM F.BATCH, MB.ID THEN
            DO.CONVERT = 1
         END ELSE
            MB.ID = MASTER.CO.MNE:"/":BATCH.ID
            READ R.MAIN.BATCH FROM F.BATCH, MB.ID THEN
               DO.CONVERT = 1
            END
         END
         IF DO.CONVERT THEN
            READ R.MAIN.NAU.BATCH FROM F.BATCH$NAU, MB.ID ELSE R.MAIN.NAU.BATCH = ''
*
** Convert to each company
*
            SEL.STMT = "SELECT F.COMPANY WITH CONSOLIDATION.MARK NE 'C'"
            CO.LIST = ""
            NO.SEL = ''
            CALL EB.READLIST(SEL.STMT, CO.LIST, "", NO.SEL, "")
*
            IF NO.SEL GT 1 THEN       ; * If 1 it is single company
               LOOP
                  REMOVE CO.CODE FROM CO.LIST SETTING YD
               WHILE CO.CODE:YD
                  IF CO.CODE NE ID.COMPANY THEN
                     READ COMP.REC FROM F.COMPANY, CO.CODE THEN ELSE COMP.REC = ''
                  END ELSE
                     MATBUILD COMP.REC FROM R.COMPANY
                  END
                  COMP.MNE = COMP.REC<3>        ; * Company mnemonic
                  IF COMP.REC<33> = COMP.MNE THEN         ; * Only create for non shared FIN files FINAN.FINAN.MNE
                     IF COMP.MNE THEN
                        NEW.COMP.ID = COMP.MNE:"/":BATCH.ID 

* If there is an existing unauthorised record then don't do anything

                        R.NAU.BATCH = ""
                        READ R.NAU.BATCH FROM F.BATCH$NAU, NEW.COMP.ID ELSE R.NAU.BATCH = ""
                        IF R.NAU.BATCH = "" THEN
                           GOSUB UPDATE.BATCH.RECORD
                        END
                     END
                  END

               REPEAT

            END
         END

      REPEAT

      RETURN

*--------------
UPDATE.BATCH.RECORD:
*--------------

* If there exits a unauthorised mater company batch record
* then copy the record to the other company

      READ NEW.BATCH.REC FROM F.BATCH, NEW.COMP.ID ELSE

         IF (R.MAIN.NAU.BATCH<16> EQ "INAU") THEN
            NEW.BATCH.REC = R.MAIN.NAU.BATCH
            GOSUB UPDATE.RECORD.FIELDS
         END ELSE
            NEW.BATCH.REC = R.MAIN.BATCH
            GOSUB UPDATE.RECORD.FIELDS
         END
      END

      RETURN

*-------------------
UPDATE.RECORD.FIELDS:
*-------------------

      NEW.BATCH.REC<9> = '' ; *                             Next run date
      NEW.BATCH.REC<13> = '' ; *                            Last run date
      NEW.BATCH.REC<14> = '' ; *                            Job message
      NEW.BATCH.REC<15> = '' ; *                            User
      NEW.BATCH.REC<16> = 'INAU' ; *                        Record Status
      NEW.BATCH.REC<17> = 1 ; *                             Curr No
      NEW.BATCH.REC<18> = "SY_CONV.AM.BATCH.LEVEL.R08"  ; * Inputter
      NEW.BATCH.REC<19> = X ; *                             Date Time
      NEW.BATCH.REC<20> = '' ; *                            Authoriser
      NEW.BATCH.REC<21> = CO.CODE ; *                       Company Code
      NEW.BATCH.REC<22> = '' ; *                            Dept Code
      NEW.BATCH.REC<23> = '' ; *                            Auditor Code
      NEW.BATCH.REC<24> = '' ; *                            Audit Date Time

      WRITE NEW.BATCH.REC TO F.BATCH$NAU, NEW.COMP.ID

      RETURN

   END
