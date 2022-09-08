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
* <Rating>-208</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Foundation
    SUBROUTINE CONV.AM.PARAMETER.R09(company.ID, company.RECORD, F.COMPANY)
*--------------------------------------------------------------------------------------------
* Description: this routine will update VEH.POINTER as current month and HIST.DURATION as "12"
* ------------
*
* Author: vjerryfuller@temenos.com
*--------------------------------------------------------------------------------------------
* Modification History:
* ---------------------
*
* 01/11/2008 - BG_100020665
*              Child company update master company AM.PARAMETER if only one parameter file exist
*
* 08/12/08 - BG_100021204
*            Conversion should call journal updates
*
* 07/01/09 - BG_100021528
*            Addition of VehPtrUpdDate in AM.PARAMETER during conversion
* 
* 27/09/13 - Defect : 792535 Task : 795087
*            Check if AM.PARAMETER record exists in the previous release before creating in the next release
*
*--------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AM.PARAMETER
    $INSERT I_F.DATES
    $INSERT I_F.AM.VEH.INDEX
    $INSERT I_F.COMPANY       ;* BG_100020638 - S/E

    GOSUB initialise
    IF proceedFurther THEN    ;* BG_100020638 - S
        GOSUB setCompany
        GOSUB openFiles
        GOSUB readAmParameter
        IF runThisConv THEN
            GOSUB mainProgram
            GOSUB resetCompany
        END
    END   ;* BG_100020638 - E
    RETURN

*--------------------------------------------------------------------------------------------
initialise:
*----------

* Equate variables
    EQU amParameterVehPointer TO 38
    EQU amParameterHistDuration TO 53
    EQU amParameterVehPtrUpdDate TO 86
    EQU maxMonth TO 12
    EQU currStatus TO 'ACTIVE'

* Initialise variables
    currMonth = R.DATES(EB.DAT.TODAY)[5,2]
    currYear = R.DATES(EB.DAT.TODAY)[1,4]
    retry = ''

* check to proceed further
    GOSUB checkToContinue     ;* BG_100020638 - S
    RETURN

*--------------------------------------------------------------------------------------------
setCompany:
*----------

    saveIdCompany = ID.COMPANY
    CALL LOAD.COMPANY(company.ID)
    RETURN

*--------------------------------------------------------------------------------------------
resetCompany:
*------------

    CALL LOAD.COMPANY(saveIdCompany)
    CALL JOURNAL.UPDATE("")   ;* we have to call this, since run.conversion.pgms does not call journal update
    RETURN

*--------------------------------------------------------------------------------------------
openFiles:
*---------

* Open file variables
    FN.AM.VEH.LIST = 'F.AM.VEH.LIST'
    F.AM.VEH.LIST = ''
    CALL OPF(FN.AM.VEH.LIST, F.AM.VEH.LIST)

    FN.AM.VEH.INDEX = 'F.AM.VEH.INDEX'
    F.AM.VEH.INDEX = ''
    CALL OPF(FN.AM.VEH.INDEX, F.AM.VEH.INDEX)

    FN.AM.VEH.DATE.REF = 'F.AM.VEH.DATE.REF'
    F.AM.VEH.DATE.REF = ''
    CALL OPF(FN.AM.VEH.DATE.REF, F.AM.VEH.DATE.REF)

    FN.AM.PARAMETER = 'F.AM.PARAMETER'
    F.AM.PARAMETER = ''
    CALL OPF(FN.AM.PARAMETER, F.AM.PARAMETER)

    RETURN

*--------------------------------------------------------------------------------------------
checkToContinue:
*---------------

    proceedFurther = @FALSE
* Check whether the company has the product
    product = "AM":@FM:company.ID
    validProduct = @FALSE
    productInstalled = @FALSE
    companyHasProduct = @FALSE
    errorText = ''
    CALL EB.VAL.PRODUCT(product, validProduct, productInstalled, companyHasProduct, errorText)

* other than real company; the branches, consolidation and reporting companies will not process further
    IF NOT(INDEX(company.ID,";",1)) AND company.RECORD<EB.COM.FINANCIAL.COM> EQ company.ID AND company.RECORD<EB.COM.CONSOLIDATION.MARK> EQ 'N' AND companyHasProduct THEN
        proceedFurther = @TRUE
    END
    RETURN          ;* BG_100020638 - E

*--------------------------------------------------------------------------------------------
mainProgram:
*-----------

    GOSUB checkHistFileExist
    GOSUB updateAmParameter   ;* BG_100020665 - S/E
    GOSUB updateAmVehIndex
    GOSUB updateAmVehList
    RETURN

*--------------------------------------------------------------------------------------------
checkHistFileExist:
*------------------

* Check existance of all AM.VEH and AM.INST.VEH files

    CALL AM.CHK.HIST.FILES.EXIST(maxMonth)
    IF E THEN
        GOSUB FATAL.ERROR
    END
    RETURN

*--------------------------------------------------------------------------------------------
updateAmVehIndex:
*----------------

* Update all default Index files.
    FOR iLoop = currMonth TO 1 STEP -1
        currContainer = iLoop
        postYear = currYear
        GOSUB buildAmVehIndexRecord
        GOSUB writeAmVehIndex
    NEXT iLoop

    nextMonth = currMonth + 1
    prevYear = currYear - 1
    FOR iLoop = nextMonth TO maxMonth
        currContainer = iLoop
        postYear = prevYear
        GOSUB buildAmVehIndexRecord
        GOSUB writeAmVehIndex
    NEXT iLoop
    RETURN

