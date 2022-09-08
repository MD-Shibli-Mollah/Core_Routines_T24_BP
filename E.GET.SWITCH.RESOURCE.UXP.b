* @ValidationCode : Mjo1MzQ1MTIxNjU6Q3AxMjUyOjE2MTExMjAzMjAwMjU6cmFrZXNodjoyNDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMi4yMDIxMDExMy0wNjM4OjMyMDozMDU=
* @ValidationInfo : Timestamp         : 20 Jan 2021 10:55:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rakeshv
* @ValidationInfo : Nb tests success  : 24
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 305/320 (95.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202102.20210113-0638
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE EB.ModelBank

SUBROUTINE E.GET.SWITCH.RESOURCE.UXP(requestData, resultantResourceNameOut)
*-----------------------------------------------------------------------------
* Given a T24 resource / resources (Version, Enquiry, Menu, Cos or Tab), This routine handles
* Abbreviation, candidate assesment, switching and DS variants.
*
* 1. If context is VERSION_FIELD_DROPDOWN or VERSION_CONTRACT_SCREEN_DROPDOWN or ENQUIRY_SELECTION_FIELD_DROPDOWN then resolve the enquiry first.
* 2. Check for layering and get the switch resource.
* 3. Check for DS variant
* 4. If a DS variant is found or an enquiry is resolved then check for switch and then DS variant recursively until no switch is found
*-----------------------------------------------------------------------------
* Modification History :
* 04/02/2019    Enhancement 2687491 / Task 2963069  : UXPB Migration to IRIS R18 - move SwitchFactory and DS variants to T24 to make it tenant aware
* 07/11/2019    Defect      3321403 / Task 3412832  : Make sure AAA,AA abbreviation works.
* 25/11/2019    Defect      3431709 / Task 3442012  : To provide command line support for Dynamic percent enquiries
* 31/12/2019    Defect      3504137 / Task 3514361  : CUSTOMER E is leading to error page.
* 20/01/2021    Defect      4169538 / Task 4187912  : .LIST enquiry removed from the version dropdown to work in accordance with old browser.
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.Versions
    
    GOSUB init
    
    numberOfGivenResources = DCOUNT(resourceNames, " ")
    isInvalidResource = @FALSE
    
    FOR resourceCount = 1 TO numberOfGivenResources
        resourceName = FIELD(resourceNames, " ", resourceCount)
        
        IF isVersionFieldOrContractScreenOrEnqDropdown THEN
            IF numberOfGivenResources > 1 THEN
                ebError = 'Do not support multiple resource resolution for context: ': context
                EB.Reports.setEnqError(ebError)
                RETURN
            END
            
            resourceType = 'E'
        END ELSE
            resourceType = FIELD(resourceTypes, " ", resourceCount)
            
            IF resourceType NE '' THEN
                resourceTypeLast = resourceType
            END ELSE IF resourceTypeLast NE '' THEN
                resourceType = resourceTypeLast
            END
        END
        
        GOSUB explodeResourceTypeAndCheckIfExists

        IF resourceType EQ 'APP' THEN
            IF isCommandLineContext THEN
                IF isInvalidResource THEN
                    ebError = 'Invalid application: ' : resourceName
                    EB.Reports.setEnqError(ebError)
                END ELSE
                    GOSUB buildResponse
                END
            END ELSE
                ebError = 'Do not support application resource - supported resource types are COS, MENU, ENQUIRY, TAB and VERSION'
                EB.Reports.setEnqError(ebError)
            END
            
            RETURN
        END
        
* check if the resource to resolve actually exists - if not then throw error
        IF isInvalidResource THEN
            ebError = 'Could not resolve ' : LOWCASE(resourceType) : ' resource: ' : resourceName
            EB.Reports.setEnqError(ebError)
            RETURN
        END
* For VersionFieldOrContractScreenDropdown enquiry first resolve the enquiry and then process switching
        IF NOT(isVersionFieldOrContractScreenOrEnqDropdown) THEN
            GOSUB processSwitching
        END
        
* DS variant or dynamic resource resolving  is not applicable for version
        IF resourceType <> 'VERSION' THEN
            GOSUB resolveEnquiryResourceOrCheckForDsVariant
        END
        
        GOSUB buildResponse
    NEXT resourceCount
    
RETURN

*** <region name= checkAbbreviationAndReValidate>
*** <desc> </desc>
checkAbbreviationAndReValidate:
	IF recordReadError AND doAbbreviationCheck THEN
	    GOSUB checkAbbreviation
        IF isAnyAbbreviationFound THEN
            recordReadError = ''
            GOSUB explodeResourceTypeAndCheckIfExists ;* revalidate as FT might have resolved to FUNDS.TRANSFER
        END
    END
RETURN
*** </region>

*** <region name= checkAbbreviation>
*** <desc> </desc>
checkAbbreviation:
    abbreviationReadError = ''
    doAbbreviationCheck = @FALSE
    
    IF INDEX(resourceName, '%', 1) EQ 1 THEN
        beginsWithPercent = @TRUE
        resourceName = FIELD(resourceName, '%', 2)
    END
    
    IF INDEX(resourceName, '$NAU', 1) THEN
        isUnauthEnquiry = @TRUE
        resourceName = FIELD(resourceName, '$NAU', 1)
        fileSuffix = '$NAU'
    END ELSE IF INDEX(resourceName, '$HIS', 1) THEN
        isUnauthEnquiry = @TRUE
        resourceName = FIELD(resourceName, '$HIS', 1)
        fileSuffix = '$HIS'
    END ELSE IF INDEX(resourceName, ',', 1) THEN
        isResourceNameWithComma = @TRUE ;* eg. FT,AC
        suffixAfterComma = FIELD(resourceName, ',', 2) ;* eg. AC
        resourceName = FIELD(resourceName, ',', 1) ;* eg. FT
    END
    
    R.Abbreviation = EB.SystemTables.Abbreviation.CacheRead(resourceName, abbreviationReadError)
    IF R.Abbreviation THEN
        isAnyAbbreviationFound = @TRUE
        originalText = R.Abbreviation<EB.SystemTables.Abbreviation.AbbOriginalText>
* In command line context we default the resource type to V - now check the actual resource type if any for eg. in EXCEPTION -> out ENQ EXCEPTION
        IF resourceType EQ 'V' AND INDEX(originalText, " ", 1) THEN
            iSuffix = ''
            abbreviationOriginalTextPrefix = FIELD(originalText, " ", 1)
            
            BEGIN CASE
                CASE abbreviationOriginalTextPrefix EQ 'COS'
                    resourceType = 'C'
                    resourceName = FIELD(originalText, " ", 2)
                    iSuffix = INDEX(originalText, " ", 2)
                    recursivelyCheckForAbbreviation = @FALSE
                CASE abbreviationOriginalTextPrefix EQ 'ENQ'
                    resourceType = 'E'
                    resourceName = FIELD(originalText, " ", 2)
                    iSuffix = INDEX(originalText, " ", 2)
                    recursivelyCheckForAbbreviation = @FALSE
                CASE abbreviationOriginalTextPrefix EQ 'MENU'
                    resourceType = 'M'
                    resourceName = FIELD(originalText, " ", 2)
                    iSuffix = INDEX(originalText, " ", 2)
                    recursivelyCheckForAbbreviation = @FALSE
                CASE abbreviationOriginalTextPrefix EQ 'TAB'
                    resourceType = 'T'
                    resourceName = FIELD(originalText, " ", 2)
                    iSuffix = INDEX(originalText, " ", 2)
                    recursivelyCheckForAbbreviation = @FALSE
                CASE 1
                    resourceType = 'V'
                    resourceName = abbreviationOriginalTextPrefix
                    abbreviationOriginalTextPrefix = ''
                    iSuffix = INDEX(originalText, " ", 1)
            END CASE
            
	        IF iSuffix AND abbreviationOriginalTextSuffix EQ '' THEN
	            abbreviationOriginalTextSuffix = originalText[iSuffix, LEN(originalText)]
	        END
        END ELSE
	        IF resourceType EQ '' THEN
	            resourceType = 'V'  ;* default to version
	        END
            resourceName = originalText
            recursivelyCheckForAbbreviation = @FALSE    ;* don't check for abbreviation if we dont have any space seperated words
        END
    END ELSE
        recursivelyCheckForAbbreviation = @FALSE
        IF resourceType EQ '' THEN
            resourceType = 'V'  ;* default to version
        END
    END
    
    IF recursivelyCheckForAbbreviation THEN
* we have to check for abbreviaton recursively max 2 times as required by old browser specs
* For e.g. if FIND=VC L 2 EQ
*             VC=VAULT.CONTROL
* So final result should be VAULT.CONTROL L 2 EQ
        recursivelyCheckForAbbreviation = @FALSE
        GOSUB checkAbbreviation
    END
    
    IF beginsWithPercent THEN
        resourceName = '%' : resourceName
    END
    
    IF isUnauthEnquiry THEN
        resourceName := fileSuffix
    END ELSE IF isResourceNameWithComma THEN
        IF resourceName[1] <> ',' THEN ;* if the resourceName doesnot end with comma then add comma
            resourceName := ','
        END
        
        resourceName := suffixAfterComma
    END
    
RETURN
*** </region>

*** <region name= explodeResourceTypeAndCheckIfExists>
explodeResourceTypeAndCheckIfExists:
*** <desc> </desc>
    resolvedResourceType = ''
* Do early conditional test for abbreviation if necessary (as its more likely to be abbreviation at the length of below 6- see IN2PV routine).
    IF doAbbreviationCheck AND LEN(resourceName) < 6 THEN
        GOSUB checkAbbreviation
    END
    
    BEGIN CASE
        CASE resourceType EQ 'E'
* enquiry resolver might have been called for dropdown context - in that case we dont need to validate the enquiry
* as it could be dynamic enquiry. Also, we don't need to check abbreviation for dropdown enquiries.So, doAbbreviationCheck will be true
* only for command line context
            resolvedResourceType = 'ENQUIRY'
            IF doAbbreviationCheck THEN
                EB.Reports.Enquiry.CacheRead(resourceName, recordReadError)
                GOSUB checkAbbreviationAndReValidate
                IF  recordReadError AND (isVersionFieldOrContractScreenOrEnqDropdown OR beginsWithPercent) THEN
                    recordReadError = '' ;* continue even in case of error as it might be dynamic percentage enquiry e.g. %FUNDS.TRANSFER
                    IF (beginsWithPercent AND isResourceNameWithComma) THEN
                        resourceName =  FIELD(resourceName, ',', 1)      ;* Fetching the applicationName part alone
                    END
                END
            END
        CASE resourceType EQ 'V'
            IF INDEX(resourceName, ',', 1) THEN
                resolvedResourceType = 'VERSION'
                EB.Versions.Version.CacheRead(resourceName, recordReadError)
                GOSUB checkAbbreviationAndReValidate
            END ELSE
                resolvedResourceType = 'APP'
                EB.SystemTables.PgmFile.CacheRead(resourceName, recordReadError)
                GOSUB checkAbbreviationAndReValidate
            END
        CASE resourceType EQ 'C'
            resolvedResourceType = 'COS'
            EB.SystemTables.CompositeScreen.CacheRead(resourceName, recordReadError)
            GOSUB checkAbbreviationAndReValidate
        CASE resourceType EQ 'M'
            resolvedResourceType = 'MENU'
            EB.SystemTables.HelptextMenu.CacheRead(resourceName, recordReadError)
            IF recordReadError <> '' THEN
                mainMenuRecordReadError = ''
                EB.SystemTables.HelptextMainmenu.CacheRead(resourceName, mainMenuRecordReadError)
                IF mainMenuRecordReadError EQ '' THEN
                    recordReadError = ''
                END
            END
            GOSUB checkAbbreviationAndReValidate
        CASE resourceType EQ 'T'
            resolvedResourceType = 'TAB'
            EB.SystemTables.TabbedScreen.CacheRead(resourceName, recordReadError)
            GOSUB checkAbbreviationAndReValidate
        CASE 1
            isInvalidResource = @TRUE
            RETURN
    END CASE
    
    IF recordReadError <> '' THEN
        isInvalidResource = @TRUE
    END
    
    resourceType = resolvedResourceType
RETURN
*** </region>
    
*** <region name= init>
init:
*** <desc> </desc>
*R='CUSTOMER.INFO CUSTOMER,INPUT' T='E V' C=VFD
    resourceName = ''
    resourceNames = ''
    resourceType = ''
    resourceTypes = ''
    resourceTypeLast = ''
    context = ''
    candidates = ''
    resultantResourceNameOut = ''
    isCommandLineContext = @FALSE
    isVersionFieldOrContractScreenOrEnqDropdown = @FALSE
    numFields = DCOUNT(requestData, @SM)
    abbreviationOriginalTextPrefix = ''
    abbreviationOriginalTextSuffix = ''
    recursivelyCheckForAbbreviation = @TRUE
    beginsWithPercent = @FALSE
    isUnauthEnquiry = @FALSE
    isResourceNameWithComma = @FALSE    ;* eg. FT,AC
    suffixAfterComma = ''
    fileSuffix = ''
    doAbbreviationCheck = @FALSE
    isAnyAbbreviationFound = @FALSE
    recordReadError = ''
    
    FOR fieldCnt = 1 TO numFields
        fieldAndData = FIELD(requestData, @SM, fieldCnt)
        field = FIELD(fieldAndData, '=', 1)
        value = FIELD(fieldAndData, '=', 2)
        
        BEGIN CASE
            CASE field EQ 'R'
                resourceNames = TRIM(value, "'", 'B') ;*Remove leading and trailing quote characters
            CASE field EQ 'T'
                resourceTypes = TRIM(value, "'", 'B')
            CASE field EQ 'C'
                context = value
                
                IF context = 'VFD' OR context = 'VCSD' OR context = 'ESFD' THEN
                    isVersionFieldOrContractScreenOrEnqDropdown = @TRUE
                END ELSE IF context EQ 'CMD' THEN
                    isCommandLineContext = @TRUE
                    doAbbreviationCheck = @TRUE
                END
                
            CASE 1
                RETURN
        END CASE
    NEXT fieldCnt
RETURN

*** </region>

*** <region name= process>
processSwitching:
*** <desc> </desc>
    IF isUnauthEnquiry THEN ;* It's not possible to have switch for enquiries with $NAU or $HIS suffix as 'INVALID FORMAT' error occurs
        RETURN
    END
    
    R.Layering = ''
    
* Set R.Layering so that Layering routine checks the associated versions if any
    IF resourceType EQ 'VERSION' THEN
        R.Layering = EB.Versions.Version.CacheRead(resourceName, '')
    END

    LOOP
        savedT24ResourceName = resourceName
        EB.SystemTables.Layering(resourceType, resourceName, R.Layering)  ;*switch resource name is set to resourceName
    WHILE (resourceType EQ 'ENQUIRY' AND savedT24ResourceName <> resourceName) REPEAT
    
RETURN
*** </region>

*** <region name= resolveEnquiryResourceOrCheckForDsVariant>
resolveEnquiryResourceOrCheckForDsVariant:
*** <desc> </desc>
    checkSwitch = @FALSE
    enquiryResolveError = ''
    
    IF isVersionFieldOrContractScreenOrEnqDropdown THEN
        candidateCount = 0
        isVersionFieldOrContractScreenOrEnqDropdown = @FALSE ;* because next time we want to check for DS variants only (if any as this is recursive)

		IF context = 'VFD' OR context = 'ESFD' THEN
            candidates<-1> = resourceName : '-LIST'  ;*<domainName>-LIST
            candidates<-1> = '%' : resourceName      ;*%<domainName>
	    END ELSE IF context = 'VCSD' THEN
            IF INDEX(resourceName, ',', 1) THEN  ;* if contract screen is a version
                application = FIELD(resourceName, ',', 1)
                candidates<-1> = resourceName : '-LIST'  ;*<domainName>,<versionName>-LIST
                candidates<-1> = application : '-LIST'   ;*<domainName>-LIST
                candidates<-1> = '%' : resourceName      ;*%<domainName>,<versionName>
                candidates<-1> = '%' : application       ;*%<domainName>
            END ELSE
                candidates<-1> = resourceName : '-LIST'  ;*<domainName>-LIST
                candidates<-1> = '%' : resourceName      ;*%<domainName>
            END
	    END
        
        originalResourceName = resourceName
        candidateCount = DCOUNT(candidates, @FM);
        
        FOR candidate = 1 TO candidateCount
            resourceName = candidates<candidate>
            enquiryResolveError = ''
            EB.Reports.Enquiry.CacheRead(resourceName, enquiryResolveError)
            
            IF enquiryResolveError = '' THEN
                checkSwitch = @TRUE
                BREAK
            END
        NEXT candidate
* Dynamic percentage enquiry has to be formed as %appName even if supplied resource name is %appName,versionName
* due to SMS related issue with RP as mentioned in defect 3273793
        IF enquiryResolveError <> '' THEN
            resourceName = '%' : FIELD(originalResourceName, ',', 1) ;*default enquiry (enqList...) is represented as % enquiry
        END
    END ELSE
        dsVariantReadError = ''
        dsVariantResourceName = resourceName : '.DS'
        EB.Reports.Enquiry.CacheRead(dsVariantResourceName, dsVariantReadError)
        
        IF dsVariantReadError = '' THEN
            resourceName = dsVariantResourceName
            checkSwitch = @TRUE
        END
    END

    IF checkSwitch THEN
        resourceNameSave = resourceName
        
        GOSUB processSwitching
        
        IF resourceNameSave <> resourceName THEN
            GOSUB resolveEnquiryResourceOrCheckForDsVariant
        END
    END
RETURN
*** </region>

*** <region name= buildResponse>
buildResponse:
*** <desc> </desc>
    IF resourceType EQ 'VERSION' THEN
        IF R.Layering<EB.Versions.Version.VerAssocVersion> <> '' THEN
* include associated versions in the response else set to -1 indicating no associated versions
	        CONVERT @VM TO ' ' IN R.Layering<EB.Versions.Version.VerAssocVersion>
	        resultantResourceNameOut<-1> = resourceName : abbreviationOriginalTextSuffix
	        resultantResourceNameOut<-1> = R.Layering<EB.Versions.Version.VerAssocVersion>
        END ELSE
            resultantResourceNameOut<-1> = resourceName : abbreviationOriginalTextSuffix
            resultantResourceNameOut<-1> = '-1'
        END
    END ELSE
        IF abbreviationOriginalTextPrefix THEN
            resourceName = abbreviationOriginalTextPrefix : " " : resourceName
        END
        resultantResourceNameOut<-1> = resourceName : abbreviationOriginalTextSuffix
    END
*** </region>
RETURN

END

