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
* <Rating>-28</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.Interest
    SUBROUTINE CONV.AA.PRD.DES.INTEREST.201509(REC.ID, PROD.REC, YFILE)


*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
* Record Conversion routine to convert values in RATE.TYPE field in AA.PRD.DES.INTEREST
*
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
*
** Input:
*
** REC.ID   - Record Id
** PROD.REC - AA.PRD.DES.INTERST Record
** YFILE    - File Name
*
*** </region>
*-----------------------------------------------------------------------------



*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History
*
* 18/06/15 - Enhancement - 1277976
*            Task - 1300622
*            Conversion routine to record the value of "REDUCING.RATE", if the RATE.TYPE field is null in current processing interest record. 
*
*** </region>
*-----------------------------------------------------------------------------



*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
INITIALISE:

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main process>
*** <desc>Description for the main process</desc>
PROCESS:

	IF PROD.REC<43> EQ "" THEN
		PROD.REC<43> = "REDUCING.RATE"
    END
        
    RETURN
*** </region>
*-----------------------------------------------------------------------------

    END
