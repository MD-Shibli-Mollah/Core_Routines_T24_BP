* @ValidationCode : MjotMTg5ODM3MTA5MDpDcDEyNTI6MTU2MTIwODczOTUwNTplc29vcnlhOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNC4yMDE5MDQxMC0wMjM5Oi0xOi0x
* @ValidationInfo : Timestamp         : 22 Jun 2019 18:35:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : esoorya
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201904.20190410-0239
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PPAACH.ClearingFramework
SUBROUTINE PPAACH.SOURCE.API(iFileReceivedSource, iFileHeaderSendingInstitution,oSource,oSourceResponse)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 20/06/2019 - Enhancement / Task
*              Source API to be attached in the PP.MESSAGE.ACCEPTANCE.PARAM
*-----------------------------------------------------------------------------
* When the Source API is called, change the Source to ARGDDI
    oSource = 'ARGDDI'
END
