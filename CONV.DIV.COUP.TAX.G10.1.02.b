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
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SccClassicCA
      SUBROUTINE CONV.DIV.COUP.TAX.G10.1.02

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY

*
** This routine will be responsible to delete the files
** remaining
*
      F.VOC = ''
      OPEN '','VOC' TO F.VOC ELSE
         ABORT "UNABLE TO OPEN VOC"
      END
*
      F.COMPANY = ''
      CALL OPF('F.COMPANY',F.COMPANY)
*
      SEL.CMD = 'SSELECT F.COMPANY'
      COM.LIST = ''
      YSEL = 0
      CALL EB.READLIST(SEL.CMD,COM.LIST,'',YSEL,'')
*
      FOR I = 1 TO 3
*
         BEGIN CASE
            CASE I = 1
               SUFFIX = ""
            CASE I = 2
               SUFFIX = "$NAU"
            CASE I = 3
               SUFFIX = "$HIS"
         END CASE
*
         WORK.COM.LIST = COM.LIST
*
         LOOP
            REMOVE K.COMPANY FROM WORK.COM.LIST SETTING END.OF.COMPANIES
         WHILE K.COMPANY:END.OF.COMPANIES
            READ COMPANY.REC FROM F.COMPANY,K.COMPANY THEN
               LOCATE 'SC' IN COMPANY.REC<EB.COM.APPLICATIONS,1> SETTING POSN THEN
                  MNEMONIC = COMPANY.REC<EB.COM.MNEMONIC>
                  YFILE = 'F':MNEMONIC:'.DIV.COUP.TAX':SUFFIX
                  GOSUB MODIFY.FILE
               END
            END
         REPEAT
*
         YFILE = "F.DIV.COUP.TAX":SUFFIX
         GOSUB DELETE.OLD.FILE
*
      NEXT I
*
      RETURN
*
************
MODIFY.FILE:
************
*
      ETEXT = ""
      FN.TRANSACTION = "F":MNEMONIC:".TRANSACTION"
      F.TRANSACTION = ""
*
** If the TRANSACTION file is not found then this file should not exist
*
      OPEN '',FN.TRANSACTION TO F.TRANSACTION THEN
         GOSUB COPY.FILE.RECORDS
      END

      RETURN
*
*****************
COPY.FILE.RECORDS:
*****************

      COPY.CMD = "COPY FROM F.DIV.COUP.TAX":SUFFIX:" TO ":YFILE:" ALL"
      EXECUTE COPY.CMD

      RETURN
*
****************
DELETE.OLD.FILE:
****************
*
*
* Read the VOC entry for the file
*
      R.VOC = ''
      READU R.VOC FROM F.VOC, YFILE LOCKED
         NULL
      END ELSE
         ABORT "COULD NOT READ VOC RECORD ":YFILE
      END
*
** Remove file from SYSTEM
*
      FILE.PATH = R.VOC<2>
      COMMAND.TYPE = "REMOVE"
      PARAMS = FILE.PATH:"/":YFILE
      CALL SYSTEM.CALL(COMMAND.TYPE,"",PARAMS,"",RESULT.CODE)
*
** Remove the VOC record
*
      DELETE F.VOC, YFILE

      RETURN

   END
*
