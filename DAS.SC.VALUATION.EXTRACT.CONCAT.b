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
    $PACKAGE AM.ValuationUpdates
    SUBROUTINE DAS.SC.VALUATION.EXTRACT.CONCAT(THE.LIST, THE.ARGS, TABLE.SUFFIX)
*-----------------------------------------------------------------------------
* Data Access Servive for SC.VALUATION.EXTRACT.CONCAT
* Implements the query definition for all queries that can be used against
* the SC.VALUATION.EXTRACT.CONCAT table.
* The method signature must remain:
* THE.LIST, THE.ARGS, TABLE.SUFFIX
* where
* THE.LIST     - Passes in the name of the query and is held in MY.CMD. Returns the ley list.
* THE.ARGS     - Variable parts of selection data, normally field delimited.
* TABLE.SUFFIX - $NAU, $HIS or blank. Used to access non-live tables.
*-----------------------------------------------------------------------------
* Modifications:
* --------------
*----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.SC.VALUATION.EXTRACT.CONCAT
    $INSERT I_DAS.SC.VALUATION.EXTRACT.CONCAT.NOTES
    $INSERT I_DAS
*-----------------------------------------------------------------------------
BUILD.DATA:
    MY.TABLE = "SC.VALUATION.EXTRACT.CONCAT": TABLE.SUFFIX
*
    BEGIN CASE

    CASE MY.CMD = dasAllIds   ;* Standard; returns all keys
* TODO ADD.TO.CACHE = 1             ; * Only if the item is cacheable


    CASE MY.CMD = dasScValuationExtractConcatMatchingId
        MY.FIELDS = "@ID"
        MY.OPERANDS = "LK"
        GIVEN.ID = THE.ARGS:dasWildcard
        MY.DATA = GIVEN.ID
        ADD.TO.CACHE = 0

    CASE OTHERWISE
        ERROR.MSG = "UNKNOWN.QUERY"

    END CASE

    RETURN
*-----------------------------------------------------------------------------
END
