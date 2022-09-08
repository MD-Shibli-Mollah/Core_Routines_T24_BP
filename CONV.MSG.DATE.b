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

* Version 3 14/03/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>780</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Delivery
      SUBROUTINE CONV.MSG.DATE (DR.ID,R.DR,YFILLE)
$INSERT I_COMMON
$INSERT I_EQUATE
*This routine converts the MSG.SEND.DATE from MATURITY.REVIEW
* date to the date based on the days in EB.ACTIVITY,
* LC.PARAMETERS or CURRENCY. Also this routine updates
* DRAW.SCHEDULES
*
      EQU TF.DR.DRAWING.TYPE TO 1
      EQU TF.DR.DRAW.CURRENCY TO 2
      EQU TF.DR.MSG.SEND.DATE TO 167
      EQU TF.DR.EB.ADV.NO TO 164
      EQU TF.DR.MATURITY.REVIEW TO 7
      EQU LC.PARA.REIMBURSE.DAYS TO 3
      EQU EB.ACT.DAYS.PRIOR.EVENT TO 2
      EQU EB.CUR.DAYS.DELIVERY TO 7
      EQU EB.COM.LOCAL.COUNTRY TO 14
      EQU TF.DR.DISCOUNT.AMT TO 14
      EQU TF.DR.VALUE.DATE TO 11
*
      IF FILE.TYPE NE 1 THEN RETURN
      TRUE = 1
      FALSE = 0
      DR.TYPE = R.DR<TF.DR.DRAWING.TYPE>
      IF DR.TYPE NE 'AC' AND DR.TYPE NE 'DP' THEN RETURN
      GOSUB INITIALISE
      NO.OF.MSG = DCOUNT(R.DR<TF.DR.EB.ADV.NO>,VM)
      FOR I = 1 TO NO.OF.MSG
         SEND.DATE = ''
         EB.ADV = R.DR<TF.DR.EB.ADV.NO,I>
         BEGIN CASE
            CASE EB.ADV[6,2] = '14' OR EB.ADV[6,2] = '16'
               MAT.DATE = R.DR<TF.DR.MATURITY.REVIEW>
               CALL DBR('EB.ACTIVITY':FM:EB.ACT.DAYS.PRIOR.EVENT,EB.ADV,RE)
               CALL DBR('LC.PARAMETERS':FM:LC.PARA.REIMBURSE.DAYS,'SYSTEM',PARA.DAYS)
               IF REIMB.DAYS EQ '' THEN REIMB.DAYS = PARA.DAYS
               CALL WORKING.DAY("",MAT.DATE,"-",REIMB.DAYS:"W","B",CCY.LIS,
                  "",SEND.DATE,"","")
               IF SEND.DATE GT MAT.DATE THEN SEND.DATE = MAT.DATE
               OLD.DATE = R.DR<TF.DR.MSG.SEND.DATE,I>
               R.DR<TF.DR.MSG.SEND.DATE,I> = SEND.DATE
               IF MAT.DATE NE SEND.DATE AND SEND.DATE NE '' THEN
                  MAT.DATE = OLD.DATE
                  GOSUB DELETE.DRAW.SCHEDULES
                  MAT.DATE = SEND.DATE
                  GOSUB UPDATE.DRAW.SCHEDULES
               END
            CASE EB.ADV[6,2] = '15' OR EB.ADV[6,2] = '17'
               MAT.DATE = R.DR<TF.DR.MATURITY.REVIEW>
               YCCY = R.DR<TF.DR.DRAW.CURRENCY>
               CCY.LIST = YCCY[1,2]:FM:R.COMPANY(EB.COM.LOCAL.COUNTRY)[1,2]
               PAY.DAYS = ''
               CALL DBR("CURRENCY":FM:EB.CUR.DAYS.DELIVERY,YCCY,PAY.DAYS)
               PAY.DAYS = PAY.DAYS + 1
               CALL WORKING.DAY('',MAT.DATE,'-',PAY.DAYS:'W','',CCY.LIST,'',
                  SEND.DATE,'','')
               IF SEND.DATE GT MAT.DATE THEN
                  SEND.DATE = MAT.DATE
               END
               OLD.DATE = R.DR<TF.DR.MSG.SEND.DATE,I>
               IF R.DR<TF.DR.DISCOUNT.AMT> THEN
                  R.DR<TF.DR.MSG.SEND.DATE,I> = R.DR<TF.DR.VALUE.DATE>
               END ELSE
                  R.DR<TF.DR.MSG.SEND.DATE,I> = SEND.DATE
               END
               IF R.DR<TF.DR.DISCOUNT.AMT> THEN
                  MAT.DATE = OLD.DATE
                  GOSUB DELETE.DRAW.SCHEDULES
                  MAT.DATE = R.DR<TF.DR.VALUE.DATE>
                  GOSUB UPDATE.DRAW.SCHEDULES
               END ELSE
                  IF MAT.DATE NE SEND.DATE AND SEND.DATE NE '' THEN
                     MAT.DATE = OLD.DATE
                     GOSUB DELETE.DRAW.SCHEDULES
                     MAT.DATE = SEND.DATE
                  END
                  GOSUB UPDATE.DRAW.SCHEDULES
               END
         END CASE
      NEXT I
      RETURN
*
*
UPDATE.DRAW.SCHEDULES:
      UPD.FLG = FALSE
      READ R.DRAW.SCH FROM F.DRAW.SCH, MAT.DATE THEN
         NO.ID = DCOUNT(R.DRAW.SCH,FM)
         FOR NUMBER = 1 TO NO.ID
            BEGIN CASE
               CASE DR.ID = R.DRAW.SCH<NUMBER>
                  UPD.FLG = TRUE
               CASE DR.ID < R.DRAW.SCH<NUMBER>
                  INS DR.ID BEFORE R.DRAW.SCH<NUMBER>
                  UPD.FLG = TRUE
            END CASE
         UNTIL UPD.FLG
         NEXT NUMBER
         IF NOT(UPD.FLG) THEN
            R.DRAW.SCH<-1> = DR.ID
         END
      END ELSE
         R.DRAW.SCH<-1> = DR.ID
      END
      WRITE R.DRAW.SCH TO F.DRAW.SCH,MAT.DATE ON ERROR
         PRINT 'UPDATES FAILED'
      END
      RETURN
*
DELETE.DRAW.SCHEDULES:
      READ R.DRAW.SCH FROM F.DRAW.SCH, MAT.DATE THEN
         LOCATE DR.ID IN R.DRAW.SCH<1> SETTING FOUND ELSE NULL
         IF FOUND THEN
            DEL R.DRAW.SCH<FOUND>
            IF R.DRAW.SCH THEN
               WRITE R.DRAW.SCH TO F.DRAW.SCH,MAT.DATE ON ERROR
                  PRINT 'UPDATES FAILED'
               END
            END ELSE
               DELETE F.DRAW.SCH,MAT.DATE
            END
         END
      END
      RETURN
*
INITIALISE:
      R.DRAW.SCH = ''
      FN.DRAW.SCH = 'F.DRAW.SCHEDULES'
      F.DRAW.SCH = ''
      CALL OPF(FN.DRAW.SCH,F.DRAW.SCH)
      RETURN
   END
