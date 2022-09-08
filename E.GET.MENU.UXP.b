* @ValidationCode : MjotNzMxMjU2ODI3OmNwMTI1MjoxNjE1ODk4NDkzMzMyOnByYXZlZW5hcjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDMuMjAyMTAzMDEtMDU1NjotMTotMQ==
* @ValidationInfo : Timestamp         : 16 Mar 2021 18:11:33
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : praveenar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE EB.ModelBank

SUBROUTINE E.GET.MENU.UXP(menuId, xmlMenuResponse)
    
    $USING EB.Browser
    $USING EB.Reports
    $USING EB.Iris
    
    EQUATE PERCENT TO "%"
    EQUATE ESC.PERCENT TO "%25"
*-----------------------------------------------------------------------------
* Routine to return dynamic menu XML for new Browser
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 17/06/2019 Enhancement 2984307 / Task 2984307 UXPB Migration to IR18
* 16/03/2021 Defect 3946300 / Task 3980313 To handle special chars in GET.MENU
*-----------------------------------------------------------------------------

    xmlMenuResponse = ''
* menu id might change after call to OsGetMenu - so, remember the original one for error handling
    tempMenuId = menuId
    EB.Browser.OsGetMenu(menuId, xmlMenuResponse)
    UxpBrowser = ''
    EB.Iris.RpGetIsUxpBrowser(UxpBrowser)   ;* Check if it is UXPB request
    IF UxpBrowser THEN    ;* For UXPB requests, decode the encoded special chars
        xmlMenuResponse = CHANGE( xmlMenuResponse, ESC.PERCENT, PERCENT )
    END
    IF xmlMenuResponse EQ '' THEN
        ebError = 'Invalid menu id: ' : tempMenuId
        EB.Reports.setEnqError(ebError)
        RETURN
    END
    
    CONVERT @FM TO '' IN xmlMenuResponse    ;* Get rid of all the Fms
    
RETURN
END
