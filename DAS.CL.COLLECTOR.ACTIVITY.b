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
* <Rating>-14</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CL.Contract
    SUBROUTINE DAS.CL.COLLECTOR.ACTIVITY(THE.LIST, THE.ARGS, TABLE.SUFFIX)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*** <doc>
* 
* Routine will select CL Collector Activity table
* @author johnson@temenos.com
* @stereotype template
* @uses 
* @uses 
* @package retaillending.CL
*
*** </doc> 
*** </region>

*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History :
*-----------------------
* 11/04/14 -  ENHANCEMENT - 908020 /Task - 988392
*          -  Loan Collection process
*** </region>

*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
*
* Input :
*
* THE.LIST     - Passes in the name of the query and is held in MY.CMD. Returns the ley list.
* THE.ARGS     - Variable parts of selection data, normally field delimited.
* TABLE.SUFFIX - $NAU, $HIS or blank. Used to access non-live tables.
* 
* Output
*
* 
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts Section>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.CL.COLLECTOR.ACTIVITY
    $INSERT I_DAS.CL.COLLECTOR.ACTIVITY.NOTES
    $INSERT I_DAS
    
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Build Data's>
*** <desc>Main control logic</desc>

BUILD.DATA:
    MY.TABLE = 'CL.COLLECTOR.ACTIVITY' : TABLE.SUFFIX
*
    BEGIN CASE
    CASE MY.CMD = dasAllIds   ;* Standard; returns all keys
    CASE MY.CMD = dasClCollector$COLL.ID          ;* Explanation
        MY.FIELDS = 'COLLECTOR.ID'      ;* Must be a valid field
        MY.OPERANDS = 'EQ'    ;* As per ENQUIRY (e.g. LK not LIKE)
        MY.DATA = THE.ARGS<1> ;* The data part
        MY.JOINS = ''         ;* AND / OR
    CASE OTHERWISE
        ERROR.MSG = 'UNKNOWN.QUERY'
    END CASE
    RETURN
    
*** </region>
*-----------------------------------------------------------------------------
END
