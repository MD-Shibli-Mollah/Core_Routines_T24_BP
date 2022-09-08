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
* <Rating>-51</Rating>
*-----------------------------------------------------------------------------
* Version 2 02/06/00  GLOBUS Release No. G10.2.02 29/03/00

    $PACKAGE PC.Contract
    SUBROUTINE E.PC.TRANS.JOURNAL(Y.ID.LIST)

*** <region name= Description>
*** <desc> </desc>
* This routine will return a list of id's to the ENQUIRY
* PC.TRANSACTION.JNL in the format 'S*':<STMT ENTRY ID> for stmt entry
*                                  'C*':<CATEGORY   ID> for categ entry
* The list is derived from two concat files based on START.PERIOD
* as the selection criteria . The concat files are
* PC.STMT.ADJUSTMENT    &     PC.CATEG.ADJUSTMENT
*
*** </region>

*** <region name= Modifiation history>
*** <desc> </desc>
*-----------------------------------------------------------------------------
*              MODIFICATION HISTORY
*-----------------------------------------------------------------------------
*
* 13/03/07 - EN_10003262
*            Modified to call DAS to select data.
*
* 25/06/2011 - DEFECT 232431 / TASK 233610
*              Changes done to return the entry ids correctly
*
*-----------------------------------------------------------------------

*** </region>

*** <region name= Insert files>
*** <desc> </desc>



    $USING PC.Contract
    $USING EB.Reports
    $USING EB.DataAccess
    $INSERT I_DAS.PC.STMT.ADJUSTMENT
    $INSERT I_DAS.PC.CATEG.ADJUSTMENT

*** </region>

*** <region name= Main process>
*** <desc> </desc>
*
* Find the position of START.PERIOD

    Y.CONCAT.REC = '' ; Y.ID.LIST = ''
    LOCATE "START.PERIOD" IN EB.Reports.getDFields()<1> SETTING YDATE.POS ELSE
    RETURN
    END

    IF EB.Reports.getDLogicalOperands()<YDATE.POS> = '' OR EB.Reports.getDRangeAndValue()<YDATE.POS> = "" OR EB.Reports.getDRangeAndValue()<YDATE.POS> = "ALL" THEN
        RETURN
    END

    YOPERAND = EB.Reports.getDLogicalOperands()<YDATE.POS>     ; * EQ,GT,LT
    ST.PER = EB.Reports.getDRangeAndValue()<YDATE.POS>        ; * start period

    GOSUB GET.STMT.RECS
    GOSUB GET.CATEG.RECS

    IF Y.CONCAT.REC THEN
        Y.ID.LIST = Y.CONCAT.REC        ; * here's the list
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------


*** <region name= Get STMT.ENTRY>
*** <desc> </desc>
GET.STMT.RECS:

    BEGIN CASE
        CASE YOPERAND EQ 1              ; * equals
            STMT.LIST = dasPcStmtAdjustmentStartPeriod
        CASE YOPERAND EQ 3              ; * less than
            STMT.LIST = dasPcStmtAdjustmentStartPeriodLt
        CASE YOPERAND EQ 4              ; * greater than
            STMT.LIST = dasPcStmtAdjustmentStartPeriodGt
    END CASE
    THE.ARGS = ST.PER
    TABLE.SUFFIX = ''
    EB.DataAccess.Das('PC.STMT.ADJUSTMENT', STMT.LIST, THE.ARGS, TABLE.SUFFIX)

    IF STMT.LIST THEN
        LOOP
            REMOVE ID.STMT FROM STMT.LIST SETTING STMT.MARK
        WHILE ID.STMT : STMT.MARK DO
            Y.CONCAT.REC<-1> = 'S*':FIELD(ID.STMT,'-',3)
        REPEAT
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get CATEG.ENTRY>
*** <desc> </desc>
GET.CATEG.RECS:

    BEGIN CASE
        CASE YOPERAND EQ 1              ; * equals
            CAT.ADJ.LIST = dasPcCategAdjustmentStartPeriod
        CASE YOPERAND EQ 3              ; * less than
            CAT.ADJ.LIST = dasPcCategAdjustmentStartPeriodLt
        CASE YOPERAND EQ 4              ; * greater than
            CAT.ADJ.LIST = dasPcCategAdjustmentStartPeriodGt
    END CASE
    THE.ARGS = ST.PER
    TABLE.SUFFIX = ''
    EB.DataAccess.Das('PC.CATEG.ADJUSTMENT', CAT.ADJ.LIST, THE.ARGS, TABLE.SUFFIX)

    IF CAT.ADJ.LIST THEN
        LOOP
            REMOVE ID.CAT.ADJ FROM CAT.ADJ.LIST SETTING CAT.ADJ.MARK
        WHILE ID.CAT.ADJ : CAT.ADJ.MARK DO
            Y.CONCAT.REC<-1>='C*':FIELD(ID.CAT.ADJ,'-',3)
        REPEAT
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------

    END
