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
* <Rating>406</Rating>
*-----------------------------------------------------------------------------
      * Version 46 25/10/00 GLOBUS Release No. G11.1.00 31/10/00
*
*************************************************************************
*
      $PACKAGE AC.AccountOpening
      SUBROUTINE CONV.AC.LOCKED.EVENTS
*
*************************************************************************
*
* This routine will read through all existing ACCOUNTS with locked amount #
* and convert the existing locked amount to the new AC.LOCKED.EVENTS.
* Each locked date and locked amount will be recorded as an event in AC.LOCKED.EVENT
*
*************************************************************************
*
* 10/10/03 - CI_10013469
*          - When upgrading from G11 to G131, after running conversion
*          - for AC.LOCKED.EVENTS, the ID are created as 1,2 etc..
*          - which is wrong. ID should be ACLK...
*
* 18/11/03 - CI_10014753
*            After conversion locked amount in AC.LOCKED.EVENTS are wrong.
* 25/11/03 - BG_10005713
*            No F.READ and F.WRITE
*************************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.AC.LOCKED.EVENTS
$INSERT I_F.ACCOUNT
$INSERT I_F.LOCKING       ;* CI_10013469
$INSERT I_F.COMPANY       ;* CI_10013469
*************************************************************************
*
      GOSUB INITIALISE
      GOSUB SELECT.ACCOUNT
      RETURN
*
*************************************************************************
INITIALISE:
*      Open files
*
      FN.ACCOUNT = 'F.ACCOUNT' ; F.ACCOUNT = ''

      CALL OPF(FN.ACCOUNT,F.ACCOUNT)
      CALL OPF('F.ACCOUNT$HIS',F.ACCOUNT.HIS)

      FN.AC.LOCKED.EVENTS = 'F.AC.LOCKED.EVENTS' ; F.AC.LOCKED.EVENTS = ""

      CALL OPF(FN.AC.LOCKED.EVENTS, F.AC.LOCKED.EVENTS)


* Initialise Variables

      DIM R.ACCOUNT(AC.AUDIT.DATE.TIME)
      MAT R.ACCOUNT = ''

      DIM LOCK.REC(AC.LCK.AUDIT.DATE.TIME)
      MAT LOCK.REC = ""

      ACC.ID = 0
      WRITE.ACC =0
      NO.OF.RECS = 0
      NO.OF.ACTS = 0
      LOCKING.ID = ''                    ; * CI_10013469
      LOCKING.ID = "F":R.COMPANY(EB.COM.MNEMONIC):".AC.LOCKED.EVENTS"  ; * CI_10013469
      RETURN
*************************************************************************
*
SELECT.ACCOUNT:
*
* clear the work file

      EX.STMT = 'SELECT ':FN.ACCOUNT:' WITH '
      EX.STMT := ' LOCKED.AMOUNT <> "" '
      SEL.LIST = "" ; SYS.ERROR = ""
      CALL EB.READLIST(EX.STMT, SEL.LIST, "", NO.OF.RECS, SYS.ERROR)
      IF SEL.LIST = "" THEN
         RETURN
      END ELSE
         LOOP
            REMOVE ACC.ID FROM SEL.LIST SETTING POS
            NO.OF.ACTS +=1
            PRINT 'Processing  ':NO.OF.ACTS:'  out of  ':NO.OF.RECS:'.......'
         WHILE ACC.ID:POS DO
            MATREADU R.ACCOUNT FROM F.ACCOUNT , ACC.ID THEN
               GOSUB UPDATE.LOCKED.EVENTS
               IF WRITE.ACC THEN
                  GOSUB WRITE.HISTORY
                  R.ACCOUNT(AC.FROM.DATE) = TMP.LOCK.DATE
                  R.ACCOUNT(AC.LOCKED.AMOUNT) = TMP.LOCK.AMT
                  MATWRITE R.ACCOUNT TO F.ACCOUNT, ACC.ID

               END ELSE
                  RELEASE F.ACCOUNT, ACC.ID
               END
            END

         REPEAT
      END
      RETURN
*******************************************************************
UPDATE.LOCKED.EVENTS:
      WRITE.ACC = ""
      LOCKED.DATE = R.ACCOUNT(AC.FROM.DATE)
      LOCKED.AMT = R.ACCOUNT(AC.LOCKED.AMOUNT)
      TMP.LOCK.DATE = ""
      TMP.LOCK.AMT = ""
      NO.AMTS = DCOUNT(LOCKED.AMT,@VM)
