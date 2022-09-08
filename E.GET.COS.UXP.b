* @ValidationCode : MjoxMzE0NzE2NzkyOkNwMTI1MjoxNTczNTMzNjU4NzM3OmdvdmluZGFwYW5kZXk6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTEwLjIwMTkwOTIwLTA3MDc6LTE6LTE=
* @ValidationInfo : Timestamp         : 12 Nov 2019 10:10:58
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : govindapandey
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE EB.ModelBank

SUBROUTINE E.GET.COS.UXP(cosId, cosResponseJson)
    $USING EB.API
    $USING EB.Utility
    $USING EB.SystemTables
    $USING EB.Template
    $USING EB.Reports
*-----------------------------------------------------------------------------
* Routine to return dynamic COS json for top level cos including its child coses
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
* 17/06/2019    Enhancement 2687491 / Task 3028524  : UXPB Migration to IRIS R18 - NO.FILE for COS
* 27/06/2019    Enhancement 2687491 / Task 3028524  : Support DS variants for enquiry and avoid any possibility of infinite recursion
* 07/11/2019    Defect      3321403 / Task 3412832  : Default menus are not getting loaded.
*-----------------------------------------------------------------------------
    GOSUB init
    GOSUB process
    GOSUB finalise
RETURN
*** <region name= init>
*** <desc> </desc>
init:
    childCosIdList = ''
    childCosNumber = 0
    trimmedFieldName = ''
    cosResponseJson = '['
    appName = 'T24.UXPB.COS'
    
    EB.API.GetFieldDefinitions(appName, 'LOAD') ;*load the field definition
    isChildCos = @FALSE
    
    minimalFieldNames = EB.ModelBank.getCUxpbCosMinimalFieldNames()
    mvSvGroupNames = EB.ModelBank.getCUxpbCosMvSvGroupNames()
    svGroupNamesWithSingleDisplayableAssociatedField = EB.ModelBank.getCUxpbCosSvGroupNamesWithSingleDisplayableAssociatedField()
    
    ssRecord = ''
    EB.API.GetStandardSelectionDets(appName, ssRecord)   ;* read SS record
    
    logicallyOrderedFieldNumbers = ssRecord<EB.SystemTables.StandardSelection.SslLogicalOrder>   ;* get logical
    physicallyOrderedFieldNumbers = ssRecord<EB.SystemTables.StandardSelection.SslPhysicalOrder>   ;* get physical
    CONVERT " " TO @FM IN logicallyOrderedFieldNumbers   ;* convert space to Field marker
    CONVERT " " TO @FM IN physicallyOrderedFieldNumbers  ;* convert space to field marker
    
    IF NOT(minimalFieldNames) OR NOT(mvSvGroupNames) OR NOT(svGroupNamesWithSingleDisplayableAssociatedField) THEN
        GOSUB setMinimalFieldNames
        GOSUB setMvSvGroupNames
    END
RETURN
*** </region>

