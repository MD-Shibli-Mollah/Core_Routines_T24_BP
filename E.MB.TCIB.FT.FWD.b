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
* <Rating>-147</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T2.ModelBank
    SUBROUTINE E.MB.TCIB.FT.FWD(RET.DATA)
*-------------------------------------------------------------------------------
* This is a nofile routine which returns the forward dated FT transactions
* pertaining to a customer.
* This routine returns the forward dated FT transactions based on the Transaction periods and Amount.
*-------------------------------------------------------------------------------
* Modification History :
*---------------------
* 25/11/14 - Task 1189310 / Defect 1185526
*            Get transactions when selected account is debit account number
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
*
* 30/12/15 - Defect 1517159 / Task 1585358
*            FT records which is inputted in different branch are not shown.
*-------------------------------------------------------------------------------
    $USING AC.CashFlow
    $USING AC.EntryCreation
    $USING EB.API
    $USING EB.Reports
    $USING EB.SystemTables
    $USING FT.Contract
	
    GOSUB INITIALISE
    GOSUB GET.ENQ.DATA
    GOSUB PROCESS
    RETURN

*-----------------------------------------------------------------------------
INITIALISE:
*-----------------------------------------------------------------------------
*Open Required files and initialise the variables

    ACCOUNT.NUMBERS = ''; ACCT.ID = ''
    CHECK.LIST = ''
    FT.REF = ''
    STMT.ID = ''
    CHECK.TYPE = 'FT'
    TRANS.TYPE = ''
    CHECK.LIST.ENT.TODAY = '';VALUE.DT = '';
    IN.START.DATE = ''
    IN.END.DATE = ''
    RETURN

*-----------------------------------------------------------------------------
GET.ENQ.DATA:

    LOCATE 'ACCT.ID' IN EB.Reports.getDFields()<1> SETTING ID.POS THEN
    ACCT.ID = EB.Reports.getDRangeAndValue()<ID.POS>       ;* Get the account number from enquiry selection
    END

    LOCATE 'IN.START.DATE' IN EB.Reports.getDFields()<1> SETTING START.POS THEN
    IN.START.DATE = EB.Reports.getDRangeAndValue()<START.POS>        ;* Get the Start Date from enquiry selection
    END ELSE
    IN.START.DATE= ''
    END

    LOCATE 'IN.END.DATE' IN EB.Reports.getDFields()<1> SETTING END.POS THEN
    IN.END.DATE = EB.Reports.getDRangeAndValue()<END.POS>  ;* Get the End Date from enquiry selection
    END ELSE
    IN.END.DATE=''
    END

    LOCATE 'AMOUNT.MIN.LCY' IN EB.Reports.getDFields()<1> SETTING MIN.AMT.POS THEN
    AMOUNT.GE = EB.Reports.getDRangeAndValue()<MIN.AMT.POS>          ;* Get the Amount Range from Enquiry selection.
    END ELSE
    AMOUNT.GE = ''
    END

    LOCATE 'AMOUNT.MAX.LCY' IN EB.Reports.getDFields()<1> SETTING MAX.AMT.POS THEN
    AMOUNT.LE = EB.Reports.getDRangeAndValue()<MAX.AMT.POS>          ;* Get the Amount Range from Enquiry selection.
    END ELSE
    AMOUNT.LE = ''
    END
    LOCATE 'DEBIT.ACCT.FLAG'  IN EB.Reports.getDFields()<1> SETTING DEBIT.POS THEN
    DEBIT.ACCT.FLAG = EB.Reports.getDRangeAndValue()<DEBIT.POS>      ;* Get the Debit account number flag Range from Enquiry selection.
    END ELSE
    DEBIT.ACCT.FLAG = ''
    END

    IF (IN.START.DATE AND IN.START.DATE LE EB.SystemTables.getToday()) OR (IN.END.DATE AND IN.END.DATE LE EB.SystemTables.getToday()) THEN
        EB.Reports.setEnqError("AI-PAY.DATE.INVALID")
    END

    IF IN.START.DATE NE '' AND IN.END.DATE EQ '' THEN
        Y.END.DATE = EB.SystemTables.getToday()
        EB.API.Cdt('',Y.END.DATE,'+90C')
        IN.END.DATE = Y.END.DATE
    END
    IF (NOT(IN.START.DATE) AND NOT(IN.END.DATE))OR (IN.START.DATE EQ '' AND IN.END.DATE NE '') THEN ;* set start date value if no data passed in arguments
        Y.END.DATE = EB.SystemTables.getToday()
        EB.API.Cdt('',Y.END.DATE,'+01C')
        IN.START.DATE = Y.END.DATE
    END
    RETURN
