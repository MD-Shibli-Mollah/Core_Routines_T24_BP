* @ValidationCode : MjoxODA4MDY3MzY6Q3AxMjUyOjE1OTgzNDE3NTk0MjE6anViaXR0YWpvaG46NzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOS4yMDIwMDgyMC0xNDE0OjQwOjM4
* @ValidationInfo : Timestamp         : 25 Aug 2020 13:19:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jubittajohn
* @ValidationInfo : Nb tests success  : 7
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 38/40 (95.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200820-1414
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE BX.ModelBank
 
SUBROUTINE E.AA.GET.SDB.BOX.DETAILS(AVAILABLE.BOXES)

*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
*
* This enquiry routine will read the AVAILABLE boxes for given box type.
*
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
*
* Input/Outpu aruguement
*
*@param  Available Boxes         List of available box numbers
*
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
*
*  22/02/2016 - Enhancement : 1033356
*               Task : 1638897
*               Get the available box numbers for given box type.
*
* 22/05/2018 - Enhancement : 2583186
*              Task : 2583189
*              Adding functionality of searching based on branch of the box
*
* 17/09/2018 - Defect : 2764026
*              Task  : 2771617
*              Check if box type is inputted or not and modify select command
*
* 08/07/2019 - Defect : 3204673
*              Task  : 3218153
*              Dropdown on box number field is not showing the available boxes in branch.
*
*  06/09/2019 - Defect : 3312328
*               Task : 3323065
*               Branch code is been loaded in the system user variable
*
*  13/06/2020 - Defect : 3906788
*               Task : 3910587
*               Branch variable is cleared if no branch id is returned by the system user variable
*
*** </region>
*-----------------------------------------------------------------------------

*
*** <region name= Inserts>
*** <desc>Inserts and common variables</desc>
*


    
    $USING AA.Framework
    $USING EB.Reports
    $USING EB.SystemTables
    $USING ST.OrganizationStructure
    $USING EB.Security
    DEFFUN System.getVariable()
    
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Main Control>
*** <desc>Main processing block</desc>

    GOSUB INITIALISE
    GOSUB MAIN.PROCESS
 
RETURN
*** </region>
*--------------------------------------------------------------------------------------------
*
*** <region name= Initialise>
*** <desc> Initialise local variables here</desc>
INITIALISE:
 
    SOURCE.RULE.VALUES = ''   ;* Initialise with Null
    
    Username = EB.SystemTables.getRUser()<EB.Security.User.UseUserName>
    CURRENT = 'CURRENT.':Username:'.BRANCH'
    BRANCH =System.getVariable(CURRENT);*Gets the branch id stored in the user variable
*System.getVariable() returns the value of system user variable passed.If the value of the system user variable is not found in cache,then variable name
*passed as input itself is returned back, else returns the value, branch id in this case.If the BRANCH variable holds the system user variable name,
*then the variable should be set as null for getting the box numbers correctly
    IF BRANCH EQ CURRENT THEN
        BRANCH = ''
    END
    
RETURN
*** </region>
*--------------------------------------------------------------------------------------------
*
*** <region name= Main Process>
*** <desc> Main Processing block</desc>
MAIN.PROCESS:

    LOCATE 'BOX.TYPE' IN EB.Reports.getEnqSelection()<2,1> SETTING SOR.POS THEN
        BOX.TYPE = EB.Reports.getEnqSelection()<4,SOR.POS>
    END
    
    FN.SOURCE.FILE.NAME = 'F.AA.SDB.BOX'
    F.SOURCE.FILE.NAME = ''

    CALL OPF(FN.SOURCE.FILE.NAME, F.SOURCE.FILE.NAME)

    COMPANY.CODE = EB.SystemTables.getIdCompany()
    

    IF BOX.TYPE THEN
        SELECT.CMD = 'SELECT ': FN.SOURCE.FILE.NAME : ' WITH BOX.TYPE EQ ' : BOX.TYPE  : ' AND STATUS EQ AVAILABLE':' AND CO.CODE EQ ' :  COMPANY.CODE:      ;* Select statementE
    END ELSE
        SELECT.CMD = 'SELECT ': FN.SOURCE.FILE.NAME : ' WITH STATUS EQ AVAILABLE':' AND CO.CODE EQ ' :  COMPANY.CODE:      ;* Select statement
    END
    IF BRANCH THEN
        SELECT.CMD := ' WITH @ID LIKE ' :COMPANY.CODE: '-' :BRANCH:'-...'  ;* Search with the branch
    END ELSE
        SELECT.CMD := ' WITH @ID UNLIKE ' :COMPANY.CODE: '-...-...'          ;* Search with the company alone
    END
*** Execute select stament and get the records

    CALL EB.READLIST(SELECT.CMD, ALL.BOXES, '', '', RET.ERROR)

    NO.BOXES = DCOUNT(ALL.BOXES, @FM)

    FOR BOX.NO = 1 TO NO.BOXES
        
        IF BRANCH THEN                                          ;* If branch is specified we need only the records which have branch, the JQL should take care of that.
            ACT.BOX.NO = FIELDS(ALL.BOXES<BOX.NO> , '-' , 3, 1) ;* With branch, box number is the 3rd component
        END ELSE                                                ;* If branch is not specified we need only those records with don't have branch, the JQL should take care of that.
            ACT.BOX.NO = FIELDS(ALL.BOXES<BOX.NO> , '-' , 2, 1) ;* Witout branch, box number is the 2nd component
        END
 
        AVAILABLE.BOXES<-1> = ACT.BOX.NO
            
    NEXT BOX.NO

RETURN
*** </region>
*------------------------------------------------------------------------------------------
END
