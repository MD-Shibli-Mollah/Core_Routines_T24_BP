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
* <Rating>498</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.Contract
      SUBROUTINE CONV.AZ.SCHEDULES.G12.2(AZ.ID,R.SCHEDULES,FV.AZ.SCHEDULES)


* This is the conversion routine which is used to update SCHEDULE.BAL
* Field in AZ.SCHEDULES record.
* This field is newly introduced in G12.2 & it is used to compute the
* o.s.balances.

* In case of loans , this field should contain the Principal amount
* to be repaid after today - except for Nonredemption contract
* Where we have to consider future B schedules into account.

* In case of deposits , this field should have the Interest amount
* added to the deposit amount.


$INSERT I_COMMON
$INSERT I_EQUATE


      EQU AZ.SLS.DATE TO 14,
         AZ.SLS.TYPE.B TO 1,
         AZ.SLS.TYPE.P TO 2,
         AZ.SLS.TYPE.I TO 3,
         AZ.SLS.SCHEDULE.BAL TO 21,
         AZ.ALL.IN.ONE.PRODUCT TO 4,
         AZ.PREV.REPAYMENT.TYPE TO 40,
         AZ.APP.LOAN.DEPOSIT TO 2


* Check if the routine is run before Running conversions for AZ.ACCOUNT or
* after running conversions for AZ.ACCOUNT.

      R.AZ.SCHEDULES = R.SCHEDULES

      FN.AZ.ACCOUNT = 'F.AZ.ACCOUNT' ; FV.AZ.ACCOUNT = ''
      CALL OPF(FN.AZ.ACCOUNT,FV.AZ.ACCOUNT)

      CALL F.READ(FN.AZ.ACCOUNT,AZ.ID,R.AZ.ACCOUNT,FV.AZ.ACCOUNT,AZ.ERR)

      IF R.AZ.ACCOUNT<AZ.PREV.REPAYMENT.TYPE> MATCHES ('ANNUITY':VM:'LINEAR':VM:'NONRED':VM:'OTHERS':VM:'FIXED':VM:'SAVINGS-PLAN':VM:'SPL-DEPOSIT' ) THEN
         RUN.AFTER.CONV = 1
      END ELSE
         RUN.AFTER.CONV = 0
      END
      IF NOT(RUN.AFTER.CONV) THEN
         AZ.INTEREST.LIQU.ACCT = 12
         AZ.CALCULATION.BASE = 32
         AZ.REPAYMENT.TYPE = 31
      END ELSE
         AZ.INTEREST.LIQU.ACCT = 13
         AZ.CALCULATION.BASE = 41
         AZ.REPAYMENT.TYPE = 40
      END
      NONRED = R.AZ.ACCOUNT<AZ.REPAYMENT.TYPE>


      INT.LIQ.ACCT = R.AZ.ACCOUNT<AZ.INTEREST.LIQU.ACCT>
      NONRED = NONRED EQ 'NONRED'

      APP.ID = R.AZ.ACCOUNT<AZ.ALL.IN.ONE.PRODUCT>
      CALC.BASE = R.AZ.ACCOUNT<AZ.CALCULATION.BASE>
      CALL DBR('AZ.PRODUCT.PARAMETER':FM:AZ.APP.LOAN.DEPOSIT,APP.ID,LOAN.DEPOSIT)

      ALL.DATES = RAISE(R.AZ.SCHEDULES<AZ.SLS.DATE>)
      NO.OF.DATES = DCOUNT(ALL.DATES,FM)
      FOR NO.SCH = 1 TO NO.OF.DATES
         SCH.DATE = R.AZ.SCHEDULES<AZ.SLS.DATE,NO.SCH>
         IF SCH.DATE LT TODAY THEN CONTINUE
         OUT.BAL = 0
         IF LOAN.DEPOSIT = 'LOAN' THEN
            FOR NO.REP = NO.SCH +1 TO NO.OF.DATES
               OUT.BAL + = R.AZ.SCHEDULES<AZ.SLS.TYPE.P,NO.REP>
               IF NONRED AND CALC.BASE NE 'PRINCIPAL' THEN OUT.BAL - =R.AZ.SCHEDULES<AZ.SLS.TYPE.B,NO.REP>
            NEXT NO.REP
         END ELSE
            FOR NO.REP = 1 TO NO.SCH
               OUT.BAL += R.AZ.SCHEDULES<AZ.SLS.TYPE.B,NO.REP>
               IF NOT(INT.LIQ.ACCT) THEN OUT.BAL + = R.AZ.SCHEDULES<AZ.SLS.TYPE.I,NO.REP>
            NEXT NO.REP
            IF NO.SCH = NO.OF.DATES THEN OUT.BAL = 0
         END
         R.SCHEDULES<AZ.SLS.SCHEDULE.BAL,NO.SCH> = OUT.BAL
      NEXT NO.SCH
      RETURN
   END
