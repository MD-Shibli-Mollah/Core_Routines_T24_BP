* @ValidationCode : MjotMTMxNzU1MTI1OkNwMTI1MjoxNTc4NTY0NDE5OTE0Om1oaW5kdW1hdGh5OjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDEuMjAxOTEyMjQtMTkzNToyNzoyNw==
* @ValidationInfo : Timestamp         : 09 Jan 2020 15:36:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mhindumathy
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 27/27 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191224-1935
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PW.ModelBank
SUBROUTINE E.MB.PW.VIEW.GET.USER
*-----------------------------------------------------------------------------
*
* This is a build routine attached to the enquiry PW.VIEW.ACTIVITY.DURATION.
* Returns the user who is responsible for the activity.
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 17/12/2019 - Enhancement 3396943 / Task 3483737
*              Integration of BSG created screen to L1 PW
*
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING EB.SystemTables
    $USING ST.Config
    $USING ST.CustomerService
    $USING EB.Security
    $USING PW.Foundation
    
    GOSUB INITIALISE
    GOSUB PROCESS
    
RETURN
*-----------------------------------------------------------------------------

INITIALISE:

    pwActivityTxnId = EB.Reports.getOData() ;* get the value from enquiry
    nameDesc = "" ;* Initialise the value
RETURN

*-----------------------------------------------------------------------------
PROCESS:
    
    pwActivityTxnRec = PW.Foundation.ActivityTxn.CacheRead(pwActivityTxnId, Error) ;* read the PW.ACTIVITY.TXN record
    pwActivityTxnUser = pwActivityTxnRec<PW.Foundation.ActivityTxn.ActTxnUser,1> ;* get the first user
    
    BEGIN CASE
        
        CASE INDEX(pwActivityTxnUser,"*",1) ;* for external user
            custId = FIELD(pwActivityTxnUser,"*",2,1) ;* get the externalCustomer Id
            perfLang = EB.SystemTables.getLngg()
            ST.CustomerService.getNameAddress(custId,perfLang,customerNameAddress) ;* get the Name Address in preferred Language
            nameDesc = customerNameAddress<ST.CustomerService.NameAddress.name1> ;* get the customer name
        
        CASE pwActivityTxnUser EQ "OFS" ;* for Auto activity set the name as "Automated"
            nameDesc = "Automated"
            
        CASE NUM(pwActivityTxnUser) ;* if the user is a Dept Acct Officer
            daoRec = ST.Config.DeptAcctOfficer.CacheRead(pwActivityTxnUser, DaoErr) ;* read the DAO record
            nameDesc = daoRec<ST.Config.DeptAcctOfficer.EbDaoName> ;* get the DaoName
            
        CASE 1 ;* if user
            UserRec = EB.Security.User.CacheRead(pwActivityTxnUser, UserErr) ;* read the user
            IF UserErr EQ "" THEN ;* Valid user
                nameDesc = pwActivityTxnUser ;* assign the username as the output
            END
        
    END CASE
    
    EB.Reports.setOData(nameDesc) ;* set the output data
    
RETURN
*-----------------------------------------------------------------------------

END