*** <region name= process>
*** <desc> </desc>
process:
    Error = ''
    R.CosRecord = ''
    cosIdBeforeSwitch = cosId
    
    IF NOT(isChildCos) THEN
        IF INDEX(cosId, 'Tabbed', 1) THEN
            cosId = cosId[1,INDEX(cosId, 'Tabbed', 1) - 1]
            EB.SystemTables.Layering('TAB', cosId, '')  ;*switch tab name is set to cosId
            cosId := 'Tabbed'
        END ELSE
            EB.SystemTables.Layering('COS', cosId, '')  ;*switch cos name is set to cosId
        END
    END

    R.CosRecord = EB.Utility.T24UxpbCos.CacheRead(cosId, Error)
    
    types = ''
    
    IF Error EQ '' THEN
        IF isChildCos THEN
            cosResponseJson := ','
        END
        
        cosResponseJson := '{"t24Name":"':cosId:'"'
        
        totalFields = DCOUNT(R.CosRecord, @FM)
        FOR fieldNumber = 1 TO totalFields
            physicalFieldNumber = logicallyOrderedFieldNumbers<fieldNumber>
            value = R.CosRecord<physicalFieldNumber>
            types = EB.SystemTables.getT(fieldNumber)
            
            LOCATE 'NOINPUT' IN types SETTING pos THEN
                CONTINUE    ;* ignore audit and other NOINPUT fields
            END
            
            fieldName = EB.SystemTables.getF(fieldNumber)

            IF fieldName[3,1] EQ "<" THEN
                GOSUB handleMvFields
                CONTINUE
            END

            IF value <> '' THEN
                cosResponseJson := ","
                IF minimalFieldNames<fieldNumber> <> '' THEN
                    cosResponseJson := '"':minimalFieldNames<fieldNumber>:'"' : ":" : '"':value:'"'
	            END ELSE
	                GOSUB getTrimmedFieldName
                    cosResponseJson := '"':trimmedFieldName:'"' : ":" : '"':value:'"'
	            END
            END
        NEXT fieldNumber
        
        cosResponseJson := '}' ;* end this cos group
    END ELSE
        ebError = 'Couldnot read T24.UXPB.COS - '
        
        IF NOT(isChildCos) THEN
            IF cosId <> cosIdBeforeSwitch THEN  ;* if there is a switch defined using EB.SWITCH.PARAMETER table
                ebError := 'Switched '
            END
        END ELSE
            ebError := 'child '
        END
        
        ebError := 'id: ' : cosId : ' : ' : Error
        
        EB.Reports.setEnqError(ebError)
        RETURN
    END
    
    IF childCosIdList NE '' THEN
        isChildCos = @TRUE
        
        LOOP
            childCosNumber++
        WHILE childCosIdList<childCosNumber>
            cosId = childCosIdList<childCosNumber>
            GOSUB process
        REPEAT
    END
RETURN
*** </region>
*** <region name= handleMvFields>
*** <desc> </desc>
handleMvFields:
    mvJson = ''
    numMv = DCOUNT(value,@VM)
    currentFieldNumber = fieldNumber
    anyDisplayableMvGroupFound = @FALSE
    
    mvJson := '"' : mvSvGroupNames<fieldNumber> : '":['    ;* initialize the group
    
    FOR mv = 1 TO numMv
