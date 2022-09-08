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
* <Rating>-89</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T2.ModelBank
    SUBROUTINE NOFILE.LAST.N.TXNS(TXN.ARR)
*----------------------------------------------------------------------------
* MODIFICATION HISTORY:
*--------------------
* 23/09/09 - BG_100025315
*            Insert to be taken from GLOBUS.BP removed..
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
* Routine to retrieve the transactions based on amount,start date and end date  if specified.
* If dates are not specified then produces the data for the last one month
*-------------------------------------------------------------------------------
*** <region = Insert Files>
*** <desc>Insert files</desc>

    $USING AC.EntryCreation
    $USING AC.AccountOpening
    $USING AC.ModelBank
    $USING EB.API
    $USING EB.Reports
    $USING EB.SystemTables
    $USING ST.Config

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

    ERR.AC = ""
    ID.POS="";START.POS="";END.POS="";LCY.POS =""
    FN.AC="F.ACCOUNT"
    F.AC=""
    ERR.AC=""
    ENTRY.BAL=""
    NET.ENTRIES.ARR=""
    NEW.TXN.ARR=""
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
    EB.API.Cdt('',Y.END.DATE,'+01C')

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

    EB.API.Cdt('',IN.END.DATE,'+01C')
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
    AC.ModelBank.EStmtEnqByConcat(Y.STMT.IDS)

    LOOP
        REMOVE Y.STMT FROM Y.STMT.IDS SETTING STMT.POS
    WHILE Y.STMT:STMT.POS
        STMT.ID = FIELD(Y.STMT,'*',2)
        *To handle netted entries set the flag to one only for the first entry
        IF INDEX(STMT.ID,"!",1) THEN
            IS.NET.ENTRY=1
            LOCATE STMT.ID IN NET.ENTRIES.ARR<1> SETTING POS2 THEN
            FLAG=0
        END  ELSE
            NET.ENTRIES.ARR<-1>=STMT.ID
            FLAG=1
        END
    END

    STMT.AMOUNT= FIELD(Y.STMT,'*',6)
*Produce the stmt entry only for the first occurance of a netted entry
    IF IS.NET.ENTRY EQ 1 THEN
        IF FLAG EQ 1 THEN
            GOSUB PRODUCE.OUTPUT.DATA
        END
    END ELSE
        GOSUB PRODUCE.OUTPUT.DATA
    END
    IS.NET.ENTRY=0
    REPEAT

*Sort so that the most recent balance appears at the top of the list. Also if amount is also specified in the criteria, then only entries satisfying the criteria are added to the array.
    TXN.ARR.COUNT=DCOUNT(TXN.ARR,@FM)
    TXN.ARR.POS = TXN.ARR.COUNT
    FOR I= 1 TO TXN.ARR.COUNT
        IF AMOUNT.GE NE '' OR AMOUNT.LE NE '' THEN
            STMT.ENT=TXN.ARR<TXN.ARR.POS>
            STATEMENT.AMT= FIELD(STMT.ENT,'*',10,1)
            STATEMENT.AMT= ABS(STATEMENT.AMT)
            GOSUB CHECK.AMOUNT.VALUE
            *     IF STATEMENT.AMT >= AMOUNT.LCY<1,1,1> AND STATEMENT.AMT <= AMOUNT.LCY<1,1,2> THEN
            *         NEW.TXN.ARR<-1>= TXN.ARR<TXN.ARR.POS>
            *     END
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
*-------------------------------------------------------------------------------
*** <region = Output data>
PRODUCE.OUTPUT.DATA:
*------------------
* Read the statement entry file and retrive the transaction code and form the description. This paragraph produces the output array.
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
*The common variable O.DATA contains the opening balance
    EB.Reports.setOData(STMT.REC<AC.EntryCreation.StmtEntry.SteAccountNumber>)
    AC.ModelBank.ECalcOpenBalance()
    OPENING.BALANCE=EB.Reports.getOData()

    ENTRY.BAL=ENTRY.AMOUNT+ ENTRY.BAL

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
    STMT.CURRENCY=STMT.REC<AC.EntryCreation.StmtEntry.SteCurrency>
*Form the final output array.
    TXN.ARR.INPUT = STMT.DATE.TIME:"*":STMT.BOOKING.DATE:"*":STMT.TRANS.REFERENCE:"*":NARRATIVE.CODE:"*":VALUE.DATE:"*":DEBIT.AMOUNT:"*":CREDIT.AMOUNT:"*":TOT.RUN.BAL:"*":STMT.CURRENCY:"*":ENTRY.AMOUNT
    TXN.ARR<-1>=TXN.ARR.INPUT

    RETURN
*** </region>
*-------------------------------------------------------------------------------
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
*** <region = Check transaction reference length>
GET.TRANS.REFERENCE:
*------------------
    TRANS.REF = STMT.TRANS.REF
    STMT.TRANS.REFERENCE = ''
    REF.INDEX = 0
    REF.LENGTH.CNT = DIV(LEN(TRANS.REF),35)
    REF.INDEX = INDEX(REF.LENGTH.CNT,".",1)
    IF REF.INDEX THEN
        REF.LENGTH.CNT = REF.LENGTH.CNT[1,REF.INDEX] + 1
    END
    FOR REF = 1 TO REF.LENGTH.CNT
        STMT.TRANS.REFERENCE := TRANS.REF[1,35]:" "
        TRANS.REF = TRANS.REF[36,LEN(TRANS.REF)]
    NEXT REF
    RETURN

*** </region>
*--------------------------------------------------------------------------------
    END
