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
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
      $PACKAGE LC.ModelBank

    SUBROUTINE DAS.SWIFT.IN.LIST(THE.LIST,THE.ARGS,TABLE.SUFFIX)

*-----------------------------------------------------------------------------
*    Data Access Servive for SWIFT.IN.LIST
*    Implements the query definition for all queries that can be used against
*    the SWIFT.IN.LIST table.
*    The method signature must remain:
*    THE.LIST, THE.ARGS, TABLE.SUFFIX
*    where
*    THE.LIST     - Passes in the name of the query and is held in MY.CMD. Returns the ley list.
*    THE.ARGS     - Variable parts of selection data, normally field delimited.
*    TABLE.SUFFIX - $NAU, $HIS or blank. Used to access non-live tables.
* -----------------------------------------------------------------------------
** <region name= Modification History>
** <desc> Modification History </desc>

Modifications:
*--------------
*
* 10/11/10 - TASK: 96941
*            Introduction of DAS
*            REF: 33493
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.SWIFT.IN.LIST
    $INSERT I_DAS.SWIFT.IN.LIST.NOTES
    $INSERT I_DAS


*===========
BUILD.DATA:
*===========

    MY.TABLE = "SWIFT.IN.LIST": TABLE.SUFFIX
*
    BEGIN CASE

    CASE MY.CMD = DAS$ALL.IDS ;* Standard; returns all keys

    CASE OTHERWISE
        ERROR.MSG = "UNKNOWN.QUERY"

    END CASE

    RETURN

END
