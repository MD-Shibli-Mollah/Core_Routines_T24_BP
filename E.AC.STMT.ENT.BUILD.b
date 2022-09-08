* @ValidationCode : MjoxNjkyMTc0MzA0OkNwMTI1MjoxNTQ3MDg5MDU3NjE1OnJkaGVwaWtoYToyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxODEyLjE6NDY6NDM=
* @ValidationInfo : Timestamp         : 10 Jan 2019 08:27:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdhepikha
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 43/46 (93.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-236</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank
SUBROUTINE E.AC.STMT.ENT.BUILD(EnqData)
*-----------------------------------------------------------------------------
*** <region name= description>
*** <desc> Description about the routine</desc>
*
* New build routine introduced to modify the selection criteria, this routine
* is invoked prior to the actual selection.
*-----------------------------------------------------------------------------
*
* @uses EB.SystemTables
* @uses EB.Reports, EB.Template
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
* 11/12/2018 - Enhancement 2898141 / Task 2898160
*              New build routine to verify and modify the selection criteria
*
*** </region>
*
*-----------------------------------------------------------------------------
*** <region name= insertlibrary>
*** <desc>To define the packages being used </desc>

    $USING EB.SystemTables
    $USING EB.Reports
    $USING AC.AccountOpening
    $USING EB.Template
    $USING AC.ModelBank
    
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

    AC.ModelBank.setRecentTransactionsFlag(1)
    noOfEntries = ""
    accountNumber = ""
    
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= process>
process:
*** <desc> Check whether the mandatory details are provided to proceed further </desc>

    GOSUB getAccount ;* To get the account from the selection criteria
    GOSUB readAccount ;* To read the account record
    
    IF NOT(noOfEntries) THEN
        EnqData<2,-1> = "NO.OF.ENTRIES"
        EnqData<3,-1> = "EQ"
        EnqData<4,-1> = 10
    END
    
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= getAccount>
getAccount:
*** <desc> To get the account from the selection criteria </desc>
    
    LOCATE "ACCT.ID" IN EnqData<2,1> SETTING acctPos THEN
        accountNumber = EnqData<4,acctPos>
    END
    
    LOCATE "NO.OF.ENTRIES" IN EnqData<2,1> SETTING noOfEntPos THEN
        noOfEntries = EnqData<4,noOfEntPos>
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

END



