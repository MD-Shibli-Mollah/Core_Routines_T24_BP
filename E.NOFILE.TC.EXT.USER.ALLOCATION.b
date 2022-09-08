* @ValidationCode : MjoxNjExNTUwMTU1OkNwMTI1MjoxNTYwMTU4MTgyMzgwOmRtYXRlaToyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA3LjIwMTkwNTMxLTAzMTQ6MTc2OjEyOQ==
* @ValidationInfo : Timestamp         : 10 Jun 2019 12:16:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dmatei
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 129/176 (73.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AO.Framework
SUBROUTINE E.NOFILE.TC.EXT.USER.ALLOCATION(OUT.ARRAY)
*-----------------------------------------------------------------------------
* This nofile routine is build to extract information from AA.ARRANGEMENT.EXTUSER, EB.EXTERNAL.USER
* AA.ARRANGEMENT and AA.TC.LICENSING tables.
* Main routine used in TCUA front end solution to fetch the list of EEU attached with an arrangement.
*-----------------------------------------------------------------------------
* Modification History :
*
* 14-Aug-18 - En 2600393 /Task 2722321
*             TCUA as business component
*
* 26-Sep-18 - Defect 2783561 / Task 2784472
*             Differentiate between whenlicensing property is enabled and NoOfRoles set it 0 and licensing property not enabled.
*
* 12/02/2019 - Enhancement 2875458 / Task 3025805 - Migration to IRIS R18
*
* 22/05/2019 - Defect 3143229 / Task 3143364
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING EB.Channels
    $USING AO.Framework
    $USING AA.ProductFramework
    $USING AA.Framework
    $USING EB.ARC
*-----------------------------------------------------------------------------
    GOSUB initialise ;* Initialise
    IF recAaArrangementExtuser NE "" THEN
        GOSUB process ;* Main Process
    END
*
RETURN
*------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables</desc>
initialise:
* Local variable initialisation
    OUT.ARRAY = ""
    fieldName = EB.Reports.getEnqSelection()<2> ;* Selection field name
    selectionData = EB.Reports.getEnqSelection()<4> ;* Filter data
            
    subArrangementId = ""
    masterArrangementId = ""
    masterOnly = ""
    countOnly = ""
    recAaArrangementExtuser = ""
            
    LOCATE "ArrangementId" IN fieldName<1,1> SETTING masterPos THEN
        masterArrangementId = selectionData<1, masterPos>
    END

    LOCATE "SubArrangementId" IN fieldName<1,1> SETTING subPos THEN
        subArrangementId = selectionData<1, subPos>
    END
    
    LOCATE "MasterOnly" IN fieldName<1,1> SETTING subPos THEN
        masterOnly = selectionData<1, subPos>
    END
    
    LOCATE "CountOnly" IN fieldName<1,1> SETTING subPos THEN
        countOnly = selectionData<1, subPos>
    END
    
    recAaArrangementExtuser = EB.Channels.AaArrangementExtuser.Read(masterArrangementId, errArrExtuser) ;* Read the table
*
RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name= process>
*** <desc>the main process</desc>
process:
* Main process
    GOSUB licenseCount ;* Fetch license information from AA.TC.LICENSING
    
    totalmExtUserIds = ""
    totalsExtUserIds = ""
    cntOfTotalmUsers = 0
    cntOfTotalsUsers = 0
    totalmExtUserIds = recAaArrangementExtuser<EB.Channels.AaArrangementExtuser.AaeExtUserId>
            
    CONVERT @FM TO @VM IN totalmExtUserIds
    cntOfTotalmUsers = DCOUNT(totalmExtUserIds, @VM) ;* Total number of users created for the arrangement

    totalsExtUserIds = recAaArrangementExtuser<EB.Channels.AaArrangementExtuser.AaeSubExtUserId>
    CONVERT @SM TO @VM IN totalsExtUserIds
    cntOfTotalsUsers = DCOUNT(totalsExtUserIds, @VM) ;* Total number of users created for the arrangement
    cntOfTotalUsers = cntOfTotalmUsers + cntOfTotalsUsers
    aError = ""
    cntRoles = 0
    roleIds = ""
    aaArragementRec = AA.Framework.Arrangement.Read(masterArrangementId, aError)                ;* get the roles list
    roleIds = aaArragementRec<AA.Framework.Arrangement.ArrSubArrangement>    ;* get the sub arrangement

    cntRoles = DCOUNT(roleIds, @VM) ;* Number of roles created
* Case to differentiate by selection criteria
    BEGIN CASE
        CASE subArrangementId EQ "" AND masterOnly EQ "" AND countOnly EQ ""
            GOSUB masterLevel ;* Prepare the output array for master level information
            GOSUB addMasterLevelCount ;* Prepare the output array for count
            GOSUB subLevel ;* Prepare the out array for the role
        CASE subArrangementId EQ "" AND masterOnly NE "" AND countOnly EQ ""
            GOSUB allMasterLevelUser ;* Count the users created for master
            GOSUB masterLevel ;* Prepare the output array for master level information
            GOSUB addMasterLevelCount ;* Prepare the output array for count
        CASE subArrangementId EQ "" AND masterOnly EQ "" AND countOnly NE ""
            OUT.ARRAY<1> =   '' : "*" : '' : "*" : '' : "*" : ''  : "*" : '' : "*" : '' : "*" : ''
            GOSUB addMasterLevelCount ;* Prepare the output array for count
        CASE subArrangementId EQ "" AND masterOnly NE "" AND countOnly NE ""
            GOSUB allMasterLevelUser ;* Count the users created for master
            OUT.ARRAY<1> =   '' : "*" : '' : "*" : '' : "*" : ''  : "*" : '' : "*" : '' : "*" : ''
            GOSUB addMasterLevelCount ;* Prepare the output array for coun
        CASE subArrangementId NE "" AND masterOnly NE "" AND countOnly NE ""
            OUT.ARRAY<1> =  '' : "*" : '' : "*" : '' : "*" : ''  : "*" : '' : "*" : '' : "*" : ''
            GOSUB withSubArrangementUser ;* Prepare the output array for count
        CASE subArrangementId NE ""
            GOSUB withSubArrangementUser ;* Prepare the out array for the role
    END CASE
*
RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name= licenseCount>
*** <desc>count the nomber of licensing from the licensing condition</desc>
licenseCount:
* Fetch license information from AA.TC.LICENSING

    aaProperyClassId = 'TC.LICENSING' ;* PROPERTY CLASS
    licensingRec=''
    licensingErr = ''
* get information from masterArrangement using GetArrangementConditions
    AA.Framework.GetArrangementConditions(masterArrangementId, aaProperyClassId, '', '', '', licensingRec, licensingErr)      ;* Get arrangement condition Property class
    licensingRec = RAISE(licensingRec)
    IF licensingErr EQ '' AND licensingRec NE '' THEN
        userLicense = licensingRec<AO.Framework.TcLicensing.AaTcLicenNoOfUsers> ;* Users
        roleLicense = licensingRec<AO.Framework.TcLicensing.AaTcLicenNoOfRoles> ;* Roles
    END ELSE
* set to zero value. So that in the front end solution we can differentiate the use of roles
        userLicense = "0"
        roleLicense = "0"
    END
*
RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name= allMasterLevelUser>
*** <desc>count the users created for master</desc>
allMasterLevelUser:
* Count the users created for master
    extUserIds = ""
    cntOfUsers = ""
    extUserIds = recAaArrangementExtuser<EB.Channels.AaArrangementExtuser.AaeExtUserId>
    cntOfUsers = DCOUNT(extUserIds, @VM)
*
RETURN
*** </region>
*-------------------------------------------------------------------------------
*** <region name= masterLevel>
*** <desc>output array for master</desc>
masterLevel:
* Prepare the output array for master level information
    extUserIds = ""
    extUserIds = recAaArrangementExtuser<EB.Channels.AaArrangementExtuser.AaeExtUserId>
    masExtPos = 1
    IF extUserIds EQ "" THEN
        OUT.ARRAY<1> =  '' : "*" : '' :"*": '' : "*" : masterArrangementId  : "*" : '' : "*" : '' : "*" : ''
    END ELSE
* Loop through the each external user id
   
        LOOP
            REMOVE masterEeuId FROM extUserIds SETTING mEeuPos
        WHILE masterEeuId:mEeuPos
            catEeuStatus = recAaArrangementExtuser<EB.Channels.AaArrangementExtuser.AaeExtUserStatus, masExtPos>
            externalUserId = masterEeuId
            eeuStatus = ''
            GOSUB readExternalUserId ;* Read EB.EXTERNAL.USER to fetch Customer name
            OUT.ARRAY<-1> =  masterEeuId : "*" : customerId: "*" : welcomeName : "*" : masterArrangementId : "*" : subArrangementId : "*" : "" : "*" : catEeuStatus :"-": eeuStatus
            masExtPos = masExtPos + 1
        REPEAT
    END
*
RETURN
*** </region>
*-------------------------------------------------------------------------------
*** <region name= addMasterLevelCount>
*** <desc>output array for count</desc>
addMasterLevelCount:
* Prepare the output array for count
    IF masterOnly EQ "" THEN
* Total number of users created only under the master
        OUT.ARRAY<1> := "*" :cntOfTotalUsers : "*" : cntOfTotalUsers : "*" : userLicense : "*" : cntRoles : "*" : roleLicense
    END ELSE
* The users created only under the master
        OUT.ARRAY<1> := "*" :cntOfUsers : "*" : cntOfTotalUsers : "*" : userLicense : "*" : cntRoles : "*" : roleLicense
    END
*
RETURN
*** </region>
*-------------------------------------------------------------------------------
*** <region name= withSubArrangementUser>
*** <desc>output array for role</desc>
withSubArrangementUser:
* Prepare the out array for the role
    cntOfSubUsers = ""
    subArrangementIds = recAaArrangementExtuser<EB.Channels.AaArrangementExtuser.AaeSubArrangementId>
    
    FIND subArrangementId IN subArrangementIds SETTING FMpos,VMpos THEN
        subExtUserIds = recAaArrangementExtuser<EB.Channels.AaArrangementExtuser.AaeSubExtUserId,VMpos>
        cntOfSubUsers = DCOUNT(subExtUserIds, @SM)
        IF countOnly EQ "" THEN
            subArrPos = VMpos
            GOSUB subLevelRoleUpdate ;* Prepare the out array for the role
        END ELSE
            OUT.ARRAY<1> := "*" : '' : "*" : '' : "*" : ''  : "*" : '' : "*" : ''
        END
        OUT.ARRAY<1> := "*" :cntOfSubUsers : "*" : cntOfTotalUsers : "*" : userLicense : "*" : cntRoles : "*" : roleLicense
    END ELSE
        OUT.ARRAY = ""
    END
*
RETURN
*** </region>
*-------------------------------------------------------------------------------
*** <region name= subLevel>
*** <desc>get all the external users for roles</desc>
subLevel:
* Loop through the each external user id at sub arrangement level
    subArrangementIds = recAaArrangementExtuser<EB.Channels.AaArrangementExtuser.AaeSubArrangementId>
    subArrangementId = ""
    subArrPos = 1
    LOOP
        REMOVE subArrangementId FROM subArrangementIds SETTING VMpos
    WHILE subArrangementId:VMpos
        subExtUserIds = recAaArrangementExtuser<EB.Channels.AaArrangementExtuser.AaeSubExtUserId,subArrPos>
        GOSUB subLevelRoleUpdate ;* Prepare the out array for the role
        subArrPos = subArrPos + 1
    REPEAT
*
RETURN
*** </region>
*-------------------------------------------------------------------------------
*** <region name= subLevelRoleUpdate>
*** <desc>out array for the role</desc>
subLevelRoleUpdate:
* Prepare the out array for the role
    subExtUserId = ""
    subExtPos = 1
    CHANGE @SM TO @VM IN subExtUserIds
      
    LOOP
        REMOVE subExtUserId FROM subExtUserIds SETTING sArrPos
    WHILE subExtUserId:sArrPos
        catEeuStatus = recAaArrangementExtuser<EB.Channels.AaArrangementExtuser.AaeSubExtUserStatus, subArrPos, subExtPos>
        arragementRec = AA.Framework.Arrangement.Read(subArrangementId, aError)                ;* get the role
        roleDescription = arragementRec<AA.Framework.Arrangement.ArrRemarks>    ;* get the role decription
        externalUserId = subExtUserId
        eeuStatus = ''
        GOSUB readExternalUserId ;* Read EB.EXTERNAL.USER to fetch Customer name
        OUT.ARRAY<-1> =  subExtUserId : "*" : customerId: "*" :welcomeName : "*" : masterArrangementId : "*" : subArrangementId : "*" : roleDescription : "*" : catEeuStatus :"-": eeuStatus
        subExtPos = subExtPos + 1
    REPEAT
*
RETURN
*** </region>
*-------------------------------------------------------------------------------
*** <region name= readExternalUserId>
*** <desc>get customer name from eb.external.user</desc>
readExternalUserId:
* Read EB.EXTERNAL.USER to fetch Customer name

    recExternalUser = ""

    IF catEeuStatus EQ "AUTH" OR catEeuStatus EQ "AUTHCHG" THEN
        recExternalUser = EB.ARC.ExternalUser.Read(externalUserId, "") ;* Read EB.EXTERNAL.USER table
    END ELSE
        recExternalUser = EB.ARC.ExternalUser.ReadNau(externalUserId, "") ;* Read EB.EXTERNAL.USER$NAU table
    END

    welcomeName = recExternalUser<EB.ARC.ExternalUser.XuName> ;* Get the welcome name
    customerId = recExternalUser<EB.ARC.ExternalUser.XuCustomer> ;* Get the customerId
    IF subArrangementId EQ "" THEN ;* If sub arrangement id is empty then it's for the master
        arrangementId = masterArrangementId
        arrangementIds = recExternalUser<EB.ARC.ExternalUser.XuArrangement>
    END ELSE
        arrangementId = subArrangementId
        arrangementIds = recExternalUser<EB.ARC.ExternalUser.XuSubArrangement>
    END
    FIND arrangementId IN arrangementIds SETTING FMp,VMp THEN
        IF eeuStatus EQ '' THEN
            eeuStatus = recExternalUser<EB.ARC.ExternalUser.XuStatus,VMp> ;* EB.EXTERNAL.USER status for a specific channel
        END ELSE
            eeuStatus = eeuStatus : "-" : recExternalUser<EB.ARC.ExternalUser.XuStatus,VMp> ;* EB.EXTERNAL.USER status for a specific channel
        END
    END
*
RETURN
*** </region>
*-------------------------------------------------------------------------------
END