*------------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
* Build an array with the account numbers for the customer and then the statement
* Entry id is read from the file ACCT.ENT.FWD& ACCT.ENT.TODAY then the STMT.ENTRY file is read
* and the FT transactions are retrieved.

    IF ACCT.ID NE '' THEN
        GOSUB GET.STMT.REF.NO
        GOSUB GET.REF.NO
        GOSUB PROCESS.ENT.TODAY
    END

*-----------------------------------------------------------------------------
GET.STMT.REF.NO:
*-----------------------------------------------------------------------------
*The statement entry key is fetched from ACCT.ENT.FWD

    R.ACCT.ENT.FWD.REC = AC.CashFlow.AcctEntFwd.Read(ACCT.ID, ERR3)
    R.ACCT.ENT.TODAY.REC = AC.EntryCreation.AcctEntToday.Read(ACCT.ID, ERR6)
    CHECK.LIST = R.ACCT.ENT.FWD.REC
    CHECK.LIST.ENT.TODAY = R.ACCT.ENT.TODAY.REC
    RETURN

*-----------------------------------------------------------------------------
GET.REF.NO:
*-----------------------------------------------------------------------------
* The FT Transactions are fetched from STMT.ENTRY

    LOOP
        REMOVE STMT.ID FROM CHECK.LIST SETTING POS4
    WHILE STMT.ID:POS4
        R.STMT.REC = AC.EntryCreation.StmtEntry.Read(STMT.ID, ERR5)
        IF NOT(ERR5) THEN
            GOSUB GET.TRANSACTION.RECS  ;*Get transaction records to show output
        END
    REPEAT
    RETURN

*-----------------------------------------------------------------------------
CHECK.STMT.REC:
*-----------------------------------------------------------------------------

* If start,End date and Amounts are not given in the enquiry the return all the Transactions.

    IF IN.START.DATE NE '' AND IN.END.DATE NE '' AND (AMOUNT.GE NE '' OR AMOUNT.LE NE '') THEN      ;* If start and End Date not null then find Current date
        CURRENT.DATE = R.STMT.REC<AC.EntryCreation.StmtEntry.SteValueDate>
        STATEMENT.AMT = ABS(R.STMT.REC<AC.EntryCreation.StmtEntry.SteAmountLcy>)
        IF IN.START.DATE LE CURRENT.DATE AND CURRENT.DATE LE IN.END.DATE THEN
            GOSUB CHECK.AMOUNT.VALUE
        END

    END ELSE
        IF IN.START.DATE NE '' AND IN.END.DATE NE '' THEN
            CURRENT.DATE = R.STMT.REC<AC.EntryCreation.StmtEntry.SteValueDate>
            IF IN.START.DATE LE CURRENT.DATE AND CURRENT.DATE LE IN.END.DATE THEN
                FT.REF = R.STMT.REC<AC.EntryCreation.StmtEntry.SteTransReference> ;*Get the reference based on the Dates
                GOSUB BUILD.RET.DETAILS
            END
        END ELSE
            IF AMOUNT.GE NE '' OR AMOUNT.LE NE '' THEN
                STATEMENT.AMT = ABS(R.STMT.REC<AC.EntryCreation.StmtEntry.SteAmountLcy>)
                GOSUB CHECK.AMOUNT.VALUE
            END ELSE
                FT.REF = R.STMT.REC<AC.EntryCreation.StmtEntry.SteTransReference>
                GOSUB BUILD.RET.DETAILS
            END
        END
    END
    RETURN

*-----------------------------------------------------------------------------
PROCESS.ENT.TODAY:
*-----------------------------------------------------------------------------

    LOOP
        REMOVE STMT.ENT.ID FROM CHECK.LIST.ENT.TODAY SETTING POS7
    WHILE STMT.ENT.ID : POS7
        R.STMT.ENT.REC = AC.EntryCreation.StmtEntry.Read(STMT.ENT.ID, ERR7)
        IF NOT(ERR7) THEN
            VALUE.DT = R.STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteValueDate>
            IF VALUE.DT GT EB.SystemTables.getToday() THEN
                GOSUB CHECK.STMT.ENT.REC
            END
        END
    REPEAT
    RETURN

*-----------------------------------------------------------------------------------------
CHECK.STMT.ENT.REC:
*-------------------------------------------------------------------------------------------

