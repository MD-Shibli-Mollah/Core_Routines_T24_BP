* @ValidationCode : MjoxMDkxNzA4NDM6Q3AxMjUyOjE2MTUyOTMxODQ0MDU6cmFrc2hhcmE6ODowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMy4yMDIxMDMwMS0wNTU2OjcxOjcx
* @ValidationInfo : Timestamp         : 09 Mar 2021 18:03:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rakshara
* @ValidationInfo : Nb tests success  : 8
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 71/71 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
*-----------------------------------------------------------------------------
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.BUILD.ACCRUAL.DETAILS(ENQ.DATA)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Program Description </desc>
**
* Conversion routine to return interest accrual details for the current period
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
* 05/11/20 - Task : 4062192
*            Enhancement : 3164925
*            Conversion routine to build accrual id list for multiple properties of the arrangement
*
* 11/11/20 - Task : 4076072
*            Enhancement : 3164925
*            Return Accrual id as it is when it is the incoming value
*
* 23/11/20 - Task : 4093276
*            Enhancement : 3164925
*            To get the participant id and arrangement id from @ID and LINKED.ARRANGEMENT respectively from enq.data
*
* 24/11/20 - Task : 4096316
*            Enhancement : 3164925
*            To get only the accrual id of the given property if property name is given
*
* 18/02/21 - Task : 4238705
*            Enhancement : 4184741
*            Send 'ERROR' as ID if selection criteria input is given wrong
*
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Inserts>
***
   
    $USING EB.SystemTables
    $USING AA.Framework
    $USING AA.Interest
    $USING AA.ProductFramework
    
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
  
    TodayDate = EB.SystemTables.getToday()
    
    LOCATE "@ID" IN ENQ.DATA<2,1> SETTING IdPos THEN
        AccrualId = ENQ.DATA<4,IdPos>
    END

    AccrualIdList = ''

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
*** <desc>Main control logic in the sub-routine</desc>
MainProcess:
*------------

    FINDSTR '-' IN AccrualId SETTING Pos THEN
        AccrualIdList = AccrualId ;* Return accrual id as out argument
    END ELSE
        GOSUB GetAccrualIdList ; *To get accrual id list
    END

    IF AccrualIdList THEN
        CHANGE @FM TO " " IN AccrualIdList
        
        LOCATE "@ID" IN ENQ.DATA<2,1> SETTING IdPos THEN
        END
        ENQ.DATA<2,IdPos> = "@ID"
        ENQ.DATA<3,IdPos> = "EQ"
        ENQ.DATA<4,IdPos> = AccrualIdList
    END ELSE
        ENQ.DATA<2,IdPos> = "@ID"
        ENQ.DATA<3,IdPos> = "EQ"
        ENQ.DATA<4,IdPos> = "ERROR"
    END
       
RETURN
*** </region>
***-----------------------------------------------------------------------------
*** <region name= Get Int Properties>
*** <desc> Get then INTEREST property name list</desc>
GetInterestProperties:

* Get arrangement record
    RArrangement = ''
    AA.Framework.GetArrangement(ArrangementId, RArrangement, RetError)

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
*** <region name= GetAccrualIdList>
*** <desc>To get accrual id list </desc>
GetAccrualIdList:
    
    LOCATE "LINKED.ARRANGEMENT" IN ENQ.DATA<2,1> SETTING AccPos THEN
        ArrangementId = ENQ.DATA<4,AccPos>
        DEL ENQ.DATA<2,AccPos>
        DEL ENQ.DATA<3,AccPos>
        DEL ENQ.DATA<4,AccPos>
    END

    ParticipantId = AccrualId

    LOCATE 'PROPERTY.NAME' IN ENQ.DATA<2,1> SETTING PropPos THEN
        InterestProperties = ENQ.DATA<4,PropPos>
        DEL ENQ.DATA<2,PropPos>
        DEL ENQ.DATA<3,PropPos>
        DEL ENQ.DATA<4,PropPos>
    END ELSE
        GOSUB GetInterestProperties ;* To get the interest properties for the arrangement
    END

    PropertyCount = DCOUNT(InterestProperties,@VM) ;* Get total number of Interest properties

*Loop each interestproperty and form ACCRUAL.ID.LIST
    
    FOR PropertyCnt = 1 TO PropertyCount
        BEGIN CASE
            CASE ParticipantId
                AccrualIdList<-1> = ArrangementId:'-':InterestProperties<1,PropertyCnt>:'--':ParticipantId
            CASE 1
                AccrualIdList<-1> = ArrangementId:'-':InterestProperties<1,PropertyCnt>
        END CASE
    
    NEXT  PropertyCnt

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
