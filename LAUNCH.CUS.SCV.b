* @ValidationCode : MjotOTEzNjk1MjUxOkNwMTI1MjoxNTYzOTcyMTQ4MDEwOm1oaW5kdW1hdGh5Oi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwOC4yMDE5MDcxNy0wMjU0Oi0xOi0x
* @ValidationInfo : Timestamp         : 24 Jul 2019 18:12:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : mhindumathy
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.20190717-0254
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
$PACKAGE PW.ModelBank
SUBROUTINE LAUNCH.CUS.SCV
*-----------------------------------------------------------------------------

*Version level routine attached to EB.CHECK.DOCUMENT,WELCOME
*COS will be launched when the version record is committed
*-----------------------------------------------------------------------------
* Modification History
*-----------------------------------------------------------------------------
*
* 19/07/19 - Enhancement 2822523
*          - Task 2990408
*          - Componentization - PW.ModelBank
*-----------------------------------------------------------------------------

* Adding insert files
    $USING OP.ModelBank
    $USING EB.SystemTables
    $USING EB.Browser
    $USING EB.API

    IF EB.SystemTables.getRNew(OP.ModelBank.EbCheckDocument.EbCheFivSixCustomer) THEN
        EB.Browser.SystemSetvariable('CURRENT.CUSTOMER',EB.SystemTables.getRNew(OP.ModelBank.EbCheckDocument.EbCheFivSixCustomer))
        NEXT.TASK = "COS CUSTOMER.OVERVIEW.CSM ":EB.SystemTables.getRNew(OP.ModelBank.EbCheckDocument.EbCheFivSixCustomer) ;*To store COS in the Variable
        EB.API.SetNextTask(NEXT.TASK)  ;*To launch the COS
    END

RETURN
