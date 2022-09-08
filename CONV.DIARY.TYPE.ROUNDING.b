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

* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>89</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SccEventCapture
      SUBROUTINE CONV.DIARY.TYPE.ROUNDING

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.DIARY.TYPE

      FN.FILE = 'F.DIARY.TYPE'
      F.FILE = ''
      CALL OPF(FN.FILE,F.FILE)
      GOSUB PROCESS.FILE
      FN.FILE = 'F.DIARY.TYPE$NAU'
      F.FILE = ''
      CALL OPF(FN.FILE,F.FILE)
      GOSUB PROCESS.FILE
      FN.FILE = 'F.DIARY.TYPE$HIS'
      F.FILE = ''
      CALL OPF(FN.FILE,F.FILE)
      GOSUB PROCESS.FILE
*
      RETURN
*
*************
PROCESS.FILE:
*************
*
      LIST = ''
      CMD = 'SSELECT ':FN.FILE
      CALL EB.READLIST(CMD,LIST,'','','')
      IF NOT(LIST) THEN RETURN
*
      LOOP
         REMOVE CODE FROM LIST SETTING MORE

      WHILE CODE DO

         CALL F.READU(FN.FILE,CODE,R.FILE,F.FILE,ER,'R 05 12')
         IF ER THEN
            E = 'RECORD & NOT FOUND ON FILE & ':FM:CODE:VM:F.FILE
            CALL FATAL.ERROR("CONV.DIARY.TYPE.ROUNDING")
         END

         IF R.FILE<SC.DRY.ROUNDING>[1,1] = "Y" THEN
            R.FILE<SC.DRY.ROUNDING> = "DOWN"
         END ELSE
            R.FILE<SC.DRY.ROUNDING> = "STANDARD"
         END
*
         R.FILE<SC.DRY.ROUNDING.LEVEL> = "CUSTOMER"
*
         IF R.FILE<SC.DRY.AUTO.ENTITLE> = "" THEN
            R.FILE<SC.DRY.AUTO.ENTITLE> = "YES"
         END

         IF R.FILE<SC.DRY.DIARY.CREATE> = "" THEN
            R.FILE<SC.DRY.DIARY.CREATE> = "AUT"
         END
*
         CALL F.WRITE(FN.FILE,CODE,R.FILE)
         CALL JOURNAL.UPDATE(CODE)

      REPEAT
*
      RETURN
*
   END
