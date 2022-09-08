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
* <Rating>-164</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.GET.AC.UNAUTH.ENTRIES(ALL.UNAUTH.ENTRIES)
*-----------------------------------------------------------------------------
**
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
**
** Consversion routine which gets the account ID in O.DATA and
** returns the Unauthorised entries (Real and Fwd).
**
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Changes done to the sub-routine</desc>
* Modification History :
*
* 03/11/2011 - Enhancement - 99121 / Task - 295691
*              Build link to unauthorised entries for accounts.
*              New Version.
*
* 06/01/12 - Defect 335717 / Task 335719
*            OUR.REFERENCE value is not getting updated for TELLER Transactions.
*            Hence changed as TRANS.REFERENCE.
*
* 29/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 08/06/2015 - Defect -1368205(PACS00461880)/ Task - 1369903
*			   When transaction is done in Foreign Crncy the corresponding
*			   amount will be populated in the field Total Unauth Debit/Credit
*			   in GET.ACC.UNAUTH.ENTRIES enquiry instead of the LCY amount.
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>Inserts used in the sub-routine</desc>
*
    $USING EB.Reports
    $USING AC.EntryCreation
    $USING AC.BalanceUpdates
    $USING AC.CashFlow

*
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Process Logic>
*** <desc>Program Control</desc>
*
    GOSUB INITIALISE
    GOSUB CALL.ACCOUNTING.SERVICE
    GOSUB FETCH.UNAUTH.ENTRIES

    RETURN
*
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= initialise>
*** <desc>initialise the required variables </desc>
*
INITIALISE:

    LOCATE 'ACCOUNT.NUMBER' IN EB.Reports.getDFields()<1> SETTING YACCOUNT.POS THEN  ;* Get the Account Number.
    ACCOUNT.NO = EB.Reports.getDRangeAndValue()<YACCOUNT.POS>
    END ELSE
    RETURN
    END

    balanceDetails = ''       ;* Variable will hold the ENTRY.HOLD and FWD.ENTRY.HOLD id's.
    mode = 'GET.KEY'          ;* Variable used to get the ENTRY.HOLD and FWD.ENTRY.HOLD keys.
    type = 'BOTH'   ;* Variable used to get both the real and fwd keys.

    UNAUTH.ENT.REC = ''       ;* Array holds unauthorised real entries.
    FWD.UNAU.ENT.REC = ''     ;* Array holds unauthorised fwd entries.
    ALL.UNAUTH.ENTRIES = ''   ;* Array holds both the unauthorised entries.

    R.ENTRY.ARRAY = ''

    RET.DATA = ''
    RET.FWD.DATA = ''

    RETURN
*
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= call accounting service>
*** <desc>make a call to the accounting service routine.</desc>
*
CALL.ACCOUNTING.SERVICE:

    AC.BalanceUpdates.AccountserviceGetunaudetails(ACCOUNT.NO, balanceDetails, mode, type)  ;* Returns the respective keys from ENTRY.HOLD and FWD.ENTRY.HOLD.

    RETURN
*
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Fetch Unauthorised Entries>
*** <desc>Form real and fwd entries </desc>
*
FETCH.UNAUTH.ENTRIES:

    IF balanceDetails<3> THEN
        ENT.HLD.KEYS = balanceDetails<3>          ;* Holds the list of ENTRY.HOLD keys.
        GOSUB READ.ENTRY.HOLD                     ;* Read ENTRY.HOLD and get respective entries.
        ALL.UNAUTH.ENTRIES = UNAUTH.ENT.REC       ;* Array holds unauthorised real entries.
    END

    IF balanceDetails<6> THEN
        FWD.ENT.HLD.KEYS = balanceDetails<6>      ;* Holds the list of FWD.ENTRY.HOLD keys.
        GOSUB READ.FWD.ENTRY.HOLD                 ;* Read Fwd Entry Hold and get respective entries.
        IF ALL.UNAUTH.ENTRIES THEN
            ALL.UNAUTH.ENTRIES = ALL.UNAUTH.ENTRIES:@FM:FWD.UNAU.ENT.REC        ;* Append the fwd entries with the real entries.
        END ELSE
            ALL.UNAUTH.ENTRIES = FWD.UNAU.ENT.REC
        END
    END

    RETURN
*
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Get Real Entries>
*** <desc>Get Real Entries </desc>
*
READ.ENTRY.HOLD:

    CNT.NAU.KEYS = DCOUNT(ENT.HLD.KEYS, @VM)       ;* Count the number of Entry Hold Keys.

    FOR LOOP.KEY = 1 TO CNT.NAU.KEYS               ;* Loop all the keys.
        ENTRY.HOLD.ID = ENT.HLD.KEYS<1, LOOP.KEY>  ;* pick the keys one by one.
        R.ENTRY.HOLD = ''
        RETURN.ERROR = ''
        R.ENTRY.HOLD = AC.EntryCreation.tableEntryHold(ENTRY.HOLD.ID, RETURN.ERROR)       ;* Read F.ENTRY.HOLD file.
        IF NOT(RETURN.ERROR) THEN
            GOSUB GET.REAL.ENTRIES      ;* Get the respective entries from the ENTRY.HOLD.
        END
    NEXT LOOP.KEY

    RETURN
