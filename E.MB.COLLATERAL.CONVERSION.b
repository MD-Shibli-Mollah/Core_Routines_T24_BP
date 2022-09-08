* @ValidationCode : MjoxMjY2NTI1NjUxOmNwMTI1MjoxNDk2NjczMTM2NDA3OmNtYW5pdmFubmFuOjM6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzA1LjA6MjM6MjM=
* @ValidationInfo : Timestamp         : 05 Jun 2017 20:02:16
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : cmanivannan
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 23/23 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201705.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE LI.ModelBank
SUBROUTINE E.MB.COLLATERAL.CONVERSION
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 05/06/17 - Defect 2102216 / Task 2148534
*            Build Routine, whether check the COLLATERAL is installed or not
*            and then process the selected records.
*
*-----------------------------------------------------------------------------

    $USING CO.Config
    $USING EB.Reports
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING ST.CompanyCreation

*-----------------------------------------------------------------------------

    GOSUB initialise ;* initialise the variables
    GOSUB openfiles  ;* open the files
    GOSUB process    ;* do the further process

    RETURN
*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc> </desc>

    iCollateralCodeID = EB.Reports.getOData() ;* Incoming DE.ADDRESS id
    rCompanyApplication = ''
    oErrorinProcessing = ''
    oCollateralCodeRECORD = ''

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= process>
process:
*** <desc> </desc>
    IF NOT(iCollateralCodeID) THEN
        RETURN
    END
    rCompanyApplication = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)

    LOCATE "CO" IN rCompanyApplication<1,1> SETTING COL.POS THEN
        oCollateralCodeRECORD = CO.Config.CollateralCode.CacheRead(iCollateralCodeID, oErrorinProcessing)
        IF oCollateralCodeRECORD THEN
            EB.Reports.setOData(oCollateralCodeRECORD<CO.Config.CollateralCode.CollCodeDescription>)
        END
    END ELSE
        EB.Reports.setOData('')
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------
** <region name= open files>
openfiles:
*** <desc> </desc>

    RETURN
*** </region>
*-----------------------------------------------------------------------------

    END