* temporarily store mv group in a seperate variable so that we can discard this group if none fields were having value
        tempMvJson = '{'
        numDisplayableMvFields = 0  ;* variable to track how many fields were displayable
        currentFieldNumber = fieldNumber
        contentType = ''
        
        LOOP
            fieldName = EB.SystemTables.getF(currentFieldNumber)
            
            physicalFieldNumber = logicallyOrderedFieldNumbers<currentFieldNumber>
            value = R.CosRecord<physicalFieldNumber,mv>
            
            IF fieldName[6,1] EQ "<" OR fieldName[6,1] EQ "." THEN ;* If its associated sub value or a sub value
                IF svGroupNamesWithSingleDisplayableAssociatedField<currentFieldNumber> <> '' THEN
                    GOSUB handleSvFieldsWithSingleAssociatedField
                END ELSE
                    GOSUB handleSvFields
                END
                CONTINUE
            END
            
            IF value EQ '' THEN
                IF fieldName[3,1] <> ">" THEN   ;* if its not end of mv group then continue else break as we are done with it
                    currentFieldNumber++
                    CONTINUE
                END ELSE
                    BREAK
                END
            END
            
            IF numDisplayableMvFields <> 0 THEN
                tempMvJson := ','
            END
            
            IF minimalFieldNames<currentFieldNumber> <> '' THEN
                trimmedFieldName = minimalFieldNames<currentFieldNumber>
                
                IF trimmedFieldName EQ 'params' THEN
                    value = CHANGE(value, EB.ModelBank.DoubleQuotes, EB.ModelBank.SingleQuote)
                END ELSE IF trimmedFieldName EQ 'contentType' THEN
                    contentType = value
                END ELSE IF trimmedFieldName EQ 'resource'THEN
                    BEGIN CASE
                        CASE contentType = 'COS'
                            IF INDEX(value, 'Tabbed', 1) THEN
                                value = value[1,INDEX(value, 'Tabbed', 1) - 1]
                                EB.SystemTables.Layering('TAB', value, '')  ;*switch tab name is set to value
                                value := 'Tabbed'
                            END ELSE
                                EB.SystemTables.Layering('COS', value, '')  ;*check for switch - value is set to switched value if present
                            END
                            IF cosId <> value THEN
	                            LOCATE value IN childCosIdList SETTING CHILD.COS.FOUND ELSE
	                                childCosIdList<-1> = value
	                            END
                            END
                        CASE contentType = 'ENQ'
                            dsVariantReadError = ''
					        dsVariantResourceName = value : '.DS'
					        EB.Reports.Enquiry.CacheRead(dsVariantResourceName, dsVariantReadError)
                            
					        IF dsVariantReadError EQ '' THEN
					            value = dsVariantResourceName
					        END
                            
                            EB.SystemTables.Layering('ENQUIRY', value, '')  ;*check for switch - value is set to switched value if present
                        CASE contentType = 'SCREEN'
                            EB.SystemTables.Layering('VERSION', value, '')  ;*check for switch - value is set to switched value if present
                    END CASE
                END
                
                tempMvJson := '"':trimmedFieldName:'"' : ":" : '"':value:'"'
            END ELSE
                GOSUB getTrimmedFieldName
                tempMvJson := '"':trimmedFieldName:'"' : ":" : '"':value:'"'
            END
            
            numDisplayableMvFields++
        WHILE fieldName[3,1] <> ">"
            currentFieldNumber++
        REPEAT
        
        tempMvJson := '}'    ;* close the temp mv group
        
        IF numDisplayableMvFields > 0 THEN
            IF mv <> 1 AND anyDisplayableMvGroupFound THEN
                mvJson := ','
            END
            
            mvJson := tempMvJson
            anyDisplayableMvGroupFound = @TRUE
        END
    NEXT mv
    
    mvJson := ']'
    
    IF anyDisplayableMvGroupFound THEN
        cosResponseJson := ","
        cosResponseJson := mvJson
    END
    
    fieldNumber = currentFieldNumber
RETURN
*** </region>
*** <region name= handleSvFields>
*** <desc> </desc>
handleSvFields:
    anyDisplayableSvValueFound = @FALSE
    currentSvFieldNumber = currentFieldNumber
    
    svJson = '"': mvSvGroupNames<currentFieldNumber> : '":['
    
    numSv = DCOUNT(value, @SM)
    
    FOR sv = 1 TO numSv
        tempSvJson = '{'
        numDisplayableSvFields = 0
        currentSvFieldNumber = currentFieldNumber
        
        LOOP
            fieldName = EB.SystemTables.getF(currentSvFieldNumber)
            
            physicalFieldNumber = logicallyOrderedFieldNumbers<currentSvFieldNumber>
            value = R.CosRecord<physicalFieldNumber,mv,sv>
            
            IF value EQ '' THEN
                IF fieldName[6,1] <> ">" THEN
                    currentSvFieldNumber++
                    CONTINUE
                END ELSE
                    BREAK
                END
            END
            
            IF numDisplayableSvFields <> 0 THEN
                tempSvJson := ','
            END
            
            IF minimalFieldNames<currentSvFieldNumber> <> '' THEN
                trimmedFieldName = minimalFieldNames<currentSvFieldNumber>  ;* should assign trimmedFieldName here inorder to identify childCos later
            END ELSE
                GOSUB getTrimmedFieldName
            END
            
            tempSvJson := '"':trimmedFieldName:'"' : ":" : '"' : value : '"'
            numDisplayableSvFields++
            
        WHILE fieldName[6,1] <> ">"
            currentSvFieldNumber++
        REPEAT
        
        tempSvJson := '}'
        
        IF numDisplayableSvFields > 0 THEN
            IF anyDisplayableSvValueFound THEN
                svJson := ','
            END
            
            svJson := tempSvJson
            anyDisplayableSvValueFound = @TRUE
        END
    NEXT sv
    
    svJson := ']'
    
    IF anyDisplayableSvValueFound THEN
        IF numDisplayableMvFields <> 0 THEN
            tempMvJson := ','
        END
        
        tempMvJson := svJson
        numDisplayableMvFields++
        anyDisplayableMvGroupFound = @TRUE
    END
    
    currentFieldNumber = currentSvFieldNumber + 1
