* @ValidationCode : MjoyMDkzMDI5ODE5OmNwMTI1MjoxNTAzNTkyMjM3ODA0OmxncmFoYW06LTE6LTE6LTUzOi0xOmZhbHNlOk4vQTpERVZfMjAxNzA3LjIwMTcwNjIzLTAwMzU6LTE6LTE=
* @ValidationInfo : Timestamp         : 24 Aug 2017 17:30:37
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : lgraham
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -53
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201707.20170623-0035
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-75</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LI.ModelBank

SUBROUTINE E.LIM.ALLOW.EXCESS.SELECTION(LIMIT.LIST)
*-----------------------------------------------------------------------------
* 28/12/01 - GLOBUS_EN_10000351
* This is the selection routine for producing the list of limit ids for
* which the excess over the allowed amt maybe calculated. The user
* supplies the liability number in the selection fields and the limit ids
* for the same are fetched.

*
* 11/09/02 - EN_10001097
*            Conversion of error messages to error codes.
*
* 20/03/06 - BG_100010670
*            Enquiry LIMIT.ALLOW.EXCESS display records incorrectly.
*
* 28/02/07 - EN_10003212
*            All select statements are replaced with DAS to ensure that all applications
*            go through a single framework for the querys being raised against the database
*
* 05/04/07 - BG_100013547
*            Bug fix foe DAS.
*
* 21/08/17 - EN 2205157 / Task 2237727
*            use API instead of direct I/O for LIMIT related files
*            LIMIT.LIABILITY
*******************************************************************************************

    $INSERT I_DAS.LIMIT.LIABILITY

    $USING LI.Config
    $USING ST.Customer
    $USING EB.DataAccess
    $USING EB.ErrorProcessing
    $USING EB.Reports

**********************
PROCESS:
**********************
*
    LOCATE "LIABILITY.NUMBER" IN EB.Reports.getDFields()<1> SETTING ALLOW.POS ELSE
        ALLOW.POS = ''
    END
*
    GOSUB CHECK.LOGICAL.OPERANDS
*
RETURN

************************
INITIALISE:
************************

*Open files

    YID.LIST = ''

    LIMIT.LIST = ''
    LIMIT.LIAB.LIST = ''
    LIMIT.LIAB.ERR = ''
    LIAB.REC = ''
    LIAB.ERR = ''
    LIAB.ID = ''
    LIMIT.REC = ''
    LIMIT.ID = ''
    LIMIT.ERR = ''

RETURN


*********************************
FORM.LIST.OF.CUST:
*********************************

* Forms a list of customers to be processed depending on the common
* variables passed. D.LOGICAL.OPERANDS & D.RANGE.AND.VALUE.

    Y.OPERAND = EB.Reports.getDLogicalOperands()<ALLOW.POS>
    Y.CHK.VALUE = EB.Reports.getDRangeAndValue()<ALLOW.POS>
    Y.CUST.ARRAY = ''

    Y.SEL.CRITERIA = ''
    BEGIN CASE
        CASE Y.OPERAND = 1        ;* Equalto liability number.
            Y.SEL.CRITERIA = DAS.LIMIT.LIABILITY$ID.LIKE
            SELECT.DATA = Y.CHK.VALUE<1,1,1>

        CASE Y.OPERAND = 2        ;* Range
            Y.SEL.CRITERIA = DAS.LIMIT.LIABILITY$ID.RANGE
            SELECT.DATA = Y.CHK.VALUE<1,1,1> : @FM : Y.CHK.VALUE<1,1,2>

        CASE Y.OPERAND = 3        ;* Less Than
            Y.SEL.CRITERIA = DAS.LIMIT.LIABILITY$ID.LESS
            SELECT.DATA  =  Y.CHK.VALUE<1,1>

        CASE Y.OPERAND = 4        ;* Greater Than
            Y.SEL.CRITERIA = DAS.LIMIT.LIABILITY$ID.GREATER
            SELECT.DATA = Y.CHK.VALUE<1,1>

        CASE Y.OPERAND = 5        ;* Not Equal to
            Y.I = 1
            Y.SEL.CRITERIA = DAS.LIMIT.LIABILITY$ID.NOT.EQ
            SELECT.DATA = ''
            LOOP
                Y.X = Y.CHK.VALUE<1,1,Y.I>
            WHILE Y.X
                SELECT.DATA  := Y.X
            REPEAT

        CASE Y.OPERAND = 6 OR Y.OPERAND = 7
            NULL

        CASE Y.OPERAND = 8        ;* Less than or Equal
            Y.SEL.CRITERIA = DAS.LIMIT.LIABILITY$ID.LESS.EQUAL
            SELECT.DATA = Y.CHK.VALUE<1,1>


        CASE Y.OPERAND = 9        ;* Greater than or Equal
            Y.SEL.CRITERIA = DAS.LIMIT.LIABILITY$ID.GREATER.EQUAL
            SELECT.DATA = Y.CHK.VALUE<1,1>

        CASE Y.OPERAND = 10       ;* Less than Greater than
            Y.SEL.CRITERIA = DAS.LIMIT.LIABILITY$ID.NOTIN.RANGE
            SELECT.DATA = Y.CHK.VALUE<1,1,1> : @FM : Y.CHK.VALUE<1,1,2>
    END CASE

    LIMIT.LIAB.LIST = Y.SEL.CRITERIA
    EB.DataAccess.Das('LIMIT.LIABILITY', LIMIT.LIAB.LIST, SELECT.DATA, '')

    IF NOT(LIMIT.LIAB.LIST)  THEN
        ETEXT ='LI.RTN.CU.LIABILITY.REC.DOESNT.EXIST'
        EB.ErrorProcessing.FatalError("E.LIM.ALLOW.EXCESS.SELECTION")
    END
    IF LIMIT.LIAB.LIST THEN
        GOSUB PROCESS.LIMIT.IDS
    END

RETURN

************************
PROCESS.LIMIT.IDS:
************************

* Process each limit record for the customer liability

    LOOP
        REMOVE LIAB.ID FROM LIMIT.LIAB.LIST SETTING LIMIT.VAR
    WHILE LIAB.ID:LIMIT.VAR
        LIAB.REC = ''
        LI.Config.LimitLiabilityRead(LIAB.ID, LIAB.REC, LIAB.ERR)

        LIMIT.COUNT = DCOUNT(LIAB.REC,@FM)
        FOR LIM = 1 TO LIMIT.COUNT
            LIMIT.ID = LIAB.REC<LIM>
            LIMIT.REC = LI.Config.Limit.Read(LIMIT.ID, LIMIT.ERR)
            IF LIMIT.REC THEN
                LIMIT.LIST:= LIMIT.ID:@FM
            END
        NEXT LIM

    REPEAT
RETURN
*
***********************
CHECK.LOGICAL.OPERANDS:
***********************
    LOGICAL.OPERAND = EB.Reports.getDLogicalOperands()
    BEGIN CASE
*
        CASE LOGICAL.OPERAND<ALLOW.POS> = '' OR LOGICAL.OPERAND<ALLOW.POS> EQ 6 OR LOGICAL.OPERAND<ALLOW.POS> EQ 7
            RETURN
*
    END CASE
*
    GOSUB INITIALISE
    GOSUB FORM.LIST.OF.CUST
RETURN
*-----------------------------------------------------------------------------
*
END
