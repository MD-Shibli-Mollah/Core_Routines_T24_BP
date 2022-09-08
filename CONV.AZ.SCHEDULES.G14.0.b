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

* THIS IS A ROUTINE TO CONVERT AZ.SCHEDULES RECORD
*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.Contract
      SUBROUTINE CONV.AZ.SCHEDULES.G14.0(AZS.ID,AZS.REC,YFILE)

*******************************************************************************
*
* 31/03/2003 - EN_10001673
*	       New fields added to AZ.SCHEDULES for which data record,
*	       has to be properly mapped to new field layout.
*******************************************************************************

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.ACCOUNT
* -----------------------------------------------------------------------
*Since DATE field is moved up DATA are to be moved accordingly.
*Also new field added CURRENCY which is to be populated with CCY of AZ contract.


      OLD.AZS.REC = AZS.REC
      NEW.AZS.REC = ''

      AZ.ID = FIELD(AZS.ID,'-',1)

      CALL DBR("ACCOUNT":FM:AC.CURRENCY:FM:".A",AZ.ID,AZ.CCY)

* Forming new array.
* New field currency added.
      NEW.AZS.REC<1> = AZ.CCY
* Date field moved up.
      NEW.AZS.REC<2> = OLD.AZS.REC<14>   ; *DATE FIELD.
      NEW.AZS.REC<3> = OLD.AZS.REC<1>    ; *TYPE.B
      NEW.AZS.REC<4> = OLD.AZS.REC<2>    ; *TYPE.P
      NEW.AZS.REC<5> = OLD.AZS.REC<3>    ; *TYPE.I
      NEW.AZS.REC<6> = OLD.AZS.REC<4>    ; *TYPE.C
      NEW.AZS.REC<7> = ''                ; *NEW FIELD 'CHG.CODE'
      NEW.AZS.REC<8> = ''                ; *NEW FIELD 'CHG.CCY'
      NEW.AZS.REC<9> = ''                ; *NEW FIELD 'CHG.AMT'
      NEW.AZS.REC<10> = ''               ; *NEW FIELD 'CHG.LIQ.ACCT'
      NEW.AZS.REC<11> = ''               ; *NEW FIELD 'NO.ACCT'
      NEW.AZS.REC<12> = ''               ; *NEW FIELD 'CHG.PL.ACCT'
      NEW.AZS.REC<13> = ''               ; *NEW FIELD 'TAX.CODE'
      NEW.AZS.REC<14> = ''               ; *NEW FIELD 'TAX.AMOUNT'
      NEW.AZS.REC<15> = ''               ; *NEW FIELD 'TAX.AMT.LCY'
      NEW.AZS.REC<16> = ''               ; *NEW FIELD 'TAX.ACCT'
      NEW.AZS.REC<17> = OLD.AZS.REC<5>   ; *TYPE.N
      NEW.AZS.REC<18> = OLD.AZS.REC<6>   ; *TYPE.Z
      NEW.AZS.REC<19> = ''               ; *TYPE.CI  NEW TYPE ADDED
      NEW.AZS.REC<20> = ''               ; *TYPE.CC  NEW TYPE ADDED
      NEW.AZS.REC<21> = OLD.AZS.REC<7>   ; *TYPE.R
      NEW.AZS.REC<22> = OLD.AZS.REC<8>   ; *INT.KEY
      NEW.AZS.REC<23> = OLD.AZS.REC<9>   ; *PRD.RATE.KEY
      NEW.AZS.REC<24> = OLD.AZS.REC<10>  ; *INT.SPREAD
      NEW.AZS.REC<25> = OLD.AZS.REC<11>  ; *INT.OPERAND
      NEW.AZS.REC<26> = OLD.AZS.REC<12>  ; *INT.PERCENT
      NEW.AZS.REC<27> = OLD.AZS.REC<13>  ; *FIXED.RATE
      NEW.AZS.REC<28> = ''               ; *NEW FIELD 'AZ.INT.RATE'
      NEW.AZS.REC<29> = OLD.AZS.REC<15>  ; *GRACE.END.DATE
      NEW.AZS.REC<30> = OLD.AZS.REC<16>  ; *REPAY.AMT
      NEW.AZS.REC<31> = OLD.AZS.REC<17>  ; *TOT.TAX
      NEW.AZS.REC<32> = OLD.AZS.REC<18>  ; *TAX.KEY
      NEW.AZS.REC<33> = OLD.AZS.REC<19>  ; *TOT.REPAY.AMT
      NEW.AZS.REC<34> = OLD.AZS.REC<20>  ; *ACCR.INT
      NEW.AZS.REC<35> = OLD.AZS.REC<21>  ; *SCHEDULE.BAL
      NEW.AZS.REC<36> = OLD.AZS.REC<22>  ; *ANNUITY.ADJUST
      NEW.AZS.REC<37> = ''               ; *NEW FIELD 'LAST.CIGEN.DATE'
      * FROM FIELD 38 TO 47 ARE RESERVED FIELDS.
      * OTHERS FIELDS FROM VALUE.DATE TO NOTES.
      J = 27
      FOR I = 48 TO 57
         NEW.AZS.REC<I> = OLD.AZS.REC<J>
         J += 1
      NEXT I

      AZS.REC = NEW.AZS.REC

      RETURN
   END
