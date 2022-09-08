* @ValidationCode : MTotMTEyMjgwMTMyOTpVVEYtODoxNDY5NjM2MTQ1MTAyOmthbmFuZDotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MDcuMQ==
* @ValidationInfo : Timestamp         : 27 Jul 2016 21:45:45
* @ValidationInfo : Encoding          : UTF-8
* @ValidationInfo : User Name         : kanand
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201607.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


    $PACKAGE FT.Channels
    SUBROUTINE E.NOFILE.TC.FT.FUTURE.DATE(RET.DATA)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This is a nofile routine which returns the forward dated FT transactions
* pertaining to a customer.
* This routine returns the forward dated FT transactions based on the Transaction periods and Amount.
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile routine
* Attached To        : Enquiry > TC.NOF.FUNDS.TRANSFER.FUTURE using the Standard selection NOFILE.TC.FUNDS.TRANSFER.FUTURE
* IN Parameters      : Account number, Start date, End date, Minimum amount, Maximum amount and Debit account Flag
* Out Parameters     : Return Data(RET.DATA)
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 27/05/2016  - Enhancement 1694534 / Task 1741987
*               TCIB Componentization- Advanced Common Functional Components - Transfers/Payment/STO/Beneficiary/DD
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts

    $USING AC.CashFlow
    $USING AC.EntryCreation
    $USING EB.API
    $USING EB.Reports
    $USING EB.SystemTables
    $USING FT.Contract

*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>

    GOSUB INITIALISE
    GOSUB GET.ENQ.DATA
    GOSUB PROCESS

    RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise variables used in this routine</desc>
INITIALISE:
*-----------


    ACCOUNT.NO = ''; CHECK.LIST = ''; FT.REF = ''; STMT.ID = ''; CHECK.TYPE = 'FT'; TRANSACTION.TYPE = '' ;*Initialising variables
    CHECK.LIST.ENT.TODAY = ''; VALUE.DATE = ''; START.DATE = ''; END.DATE = ''    ;*Intialising variables

    RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.ENQ.DATA>
*** <desc>Get the selection field values from enquiry</desc>
*-----------------------------------------------------------------------------
GET.ENQ.DATA:
*------------

    LOCATE 'ACCOUNT.NO' IN EB.Reports.getDFields()<1> SETTING ID.POS THEN
    ACCOUNT.NO = EB.Reports.getDRangeAndValue()<ID.POS>       ;* Get the account number from enquiry selection
    END

    LOCATE 'START.DATE' IN EB.Reports.getDFields()<1> SETTING START.POS THEN
    START.DATE = EB.Reports.getDRangeAndValue()<START.POS>        ;* Get the Start Date from enquiry selection
    END ELSE
    START.DATE= ''
    END

    LOCATE 'END.DATE' IN EB.Reports.getDFields()<1> SETTING END.POS THEN
    END.DATE = EB.Reports.getDRangeAndValue()<END.POS>  ;* Get the End Date from enquiry selection
    END ELSE
    END.DATE=''
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

    BEGIN CASE
        CASE (START.DATE AND START.DATE LE EB.SystemTables.getToday()) OR (END.DATE AND END.DATE LE EB.SystemTables.getToday()) ;*Case for Invalid start date
            EB.Reports.setEnqError("AI-PAY.DATE.INVALID")
        CASE (START.DATE NE '') AND (END.DATE EQ '')        ;*Case to retrieve system end date when user not provided end date
            SYSTEM.END.DATE = EB.SystemTables.getToday()
            EB.API.Cdt('',SYSTEM.END.DATE,'+90C')
            END.DATE = SYSTEM.END.DATE
        CASE (NOT(START.DATE) AND NOT(END.DATE)) OR (START.DATE EQ '' AND END.DATE NE '') ;*Case to set start date value if no data passed in arguments
            SYSTEM.END.DATE = EB.SystemTables.getToday()
            EB.API.Cdt('',SYSTEM.END.DATE,'+01C')
            START.DATE = SYSTEM.END.DATE
    END CASE

    RETURN

