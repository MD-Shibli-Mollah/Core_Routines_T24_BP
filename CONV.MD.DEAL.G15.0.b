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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MD.Contract
      SUBROUTINE CONV.MD.DEAL.G15.0(MD.ID, MD.REC, MD.FILE)

* 22/11/04 - BG_100007655
*            SWIFT 2005 changes for MD application.
*            Conversion routine to add two new fields APPLICABLE.RULE and
*            NARRATIVE and assign 'NONE' to the field APPLICABLE.RULE.
*

$INSERT I_COMMON
$INSERT I_EQUATE

    EQU MD.DEA.APPLICABLE.RULE TO 133, MD.DEA.NARRATIVE TO 134

    IF MD.REC<MD.DEA.APPLICABLE.RULE> = '' THEN
       MD.REC<MD.DEA.APPLICABLE.RULE> = 'NONE'
       MD.REC<MD.DEA.NARRATIVE> = ''
    END

RETURN
END
