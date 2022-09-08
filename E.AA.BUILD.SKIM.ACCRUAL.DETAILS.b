* @ValidationCode : MjoyMDEyMjA0NDI0OkNwMTI1MjoxNjA2Mjc5Njc2ODA5OmRpdnlhc2FyYXZhbmFuOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjEtMDY1NTo1Mzo1Mw==
* @ValidationInfo : Timestamp         : 25 Nov 2020 10:17:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : divyasaravanan
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 53/53 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.BUILD.SKIM.ACCRUAL.DETAILS(ENQ.DATA)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Program Description </desc>
**
* Conversion routine to build Skim interest accrual details for the given participant id
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
* 05/11/20 - Task : 4065402
*            Enhancement : 3164925
*            Conversion routine to build skim accrual details of given participant id
*
* 12/11/20 - Task : 4077933
*            Enhancement : 3164925
*            To also return the skim accrual id for participant directly
*
* 23/11/20 - Task : 4093276
*            Enhancement : 3164925
*            To get the participant id and arrangement id from @ID and LINKED.ARRANGEMENT respectively from enq.data
*
* 24/11/20 - Task : 4096316
*            Enhancement : 3164925
*            To get only the accrual id of the given property if property name is given
*
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Inserts>
***
  
    $USING AA.Framework
    $USING AA.Participant
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
    END

 
RETURN
*** </region>
***-----------------------------------------------------------------------------
*** <region name= Get Int Properties>
*** <desc> Get then INTEREST property name list</desc>
GetInterestSkimProperties:
    
* Get the Participant property record
    RParticipant = ''
    RetError = ''
    AA.Framework.GetArrangementConditions(ArrangementId, 'PARTICIPANT', "", TodayDate, "", RParticipant, RetError)
    RParticipant = RAISE(RParticipant)
    
    ParticipantList = RParticipant<AA.Participant.Participant.PrtParticipant> ;* Get the participants
    SkimProperties = RParticipant<AA.Participant.Participant.PrtSkimProperty> ;* Get Skim properties
    
    LOCATE ParticipantId IN ParticipantList<1,1> SETTING PartPos THEN
        PartSkimProperties = SkimProperties<1,PartPos> ;* Get the skim properties for the given participant id
    END

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
        PartSkimProperties = ENQ.DATA<4,PropPos>
        DEL ENQ.DATA<2,PropPos>
        DEL ENQ.DATA<3,PropPos>
        DEL ENQ.DATA<4,PropPos>
    END ELSE
        GOSUB GetInterestSkimProperties ;* To get the interest properties for the arrangement
    END

    PropertyCount = DCOUNT(PartSkimProperties,@SM) ;* Get total number of Interest properties

*Loop each interestproperty and form ACCRUAL.ID.LIST
    
    FOR PropertyCnt = 1 TO PropertyCount
        AccrualIdList<-1> = ArrangementId:'-':PartSkimProperties<1,1,PropertyCnt>:'--':ParticipantId:'-SKIM'
    NEXT  PropertyCnt

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
