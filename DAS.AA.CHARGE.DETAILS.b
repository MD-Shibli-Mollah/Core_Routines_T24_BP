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
    $PACKAGE AA.ModelBank
    SUBROUTINE DAS.AA.CHARGE.DETAILS(THE.LIST, THE.ARGS, TABLE.SUFFIX)

*-----------------------------------------------------------------------------
* Data Access Service for AA.DETAILS.CHARGE
* Implements the query definition for all queries that can be used against
* the AA.DETAILS.CHARGE table.
*-----------------------------------------------------------------------------
* Modifications:
*
*******************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.AA.CHARGE.DETAILS
    $INSERT I_DAS.AA.CHARGE.DETAILS.NOTES
    $INSERT I_DAS

BUILD.DATA:

    MY.TABLE = "AA.CHARGE.DETAILS" : TABLE.SUFFIX

    BEGIN CASE
    CASE MY.CMD = DAS$ALL.IDS ;* Standard to return all keys

    CASE MY.CMD = DAS.CHARGE.DETAILS$IDLK         ;* to select by it's @ID
        MY.FIELDS = "@ID"
        MY.OPERANDS = "LK"
        MY.DATA = THE.ARGS<1>:"..."

    CASE OTHERWISE
        ERROR.MSG = "UNKNOWN.QUERY"
    END CASE

    RETURN

END
