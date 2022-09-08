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
    $PACKAGE EB.Foundation
    SUBROUTINE DAS.IN2.CONCAT(THE.LIST, THE.ARGS, TABLE.SUFFIX)
*-----------------------------------------------------------------------------
 * Data Access Servive for IN2.CONCAT
 * Implements the query definition for all queries that can be used against
 * the IN2.CONCAT table.
 * The method signature must remain:
 * THE.LIST, THE.ARGS, TABLE.SUFFIX
 * where
 * THE.LIST     - Passes in the name of the query and is held in MY.CMD. Returns the ley list.
 * THE.ARGS     - Variable parts of selection data, normally field delimited.
 * TABLE.SUFFIX - $NAU, $HIS or blank. Used to access non-live tables.
 *-----------------------------------------------------------------------------
 * Modifications:
 * --------------
 * 21/11/06 - EN_10003119
 *            Creation
 *----------------------------------------------------------------------------
     $INSERT I_COMMON
     $INSERT I_EQUATE
     $INSERT I_DAS.IN2.CONCAT
     $INSERT I_DAS.IN2.CONCAT.NOTES
     $INSERT I_DAS
 *-----------------------------------------------------------------------------
 BUILD.DATA:
     MY.TABLE = "IN2.CONCAT": TABLE.SUFFIX
*
     BEGIN CASE

     CASE MY.CMD = dasAllIds   ;* Standard; returns all keys
 * TODO ADD.TO.CACHE = 1             ; * Only if the item is cacheable


     CASE OTHERWISE
         ERROR.MSG = "UNKNOWN.QUERY"

     END CASE

     RETURN
 *-----------------------------------------------------------------------------
 END