*--------------------------------------------------------------------------------------------
buildAmVehIndexRecord:
*---------------------

* Update the index record

    amVehIndex.RECORD = ''
    IF currContainer < 10 THEN
        currContainer = '0':currContainer
    END

    GOSUB checkVehDateRef
    amVehIndex.ID = 'AM.VEH.':postYear:currContainer
    amVehIndex.RECORD <AmVehIndex_VehContainer> = currContainer
    amVehIndex.RECORD <AmVehIndex_Status> = currStatus
    RETURN

*--------------------------------------------------------------------------------------------
writeAmVehIndex:
*---------------

* Write the index status and yyyymm to AM.VEH.INDEX

    amVehIndexTempRec = ''
    amVehIndexError = ''
    CALL F.READU(FN.AM.VEH.INDEX, amVehIndex.ID, amVehIndexTempRec, F.AM.VEH.INDEX, amVehIndexError, retry)

    IF amVehIndexTempRec EQ '' THEN
        CALL F.WRITE(FN.AM.VEH.INDEX, amVehIndex.ID, amVehIndex.RECORD)
    END ELSE
        CALL F.RELEASE(FN.AM.VEH.INDEX, amVehIndex.ID, F.AM.VEH.INDEX)
    END
    RETURN

*--------------------------------------------------------------------------------------------
updateAmVehList:
*---------------

* prepare the default list record

    amVehList.RECORD = ''
    FOR iLoop = 1 TO maxMonth
        IF iLoop < 10 THEN
            iLoop = "0":iLoop
        END
        amVehList.RECORD<-1> = iLoop
    NEXT iLoop

    GOSUB writeToAmVehList
    RETURN

*--------------------------------------------------------------------------------------------
writeToAmVehList:
*----------------

* write the list to AM.VEH.LIST

    amVehListTempRec = ''
    amVehListError = ''
    amVehList.ID = amParameter.ID       ;* BG_100020665  - S/E
    CALL F.READU(FN.AM.VEH.LIST, amVehList.ID, amVehListTempRec, F.AM.VEH.LIST, amVehListError, retry)

    IF amVehListTempRec EQ '' THEN
        CALL F.WRITE(FN.AM.VEH.LIST, amVehList.ID, amVehList.RECORD)
    END ELSE
        CALL F.RELEASE(FN.AM.VEH.LIST, amVehList.ID, F.AM.VEH.LIST)
    END
    RETURN

*--------------------------------------------------------------------------------------------
updateAmParameter:  ;* BG_100020638 - S
*-----------------

* update month and maximum container to the am.parameter
* if master company update otherwise leave without update (if only one parameter setup is present)
    IF company.ID EQ amParameter.ID THEN
        amParameter.RECORD<amParameterVehPointer> = currMonth
        amParameter.RECORD<amParameterHistDuration> = maxMonth        ;* Default number of containers
        amParameter.RECORD<amParameterVehPtrUpdDate> = TODAY
        GOSUB writeAmParameter
    END ELSE
        GOSUB releaseAmParameter
    END
    RETURN          ;* BG_100020638 - E

*--------------------------------------------------------------------------------------------
checkVehDateRef:
*---------------

    amVehDateRef.RECORD = ''
    amVehDateRefError = ''
    amVehDateRef.ID = currContainer
    CALL F.READ(FN.AM.VEH.DATE.REF, amVehDateRef.ID, amVehDateRef.RECORD, F.AM.VEH.DATE.REF, amVehDateRefError)
    IF amVehDateRef.RECORD NE '' THEN
        postYear = amVehDateRef.RECORD[1,4]
    END
    RETURN

*--------------------------------------------------------------------------------------------
readAmParameter:    ;* BG_100020638 - S
*---------------

    amParameter.ID = company.ID
    CALL EB.READ.PARAMETER(FN.AM.PARAMETER, 'Y', '', amParameter.RECORD, amParameter.ID, F.AM.PARAMETER, err)
    runThisConv = 0
* if master company update otherwise leave without update (if only one parameter setup is present)
* Also if field VEH.POINTER is not null, means conversion already been run.
    IF company.ID EQ amParameter.ID AND NOT(err) AND amParameter.RECORD<amParameterVehPointer> EQ '' THEN
        runThisConv = 1
    END
    RETURN

*--------------------------------------------------------------------------------------------
writeAmParameter:
*----------------

    CALL F.WRITE(FN.AM.PARAMETER, amParameter.ID, amParameter.RECORD)
    RETURN

*--------------------------------------------------------------------------------------------
releaseAmParameter:
*------------------

    CALL F.RELEASE(FN.AM.PARAMETER, amParameter.ID, F.AM.PARAMETER)
    RETURN          ;* BG_100020638 - E

*--------------------------------------------------------------------------------------------
FATAL.ERROR:
*-----------

    SOURCE.INFO = "CONV.AM.PARAMETER.R09"
    SOURCE.INFO<2> = "AM"
    SOURCE.INFO<3> = E<2>
    SOURCE.INFO<4> = "History File Missing F.FILE.CONTROL"
    CALL FATAL.ERROR(SOURCE.INFO)
END