*** </region>
*----------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= PROCESS>
* <desc> Build an array with the account numbers for the customer and then the statement
* Entry id is read from the file ACCT.ENT.FWD& ACCT.ENT.TODAY then the STMT.ENTRY file is read
* and the FT transactions are retrieved. </desc>
PROCESS:
*-------

    IF ACCOUNT.NO NE '' THEN
        GOSUB GET.STMT.REF.NO
        GOSUB GET.REF.NO
        GOSUB PROCESS.ENT.TODAY
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.STMT.REF.NO>
*<desc>The statement entry key is fetched from ACCT.ENT.FWD</desc>
GET.STMT.REF.NO:
*----------------

    R.ACCT.ENT.FWD.REC = AC.CashFlow.AcctEntFwd.Read(ACCOUNT.NO, ERR.FWD.ENT)  ;*Retrieve statement entries
    R.ACCT.ENT.TODAY.REC = AC.EntryCreation.AcctEntToday.Read(ACCOUNT.NO, ERR.ENT.TODAY)   ;*Retrieve today statement entries
    CHECK.LIST = R.ACCT.ENT.FWD.REC
    CHECK.LIST.ENT.TODAY = R.ACCT.ENT.TODAY.REC

    RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.REF.NO>
*** <desc> The FT Transactions are fetched from STMT.ENTRY </desc>
GET.REF.NO:
*----------


    LOOP
        REMOVE STMT.ID FROM CHECK.LIST SETTING POS.STMT
    WHILE STMT.ID:POS.STMT
        R.STMT.REC = AC.EntryCreation.StmtEntry.Read(STMT.ID, ERR.STMT.ENT) ;*Read individual statement entry
        IF NOT(ERR.STMT.ENT) THEN
            GOSUB GET.TRANSACTION.RECS  ;*Get transaction records to show output
        END
    REPEAT

    RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name= CHECK.STMT.REC>
*** <desc> If start,End date and Amounts are not given in the enquiry the return all the Transactions. </desc>
CHECK.STMT.REC:
*--------------

    IF START.DATE NE '' AND END.DATE NE '' AND (AMOUNT.GE NE '' OR AMOUNT.LE NE '') THEN      ;* If start and End Date not null then find Current date
        CURRENT.DATE = R.STMT.REC<AC.EntryCreation.StmtEntry.SteValueDate>  ;*Read value date
        STATEMENT.AMT = ABS(R.STMT.REC<AC.EntryCreation.StmtEntry.SteAmountLcy>)    ;*Read statement amount
        IF START.DATE LE CURRENT.DATE AND CURRENT.DATE LE END.DATE THEN ;*Case to return values based on current date
            GOSUB CHECK.AMOUNT.VALUE
        END
    END ELSE
        IF START.DATE NE '' AND END.DATE NE '' THEN     ;*Case for start date and end date provided
            CURRENT.DATE = R.STMT.REC<AC.EntryCreation.StmtEntry.SteValueDate>  ;*Read value date
            IF START.DATE LE CURRENT.DATE AND CURRENT.DATE LE END.DATE THEN
                FT.REF = R.STMT.REC<AC.EntryCreation.StmtEntry.SteTransReference> ;*Get the reference based on the Dates
                GOSUB BUILD.RET.DETAILS     ;*Form FT reference in final array
            END
        END ELSE
            IF AMOUNT.GE NE '' OR AMOUNT.LE NE '' THEN  ;*Case for amount provided scenario
                STATEMENT.AMT = ABS(R.STMT.REC<AC.EntryCreation.StmtEntry.SteAmountLcy>)    ;*Read statement amount
                GOSUB CHECK.AMOUNT.VALUE
            END ELSE
                FT.REF = R.STMT.REC<AC.EntryCreation.StmtEntry.SteTransReference>   ;*Get FT transaction reference Id
                GOSUB BUILD.RET.DETAILS
            END
        END
    END
    RETURN

