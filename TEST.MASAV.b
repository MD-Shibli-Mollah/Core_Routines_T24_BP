* @ValidationCode : Mjo4NDkyNzYyMzc6Q3AxMjUyOjE1NjI3NjM1NDAzMzY6bmFuZGhpbmlzaXZhOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDUzMS0wMzE0Oi0xOi0x
* @ValidationInfo : Timestamp         : 10 Jul 2019 18:29:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nandhinisiva
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*10/07/2019- Task 3222476: Task removing $using
*-----------------------------------------------------------------------------
$PACKAGE PPMASV.Foundation
SUBROUTINE TEST.MASAV(ddItemId, DdItemRecord, ioMessage, reserved1, reserved2, reserved3)
        
ioMessage<205> = 'MASAVDDI'   ;* DdiRemittanceInfo

RETURN
END
