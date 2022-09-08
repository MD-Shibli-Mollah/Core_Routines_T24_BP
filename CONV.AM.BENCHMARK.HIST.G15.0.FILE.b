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

* Version 3 02/06/00  GLOBUS Release No. G14.1.01 04/12/03
*-----------------------------------------------------------------------------
* <Rating>8</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Benchmark
      SUBROUTINE CONV.AM.BENCHMARK.HIST.G15.0.FILE
*-----------------------------------------------------------------------------
* Conversion file routine to move all the records from the old INT level file
* to the FIN level file.
*----------------------------------------------------------------------------- 
* Modification History :
*
* 10/05/04 - GLOBUS_EN_10002262
*            New program
*
* 08/12/08 - BG_100021204
*            Conversion should call journal updates
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

      GOSUB INITIALISE

      SUFFIX = ''   ; * live file
      GOSUB MOVE.INT.TO.FIN

      SUFFIX = '$NAU'   ; * unauthorised file
      GOSUB MOVE.INT.TO.FIN

      SUFFIX = '$HIS'   ; * history file
      GOSUB MOVE.INT.TO.FIN

      RETURN

*
*-----------------------------------------------------------------------------
INITIALISE:

      FN.AM.BENCH.INDICES = 'F.AM.BENCH.INDICES'
      F.AM.BENCH.INDICES = ''
      CALL OPF(FN.AM.BENCH.INDICES,F.AM.BENCH.INDICES)

      FILE.TO.CONVERT = 'AM.BENCHMARK.HIST'
      ABI.FIELD = 6
      ABI.FIELD2 = 15

      RETURN
*
*-----------------------------------------------------------------------------
MOVE.INT.TO.FIN:
* open the files, both source and destination, if opened ok then move the
* records depending on the SAM record.

      FN.INT.FILE = 'F.':FILE.TO.CONVERT:SUFFIX
      OPEN FN.INT.FILE TO F.INT.FILE ELSE
         ETEXT = 'CANNOT OPEN ':FN.INT.FILE
      END

      IF ETEXT = '' THEN
         FN.FIN.FILE = 'F.':FILE.TO.CONVERT:SUFFIX
         F.FIN.FILE = ''
         CALL OPF(FN.FIN.FILE:FM:'NO.FATAL.ERROR',F.FIN.FILE)
      END

      IF ETEXT = '' THEN
         GOSUB DO.THE.MOVE
      END

      RETURN

*-----------------------------------------------------------------------------
DO.THE.MOVE:
* select the source file and do the move,

      CMMD = 'SELECT ':FN.INT.FILE
      CALL EB.READLIST(CMMD,SOURCE.LIST,'','','')

      LOOP
         REMOVE SOURCE.ID FROM SOURCE.LIST SETTING MORE.SOURCE
      WHILE SOURCE.ID:MORE.SOURCE
         YERR = ''
         READ R.SOURCE FROM F.INT.FILE,SOURCE.ID ELSE
* use READ as F.READ doesn't work, it tries to read from FBNK...
            YERR = 'RECORD NOT FOUND'
         END
         IF YERR = '' THEN
* Check that the record did exist!
            AM.BENCH.INDICES.ID = R.SOURCE<ABI.FIELD,1,1>
            IF AM.BENCH.INDICES.ID = '' THEN
               AM.BENCH.INDICES.ID = R.SOURCE<ABI.FIELD2,1,1>
            END
            ABI.ERR = ''
            IF AM.BENCH.INDICES.ID NE '' THEN
               CALL F.READ(FN.AM.BENCH.INDICES,AM.BENCH.INDICES.ID,R.AM.BENCH.INDICES,F.AM.BENCH.INDICES,ABI.ERR)
            END
            IF ABI.ERR = '' THEN
* AM.BENCHMARK record exists in this company, or is not set
               FIN.ERR = ''
               CALL F.READ(FN.FIN.FILE,SOURCE.ID,R.DESTINATION,F.FIN.FILE,FIN.ERR)
               IF FIN.ERR NE '' THEN
* only do the write if the record doesn't already exist (perhaps the conversion crashed?!)
                  CALL F.WRITE(FN.FIN.FILE,SOURCE.ID,R.SOURCE)
               END
            END
         END
      REPEAT
      CALL JOURNAL.UPDATE("") ; * we have to call this, since run.conversion.pgms does not call journal update
      RETURN

   END
