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
* <Rating>-248</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T2.ModelBank

    SUBROUTINE NOFILE.LAST.N.TXNS.RECENT(TXN.ARR)
*----------------------------------------------------------------------------
* MODIFICATION HISTORY:
*--------------------
* 20/12/13 - Enhancement 590517
*            Routine to retrieve the transactions based on amount,start date and end date  if specified.
*            If dates are not specified then produces the data for the last one month
*
* 10/03/14 - Enhancement 641974 / Task 927795
*            Removing code lines which are not required
*
* 06/08/14 - Defect 1069880 / Task 1079274
*            Transaction Reference value has been populated based on condition.
*
* 07/10/14 - Defect 1129417 / Task 1131919
*            Description in Mini statement is not updated properly.
*
* 19/09/14 - Task : 1118297 (Defect : 1116751)
*            Fatal out error occurs during "View Mini Statement" in TCIB Retail
*
* 15/10/14 - Defect 1137196 / Task 1140233
*            Wrong balance is displayed in mini statement screen.
*
* 20/11/14 - Defect 1162354 / Task 1181213
*            Get all / paid in / paid out transactions
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
*-------------------------------------------------------------------------------
*** <region = Insert Files>
*** <desc>Insert files</desc>

    $USING AC.AccountOpening
    $USING AC.EntryCreation
    $USING AC.ModelBank
    $USING EB.API
    $USING EB.ErrorProcessing
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.TransactionControl
    $USING FT.Contract
    $USING ST.Config
    $USING T2.ModelBank

    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS

    RETURN
*** </region>
*-------------------------------------------------------------------------------
*** <region = Initialisation>
INIT:
*---
*To initialise the variables


    ACCOUNT.REC = "" ; ERR.AC = ""
    ID.POS="";START.POS="";END.POS="";LCY.POS =""
    FN.AC="F.ACCOUNT"
    F.AC=""
    ERR.AC=""
    ENTRY.BAL=""
    NET.ENTRIES.ARR=""
    NEW.TXN.ARR=""

    TRANS.POS=''
    ACTION.POS=''
    TYPE.POS = ''
    TXN.COUNT = ''
    TXN.LIST.COUNT = ''
    RETURN

*** </region>
*-------------------------------------------------------------------------------
*** <region = Open files>
OPEN.FILES:
*---------

    RETURN

*** </region>
*-------------------------------------------------------------------------------
*** <region = main process>
PROCESS:
*------
*If start and end date are not specified then produces one month data


    Y.DATE=EB.SystemTables.getToday()
    EB.API.Cdt('',Y.DATE,'-30C')
    Y.START.DATE = Y.DATE
    Y.END.DATE = EB.SystemTables.getToday()


    LOCATE 'ACCT.ID' IN EB.Reports.getDFields()<1> SETTING ID.POS THEN
    DR.ID = EB.Reports.getDRangeAndValue()<ID.POS>
    END
    LOCATE 'IN.START.DATE' IN EB.Reports.getDFields()<1> SETTING START.POS THEN
    IN.START.DATE = EB.Reports.getDRangeAndValue()<START.POS>
    END ELSE
    IN.START.DATE= Y.START.DATE
    END

    LOCATE 'IN.END.DATE' IN EB.Reports.getDFields()<1> SETTING END.POS THEN
    IN.END.DATE = EB.Reports.getDRangeAndValue()<END.POS>
    END ELSE
    IN.END.DATE= Y.END.DATE
    END

    IF (NOT(IN.START.DATE) OR (IN.START.DATE EQ 'null')) THEN
        IN.START.DATE= Y.START.DATE
    END

    IF (NOT(IN.END.DATE) OR (IN.END.DATE EQ 'null')) THEN
        IN.END.DATE= Y.END.DATE
    END

    LOCATE 'AMOUNT.MIN.LCY' IN EB.Reports.getDFields()<1> SETTING MIN.AMT.POS THEN
    AMOUNT.GE = EB.Reports.getDRangeAndValue()<MIN.AMT.POS>
    END ELSE
    AMOUNT.GE = ''
    END

    LOCATE 'AMOUNT.MAX.LCY' IN EB.Reports.getDFields()<1> SETTING MAX.AMT.POS THEN
    AMOUNT.LE = EB.Reports.getDRangeAndValue()<MAX.AMT.POS>
    END ELSE
    AMOUNT.LE = ''
    END
    LOCATE 'NO.OF.TRANS' IN EB.Reports.getDFields()<1> SETTING TRANS.POS THEN
    NOTRANS = EB.Reports.getDRangeAndValue()<TRANS.POS>
    END

    LOCATE 'USER.ACTION' IN EB.Reports.getDFields()<1> SETTING ACTION.POS THEN
    ACTION = EB.Reports.getDRangeAndValue()<ACTION.POS>
    END

    LOCATE 'PAY.TYPE' IN EB.Reports.getDFields()<1> SETTING TYPE.POS THEN  ;* new selection field to get all /paid in / paid out transactions
    TXN.PAY.TYPE = EB.Reports.getDRangeAndValue()<TYPE.POS>
    END
    IF NOT(TXN.PAY.TYPE) THEN ;* If no pay type passed set it to ALL by default
        TXN.PAY.TYPE = 'ALL'
    END

