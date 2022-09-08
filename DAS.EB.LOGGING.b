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

*--------------------------------------------------------------------------------------------------
* <Rating>-60</Rating>
*--------------------------------------------------------------------------------------------------
    $PACKAGE EB.Logging
    
    SUBROUTINE DAS.EB.LOGGING(THE.LIST, THE.ARGS, TABLE.SUFFIX)
*--------------------------------------------------------------------------------------------------
* Data Access Service for EB.LOGGING
* Implements the query definition for all queries that can be used against
* the EB.LOGGING table.
* The method signature must remain:
* THE.LIST, THE.ARGS, TABLE.SUFFIX
* where
* THE.LIST     - Passes in the name of the query and is held in MY.CMD. Returns the ley list.
* THE.ARGS     - Variable parts of selection data, normally field delimited.
* TABLE.SUFFIX - $NAU, $HIS or blank. Used to access non-live tables.
*--------------------------------------------------------------------------------------------------
* Modifications:
* -------------
* 08/07/15- Defect 1381689 / Task 1399374			
* 		To extract the record which matches with File upload Id	
*==================================================================================================
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.COMMON
    $INSERT I_DAS.EB.LOGGING
    $INSERT I_DAS.EB.LOGGING.NOTES
    $INSERT I_DAS
*--------------------------------------------------------------------------------------------------
BUILD.DATA:

    MY.TABLE = 'EB.LOGGING' : TABLE.SUFFIX
    BEGIN CASE
    CASE MY.CMD = dasAllIds   ;* Standard; returns all keys



    CASE MY.CMD = dasEbFileLoggingId       ;* Select by RECORD.KEY
        MY.FIELDS = 'RECORD.KEY'           ; * If matches with Record Key
        MY.OPERANDS = 'LIKE'
        MY.DATA =  THE.ARGS<1>:dasWildcard

    CASE OTHERWISE
        ERROR.MSG = 'UNKNOWN.QUERY'

    END CASE

    RETURN
*--------------------------------------------------------------------------------------------------
END
