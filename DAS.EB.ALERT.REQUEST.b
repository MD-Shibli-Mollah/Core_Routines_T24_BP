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

*-------------------------------------------------------------------------
* <Rating>-31</Rating>
*-------------------------------------------------------------------------

    $PACKAGE EB.AlertProcessing
    SUBROUTINE DAS.EB.ALERT.REQUEST(THE.LIST,THE.ARGS,TABLE.SUFFIX)

*-----------------------------------------------------------------------------
* Data Access Servive for EB.ALERT.REQUEST
* Implements the query definition for all queries that can be used against
* the EB.ALERT.REQUEST table.
* THE.LIST, THE.ARGS, TABLE.SUFFIX
* where
* THE.LIST     - Passes in the name of the query and is held in MY.CMD. Returns the ley list.
* THE.ARGS     - Variable parts of selection data, normally field delimited.
* TABLE.SUFFIX - $NAU, $HIS or blank. Used to access non-live tables.
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.EB.ALERT.REQUEST
    $INSERT I_DAS.EB.ALERT.REQUEST.NOTES
    $INSERT I_DAS.COMMON
    $INSERT I_DAS
*-----------------------------------------------------------------------------

BUILD.DATA:

    MY.TABLE = "EB.ALERT.REQUEST": TABLE.SUFFIX

    BEGIN CASE

    CASE MY.CMD = dasAllIds          ;* Standard; returns all keys

    CASE MY.CMD = DAS.EB.ALERT.REQUEST$CONTRACT.REF               ;* Query to select the EB.ALERT.REQUEST record

        MY.FIELDS = 'CONTRACT.REF':FM:'SUBSCRIBE'
        MY.OPERANDS = 'EQ':FM:'EQ'
        MY.DATA = THE.ARGS<1>:FM:THE.ARGS<2>
        MY.JOINS = 'AND'

    CASE OTHERWISE
        ERROR.MSG = "UNKNOWN.QUERY"

    END CASE

    RETURN
END
