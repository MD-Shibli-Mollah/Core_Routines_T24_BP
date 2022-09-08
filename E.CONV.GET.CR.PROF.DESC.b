* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version n dd/mm/yy  GLOBUS Release No. G13.1.00 31/10/02
*-----------------------------------------------------------------------------
* <Rating>-6</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.ModelBank

    SUBROUTINE E.CONV.GET.CR.PROF.DESC
*-----------------------------------------------------------------------------
* Conversion routine to display description from CR.PROFILE
* This conversion is to avoid if CR product is not installed in the company
*-----------------------------------------------------------------------------
* Modification History:
*17/04/15  - Defect : 1279233
*          - Task   : 1318583
*          - Enquiry not allowing to edit due to CR profile product not installed in the company
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Reports
    $USING ST.CompanyCreation
    $USING CR.Analytical
*-----------------------------------------------------------------------------
    ID.DATA       = ''
    ID.DATA       = EB.Reports.getOData()
    CR.INSTALLED  = ''
    PR.POS        = ''
    R.CR.PROFILE  = ''
    CR.ERR        = ''
*-----------------------------------------------------------------------------
    IF ID.DATA THEN
        LOCATE 'CR' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING PR.POS THEN
        R.CR.PROFILE = CR.Analytical.Profile.Read(ID.DATA, CR.ERR)
        EB.Reports.setOData(R.CR.PROFILE<1,EB.SystemTables.getLngg()>)
    END
    END

    RETURN
*-----------------------------------------------------------------------------
    END
*-----------------------------------------------------------------------------
