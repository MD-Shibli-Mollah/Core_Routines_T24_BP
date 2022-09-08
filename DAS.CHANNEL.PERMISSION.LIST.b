* @ValidationCode : MjoyMTQ1NDUyODk5OkNwMTI1MjoxNTExODgyODA2OTM2OnNhbnRvc2hwcmFzYWQ6LTE6LTE6MDotMTp0cnVlOk4vQTpERVZfMjAxNzEyLjIwMTcxMTE5LTAxMjQ6LTE6LTE=
* @ValidationInfo : Timestamp         : 28 Nov 2017 20:56:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : santoshprasad
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : DEV_201712.20171119-0124
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-11</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.ARC
SUBROUTINE DAS.CHANNEL.PERMISSION.LIST(THE.LIST, THE.ARGS, TABLE.SUFFIX)
*-----------------------------------------------------------------------------
* Data Access Servive for CHANNEL.PERMISSION.LIST
* Implements the query definition for all queries that can be used against
* the CHANNEL.PERMISSION.LIST table.
* The method signature must remain:
* THE.LIST, THE.ARGS, TABLE.SUFFIX
* where
* THE.LIST     - Passes in the name of the query and is held in MY.CMD. Returns the ley list.
* THE.ARGS     - Variable parts of selection data, normally field delimited.
* TABLE.SUFFIX - $NAU, $HIS or blank. Used to access non-live tables.
*-----------------------------------------------------------------------------
* Modification History:
* 18/05/15 - Enhancement - 1226758 / Task: 1347374
*            Create and update account groups based on channel permission
*
* 27/11/2017 - Defect - 2352995 / Task: 2360216
*              Remove the cache read for updated channel permission accounts.
* -------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.CHANNEL.PERMISSION.LIST.NOTES
    $INSERT I_DAS.CHANNEL.PERMISSION.LIST
    $INSERT I_DAS
*-----------------------------------------------------------------------------
BUILD.DATA:
    MY.TABLE = 'CHANNEL.PERMISSION.LIST' : TABLE.SUFFIX
*
    BEGIN CASE
        CASE MY.CMD = dasAllIds   ;* Standard; returns all keys
    END CASE
RETURN
*------------------------------------------------------------------------------
END
