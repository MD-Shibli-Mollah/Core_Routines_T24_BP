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
* <Rating>-39</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.ModelBank
    SUBROUTINE TCIB.GET.DETAILS.LC.ADVICE.TXT
*-----------------------------------------------------------------------------
* Subroutine to get the full Narrative from a LC.ADVICE.TEXT and returns the
* message by replacing VM with a separator '*'
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine </desc>
*
* Modification History:
*---------------------
* 23/09/14 -  Defect - 1116294 / Task 1120594
*             TCIB-Corporate - Connectivity error while editing Standard documents
*
* 14/07/15 - Enhancement 1326996 / Task 1399947
*			 Incorporation of T components
* 
* 05/01/16 - Defect 1589822 / Task 1589878
*	         Componentisation package error
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts

    $USING EB.Reports
    $USING LC.Config

*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise commons and do OPF </desc>
INITIALISE:
*---------

    Y.LC  = ''      ;*Initialising variable
    LC.ERR = '';
    R.LC = '';
    LC.ID = EB.Reports.getOData()  ;*ID of the current record

    RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc> Converting the Narrative </desc>
PROCESS:
*------
    R.LC = LC.Config.AdviceText.Read(LC.ID,LC.ERR)     ;*Reading the LC Advice text application
    IF NOT(LC.ERR) THEN
        Y.LC = R.LC<LC.Config.AdviceText.TfAdNarrative>
        CONVERT @SM TO "" IN Y.LC
        EB.Reports.setOData(Y.LC)
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END
