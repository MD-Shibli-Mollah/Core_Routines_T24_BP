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

* Version 3 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>-88</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.GET.ENTRY.IDS(ENQUIRY.DATA)
******************************************************************
*
* This is the build routine for the LINE.BAL.DET enquriry. It gets the
* RE.CONSOL.SPEC.ENTRY, STMT.ENTRY and CATEG.ENTRY IDs will be returned.
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 17/03/06 - BG_100010679
*            Created to get RE.CONSOL.SPEC.ENTRY, STMT.ENTRY or CATEG.ENTRY
*            IDs.
*
* 29/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING RE.ReportGeneration
    $USING EB.DataAccess

    EQU TRUE TO @TRUE, FALSE TO @FALSE
*-----------------------------------------------------------------------------

* Initialise
    GOSUB INITIALISE

* Build command
    GOSUB BUILD.COMMAND

* Build select list
    EB.DataAccess.Readlist(COMMAND, RE.STAT.LINE.MVMT.LIST, "", "", "")

* Process list
    GOSUB PROCESS.LIST

    RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise</desc>

* Open F.RE.STAT.LINE.MVMT file
    FN.RE.STAT.LINE.MVMT = 'F.RE.STAT.LINE.MVMT'
    F.RE.STAT.LINE.MVMT = ''
    EB.DataAccess.Opf(FN.RE.STAT.LINE.MVMT, F.RE.STAT.LINE.MVMT)

* Get sort and selection values
    SORT.DICT.ITEM.LIST = EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFixedSort>
    SELECT.DICT.ITEM.LIST = EB.Reports.getDFields()
    SELECT.OPERAND.NO.LIST = EB.Reports.getDLogicalOperands()
    SELECT.VALUE.LIST = EB.Reports.getDRangeAndValue()

* Initialise enquiry data, so it can be populated with values for return
    ENQUIRY.DATA = ""

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= BUILD.COMMAND>
BUILD.COMMAND:
*** <desc>Build command</desc>

* Initialise select statement
    COMMAND = "SSELECT " : FN.RE.STAT.LINE.MVMT

* Add sort details to select statement
    EB.Reports.setFirstTime(TRUE)
    LOOP
        REMOVE DICT.ITEM FROM SORT.DICT.ITEM.LIST SETTING DICT.ITEM.MARK
    WHILE DICT.ITEM : DICT.ITEM.MARK
        ID.DICT.ITEM = FIELD(DICT.ITEM, " ", 1)
        SEQUENCE = FIELD(DICT.ITEM, " ", 2)
        IF SEQUENCE = "DSND" THEN
            COMMAND := " BY-DSND"
        END ELSE
            COMMAND := " BY"
        END
        COMMAND := " " : ID.DICT.ITEM
    REPEAT

* Add filter details to select statement
    EB.Reports.setFirstTime(TRUE)
    LOOP
        REMOVE ID.DICT.ITEM FROM SELECT.DICT.ITEM.LIST SETTING DICT.ITEM.MARK
        REMOVE OPERAND.NO FROM SELECT.OPERAND.NO.LIST SETTING OPERAND.MARK
        REMOVE VALUE FROM SELECT.VALUE.LIST SETTING VALUE.MARK
    WHILE ID.DICT.ITEM : DICT.ITEM.MARK
        IF OPERAND.NO # "" THEN
            OPERAND = EB.Reports.getOperandList()<OPERAND.NO>
            IF OPERAND = "LK" THEN
                OPERAND = "LIKE"
            END
            IF EB.Reports.getFirstTime() THEN
                EB.Reports.setFirstTime(FALSE)
            END ELSE
                COMMAND := " AND"
            END
            COMMAND := " WITH " : ID.DICT.ITEM
            COMMAND := " " : OPERAND
            COMMAND := ' "' : VALUE : '"'
        END
    REPEAT

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.LIST>
PROCESS.LIST:
*** <desc>Process list</desc>

* Process each RE.STAT.LINE.MVMT record
    LOOP
        REMOVE ID.RE.STAT.LINE.MVMT FROM RE.STAT.LINE.MVMT.LIST SETTING RE.STAT.LINE.MVMT.MARK
    WHILE ID.RE.STAT.LINE.MVMT : RE.STAT.LINE.MVMT.MARK
        * Process RE.STAT.LINE.MVMT
        GOSUB PROCESS.RE.STAT.LINE.MVMT
    REPEAT

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.RE.STAT.LINE.MVMT>
PROCESS.RE.STAT.LINE.MVMT:
*** <desc>Process RE.STAT.LINE.MVMT record</desc>

* Read RE.STAT.LINE.MVMT record
    R.RE.STAT.LINE.MVMT = ''
    YERR = ''
    R.RE.STAT.LINE.MVMT = RE.ReportGeneration.tableStatLineMvmt(ID.RE.STAT.LINE.MVMT, YERR)

* Process each ENT.KEY
    TYPE = ID.RE.STAT.LINE.MVMT["-", 5, 1]
    ENT.KEY.LIST = R.RE.STAT.LINE.MVMT
    LOOP
        REMOVE ID.ENT.KEY FROM ENT.KEY.LIST SETTING ENT.KEY.MARK
    WHILE ID.ENT.KEY : ENT.KEY.MARK
        * Process ENT.KEY
        GOSUB PROCESS.ENT.KEY
    REPEAT

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.ENT.KEY>
PROCESS.ENT.KEY:
*** <desc>Process ENT.KEY</desc>

* Get entries and add them to list to return together with the type of entry
    ENTRY.LIST = ""
    RE.ReportGeneration.GetEntryIds(TYPE, ID.ENT.KEY, ENTRY.LIST)
    LOOP
        REMOVE ID.ENTRY FROM ENTRY.LIST SETTING ENTRY.MARK
    WHILE ID.ENTRY : ENTRY.MARK
        ENTRY = TYPE : "*" : ID.ENTRY
        IF ENQUIRY.DATA # "" THEN
            ENQUIRY.DATA := @FM
        END
        ENQUIRY.DATA := ENTRY
    REPEAT

    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END