*
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Read Entry Hold>
*** <desc>Read Entry Hold </desc>
*
GET.REAL.ENTRIES:

    CNT.ENTRIES = DCOUNT(R.ENTRY.HOLD, @FM)       ;* Count the number of entries in ENTRY.HOLD record.

    FOR LOOP.ENTRY = 1 TO CNT.ENTRIES   ;* Loop all the entries.
        IF ACCOUNT.NO EQ R.ENTRY.HOLD<LOOP.ENTRY, AC.EntryCreation.StmtEntry.SteAccountNumber> THEN ;* Take the entry if the account number passed is matched in the entry.
            R.ENTRY.ARRAY = R.ENTRY.HOLD<LOOP.ENTRY>         ;* Pick the entries one by one.
            GOSUB GET.REQUIRED.VALUES
            RET.DATA = Y.ACCCOUNT.NO:"*":Y.CUSTOMER.NO:"*":Y.OUR.REFERENCE:"*":Y.CURRENCY:"*":Y.UNAUTH.DEBIT:"*":Y.UNAUTH.CREDIT
            IF UNAUTH.ENT.REC THEN
                UNAUTH.ENT.REC = UNAUTH.ENT.REC:@FM:RET.DATA
            END ELSE
                UNAUTH.ENT.REC = RET.DATA
            END
        END
    NEXT LOOP.ENTRY

    RETURN
*
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Read Fwd Entry Hold>
*** <desc>Read Fwd Entry Hold </desc>
*
READ.FWD.ENTRY.HOLD:

    CNT.FWD.NAU.KEYS = DCOUNT(FWD.ENT.HLD.KEYS, @VM)        ;* Count the number of Fwd Entry Hold Keys.

    FOR LOOP.FWD.KEY = 1 TO CNT.FWD.NAU.KEYS      ;* Loop all the keys.
        FWD.ENTRY.HOLD.ID = FWD.ENT.HLD.KEYS<1, LOOP.FWD.KEY>         ;* pick the keys one by one.
        R.FWD.ENTRY.HOLD = ''
        RETURN.ERROR = ''
        R.FWD.ENTRY.HOLD = AC.CashFlow.tableFwdEntryHold(FWD.ENTRY.HOLD.ID,RETURN.ERROR)   ;* Read F.FWD.ENTRY.HOLD file.
        IF NOT(RETURN.ERROR) THEN
            GOSUB GET.FWD.ENTRIES       ;* Get the respective entries from the FWD.ENTRY.HOLD.
        END
    NEXT LOOP.FWD.KEY

    RETURN
*
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Get Fwd Entries>
*** <desc>Get Fwd entries </desc>
*
GET.FWD.ENTRIES:

    CNT.FWD.ENTRIES = DCOUNT(R.FWD.ENTRY.HOLD, @FM)         ;* Count the number of entries in ENTRY.HOLD record.

    FOR LOOP.FWD.ENTRY = 1 TO CNT.FWD.ENTRIES     ;* Loop all the entries.
        IF ACCOUNT.NO EQ R.FWD.ENTRY.HOLD<LOOP.FWD.ENTRY, AC.EntryCreation.StmtEntry.SteAccountNumber> THEN       ;* Take the entry if the account number passed is matched in the entry.
            R.ENTRY.ARRAY = R.FWD.ENTRY.HOLD<LOOP.FWD.ENTRY>          ;* Pick the entries one by one.
            GOSUB GET.REQUIRED.VALUES
            Y.FWD.FLAG = "1"
            RET.FWD.DATA = Y.ACCCOUNT.NO:"*":Y.CUSTOMER.NO:"*":Y.OUR.REFERENCE:"*":Y.CURRENCY:"*":"*":"*":Y.UNAUTH.DEBIT:"*":Y.UNAUTH.CREDIT:"*":Y.FWD.FLAG
            IF FWD.UNAU.ENT.REC THEN
                FWD.UNAU.ENT.REC = FWD.UNAU.ENT.REC:@FM:RET.FWD.DATA  ;* '@FM' is the delimiter between the entries.
            END ELSE
                FWD.UNAU.ENT.REC = RET.FWD.DATA
            END
        END
    NEXT LOOP.FWD.ENTRY

    RETURN
*
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Get Required Values>
*** <desc>Get Required Values </desc>
*
GET.REQUIRED.VALUES:
********************
    TRAN.AMT = ''
    GOSUB REFRESH.RETURN.VARIABLES

    Y.ACCCOUNT.NO = R.ENTRY.ARRAY<1, AC.EntryCreation.StmtEntry.SteAccountNumber>
    Y.CUSTOMER.NO = R.ENTRY.ARRAY<1, AC.EntryCreation.StmtEntry.SteCustomerId>
    Y.OUR.REFERENCE = R.ENTRY.ARRAY<1, AC.EntryCreation.StmtEntry.SteTransReference>
    Y.CURRENCY = R.ENTRY.ARRAY<1, AC.EntryCreation.StmtEntry.SteCurrency>

    IF R.ENTRY.ARRAY<1, AC.EntryCreation.StmtEntry.SteAmountFcy> NE '' THEN
        TRAN.AMT = R.ENTRY.ARRAY<1, AC.EntryCreation.StmtEntry.SteAmountFcy>
    END ELSE
        TRAN.AMT = R.ENTRY.ARRAY<1, AC.EntryCreation.StmtEntry.SteAmountLcy>
    END

    IF TRAN.AMT LT 0 THEN
        Y.UNAUTH.DEBIT = TRAN.AMT
    END ELSE
        Y.UNAUTH.CREDIT = TRAN.AMT
    END


    RETURN
*
*** </region>
*------------------------------------------------------------------------------------------------------------

*** <region name= Refresh Return Variables>
*** <desc>Refresh Return Variables </desc>
*
REFRESH.RETURN.VARIABLES:

    Y.ACCCOUNT.NO = ''	     ;    Y.CUSTOMER.NO = ''
    Y.OUR.REFERENCE = ''      ;    Y.CURRENCY = ''
    Y.UNAUTH.DEBIT = ''       ;    Y.UNAUTH.CREDIT = ''

    RETURN
*
*** </region>
*------------------------------------------------------------------------------------------------------------

    END
