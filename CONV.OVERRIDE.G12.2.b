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
* <Rating>26561</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.OverrideProcessing
      SUBROUTINE CONV.OVERRIDE.G12.2
*-----------------------------------------------------------------------------
* Conversion program to populate the new SYSTEM field in each selected OVERRIDE
* record with 'YES' - indicating that it is a TEMENOS generated OVERRIDE record.
* The program will also populate the new multi-valued field DATA.TYPE with the
* data type of the placeholders (&) within the MESSAGE field of the OVERRIDE record.
*-----------------------------------------------------------------------------
* M O D I F I C A T I O N S
*-----------------------------------------------------------------------------
* 20/02/02 - GLOBUS_EN_10000469 - Automatic Processing of Overrides
*            New Program
*
* 11/03/02 - GLOBUS_EN_10000528
*            Encorporating conversion for Barclays. This will convert their
*            current override data into the new data for override suppression.
*
* 15/04/02 - GLOBUS_BG_100000881
*            Code in the section READ.RECOD changes the OVERRIDE.ID before the 
*            call to F.RELEASE and records remain locked.  Code moved after the
*            call to F.RELEASE.
*
* 29/09/05 - CI_10035170
*            Override record 'CL.RISK.EXCEEDS.OF' not getting converted properly.
*            Ref: HD0512899
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

      GOSUB INITIALISE

      FILE.TO.SELECT = 'NAU'
      GOSUB READ.FILE.VARIABLE
      GOSUB SELECT.RECORDS

      FILE.TO.SELECT = 'LIVE'
      GOSUB READ.FILE.VARIABLE
      GOSUB SELECT.RECORDS

      FILE.TO.SELECT = 'HIS'
      GOSUB READ.FILE.VARIABLE
      GOSUB SELECT.RECORDS

      RETURN

*-----------------------------------------------------------------------------
* S U B R O U T I N E S
*-----------------------------------------------------------------------------
INITIALISE:

      DATA.POSN = 3
      SYSTEM.REF = 33

*GLOBUS_EN_10000528/S
*Assign fields to be converted to variables
      CREATE.LIST = 19
      OLD.MATCH = 20
      NEW.MATCH = 21
      SUPPRESS = 20
*GLOBUS_EN_10000528/E

      RETURN

*-----------------------------------------------------------------------------
READ.FILE.VARIABLE:

      BEGIN CASE
         CASE FILE.TO.SELECT = 'NAU'
            FN.OVERRIDE = "F.OVERRIDE$NAU"
         CASE FILE.TO.SELECT = 'LIVE'
            FN.OVERRIDE = "F.OVERRIDE"
         CASE FILE.TO.SELECT = 'HIS'
            FN.OVERRIDE = "F.OVERRIDE$HIS"
      END CASE

      F.OVERRIDE = ""
      CALL OPF(FN.OVERRIDE,F.OVERRIDE)

      RETURN

