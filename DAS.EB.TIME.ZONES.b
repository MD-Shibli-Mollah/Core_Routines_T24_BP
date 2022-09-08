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
* <Rating>-14</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE DAS.EB.TIME.ZONES(THE.LIST, THE.ARGS, TABLE.SUFFIX)
*-----------------------------------------------------------------------------
* Data Access Servive for EB.TIME.ZONES
* Implements the query definition for all queries that can be used against
* the EB.FILE.UPLOAD table.
* The method signature must remain:
* THE.LIST, THE.ARGS, TABLE.SUFFIX
* where
* THE.LIST     - Passes in the name of the query and is held in MY.CMD. Returns the ley list.
* THE.ARGS     - Variable parts of selection data, normally field delimited.
* TABLE.SUFFIX - $NAU, $HIS or blank. Used to access non-live tables.
*-----------------------------------------------------------------------------
* @author sowmya@temenos.com
* Utility routine to get the list of time zones configured
*
*
* @param TABLE.NAME    :incoming arg: F.EB.TIME.ZONES
* @param THE.LIST      :outgoing arg: Time zone list

*-----------------------------------------------------------------------------
* Modification History :
*
* 13/08/13 - Story : 557778 / Enhancement :689421 / Task : 689426
*            T24 Multi-Time Zone
*
*----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.EB.TIME.ZONES
    $INSERT I_DAS.EB.TIME.ZONES.NOTES
    $INSERT I_DAS
*-----------------------------------------------------------------------------
BUILD.DATA:
*---------*

    MY.TABLE = 'EB.TIME.ZONES' : TABLE.SUFFIX
*
    BEGIN CASE

    CASE MY.CMD = dasAllIds   ;* Standard; returns all keys

    CASE MY.CMD = dasEbTimeZonesEqFavorites       ;* Select based on Status

        MY.FIELDS = 'FAVORITES'         ;* Must be a valid field
        MY.OPERANDS = 'EQ'    ;* EQ - Equals
        MY.DATA = THE.ARGS<1> ;* The data part
        MY.JOINS = ''

    CASE OTHERWISE
        ERROR.MSG = 'UNKNOWN.QUERY'

    END CASE

    RETURN

*-----------------------------------------------------------------------------
END
