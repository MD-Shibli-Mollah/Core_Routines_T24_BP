* @ValidationCode : MjoxMzE5ODE0ODUxOkNwMTI1MjoxNjE1NDQ2NTU1MTg0Om1hbmlydWRoOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDMuMjAyMTAzMDUtMDYzNjotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Mar 2021 12:39:15
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : manirudh
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210305-0636
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.Framework 
SUBROUTINE CONV.AA.ARRANGEMENT.ACTIVITY.R1602(YID, R.RECORD, FN.FILE)

*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
* Conversion Routine to update the orginal system date as effective date
*
*-----------------------------------------------------------------------------
** @package Retail.AA
* @stereotype subroutine
* @ author hariprasath@temenos.com
*-----------------------------------------------------------------------------
**** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History
*
* 15/10/12 - Enhancement : 1434844
*			 Task : 1466414
*            Update orginal system date
*
* 28/01/21 - Task : 4201818
*            Def  : 4141251
*            To improve upgrade performance, we are defaulting ORG.SYSTEM.DATE here if it is not set previously
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
    $INSERT I_COMMON
    $INSERT I_EQUATE

    
RETURN
*** </region>
*---------------------------------------------------------------------------------
END
