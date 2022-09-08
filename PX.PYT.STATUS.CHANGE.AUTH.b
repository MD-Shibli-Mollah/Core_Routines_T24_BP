* @ValidationCode : MjoxNjkzNzQzMTAzOkNwMTI1MjoxNTk0NDY2NDIxMzUzOmtoYXJpbmk6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTI3LTA0MzU6LTE6LTE=
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
SUBROUTINE PX.PYT.STATUS.CHANGE.AUTH
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 01/07/2020 - Defect 3780928 / Task 3832287
*              Routine to update PX.PYT.RESOURCE in the same payment authorisation call
*
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING PX.Framework
*-----------------------------------------------------------------------------

    APPLICATION.NAME = EB.SystemTables.getApplication()
    ERR = ''

    BEGIN CASE

        CASE APPLICATION.NAME = "PAYMENT.ORDER"
            GOSUB PO.STATUS.UPDATE

        CASE APPLICATION.NAME = "STANDING.ORDER"
            GOSUB STO.STATUS.UPDATE

    END CASE

    R.PX.PYT.RESOURCE = PX.Framework.PxPytResource.Read(EB.SystemTables.getIdNew(),ERR)
    IF ERR THEN
        RETURN
    END
    R.PX.PYT.RESOURCE<PX.Framework.PxPytResource.PaymentStatus> = PAYMENT.STATUS
    R.PX.PYT.RESOURCE<PX.Framework.PxPytResource.ScaStatus> = SCA.STATUS
    PX.Framework.PxPytResource.Write(EB.SystemTables.getIdNew(),R.PX.PYT.RESOURCE)

RETURN

PO.STATUS.UPDATE:

    PAYMENT.STATUS = "ACSP"
    SCA.STATUS = "finalised"

RETURN

STO.STATUS.UPDATE:

    PAYMENT.STATUS = "ACWP"
    SCA.STATUS = "finalised"

RETURN


END
