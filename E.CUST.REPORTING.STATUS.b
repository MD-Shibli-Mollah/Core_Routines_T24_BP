* @ValidationCode : MjotNjkyMDc3Mzk5OkNwMTI1MjoxNTc1OTgwODkwNjk2OmFzdXJ5YToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTEyLjIwMTkxMTE5LTEzMzQ6Mjk6Mjk=
* @ValidationInfo : Timestamp         : 10 Dec 2019 17:58:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : asurya
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 29/29 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201912.20191119-1334
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE ST.ModelBank
SUBROUTINE E.CUST.REPORTING.STATUS(ACC.DATA)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 29/11/19 - Task 3463282
* 			 New routine introduced to fetch customer reporting information
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING ST.Customer
    $USING CD.CustomerIdentification
    $USING FA.CustomerIdentification
    $USING EB.API
    $USING EB.SOAframework


    LOCATE 'CUSTOMER.ID' IN EB.Reports.getDFields()<1> SETTING CUS.POS THEN    ;* locate ACCOUNTREFERENCE in enquiry data and get position
        CUST.ID = EB.Reports.getDRangeAndValue()<CUS.POS>                           ;* Get the account id using the position
    END
    
    IF CUST.ID THEN
		EB.SOAframework.Checkserviceexists("CUSTOMER","getRecord",serviceName)
        CALL @serviceName(CUST.ID, CUSTOMER.RECORD)
        POSTING.RESTRICT = CUSTOMER.RECORD<ST.Customer.Customer.EbCusPostingRestrict>
        CONVERT @VM TO "|" IN POSTING.RESTRICT
        AML.RESULT = CUSTOMER.RECORD<ST.Customer.Customer.EbCusAmlResult>
    END

    CD.INSTALLED = ''
    EB.API.ProductIsInCompany("CD", CD.INSTALLED)
    IF CD.INSTALLED THEN
        CRS.ERR = ''
        CRS.CUST.SUPP.INFO.REC = CD.CustomerIdentification.CrsCustSuppInfo.Read(CUST.ID, CRS.ERR)
        CRS.STATUS = CRS.CUST.SUPP.INFO.REC<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCrsStatus>
        CONVERT @VM TO "|" IN CRS.STATUS
        CRS.JURISDICTION = CRS.CUST.SUPP.INFO.REC<CD.CustomerIdentification.CrsCustSuppInfo.CdSiReportableJurRes>
        CONVERT @VM TO "|" IN CRS.JURISDICTION
    END

    FA.INSTALLED = ''
    EB.API.ProductIsInCompany("FA", FA.INSTALLED)
    IF FA.INSTALLED THEN
        FA.ERR = ''
        FATCA.CUST.SUPP.INFO.REC = FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.Read(CUST.ID, FA.ERR)
        FATCA.STATUS = FATCA.CUST.SUPP.INFO.REC<FA.CustomerIdentification.FatcaCustomerSupplementaryInfo.FiFatcaStatus>
    END
 
    ACC.DATA = FATCA.STATUS : '*' : CRS.STATUS : "*" : CRS.JURISDICTION : "*" : POSTING.RESTRICT : "*" : AML.RESULT

RETURN
    
END