RETURN
*** </region>
*** <region name= handleSvFieldsWithSingleAssociatedField:>
*** <desc> </desc>
handleSvFieldsWithSingleAssociatedField:
    anyDisplayableSvValueFound = @FALSE
    currentSvFieldNumber = currentFieldNumber
    svJson = '"': svGroupNamesWithSingleDisplayableAssociatedField<currentFieldNumber> : '":['
    numSv = DCOUNT(value, @SM)
    
    FOR sv = 1 TO numSv
        currentSvFieldNumber = currentFieldNumber
        
        LOOP
            fieldName = EB.SystemTables.getF(currentSvFieldNumber)
            
            physicalFieldNumber = logicallyOrderedFieldNumbers<currentSvFieldNumber>
            value = R.CosRecord<physicalFieldNumber,mv,sv>
            
            IF (fieldName[6,1] EQ "<" OR fieldName[6,1] EQ ".") AND value <> '' THEN
	            
                IF anyDisplayableSvValueFound THEN
                    svJson := ','
                END
        
                svJson := '"' : value : '"'
                anyDisplayableSvValueFound = @TRUE
            END
        WHILE fieldName[6,1] <> ">" AND fieldName[6,1] <> "."
            currentSvFieldNumber++
        REPEAT
    NEXT sv
    
    svJson := ']'
    
    IF anyDisplayableSvValueFound THEN
        IF numDisplayableMvFields <> 0 THEN
            tempMvJson := ','
        END
        
        tempMvJson := svJson
        numDisplayableMvFields++
        anyDisplayableMvGroupFound = @TRUE
    END
    
    currentFieldNumber = currentSvFieldNumber + 1 ;* set to next field number
RETURN
*** </region>
*** <region name= getTrimmedFieldName>
*** <desc> </desc>
getTrimmedFieldName:
    trimmedFieldName = fieldName
    charAfterFirstXX = fieldName[3,1]
    charAfterSecondXX = fieldName[6,1]
    
    BEGIN CASE
        CASE charAfterFirstXX EQ '<' OR charAfterSecondXX EQ '<'
            trimmedFieldName = fieldName['<',2,1]   ;* get rid of 'XX< or XX-XX<'
        CASE charAfterFirstXX EQ '>' OR charAfterSecondXX EQ '>'
            trimmedFieldName = fieldName['>',2,1]   ;* get rid of 'XX> or XX-XX>'
        CASE charAfterFirstXX EQ '-'
            IF charAfterSecondXX EQ '-' THEN
                trimmedFieldName = fieldName['-',3,1]    ;* get rid of 'XX-XX-'
            END ELSE
                trimmedFieldName = fieldName['-',2,1]    ;* get rid of 'XX-'
            END
    END CASE
    
    GOSUB convertToCamelCase
RETURN
*** </region>
*** <region name= convertToCamelCase>
*** <desc> </desc>
convertToCamelCase:
    words = CONVERT('.',@FM,trimmedFieldName)
    numWords = DCOUNT(words, @FM)
    trimmedFieldName = OCONV(words<1>, "MCL")
    
    FOR i = 2 TO numWords
        trimmedFieldName := OCONV(OCONV(words<i>,"MCL"),"MCT")
    NEXT i
