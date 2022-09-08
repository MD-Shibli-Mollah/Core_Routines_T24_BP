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
* <Rating>-17</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Security
    SUBROUTINE DAS.OS.TOKEN(THE.LIST, THE.ARGS, TABLE.SUFFIX)
*-----------------------------------------------------------------------------
* Data Access Servive for TEMPLATE
* Implements the query definition for all queries that can be used against
* the TEMPLATE table.
* The method signature must remain:
* THE.LIST, THE.ARGS, TABLE.SUFFIX
* where
* THE.LIST     - Passes in the name of the query and is held in MY.CMD. Returns the ley list.
* THE.ARGS     - Variable parts of selection data, normally field delimited.
* TABLE.SUFFIX - $NAU, $HIS or blank. Used to access non-live tables.
*-----------------------------------------------------------------------------
* Modifications:
* -------------
* 27/09/06 - EN_10003086
*            Creation
*            Ref:SAR-2005-08-18-0008
*
* 15/11/06 - EN_10003119
*            Some more select added
*            Ref:SAR-2006-05-15-0005
*
* 05/12/07 - BG_100016193
*            Replaced F1 with proper dictionary name
*
* 05/06/08 - BG_100018680
*            Added - now only select internal users, ignore external
*
* 29/08/12 - Task : 472209/Defect : 469642
*          - Record Lock not working
*
*----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.OS.TOKEN
    $INSERT I_DAS.OS.TOKEN.NOTES
    $INSERT I_DAS
*-----------------------------------------------------------------------------
BUILD.DATA:
    MY.TABLE = 'OS.TOKEN' : TABLE.SUFFIX

    BEGIN CASE
    CASE MY.CMD = DAS$ALL.IDS ;* Standard to return all keys
    CASE MY.CMD = DAS.OS.TOKEN.USER.ID  ;* Explanation   EN_10003119 S BG_100016193 S
        MY.FIELDS = 'USER.ID' ;* Must be a valid field BG_100016193 E
        MY.OPERANDS = 'EQ'    ;* As per ENQUIRY (e.g. LK not LIKE)
        LOCK.OPERATOR=THE.ARGS
        MY.DATA = LOCK.OPERATOR         ;* The data part              EN_10003119 E
        MY.JOINS = "OR"
        MY.FIELDS<-1> = 'EXTERNAL.USER'
        MY.OPERANDS<-1> = 'EQ'
        LOCK.OPERATOR=THE.ARGS
        MY.DATA<-1> = LOCK.OPERATOR
    CASE MY.CMD = DAS.OS.TOKEN.EXTERNAL.USER      ;* BG_100018680 S
* get me all tokens that do not have an external user attribute
        MY.FIELDS = 'EXTERNAL.USER'
        MY.OPERANDS = 'EQ'
        MY.DATA = THE.ARGS<1>
    CASE OTHERWISE
        ERROR.MSG = 'UNKNOWN.QUERY'
    END CASE
    RETURN
*-----------------------------------------------------------------------------
END