*** </region>
*-----------------------------------------------------------------------------------------------------------------
*** <region name= PROCESS.ENT.TODAY>
PROCESS.ENT.TODAY:
*------------------

    LOOP
        REMOVE STMT.ENT.ID FROM CHECK.LIST.ENT.TODAY SETTING POS.ENT
    WHILE STMT.ENT.ID : POS.ENT
        R.STMT.ENT.REC = AC.EntryCreation.StmtEntry.Read(STMT.ENT.ID, ERR.STMT.ENT)
        IF NOT(ERR.STMT.ENT) THEN
            VALUE.DATE = R.STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteValueDate>
            IF VALUE.DATE GT EB.SystemTables.getToday() THEN
                GOSUB CHECK.STMT.ENT.REC
            END
        END
    REPEAT
    RETURN

*** </region>
*-----------------------------------------------------------------------------------------
*** <region name= CHECK.STMT.ENT.REC>
***<desc> If start,End date and Amounts are not given in the enquiry the return all the Transactions.</desc>
CHECK.STMT.ENT.REC:
*------------------

    BEGIN CASE
        CASE (START.DATE NE '') AND (END.DATE NE '') AND (AMOUNT.GE NE '' OR AMOUNT.LE NE '') ;*Case for amount value is provided
            CURRENT.DATE = R.STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteValueDate>
            STATEMENT.AMT = ABS(R.STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteAmountLcy>)
            IF START.DATE LE CURRENT.DATE AND CURRENT.DATE LE END.DATE THEN
                GOSUB CHECK.AMOUNT.VALUE
            END
        CASE (START.DATE NE '') AND (END.DATE NE '')      ;*Case for date value alone is provided
            CURRENT.DATE = R.STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteValueDate>
            IF START.DATE LE CURRENT.DATE AND CURRENT.DATE LE END.DATE THEN
                FT.REF = R.STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteTransReference>
                GOSUB BUILD.RET.DETAILS
            END
        CASE (AMOUNT.GE NE '') OR (AMOUNT.LE NE '')       ;*Case for amount value alone is provided
            STATEMENT.AMT = ABS(R.STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteAmountLcy>)
            GOSUB CHECK.AMOUNT.VALUE
        CASE 1
            FT.REF = R.STMT.ENT.REC<AC.EntryCreation.StmtEntry.SteTransReference>   ;*Case for default value
            GOSUB BUILD.RET.DETAILS
    END CASE
    RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= BUILD.RET.DETAILS>
*** <desc> Get the transaction ref and check if its an FT transaction . If so
* add the reference to the returning array </desc>
BUILD.RET.DETAILS:
*-----------------

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
    FT.ARRAY<-1> = FT.REF               ;*Add the FT id in array
    RET.DATA<-1> = FT.REF:"*"           ;*Form the final array which will be passed to enquiry
    END
    END
    RETURN
*** </region>
*-------------------------------------------------------------------------------------
*** <region name= CHECK.AMOUNT.VALUE>
*** <desc> If maximum amount or minimum amount is not given in the enquiry. </desc>
CHECK.AMOUNT.VALUE:
*-------------------

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

*** </region>
*--------------------------------------------------------------------------------------------
*** <region name= GET.TRANSACTION.RECS>
*** <desc> Get only transactions where the selected account is a debit account if this flag is set </desc>
GET.TRANSACTION.RECS:
*--------------------

    R.FT = ''       ;*Initialise varaibles
    FT.ERR = ''
    IF NOT(DEBIT.ACCT.FLAG) THEN        ;* If not set get statement record
        GOSUB CHECK.STMT.REC
    END ELSE
        STATEMENT.AMT.LCY = R.STMT.REC<AC.EntryCreation.StmtEntry.SteAmountLcy>   ;* If set check whether the select account is debit account of transaction
        TRANS.REF = R.STMT.REC<AC.EntryCreation.StmtEntry.SteTransReference>
        R.FT = FT.Contract.FundsTransfer.Read(TRANS.REF, FT.ERR)
        IF NOT(FT.ERR) AND (R.FT<FT.Contract.FundsTransfer.DebitAcctNo> EQ ACCOUNT.NO) THEN   ;* Read statement entry if the account is debit account of the transaction
            GOSUB CHECK.STMT.REC
        END
    END
    RETURN

*** </region>
*-------------------------------------------------------------------------------------------

    END