*Test to see if the account record exists
    ACCOUNT.REC = AC.AccountOpening.Account.Read(DR.ID,ERR.AC)
    IF ERR.AC THEN
        EB.Reports.setEnqError("EB-RMB1.REC.MISS.FILE")
        tmp=EB.Reports.getEnqError(); tmp<2,1>=DR.ID; EB.Reports.setEnqError(tmp)
        tmp=EB.Reports.getEnqError(); tmp<2,2>=FN.AC; EB.Reports.setEnqError(tmp)
    END
*Retrieve the statement ids
    tmp=EB.Reports.getDFields(); tmp<1>='ACCOUNT'; EB.Reports.setDFields(tmp)
    tmp=EB.Reports.getDFields(); tmp<2>='BOOKING.DATE'; EB.Reports.setDFields(tmp)
    EB.Reports.setDLogicalOperands(1:@FM:2)
    tmp=EB.Reports.getDRangeAndValue(); tmp<1>=DR.ID; EB.Reports.setDRangeAndValue(tmp)
    tmp=EB.Reports.getDRangeAndValue(); tmp<2>=IN.START.DATE:@VM:IN.END.DATE; EB.Reports.setDRangeAndValue(tmp)

    GROUP.ID=EB.ErrorProcessing.getExternalUserId()
    GOSUB UPDATE.ID.ACTION
    GOSUB SORT.BY.AMT
    RETURN

*** </region>
*-------------------------------------------------------------------------------
*** <region = Output data>
UPDATE.ID.ACTION:
*-----------------------------

    BEGIN CASE
        CASE ACTION = "FIRST"
            AC.ModelBank.EStmtEnqByConcat(Y.STMT.IDS)
            GOSUB FILTER.FUTURE.PAYMENTS    ;* Filter future dated payments
            IF TXN.PAY.TYPE AND TXN.PAY.TYPE NE 'ALL' THEN      ;* Filter paid in / out payments based on the selection passed
                GOSUB FILTER.CREDIT.DEBIT.PAYMENTS
            END
            Y.STMT.IDS=SE.IDS     ;* To get already processed transactions
            NOOFSEIDS=DCOUNT(Y.STMT.IDS,@FM)

            IF NOTRANS GE NOOFSEIDS THEN
                NOTRANS=NOOFSEIDS
            END
            GOSUB UPDATE.SE.IDS
            GOSUB READ.FIRST.SET.SE.IDS

        CASE ACTION = "NEXT"
            TCIB.REC = T2.ModelBank.TcibRecentTrans.Read(GROUP.ID,ERR.TCIB)

            TOTALNO=TCIB.REC<T2.ModelBank.TcibRecentTrans.TcibComTotalRecords>
            INTPOS=TCIB.REC<T2.ModelBank.TcibRecentTrans.TcibComProcessed>
            ENDPOS=INTPOS+NOTRANS

            IF (TOTALNO-ENDPOS) GE "0" THEN
                INCR=ENDPOS
                GOSUB READ.ID.AND.UPDATE.NEXT

            END
            ELSE
            INCR=TOTALNO
            GOSUB READ.ID.AND.UPDATE.NEXT
        END

    CASE ACTION = "BACK"
        TCIB.REC = T2.ModelBank.TcibRecentTrans.Read(GROUP.ID,ERR.TCIB)
        ENDPOS=TCIB.REC<T2.ModelBank.TcibRecentTrans.TcibComProcessed>
        INTPOS=ENDPOS-NOTRANS
        IF INTPOS GE "0" THEN
            GOSUB READ.ID.AND.UPDATE.BACK
        END
        ELSE
        INTPOS="0"
        GOSUB READ.ID.AND.UPDATE.BACK
    END

    END CASE
    EB.TransactionControl.JournalUpdate("")
    RETURN
