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
	$PACKAGE T2.ModelBank
    SUBROUTINE TCIB.GET.DETAILS.MSG
*-----------------------------------------------------------------------------
* Subroutine to get the full message from a EB.SECURE.MESSAGE and returns the
* message by replacing VM with a separator '*'
*-----------------------------------------------------------------------------
* *** <region name= Modification History>
*** <desc>Changes done in the sub-routine </desc>
*
* Modification History:
*---------------------
* 27/06/13 - Enhancement 590517
*            TCIB Retail
* 15/07/15 - Task 1397943 / Defect 1391003
*            Star Sign Displayed instead of Space when Message composed and Viewed
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
*
* 27/11/15 - Minor Enhancement 1466365 / Task 1470950
*	      Truncation issue in Messages section
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts
    $USING EB.ARC
    $USING EB.Reports

*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>

    GOSUB INITIALISE
    GOSUB PROCESS

*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise commons and do OPF </desc>
INITIALISE:
*---------
    MSG.ID = EB.Reports.getOData()
    RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc> Converting the message </desc>
PROCESS:
*------

    R.MSG = EB.ARC.SecureMessage.Read(MSG.ID,MSG.ERR)
    IF NOT(MSG.ERR) THEN
        Y.MSG = R.MSG<EB.ARC.SecureMessage.SmMessage>
        CONVERT @VM TO "|" IN Y.MSG
        EB.Reports.setOData(Y.MSG)
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END
