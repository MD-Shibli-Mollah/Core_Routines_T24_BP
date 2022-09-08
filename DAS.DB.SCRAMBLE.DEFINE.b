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
    $PACKAGE TK.Foundation
    SUBROUTINE DAS.DB.SCRAMBLE.DEFINE(THE.LIST, THE.ARGS, TABLE.SUFFIX)
*-----------------------------------------------------------------------------
 * Data Access Servive for DB.SCRAMBLE.DEFINE
 * Implements the query definition for all queries that can be used against
 * the DB.SCRAMBLE.DEFINE table.
 * The method signature must remain:
 * THE.LIST, THE.ARGS, TABLE.SUFFIX
 * where
 * THE.LIST     - Passes in the name of the query and is held in MY.CMD. Returns the ley list.
 * THE.ARGS     - Variable parts of selection data, normally field delimited.
 * TABLE.SUFFIX - $NAU, $HIS or blank. Used to access non-live tables.
 *-----------------------------------------------------------------------------
 * Modifications:
 * --------------
 * 28/11/06 - EN_10003119
 *            Creation
 *----------------------------------------------------------------------------
     $INSERT I_COMMON
     $INSERT I_EQUATE
     $INSERT I_DAS.DB.SCRAMBLE.DEFINE
     $INSERT I_DAS.DB.SCRAMBLE.DEFINE.NOTES
     $INSERT I_DAS
 *-----------------------------------------------------------------------------
 BUILD.DATA:
     MY.TABLE = "DB.SCRAMBLE.DEFINE": TABLE.SUFFIX
*
     BEGIN CASE

     CASE MY.CMD = dasAllIds   ;* Standard; returns all keys
 * TODO ADD.TO.CACHE = 1             ; * Only if the item is cacheable


     CASE MY.CMD = dasDbScrambleDefine$ID
         MY.FIELDS = "@ID"
         MY.OPERANDS = "NE"
         ID = THE.ARGS
         MY.DATA = ID
         MY.SORT = "BY @ID"
         ADD.TO.CACHE = 0

     CASE OTHERWISE
         ERROR.MSG = "UNKNOWN.QUERY"

     END CASE

     RETURN
 *-----------------------------------------------------------------------------
 END
