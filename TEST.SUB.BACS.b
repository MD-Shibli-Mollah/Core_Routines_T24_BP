* @ValidationCode : MjotMTcxODQxMTQ3MjpjcDEyNTI6MTU1MDMyMjg2MTA2MTpyYW5qYW5hOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDEuMjAxODEyMjMtMDM1MzotMTotMQ==
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
SUBROUTINE TEST.SUB.BACS(ddItemId, DdItemRecord, ioMessage, reserved1, reserved2, reserved3)

	ioMessage<205> = 'BACSDDI'   ;* DdiRemittanceInfo
	
RETURN 
END
