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
* <Rating>-46</Rating>
*-----------------------------------------------------------------------------
	$PACKAGE IM.ModelBank
    SUBROUTINE E.SCV.CUST.PHOTO.BUILD(ENQ.DATA)
*
* Subroutine Type : BUILD Routine
* Attached to     : CUST.PHOTO.RTN.SCV
* Attached as     : Build Routine
* Primary Purpose : We need a way of searching a customer based on any products held should
*                   also be able to link the photo of the customer (from IM.DOCUMENT.IMAGE)
* Incoming:
* ---------
*
* Outgoing:
* ---------
*
* Error Variables:
* ----------------
*
*-----------------------------------------------------------------------------
*17/12/13 - Defect 864147 / Task 865393
*           Additional condition has been added to avoid passing the null value.
*
* 13/07/15 - Task 1399837 / Enhancement 1326996
* 			 Incorporation of IM components
*-----------------------------------------------------------------------------
    
    $USING IM.Foundation
    
    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS

    RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:

    LOCATE 'IMAGE.REFERENCE' IN ENQ.DATA<2,1> SETTING CUS.CODE.POS THEN
        Y.CUST.ID = ENQ.DATA<4,CUS.CODE.POS>
        IF Y.CUST.ID THEN
             R.IM.REFERENCE = IM.Foundation.ImReference.Read(Y.CUST.ID, ERR.IM.REF)
            CONVERT @FM TO " " IN R.IM.REFERENCE
* 864147 - Start
* Additional Condition to avoid passing the null value to the selection criteria.
      IF R.IM.REFERENCE THEN
            ENQ.DATA<2,CUS.CODE.POS> = '@ID'
            ENQ.DATA<3,CUS.CODE.POS> = 'EQ'
            ENQ.DATA<4,CUS.CODE.POS> = R.IM.REFERENCE
        END
        END
* 864147 - End    
    END

    RETURN
*-----------------------------------------------------------------------------------
INITIALISE:

    Y.CUST.ID = ''

    RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------
OPEN.FILES:

    RETURN          ;* From OPEN.FILES
*-----------------------------------------------------------------------------------
END
