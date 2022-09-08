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
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
	$PACKAGE AA.Framework
    SUBROUTINE CONV.AA.ACTIVITY.HISTORY.R1605(Id, Record,File)

*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
* Conversion Routine to update the correct marker for the new field TRANSACTION.INITATION
*
*-----------------------------------------------------------------------------
* @package Retail.AA
* @stereotype subroutine
* @ author hariprasath@temenos.com
*-----------------------------------------------------------------------------
**** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History
*
* 18/02/16 - Enhancement : 1224667
*			 Task : 1636091
*            New field TRANSACTION.INITATION initation added
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts


*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Store the org system date as effective date</desc>

	AhActivityRef = '2'	;* Activity reference
	AhContractId = '10'	;* Transaction Initation Type
	
*** Activity reference field having exact values seprated by corresponding markers
    ActivityReferences = Record<AhActivityRef>   ;* AAA1^AAA2]AAA3
	ContractId	= ""    ;* Assume the contarct id value as null
	
*** concat empty value with the activity reference seprated by '-'
	MergedFieldValue = SPLICE(ActivityReferences,"-",REUSE(ContractId))   ;* AAA1-^AAA2-]AAA3-

*** Splite the merged values by "-" and get the second position of the string
	ContractIds = FIELDS(MergedFieldValue,"-",2)   ;* ^]
	
    Record<AhContractId> =  ContractIds   ;* Got the marker and update!
    
    RETURN
*** </region>
*---------------------------------------------------------------------------------
    END

