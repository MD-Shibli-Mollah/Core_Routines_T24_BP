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
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OP.ModelBank
    SUBROUTINE LAUNCH.PROSPECT.SCV
*-----------------------------------------------------------------------------

* Version level routine attached to EB.CHECK.DOCUMENT,LEN.PROSPECT
* COS will be launched when the version record is committed

*----------------------------------------------------------------------------------------------
* Modification History

* 2012/03/15 - Defect - 362684 / Task - 371558
*                                Composite Screen "CUSTOMER.OVERVIEW.PROS" is replaced with the
*                                composite screen "CUSTOMER.OVERVIEW.PROSPECT".

*-----------------------------------------------------------------------------------------------

    $USING OP.ModelBank
    $USING EB.Browser
    $USING EB.API
    $USING EB.SystemTables


    IF EB.SystemTables.getRNew(OP.ModelBank.EbCheckDocument.EbCheFivSixCustomer) THEN
        VAR.VAL = EB.SystemTables.getRNew(OP.ModelBank.EbCheckDocument.EbCheFivSixCustomer)
        EB.Browser.SystemSetvariable('CURRENT.CUSTOMER',VAR.VAL)    ;* To set Current customer from the CUSTOMER field
        EB.SystemTables.setRNew(OP.ModelBank.EbCheckDocument.EbCheFivSixCustomer, VAR.VAL)
        NEXT.TASK = "COS CUSTOMER.OVERVIEW.PROSPECT ":EB.SystemTables.getRNew(OP.ModelBank.EbCheckDocument.EbCheFivSixCustomer)  ;*To store COS in the Variable
        EB.API.SetNextTask(NEXT.TASK)          ;*To launch the COS
    END

    RETURN
    END
