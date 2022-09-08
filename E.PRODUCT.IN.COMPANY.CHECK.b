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

*-----------------------------------------------------------------------------
* <Rating>-26</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AI.ModelBank
    SUBROUTINE E.PRODUCT.IN.COMPANY.CHECK
*-----------------------------------------------------------------------------
* Routine type       : Conversion routine
* Attached To        : ENQUIRY>EB.MESSAGE.READ.IN
* Purpose            : This routine used to check whether the incomming product is available
*                      in R.COMPANY.
* Incoming           : O.DATA
* Outgoing			 : O.DATA
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 19/08/15 - Defect 1442572 / Task 1442807
*            IM dependency issue in secure message reply from T24 to External User
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Reports
    $USING ST.CompanyCreation

*-----------------------------------------------------------------------------
    GOSUB INITIALISE
    GOSUB PROCESS
*
    RETURN
*-----------------------------------------------------------------------------
INITIALISE:
* Intialise the required variables
    PRODUCT.ID=EB.Reports.getOData() ;* To get the Product Id
*
    RETURN
*------------------------------------------------------------------------------
PROCESS:
* To check the product availability in R.COMPANY
    LOCATE PRODUCT.ID IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING IM.INSTALLED THEN ;* Locate the PRODUCT Id
    EB.Reports.setOData("YES");* Set Flag YES , When the product is available
    END ELSE
    EB.Reports.setOData("NO");* Set Flag NO , When the product is not available
    END
*
    RETURN
*-------------------------------------------------------------------------------------
    END
*-------------------------------------------------------------------------------------
