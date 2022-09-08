* @ValidationCode : MjotMjAwMDkwODI5NjpDcDEyNTI6MTU4MzkyMzIxMDc2OTpzaGVyaWZmYXBhcnZlZW46LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMjAwMi4yMDIwMDExNy0yMDI2Oi0xOi0x
* @ValidationInfo : Timestamp         : 11 Mar 2020 16:10:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sheriffaparveen
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.Reports
SUBROUTINE E.SUM
*
*     ENQUIRY SUM
*     ===========
* 07/01/20 - Task 3526419
*            Incorporation of EB.Reports

    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    OData=EB.Reports.getOData()
    
    EB.Reports.setOData(SUM(OData))
RETURN
END
