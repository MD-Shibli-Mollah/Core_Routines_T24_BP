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

*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
* Version 1 24/07/01  GLOBUS Release No. G12.0.01 31/07/01
*************************************************************
    $PACKAGE MG.Contract
      SUBROUTINE CONV.MG.SCH.G11.2.00(CONTRACT.ID,R.RECORD,FN.FILE)
***********************************************************

* This routine is to populate the ADD.PAY.TYPE field newly introduced
* with ADD.PAY.TYPEs from MG.MORTAGGE if defined.
* This should be populated only if ADD.PAY.SCH has been populated
* with 'Y' and ADD.PAY.TYPE is null in MG.SCHEDULES.

$INSERT I_COMMON
$INSERT I_EQUATE
*
      F.MG.MORTGAGE = 'F.MG.MORTGAGE'
      FN.MG.MORTGAGE = ''
      CALL OPF(F.MG.MORTGAGE,FN.MG.MORTGAGE)
*
      IF R.RECORD<3> EQ 'Y' AND R.RECORD<4> EQ '' THEN

         MG.MORT.ID = CONTRACT.ID[1, LEN(CONTRACT.ID) - 9 ]

         MG.REC = ''
         MG.ERR = ''

         CALL F.READ(F.MG.MORTGAGE, MG.MORT.ID, MG.REC, FN.MG.MORTGAGE, MG.ERR)
*
         IF MG.REC<49> NE '' THEN
            NO.OF.ADD.PAYS = DCOUNT(MG.REC<49>, VM)
            FOR ADD.PAY = 1 TO NO.OF.ADD.PAYS
               R.RECORD<4,-1> = MG.REC<49,ADD.PAY>
            NEXT

         END
         RETURN
      END
   END