RETURN
*** </region>
*** <region name= setMinimalFieldNames>
*** <desc> </desc>
setMinimalFieldNames:
    minimalFieldNames = ''
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosTitleLanguage>
    minimalFieldNames<logicalFieldNumber> =  't24LanguageId'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosTitleText>
    minimalFieldNames<logicalFieldNumber> = 'text'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosInvokableType>
    minimalFieldNames<logicalFieldNumber> = 'type'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosInvokableParamName>
    minimalFieldNames<logicalFieldNumber> = 'name'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosInvokableParamValue>
    minimalFieldNames<logicalFieldNumber> = 'value'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosPanelName>
    minimalFieldNames<logicalFieldNumber> = 'name'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosPanelType>
    minimalFieldNames<logicalFieldNumber> = 'type'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosPanelPattern>
    minimalFieldNames<logicalFieldNumber> = 'pattern'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosPanelParent>
    minimalFieldNames<logicalFieldNumber> = 'parentPanel'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosPanelTitleText>
    minimalFieldNames<logicalFieldNumber> = 'text'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosPanelTitleLanguage>
    minimalFieldNames<logicalFieldNumber> = 't24LanguageId'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosHorizontalOverflowOption>
    minimalFieldNames<logicalFieldNumber> = 'horizontalOverflow'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosVerticalOverflowOption>
    minimalFieldNames<logicalFieldNumber> = 'verticalOverflow'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosContentType>
    minimalFieldNames<logicalFieldNumber> = 'contentType'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosContentResourceName>
    minimalFieldNames<logicalFieldNumber> = 'resource'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosContentParams>
    minimalFieldNames<logicalFieldNumber> = 'params'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosContentTabbedEnqSelectFrom>
    minimalFieldNames<logicalFieldNumber> = 'tabbedEnqSelectFrom'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosContentTabbedEnqSelectTo>
    minimalFieldNames<logicalFieldNumber> = 'tabbedEnqSelectTo'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosHomeScreenCmdLine>
    minimalFieldNames<logicalFieldNumber> = 'showCommandLineIfInvokedAsHomeScreenCOS'
    
    EB.ModelBank.setCUxpbCosMinimalFieldNames(minimalFieldNames)
RETURN
*** </region>
*** <region name= setMvSvGroupNames>
*** <desc> </desc>
setMvSvGroupNames:
    mvSvGroupNames = ''
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosTitleLanguage>
    mvSvGroupNames<logicalFieldNumber> = 'title'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosInvokableType>
    mvSvGroupNames<logicalFieldNumber> = 'invokables'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosInvokableParamName>
    mvSvGroupNames<logicalFieldNumber> = 'params'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosPanelName>
    mvSvGroupNames<logicalFieldNumber> = 'panels'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosPanelTitleText>
    mvSvGroupNames<logicalFieldNumber> = 'title'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosContentType>
    mvSvGroupNames<logicalFieldNumber> = 'initialContent'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosContentTabbedEnqSelectFrom>
    mvSvGroupNames<logicalFieldNumber> = 'selectionFieldInfo'
    
    EB.ModelBank.setCUxpbCosMvSvGroupNames(mvSvGroupNames)
    
    svGroupNamesWithSingleDisplayableAssociatedField = ''
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosAdditionalCssClassName>
    svGroupNamesWithSingleDisplayableAssociatedField<logicalFieldNumber> = 'additionalCssClassNames'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosHostableNamedContent>
    svGroupNamesWithSingleDisplayableAssociatedField<logicalFieldNumber> = 'hostableNamedContent'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosHostableCosContent>
    svGroupNamesWithSingleDisplayableAssociatedField<logicalFieldNumber> = 'hostableCosContent'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosHostableEnquiryContent>
    svGroupNamesWithSingleDisplayableAssociatedField<logicalFieldNumber> = 'hostableEnquiryContent'
    
    logicalFieldNumber = physicallyOrderedFieldNumbers<EB.Utility.T24UxpbCos.UxpbCosHostableScreenContent>
    svGroupNamesWithSingleDisplayableAssociatedField<logicalFieldNumber> = 'hostableScreenContent'
    
    EB.ModelBank.setCUxpbCosSvGroupNamesWithSingleDisplayableAssociatedField(svGroupNamesWithSingleDisplayableAssociatedField)
RETURN
*** </region>
*** <region name= finalise>
*** <desc> </desc>
finalise:
    cosResponseJson := ']'
    EB.API.GetFieldDefinitions(appName, 'RESTORE')   ;* Restore the field definitions
RETURN
*** </region>

END