*** </region>
*-------------------------------------------------------------------------------

*** <region = update Stmt id and no of recrods in contact file for first action>
UPDATE.SE.IDS:
*-----------------------------

    CHANGE @FM TO @VM IN SE.IDS
    READ.TCIB.RECENT<T2.ModelBank.TcibRecentTrans.TcibComSeName>=SE.IDS
    READ.TCIB.RECENT<T2.ModelBank.TcibRecentTrans.TcibComTotalRecords>=NOOFSEIDS
    READ.TCIB.RECENT<T2.ModelBank.TcibRecentTrans.TcibComProcessed>=NOTRANS

    T2.ModelBank.TcibRecentTrans.Write(GROUP.ID, READ.TCIB.RECENT)
    RETURN

*** </region>
*-------------------------------------------------------------------------------
*** <region = read no of recrods for processing a first action>
READ.FIRST.SET.SE.IDS:
*-----------------------------
* read records till the no.of transactions provided from tcib.recent.trans table

    IF NOTRANS AND SE.IDS THEN
        STMTENDNO = NOOFSEIDS-NOTRANS
        STMTENDNO = STMTENDNO+1
        LAST.STMT.ID = Y.STMT.IDS<STMTENDNO>
        GOSUB LAST.STMT.BOOKING.DATE
    END ELSE
        STMTENDNO = 1
    END

    START.NO=NOOFSEIDS

    LOOP
    WHILE  STMTENDNO <=START.NO
        STMT.ID=SE.IDS<1,STMTENDNO>
        IF STMT.ID THEN
            GOSUB PRODUCE.OUTPUT.DATA
        END
        STMTENDNO+=1
    REPEAT

    RETURN

*** </region>
*-------------------------------------------------------------------------------
*** <region = update no of recrods processed for next action>
READ.ID.AND.UPDATE.NEXT:
*-----------------------------
    START.NO=INTPOS+1
    GOSUB COMMON.LOOP.READ.ID
    TCIB.REC<T2.ModelBank.TcibRecentTrans.TcibComProcessed>=INCR
    T2.ModelBank.TcibRecentTrans.Write(GROUP.ID, TCIB.REC)
    RETURN

*** </region>
*-------------------------------------------------------------------------------
*** <region = update no of recrods processed for back action>
READ.ID.AND.UPDATE.BACK:
*-----------------------------
    INCR=ENDPOS
    START.NO=INTPOS+1
    GOSUB COMMON.LOOP.READ.ID

    TCIB.REC<T2.ModelBank.TcibRecentTrans.TcibComProcessed>=INTPOS
    T2.ModelBank.TcibRecentTrans.Write(GROUP.ID, TCIB.REC)


    RETURN

*** </region>
*-------------------------------------------------------------------------------
*** <region = common loop for reading stmt id based on action value(next or back)>
COMMON.LOOP.READ.ID:
*-----------------------------

    LOOP

    WHILE  START.NO <=INCR
        STMT.ID=TCIB.REC<1,START.NO>
        GOSUB PRODUCE.OUTPUT.DATA
        START.NO+=1
    REPEAT
    RETURN

