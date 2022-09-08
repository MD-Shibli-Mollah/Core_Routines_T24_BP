* @ValidationCode : Mjo3MzQyMDcxMjg6Y3AxMjUyOjE1NTAzMjI4NjEwNjk6cmFuamFuYTotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTAxLjIwMTgxMjIzLTAzNTM6LTE6LTE=
* @ValidationInfo : Timestamp         : 16 Feb 2019 18:44:21
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : ranjana
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201901.20181223-0353
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE PP.PaymentFrameworkService
SUBROUTINE TEST.SUB(ddItemId, DdItemRecord, ioMessage, reserved1, reserved2, reserved3)

	ioMessage<205> = 'ACHDDI'   ;* DdiRemittanceInfo
	ioMessage<210> = 'PPD-22'   ;* DdiRemittanceInfo
    ioMessage<211> = "INSDR"   ;* DdiRemittanceInfo
    ioMessage<212> = "CENTRYDC"   ;* DdiRemittanceInfo
    ioMessage<213> = "RETRY PYMT"   ;* DdiRemittanceInfo 
	
RETURN
END
