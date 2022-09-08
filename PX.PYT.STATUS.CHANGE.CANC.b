* @ValidationCode : MjotNjk4MjY1NzQ2OkNwMTI1MjoxNTk0NDY2NDIxMzUzOmtoYXJpbmk6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTI3LTA0MzU6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Jul 2020 16:50:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kharini
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PX.Framework
SUBROUTINE PX.PYT.STATUS.CHANGE.CANC
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 01/07/2020 - Defect 3780928 / Task 3832287
*              Routine to update PX.PYT.RESOURCE in the same payment cancellation call
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING PX.Framework
*-----------------------------------------------------------------------------
    
    ERR = ''
    R.PX.PYT.RESOURCE = PX.Framework.PxPytResource.Read(EB.SystemTables.getIdNew(),ERR)
    IF ERR THEN
        RETURN
    END
    R.PX.PYT.RESOURCE<PX.Framework.PxPytResource.PaymentStatus> = "CANC"
    R.PX.PYT.RESOURCE<PX.Framework.PxPytResource.ScaStatus> = "finalised"
    PX.Framework.PxPytResource.Write(EB.SystemTables.getIdNew(),R.PX.PYT.RESOURCE)

RETURN

END