*** </region>
*-------------------------------------------------------------------------------
*** <region LAST.STMT.BOOKING.DATE>
LAST.STMT.BOOKING.DATE:
*----------------------

    AMT.LCY = ''
    AMT.FCY = ''
    ENTRY.CCY =''
    STMT.NO = 1
    LAST.STMT.REC = AC.EntryCreation.StmtEntry.Read(LAST.STMT.ID,LAST.ERR.STMT)
    LAST.START.DATE = LAST.STMT.REC<AC.EntryCreation.StmtEntry.SteBookingDate>
    tmp=EB.Reports.getDRangeAndValue(); tmp<2>=LAST.START.DATE:@VM:IN.END.DATE; EB.Reports.setDRangeAndValue(tmp)

    EB.Reports.setOData(LAST.STMT.REC<AC.EntryCreation.StmtEntry.SteAccountNumber>)
    AC.ModelBank.ECalcOpenBalance()  ;* To get opening balance for the booking date.
    LAST.OPENING.BAL = EB.Reports.getOData()
    IF LAST.OPENING.BAL NE 0 THEN       ;* To get the transactions between different date
        AC.ModelBank.EStmtEnqByConcat(SEL.STMT.IDS)   ;* To get selected statement entry list
        LOOP
            REMOVE SEL.STMT FROM SEL.STMT.IDS SETTING STMT.POS
        WHILE SEL.STMT:STMT.POS
            STMT.LIST<-1> = FIELD(SEL.STMT,'*',2) ;* To get the statement entry Id
        REPEAT
    END ELSE
        STMT.LIST=SE.IDS      ;* To get the statement entry Id for same date transaction
        CONVERT @VM TO @FM IN STMT.LIST
    END
    LOCATE LAST.STMT.ID IN STMT.LIST<1> SETTING ID.POS THEN
    LAST.STMT.ID.POS = ID.POS
    END

    LOOP
    WHILE STMT.NO< ID.POS
        STMT.REC = AC.EntryCreation.StmtEntry.Read(STMT.LIST<STMT.NO>,ERR.STMT)
        AMT.LCY=STMT.REC<AC.EntryCreation.StmtEntry.SteAmountLcy>
        AMT.FCY=STMT.REC<AC.EntryCreation.StmtEntry.SteAmountFcy>
        ENTRY.CCY=STMT.REC<AC.EntryCreation.StmtEntry.SteCurrency>
        GOSUB GET.ENTRY.BALANCE
        LAST.OPENING.BAL = LAST.OPENING.BAL+ENTRY.BAL
        ENTRY.BAL = ''
        ENTRY.AMOUNT = ''
        STMT.NO+=1
    REPEAT
    tmp=EB.Reports.getDRangeAndValue(); tmp<2>=IN.START.DATE:@VM:IN.END.DATE; EB.Reports.setDRangeAndValue(tmp)
    RETURN

*** </region>
*-------------------------------------------------------------------------------
*** <region = Output data>
PRODUCE.OUTPUT.DATA:
*------------------
* Read the statement entry file and retrive the transaction code and form the description. This paragraph produces the output array.
    AMT.LCY = ''
    AMT.FCY = ''
    ENTRY.CCY = ''

    STMT.REC = AC.EntryCreation.StmtEntry.Read(STMT.ID,ERR.STMT)
    STMT.TRANS.CODE=STMT.REC<AC.EntryCreation.StmtEntry.SteTransactionCode>
    TRANS.REC = ST.Config.Transaction.Read(STMT.TRANS.CODE,ERR.TRANS)
    STMT.TRANS.CODE= TRANS.REC<ST.Config.Transaction.AcTraNarrative>
    STMT.NARRATIVE = STMT.REC<AC.EntryCreation.StmtEntry.SteNarrative,1>
    NARRATIVE.CODE= STMT.TRANS.CODE : " " :  STMT.NARRATIVE
    VALUE.DATE= STMT.REC<AC.EntryCreation.StmtEntry.SteValueDate>
    AMT.LCY=STMT.REC<AC.EntryCreation.StmtEntry.SteAmountLcy>
    AMT.FCY=STMT.REC<AC.EntryCreation.StmtEntry.SteAmountFcy>
    ENTRY.CCY=STMT.REC<AC.EntryCreation.StmtEntry.SteCurrency>

*The common variable O.DATA contains the opening balance
    IF NOT(NOTRANS) THEN
        EB.Reports.setOData(STMT.REC<AC.EntryCreation.StmtEntry.SteAccountNumber>)
        AC.ModelBank.ECalcOpenBalance()
        OPENING.BALANCE=EB.Reports.getOData()
    END ELSE
        OPENING.BALANCE = LAST.OPENING.BAL
    END
    GOSUB GET.ENTRY.BALANCE

    IF NOT(ENTRY.BAL) AND  (OPENING.BALANCE EQ 0) THEN
        OPENING.BALANCE = ''
        ENTRY.BAL = ''
    END
*Calculate the total balance
    TOT.RUN.BAL=OPENING.BALANCE+ENTRY.BAL


    IF NOT(TOT.RUN.BAL) THEN
        TOT.RUN.BAL = ''
    END


    STMT.DATE.TIME = STMT.REC<AC.EntryCreation.StmtEntry.SteDateTime>
    STMT.BOOKING.DATE=STMT.REC<AC.EntryCreation.StmtEntry.SteBookingDate>
    STMT.TRANS.REF= STMT.REC<AC.EntryCreation.StmtEntry.SteTransReference>

    IF LEN(STMT.TRANS.REF) GT 35 THEN
        GOSUB GET.TRANS.REFERENCE
    END ELSE
        STMT.TRANS.REFERENCE = STMT.TRANS.REF
    END
