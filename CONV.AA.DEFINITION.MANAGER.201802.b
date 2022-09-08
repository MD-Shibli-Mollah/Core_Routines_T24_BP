* @ValidationCode : Mjo4NTExNjUwNzQ6Q3AxMjUyOjE1MTU1ODYwMjA4ODk6bHN1bWFuOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MTIuMjAxNzEwMjctMDAyMDotMTotMQ==
* @ValidationInfo : Timestamp         : 10 Jan 2018 17:37:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : lsuman
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201712.20171027-0020
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.ProductManagement
SUBROUTINE CONV.AA.DEFINITION.MANAGER.201802(DEFINITION.MANAGER.ID, DEFINITION.MANAGER.RECORD, DEFINITION.MANAGER.FILE)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
*
*  Renaming ConditionClassType,Reserved10,Reserved9,Reserved9,Reserved7 as
*  Reserved15,CommonClassType,CommonClass,CommonClassCondition,CommonConditionVersion
*
*** </region>
*-----------------------------------------------------------------------------
* @author   : lsuman@temenos.com
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
* @param DefinitionManagerId      - Definition Manager ID
* @param DefinitionManagerRecord  - Definition Manger record for the incoming id
* @param DefinitionManagerFile    - AA.DEFINITION.MANAGER file
*
* Output
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
*
* 12/12/17 - Task : 2337793
*            Enhancement : 2337790
*            Renaming ConditionClassType,Reserved10,Reserved9,Reserved9,Reserved7 as
*            Reserved15,CommonClassType,CommonClass,CommonClassCondition,CommonConditionVersion
*
*-----------------------------------------------------------------------------
*** </region>
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
    
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Process Logic>

    GOSUB INITIALISE
    GOSUB UPDATE.NEW.FIELDS
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initialise</desc>
INITIALISE:
    
    COMMON.CLASS.TYPES = ""
    COMMON.CLASS = ""
    COMMON.CONDITIONS = ""
    COMMON.CONDITION.VERSIONS = ""
    
    R.AA.DEFINITION.MANAGER = DEFINITION.MANAGER.RECORD
        
    CONDITION.CLASS.TYPES = R.AA.DEFINITION.MANAGER<6> ;* Condition Class Type
    CLASSES = R.AA.DEFINITION.MANAGER<4> ;* Class
    CONDITIONS = R.AA.DEFINITION.MANAGER<11> ;* Condition
    CONDITION.VERSIONS = R.AA.DEFINITION.MANAGER<12> ;* Condition Version

    TOTAL.CONDITION.CLASS = DCOUNT(CLASSES, @VM)
    IF TOTAL.CONDITION.CLASS EQ "" THEN
        TOTAL.CONDITION.CLASS = 1
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Update New Fields>
*** <desc> </desc>
UPDATE.NEW.FIELDS:

    FOR CONDITION.CLASS.COUNT = 1 TO TOTAL.CONDITION.CLASS ;* loop through all condition class types
        IF CONDITION.CLASS.TYPES<1, CONDITION.CLASS.COUNT> THEN ;*if condition class type is present, then assign the existing common class type definition to the new fields
            IF COMMON.CLASS.TYPES THEN
                COMMON.CLASS.TYPES := @VM: CONDITION.CLASS.TYPES<1, CONDITION.CLASS.COUNT>
                COMMON.CLASSES := @VM: CLASSES<1, CONDITION.CLASS.COUNT>
                COMMON.CONDITIONS := @VM: CONDITIONS<1, CONDITION.CLASS.COUNT>
                COMMON.CONDITION.VERSIONS := @VM: CONDITION.VERSIONS<1, CONDITION.CLASS.COUNT>
                GOSUB CLEAR.OLD.FIELDS  ;* * Make sure to empty the current position since the values got moved to the new field position
            END ELSE
                COMMON.CLASS.TYPES = CONDITION.CLASS.TYPES<1, CONDITION.CLASS.COUNT>
                COMMON.CLASSES = CLASSES<1, CONDITION.CLASS.COUNT>
                COMMON.CONDITIONS = CONDITIONS<1, CONDITION.CLASS.COUNT>
                COMMON.CONDITION.VERSIONS = CONDITION.VERSIONS<1, CONDITION.CLASS.COUNT>
                GOSUB CLEAR.OLD.FIELDS  ;* * Make sure to empty the current position since the values got moved to the new field position
            END
        END
    NEXT CONDITION.CLASS.COUNT
    
* Update the new field values in the appropriate positions
    R.AA.DEFINITION.MANAGER<13> = COMMON.CLASS.TYPES
    R.AA.DEFINITION.MANAGER<14> = COMMON.CLASSES
    R.AA.DEFINITION.MANAGER<16> = COMMON.CONDITIONS
    R.AA.DEFINITION.MANAGER<17> = COMMON.CONDITION.VERSIONS

* Get the values of ACTION to VERSION.DATE from the previous position and move the them to the current position
    FOR FIELD.COUNT = 18 TO 27
        R.AA.DEFINITION.MANAGER<FIELD.COUNT+10> = R.AA.DEFINITION.MANAGER<FIELD.COUNT>
        R.AA.DEFINITION.MANAGER<FIELD.COUNT> = "" ;*To empty the reserved fields
    NEXT FIELD.COUNT

    DEFINITION.MANAGER.RECORD = R.AA.DEFINITION.MANAGER ;*assign back the updated fields to the record
    
RETURN
*** </region>
*-----------------------------------------------------------------------------*

*** <region name= Clear old Fields>
*** <desc> </desc>
CLEAR.OLD.FIELDS:

    FOR POS = 4 TO 12 ;* deleting the full multi value set containing Condition Class type.
        DEL R.AA.DEFINITION.MANAGER<POS, CONDITION.CLASS.COUNT>
    NEXT POS
 
RETURN
*** </region>
*-----------------------------------------------------------------------------*

END
