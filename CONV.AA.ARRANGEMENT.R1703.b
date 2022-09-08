* @ValidationCode : MjotMzcxMDEwMDQwOkNwMTI1MjoxNTQyMDkwODEwODM1OmpoYWxha3ZpajoxOjA6MDotMTpmYWxzZTpOL0E=
* @ValidationInfo : Timestamp         : 13 Nov 2018 12:03:30
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jhalakvij
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.Framework
SUBROUTINE CONV.AA.ARRANGEMENT.R1703(Id, Record,File)
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
* Conversion Routine to update the correct marker for the AGENT.ID,AGENT.ARR.ID and new field AGENT.ROLE
*
*-----------------------------------------------------------------------------
* @package Retail.AA
* @stereotype subroutine
* @ author rjeevithkumar@temenos.com
*-----------------------------------------------------------------------------
**** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History
*
* 16/01/17 - Enhancement : 1911014
*            Task : 1911021
*            Added multi value set of AGENT.ID,AGENT.ARR.ID and new field AGENT.ROLE
*
* 15/02/18 - Enhancement : 2460883
*            Task   : 2461438
*            New Field Inheritance.property added as part of Other API Changes.
*            Hence Field positions for AGENT.ID,AGENT.ARR.ID and AGENT.ROLE got changed
* 09/11/18 - Defect  :  2839657
*            Task    :  2849961
*            Add new field AGENT.ROLE and get value of AGENT.ID and AGENT.ARR.ID from RECORD(IN/OUT Param of Routine)
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB UPDATE.AGENT.ROLE   ;*add new field AGENT.ROLE
  
RETURN

*-----------------------------------------------------------------------------------

INITIALISE:

    AgcommAgentId = '40'
    AgcommAgentArrId = '41'
    AgcommAgentRole = '42'

    AgentId =Record<AgcommAgentId>
    
    AgentArrId =Record<AgcommAgentArrId>

    Record<AgcommAgentRole>=""


RETURN

*----------------------------------------------------------------------------------------

UPDATE.AGENT.ROLE:
    
    IF AgentId NE '' AND AgentArrId NE ''  THEN ;* agentid and agentarrid field having value then update agent role

        Record<AgcommAgentRole> = "AGENT" ;* By default agent role is AGENT

    END
RETURN
*----------------------------------------------------------------------------------------
END
