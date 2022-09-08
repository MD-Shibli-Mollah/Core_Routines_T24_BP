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
* <Rating>180</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.ModelBank
      SUBROUTINE E.AZ.GET.SCH.RATE.NAU

********************************************************************
* 14/03/2003 - BG_100003793
* New routine added.
* This is a enquiry routine added to ENQUIRY, AZ.DEP.SCH.NAU
* Proper Interest rate is retrived from AZ.SCHEDULES.NAU based on
* enquiry date and R schedule date.
********************************************************************

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_ENQUIRY.COMMON
$INSERT I_F.DATES
$INSERT I_F.AZ.SCHEDULES.NAU

      GOSUB INITIALISE
      GOSUB PERFORM.PARA
      RETURN

INITIALISE:

      ENQ.DATE = TODAY
      AC.ID = O.DATA
      R.AZ.SCHEDULES = ''
      POS.DATE = ''
      FN.AZ.SCHEDULES.NAU = 'F.AZ.SCHEDULES.NAU' ; FV.AZ.SCHEDULES.NAU = ''
      CALL OPF(FN.AZ.SCHEDULES.NAU,FV.AZ.SCHEDULES.NAU)
      CALL F.READ(FN.AZ.SCHEDULES.NAU,AC.ID,R.AZ.SCHEDULES,FV.AZ.SCHEDULES.NAU,YSERR)
      ALL.DATES = RAISE(R.AZ.SCHEDULES<ASN.DATE>)
      CALL AZ.GET.REGION(AZ$REGION)
      NO.OF.DATES = DCOUNT(ALL.DATES,FM)
      RETURN

PERFORM.PARA:

      O.DATA = ''
      LOOP
      WHILE NO.OF.DATES
         POS.DATE = FIELD(ALL.DATES,FM,NO.OF.DATES)
         IF POS.DATE LE ENQ.DATE THEN
            IF R.AZ.SCHEDULES<ASN.TYPE.R,NO.OF.DATES> THEN O.DATA = R.AZ.SCHEDULES<ASN.TYPE.R,NO.OF.DATES>
         END
         NO.OF.DATES -= 1
         IF O.DATA THEN EXIT
      REPEAT
      RETURN

   END
