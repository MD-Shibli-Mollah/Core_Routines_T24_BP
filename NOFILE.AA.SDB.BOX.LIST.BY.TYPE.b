* @ValidationCode : MjotMTA0NjYwNTAwMTpDcDEyNTI6MTU2NDU1NDAyMDU5ODpqaGFsYWt2aWo6NTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDUzMS0wMzE0OjExNjoxMDU=
* @ValidationInfo : Timestamp         : 31 Jul 2019 11:50:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jhalakvij
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 105/116 (90.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE BX.ModelBank
SUBROUTINE NOFILE.AA.SDB.BOX.LIST.BY.TYPE(LineOut)
*-----------------------------------------------------------------------------
***** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
*
* This routine is linked to a NOFILE enquiry , it takes BOX.TYPE and or BOX.STATUS as input and returns howmamy boxes they are of that type and or status
* The layout for returned data is in format BOX.TYPE~BOX.STATUS~COUNT~TOTAL
*-----------------------------------------------------------------------------
* @uses
* @package BX.ModelBank
* @stereotype subroutine
* @link
* @author empoyi@temenos.com
*-----------------------------------------------------------------------------
*** </region>
************************************************************************************
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*------
* @implied             - box type , and or box status from enquiry selection screen

* Ouptut
*-------
* @param lineOut       - BOX.TYPE~BOX.STATUS~COUNT~TOTAL
*** </region>

************************************************************************************

*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History
*
*  31/03/2016 - Enhancement : 1629504
*               Task : 1629504
*               Total SDB boxes enquiry.
*
* 23/03/2016 - Defect : 2054653
*              Task : 2064421
*              Select the current branch company AA.SDB.BOX alone when launchig the enquiry.
*              If company select is set to ALL then select all SDB boxes.
*
* 27/06/2017 - Defect : 2166910
*              Task : 2174758
*              Change layout of SDB.BOX.LIST.BY.TYPE: Don't print Box type in a single line before details but append it in front of details
*              and don't print toal line per Box type
*
* 22/05/2018 - Enhancement : 2583186
*              Task : 2583189
*              Adding functionality of searching based on branch of the box
*
* 08/05/2019 - Defect : 3080640
*              Task : 3119368
*              Enquiry AA.SDB.BOX.TOTAL (Nofile Enquiry) is not fetching the required output after passing the selection criteria for the branch in the enquiry during runtime
*
* 26/07/2019 - Defect : 3251319
*              Task : 3251578
*              Enquiry AA.SDB.BOX.TOTAL (Nofile Enquiry) should fetch the records properly.
*
*** </region>

*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>import required packages </desc>
    $USING BX.Framework
    $USING EB.DataAccess
    $USING EB.Reports
    $USING EB.SystemTables

*---------------------------------------
*** <region name =  Main Flow>
*** <desc>Main Flow of program </desc>
    GOSUB Initialise
    GOSUB GetBranchSelectionCriteria
    GOSUB GetSelectionCriteria
    GOSUB Process
    GOSUB OutputTheLine
RETURN
*-----------------------------------------------------------------------------
*** <region name =  Initialise>
*** <desc>Initialise variables </desc>
Initialise:
*-----------------------------------------------------------------------------
**** Define layout of Outgoing enquiry Line
    EQU boxTypeField TO 1,
    boxStatusField TO 2 ,
    statusTotalField TO 3,
    typeTotalField   TO 4

****  Get COMMON variable from the enquiry system
    dFields = EB.Reports.getDFields()
    dRangeAndValue = EB.Reports.getDRangeAndValue()
    logicalOperands = EB.Reports.getDLogicalOperands()
    enqSelection = EB.Reports.getEnqSelection()
    EQU enqSelectionEnquiryName TO 1 , enqSelectionFields TO 2 , enqSelectionOperators TO 3 , enqSelectionCriterion TO 4

**** Set the File to be selected and Initialise select Statement
 
    CompanyForEnquiry  = EB.Reports.getREnq()<EB.Reports.Enquiry.EnqCompanySelect>          ;* If user given ALL in this field select boxes for all companies

    CompanyCode = EB.SystemTables.getIdCompany()
    FN.FILE.NAME = "F.AA.SDB.BOX"
    F.FILE.NAME = ""
    EB.DataAccess.Opf(FN.FILE.NAME, F.FILE.NAME)

    IF CompanyForEnquiry EQ 'ALL' THEN
        SelectStatement = 'SELECT ':FN.FILE.NAME
    END ELSE
        SelectStatement = 'SELECT ':FN.FILE.NAME: ' WITH CO.CODE EQ ' :  CompanyCode
    END
  
RETURN
*-----------------------------------------------------------------------------
*** <region name =  GetBranchSelectionCriteria>
*** <desc>Since BRANCH is not a real field in the table but only part of the ID we cannot just add it to the JQL selection.</desc>
GetBranchSelectionCriteria:
*-----------------------------------------------------------------------------
**** Loop through user provided selection Criteria and Append them to the JQL slect statement

    selectionField = "BRANCH"
    branchSearchLocation = ""
    
            
    LOCATE selectionField IN dFields SETTING branchPosition THEN;*If found, store the corresponding value from dRangeAndValue
        
        selectionFields = RAISE(enqSelection<enqSelectionFields>)
        LOCATE selectionField IN selectionFields SETTING enqPosition THEN
         
            branchField = enqSelection<enqSelectionFields, enqPosition>
            branchOperator = enqSelection<enqSelectionOperators, enqPosition>
            branchCriteria = enqSelection<enqSelectionCriterion, enqPosition>
                    
            DEL enqSelection<enqSelectionFields, enqPosition>;*Now delete the branch criteria from the enquiry selection
            DEL enqSelection<enqSelectionOperators, enqPosition>
            DEL enqSelection<enqSelectionCriterion, enqPosition>
        END
        
        DEL dFields<branchPosition>
        DEL dRangeAndValue<branchPosition>
         
        BEGIN CASE
            CASE branchPosition AND branchOperator EQ 'EQ';*If we have a branch criteria add it to the select statement. In all other cases leave the select statement unchanged.

                SelectStatement := " AND WITH @ID LIKE ...-":branchCriteria:"-..."

            CASE branchPosition AND branchOperator EQ 'NE'

                SelectStatement := ' AND WITH @ID UNLIKE ...-':branchCriteria:'-...'
        END CASE
    END
    
RETURN
***</region>
*-----------------------------------------------------------------------------
*** <region name =  GetSelectionCriteria>
*** <desc>retrieve the box number entered by the user, format can be boxNo or CompanyCode-BoxNo </desc>
GetSelectionCriteria:
*-----------------------------------------------------------------------------
**** Loop through user provided selection Criteria and Append them to the JQL slect statement

    noOfSelectionCriteria = DCOUNT(dRangeAndValue,@FM)
    IF noOfSelectionCriteria GE 1  THEN
        SelectStatement := ' WITH '
        FOR selectionFieldCount = 1 TO noOfSelectionCriteria
            IF LEN(dRangeAndValue<selectionFieldCount>) LT 1 THEN
                CONTINUE ;* skip any selection field where no selection criteria is not provided
            END
            IF selectionFieldCount GT 1   THEN
                SelectStatement := ' AND WITH '
            END
            selectionField = dFields<selectionFieldCount>
            selectionCriteria = dRangeAndValue<selectionFieldCount>
            LOCATE selectionField IN enqSelection<enqSelectionFields,1> SETTING itsPosition THEN
                selectionOperator = enqSelection<enqSelectionOperators,itsPosition>
                GOSUB processSpecialOperators ;* some operators may require special processing , handle them accordingly
            END

            SelectStatement :=  selectionField :' ':selectionOperator:' ':selectionCriteria
        NEXT selectionFieldCount
    END
    
RETURN
*-----------------------------------------------------------------------------

*** <region name =  Process>
*** <desc>Read the box record and Build enquiry Output BOX.TYPE~BOX.STATUS~COUNT~TOTAL </desc>
Process:
*-----------------------------------------------------------------------------

    KeyList=''
    ListName=''
    Selected=''
    SystemReturnCode=''
    EB.DataAccess.Readlist(SelectStatement, KeyList, ListName, Selected, SystemReturnCode)
    boxLine = ''

    FOR boxCounter = 1 TO Selected

        boxId = KeyList<boxCounter>
        boxRecord = ''
        readError = ''
        boxRecord   = BX.Framework.SdbBox.CacheRead(boxId,readError)
        IF readError THEN
            CONTINUE
        END
        boxType = boxRecord<BX.Framework.SdbBox.BxBoxType>
        boxStatus = boxRecord<BX.Framework.SdbBox.BxStatus>
        FIND boxType IN boxLine  SETTING typeFieldPosition , typeValuePosition , typeSubValuePosition THEN

            boxLine<typeFieldPosition,typeTotalField> += 1
            boxStatusesForThisType = boxLine<typeFieldPosition,boxStatusField>
            FIND boxStatus IN boxStatusesForThisType SETTING statusFieldPosition , statusValuePosition ,statusSubValuePosition THEN
                boxLine<typeFieldPosition,statusTotalField,statusSubValuePosition> += 1
            END  ELSE
                newStatusPosition = -1
                boxLine<typeFieldPosition,boxStatusField,newStatusPosition> = boxStatus
                boxLine<typeFieldPosition,statusTotalField,newStatusPosition> = 1
            END
        END ELSE
            newTypePosition = DCOUNT(boxLine,@FM) + 1
            boxLine<newTypePosition,boxTypeField> = boxType
            boxLine<newTypePosition,boxStatusField,1> = boxStatus
            boxLine<newTypePosition,typeTotalField> = 1
            boxLine<newTypePosition,statusTotalField,1> = 1
        END

    NEXT boxCounter

RETURN

*-----------------------------------------------------------------------------
** <region name =  OutputTheLine>
*** <desc>Send a string of Data to separated by <*> the enquiry system   </desc>

OutputTheLine:
*-----------------------------------------------------------------------------

    FOR typeCount = 1 TO DCOUNT(boxLine,@FM)
        boxTypeOut = boxLine<typeCount,boxTypeField>
        FOR statusCount = 1 TO DCOUNT(boxLine<typeCount,boxStatusField>,@SM)
            LineOut<-1> = boxTypeOut:'*':boxLine<typeCount,boxStatusField,statusCount> :'*':boxLine<typeCount,statusTotalField,statusCount>
        NEXT statusCount
    NEXT typeCount

RETURN
*-----------------------------------------------------------------------------
*** <region name =  processSpecialOperators>
*** <desc>Handle any special operators in this section , things like RG (BETWEEN) will have 2 subvalues in selectionCriteria instead on just one one  </desc>
processSpecialOperators:
*-----------------------------------------------------------------------------

    BEGIN CASE
        CASE selectionOperator MATCHES 'RG':@VM:'NR'
            selectionCriteria = selectionCriteria<1,1,1> :' ':selectionCriteria<1,1,2> ;* selectionCriteria = subavalue1 <space> subvalue2
        CASE selectionOperator EQ 'LK'
            selectionOperator = 'LIKE'
        CASE selectionOperator EQ 'UL'
            selectionOperator = 'UNLIKE'
    END CASE

RETURN

*-----------------------------------------------------------------------------
END ;*
*-----------------------------------------------------------------------------

