* @ValidationCode : MjotMTk3NzUxNDgzMzpDcDEyNTI6MTU0OTI4MzYxODMxNDprY2hhcnVtYXRoaTo1OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTAxLjIwMTgxMjIzLTAzNTM6MTYxOjEzMw==
* @ValidationInfo : Timestamp         : 04 Feb 2019 18:03:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kcharumathi
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 133/161 (82.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201901.20181223-0353
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-154</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank
SUBROUTINE E.AC.STMT.ENT.PAGE.BUILD(EnqData)
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
* @uses AC.AccountOpening
* @package AC.ModelBank
* @class E.AC.STMT.ENT.BUILD
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
* 29/01/2019 - Enhancement 2933754 / Task 2933757
*              New Build Routine for the enquiry AC.TRANSACTION.LIST
*
*
*** </region>
*
*-----------------------------------------------------------------------------
*** <region name= insertlibrary>
*** <desc>To define the packages being used </desc>

    $USING AC.ModelBank
    $USING EB.SystemTables
    $USING EB.Reports
    $USING AC.AccountOpening
    $USING EB.API
    $USING EB.Template
    $USING EB.Iris
    $USING EB.Utility

*** </region>

*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESS LOGIC>
*** <desc>Main process logic</desc>

    GOSUB initialise ;* Initialise the required variables
    GOSUB process ;* Check whether the mandatory details are provided to proceed further
    
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc> Initialise the required variables </desc>

    processGoHead = 1
    today = EB.SystemTables.getToday()
    AC.ModelBank.setRecentTransactionsFlag(1)
    
    UxpBrowser=''
    EB.Iris.RpGetIsUxpBrowser(UxpBrowser)   ;*Check for UXP request
    IF UxpBrowser THEN
        noOfSelFields = DCOUNT(EnqData<2>,@VM)             ;*Get the total number of selection fields
        FOR field=1 TO noOfSelFields
            IF EnqData<2,field> MATCHES 'BOOKING.DATE':@VM:'VALUE.DATE':@VM:'PROCESSING.DATE' THEN         ;*Check for any date field as criteria
                IF EnqData<3,field> MATCHES 'GE':@VM:'LE' THEN                                             ;*Check for the operators sepcified for range values
                    LOCATE EnqData<2,field> IN secondOccFields<1,1> SETTING firstPos THEN                  ;*Check 2nd occurence of the date fields
                        IF EnqData<2,field> EQ EnqData<2,secondOccFields<2,firstPos>> THEN                ;*In-case of same criteria field mentioned again as selection
                            EnqData<3,secondOccFields<2,firstPos>> = 'RG'                                  ;*Update the operator as Range
                            EnqData<4,secondOccFields<2,firstPos>>:=' ':EnqData<4,field>                  ;*Update the 2nd (or) max limit mentioned as range value
                        END
                    END ELSE
                        secondOccFields<1,-1> = EnqData<2,field>                                          ;*Assign the 2nd occurence date field
                        secondOccFields<2,-1> = field                                                       ;*Assign the 2nd occurence position of date field
                    END
                END
            END
        NEXT field
    END
    
    
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= process>
process:
*** <desc> Check whether the mandatory details are provided to proceed further </desc>

* loop around to determine the values defined in the selection criteria
* and check whether the values provided are valid, if not error is raised
    loopCnt = 1
    maxLoops = 4

    LOOP
    WHILE loopCnt LE maxLoops AND processGoHead DO

        BEGIN CASE

            CASE loopCnt EQ 1
                GOSUB getAccount ;* To get the account from the selection criteria
                GOSUB readAccount ;* To read the account record

            CASE loopCnt EQ 2
                GOSUB getRequiredEntryCount ;* To get the required number of entries from the selection criteria

            CASE loopCnt EQ 3
                GOSUB determineDateRange ; *
                GOSUB getStartDate ;* To get the start date from the selection criteria

            CASE loopCnt EQ 4
                GOSUB getEndDate ;* To get the end date from the selection criteria

        END CASE

        IF EB.Reports.getEnqError() THEN
            processGoHead = 0 ;* if error is set, set the flag to '0' such that further processing is stopped
        END

        loopCnt += 1

    REPEAT

* donot proceed further if any of the validation fails
    IF NOT(processGoHead) THEN
        RETURN
    END

* update the formatted date
    LOCATE type IN EnqData<2,1> SETTING datePos THEN
        EnqData<2,datePos> = type
        EnqData<3,datePos> = "RG"
        EnqData<4,datePos> = dateDetermined
    END ELSE
        EB.Reports.setEnqError("AC-ATLEAST.ONE.DATE.MANDATORY")
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= getAccount>
getAccount:
*** <desc> To get the account from the selection criteria </desc>

    locateField = "ACCT.ID"
    GOSUB getRequiredValue ;* to get the value provided in enquiry selection
    accountNumber = locateValue
    
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= getRequiredValue>
getRequiredValue:
*** <desc> to get the value provided in enquiry selection </desc>

    locateValue = ""
    LOCATE locateField IN EnqData<2,1> SETTING FldFoundPos THEN
        locateValue = EnqData<4,FldFoundPos>
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= getRequiredEntryCount>
getRequiredEntryCount:
*** <desc> To get the required number of entries from the selection criteria </desc>

    locateField = "NO.OF.ENTRIES"
    locateFieldNumeric = 1
    GOSUB getRequiredValue ;* to get the value specific to "NO.OF.ENTRIES" provided in enquiry selection
    
    IF NOT(NUM(locateValue)) THEN
        EB.Reports.setEnqError("AC-NO.OF.ENTRIES.VALUE.NOT.NUMERIC") ;* if the field whose property is numeric does not hold numeric value then error is set
        RETURN
    END
    requiredEntryCount = locateValue

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= getStartDate>
getStartDate:
*** <desc> To get the start date from the selection criteria </desc>

    inStartDate = ""
    inStartDate = FIELD(dateRange, ' ', 1)
    
* if start date is not part of the selection criteria then start date will be
* defaulted to previous calendar day
    IF inStartDate THEN
        EB.SystemTables.setComi(inStartDate)
        GOSUB checkValidDate ; *To check whether the given date is valid
        EB.SystemTables.setComi(saveComi)
    END ELSE
        inStartDate = today
        EB.API.Cdt("",inStartDate,"-01C")
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= getEndDate>
getEndDate:
*** <desc> To get the end date from the selection criteria </desc>

    inEndDate = ""
    inEndDate = FIELD(dateRange, ' ', 2)

* if end date is not part of the selection criteria then end date
* will be defaulted to today

    IF inEndDate THEN
        EB.SystemTables.setComi(inEndDate)
        GOSUB checkValidDate ; *To check whether the given date is valid
        EB.SystemTables.setComi(saveComi)
    END ELSE
        inEndDate = today
    END
    
    dateDetermined = inStartDate:' ':inEndDate

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

    CheckData<AC.AccountOpening.AccountValidity> = 'Y'
    CheckData<AC.AccountOpening.HisAccount> = 'Y'
    CallMode = 'ONLINE'
    
* API called to get the account reference
    AC.AccountOpening.CheckAccount(accountNumber, rAccount, CheckData, CallMode, "", CheckDataResult, "", errAccount)

    IF NOT(rAccount) AND errAccount THEN
        GOSUB raiseAccountError ;* raise error if the account provided is not valid in T24
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= raiseAccountError>
raiseAccountError:
*** <desc> raise error if the account provided is not valid in T24 </desc>

* if the account provided in the selection criteria is not valid in T24
* then error is raised

    EB.Reports.setEnqError("AC-INVALID.AC.NO")
    tmp = EB.Reports.getEnqError()
    tmp<2,1> = accountNumber
    EB.Reports.setEnqError(tmp)

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= determineDateRange>
determineDateRange:
*** <desc> </desc>

    locateField = "BOOKING.DATE"
    GOSUB getRequiredValue ;* to get the value specific to "NO.OF.ENTRIES" provided in enquiry selection
    
    IF locateValue AND NOT(EB.Reports.getEnqError()) THEN
        type = "BOOKING.DATE"
        dateRange = locateValue
        bookingDateRange = 1
    END
    
    locateField = "PROCESSING.DATE"
    GOSUB getRequiredValue ;* to get the value specific to "NO.OF.ENTRIES" provided in enquiry selection
    
    IF locateValue AND NOT(EB.Reports.getEnqError()) THEN
        type = "PROCESSING.DATE"
        dateRange = locateValue
        processingDateRange = 1
    END
    
    IF bookingDateRange AND processingDateRange THEN
        EB.Reports.setEnqError("AC-MORE.THAN.ONE.DATE.SPECIFIED")
        RETURN
    END
    
    locateField = "VALUE.DATE"
    GOSUB getRequiredValue ;* to get the value specific to "NO.OF.ENTRIES" provided in enquiry selection
    
    IF locateValue AND NOT(EB.Reports.getEnqError()) THEN
        type = "VALUE.DATE"
        dateRange = locateValue
        valueDateRange = 1
    END
    
    IF processingDateRange AND valueDateRange THEN
        EB.Reports.setEnqError("AC-MORE.THAN.ONE.DATE.SPECIFIED")
        RETURN
    END
    
    IF bookingDateRange AND valueDateRange THEN
        EB.Reports.setEnqError("AC-MORE.THAN.ONE.DATE.SPECIFIED")
    END

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= checkValidDate>
checkValidDate:
*** <desc>To check whether the given date is valid </desc>

    EB.Utility.InTwod("11","D") ;* Call IN2D routine to check whether the given date is valid
    IF EB.SystemTables.getEtext() THEN
        EB.Reports.setEnqError(EB.SystemTables.getEtext())
    END

RETURN
*** </region>

END



