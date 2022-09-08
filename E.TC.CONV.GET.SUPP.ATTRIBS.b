* @ValidationCode : MjotNDEyOTU1MzM1OkNwMTI1MjoxNTU0NzIyNjg3NDkxOmpleWFsYXZhbnlhajoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTAzLjIwMTkwMjE5LTEyNDE6MzQ6MzM=
* @ValidationInfo : Timestamp         : 08 Apr 2019 16:54:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jeyalavanyaj
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 33/34 (97.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201903.20190219-1241
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE T2.ModelBank
SUBROUTINE E.TC.CONV.GET.SUPP.ATTRIBS
*-----------------------------------------------------------------------------
* Description :
* -----------
* This Enquiry(Conversion) routine is to provide external account details
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 18/03/19  - Enhancement - 2867757 / Task 3039079
*               Fetch the details of external accounts for TCIB
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
    $USING EB.API
    $USING EB.Reports
    $USING EB.Security
    $USING EB.SystemTables
    $USING AA.Framework
    $USING AC.AccountOpening
        
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>
*
    GOSUB Initialise
    GOSUB Process
    
    finalArray = extAccountNo:"*":shortTitle:"*":sortCode
    EB.Reports.setOData(finalArray)
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise variables used in this routine</desc>
Initialise:
*---------
* Initialise the required variables
    arrangementId = EB.Reports.getOData() ;* Get Arrangement value value
    arrangementRec = AA.Framework.Arrangement.Read(arrangementId, arrangementError)
    openingDate = arrangementRec< AA.Framework.Arrangement.ArrStartDate>
    languageId = EB.SystemTables.getRUser()<EB.Security.User.UseLanguage>
*
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------------------------------
*** <region name = Process>
*** <desc>Read account Supplemetary attributes record</desc>
Process:
*------
* Get account details
    AA.Framework.GetArrangementAccountId(arrangementId, accountId, "", "");* Get account of current arrangement
    accountRecord = AC.AccountOpening.Account.Read(accountId, accounrError)
    accountName = accountRecord<AC.AccountOpening.Account.AccountTitleOne>
    shortTitle    = accountRecord<AC.AccountOpening.Account.ShortTitle,languageId>
    
* Get supplementary attributes of the arrangement
    AA.Framework.GetArrangementConditions(arrangementId,'XSUPPLEMENTARY.ATTRIBS','',openingDate,'',sAttrPropertyRec,sAttrErr)      ;* Get arrangement condition for supplementary attribute Property class
    SS.RECORD = ''
    applicationName = 'AA.ARR.XSUPPLEMENTARY.ATTRIBS'
    fieldNames = 'SORT.CODE':@FM:'CLIENT.NAME':@FM:'SWIFT.REF':@FM:'ACCOUNT.NUMBER'
    EB.API.GetStandardSelectionDets(applicationName, SS.RECORD) ;* Read the SS record for this property class to read the field data
    FOR fieldPos = 1 TO DCOUNT(fieldNames,@FM)
        fieldName = fieldNames<fieldPos>
        GOSUB GetFieldNo
        fieldData<fieldPos> = sAttrPropertyRec<1,fieldNo>
    NEXT fieldPos
    sortCode = fieldData<1>
    IF shortTitle EQ '' THEN
        shortTitle = accountName
    END
    clientName = fieldData<2>
    extAccountNo = fieldData<4>
*
RETURN
*** </region>
*------------------------------------------------------------------------------------------------------*
* <region name= Get Field Number>
* <desc> Get Field number</desc>
GetFieldNo:
*---------
    FIELD.NO = ""           ;* Initialise the field number
    EB.API.FieldNamesToNumbers(fieldName, SS.RECORD, fieldNo, "", "", "", "", ErrMsg)
        
RETURN
* </region>
*** </region>
*------------------------------------------------------------------------------------------------------*
    
END