*-----------------------------------------------------------------------------
PROCESS.RECORDS:
* This will remove a record id from the selected list of OVERRIDE records and
* will match the id to one of the CASE's below.

      LOOP
         REMOVE OVERRIDE.ID FROM KEY.LIST SETTING MORE.DATA
      WHILE MORE.DATA:OVERRIDE.ID
         BEGIN CASE
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AC.EXP.AC.CUS'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AC.EXP.CURR.DIFF'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AC.EXP.DATE.ENT.N.T'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AC.EXP.FULLY.MATCHED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AC.EXP.REC.MORE.EXP'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AC.EXP.VAL.DATE.IN.PAST'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AC.LINK.DIFFERENT.CUSTOMER'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ACCOUNT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<DATA.POSN,2> = 'ANY'
                  R.OVERRIDE<DATA.POSN,3> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ACCOUNT.INACTIVE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ACC'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ACCT.BAL.LT.LOCKED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ACC'
                  R.OVERRIDE<DATA.POSN,2> = 'AMT'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ACCT.BR.OFFLINE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ACC'
                  R.OVERRIDE<DATA.POSN,2> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ACCT.DEBIT.COLLATERAL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ACCT.DIFF'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ACCT.INACTIVE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ACCT.LINKED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'AMT'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ACCT.NOT.PART.PORT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ACCT.PORTFOLIO'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'AMT'
                  R.OVERRIDE<DATA.POSN,2> = 'A'
                  R.OVERRIDE<DATA.POSN,3> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ACCT.UNAUTH.OD'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'CCY'
                  R.OVERRIDE<DATA.POSN,2> = 'AMT'
                  R.OVERRIDE<DATA.POSN,3> = 'ACC'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ACCT.UNAUTH.OVRDRFT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ACC'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ADV.LT.AVAIL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'AMT'
                  R.OVERRIDE<DATA.POSN,2> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ADVISED.EXCESS'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'CCY'
                  R.OVERRIDE<DATA.POSN,2> = 'AMT'
                  R.OVERRIDE<DATA.POSN,3> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AZ'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AZ.AC.NOM'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AZ.AC.REP'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AZ.AMT.EXCESS'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AZ.DD.FIN'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AZ.INT.EXCESS'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AZ.INT.GT.MAX'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AZ.INT.SCH'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AZ.MAT.MAX.TERM'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AZ.MAT.MIN.TERM'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AZ.NO.NOM.ACCT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AZ.PRIN.SCH'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'AZ.TOT.AMT.DUE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'AMT'
                  R.OVERRIDE<DATA.POSN,2> = 'AMT'
                  R.OVERRIDE<DATA.POSN,3> = 'AMT'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'BACS.DUTCH.CO'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'BACS.SLOVAK.CO'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'BACS.SWIS.CO'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'BACS.UK.CO'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'BELOW.CLEAN.RISK'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'BEN.BANK.EQ.ACCT.BANK'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'BGC.DUTCH.CO'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'BNK.DIFF.CCY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'BROK.LAST.PRICE.DIFF'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'AMT'
                  R.OVERRIDE<DATA.POSN,2> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CASH.FLOW.EXCESS'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'D'
                  R.OVERRIDE<DATA.POSN,2> = 'ACC'
                  R.OVERRIDE<DATA.POSN,3> = 'CCY'
                  R.OVERRIDE<DATA.POSN,4> = 'AMT'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CASH.FLOW.OVERDRAFT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'D'
                  R.OVERRIDE<DATA.POSN,2> = 'ACC'
                  R.OVERRIDE<DATA.POSN,3> = 'CCY'
                  R.OVERRIDE<DATA.POSN,4> = 'AMT'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CG.OLD.NEW.PL.DIFF'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<DATA.POSN,2> = 'AMT'
                  R.OVERRIDE<DATA.POSN,3> = 'AMT'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CHARGE.CCY.MKT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<DATA.POSN,2> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CHARGE.INPUT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CHARGED.CUSTOMER'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CHECK.JUL.DATE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CHQ.NO.NOT.PRESENT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CHQ.NO.STOPPED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CHQ.NOT.IN.REG'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CHQ.PRESENTED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CHQ.PRINTED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CHQ.STOP.ON.AMT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<DATA.POSN,2> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CL.RISK.EXCEEDS.OF'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
	          R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CL.RISK.EXCESS'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'CCY'
                  R.OVERRIDE<DATA.POSN,2> = 'AMT'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CLEAN.RISK.EXCEEDS'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CLIENT.NO.SELL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CLIENT.STOCK'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<DATA.POSN,2> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'COLL.BELOW.FLOOR.AMOUNT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'COLL.INSUFFICIENT.FUND'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'COMM.CHG.FOR.TXN'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CONVERSION.DIFF'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CR.BACKDATED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CR.GT.BACKVALUE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CR.NO.WORKING.DAY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CR.VAL.DATE.CUT.OFF'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CREDIT.ACCT.MISSING'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CREDIT.CCY.MKT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<DATA.POSN,2> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CURRENCY.BLOCKED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CURRENCY.UNAVAILABLE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<DATA.POSN,2> = 'CCY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CUST.LAST.PRICE.DIFF'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'AMT'
                  R.OVERRIDE<DATA.POSN,2> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CUST.NOT.EQ.DEFAULT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CUST.RATE.NOT.GT.ZERO'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CUST.USING.PORT.AS.COLL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'CUS'
                  R.OVERRIDE<DATA.POSN,2> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'CUST.USING.SEC.AS.COLL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'CUS'
                  R.OVERRIDE<DATA.POSN,2> = 'SEC'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DATE.GT.14'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DATE.HOLIDAY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<DATA.POSN,2> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DAY.EXCESS'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<DATA.POSN,2> = 'CCY'
                  R.OVERRIDE<DATA.POSN,3> = 'AMT'
                  R.OVERRIDE<DATA.POSN,4> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DD.FULL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DD.NOT.FULL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DEBIT.CCY.MKT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<DATA.POSN,2> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DEBIT.COLLATERAL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DEPOSIT.GT.MAX.BAL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DEPOSIT.GT.MAX.PER.PRD'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DIFF.CUST.ACCTS'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DISPO.LIMIT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DM.CONFIRM.DOC'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<DATA.POSN,2> = 'A'
                  R.OVERRIDE<DATA.POSN,3> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DM.EXPIRY.DOC'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<DATA.POSN,2> = 'A'
                  R.OVERRIDE<DATA.POSN,3> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DM.INVALID.DOC'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<DATA.POSN,2> = 'A'
                  R.OVERRIDE<DATA.POSN,3> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DM.NOT.RECEIVE.DOC'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<DATA.POSN,2> = 'A'
                  R.OVERRIDE<DATA.POSN,3> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DR.ACCT.PL.ACCT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DR.BACKDATED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DR.GT.BACKVALUE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DR.GT.FWD'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DR.GT.MAX.DR.INCREASE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DR.TXN.RESTRICTION'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DR.VAL.DATE.CUT.OFF'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DR.VAL.GT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DUP.CONTRACT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DX.EXCEED.PRI.TOL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DX.NO.AUTO.COMM.CODE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'CUS'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'DX.NO.CONTRACT.CONTINGENT.VAL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'EBQA.DIFF.CUS'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'EFF.INT.RATE.GT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'EFF.INT.RATE.LT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'EFFECT.LT.TODAY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'D'
                  R.OVERRIDE<DATA.POSN,2> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ENTRY.VAL.CURR.BLOCKED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<DATA.POSN,2> = 'CCY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'EXCESS.AMT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<DATA.POSN,2> = 'ANY'
                  R.OVERRIDE<DATA.POSN,3> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'EXCESS.ID'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'CCY'
                  R.OVERRIDE<DATA.POSN,2> = 'AMT'
                  R.OVERRIDE<DATA.POSN,3> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'EXP.DAT.LT.TODAY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'EXP.DATE.LT.MAT.DATE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'EXP.DATE.LT.VAL.DATE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'EXP.GT.OVERRIDE.DATE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'EXP.LT.OVERRIDE.DATE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'EXP.NON.WORKING'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'FIELD.VALUE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<DATA.POSN,2> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'FIELDS.IGNORE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'FIELDVALUE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'GT.CR.VAL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'GT.LIMIT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'GT.OVERRIDE.DATE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'HOLIDAY.TABLE.MISSING'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'INSUFF.TIME.BAND'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'INT.RATE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'INT.SPREAD'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'INTERNAL.EXCESS'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'CCY'
                  R.OVERRIDE<DATA.POSN,2> = 'AMT'
                  R.OVERRIDE<DATA.POSN,3> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'INVALID.DEPOSIT.TXN'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'INVALID.WITHDRAWL.TXN'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ISSUER.BLOCKED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ISSUER.EXP.EXCEED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ISSUER.RISK'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'LAST.PRICE.DIFF'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'AMT'
                  R.OVERRIDE<DATA.POSN,2> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'LCCY.ADJUST'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'AMT'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'LCCY.UNDEFINED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'LIMIT.DATE.EXPIRED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'LIMIT.EXPIRED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'LIMIT.EXPS.BEF.TXN'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'LIMIT.NOT.COMMITTED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'LIMIT.NOT.DATE.EXPIRED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'LIMIT.UNAVAIL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'LIMIT.UNAVAIL.FOR'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<DATA.POSN,2> = 'CUS'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'LT.MINIMUM.BAL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'LT.OVERRIDE.DATE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'MARKET.ENTRY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<DATA.POSN,2> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'MAT.DT.HOLIDAY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'MAT.NON.WORK.DAY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'MAT.NONWORK.DAY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'MAT.NOT.WDAY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'MAX.DEPOSIT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'AMT'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'MAX.INCREASE.EXEEDED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'MAX.INT.RATE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'MAX.TERM'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'MAX.TERM.NUM'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'MAX.WITHDRAWLS'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'MIN.DEPOSIT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'AMT'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'MIN.TERM'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'MIN.TERM.NUM'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'MXM.AMT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'AMT'
                  R.OVERRIDE<DATA.POSN,2> = 'CCY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NETTING.OVERRIDE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NO.AGENCY.ACCT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NO.CCR.ACCT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NO.CCY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NO.CHECK.LIMIT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NO.CHQ.AMT.VAL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NO.CHQ.ISSUED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NO.EARLY.CLOSURE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NO.HOLIDAY.TABLE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NO.LINE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NO.LINE.ALL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NO.MULTI.CHQ.FOR.TXN'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NO.PAY.SENT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NO.TIME.BAND'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NO.WORKING.DAY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NOMINAL.LESS.TRADE.UNIT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NON.WORK.DAY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NOSTRO.ACCT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NOT.AGENCY.CUST'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NOT.BANK'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NOT.CR.ACCT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NOT.IN.DENOM'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'AMT'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'NOT.WDAY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'PC.TXN'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'PORT.BLOCKED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<DATA.POSN,2> = 'D'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'PORT.CLOSED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<DATA.POSN,2> = 'D'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'PORT.DEFAULT.DEPO.DIFF'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'POSTING.RESTRICT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ACC'
                  R.OVERRIDE<DATA.POSN,2> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'POSTING.RESTRICT.CUST'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'CUS'
                  R.OVERRIDE<DATA.POSN,2> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'PRIN.BELOW.PLEDGED.COLL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'RATE.NOT.FIXED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'RATE.REQ'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'RATE.REQ.PROV.RATE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'REC.NOT.REDUCE.LIMIT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'REC.NOT.REDUCES.LIMIT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'REC.REDUCES.LIMIT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'SAME.ACCT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'SB.GROUP.UNAUTH.OD'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'CCY'
                  R.OVERRIDE<DATA.POSN,2> = 'AMT'
                  R.OVERRIDE<DATA.POSN,3> = 'A'
                  R.OVERRIDE<DATA.POSN,4> = 'ACC'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'SC.CHANGE.STRUCTURE.TO'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'SC.PORT.GRP.REMOVE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'SC.SR.RECON.ISIN.MISMATCH'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'SEC'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'SC.SR.RECON.QTY.MISMATCH'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'SC.SR.RECON.SUBAC.MISMATCH'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'SC.STAT.REQ.MISSING.SUBAC'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'SCC.SLOVAK.CO'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'SEC.LESS.HOLDING'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'SEC.REDOM'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'SIC.SWISS.CO'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'SPREAD.GT.CURR'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'STOCK.BLOCKED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'STOCK.LENT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'STOCK.UNSETTLED'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'SUB.ACCT.CUST'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<DATA.POSN,2> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TOT.ALLOW.LESS.CUST.ALLOW'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TRADE.BROKER.UNAUTH'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'CUS'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.CR.TILL.CLOS.BAL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.CUR.TT.NOT.IN.TILL.TRF'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.DEAL.SLIP.ADV.NOT.PROD'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.ED1.LT.BACK.VAL.MIN'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.ED1.MIN.FWD.DATE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.ED1.NOT.WRK.DAY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.ED2.LT.BACK.VAL.MIN'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.ED2.MIN.FWD.DATE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.ED2.NOT.WRK.DAY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.EXP.DATE.SPLITS.'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.SIG.NOT.VER'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.TRF.TO.DIFF.CUST'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.VD1.LT.BACK.VAL.MIN'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.VD1.MIN.FWD.DATE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.VD1.NOT.WRK.DAY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.VD2.LT.BACK.VAL.MIN'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.VD2.MIN.FWD.DATE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TT.VD2.NOT.WRK.DAY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'TXN.EXCEEDS.AVAIL.AMT'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'USE.CURR.RATE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'VALUE.DATE'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'WITHDRAWL.AMT.GT.MAX'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'WITHDRAWL.LT.MIN.BAL'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'WITHDRAWL.NOTICE.NOT.MET'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ACC'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'XRATE.DIFF'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'A'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
            CASE FIELD(OVERRIDE.ID, ';', 1) = 'ZONE.LCCY'
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  R.OVERRIDE<DATA.POSN,1> = 'ANY'
                  R.OVERRIDE<SYSTEM.REF> = 'YES'
                  GOSUB WRITE.RECORD
               END
