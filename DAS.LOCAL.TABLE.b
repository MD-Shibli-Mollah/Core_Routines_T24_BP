* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-11</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.LocalReferences
    
    SUBROUTINE DAS.LOCAL.TABLE(THE.LIST, THE.ARGS, TABLE.SUFFIX)
*-----------------------------------------------------------------------------
* Modification History:
*
* 11/11/10 - TASK: 96941
*            Introduction of DAS
*            REF: 33493
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.LOCAL.TABLE
    $INSERT I_DAS.LOCAL.TABLE.NOTES
    $INSERT I_DAS
*-----------------------------------------------------------------------------
*** <region name= BUILD.DATA>
BUILD.DATA:
***
    MY.TABLE = 'LOCAL.TABLE' : TABLE.SUFFIX

    BEGIN CASE
    CASE MY.CMD = DAS$ALL.IDS ;* Standard to return all keys
    CASE MY.CMD = dasLocalTableShortName      
        MY.FIELDS = 'SHORT.NAME'
        MY.OPERANDS = 'EQ'
        MY.DATA = THE.ARGS<1>
    CASE OTHERWISE
        ERROR.MSG = 'UNKNOWN.QUERY'
    END CASE
    RETURN
*** </region>
*-----------------------------------------------------------------------------
END
