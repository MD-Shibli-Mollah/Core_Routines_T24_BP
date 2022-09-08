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

*
*-----------------------------------------------------------------------------
* <Rating>-142</Rating>
*-----------------------------------------------------------------------------
      $PACKAGE AC.AccountOpening
      SUBROUTINE CONV.ACCOUNT.R7.200609(ID.ACCOUNT, R.ACCOUNT, FN.ACCOUNT)
*-----------------------------------------------------------------------------
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* where ever possible use the RECORD.ROUTINE to convert/populate record data fields.
*-----------------------------------------------------------------------------
* Modification History:
*
* 08/06/06 - EN_10002965
*            Created to convert account record for trade dated balance check.
*
* 13/07/06 - BG_100011658
*            Bug fixes and code improvements as a result of code review.
*
* 01/10/07 - CI_10051646
*            Ignore HIS file for conversion. 
*
* 15/07/09 - EN_10004199
*            Extra argument is passed to GET.CREDIT.CHECK to identify if
*            Locked amount check should include Limit.
*
* 11/02/10 - Task 21555 // SAR-2009-04-21-0009
*            An option to set which movement that has not updated the Available Balance 
*            should be included in the Locked amount checking.
*
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.COMPANY
$INSERT I_F.ACCOUNT.PARAMETER
$INSERT I_F.STMT.ENTRY

      DIM R.ACCOUNT1(199)
      MAT R.ACCOUNT1 = ""
      IF FN.ACCOUNT['$',2,1] = 'HIS' THEN
         RETURN
      END 

      GOSUB INITIALISATION
      GOSUB GET.ACCT.PARAMETER.DETAILS
      GOSUB GET.ACCOUNT.DETAILS
      GOSUB CHECK.CASH.FLOW.DAYS
      GOSUB UPDATE.CREDIT.CHECK
      GOSUB UPDATE.FORWARD.MVMTS

      RETURN

*-----------------------------------------------------------------------------
INITIALISATION:

      FN.ACCT.ENT.FWD = FN.ACCOUNT[".", 1, 1] : '.ACCT.ENT.FWD'
      F.ACCT.ENT.FWD = ''
      CALL OPF(FN.ACCT.ENT.FWD, F.ACCT.ENT.FWD)
      FN.STMT.ENTRY = FN.ACCOUNT[".", 1, 1] : '.STMT.ENTRY'
      F.STMT.ENTRY = ''
      CALL OPF(FN.STMT.ENTRY, F.STMT.ENTRY)

      RETURN

*-----------------------------------------------------------------------------

*** <region name= GET.ACCT.PARAMETER.DETAILS>
GET.ACCT.PARAMETER.DETAILS:
*** <desc>Get account parameter details</desc>

      CASH.FLOW.DAYS = R.ACCOUNT.PARAMETER<AC.PAR.CASH.FLOW.DAYS>
      VDATE.BAL.CHK = R.ACCOUNT.PARAMETER<67>

      RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.ACCOUNT.DETAILS>
GET.ACCOUNT.DETAILS:
*** <desc>Get account details</desc>

      MATPARSE R.ACCOUNT1 FROM R.ACCOUNT
      AVAIL.BAL.UPD = ""
      LOCK.INC.MVMT = ""
      CALL GET.CREDIT.CHECK(AVAIL.CHECK, "", MAT R.ACCOUNT1, "",AVAIL.BAL.UPD ,LOCK.INC.MVMT) ;* extra argument for Locked.with.Limit
      LIMIT.REF = R.ACCOUNT<10>

      RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CHECK.CASH.FLOW.DAYS>
CHECK.CASH.FLOW.DAYS:
*** <desc>Check cash flow days</desc>

* If cash flow days is not set, check the set up of the account to
* determine how cash flow days should be set
      IF CASH.FLOW.DAYS = "" THEN
         IF AVAIL.CHECK = "WORKING" AND VDATE.BAL.CHK # "YES" AND LIMIT.REF # "NOSTRO" THEN
            CASH.FLOW.DAYS = 0
         END ELSE
            CASH.FLOW.DAYS = 10
         END
      END

      RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= UPDATE.CREDIT.CHECK>
