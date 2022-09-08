* @ValidationCode : MjoxMzI2NzkzODI1OkNwMTI1MjoxNTE4NTExNDQ4MjMwOnZwZGlsaXBrdW1hcjoxOjA6LTE0Oi0xOmZhbHNlOk4vQTpERVZfMjAxODAxLjIwMTcxMjIzLTAxNTE6Njo2
* @ValidationInfo : Timestamp         : 13 Feb 2018 14:14:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vpdilipkumar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : -14
* @ValidationInfo : Coverage          : 6/6 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201801.20171223-0151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-26</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LC.Channels
SUBROUTINE V.TC.LC.ADV.TEXT.CHK
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* To reset the narrative field for input operation
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Check record routine
* Attached To        : Version > LC.ADVICE.TEXT,TC
* IN Parameters      : NIL
* Out Parameters     : NIL
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 11/01/2018  - Enhancement 2389785 / Task 2389788
*             TCIB2.0 Corporate - Advanced Functional Components - Letter of credit
*---------------------------------------------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine. </desc>
* Inserts

    $USING LC.Channels
    $USING EB.SystemTables
    $USING LC.Config
    
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= MAIN PROCESSING>
*** <desc>Main processing </desc>

    GOSUB PROCESS

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
*** <region name= PROCESS>
*** <desc>This has the main processing logic to reset the narrative field. </desc>
PROCESS:
*------
    IF EB.SystemTables.getRNew(LC.Config.AdviceText.TfAdNarrative) NE '' AND EB.SystemTables.getVFunction() EQ 'I' THEN ;*Check if a value in Narrative field exist when user opens a record in 'I' mode
        EB.SystemTables.setRNew(LC.Config.AdviceText.TfAdNarrative, '') ;*Clear the Narrative field data
    END
    
RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------
END