* New field mapping added for Narrative field
    R.FT = FT.Contract.FundsTransfer.Read(STMT.TRANS.REF,FT.ERR)  ;* Read the Funds Transfer Application
    Y.NARRATIVE = R.FT<FT.Contract.FundsTransfer.PaymentDetails,1>      ;* Get values for payment details field and store the same value in the narrative field

    IF Y.NARRATIVE EQ '' THEN
        Y.NARRATIVE = NARRATIVE.CODE    ;* Else Store the Statement entry descritpion in narrative field.
    END
*
    STMT.CURRENCY=STMT.REC<AC.EntryCreation.StmtEntry.SteCurrency>
*Form the final output array.

    TXN.ARR.INPUT = STMT.DATE.TIME:"*":STMT.BOOKING.DATE:"*":STMT.TRANS.REFERENCE:"*":Y.NARRATIVE:"*":VALUE.DATE:"*":DEBIT.AMOUNT:"*":CREDIT.AMOUNT:"*":TOT.RUN.BAL:"*":STMT.CURRENCY:"*":ENTRY.AMOUNT

* Get all /Paid In / Paid Out transactions

    BEGIN CASE
        CASE TXN.PAY.TYPE EQ 'ALL'
            TXN.ARR<-1>=TXN.ARR.INPUT
        CASE (TXN.PAY.TYPE EQ 'PAIDIN') AND CREDIT.AMOUNT
            TXN.ARR<-1>=TXN.ARR.INPUT
        CASE (TXN.PAY.TYPE EQ 'PAIDOUT') AND DEBIT.AMOUNT
            TXN.ARR<-1>=TXN.ARR.INPUT
    END CASE

    TXN.LIST.COUNT = DCOUNT(TXN.ARR,@FM)

    RETURN
*** </region>
*-------------------------------------------------------------------------------
*** <region = Check transaction reference length>
GET.TRANS.REFERENCE:
*------------------
    TRANS.REF = STMT.TRANS.REF
    STMT.TRANS.REFERENCE = ''
    REF.INDEX = 0
    REF.LENGTH.CNT = DIV(LEN(TRANS.REF),10)
    REF.INDEX = INDEX(REF.LENGTH.CNT,".",1)
    IF REF.INDEX THEN
        REF.LENGTH.CNT = REF.LENGTH.CNT[1,REF.INDEX] + 1
    END
    FOR REF = 1 TO REF.LENGTH.CNT
        STMT.TRANS.REFERENCE := TRANS.REF[1,10]:" "
        TRANS.REF = TRANS.REF[11,LEN(TRANS.REF)]
    NEXT REF
    RETURN

*** </region>
*--------------------------------------------------------------------------------


*** <region = *Sort so that the most recent balance appears at the top of the list. Also if amount is also specified in the criteria, then only entries satisfying the criteria are added to the array.
SORT.BY.AMT:
*-----------------------------
    TXN.ARR.COUNT=DCOUNT(TXN.ARR,@FM)
    TXN.ARR.POS = TXN.ARR.COUNT
    FOR I= 1 TO TXN.ARR.COUNT
        IF AMOUNT.GE NE '' OR AMOUNT.LE NE '' THEN
            STMT.ENT=TXN.ARR<TXN.ARR.POS>
            STATEMENT.AMT= FIELD(STMT.ENT,'*',10,1)
            STATEMENT.AMT= ABS(STATEMENT.AMT)
            GOSUB CHECK.AMOUNT.VALUE
            TXN.ARR.POS=TXN.ARR.POS-1
        END ELSE
            NEW.TXN.ARR<-1>= TXN.ARR<TXN.ARR.POS>
            TXN.ARR.POS=TXN.ARR.POS-1
        END
    NEXT I
    TXN.ARR = ""
    TXN.ARR=NEW.TXN.ARR
    RETURN

*** </region>
*--------------------------------------------------------------------------------
*** <region = Amount value check>
CHECK.AMOUNT.VALUE:
*------------------
    BEGIN CASE
        CASE AMOUNT.GE NE '' AND AMOUNT.LE NE ''
            IF STATEMENT.AMT >= AMOUNT.GE AND STATEMENT.AMT <= AMOUNT.LE THEN
                NEW.TXN.ARR<-1>= TXN.ARR<TXN.ARR.POS>
            END
        CASE AMOUNT.GE NE '' OR AMOUNT.LE EQ ''
            IF STATEMENT.AMT >= AMOUNT.GE THEN
                NEW.TXN.ARR<-1>= TXN.ARR<TXN.ARR.POS>
            END
        CASE AMOUNT.LE NE '' OR AMOUNT.GE EQ ''
            IF STATEMENT.AMT <= AMOUNT.LE THEN
                NEW.TXN.ARR<-1>= TXN.ARR<TXN.ARR.POS>
            END
    END CASE
    RETURN
