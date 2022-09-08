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
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.Customer
    SUBROUTINE CONV.RELATION.R8(RELATION.ID,RELATION.REC,RELATION.FILE)
*-----------------------------------------------------------------------------
* Modification logs:
* ------------------
*
* 16/07/07 - EN_10003427
*             Ref: SAR-2006-12-01-0003
*             Co titular maintenance. Convert RELATION from value marked data to
*            sub value marked data for the language field to accomodate the
*            introduction of value marked reverse relation codes.
*-----------------------------------------------------------------------------

$INSERT I_EQUATE
$INSERT I_COMMON
*
* RELATION.REC<2> = EB.REL.REVERSE.RELATION
* RELATION.REC<3> = EB.REL.REV.REL.DESC
*
* Only process if the relation codes are not multi valued.
*
    NO.VM.IN.REL.CODES  = COUNT(RELATION.REC<2>,VM)
    IF NO.VM.IN.REL.CODES = 0 THEN

        NO.VM  = COUNT(RELATION.REC<3>,VM)
        NO.SVM = COUNT(RELATION.REC<3>,SM)
        *
        * There should be no sub value marks in a record that has not been converted.
        *
        IF NO.VM AND NO.SVM = 0 THEN
            *
            * This record has value marks, convert to sub values.
            *
            CONVERT VM TO SM IN RELATION.REC<3>
        END
        *
    END
    
RETURN
END
