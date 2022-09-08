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

* Version 7 27/02/01  GLOBUS Release No. 200510 29/09/05
*-----------------------------------------------------------------------------
* <Rating>98</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Contract
      SUBROUTINE CONV.DR.RECORD(ID,R.RECORD,YFILE)
*06/02/2000 - GB0000130
*             Make LIMIT.UPDATION as a part of conversion.

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_LC.COMMON

*// DRAWINGS
      EQU TF.DR.DRAW.CURRENCY TO 2
      EQU TF.DR.DOCUMENT.AMOUNT TO 3
      EQU TF.DR.RATE.BOOKED TO 10
      EQU TF.DR.DRAWDOWN.ACCOUNT TO 17
      EQU TF.DR.PAYMENT.ACCOUNT TO 19
      EQU TF.DR.BEN.DRAW.AMT TO 120
      EQU TF.DR.TOT.ASSN.AMT TO 121
      EQU TF.DR.ACPT.TM.BAND TO 124
      EQU TF.DR.TREASURY.RATE TO 125
      EQU TF.DR.LC.LIAB.RELEASE TO 135
      EQU TF.DR.LC.LIAB.REL.LCY TO 136

*// LETTER.OF.CREDIT
      EQU TF.LC.ACPT.TM.BAND TO 66
      EQU TF.LC.EXPIRY.DATE TO 28
      EQU TF.LC.CURRENCY.MARKET TO 24
      EQU TF.LC.LC.CURRENCY TO 20

*// ACCOUNT
      EQU AC.CURRENCY TO 8

      *// Adjusting Delivery First
      CALL CONV.DR.G10.2(ID, R.RECORD, YFILE)

      *// Read LC Record
      LC.ID = ID[1,12]
      F.LETTER.OF.CREDIT = ''
      F.DRAWINGS = ''
      LCREC = ''
      CALL OPF('F.LETTER.OF.CREDIT', F.LETTER.OF.CREDIT)
      CALL F.READ('F.LETTER.OF.CREDIT',LC.ID,LCREC,F.LETTER.OF.CREDIT,'')

      R.RECORD<TF.DR.ACPT.TM.BAND> = LCREC<TF.LC.EXPIRY.DATE>
      R.RECORD<TF.DR.BEN.DRAW.AMT> = R.RECORD<TF.DR.DOCUMENT.AMOUNT>
      R.RECORD<TF.DR.TOT.ASSN.AMT> = 0
      RATE.BOOKED = R.RECORD<TF.DR.RATE.BOOKED>

      IF RATE.BOOKED AND RATE.BOOKED LT 1 THEN
         RATE.BOOKED = 1/RATE.BOOKED
      END

      IF RATE.BOOKED EQ 0 THEN RATE.BOOKED = ''
      R.RECORD<TF.DR.RATE.BOOKED> = RATE.BOOKED
      DRAW.CCY = R.RECORD<TF.DR.DRAW.CURRENCY>
      REIMB.ACCT = R.RECORD<TF.DR.DRAWDOWN.ACCOUNT>
      REIMB.CCY = ''
      PAY.ACCT = R.RECORD<TF.DR.PAYMENT.ACCOUNT>
      PAY.CCY = ''
      CALL DBR('ACCOUNT':FM:AC.CURRENCY,REIMB.ACCT,REIMB.CCY)
      CALL DBR('ACCOUNT':FM:AC.CURRENCY,PAY.ACCT,PAY.CCY)
      IF DRAW.CCY NE PAY.CCY THEN
         R.RECORD<TF.DR.TREASURY.RATE> = RATE.BOOKED
         IF DRAW.CCY EQ REIMB.CCY THEN
            R.RECORD<TF.DR.RATE.BOOKED> = ''
         END
      END
      DOC.AMT = R.RECORD<TF.DR.DOCUMENT.AMOUNT>
      TMP.AMT = DOC.AMT
      TMP.AMT2 = ''
      CCY.MKT = LCREC<TF.LC.CURRENCY.MARKET>
      IF DRAW.CCY NE LCCY THEN
         CALL EXCHRATE(CCY.MKT,DRAW.CCY,TMP.AMT,LCCY,TMP.AMT2,'','','','','')
      END ELSE
         TMP.AMT2 = DOC.AMT
      END
      R.RECORD<TF.DR.LC.LIAB.REL.LCY> = TMP.AMT2
      LC.CURRENCY = LCREC<TF.LC.LC.CURRENCY>
      TMP.AMT = DOC.AMT
      TMP.AMT2 = ''
      IF DRAW.CCY NE LC.CURRENCY THEN
         CALL EXCHRATE(CCY.MKT,DRAW.CCY,TMP.AMT,LC.CURRENCY,TMP.AMT2,'','','','','')
      END ELSE
         TMP.AMT2 = DOC.AMT
      END
      R.RECORD<TF.DR.LC.LIAB.RELEASE> = TMP.AMT2
      CALL CONV.DRAW.PROVISION(ID,R.RECORD,YFILE)
      MATPARSE R.NEW FROM R.RECORD
      MATPARSE LC.REC FROM LCREC
      CALL CONV.DR.UPD.LIMITS(ID)
   END