*** </region>
*--------------------------------------------------------------------------------
*** <region = Balance update>
GET.ENTRY.BALANCE:
*------------------

    IF ENTRY.CCY EQ EB.SystemTables.getLccy() THEN
        ENTRY.AMOUNT=AMT.LCY
    END ELSE
        ENTRY.AMOUNT=AMT.FCY
    END

    IF ENTRY.AMOUNT GT 0 THEN
        CREDIT.AMOUNT = ENTRY.AMOUNT
    END ELSE
        CREDIT.AMOUNT=''
    END

    IF (ENTRY.AMOUNT NE '') AND (ENTRY.AMOUNT LT 0) THEN
        DEBIT.AMOUNT = ABS(ENTRY.AMOUNT)
    END ELSE
        DEBIT.AMOUNT=''
    END
    ENTRY.BAL=ENTRY.AMOUNT+ ENTRY.BAL

    RETURN
*** </region>
*--------------------------------------------------------------------------------
FILTER.FUTURE.PAYMENTS:
*---------------------
* Filter future dated payments from statement entry list
    LOOP
        REMOVE Y.STMT FROM Y.STMT.IDS SETTING STMT.POS      ;* Remove one statement entry from statement entry list
    WHILE Y.STMT:STMT.POS
        Y.STMT.ENT.ID=FIELD(Y.STMT,'*',2)         ;* To get statement entry Id
        STMT.REC = AC.EntryCreation.StmtEntry.Read(Y.STMT.ENT.ID,ERR.STMT)      ;* To read statement entry Id
        VALUE.DATE= STMT.REC<AC.EntryCreation.StmtEntry.SteValueDate>   ;* To get value date
        SUSPENSE.VALUE.DATE=STMT.REC<AC.EntryCreation.StmtEntry.SteSuspnseValueDate>       ;* To get suspense value date
        IF VALUE.DATE GT EB.SystemTables.getToday() AND SUSPENSE.VALUE.DATE GT EB.SystemTables.getToday() ELSE  ;* Filter for futur payments
        Y.STMT.ENT.IDS<-1>=Y.STMT   ;* To assign statement entry
        SE.IDS<-1> = FIELD(Y.STMT,'*',2)      ;* To assign statement entry Id
    END
    REPEAT
    RETURN
*--------------------------------------------------------------------------------
FILTER.CREDIT.DEBIT.PAYMENTS:
*---------------------------
* Filter paid in or out payments from statement entry list
    AMT.LCY = ''
    AMT.FCY = ''
    ENTRY.CCY = ''
    SAVE.SE.IDS = SE.IDS
    SE.IDS = ''
    LOOP
        REMOVE Y.STMT FROM SAVE.SE.IDS SETTING STMT.POS     ;* Remove one statement entry from statement entry list
    WHILE Y.STMT:STMT.POS

        STMT.REC = AC.EntryCreation.StmtEntry.Read(Y.STMT,ERR.STMT)   ;* To read statement entry Id
        AMT.LCY=STMT.REC<AC.EntryCreation.StmtEntry.SteAmountLcy>
        AMT.FCY=STMT.REC<AC.EntryCreation.StmtEntry.SteAmountFcy>
        ENTRY.CCY=STMT.REC<AC.EntryCreation.StmtEntry.SteCurrency>
        GOSUB GET.ENTRY.BALANCE
        IF TXN.PAY.TYPE EQ 'PAIDOUT' AND DEBIT.AMOUNT THEN  ;* Filter for credit payments
            STMT.IDS<-1> = Y.STMT       ;* To assign statement entry Id
        END
        IF TXN.PAY.TYPE EQ 'PAIDIN' AND CREDIT.AMOUNT THEN  ;* Filter for debit payment
            STMT.IDS<-1> = Y.STMT       ;* To assign statement entry Id
        END
    REPEAT
    SE.IDS = STMT.IDS
    SAVE.SE.IDS = ''

    RETURN
*--------------------------------------------------------------------------------

    END
