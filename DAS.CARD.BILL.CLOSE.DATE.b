* @ValidationCode : Mjo3ODcwODgyMjI6Q3AxMjUyOjE1NjQ1Njk3NTQzMzY6c3JhdmlrdW1hcjotMTotMTowOi0xOnRydWU6Ti9BOkRFVl8yMDE5MDguMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:12:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-11</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.Cards
SUBROUTINE DAS.CARD.BILL.CLOSE.DATE(THE.LIST, THE.ARGS, TABLE.SUFFIX)
*-----------------------------------------------------------------------------
* Data Access Servive for CARD.BILL.CLOSE.DATE
* Implements the query definition for all queries that can be used against
* the CARD.BILL.CLOSE.DATE table.
* The method signature must remain:
* THE.LIST, THE.ARGS, TABLE.SUFFIX
* where
* THE.LIST     - Passes in the name of the query and is held in MY.CMD. Returns the ley list.
* THE.ARGS     - Variable parts of selection data, normally field delimited.
* TABLE.SUFFIX - $NAU, $HIS or blank. Used to access non-live tables.

********************************************************************************
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*--------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.CARD.BILL.CLOSE.DATE
    $INSERT I_DAS.CARD.BILL.CLOSE.DATE.NOTES
    $INSERT I_DAS

BUILD.DATA:

    MY.TABLE = 'CARD.BILL.CLOSE.DATE' : TABLE.SUFFIX
*
    BEGIN CASE
        CASE MY.CMD = dasAllIds
*Records from CARD.BILL.CLOSE.DATE based on ID

        CASE MY.CMD = dasCardBillCloseDate$Date
            MY.FIELDS = '@ID'
            MY.OPERANDS = 'MATCHES'
            MY.DATA = THE.ARGS<1>
            MY.JOINS = ''
            ADD.TO.CACHE = 0

        CASE OTHERWISE
            ERROR.MSG = 'UNKNOWN.QUERY'
    END CASE

RETURN
*------------------------------------------------------------------------------
END
