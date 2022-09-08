* @ValidationCode : Mjo4MDI2NDI0MjI6Q3AxMjUyOjE1NzE3Mzc3Nzc1Mzk6c3VkaGFyYW1lc2g6NTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkxMC4yMDE5MDkyMC0wNzA3OjE0MjoxMzM=
* @ValidationInfo : Timestamp         : 22 Oct 2019 15:19:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 133/142 (93.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AO.Framework
SUBROUTINE AA.TC.LICENSING.VALIDATE
*-----------------------------------------------------------------------------
*
* Description:
* Validation routine for the property class TC.LICENSING
*-----------------------------------------------------------------------------
* Modification History
*
* 23/07/18 -  Enhancement 2669405 / Task 2669408 - Introducing new property TC.LICENSING
*
*  21/10/19 - Enhancement : 2851854
*             Task : 3396231
*             Code changes has been done as a part of AA to AF Code segregation
*-----------------------------------------------------------------------------

    $USING AO.Framework
    $USING AA.Framework
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING EB.OverrideProcessing
    $USING EB.Channels
    $USING AF.Framework

*-----------------------------------------------------------------------------
    GOSUB Initialise ;* Initialise the required variables
    GOSUB ProcessCrossVal
       
RETURN
*-----------------------------------------------------------------------------
*** Initialise local variables and file variables
Initialise:
    
    masterArrId = ''

RETURN
*-----------------------------------------------------------------------------
ProcessCrossVal:
    IF EB.SystemTables.getMessage() EQ '' THEN     ;* Only during commit...
        TEMP.V.FUN = EB.SystemTables.getVFunction()
        BEGIN CASE
            CASE TEMP.V.FUN EQ 'D'
            CASE TEMP.V.FUN EQ 'R'
            CASE 1      ;* The real crossval...
                GOSUB RealCrossVal
        END CASE
    END

RETURN
*-----------------------------------------------------------------------------
RealCrossVal:
* Real cross validation goes here....
    TEMP.PROD.ARR = AF.Framework.getProductArr()
    TEMP.AA.PROD = AA.Framework.Product
    TEMP.AA.ARR = AA.Framework.AaArrangement

    BEGIN CASE
        CASE TEMP.PROD.ARR EQ TEMP.AA.PROD   ;* If its from the designer level
            GOSUB DesignerDefaults           ;* Ideally no defaults at the product level
        CASE TEMP.PROD.ARR EQ TEMP.AA.ARR    ;* If its from the arrangement level
            GOSUB ArrangementDefaults        ;* Arrangement defaults
    END CASE

    GOSUB CommonCrossVal

    BEGIN CASE
        CASE AF.Framework.getProductArr() EQ AA.Framework.Product
            GOSUB DesignerCrossVal          ;* Designer specific cross validations
        CASE AF.Framework.getProductArr() EQ AA.Framework.AaArrangement
            GOSUB ArrangementCrossVal       ;* Arrangement specific cross validations
    END CASE

RETURN

*-----------------------------------------------------------------------------
DesignerDefaults:

RETURN

*-----------------------------------------------------------------------------
ArrangementDefaults:

RETURN
*-----------------------------------------------------------------------------

CommonCrossVal:
    

RETURN
*-----------------------------------------------------------------------------
CheckArrInputMissing:
*
* get the data for the arrangement using RNew
    GOSUB GetArrangementData
* get the arrangement ID
    arrangementId = AA.Framework.getArrId()
    arrangementRecord = AA.Framework.Arrangement.Read(arrangementId, errMsg)
    subArrListMas = arrangementRecord<AA.Framework.Arrangement.ArrSubArrangement>
* get the masterArrangement ID
    masterArrId = arrangementRecord<AA.Framework.Arrangement.ArrMasterArrangement>
    arrangementRecordMas = AA.Framework.Arrangement.Read(masterArrId, errMsg)    
    subArrList = arrangementRecordMas<AA.Framework.Arrangement.ArrSubArrangement>
    IF masterArrId EQ '' THEN
        GOSUB CheckInputMissing
    END
        
    
    RETURN
*-----------------------------------------------------------------------------
DesignerCrossVal:
*
RETURN
*-----------------------------------------------------------------------------
ArrangementCrossVal:
    GOSUB CheckArrInputMissing
    IF masterArrId NE '' THEN
        GOSUB ValidateLincenses
    END ELSE
        GOSUB ValidateAgainstProduct
    END
RETURN
*-----------------------------------------------------------------------------
CheckInputMissing:

* check if the input for the no of users is empty
    IF arrLicenNoOfUsers<1> EQ '' THEN
        EB.SystemTables.setAs("")
        EB.SystemTables.setAv("")
        EB.SystemTables.setAf(AO.Framework.TcLicensing.AaTcLicenNoOfUsers)
        EB.SystemTables.setEtext("EB-INPUT.MISSING")
        EB.ErrorProcessing.StoreEndError()
    END
* check if the input for the no of users is empty
    IF arrLicenNoOfRoles<1> EQ '' THEN
        EB.SystemTables.setAs("")
        EB.SystemTables.setAv("")
        EB.SystemTables.setAf(AO.Framework.TcLicensing.AaTcLicenNoOfRoles)
        EB.SystemTables.setEtext("EB-INPUT.MISSING")
        EB.ErrorProcessing.StoreEndError()
    END
RETURN
*-----------------------------------------------------------------------------
GetArrangementData:
* get information from arrangement using RNew
    arrLicenNoOfUsers = ''
    arrLicenNoOfRoles = ''

    arrLicenNoOfUsers = EB.SystemTables.getRNew(AO.Framework.TcLicensing.AaTcLicenNoOfUsers)
    arrLicenNoOfRoles = EB.SystemTables.getRNew(AO.Framework.TcLicensing.AaTcLicenNoOfRoles)


RETURN
*-----------------------------------------------------------------------------
GetMasterArrangementData:
* get information from masterarrangement using GetArrangementConditions
    maArrLicenNoOfUsers = ''
    maArrLicenNoOfRoles = ''

    propertyIds = ''
    propertyRecords = ''
    retErr = ''
    aaProperyClassId = "TC.LICENSING"
    AA.Framework.GetArrangementConditions(masterArrId, aaProperyClassId, '', '', propertyIds, propertyRecords, retErr)      ;* Get arrangement condition for TC Availability Property class
    IF retErr = '' AND propertyRecords NE '' THEN
        maArrLicenNoOfUsers = RAISE(propertyRecords<1,AO.Framework.TcLicensing.AaTcLicenNoOfUsers>)
        maArrLicenNoOfRoles = RAISE(propertyRecords<1,AO.Framework.TcLicensing.AaTcLicenNoOfRoles>)
    END
RETURN
*-----------------------------------------------------------------------------
ValidateLincenses:
* get the data for the arrangement using RNew
    GOSUB GetArrangementData
*get the data from the masterArr
    GOSUB GetMasterArrangementData
* read the activity history for the arrangement
    IF subArrList NE '' THEN
	    noOfRoles = ''
        noOfRoles = DCOUNT(subArrList,@VM)
* validations
	    IF noOfRoles GT maArrLicenNoOfRoles  THEN
	        EB.SystemTables.setAf(AO.Framework.TcLicensing.AaTcLicenNoOfRoles)
	        EB.SystemTables.setEtext('AO-ROLES.LIMIT.BREACHED':@FM:maArrLicenNoOfRoles)    ;*Throw error
	        EB.ErrorProcessing.StoreEndError()
	    END
    END
RETURN
*-----------------------------------------------------------------------------
ValidateAgainstProduct:
* get the data for the arrangement using RNew
    GOSUB GetArrangementData
* validate against SPF for the total no of users
    IF NOT((EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfExtAiUsers> EQ '' AND EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfExtApUsers> EQ '') AND  EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfLicenseCode>[6,4] EQ 'TMNS') THEN
	    errSpf = ''
	    recordSpf = ''
	    recordSpf = EB.SystemTables.Spf.Read("SYSTEM", errSpf)
	    noOfUsersSpf = recordSpf<EB.SystemTables.Spf.SpfExtAiUsers> + recordSpf<EB.SystemTables.Spf.SpfExtApUsers>
	    IF arrLicenNoOfUsers GT noOfUsersSpf THEN
	        EB.SystemTables.setAs('')
	        EB.SystemTables.setAv('')
	        EB.SystemTables.setAf(AO.Framework.TcLicensing.AaTcLicenNoOfUsers)
	        EB.SystemTables.setText('AO-NO.OF.USERS.EXCEED.SPF':@FM:noOfUsersSpf)
	        EB.OverrideProcessing.StoreOverride('')
	    END
    END
* read the activity history for the arrangement
    IF subArrListMas NE '' THEN
        noOfRoles = ''
        noOfRoles = DCOUNT(subArrListMas,@VM)
* validations
        IF noOfRoles GT arrLicenNoOfRoles  THEN
            EB.SystemTables.setAf(AO.Framework.TcLicensing.AaTcLicenNoOfRoles)
            EB.SystemTables.setEtext('AO-NOT.VALID.LICENSE':@FM:noOfRoles)    ;*Throw error
            EB.ErrorProcessing.StoreEndError()
        END
    END
  * get the number of the users from AA.ARRANGEMENT.EXTUSER for the current arrangement    
    arrangementExtuserRecord = ''
    ebExtUserIDList = ''
    ebExtUserIDSubList = ''
    noOfUsers = ''

    arrangementExtuserRecord = EB.Channels.AaArrangementExtuser.Read(arrangementId, errMsg)  
    IF arrangementExtuserRecord NE '' THEN
        ebExtUserIDList = arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeExtUserId>
        IF ebExtUserIDList NE '' THEN
              noOfUsers = COUNT(ebExtUserIDList,@VM) + 1       
        END        
        ebExtUserIDSubList = arrangementExtuserRecord<EB.Channels.AaArrangementExtuser.AaeSubExtUserId>
        IF ebExtUserIDSubList NE '' THEN 
            noOfUsers = noOfUsers + COUNT(ebExtUserIDSubList,@VM) + 1
        END 
    END
  * do the validation  for the no of user licenses
    IF noOfUsers GT arrLicenNoOfUsers THEN
        EB.SystemTables.setAf(AO.Framework.TcLicensing.AaTcLicenNoOfUsers)
        EB.SystemTables.setEtext('AO-NOT.VALID.LICENSE':@FM:noOfUsers)    ;*Throw error
        EB.ErrorProcessing.StoreEndError()        
    END
RETURN
*-----------------------------------------------------------------------------
END
