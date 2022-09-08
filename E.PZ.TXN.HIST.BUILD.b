* @ValidationCode : MjotNjQxNTAwOTA0OkNwMTI1MjoxNTk5NTY4NTk1MjcwOnMuc29taXNldHR5bGFrc2htaToxMTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOS4wOjMwMjoyNzQ=
* @ValidationInfo : Timestamp         : 08 Sep 2020 18:06:35
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : s.somisettylakshmi
* @ValidationInfo : Nb tests success  : 11
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 274/302 (90.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PZ.ModelBank
SUBROUTINE E.PZ.TXN.HIST.BUILD(EnqData)
*-----------------------------------------------------------------------------
*** <region name= description>
*** <desc> Description about the routine</desc>
*
* New build routine introduced to modify the selection criteria, this routine
* is invoked prior to the actual selection.
*-----------------------------------------------------------------------------
*
* @uses EB.SystemTables
* @uses EB.Reports
* @uses EB.Browser
* @uses AC.AccountOpening
* @uses IN.IbanAPI
* @package PZ.ModelBank
* @class E.PZ.TXN.HIST.BUILD
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
* @param EnqData - The actual selection creiteria defined in the enquiry selection
*
* Outgoing Arguments:
*
* @param EnqData - Modified selection criteria
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
*            New build routine is introduced.
*
* 20/10/17 - Enhancement 2140052 / Task 2312405
*            Common variable EndDate is removed
*
* 22/01/19  Enhancement 2741263 / Task 2978712
*            Performance improvement changes
*            Skip Token if passed in the selection criteria is set in the common variable
*
* 09/09/19 - Enhancement 3308494 / Task 3308495
*            TI Changes - Component moved from ST to AC.
*
* 08/04/2020 - Defect 3684044 / Task 3684116
*			   Set common variable ENQ$SKIP.SELECT only when no errors are returned from the build routine
*
*** </region>
*
*-----------------------------------------------------------------------------
*** <region name= insertlibrary>
*** <desc>To define the packages being used </desc>

    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.Browser
    $USING AC.AccountOpening
    $USING IN.IbanAPI
    $USING EB.API
    $USING EB.Template
    $USING PZ.ModelBank
    $USING EB.DataAccess
    $USING AC.EntryCreation
    $USING AC.AccountStatement
     
*** </region>

*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESS LOGIC>
*** <desc>Main process logic</desc>

    GOSUB initialise ;* Initialise the required variables
    GOSUB checkPrelimConditions ;* Check whether the mandatory details are provided to proceed further

    IF processGoHead THEN
        GOSUB process ;* To form the selection criteria based on the input provided
        IF inStartDate EQ '' AND skipToken EQ '' THEN
            EB.Reports.setEnqError("PZ-EITHER.START.DATE.OR.ENTRY.REF.MAND")
            RETURN
        END
        EB.Reports.setEnqSkipSelect(1)
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc> Initialise the required variables </desc>
    
    indicPos = ''
    processGoHead = 1
    today = EB.SystemTables.getToday()
    requiredEntryCount = ""
    inStartDate = ""
    inEndDate = ""
    formattedTimeStamp = ""
    stetPos = ''
    stetIndicator = ''
    stetErrFlag = ''
    GOSUB initialiseLocalVariables ;* Initialising the local variables
    
    FINDSTR "BERLIN" OR "STET" IN EnqData<1> SETTING indicPos THEN
        PZ.ModelBank.setPZ_Indicator(1)
    END

    FINDSTR "STET" IN EnqData<1> SETTING stetPos THEN
        stetIndicator = 1
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= checkPrelimConditions>
checkPrelimConditions:
*** <desc> Check whether the mandatory details are provided to proceed further </desc>

* loop around to determine the values defined in the selection criteria
* and check whether the values provided are valid, if not error is raised
    loopCnt = 1
    maxLoops = 6

    LOOP
    WHILE loopCnt LE maxLoops AND processGoHead DO

        BEGIN CASE

            CASE loopCnt EQ 1
                GOSUB getAccount ;* To get the account from the selection criteria
                GOSUB readAccount ;* To read the account record
                
            CASE loopCnt EQ 2
                GOSUB getSumOrDetail        ;* To get the SUM.OR.DETAIL from the selection criteria

            CASE loopCnt EQ 3
                GOSUB getRequiredEntryCount ;* To get the required number of entries from the selection criteria

            CASE loopCnt EQ 4
                GOSUB getStartDate          ;* To get the start date from the selection criteria

            CASE loopCnt EQ 5
                GOSUB getEndDate  ;* To get the end date from the selection criteria
                GOSUB validateDate          ;* To validate the date range provided and raise error if the date range exceeds 18 months

            CASE loopCnt EQ 6
                GOSUB getTimeStamp ;* To get the Time stamp from the selection criteria

        END CASE

        IF EB.Reports.getEnqError() THEN
            processGoHead = 0 ;* if error is set, set the flag to '0' such that further processing is stopped
        END

        loopCnt += 1

    REPEAT

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= getAccount>
getAccount:
*** <desc> To get the account from the selection criteria </desc>

    locateField = "TXN.HIST.ACCT.ID"
    locateFieldMandatory = 1
    GOSUB getRequiredValue ;* to get the value provided in enquiry selection

    IF NOT(EB.Reports.getEnqError()) THEN
        accountNumber = locateValue
        PZ.ModelBank.setAccountReference(accountNumber)
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= getRequiredValue>
getRequiredValue:
*** <desc> to get the value provided in enquiry selection </desc>

    locateValue = ""
    LOCATE locateField IN EnqData<2,1> SETTING FldFoundPos THEN
        IF EnqData<3,FldFoundPos> EQ "EQ" THEN
            locateValue = EnqData<4,FldFoundPos>
        END ELSE
            EB.Reports.setEnqError("EB-RMB1.OPERAND.MUST.BE.EQ.FOR.":locateField)
        END
    END ELSE
        IF locateFieldMandatory THEN
            EB.Reports.setEnqError("EB-RMB1.":locateField:".MANDATORY") ;* if the required value is not available in the enquiry selection, then set the error variable
        END
    END

    IF EB.Reports.getEnqError() THEN
        RETURN ;* do not proceed further if error is set
    END

    BEGIN CASE

        CASE NOT(locateValue)
            locateValue = locateDefaultValue
               
        CASE locateFieldNumeric
            IF locateValue AND NOT(NUM(locateValue)) THEN
                EB.Reports.setEnqError("EB-RMB1.":locateField:".NOT.NUMERIC") ;* if the field whose property is numeric does not hold numeric value then error is set
            END

    END CASE

    GOSUB initialiseLocalVariables ;* Initialising the local variables

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= getRequiredEntryCount>
getRequiredEntryCount:
*** <desc> To get the required number of entries from the selection criteria </desc>

    locateField = "NO.OF.ENTRIES"
    locateFieldNumeric = 1
    locateDefaultValue = 50
    
    GOSUB getRequiredValue ;* to get the value specific to "NO.OF.ENTRIES" provided in enquiry selection

    IF NOT(EB.Reports.getEnqError()) THEN
        requiredEntryCount = locateValue
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= getStartDate>
getStartDate:
*** <desc> To get the start date from the selection criteria </desc>

    inStartDate = ""
    locateField = "IN.START.DATE"
    GOSUB getRequiredValue ;* to get the value specific to "IN.START.DATE" provided in enquiry selection

    IF NOT(EB.Reports.getEnqError()) THEN
        inStartDate = locateValue
    END

* if start date is not part of the selection criteria then start date will be
* defaulted to previous calendar day
* if start date is not part of the selection criteria then start date will be
* defaulted to previous calendar day
    IF NOT(inStartDate) THEN
;*Set start date to null in case of belin and stet as all entries are to be displayed
        FINDSTR "BERLIN" IN EnqData<1> SETTING berPos THEN ;*Incase of Berlin make start date null
            inStartDate = ''
            RETURN
        END
        IF stetIndicator THEN ;*Incase of STET, default start date
            inStartDate = today
            EB.API.Cdt("",inStartDate,"-78W")
            RETURN
        END
        inStartDate = today ;*In other cases, make start date the previous calendar day
        EB.API.Cdt("",inStartDate,"-01C")
    END ELSE
        IF stetIndicator THEN
            stetErrFlag = 1
        END
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= getEndDate>
getEndDate:
*** <desc> To get the end date from the selection criteria </desc>

    inEndDate = ""
    locateField = "IN.END.DATE"

    GOSUB getRequiredValue ;* to get the value specific to "IN.END.DATE" provided in enquiry selection

    IF NOT(EB.Reports.getEnqError()) THEN
        inEndDate = locateValue
    END


    IF stetIndicator THEN
        IF inEndDate THEN
            stetErrFlag = 1
            EB.API.Cdt("",inEndDate,"-01C")
        END ELSE
            inEndDate = today
            EB.API.Cdt("",inEndDate,"-01C")
        END
    END

    IF NOT(inEndDate) THEN
        inEndDate = today
    END
    
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= readAccount>
readAccount:
*** <desc> To read the account record  </desc>

* to validate the incomming account reference, convert the IBAN reference provided to account number
    acctError = ""
    saveComi = EB.SystemTables.getComi()
    EB.SystemTables.setComi(accountNumber)
    
    EB.Template.In2ant(16.2,'ANT') ;* API called to validate the account reference provided
    
    accountNumber = EB.SystemTables.getComi()
    acctError = EB.SystemTables.getEtext()
    EB.SystemTables.setComi(saveComi) ;* restoring COMI after API call

    IF acctError THEN
        GOSUB raiseAccountError ;* raise error if the account provided is not valid in T24
        RETURN ;* donot proceed further
    END

    rAccount = ""
    errAccount = ""
    rAccount = AC.AccountOpening.Account.Read(accountNumber,errAccount)  ;* Get the account record
    
    IF NOT(rAccount) THEN
        F.ACCOUNT$HIS = ''
        rAccount = ''
        errAccount = ''
        EB.DataAccess.Opf('F.ACCOUNT$HIS',F.ACCOUNT$HIS)
        EB.DataAccess.ReadHistoryRec(F.ACCOUNT$HIS,accountNumber,rAccount, errAccount)
        accountNumber = FIELD(accountNumber ,';' ,1)
    END


    IF NOT(rAccount) AND errAccount THEN
        GOSUB raiseAccountError ;* raise error if the account provided is not valid in T24
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= getTimeStamp>
getTimeStamp:
*** <desc> To get the Time stamp from the selection criteria </desc>

    locateField = "IN.END.TIME"
    GOSUB getRequiredValue ;* to get the value specific to "IN.END.TIME" provided in enquiry selection
    IF NOT(EB.Reports.getEnqError()) THEN
        timeStamp = locateValue
    END

    IF NOT(timeStamp) THEN
        RETURN
    END

* convert UTC time provided to local zone time
    companyCode = EB.SystemTables.getIdCompany()
    CALL EB.GetLocalZone(companyCode,localZone)  ;* Find local zone -  set USE LOCAL ZONE IN SPF and time zone in company

* API called to deterimne the local zone time with the local zone and UTC time provided
    IF localZone THEN
        CALL EB.GetLocalZoneTime(timeStamp,localZone,localZoneTime) ;* get local zone time
        timeStamp = localZoneTime
    END

    date = inEndDate
    formattedTimeStamp = date[3,2]:date[5,2]:date[7,2]:timeStamp[1,2]:timeStamp[4,2]      ;* form time stamp - in T24 server format

    PZ.ModelBank.setTxnEndTime(formattedTimeStamp)
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= process>
process:
    
*** <desc> To form the selection criteria based on the input provided </desc>

    LOCATE "SKIP.TOKEN" IN EnqData<2,1> SETTING skipTokenPos THEN
        IF stetErrFlag = 1 THEN
            EB.Reports.setEnqError("PZ-ONLY.START.DATE.OR.ENTRY.REF.IS.MAND")
            RETURN
        END
        skipToken = EnqData<4,skipTokenPos>
        dateInSkipToken = FIELD(skipToken,'-',2)
        IF dateInSkipToken EQ '' THEN ;* If only entry id is provided
            stmtEntryRec = AC.EntryCreation.StmtEntry.Read(skipToken,entryErr)
            IF entryErr THEN
                EB.Reports.setEnqError("PZ-INVALID.ENTRY.ID")
                RETURN
            END
            processingDate = stmtEntryRec<AC.EntryCreation.StmtEntry.SteProcessingDate> ;*get processing date of the entry

*initialising the parameters to call AC.READ.ACCT.STMT.PRINT to get merged record.
            InDetails<1>='ACCT.STMT.PRINT'
            InDetails<2>=accountNumber
            InDetails<3>=processingDate
            LockRecord="No"
            RequestMode="MERGE"
            AddInfo=''
            ReservedIn=''
            AcctStmtRecord=''
            StmtSeqIndicator=''
            ErrorDetails=''
            ReservedOut=''

            AC.AccountStatement.acReadAcctStmtPrint(InDetails,RequestMode,LockRecord,AddlInfo,ReservedIn,AcctStmtRecord,StmtSeqIndicator,ErrorDetails,ReservedOut)
            acctStmtPrintedRec=AcctStmtRecord
            datesArray = FIELDS(acctStmtPrintedRec,'/',1)
            LOCATE processingDate IN datesArray BY 'AR' SETTING datePos THEN ;*check for nearest date
            END
            actualDate = datesArray<datePos>
            skipToken = actualDate:"-":skipToken ;*assign date to skip token and proceed with similar processing
        END
        PZ.ModelBank.setSkipToken(skipToken)
        DEL EnqData<2,skipTokenPos>
        DEL EnqData<3,skipTokenPos>
        DEL EnqData<4,skipTokenPos>
        
        EnqData<2,-1> = "BOOKING.DATE"
        EnqData<3,-1> = "LE"
        EnqData<4,-1> = today
        
    END ELSE
        PZ.ModelBank.setSkipToken("")
    END

    LOCATE "TXN.HIST.ACCT.ID" IN EnqData<2,1> SETTING acctIdPos THEN
        DEL EnqData<2,acctIdPos>
        DEL EnqData<3,acctIdPos>
        DEL EnqData<4,acctIdPos>
        EnqData<2,-1> = "ACCT.ID"
        EnqData<3,-1> = "EQ"
        EnqData<4,-1> = accountNumber
    END

* selection modified to query BOOKING.DATE field of STMT.ENTRY
    IF inStartDate AND inEndDate THEN
        LOCATE 'IN.START.DATE' IN EnqData<2,1> SETTING strtDatePos THEN
            DEL EnqData<2,strtDatePos>
            DEL EnqData<3,strtDatePos>
            DEL EnqData<4,strtDatePos>
        END
        LOCATE 'IN.END.DATE' IN EnqData<2,1> SETTING endDatePos THEN
            DEL EnqData<2,endDatePos>
            DEL EnqData<3,endDatePos>
            DEL EnqData<4,endDatePos>
        END
        EnqData<2,-1> = "BOOKING.DATE"
        EnqData<3,-1> = "RG"
        EnqData<4,-1> = inStartDate:@SM:inEndDate
    END

    LOCATE "NO.OF.ENTRIES" IN EnqData<2,1> SETTING entryPos THEN
        DEL EnqData<2,entryPos>
        DEL EnqData<3,entryPos>
        DEL EnqData<4,entryPos>
    END

    EnqData<2,-1> = "NO.OF.ENTRIES"
    EnqData<3,-1> = "EQ"
    EnqData<4,-1> = requiredEntryCount
  

    IF formattedTimeStamp THEN
        LOCATE "IN.END.TIME" IN EnqData<2,1> SETTING timeStmpPos THEN
            DEL EnqData<2,timeStmpPos>
            DEL EnqData<3,timeStmpPos>
            DEL EnqData<4,timeStmpPos>
        END

        EnqData<2,-1> = "DATE.TIME"
        EnqData<3,-1> = "LE"
        EnqData<4,-1> = formattedTimeStamp
    END

    LOCATE "SUM.OR.DETAIL" IN EnqData<2,1> SETTING sumDetailPos THEN
        DEL EnqData<2,sumDetailPos>
        DEL EnqData<3,sumDetailPos>
        DEL EnqData<4,sumDetailPos>
    END

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= validateDate>
validateDate:
*** <desc> To validate the date range provided and raise error if the date range exceeds 18 months </desc>

* calculating the difference in months between the dates provided
* ex:
* start date = 20130423, end date = 20150724
* year difference = 2015 - 2013 = 2
* converting year difference to months = 2 * 12 = 24
* month difference = 07 - 04 = 3
* total months = 24 + 3 = 27
*
* start date = 20130824, end date = 20150223
* year difference = 2015 - 2013 = 2
* converting year difference to months = 2 * 12 = 24
* month difference = 02 - 08 = -6
* total months = 24 - 6 = 18
*

;* error raised for berlin and stet enquiries if both start date and entry reference is not provided
    IF inStartDate THEN
    
        yearDifference = inEndDate[1,4] - inStartDate[1,4]
        yearInMonths = yearDifference * 12

        monthDifference = inEndDate[5,2] - inStartDate[5,2]
        months = monthDifference

        totalMonths = months + yearInMonths

* error raised if the difference in months of the two given dates exceeds 18
        IF totalMonths GT 18 THEN
            EB.Reports.setEnqError("PZ-INVALID.DATE.RANGE")
        END
    END
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= getSumOrDetail>
getSumOrDetail:
*** <desc> To get the SUM.OR.DETAIL from the selection criteria </desc>

    sumDetail = ""
    locateField = "SUM.OR.DETAIL"
    locateDefaultValue = "S"
    GOSUB getRequiredValue ;* to get the value provided in enquiry selection

    IF NOT(EB.Reports.getEnqError()) THEN
        sumDetail = locateValue
    END

    PZ.ModelBank.setSummaryOption(sumDetail)
 
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= initialiseLocalVariables>
initialiseLocalVariables:
*** <desc> Initialising the local variables </desc>

* these variables are used within a loop.
    locateDefaultValue = ""
    locateFieldMandatory = ""
    locateFieldNumeric = ""

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= raiseAccountError>
raiseAccountError:
*** <desc> raise error if the account provided is not valid in T24 </desc>

* if the account provided in the selection criteria is not valid in T24
* then error is raised

    EB.Reports.setEnqError("PZ-INVALID.AC.NO")
    tmp = EB.Reports.getEnqError()
    tmp<2,1> = accountNumber
    EB.Reports.setEnqError(tmp)

RETURN
*** </region>

END

