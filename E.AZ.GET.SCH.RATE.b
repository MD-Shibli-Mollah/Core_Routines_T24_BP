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
* <Rating>80</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.ModelBank
      SUBROUTINE E.AZ.GET.SCH.RATE

********************************************************************
* 26/12/2002 - EN_10001560
* New routine added.
* This is a enquiry routine added to ENQUIRY, AZ.DEPOSIT.SCHEDULES.
* Proper Interest rate is retrived from AZ.SCHEDULES based on
* enquiry date and R schedule date.
*
* 23/04/10 - Defect # 40306
*            Task # 43586
*            System skips the process when the R schedule is define with zero rate.
*
********************************************************************

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_ENQUIRY.COMMON
$INSERT I_F.DATES
$INSERT I_F.AZ.SCHEDULES

      GOSUB INITIALISE
      GOSUB PERFORM.PARA
      RETURN

INITIALISE:

      ENQ.DATE = TODAY
      AC.ID = O.DATA
      R.AZ.SCHEDULES = ''
      POS.DATE = ''
      FN.AZ.SCHEDULES = 'F.AZ.SCHEDULES' ; FV.AZ.SCHEDULES = ''
      CALL OPF(FN.AZ.SCHEDULES,FV.AZ.SCHEDULES)
      CALL F.READ(FN.AZ.SCHEDULES,AC.ID,R.AZ.SCHEDULES,FV.AZ.SCHEDULES,YSERR)
      ALL.DATES = RAISE(R.AZ.SCHEDULES<AZ.SLS.DATE>)
      CALL AZ.GET.REGION(AZ$REGION)
      NO.OF.DATES = DCOUNT(ALL.DATES,FM)
      RETURN

PERFORM.PARA:

      O.DATA = ''
      LOOP
      WHILE NO.OF.DATES
         POS.DATE = FIELD(ALL.DATES,FM,NO.OF.DATES)
         IF POS.DATE LE ENQ.DATE THEN
            IF R.AZ.SCHEDULES<AZ.SLS.TYPE.R,NO.OF.DATES> NE '' THEN 
            	O.DATA = R.AZ.SCHEDULES<AZ.SLS.TYPE.R,NO.OF.DATES>
            END
         END
         NO.OF.DATES -= 1
         IF O.DATA THEN EXIT
      REPEAT
      RETURN

   END
