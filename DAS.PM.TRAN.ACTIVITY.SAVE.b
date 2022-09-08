* @ValidationCode : MjotMTM4NTU0NjMzMTpDcDEyNTI6MTUxNjcwMTg2NTE0NDphYXJ0aGlhOi0xOi0xOjA6LTE6dHJ1ZTpOL0E6REVWXzIwMTgwMS4wOi0xOi0x
* @ValidationInfo : Timestamp         : 23 Jan 2018 15:34:25
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : aarthia
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : DEV_201801.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE PM.Engine
SUBROUTINE DAS.PM.TRAN.ACTIVITY.SAVE(THE.LIST, THE.ARGS, TABLE.SUFFIX)
*-----------------------------------------------------------------------------
* Data Access Servive for PM.TRAN.ACTIVITY.SAVE
* Implements the query definition for all queries that can be used against
* the PM.TRAN.ACTIVITY.SAVE table.
* The method signature must remain:
* THE.LIST, THE.ARGS, TABLE.SUFFIX
* where
* THE.LIST     - Passes in the name of the query and is held in MY.CMD. Returns the ley list.
* THE.ARGS     - Variable parts of selection data, normally field delimited.
* TABLE.SUFFIX - $NAU, $HIS or blank. Used to access non-live tables.  
*-----------------------------------------------------------------------------
* Modification History :
* ----------------------
* 17/01/18 - Enhancement 2388574 / Task 2388577
*            Swap Performance Improvement - Development #2 - Parameter - PM Selection routines
*
* 23/01/18 - Defect 2433507 / Task 2433769
*            Warning in TAFC compilation
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.PM.TRAN.ACTIVITY.SAVE
    $INSERT I_DAS.PM.TRAN.ACTIVITY.SAVE.NOTES
    $INSERT I_DAS
    
*-----------------------------------------------------------------------------
BUILD.DATA:
    MY.TABLE = 'PM.TRAN.ACTIVITY.SAVE' : TABLE.SUFFIX
*
    BEGIN CASE
        CASE MY.CMD = dasAllIds   ;* Standard; returns all keys
    END CASE
RETURN
*-----------------------------------------------------------------------------
END
