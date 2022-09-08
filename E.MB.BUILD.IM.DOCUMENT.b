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
	$PACKAGE IM.ModelBank
    SUBROUTINE E.MB.BUILD.IM.DOCUMENT(ENQ.DATA)
*-----------------------------------------------------------------------------
*                            Modification History
* 26/08/13 - Enhancement 681309 / Defect 712122
*
*       This routine is attached to CUSTOMER.DOCUMENT.VIEW and LIMIT.DOCUMENT.VIEW
*       enquiry to suppress the records which are not having upload id. Records
*       which are not uploaded but simply captured the image using IM.DOCUMENT.IMAGE
*       will not have a record IM.DOCUMENT.UPLOAD
*
* 13/07/15 - Task 1399837 / Enhancement 1326996
* 			 Incorporation of IM components
*-----------------------------------------------------------------------------
    $USING IM.Foundation

    GOSUB INIT
    GOSUB PROCESS
    GOSUB FORM.ENQ.DATA

    RETURN
*****
INIT:
*****
    IMAGE.ID = ''

    ENQ.DATA.FIELDS = ENQ.DATA<2>
    ENQ.DATA.OPER = ENQ.DATA<3>
    ENQ.DATA.VALUES = ENQ.DATA<4>

    LOCATE "IMAGE.REFERENCE" IN ENQ.DATA.FIELDS SETTING POS THEN
        IMAGE.ID = ENQ.DATA.VALUES<POS>
    END
    
    THE.LIST = ''
    THE.ARGS = ''
    IM.REF.ERR = ''
    R.IM.REFERENCE = ''
    IM.ID = ''
    IM.DOC.UPLOAD.ERR = ''
    IM.DOC.POS = ''
    R.IM.DOC.UPLOAD = ''
    IM.DOCUMENTS.LIST = ''

    RETURN

********
PROCESS:
********
    IF IMAGE.ID THEN
         R.IM.REFERENCE = IM.Foundation.ImReference.Read(IMAGE.ID, IM.REF.ERR)
        LOOP
            REMOVE IM.ID FROM R.IM.REFERENCE SETTING IM.DOC.POS
        WHILE IM.ID:IM.DOC.POS
        R.IM.DOC.UPLOAD = IM.Foundation.DocumentUpload.Read(IM.ID,IM.DOC.UPLOAD.ERR)
            IF R.IM.DOC.UPLOAD THEN
                IM.DOCUMENTS.LIST<-1> = IM.ID
            END
        REPEAT
    END
    RETURN

**************
FORM.ENQ.DATA:
**************

    CONVERT @FM TO ' ' IN IM.DOCUMENTS.LIST

    ENQ.DATA<2,1> = "@ID"
    ENQ.DATA<3,1> = "EQ"
    ENQ.DATA<4,1> = IM.DOCUMENTS.LIST

    RETURN
***********************************************************************************************
    END
