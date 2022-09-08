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
* <Rating>-12</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.ValuationFrameWork
    SUBROUTINE DAS.AM.VAL.EXTRACT.WRK(THE.LIST, THE.ARGS, TABLE.SUFFIX)
*-----------------------------------------------------------------------------
* Data Access Servive for AM.VAL.EXTRACT.WRK
* Implements the query definition for all queries that can be used against
* the AM.VAL.EXTRACT.WRK table.
* The method signature must remain:
* THE.LIST, THE.ARGS, TABLE.SUFFIX
* where
* THE.LIST     - Passes in the name of the query and is held in MY.CMD. Returns the ley list.
* THE.ARGS     - Variable parts of selection data, normally field delimited.
* TABLE.SUFFIX - $NAU, $HIS or blank. Used to access non-live tables.
*-----------------------------------------------------------------------------
* Modifications:
* --------------
*11/05/09 - GLOBUS_BG_100023550
*            New DAS Select
*
*----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.AM.VAL.EXTRACT.WRK
    $INSERT I_DAS.AM.VAL.EXTRACT.WRK.NOTES
    $INSERT I_DAS
*-----------------------------------------------------------------------------
BUILD.DATA:
    MY.TABLE = "AM.VAL.EXTRACT.WRK": TABLE.SUFFIX
*

    BEGIN CASE

    CASE MY.CMD = dasAllIds   ;* Standard; returns all keys
* TODO ADD.TO.CACHE = 1             ; * Only if the item is cacheable
    CASE MY.CMD = dasAmValExtractWrkAllIdsByGroup
        MY.SORT = "BY GROUP.ORDER"

*GLOBUS_BG_100023550

    CASE MY.CMD = dasAmValExtractWrkByOperator
        MY.FIELDS = "@ID"
        MY.OPERANDS = "LK"
        MY.DATA = THE.ARGS<1>:dasWildcard:THE.ARGS<2>
        MY.SORT = "BY ASSET.TYPE"

*GLOBUS_BG_100023550

    CASE OTHERWISE
        ERROR.MSG = "UNKNOWN.QUERY"

    END CASE

    RETURN
*-----------------------------------------------------------------------------
END
