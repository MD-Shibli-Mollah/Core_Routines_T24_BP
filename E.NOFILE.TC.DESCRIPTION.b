* @ValidationCode : MjoxODI0ODUyNzUxOkNwMTI1MjoxNDg3MDY3MDQwMjEzOnJzdWRoYTo0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxNzAyLjA6MTA1OjEwMQ==
* @ValidationInfo : Timestamp         : 14 Feb 2017 15:40:40
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rsudha
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 101/105 (96.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE EB.Channels
    SUBROUTINE E.NOFILE.TC.DESCRIPTION(returnData)
*-----------------------------------------------------------------------------------------------------------------
* Generic Nofile routine to provide description of a given Record Id from a T24 table or EB.LOOKUP virtual table
* IN Parameter  : T24 Application name or Virtual table name and Record Id
* OUT Parameter : Record description
*-----------------------------------------------------------------------------------------------------------------
* Modification history:
*-----------------------------------------------------------------------------------------------------------------
* 08/12/2016 - 1671286
*              IRIS Service Integration : Administration Home > create INDIRECT User
*-----------------------------------------------------------------------------------------------------------------

    $USING ST.Customer
    $USING EB.Template
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.DataAccess

    GOSUB Initialise
    GOSUB Process
*
    RETURN
*-----------------------------------------------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------------------------------------------

* Locate the current User Language
    lng = EB.SystemTables.getLngg() 

* Initilise all
    fieldName = 'DESCRIPTION':@FM:'SHORT.DESC':@FM:'COMPANY.NAME':@FM:'RATING.DESC':@FM:'COUNTRY.NAME':@FM:'CCY.NAME':@FM:'SHORT.NAME':@FM:'SHORT.TITLE':@FM:'NAME':@FM:'DESCRIPT':@FM:'DESCR':@FM:'DESC'
    fieldNameCount = ''
    fieldNameValue = ''
    appPos = ''
    idPos = ''
    applicationName = ''
    recordId = ''
    ssSysFieldName = ''
    ssSysFieldNo = ''
    ssPos = ''

* Get input parameter values from enquiry selection
    LOCATE 'APPLICATION.NAME' IN EB.Reports.getDFields()<1> SETTING appPos THEN
* Check condition for getting Application Name
        WDFields = EB.Reports.getDFields()<appPos>
        WDRangeAndValue = EB.Reports.getDRangeAndValue()<appPos>
        WDLogicalOperands = EB.Reports.getDLogicalOperands()<appPos>
        IF WDFields = 'APPLICATION.NAME' AND WDLogicalOperands = 1 THEN
            ;* To get Application Name
            applicationName = WDRangeAndValue
        END
    END

    LOCATE 'RECORD.ID' IN EB.Reports.getDFields()<1> SETTING idPos THEN
* Check condition for getting Record Id
        WDFields = EB.Reports.getDFields()<idPos>
        WDRangeAndValue = EB.Reports.getDRangeAndValue()<idPos>
        WDLogicalOperands = EB.Reports.getDLogicalOperands()<idPos>
        IF WDFields = 'RECORD.ID' AND WDLogicalOperands = 1 THEN
            ;* To get Record Id
            recordId = WDRangeAndValue
            CHANGE @SM TO ' ' IN recordId
        END
    END

    RETURN

*-----------------------------------------------------------------------------------------------------------------
Process:
*-----------------------------------------------------------------------------------------------------------------

* Check if ApplicationName exists in STANDARD.SELECTION application
    IF applicationName NE '' THEN
        standardSelectionRec = EB.SystemTables.StandardSelection.Read(applicationName, standardSelectionErr)
        
        IF NOT(standardSelectionErr) THEN
            GOSUB SelectId
        END ELSE
            GOSUB ProcessEbLookup
        END
    END

    RETURN

*-----------------------------------------------------------------------------------------------------------------
SelectId:
*-----------------------------------------------------------------------------------------------------------------

* Locate description field name in STANDARD.SELECTION fields for the ApplicationName
    ssSysFieldName = standardSelectionRec<EB.SystemTables.StandardSelection.SslSysFieldName>
    ssSysFieldNo = standardSelectionRec<EB.SystemTables.StandardSelection.SslSysFieldNo>
    descriptionNo = ''
    fieldNameCount = DCOUNT(fieldName,@FM)
    FOR i = 1 TO fieldNameCount
        fieldNameValue = fieldName<i>
        LOCATE fieldNameValue IN ssSysFieldName<1,1> SETTING ssPos THEN
            descriptionNo = ssSysFieldNo<1,ssPos>
            i = fieldNameCount
        END
    NEXT i

    fnApplication = 'F.':applicationName
    fApplication = ''

    IF recordId EQ '' THEN
* Build the Select condition 
        selectCmd = 'SELECT ' : fnApplication        
        selectId = ''
        selectNo = ''
        EB.DataAccess.Readlist(selectCmd, selectId, '', selectNo, readlistErr)
        FOR j = 1 TO selectNo
            applicationId = selectId<j>
            GOSUB GetDescription
        NEXT j
    END ELSE
        applicationId = recordId
        GOSUB GetDescription
    END

    RETURN

*-----------------------------------------------------------------------------------------------------------------
GetDescription:
*-----------------------------------------------------------------------------------------------------------------

* Read the application and get the description for applicationId
    applicationErr = ''   

    EB.DataAccess.FRead(fnApplication, applicationId, applicationRec, fApplication, applicationErr)

    IF NOT(applicationErr) THEN
        IF applicationRec<descriptionNo, lng> THEN
            applicationDescription = applicationRec<descriptionNo, lng>
        END ELSE
            applicationDescription = applicationRec<descriptionNo, 1>
        END
* Build the array according to enquiry requirements
        returnData<-1> = applicationId:'*@*':applicationDescription 
    END

    RETURN

*-----------------------------------------------------------------------------------------------------------------
ProcessEbLookup:
*-----------------------------------------------------------------------------------------------------------------

    IF recordId EQ '' THEN
* Build the Select condition 
        selectCmd = 'SSELECT F.EB.LOOKUP BY @ID WITH VIRTUAL.TABLE EQ ':applicationName:' ':recordId
        selectId = ''
        selectNo = ''
        EB.DataAccess.Readlist(selectCmd, selectId, '', selectNo, readlistErr)
        FOR j = 1 TO selectNo
            applicationId = selectId<j>
            GOSUB GetLookupDescription
        NEXT j
    END ELSE
        applicationId = applicationName:'*':recordId
        GOSUB GetLookupDescription
    END

    RETURN
    
*-----------------------------------------------------------------------------------------------------------------
GetLookupDescription:
*-----------------------------------------------------------------------------------------------------------------

* Read the EB.LOOKUP record and get the description for applicationId
    lookupId = ''
    lookupRec = EB.Template.Lookup.Read(applicationId, lookupErr)
    IF NOT (lookupErr) THEN
        IF lookupRec<EB.Template.Lookup.LuDescription, lng> THEN
            lookupDescription = lookupRec<EB.Template.Lookup.LuDescription, lng>
        END ELSE
            lookupDescription = lookupRec<EB.Template.Lookup.LuDescription, 1>
        END
        lookupId = lookupRec<EB.Template.Lookup.LuLookupId>
* Build the array according to enquiry requirements
        returnData<-1> = lookupId:'*@*':lookupDescription
    END

    RETURN
    
END
