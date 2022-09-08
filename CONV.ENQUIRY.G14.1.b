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
* <Rating>196</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE CONV.ENQUIRY.G14.1(Y.ID,Y.ENQUIRY.REC,Y.FILE)
*
* This is the record.routine for the conversion record CONV.ENQUIRY.G14.1
* This counts the number of selection fields and correspondingly blanks out
* the newly added field in the begining of the multi value set.
*
* Arguments:
* ---------
* Y.ID - Id of the Enquiry Record
* Y.ENQUIRY.REC - Enquiry Record
* Y.FILE - File Pointer of the Enquiry file
*
* Modifications:
* -------------
*
* 21/10/05 - CI_10035904
*            Creation
*---------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE

    SELECTION.FLDS = Y.ENQUIRY.REC<6>   ;* No of selection fields

    NO.OF.SELECTION.FLDS = DCOUNT(SELECTION.FLDS,VM)        ;* Count of no.of.fields
    FOR I = 1 TO NO.OF.SELECTION.FLDS
        IF Y.ENQUIRY.REC<5,I> = '' THEN Y.ENQUIRY.REC<5,I> = ''       ;* If no value then force a NULL
        IF Y.ENQUIRY.REC<11,I> = '' THEN Y.ENQUIRY.REC<11,I> = ''     ;* If no value then force a NULL
    NEXT I

    RETURN
END
