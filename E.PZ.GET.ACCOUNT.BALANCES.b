* @ValidationCode : Mjo0MzUwOTI3MjY6Y3AxMjUyOjE2MDgyOTI0MjcyOTA6c2Fpa3VtYXIubWFra2VuYTo4OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEyLjIwMjAxMTI4LTA2MzA6MjAxOjE5OA==
* @ValidationInfo : Timestamp         : 18 Dec 2020 17:23:47
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : 8
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 198/201 (98.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.20201128-0630
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PZ.ModelBank
SUBROUTINE E.PZ.GET.ACCOUNT.BALANCES(accData)
*-----------------------------------------------------------------------------
*New NOFILE Enquiry routine to return the different balances of the account provided
*
*IN/OUT:
* accData : Out param which contains the balance details
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 05/02/19 - En 2741258 / Task 2964972
*            Nofile Enquiry routine to return the different balances of the account provided
*
* 13/03/19 - En 3015074 / Task 3032944
*            Additional changes for STET requirement
*
* 20/06/20 - Defect 3811325 / Task 3811770
*            The json field lastChangeDateTime is displayed in the JSON response for the case where there are no transactions for the account sent in get account balance API.
*            Hence do not populate lastdateChangeTime if the account has no transactions.
*
* 25/06/2020 - Defect 3816857 / Task 3820586
*              Display results for inactive and closed accounts also. Throw error only if account is invalid.
*
* 08/07/2020 - Defect 3840480 / Task 3845654
*              Looping added in ACCT.STMT.PRINTED to fetch the correct record when IF.NO.MOVEMENT is set to YES.
*
* 18/09/20 - Enhancement 3934727 / Task 3940804
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*
* 15/12/20 - Enhancement 3760081 / Task 4133585
*          -  New routine implementation AC.READ.ACCT.STMT.PRINT to facilitate READ on STMT.PRINTED and STMT2.PRINTED files
*-----------------------------------------------------------------------------
    $USING AC.AccountOpening
    $USING EB.Reports
    $USING EB.SystemTables
    $USING ST.CompanyCreation
    $USING AC.API
    $USING EB.API
    $USING AC.CashFlow
    $USING AC.HighVolume
    $USING AC.EntryCreation
    $USING RE.ConBalanceUpdates
    $USING BF.ConBalanceUpdates
    $USING EB.Utility
    $USING AC.AccountStatement
*-----------------------------------------------------------------------------
    GOSUB Initialise ;* Variable initialisation
    IF acIsInstalled THEN
        GOSUB BuildData ;*To process the account
    END ELSE
        EB.SystemTables.setEtext('')
        enqError = "PZ-PRODUCT.AC.NOT.INSTALLED"    ;* EB.ERROR record
        EB.Reports.setEnqError(enqError)            ;* If AC product not installed set error
    END

RETURN
*-----------------------------------------------------------------------------

*** <region name= Initialise>
Initialise:
*** <desc> </desc>
*** Initialise the AC.CHECK.ACCOUNT in parameters
    acRec = ""
    checkData<AC.AccountOpening.AccountBalance> = 'Y'
    checkData<AC.AccountOpening.HisAccount> = 'Y'
    checkData<AC.AccountOpening.AccountIban> = 'Y'
    checkData<AC.AccountOpening.AccountValidity> = 'Y'
    checkData<AC.AccountOpening.AccountArrangement> = 'Y'
    callMode = 'ONLINE'
    overrideCode = ''
    errorCode = ''
    acEntryRec = ''
    checkDataResult = ''
    lastCommittedTransaction = ''
*** Get the Account ID
    LOCATE 'ACCOUNTREFERENCE' IN EB.Reports.getDFields()<1> SETTING acPos THEN    ;* locate ACCOUNTREFERENCE in enquiry data and get position
        accountId = EB.Reports.getDRangeAndValue()<acPos>                           ;* Get the account id using the position
    END
*** Product installaion check
    acIsInstalled = ""
    EB.API.ProductIsInCompany("AC", acIsInstalled)
*** Get the Reference Date
    LOCATE 'DATEREFERENCE' IN EB.Reports.getDFields()<1> SETTING balPos THEN    ;* locate DATEREFERENCE in enquiry data and get position
        dateRef = EB.Reports.getDRangeAndValue()<balPos>
        EB.SystemTables.setComi(dateRef)
        EB.Utility.InTwod("11.1", "D")
        IF EB.SystemTables.getEtext() THEN
            EB.Reports.setEnqError(EB.SystemTables.getEtext())
            RETURN
        END
    END
    today = EB.SystemTables.getToday()
    IF dateRef EQ "" OR dateRef LT today THEN ;*Date should not be less than Today
        dateRef = today
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BuildDate>
BuildData:
*** <desc> </desc>
    IF EB.Reports.getEnqError() THEN
        RETURN
    END
    AC.AccountOpening.CheckAccount(accountId, acRec, checkData, callMode, acEntryRec, checkDataResult, overrideCode, errorCode)       ;* Validate the account
    BEGIN CASE
        CASE checkDataResult<AC.AccountOpening.AccountArrangement,1> AND errorCode<1>
            EB.Reports.setEnqError(errorCode<1>)
            RETURN
        CASE errorCode<2>
            FINDSTR accountId IN errorCode<2> SETTING POS THEN ;*Return error only if the account number is invalid. Inactive/closed accounts should not return error.
                EB.Reports.setEnqError(errorCode<2>)
                RETURN
            END
    END CASE
    iBan = checkDataResult<AC.AccountOpening.AccountIban,1>
    onlineActualBal = checkDataResult<AC.AccountOpening.AccountBalance,1>
    limitAmt = checkDataResult<AC.AccountOpening.AccountBalance,4>
    lockedAmt = checkDataResult<AC.AccountOpening.AccountBalance,3>
    acCcy = acRec<AC.AccountOpening.Account.Currency>

    workingbal = ""
    AC.CashFlow.AccountserviceGetworkingbalance(accountId, workingbal, "") ;*To get the Working balance of the account

    GOSUB GetLastCommittedTxnDets ;* To get the STMT.ENTRY id and DateTime of the last committed transaction

    GOSUB GetClosingBookedBal ;* To process the Output record for ClosingBooked Balance
    GOSUB GetExpectedBal ;* To process the Output record for Expected Balance
    GOSUB GetOpeningBookedBal ;* To process the Output record for OpeningBooked Balance
    GOSUB GetInterimBookedBal ;* To process the Output record for InterimBooked Balance
    GOSUB GetInterimAvlBal ;* To process the Output record for InterimAvailable Balance
    IF dateRef GT today THEN ;* ForwardAvailable balance will be processed only when the Future date is provided in DATEREFERENCE
        GOSUB GetFwdAvlBal ;* To process the Output record for ForwardAvailable Balance
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetClosingBooked>
GetClosingBookedBal:
*** <desc>To process the Output record for ClosingBooked Balance</desc>
    refDate = today
    EB.API.Cdt("", refDate, "-1C") ;*Reference date should be the previous day for Closing booked balance
    previousDay = refDate
    closingBookedBal = ""
    outError = ""
    AC.API.EbGetAcctBalance(accountId, acRec, "BOOKING", previousDay, "", closingBookedBal, "", "", outError) ;*To get the Closing balance for the previous day
    balanceType = "closingBooked"
    stetBalanceType = "closingBooked"
    creditLimitIncluded = ""
    balanceAmount = closingBookedBal
    referenceDate = previousDay
    lastChangeDateTime = ""
    GOSUB BuildEnqDate ;* To form the output array

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetExpectedBal>
GetExpectedBal:
*** <desc>To process the Output record for Expected Balance</desc>
    ebContractBalRec = ""
    recordLock = ""
    yErr = ""
    AC.API.EbReadContractBalances(accountId, ebContractBalRec, yErr, recordLock)
    fwdUnauthCr = ebContractBalRec<BF.ConBalanceUpdates.EbContractBalances.EcbTotUnauthCr>
    fwdUnauthDb = ebContractBalRec<BF.ConBalanceUpdates.EbContractBalances.EcbTotUnauthDb>
    balanceType = "expected"
    stetBalanceType = "expected"
    creditLimitIncluded = ""
    balanceAmount = onlineActualBal+fwdUnauthCr+fwdUnauthDb
    referenceDate = today
    lastChangeDateTime = isoTimeDate
    GOSUB BuildEnqDate ;* To form the output array
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetOpeningBookedBal>
GetOpeningBookedBal:
*** <desc>To process the Output record for OpeningBooked Balance</desc>
    balanceType = "openingBooked"
    stetBalanceType = "openingBooked"
    creditLimitIncluded = ""
    balanceAmount = closingBookedBal
    referenceDate = today
    lastChangeDateTime = ""
    GOSUB BuildEnqDate ;* To form the output array
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetInterimBookedBal>
GetInterimBookedBal:
*** <desc>To process the Output record for InterimBooked Balance</desc>
    balanceType = "interimBooked"
    stetBalanceType = "interimBooked"
    creditLimitIncluded = ""
    balanceAmount = onlineActualBal
    referenceDate = today
    lastChangeDateTime = isoTimeDate
    GOSUB BuildEnqDate ;* To form the output array
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetInterimAvlBal>
GetInterimAvlBal:
*** <desc>To process the Output record for InterimAvailable Balance</desc>
    balanceType = "interimAvailable"
    stetBalanceType = "interimAvailable"
    creditLimitIncluded = ""
    balanceAmount = workingbal-lockedAmt
    referenceDate = today
    lastChangeDateTime = isoTimeDate
    GOSUB BuildEnqDate ;* To form the output array
    stetBalanceType = "interimAvailable with Limit"
    creditLimitIncluded = "true"
    balanceAmount = balanceAmount+limitAmt
    GOSUB BuildEnqDate ;* To form the output array
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GetFwdAvlBal>
GetFwdAvlBal:
*** <desc>To process the Output record for ForwardAvailable Balance</desc>
    ecbRec = ""
    err = ""
    AC.HighVolume.EbReadHvt("EB.CONTRACT.BALANCES", accountId, ecbRec, err)
    LOCATE dateRef IN ecbRec<BF.ConBalanceUpdates.EbContractBalances.EcbAvailableDate,1> BY "AR" SETTING datePos THEN ;*Locate the fwdDate in the ladder present in the ECB
        totUnathMvmt = ecbRec<BF.ConBalanceUpdates.EbContractBalances.EcbAvNauCrMvmt,datePos> + ecbRec<BF.ConBalanceUpdates.EbContractBalances.EcbAvNauDbMvmt,datePos>
        accountBalance =  ecbRec<BF.ConBalanceUpdates.EbContractBalances.EcbAvailableBal,datePos> - totUnathMvmt
    END ELSE ;*update the balance from the closest past date avaialable
        IF datePos-1 EQ 0 THEN
            accountBalance = ""
        END ELSE
            totUnathMvmt = ecbRec<BF.ConBalanceUpdates.EbContractBalances.EcbAvNauCrMvmt,datePos-1> + ecbRec<BF.ConBalanceUpdates.EbContractBalances.EcbAvNauDbMvmt,datePos-1>
            accountBalance =  ecbRec<BF.ConBalanceUpdates.EbContractBalances.EcbAvailableBal,datePos-1> - totUnathMvmt
        END
    END
    balanceType = "forwardAvailable"
    stetBalanceType = "forwardAvailable"
    creditLimitIncluded = ""
    balanceAmount = accountBalance
    referenceDate = dateRef
    lastChangeDateTime = ""
    GOSUB BuildEnqDate ;* To form the output array
    stetBalanceType = "forwardAvailable with Limit"
    creditLimitIncluded = "true"
    IF accountBalance EQ "" ELSE
        balanceAmount = accountBalance+limitAmt
    END
    GOSUB BuildEnqDate ;* To form the output array
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= BuildEnqDate>
BuildEnqDate:
*** <desc>To form the output array</desc>
    accData<-1> = accountId:"*":iBan:"*":lastCommittedTransaction:"*":balanceType:"*":creditLimitIncluded:"*":balanceAmount:"*":referenceDate:"*":lastChangeDateTime:"*":stetBalanceType
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GetLastCommittedTxnDets>
GetLastCommittedTxnDets:
*** <desc>To get the STMT.ENTRY id and DateTime of the last committed transaction </desc>
    acctStmtPrintRec = ""
    err = ""
   
    InDetails<1>='ACCT.STMT.PRINT'
    InDetails<2>=accountId
    InDetails<3>=''
    LockRecord="No"
    RequestMode="MERGE.HVT"
    AddInfo=''
    ReservedIn=''
    AcctStmtRecord=''
    StmtSeqIndicator=''
  
    ReservedOut=''

    AC.AccountStatement.acReadAcctStmtPrint(InDetails,RequestMode,LockRecord,AddlInfo,ReservedIn,AcctStmtRecord,StmtSeqIndicator,err,ReservedOut)
    acctStmtPrintRec= AcctStmtRecord

   
    IF err THEN
        RETURN  ;* Do not proceed, if the account has no transactions.
    END
    acctStmtPrintCnt = DCOUNT(acctStmtPrintRec,@FM)
    stmtCnt = acctStmtPrintCnt

    LOOP ;*When IF.NO.MOVEMENT is set to YES, ACCT.STMT.PRINTED records are generated by STMT.PRINTED records are generated only when transactions are done
    WHILE stmtCnt
        stmtPrintedId = accountId:"-":FIELD(acctStmtPrintRec<stmtCnt>,"/",1) ;*Start with latest ACCT.STMT.PRINTED
        stmtPrintedRec = ""
        err = ""
        Indetails<1>='STMT.PRINTED'
        Indetails<2>=stmtPrintedId
        Indetails<3>=''
        
        AC.AccountStatement.acReadAcctStmtPrint(Indetails, 'MERGE.HVT','NO', '', '', stmtPrintedRec, '',err, '')
        IF stmtPrintedRec THEN
            stmtCnt = 1 ;*End the loop if STMT.PRINTED record is generated. This must be the latest
        END
        stmtCnt = stmtCnt-1 ;*If STMT.PRINTED record is not available, check the next latest ACCT.STMT.PRINTED.
    REPEAT

    IF NOT(stmtPrintedRec) THEN
        RETURN  ;* Do not proceed, if the there is no STMT.PRINTED
    END

    stmtEntryCnt = DCOUNT(stmtPrintedRec,@FM)
    lastCommittedTransaction = stmtPrintedRec<stmtEntryCnt>
    readErr = ""
    stmtRec = AC.EntryCreation.StmtEntry.Read(lastCommittedTransaction,readErr)
    timeDate = stmtRec<AC.EntryCreation.StmtEntry.SteDateTime>
    year = 2000+timeDate[1,2]
    isoTimeDate = year:"-":timeDate[3,2]:"-":timeDate[5,2]:"T":timeDate[7,2]:":":timeDate[9,2]:":00" ;*converting the DateTime to ISO format
    
RETURN
*** </region>

END