* Set the blank dates with today's date and group all the corresponding amounts together
      FOR I = 1 TO NO.AMTS
         AMOUNT = LOCKED.AMT<1,I>
         IF AMOUNT = "" THEN AMOUNT = 0
         LCK.DATE = LOCKED.DATE<1,I>
         IF LCK.DATE = "" THEN LCK.DATE = TODAY
         IF AMOUNT THEN
            GOSUB CREATE.LOCKED.EVENTS

            LOCATE LCK.DATE IN TMP.LOCK.DATE<1,1> BY 'AL' SETTING POS THEN
               TMP.LOCK.AMT<1,POS> = TMP.LOCK.AMT<1,POS> + AMOUNT
            END ELSE
               TMP.LOCK.DATE = INSERT(TMP.LOCK.DATE,0,POS,0,LCK.DATE)
               TMP.LOCK.AMT = INSERT(TMP.LOCK.AMT,0,POS,0,AMOUNT)
            END
         END
      NEXT I
* Now Accumulate the totals of the locked amounts
      NO.OF.DATES = DCOUNT(TMP.LOCK.DATE,@VM)
      FOR J = 2 TO NO.OF.DATES
         TMP.LOCK.AMT<1,J> = TMP.LOCK.AMT<1,J> + TMP.LOCK.AMT<1,J-1>
      NEXT J
      IF TMP.LOCK.DATE <> LOCKED.DATE OR TMP.LOCK.AMT <> LOCKED.AMT THEN WRITE.ACC = 1
* Now that the locked.amt and locked.date has beem updated correctly
* process with creating LOCKED.EVENTS
*
      RETURN
*************************************************************************
CREATE.LOCKED.EVENTS:

      LOCK.REC(AC.LCK.ACCOUNT.NUMBER) = ACC.ID
      LOCK.REC(AC.LCK.FROM.DATE) = LCK.DATE
      LOCK.REC(AC.LCK.DESCRIPTION) = 'CONVERSION OF LOCKED.EVENTS'
      LOCK.REC(AC.LCK.TO.DATE) = ""
      LOCK.REC(AC.LCK.LOCKED.AMOUNT) = AMOUNT
      TIME.STAMP = TIMEDATE()
      X = OCONV(DATE(),"D-")
      X = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
      LOCK.REC(AC.LCK.DATE.TIME) = X
      LOCK.REC(AC.LCK.INPUTTER) = 'CONV.AC.LOCKED.EVENTS'
      LOCK.REC(AC.LCK.AUTHORISER) = 'CONV.AC.LOCKED.EVENTS'
      LOCK.REC(AC.LCK.CURR.NO) = 1
      LOCK.REC(AC.LCK.CO.CODE) = ID.COMPANY
*
* CI_10014753 S
      READ R.LOCKING FROM F.LOCKING, LOCKING.ID ELSE R.LOCKING = ''
      IF NOT(R.LOCKING) THEN
         ID.NEW = 1
      END ELSE
         NEXT.ACLK.ID = ''
         NEXT.ACLK.ID = R.LOCKING<1>[10,5]
         NEXT.ACLK.ID +=1
         ID.NEW = NEXT.ACLK.ID
      END
* CI_10014753 E
*
*  CI_10013469 S
      CALL EB.FORMAT.ID("ACLK")
      MASTER.ID = ID.NEW
      MATWRITE LOCK.REC ON F.AC.LOCKED.EVENTS, MASTER.ID
*  CI_10013469 E
      R.LOCKING<1> = MASTER.ID           ; * CI_10014753 S
      WRITE R.LOCKING TO F.LOCKING, LOCKING.ID     ; * CI_10014753 E
      RETURN
*
*********************************************************************************************
WRITE.HISTORY:

      TIME.STAMP = TIMEDATE()
      X = OCONV(DATE(),"D-")
      X = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
      R.ACCOUNT(AC.DATE.TIME) = X
      R.ACCOUNT(AC.INPUTTER) = 'CONV.AC.LOCKED.EVENTS'
      R.ACCOUNT(AC.AUTHORISER) = 'CONV.AC.LOCKED.EVENTS'
      HIST.ID = ACC.ID:';':R.ACCOUNT(AC.CURR.NO)
      MATWRITE R.ACCOUNT TO F.ACCOUNT.HIS, HIST.ID

      RETURN
***********************************************************************************************

   END
