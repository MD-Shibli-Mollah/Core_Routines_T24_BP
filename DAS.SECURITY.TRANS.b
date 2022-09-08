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
* <Rating>292</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityPositionUpdate
    SUBROUTINE DAS.SECURITY.TRANS(THE.LIST, THE.ARGS, TABLE.SUFFIX)
*-----------------------------------------------------------------------------
* Data Access Service for TEMPLATE
* Implements the query definition for all queries that can be used against
* the TEMPLATE table.
* The method signature must remain:
* THE.LIST, THE.ARGS, TABLE.SUFFIX
* where
* THE.LIST     - Passes in the name of the query and is held in MY.CMD. Returns the ley list.
* THE.ARGS     - Variable parts of selection data, normally field delimited.
* TABLE.SUFFIX - $NAU, $HIS or blank. Used to access non-live tables.
*-----------------------------------------------------------------------------
* Modification History:
*
* 14/12/06 - EN_10003115
*            Creation.
*            Ref: SAR-2006-06-14-0003
*
* 03/04/08 - GLOBUS BG_100017997 cgraf@temenos.com
*            New Das select
*
*11/05/09 - GLOBUS_BG_100023569
*            New Das Select
*
* 05/04/10 - Defect:32821, Task:36732
*            Addition of criteria for null date updated and reversal date.
*
* 24/05/13 - DEFECT 678344 TASK 685043
*            Addition of criteria to select the SECURITY.TRANS with given
*            SECURITY.ACCOUNT,DEPOSITORY and SECURITY.NUMBER
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.SECURITY.TRANS
    $INSERT I_DAS.SECURITY.TRANS.NOTES
    $INSERT I_DAS
*-----------------------------------------------------------------------------
*** <region name= BUILD.DATA>
BUILD.DATA:
***
    MY.TABLE = 'SECURITY.TRANS' : TABLE.SUFFIX

    ADD.TO.CACHE = 0

    BEGIN CASE
        CASE MY.CMD = dasAllIds   ;* Standard to return all keys
            ADD.TO.CACHE = 1

        CASE MY.CMD = dasSecurityTransTransactionAndPortfolio   ;* Value
            MY.FIELDS = '@ID'
            MY.OPERANDS = 'LK'
            MY.DATA = "..." : THE.ARGS<1> : "..."

            MY.JOINS = 'AND'

            MY.FIELDS<2> = 'SECURITY.ACCOUNT'
            MY.OPERANDS<2> = 'EQ'
            MY.DATA<2> = THE.ARGS<2>

        CASE MY.CMD = dasSecurityTransSecAccSecNumDepository    ;* BG_100017997 S
            MY.FIELDS = 'SECURITY.ACCOUNT'
            MY.OPERANDS = 'LK'
            MY.DATA = "..." : THE.ARGS<1>

            MY.JOINS = 'AND'

            MY.FIELDS<2> = 'SECURITY.NUMBER'
            MY.OPERANDS<2> = 'EQ'
            MY.DATA<2> = THE.ARGS<2>

            MY.JOINS<2> = 'AND'

            MY.FIELDS<3> = 'DEPOSITORY'
            MY.OPERANDS<3> = 'EQ'
            MY.DATA<3> = THE.ARGS<3>        ;* BG_100017997 E

            *GLOBUS_BG_100023569

        CASE  MY.CMD = dasSecurityTransBySpecDate
            MY.FIELDS    = 'SECURITY.ACCOUNT'
            MY.OPERANDS  =  'EQ'
            MY.DATA      = THE.ARGS<1>

            MY.JOINS = 'AND'

            MY.FIELDS<2>   = 'SECURITY.NUMBER'
            MY.OPERANDS<2> = 'EQ'
            MY.DATA<2>     = THE.ARGS<2>

            MY.JOINS<2> = 'AND'

            MY.FIELDS<3>   = 'TRADE.DATE'
            MY.OPERANDS<3> = 'GE'
            MY.DATA<3>     = THE.ARGS<3>

            MY.JOINS<3> = 'AND'

            MY.FIELDS<4>   = 'TRADE.DATE'
            MY.OPERANDS<4> = 'LE'
            MY.DATA<4>     = THE.ARGS<4>

        CASE MY.CMD = dasSecurityTransWithNullDateUpdatedandReversalDate
            MY.FIELDS    = 'DATE.UPDATED'
            MY.OPERANDS  =  'EQ'
            MY.DATA      = ''

            MY.JOINS = 'AND'

            MY.FIELDS    = 'REVERSAL.DATE'
            MY.OPERANDS  =  'EQ'
            MY.DATA      = ''
            *GLOBUS_BG_100023569

        CASE MY.CMD = dasSecurityTransSecAccEqSecNumDepository
            MY.FIELDS = 'SECURITY.ACCOUNT'
            MY.OPERANDS = 'EQ'
            MY.DATA = THE.ARGS<1>

            MY.JOINS = 'AND'

            MY.FIELDS<2> = 'SECURITY.NUMBER'
            MY.OPERANDS<2> = 'EQ'
            MY.DATA<2> = THE.ARGS<2>

            MY.JOINS<2> = 'AND'

            MY.FIELDS<3> = 'DEPOSITORY'
            MY.OPERANDS<3> = 'EQ'
            MY.DATA<3> = THE.ARGS<3>

        CASE OTHERWISE
            ERROR.MSG = 'UNKNOWN.QUERY'
    END CASE
    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END