*GLOBUS_EN_10000528/S
*Need to go through all the override records and convert them including the ones we dont
*go through above (in the long list).
            CASE 1
               GOSUB READ.RECORD
               IF R.OVERRIDE THEN
                  GOSUB WRITE.RECORD
               END
*GLOBUS_EN_10000528/E
         END CASE
      REPEAT

      RETURN

*-----------------------------------------------------------------------------
SELECT.RECORDS:
*Select all records in the OVERRIDE file.
      KEY.LIST = ""
      CMD = "SELECT ":FN.OVERRIDE

      CALL EB.READLIST(CMD, KEY.LIST,"","","")

      IF KEY.LIST THEN 
         GOSUB PROCESS.RECORDS
      END

      RETURN

*-----------------------------------------------------------------------------
READ.RECORD:
*Read (& lock) the matched record.
      R.OVERRIDE = "" ; YERR = ""
      BACKUP.ID = OVERRIDE.ID

      CALL F.READU(FN.OVERRIDE,OVERRIDE.ID,R.OVERRIDE,F.OVERRIDE,YERR,"R 05 12")
   
* GLOBUS_BG_100000881-S  Move this code after the check for YERR.  Otherwise locked records will not be released.
*      IF FILE.TO.SELECT = 'HIS' THEN
*         OVERRIDE.ID = FIELD(OVERRIDE.ID,';',1)
*      END
* GLOBUS_BG_100000881-E
 
      IF YERR THEN
         E = "RECORD & NOT FOUND ":FM:OVERRIDE.ID
         CALL F.RELEASE(FN.OVERRIDE,OVERRIDE.ID,F.OVERRIDE)
      END

      IF FILE.TO.SELECT = 'HIS' THEN
         OVERRIDE.ID = FIELD(OVERRIDE.ID,';',1)
      END

