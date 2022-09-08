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

*------------------------------------------------------------------------------
* <Rating>-37</Rating>
*------------------------------------------------------------------------------
    $PACKAGE CR.ModelBank
    SUBROUTINE V.TCIB.IM.SHORT.DESC
*------------------------------------------------------------------------------
* This routine is used to append language code for short description
*------------------------------------------------------------------------------
*                        M O D I F I C A T I O N S
*
* 26/06/13 - Enhancement 1007033
*            TCIB CRM Ads - Append language to short description
*------------------------------------------------------------------------------
    $INSERT I_DAS.LANGUAGE

    $USING EB.SystemTables
    $USING IM.Foundation
    $USING EB.DataAccess
    $USING EB.ErrorProcessing


    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*------------------------------------------------------------------------------
INITIALISE:
*---------
* Initialise variables and open files

    F.DOC.IMG = ''

    F.LANGUAGE = ''

    RETURN
*------------------------------------------------------------------------------
PROCESS:
*------
* Check for language mnemonic in short description

    SHORT.DESC = EB.SystemTables.getComi()
    IF EB.SystemTables.getRNew(IM.Foundation.DocumentImage.DocImageApplication) EQ "CR.OPPORTUNITY.DEFINITION"  AND SHORT.DESC THEN
        LANG.MNEM = FIELDS(SHORT.DESC,"_",1)
        GOSUB LANG.DESCRIPTION
    END
    RETURN
*------------------------------------------------------------------------------
LANG.DESCRIPTION:
*---------------
* Call DAS to get list language mnemonic and add it to an array

    THE.LIST = dasLanguageByMnemonic
    THE.ARGS<1> = LANG.MNEM
    EB.DataAccess.Das('LANGUAGE',THE.LIST,THE.ARGS,"")

    IF NOT(THE.LIST) THEN
        EB.SystemTables.setAf(IM.Foundation.DocumentImage.DocShortDescription)
        EB.SystemTables.setEtext("Add language mnemonic at the beginning of short description with _ as separator")
        EB.ErrorProcessing.StoreEndError()
    END
    RETURN
*-------------------------------------------------------------------------------
    END
