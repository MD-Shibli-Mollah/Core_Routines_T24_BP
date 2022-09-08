* @ValidationCode : MjoxMDU5MTc3MTQ6Q3AxMjUyOjE0OTAwMDg0OTc3NjY6cmRoZXBpa2hhOjI6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzAyLjA6MjM6MjI=
* @ValidationInfo : Timestamp         : 20 Mar 2017 16:44:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdhepikha
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 22/23 (95.6%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


    $PACKAGE SC.ScoPortfolioMaintenance
    SUBROUTINE CONV.SEC.ACC.MASTER.201704(SamId, RSecAccMaster, fnSecAccMaster)
*-----------------------------------------------------------------------------
*** <region name= PROGRAM DESCRIPTION>
*** <desc>Program description</desc>
*-----------------------------------------------------------------------------
*** <region name= Desc>
*** <desc>It describes the routine </desc>
*
* Amended on March 2017 as part of the enhancement to populate the new field
* IAS.CLASSIFICATION in the existing records of the template SEC.ACC.MASTER
* based on the portfolio type defined in the SEC.ACC.MASTER
* record.
*
*-----------------------------------------------------------------------------
*
* @uses SC.ScoPortfolioMaintenance
* @package SC.ScoPortfolioMaintenance
* @class CONV.SEC.ACC.MASTER.201704
* @stereotype application
* @author rdhepikha@temenos.com
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>To define the arguments </desc>
* Incoming Arguments:
*
* @param SamId         - Record Id which has to be coverted
* @param RSecAccMaster - Record variable (containing the record SEC.ACC.MASTER)
* @paramfnSecAccMaster - File path (FBNK.SEC.ACC.MASTER)
*
* Outgoing Arguments:
*
* @param RSecAccMaster - Record variable (containing the record SEC.ACC.MASTER)
*                        updated with IAS.CLASSIFICATION
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MODIFICATION HISTORY>
*** <desc>Modification History</desc>
*-----------------------------------------------------------------------------
*
* 24/02/17 - Enhancement 2014277 / Task 2042209
*            Conversion routine to udpate the IAS.CLASSIFICATION to the
*            existing SEC.ACC.MASTER records.
*
* 19/03/17 - Enhancement 2014277 / Task 2057977
*            Changes done such that the conversion routine is executed
*		     only if the module I9 is installed and IFRS.PARAMETER is
*			 configured for the current company.
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= insertlibrary>
*** <desc>To define the packages being used </desc>

    $USING SC.ScoPortfolioMaintenance
    $USING I9.Config

*** </region>

*-----------------------------------------------------------------------------
*** <region name= process>
*** <desc>Processing of the routine </desc>

    GOSUB initialise ;* Initialise required variables
    GOSUB checkI9Installed ;* To check whether the module I9 is installed

    IF  proceedFlag AND ifrsSubType THEN
        GOSUB process ;* Main Process
    END

    RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= initialise>
initialise:
*** <desc> Initialise required variables </desc>

    ifrsSubType = RSecAccMaster<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamIfrsSubType>

    RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= process>
process:
*** <desc> Main Process </desc>

* for the existing SEC.ACC.MASTER record the field IAS.CLASSIFICATION is
* populated based on the PORTFOLIO.TYPE defined in the record

    IasClassification = 'HFT'
    IF RSecAccMaster<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamPortfolioType> = 'AVAIL.SALE' THEN
        IasClassification = 'AFS'
    END
    IF RSecAccMaster<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamPortfolioType> = 'INVESTMENT' THEN
        IasClassification = 'HTM'
    END

    RSecAccMaster<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamIasClassification> = IasClassification

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= checkI9Installed>
checkI9Installed:
*** <desc> To check whether the module I9 is installed </desc>

    proceedFlag = 0
    I9.Config.IFRSCheckI9Enabled(Enabled) ;* API to determine whether the I9 product is installed and availabe for use

* only if I9 is installed and IFRS.PARAMETER is configured the flag variable is set
    IF Enabled EQ 'YES' THEN
        proceedFlag = 1
    END

    RETURN
*** </region>

    END

