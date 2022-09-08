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

* Version 4 27/03/00  GLOBUS Release No. G13.1.00 31/10/02
*-----------------------------------------------------------------------------
* <Rating>468</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Schedules
      SUBROUTINE CONV.DRAW.SCH.G10.1.02(DR.ID, R.RECORD, FILE.ID)

*
* Description
* -----------
*        This record level program will be called during the
* drawing conversion process. Basically, it will populate the
* DRAW.SCHEDULES records and update the ADVIS.SCHEDULE and
* CLASS.SCHED fields respectively.
*
*
* 07/04/11 - Task - 187183
*            Remove PRINT statements
*            Defect - 185987
*
*------------------------------------------------------------------
*
$INSERT I_EQUATE

      EQU TF.DR.DRAWING.TYPE TO 1
      EQU TF.DR.MATURITY.REVIEW TO 7
      EQU TF.DR.DISCOUNT.AMT TO 14
      EQU TF.DR.REIMBURSE.SENT TO 85
      EQU TF.DR.LC.CREDIT.TYPE TO 95
      EQU TF.DR.ACTIVITY.SENT TO 117
      EQU TF.DR.ADVIS.SCHEDULE TO 118
      EQU TF.DR.RECORD.STATUS TO 126
      EQU TF.LC.AUDIT.DATE.TIME TO 196

      *// No History Update
      IF INDEX(DR.ID,';',1) THEN RETURN
      IF R.RECORD<TF.DR.RECORD.STATUS> # '' THEN RETURN

      *// Only for Usance Payment
      IF R.RECORD<TF.DR.DRAWING.TYPE> MATCH 'AC':VM:'DP' THEN
         GOSUB PROCESS.DRAWINGS
      END
      RETURN

PROCESS.DRAWINGS:
      GOSUB INITIALIZE
      CALL CONV.DR.DEL(R.RECORD, R.LC, R.TYPE, R.PARA, DR.ID)
      RETURN

INITIALIZE:
      LC.TYPE = R.RECORD<TF.DR.LC.CREDIT.TYPE>

      FN.LC = 'F.LETTER.OF.CREDIT'
      F.LC = ''
      R.LC = ''
      CALL OPF(FN.LC, F.LC)

      FN.PARA = 'F.LC.PARAMETERS'
      F.PARA = ''
      R.PARA = ''
      CALL OPF(FN.PARA, F.PARA)

      FN.TYPE = 'F.LC.TYPES'
      F.TYPE = ''
      R.TYPE = ''
      CALL OPF(FN.TYPE, F.TYPE)

      READ R.LC FROM F.LC, DR.ID[1,12] ELSE
         GOTO PROG.ABORT
      END

      READ R.PARA FROM F.PARA, 'SYSTEM' ELSE
         GOTO PROG.ABORT
      END

      READ R.TYPE FROM F.TYPE, LC.TYPE ELSE
         GOTO PROG.ABORT
      END
      RETURN

PROG.ABORT:
      RETURN TO PROG.ABORT
      RETURN

   END
