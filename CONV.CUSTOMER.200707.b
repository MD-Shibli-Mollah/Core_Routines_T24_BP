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
    SUBROUTINE CONV.CUSTOMER.200707(ID,R.REC,YFILE)

* Record routine for the converion CONV.CUSTOMER.200607
* this is to blank out values from the (old) fields
* cr.campaign.definition/cr.campaign.opportunity
*
************************************************************************
* Modification Log:
* =================
*
* 29/02/08 - BG_100017407 / TTS0800821
*            CUSTOMER conversions for R8 have been merged.
*            Move CR.CAMPAIGN.DEFINITION from 75 to 92
*            Move CR.CAMPAIGN.OPPORTUNITY from 76 to 93
************************************************************************
*

    R.REC<92> = ''  ;* blank CR.CAMPAIGN.DEFINITION values
    R.REC<93> = ''  ;* blank CR.CAMPAIGN.OPPORTUNITY

    RETURN
END
