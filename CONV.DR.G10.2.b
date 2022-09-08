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

* Version 4 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>221</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Delivery
      SUBROUTINE CONV.DR.G10.2(DR.ID, R.DR, F.DR)

$INSERT I_COMMON
$INSERT I_EQUATE

      *// EB.ADVICES
      EQU EB.ADV.MESSAGE.TYPE TO 2
      EQU EB.ADV.MSG.CLASS TO 3

      EQU VALUE.DATE TO 11
      EQU EB.ADV.SCHEDS TO 163
      EQU EB.CLASS.SCHEDS TO 164
      EQU EB.ACT.NOS TO 165
      EQU EB.CLASS.SENT TO 168

      *// Rebuild message level schedule
*      PRINT
*      FOR I = EB.ADV.SCHEDS TO 170
*         PRINT "R.DR<":I:"> : ":R.DR<I>
*      NEXT I

      FN.ADV = 'F.EB.ADVICES'
      F.ADV = ''
      CALL OPF(FN.ADV, F.ADV)

      FN$NAU.ADV = 'F.EB.ADVICES$NAU'
      F$NAU.ADV = ''
      CALL OPF(FN$NAU.ADV, F$NAU.ADV)

      ADV.SCHED = ''
      CLASS.SCHED = ''
      ACTIVITY.SENT = R.DR<162>

      IF R.DR<EB.ADV.SCHEDS> THEN
         ADV.SCHED = R.DR<EB.ADV.SCHEDS>
         CLASS.SCHED = R.DR<EB.CLASS.SCHEDS>
      END ELSE
         FOR ICNT = 1 TO DCOUNT(R.DR<EB.ACT.NOS>,VM)
            ADV.NO = R.DR<EB.ACT.NOS,ICNT>
            ADV.SCHED<1,-1> = R.DR<VALUE.DATE> :".0.":ADV.NO
            CLASS.SCHED<1,ICNT,-1> = R.DR<EB.CLASS.SENT,ICNT>
         NEXT ICNT
      END
*      IF R.DR<141> THEN
*         FOR I = 132 TO 138
*            PRINT "R.DR<":I:"> : ":R.DR<I>
*         NEXT I
*      END
*      MSG.SCH.LIST = ''
      ACT.SENT.LIST = ''
      ADV.LIST = ''
      MSG.LIST = ''
      CLASS.LIST = ''
      DATE.LIST = ''
      SEND.LIST = ''
      FOR I = 1 TO DCOUNT(ADV.SCHED,@VM)
         ADV.NO = ADV.SCHED<1,I>
         ADV.DATE = ADV.NO['.',1,1]      ; * Extract date
         ADV.NO = ADV.NO['.',3,1]        ; * Extract ADVICE.NO
         CLASS = CLASS.SCHED<1,I>
         R.ADV = ''
         CALL F.READ(FN$NAU.ADV, ADV.NO, R.ADV, F$NAU.ADV, YERR)
         IF YERR THEN
            YERR = ''
            CALL F.READ(FN.ADV, ADV.NO, R.ADV, F.ADV, YERR)
            IF YERR THEN RETURN
         END
         CLASSES = R.ADV<EB.ADV.MSG.CLASS>
         MESSAGE.LIST = R.ADV<EB.ADV.MESSAGE.TYPE>
         FOR J = 1 TO DCOUNT(CLASS, @SM)
            CLASS.NO = CLASS<1,1,J>
            LOCATE CLASS.NO IN CLASSES<1,1> SETTING POS THEN
               ADV.LIST<1,-1> = ADV.NO
               MSG.NO = MESSAGE.LIST<1,POS>
*               MSG.SCHED = ADV.DATE:".MT":MSG.NO:'.':CLASS.NO
*               MSG.SCH.LIST<1,-1> = MSG.SCHED
               MSG.LIST<1,-1> = MSG.NO
               CLASS.LIST<1,-1> = CLASS.NO
               IF ADV.DATE = '' THEN ADV.DATE = R.DR<7>
               DATE.LIST<1,-1> = ADV.DATE
               SEND.LIST<1,-1> = 'YES'
               GOSUB UPDATE.ACTIVITY.SENT
            END
         NEXT J
      NEXT I
*      PRINT
*      FOR I = 160 TO 170
*         PRINT "R.DR<":I:"> : ":R.DR<I>
*      NEXT I
      R.DR<162> = ''
      R.DR<163> = ACT.SENT.LIST
      R.DR<164> = ADV.LIST
      R.DR<165> = MSG.LIST
      R.DR<166> = CLASS.LIST
      R.DR<167> = DATE.LIST
      R.DR<168> = ''
      R.DR<169> = ''
      R.DR<170> = SEND.LIST
*      FOR I = 160 TO 170
*         PRINT "R.DR<":I:"> : ":R.DR<I>
*      NEXT I
      RETURN

UPDATE.ACTIVITY.SENT:
      ACT.SENT = ADV.DATE:'.':ADV.NO
      LOCATE ACT.SENT IN ACTIVITY.SENT<1,1> SETTING APOS THEN
         ACT.SENT.LIST<1,-1>=ADV.NO:".":MSG.NO:".":CLASS.NO:".":ADV.DATE
      END
      RETURN

   END
