* @ValidationCode : MjotNjU3NDE2NTYyOkNwMTI1MjoxNTY4MDA4NzU0ODA0OnNyYXZpa3VtYXI6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDYxMi0wMzIxOjU0OjUz
* @ValidationInfo : Timestamp         : 09 Sep 2019 11:29:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 53/54 (98.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190612-0321
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PZ.ModelBank
SUBROUTINE E.PZ.TXN.HIST.NARRATIVE(stmtEntryId, stmtEntryRec, outVal)
*-----------------------------------------------------------------------------
*** <region name= description>
*** <desc> Description about the routine</desc>
*
* New API introduced to determine the narratives (transaction details and
* beneficiary details of an underlying transaction) from the STMT.NARR.FORMAT
* record
*-----------------------------------------------------------------------------
*
* @uses EB.SystemTables
* @uses AC.StmtPrinting
* @uses AC.EntryCreation
* @package PZ.ModelBank
* @class E.PZ.TXN.HIST.NARRATIVE
* @stereotype subroutine
* @author rdhepikha@temenos.com
*
*** </region>
*
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>To define the arguments </desc>
* Incoming Arguments:
*
* @param stmtEntryId  - ID of STMT.ENTRY
* @param stmtEntryRec - STMT.ENTRY record
*
* Outgoing Arguments:
*
* @param outVal - Transaction and beneficiary details determined from
*                 STMT.NARR.FORMAT
*
*** </region>
*
*-----------------------------------------------------------------------------
*** <region name= MODIFICATION HISTORY>
*** <desc>Modification History</desc>
*-----------------------------------------------------------------------------
*
* 06/09/17 - Enhancement 2140052 / Task 2261830
*            Transaction History API - PSD2
*            New API introduced to determine the narratives from the
*            STMT.NARR.FORMAT record
*
* 22/01/19  Enhancement 2741263 / Task 2978712
*           Changes made to return debit account and debitor name of the underlying FT transaction
*
*
* 09/09/19 - Enhancement 3308494 / Task 3308495
*            TI Changes - Component moved from ST to AC.
*
*** </region>
*
*-----------------------------------------------------------------------------

*** <region name= insertlibrary>
*** <desc>To define the packages being used </desc>

    $USING EB.SystemTables
    $USING AC.StmtPrinting
    $USING AC.EntryCreation
    $USING PZ.ModelBank

*** </region>

*-----------------------------------------------------------------------------

*** <region name= MAIN PROCESS LOGIC>
*** <desc>Main process logic</desc>

    GOSUB initialise ;* Initialise the required values

    IF sumDetail EQ "D" AND checkNetId NE "S!" THEN ;* do not proceed further if the stmt entry is a net entry
        GOSUB process ;* Main process
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc> Initialise the required values </desc>

    systemId = stmtEntryRec<AC.EntryCreation.StmtEntry.SteSystemId>
    rEbSystemId = ""
    systemIdErr = ""
    narrFormatId = ""
    sysIdApplication = ""
    txnReference = stmtEntryRec<AC.EntryCreation.StmtEntry.SteTransReference>[";",1,1]
    narrative = ""
    sumDetail = PZ.ModelBank.getSummaryOption()
    outVal = ""
    checkNetId = stmtEntryId[1,2]

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= process>
process:
*** <desc> Main process </desc>

    GOSUB formNarrativeFormatId ;* To determine the ID of STMT.NARR.FORMAT
    
    IF NOT(narrFormatId) THEN
        RETURN ;* if ID of STMT.NARR.FORMAT is not determined, donot proceed further
    END

* API called to determine the narrative from the STMT.NARR.FORMAT.
    AC.StmtPrinting.EbBuildNarrative(narrFormatId, txnReference, stmtEntryId, stmtEntryRec, "", narrative)

* determine the required values from the out variable of the API EB.BUILD.NARRATIVE
    LOCATE "TXN.CCY" IN narrative<1,1> SETTING txnCcyPos THEN
        txnCcy = narrative<1,txnCcyPos+1>
    END

    LOCATE "TXN.CCY.AMT" IN narrative<1,1> SETTING txnCcyAmtPos THEN
        txnCcyAmt = narrative<1,txnCcyAmtPos+1>
    END

    LOCATE "PAYEE.DETAILS" IN narrative<1,1> SETTING payeePos THEN
        payeeDetails = narrative<1,payeePos+1> ;* Payee details will be formatted as PayeeAccount # PayeeName, split the values before assiginig to the out parameter
        payeeAccount = FIELD(payeeDetails, "#", 1)
        payeeName = FIELD(payeeDetails, "#", 2)
        debitAccount = FIELD(payeeDetails, "#", 3) ;*or we can add a new line in stmt.narr.format
        debitCustomer = FIELD(payeeDetails, "#", 4)
    
        
    END

    GOSUB formOutputArray ;* To form the output array

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= formOutputArray>
formOutputArray:
*** <desc> To form the output array </desc>

    outVal<-1> = txnCcy         ;* Transaction currency
    outVal<-1> = txnCcyAmt      ;* Amount in transaction currency
    outVal<-1> = payeeAccount   ;* Payee Account Identification
    outVal<-1> = payeeName      ;* Payee Identification
    outVal<-1> = debitAccount   ;*debitAccount
    outVal<-1> = debitCustomer  ;*Debit customer

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= formNarrativeFormatId>
formNarrativeFormatId:
*** <desc> To determine the ID of STMT.NARR.FORMAT </desc>

* if the SYSTEM.ID is FT, STMT.NARR.FORMAT Id will be "FT.TXHIS"
* if the SYSTEM.ID is PP or the application is EB.SYSTEM.ID is "PP.ORDER.ENTRY", STMT.NARR.FORMAT Id will be "PP.TXHIS"

    systemId = systemId[1,2]
    rEbSystemId = EB.SystemTables.SystemId.CacheRead(systemId, systemIdErr)
    sysIdApplication = rEbSystemId<EB.SystemTables.SystemId.SidApplication>

    IF sysIdApplication EQ "FUNDS.TRANSFER" OR (sysIdApplication EQ "PP.ORDER.ENTRY" OR systemId EQ "PP") THEN
        narrFormatId = systemId :".TXHIS"
    END

RETURN
*** </region>

END


