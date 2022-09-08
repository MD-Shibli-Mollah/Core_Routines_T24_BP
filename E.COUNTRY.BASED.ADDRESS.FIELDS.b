* @ValidationCode : MjoxMzQwMzMwNTE3OmNwMTI1MjoxNTc0MTYxMzg4NTY3OmFyZWdneXdhdHNvbjotMTotMTowOjA6dHJ1ZTpOL0E6REVWXzIwMTkxMi4yMDE5MTEwOC0wNDQ2Oi0xOi0x
* @ValidationInfo : Timestamp         : 19 Nov 2019 16:33:08
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : areggywatson
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : DEV_201912.20191108-0446
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE EB.ModelBank
SUBROUTINE E.COUNTRY.BASED.ADDRESS.FIELDS(outArray)
*-----------------------------------------------------------------------------
* Routine invoked by Enquiry - COUNTRY.BASED.ADDRESS.FIELDS
*
* Params
* outArray	:	INOUT	:	String
*-----------------------------------------------------------------------------
* Modification History :
*
* 18/11/2019	-	Enhancement 3037835 / Task 3359909
*          			Nofile enquiry routine to return Country based address details
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING EB.SystemTables
    $USING ST.Config
    $USING ST.Customer
*-----------------------------------------------------------------------------
    
    GOSUB INIT
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------
INIT:

    enqSelectionCriteria = ''				;*variable to hold the selection criteria fields
    appRec = ''
    LOCATE 'APPLICATION' IN EB.Reports.getDFields()<1> SETTING pos1 THEN							;*get Application data
        enqSelectionCriteria<ST.Config.Application> = EB.Reports.getDRangeAndValue()<pos1>
    END
    LOCATE 'RECORD.ID' IN EB.Reports.getDFields()<1> SETTING pos2 THEN								;*get Record Id data
        enqSelectionCriteria<ST.Config.AppId> = EB.Reports.getDRangeAndValue()<pos2>
    END
    LOCATE 'ADDRESS.COUNTRY' IN EB.Reports.getDFields()<1> SETTING pos3 THEN						;*get Address Country data (mandatory)
        enqSelectionCriteria<ST.Config.AddrCountry> = EB.Reports.getDRangeAndValue()<pos3>
    END
    LOCATE 'ADDRESS.TYPE' IN EB.Reports.getDFields()<1> SETTING pos4 THEN							;*get Address Type data
        enqSelectionCriteria<ST.Config.AddressType> = EB.Reports.getDRangeAndValue()<pos4>
    END
    LOCATE 'CUSTOMER' IN EB.Reports.getDFields()<1> SETTING pos5 THEN								;*get Customer field data (only gor Person.Entity)
        appRec<ST.Customer.PersonEntity.PerEntCustomer> = EB.Reports.getDRangeAndValue()<pos5>		;*set the Customer field data in the dynamic variable (like record variable)
    END
    enqSelectionCriteria<ST.Config.Company> = EB.SystemTables.getIdCompany()						;*get Company data

    enqResponse = ''                        ;*initialise variable
    Reserved2 = ''
    Reserved3 = ''
    
RETURN
*-----------------------------------------------------------------------------
PROCESS:

    ST.Customer.getAddressFieldDetails(enqSelectionCriteria, appRec, Reserved2, enqResponse, Reserved3)		;*Invoke the API to get the Address field details

    outArray = ''
    noOfaddressFields = DCOUNT(enqResponse<ST.Customer.AddrRuleFieldName>,@VM)						;*get the count of Address fields
*Set the Address field details separated by * in outArray
    FOR addressFieldsCount=1 TO noOfaddressFields
        outArray<-1> = enqResponse<ST.Customer.AddrRuleFieldName,addressFieldsCount>:'*'
        outArray := enqResponse<ST.Customer.AddrRuleFieldLabel,addressFieldsCount>:'*'
        outArray := enqResponse<ST.Customer.AddrRuleFieldMandatory,addressFieldsCount>:'*'
        outArray := enqResponse<ST.Customer.AddrRuleFieldMaxLen,addressFieldsCount>:'*'
        outArray := enqResponse<ST.Customer.AddrRuleFieldType,addressFieldsCount>:'*'
        outArray := enqResponse<ST.Customer.AddrRuleFieldPattern,addressFieldsCount>:'*'
        outArray := enqResponse<ST.Customer.AddrRuleFieldLookUpList,addressFieldsCount>:'*'
        outArray := enqResponse<ST.Customer.AddrRuleFieldLookUpApp,addressFieldsCount>:'*'
        outArray := enqResponse<ST.Customer.AddrRuleError,addressFieldsCount>
    NEXT addressFieldsCount

RETURN
*-----------------------------------------------------------------------------
END
