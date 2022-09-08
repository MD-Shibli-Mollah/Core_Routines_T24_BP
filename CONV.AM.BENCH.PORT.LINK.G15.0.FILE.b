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
* <Rating>60</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Benchmark
      SUBROUTINE CONV.AM.BENCH.PORT.LINK.G15.0.FILE
*-----------------------------------------------------------------------------
* Conversion file routine to move all the records from the old INT level file
* to the FIN level file.
*----------------------------------------------------------------------------- 
* Modification History :
*
* 10/05/04 - GLOBUS_EN_10002262
*            New program
*
* 27/05/04 - GLOBUS_BG_100006693
*            ETEXT passed back to RUN.CONVERSION.PGMS as there are no $HIS/$NAU
*            files. Remove $HIS & $NAU processing.
*
* 08/12/08 - BG_100021204
*            Conversion should call jounral update
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

      GOSUB INITIALISE

      SUFFIX = ''   ; * live file
      GOSUB MOVE.INT.TO.FIN

      RETURN

*
*-----------------------------------------------------------------------------
INITIALISE:

      FN.SEC.ACC.MASTER = 'F.SEC.ACC.MASTER'
      F.SEC.ACC.MASTER = ''
      CALL OPF(FN.SEC.ACC.MASTER,F.SEC.ACC.MASTER)

      FN.AM.BENCHMARK = 'F.AM.BENCHMARK'
      F.AM.BENCHMARK = ''
      CALL OPF(FN.AM.BENCHMARK,F.AM.BENCHMARK)

      FILE.TO.CONVERT = 'AM.BENCH.PORT.LINK'
      SAM.FIELD = 1
      AM.BENCHMARK.FIELD = 5

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
            SEC.ACC.MASTER.ID = R.SOURCE<SAM.FIELD,1,1>
            AM.BENCHMARK.ID = R.SOURCE<AM.BENCHMARK.FIELD,1,1>
            SAM.ERR = ''
            AMB.ERR = ''
            IF SEC.ACC.MASTER.ID NE '' THEN
               CALL F.READ(FN.SEC.ACC.MASTER,SEC.ACC.MASTER.ID,R.SEC.ACC.MASTER,F.SEC.ACC.MASTER,SAM.ERR)
            END ELSE
               IF AM.BENCHMARK.ID NE '' THEN
                  CALL F.READ(FN.AM.BENCHMARK,AM.BENCHMARK.ID,R.AM.BENCHMARK,F.AM.BENCHMARK,AMB.ERR)
               END
            END
            IF SAM.ERR = '' AND AMB.ERR = '' THEN
* SAM record exists in this company, and Benchmark exists in this company
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
