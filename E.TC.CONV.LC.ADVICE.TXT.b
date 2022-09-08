* @ValidationCode : MjotMTM1MjkzNTgzOTpDcDEyNTI6MTU0NTAzMDk3MDg5NDp2cGRpbGlwa3VtYXI6MTowOjcxOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTIuMjAxODExMjMtMTMxOToxMzoxMw==
* @ValidationInfo : Timestamp         : 17 Dec 2018 12:46:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vpdilipkumar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : 71
* @ValidationInfo : Coverage          : 13/13 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-39</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LC.Channels
SUBROUTINE E.TC.CONV.LC.ADVICE.TXT
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* Subroutine to get the full Narrative from a LC.ADVICE.TEXT and returns the
* message by replacing SM with a separator ''
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Conversion routine
* Attached To        : Enquiry > TC.LC.ADVICE.TEXT
* IN Parameters      : @ID
* Out Parameters     : NARRATIVE (formatted data)
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 11/01/2018  - Enhancement 2389785 / Task 2389788
*               TCIB2.0 Corporate - Advanced Functional Components - Letter of credit
* 17/12/2018  - Defect 2779909 / Task 2873359
*               Have updated the CONVERT statement to replace SM by a space
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine </desc>
* Inserts

    $USING LC.Channels
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

    Narrative  = '';ErrTxt = '';RLcAdviceText = '' ;*Initialising variables used in this routine
    AdviceTextId = EB.Reports.getOData()  ;*Get the record id

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc> This has the main processing logic to read and format the narrative field. </desc>
PROCESS:
*------
    RLcAdviceText = LC.Config.AdviceText.Read(AdviceTextId,ErrTxt)     ;*Reading the LC Advice text application
    IF NOT(ErrTxt) THEN ;*Check if the read is success
        Narrative = RLcAdviceText<LC.Config.AdviceText.TfAdNarrative> ;*Extract the Narrative field value from LC Advice text record
        CONVERT @SM TO " " IN Narrative ;*Convert the Sub value markers in the field Narrative in to blank
        EB.Reports.setOData(Narrative) ;*Set the converted narrative field value
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
