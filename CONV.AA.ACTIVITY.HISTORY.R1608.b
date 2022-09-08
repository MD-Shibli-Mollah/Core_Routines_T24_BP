* @ValidationCode : MToxODc1NDM5OTUwOklTTy04ODU5LTE6MTQ3MTIzOTk1OTg2NzpqaGFsYWt2aWo6MTowOjA6LTE6ZmFsc2U6Ti9B
* @ValidationInfo : Timestamp         : 15 Aug 2016 11:15:59
* @ValidationInfo : Encoding          : ISO-8859-1
* @ValidationInfo : User Name         : jhalakvij
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
	$PACKAGE AA.Framework
    SUBROUTINE CONV.AA.ACTIVITY.HISTORY.R1608(Id, Record,File)

*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
* Conversion Routine to update the correct marker for the new field TRANS.INFO
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
* 25/07/16 - Enhancement : 1791929
*            Task : 1791925
*            New field added TRANS.INFO into activity history
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

	AhActivityRef = '26'	;* Activity reference
	AhTransInfo = '27'	;* Transaction Initation Type
	
*** Activity reference field having exact values seprated by corresponding markers
    ActivityReferences = Record<AhActivityRef>   ;* AAA1^AAA2]AAA3
	TransInfo	= ""    ;* Assume the contarct id value as null
	
*** concat empty value with the activity reference seprated by '-'
	MergedFieldValue = SPLICE(ActivityReferences,"-",REUSE(TransInfo))   ;* AAA1-^AAA2-]AAA3-

*** Splite the merged values by "-" and get the second position of the string
	TransInfos = FIELDS(MergedFieldValue,"-",2)   ;* ^]
	
    Record<AhTransInfo> =  TransInfos   ;* Got the marker and update!
    
    RETURN
*** </region>
*---------------------------------------------------------------------------------
    END

