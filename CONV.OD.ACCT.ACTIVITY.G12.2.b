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
      $PACKAGE AC.AccountOpening
      SUBROUTINE CONV.OD.ACCT.ACTIVITY.G12.2(OD.ID,R.OD.ACCT.ACTIVITY,F.OD.ACCT.ACTIVITY)
$INSERT I_COMMON
$INSERT I_EQUATE

* OD.IN.AC.CCY, INCR.AMT,DATE.FIRST.OD are the three fields added in
* the Position 5,6,7 respectively. Set the values in these fields as null.

      NO.DAYS = DCOUNT(R.OD.ACCT.ACTIVITY<1>,VM)
      FOR NO.REP = 1 TO NO.DAYS
         R.OD.ACCT.ACTIVITY<5,NO.REP> = ''
         R.OD.ACCT.ACTIVITY<6,NO.REP> = ''
         R.OD.ACCT.ACTIVITY<7,NO.REP> = ''
      NEXT NO.REP
      RETURN
   END
