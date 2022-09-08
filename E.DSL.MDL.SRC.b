* @ValidationCode : MjoxODE0NDY2ODI2OkNwMTI1MjoxNTM3MTcyODI5NTY4OnJlbGFuZ286LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgwOS4yMDE4MDgyMS0wMjI0Oi0xOi0x
* @ValidationInfo : Timestamp         : 17 Sep 2018 13:57:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : relango
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201809.20180821-0224
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE EB.SystemTables
SUBROUTINE E.DSL.MDL.SRC (Ids)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
* 17/09/2018 - Task : 2757231 / Defect 2755156
*              Retrieve only the source releases from DSL.MODEL.SOURCE
*-----------------------------------------------------------------------------
    $USING EB.DataAccess
    $USING EB.SystemTables
*-----------------------------------------------------------------------------

* Open files:
    Ids = ""
    fnDSLMdlSrc = "F.DSL.MODEL.SOURCE"
    fDSLMdlSrc = ""
    EB.DataAccess.Opf(fnDSLMdlSrc:@FM:"NO.FATAL.ERROR", fDSLMdlSrc)
    
    IF EB.SystemTables.getEtext() THEN      ;* If Error , Return
        RETURN
    END
* Select from DB:
    SelectStatement = "SELECT ":fnDSLMdlSrc:" SAVING UNIQUE SOURCE.RELEASE"
    KeyList = ""
    Selected = ""
    EB.DataAccess.Readlist(SelectStatement, KeyList, "", Selected, "")      ;* Get the list of files in DSL.MODEL.SOURCe
    
    Ids = KeyList       ;* Parse the values to the argument

RETURN
END
