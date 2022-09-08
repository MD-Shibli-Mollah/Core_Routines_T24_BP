* @ValidationCode : MjotMjAzMDc0NjY1MTpDcDEyNTI6MTYwNjEzMTAwMjgzNDpkaXZ5YXNhcmF2YW5hbjozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTIxLTA2NTU6NTE6NTE=
* @ValidationInfo : Timestamp         : 23 Nov 2020 17:00:02
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : divyasaravanan
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 51/51 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.NOFILE.AA.INT.ACCR.SUBHEADING(ENQ.DATA)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Program Description </desc>
**
* Conversion routine to return accrual id list
*
* @uses I_ENQUIRY.COMMON I_F.AA.ARRANGEMENT
* @package AA.ModelBank
* @stereotype subroutine
* @author divyasaravanan@temenos.com
*
**

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*
* 20/11/20 - Task : 4092320
*            Enhancement : 4086150
*            Conversion routine to return accrual id list
*
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Inserts>
***
   
    $USING EB.Reports
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING EB.SystemTables

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>
    GOSUB Initialise
    GOSUB MainProcess

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
Initialise:
*----------

    ENQ.DATA = ''

    LOCATE "ARRANGEMENT.ID" IN EB.Reports.getEnqSelection()<2,1> SETTING ID.POS THEN
        ArrangementId = EB.Reports.getEnqSelection()<4,ID.POS>
    END
    LOCATE "PARTICIPANT.ID" IN EB.Reports.getEnqSelection()<2,1> SETTING ID.POS THEN
        ParticipantId = EB.Reports.getEnqSelection()<4,ID.POS>
    END
    LOCATE "SKIM.FLAG" IN EB.Reports.getEnqSelection()<2,1> SETTING ID.POS THEN
        SkimFlag = EB.Reports.getEnqSelection()<4,ID.POS>
    END

    TodayDate = EB.SystemTables.getToday()

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
*** <desc>Main control logic in the sub-routine</desc>
MainProcess:
*------------

* Get arrangement record
    RArrangement = ''
    RetError = ''
    AA.Framework.GetArrangement(ArrangementId, RArrangement, RetError)
    
    ProductLine = RArrangement<AA.Framework.Arrangement.ArrProductLine> ;* Fetch product line
    
    GOSUB GetInterestProperties ;* To get the interest properties for the arrangement
    
    PropertyCount = DCOUNT(InterestProperties,@VM) ;* Get total number of Interest properties

*Loop each interestproperty and form ACCRUAL.ID.LIST
    
    FOR PropertyCnt = 1 TO PropertyCount
        BEGIN CASE
            CASE SkimFlag
                AccrualIdList<1,-1> = ArrangementId:'-':InterestProperties<1,PropertyCnt>:'--':ParticipantId:'-SKIM'
            CASE ParticipantId
                AccrualIdList<1,-1> = ArrangementId:'-':InterestProperties<1,PropertyCnt>:'--':ParticipantId
            CASE 1
                AccrualIdList<1,-1> = ArrangementId:'-':InterestProperties<1,PropertyCnt>
        END CASE
    
    NEXT  PropertyCnt

    ReturnData = ProductLine:'*':AccrualIdList

    ENQ.DATA<-1> = ReturnData
    
RETURN
*** </region>
***-----------------------------------------------------------------------------
*** <region name= Get Int Properties>
*** <desc> Get then INTEREST property name list</desc>
GetInterestProperties:

* Get the property list for the arrangement
    InterestProperties = ''
    PropertyList = ''
    AA.Framework.GetArrangementProduct(ArrangementId, TodayDate, RArrangement, '', PropertyList)

* Get property class list for the given property list
    PropertyClassList = ''
    AA.ProductFramework.GetPropertyClass(PropertyList, PropertyClassList)

    LoopExitFlag = "1" ;* Flag to indicate INTERET property class

    LOOP
    WHILE LoopExitFlag  ;* Exit the loop if "INTEREST" property class not found in property class list
        LOCATE 'INTEREST' IN PropertyClassList<1, 1> SETTING PropPos THEN
            InterestProperties<1,-1> = PropertyList<1, PropPos> ;* Get the property name for "INTEREST" property class
            PropertyClassList<1,PropPos> = '' ;* Remove the property class from property class list once get the property name
            PropertyClassList = PropertyClassList  ;* Reassign the property class list
        END ELSE
            LoopExitFlag = ""  ;* "INTEREST" property class not found in property class list
        END
    REPEAT
 
RETURN
*** </region>
*-----------------------------------------------------------------------------
END