UPDATE.CREDIT.CHECK:
*** <desc>Update credit check field</desc>

      IF VDATE.BAL.CHK = "YES" AND R.ACCOUNT<157> = "WORKING" THEN
         R.ACCOUNT<157> = "FORWARD"
      END

      RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= UPDATE.FORWARD.MVMTS>
UPDATE.FORWARD.MVMTS:
*** <desc>Update forward movements field</desc>

* If cash flow days is zero, clear available funds and open available
* balance, otherwise update forward movements
      IF CASH.FLOW.DAYS = 0 THEN
         R.ACCOUNT<149> = ""
         R.ACCOUNT<150> = ""
         R.ACCOUNT<151> = ""
         R.ACCOUNT<152> = ""
         R.ACCOUNT<153> = ""
         R.ACCOUNT<154> = ""
         R.ACCOUNT<155> = ""
         R.ACCOUNT<156> = ""
      END ELSE
         ID.ACCT.ENT.FWD = ID.ACCOUNT
         R.ACCT.ENT.FWD = ''
         YERR = ''
         CALL F.READ(FN.ACCT.ENT.FWD, ID.ACCT.ENT.FWD, R.ACCT.ENT.FWD, F.ACCT.ENT.FWD, YERR)
         IF NOT(YERR) THEN
            GOSUB GET.WINDOW.END.DATE
            GOSUB GET.FORWARD.MVMTS
            R.ACCOUNT<156> = FORWARD.MVMTS
         END
      END

      RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.WINDOW.END.DATE>
GET.WINDOW.END.DATE:
*** <desc>Get window end date</desc>

      STANDARD.WINDOW.END.DATE = TODAY
      CDT.DAYS =  "+" : CASH.FLOW.DAYS : "C"
      CALL CDT(R.COMPANY(EB.COM.LOCAL.REGION), STANDARD.WINDOW.END.DATE, CDT.DAYS)
      NO.AVAIL.FUNDS.DATES = DCOUNT(R.ACCOUNT<150>, VM)
      ACTUAL.WINDOW.END.DATE = R.ACCOUNT<150, NO.AVAIL.FUNDS.DATES>
      IF ACTUAL.WINDOW.END.DATE > STANDARD.WINDOW.END.DATE THEN
         WINDOW.END.DATE = ACTUAL.WINDOW.END.DATE
      END ELSE
         WINDOW.END.DATE = STANDARD.WINDOW.END.DATE
      END

      RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.FORWARD.MVMTS>
GET.FORWARD.MVMTS:
*** <desc>Get forward movements</desc>

      FORWARD.MVMTS = ""
      AVAILABLE.DATE = R.ACCOUNT<150>
      NO.AVAILABLE.DATES = DCOUNT(AVAILABLE.DATE<1>, VM)
      STMT.ENTRIES = R.ACCT.ENT.FWD
      LOOP
         REMOVE ID.STMT.ENTRY FROM STMT.ENTRIES SETTING STMT.ENTRY.MARK
      WHILE ID.STMT.ENTRY : STMT.ENTRY.MARK
         IF ID.STMT.ENTRY[1, 1] = "F" THEN
            GOSUB PROCESS.FWD.ENTRY
         END
      REPEAT

      RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.FWD.ENTRY>
PROCESS.FWD.ENTRY:
*** <desc>Process forward entry</desc>

      R.STMT.ENTRY = ''
      YERR = ''
      CALL F.READ(FN.STMT.ENTRY, ID.STMT.ENTRY, R.STMT.ENTRY, F.STMT.ENTRY, YERR)
      IF NOT(YERR) THEN
         AMOUNT.LCY = R.STMT.ENTRY<AC.STE.AMOUNT.LCY>
         AMOUNT.FCY = R.STMT.ENTRY<AC.STE.AMOUNT.FCY>
         VALUE.DATE = R.STMT.ENTRY<AC.STE.VALUE.DATE>
         IF AMOUNT.FCY = "" THEN
            AMOUNT = AMOUNT.LCY
         END ELSE
            AMOUNT = AMOUNT.FCY
         END
         IF VALUE.DATE <= WINDOW.END.DATE THEN
            LOCATE VALUE.DATE IN AVAILABLE.DATE<1, 1> SETTING VALUE.DATE.POS THEN
               FORWARD.MVMTS<1, VALUE.DATE.POS> += AMOUNT
            END
         END
      END

      RETURN
*** </region>
   END
