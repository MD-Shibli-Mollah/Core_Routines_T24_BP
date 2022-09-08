* @ValidationCode : Mjo4NzY0NDgwMTc6Q3AxMjUyOjE2MTA2OTA0MzY0Njg6YnNhdXJhdmt1bWFyOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDEuMjAyMDEyMjYtMDYxODo5Ojk=
* @ValidationInfo : Timestamp         : 15 Jan 2021 11:30:36
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bsauravkumar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 9/9 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202101.20201226-0618
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-6</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.GET.ARRANGEMENT.DETAILS
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
* 4/1/2015 - Defect 1291674/ Task 1296838
*			 Introduced new conversion routine for Fetching Arrangement Details
*
* 04/01/21 - Defect 4133691 / Task 4159477
*            Pass Linked Appl Id also as O.DATA
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING EB.Reports
    $USING ST.CompanyCreation
    $USING AA.Framework

*-----------------------------------------------------------------------------

    ARRANGEMENT.ID = EB.Reports.getOData()
    R.AA.ARRANGEMENT = ''

    LOCATE "AA" IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1, 1> SETTING AA.INSTALLED THEN  ;* Checking if AA Product is Installed
        AA.Framework.GetArrangement(ARRANGEMENT.ID, R.AA.ARRANGEMENT,"") ;* Fetching AA.ARRANGEMENT record for that particular Arrangement id
        PRODUCT.LINE = R.AA.ARRANGEMENT<AA.Framework.Arrangement.ArrProductLine>
        LINKED.APPL.ID = R.AA.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId>
        EB.Reports.setOData(PRODUCT.LINE :@FM: LINKED.APPL.ID);* obtaining value for PRODUCT.LINE & LINKED.APPL.ID
    END

RETURN
*-----------------------------------------------------------------------------
END
