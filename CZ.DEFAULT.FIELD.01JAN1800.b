* @ValidationCode : MjotNjEwOTA5OTQwOkNwMTI1MjoxNTMzNzkxNzA5MzgzOnN2YW1zaWtyaXNobmE6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgwNy4yMDE4MDYyMS0wMjIxOi0xOi0x
* @ValidationInfo : Timestamp         : 09 Aug 2018 10:45:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : svamsikrishna
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201807.20180621-0221
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE CZ.ErasureProcess
SUBROUTINE CZ.DEFAULT.FIELD.01JAN1800(customerId,applicationRecId, eraseOptionId,fieldName,inputFieldValues,outputValues)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 06/07/18 - Defect 2623913/ Task 2665771
*            Obfuscate routine to default the DATE.OF.BIRTH field
*
*-----------------------------------------------------------------------------
    outputValues = '18000101'
RETURN
END