*
      RETURN

*-----------------------------------------------------------------------------
WRITE.RECORD:
*Write the amended record back to the file.

*GLOBUS_EN_10000528/S
*The conversion is performed here.
*Fields 17, 18 and 19 hold data that need to be converted.
*Data in field 17 will hold "SEC.OPEN.ORDER"/"SC.EXE.SEC.ORDERS" instead of "YES"/"NO"
*Data in field 18 will be moved to field 19
*Data in field 18 will then hold "SC.EXE.SEC.ORDERS"/"SEC.TRADE" instead of "YES"/"NO"
*If suppression is not set, then set all the fields to ""

      IF (R.OVERRIDE<CREATE.LIST> = 'YES' OR R.OVERRIDE<CREATE.LIST> = 'NO' OR R.OVERRIDE<CREATE.LIST> = '') AND (R.OVERRIDE<OLD.MATCH> = '' OR R.OVERRIDE<OLD.MATCH> = 'YES' OR R.OVERRIDE<OLD.MATCH> = 'NO') AND R.OVERRIDE<NEW.MATCH> = '' THEN
         IF R.OVERRIDE<CREATE.LIST> = 'NO' THEN
            R.OVERRIDE<CREATE.LIST> = 'SEC.OPEN.ORDER' : VM : 'SC.EXE.SEC.ORDERS'
            IF R.OVERRIDE<OLD.MATCH> THEN
               R.OVERRIDE<NEW.MATCH> = R.OVERRIDE<OLD.MATCH>
            END ELSE
               R.OVERRIDE<NEW.MATCH> = "NO"
            END                  
            R.OVERRIDE<SUPPRESS> = 'SC.EXE.SEC.ORDERS' : VM : 'SEC.TRADE'
         END ELSE
            R.OVERRIDE<CREATE.LIST> = ''
            R.OVERRIDE<SUPPRESS> = ''
            R.OVERRIDE<NEW.MATCH> = ''
         END
      END ELSE
         CRT 'OVERRIDE - ':OVERRIDE.ID:' HAS CORRUPT DATA. NOT CONVERTED'
      END 
*GLOBUS_EN_10000528/E

      OVERRIDE.ID = BACKUP.ID

      CALL F.WRITE(FN.OVERRIDE,OVERRIDE.ID,R.OVERRIDE)

      RETURN

*-----------------------------------------------------------------------------
   END