* If start,End date and Amounts are not given in the enquiry the return all the Transactions.

    IF IN.START.DATE NE '' AND IN.END.DATE NE '' AND (AMOUNT.GE NE '' OR AMOUNT.LE NE '') THEN
        CURRENT.DATE = R.STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteValueDate>
        STATEMENT.AMT = ABS(R.STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteAmountLcy>)
        IF IN.START.DATE LE CURRENT.DATE AND CURRENT.DATE LE IN.END.DATE THEN
            GOSUB CHECK.AMOUNT.VALUE
        END
    END ELSE
        IF IN.START.DATE NE '' AND IN.END.DATE NE '' THEN
            CURRENT.DATE = R.STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteValueDate>
            IF IN.START.DATE LE CURRENT.DATE AND CURRENT.DATE LE IN.END.DATE THEN
                FT.REF = R.STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteTransReference>
                GOSUB BUILD.RET.DETAILS
            END
        END ELSE
            IF AMOUNT.GE NE '' OR AMOUNT.LE NE '' THEN
                STATEMENT.AMT = ABS(R.STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteAmountLcy>)
                GOSUB CHECK.AMOUNT.VALUE
            END ELSE
                FT.REF = R.STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteTransReference>
                GOSUB BUILD.RET.DETAILS
            END
        END
    END
    RETURN

*-----------------------------------------------------------------------------
BUILD.RET.DETAILS:
*-----------------------------------------------------------------------------
* Get the transaction ref and check if its an FT transaction . If so
* add the reference to the returning array
    BRANCH.FT.REF = ''
    TRANS.TYPE = LEFT(FT.REF,2)
    IF TRANS.TYPE EQ CHECK.TYPE THEN
        LOCATE FT.REF IN FT.ARRAY SETTING FT.FWD.POS THEN
		END
		ELSE
            BRANCH.FT.REF = FIELD(FT.REF,'\',2)   ;* Remove mnemonic if the FT belongs to the branch company
            IF BRANCH.FT.REF THEN
                FT.REF = FIELD(FT.REF,'\',1)
            END
			FT.ARRAY<-1> = FT.REF
			RET.DATA<-1> = FT.REF:"*"
		END
    END
    RETURN
*-------------------------------------------------------------------------------------
CHECK.AMOUNT.VALUE:
*--------------------------------------------------------------------------------------
* If maximum amount or minimum amount is not given in the enquiry.
    BEGIN CASE
        CASE AMOUNT.GE NE '' AND AMOUNT.LE NE ''
            IF STATEMENT.AMT >= AMOUNT.GE AND STATEMENT.AMT <= AMOUNT.LE THEN
                FT.REF = R.STMT.REC<AC.EntryCreation.StmtEntry.SteTransReference>     ;*Get the reference based on the Amount
                GOSUB BUILD.RET.DETAILS
            END
        CASE AMOUNT.GE NE '' OR AMOUNT.LE EQ ''
            IF STATEMENT.AMT >= AMOUNT.GE THEN
                FT.REF = R.STMT.REC<AC.EntryCreation.StmtEntry.SteTransReference>     ;*Get the reference based on the Amount
                GOSUB BUILD.RET.DETAILS
            END
        CASE AMOUNT.LE NE '' OR AMOUNT.GE EQ ''
            IF STATEMENT.AMT <= AMOUNT.LE THEN
                FT.REF = R.STMT.REC<AC.EntryCreation.StmtEntry.SteTransReference>     ;*Get the reference based on the Amount
                GOSUB BUILD.RET.DETAILS
            END
    END CASE
    RETURN
*--------------------------------------------------------------------------------------------
GET.TRANSACTION.RECS:
*--------------------
* Get only transactions where the selected account is a debit account if this flag is set
    R.FT = ''       ;*Initialise varaibles
    FT.ERR = ''
    IF NOT(DEBIT.ACCT.FLAG) THEN        ;* If not set get statement record
        GOSUB CHECK.STMT.REC
    END ELSE
        STATEMENT.AMT.LCY = R.STMT.REC<AC.EntryCreation.StmtEntry.SteAmountLcy>   ;* If set check whether the select account is debit account of transaction
        TRANS.REF = R.STMT.REC<AC.EntryCreation.StmtEntry.SteTransReference>
        R.FT = FT.Contract.FundsTransfer.Read(TRANS.REF, FT.ERR)
        IF NOT(FT.ERR) AND (R.FT<FT.Contract.FundsTransfer.DebitAcctNo> EQ ACCT.ID) THEN   ;* Read statement entry if the account is debit account of the transaction
            GOSUB CHECK.STMT.REC
        END
    END
    RETURN
*-------------------------------------------------------------------------------------------
    END
*-----------------------------------------------------------------------------
