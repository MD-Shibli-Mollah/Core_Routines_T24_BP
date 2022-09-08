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
* <Rating>-57</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CL.ModelReport
    SUBROUTINE E.CL.PERFORM.VIEW(ENQ.LIST.FINAL)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*** <doc>
* Routine Type : NO-FILE routine
*  This routine used for to monitor Collector Performance.
* @author johnson@temenos.com
* @stereotype template
* @uses ENQUIRY>CL.PERFORM.VIEW
* @uses
* @package retaillending.CL
*
*** </doc>
*** </region>

*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History :
*-----------------------
* 11/04/14 -  ENHANCEMENT - 908020 /Task - 988392
*          -  Loan Collection process
* ----------------------------------------------------------------------------
*** </region>
*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
*
* Input :
*
*
*
*
* Output
*
* ENQ.LIST.FINAL = It return final result
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING CL.Contract
    $USING EB.Reports
    $USING EB.DataAccess



*** </region>

*** <region name= Main Section>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN

*** </region>

*** <region name= INITIALISE>
*** <desc>Initialise local variables and file variables</desc>

*--------*
INITIALISE:
*---------*

* Initialise the required variables and open files

    FORM.ARRAY = ''
    PD.DAYS = ''
    ACT.ARRAY = ''
    SAVE.OUTCOME = ''
    SAVE.AMOUNT = ''
    SAVE.TIME = ''
    OUTCOME.CODE = ''
    OUTCOME.DUE.AMT = ''
    START.TIME = ''
    END.TIME = ''
    HOUR.DIFF = ''
    MINUTES.DIFF = ''
    DIFF = ''
    TOT.MINUTES.DIFF = ''
    COLL.ITEM.ID = ''
    TOT.AMOUNT = ''
    TOT.TIME = ''
    OLD.OUTCOME = ''
    OUTCOME.CNT =''
    SAVE.ARRAY = ''
    E.PD.DAYS = ''  ;* Get No of PD Days from Selection
    E.QUEUE = ''    ;* Get Queue from Selection
    E.COLL.ID = ''  ;* Get Collector Id from Selection
    E.FROM.DATE = ''          ;* Get From Date from Selection
    E.TO.DATE = ''  ;* Get To Date from Selection

    GOSUB GET.INFO.FROM.ENQ
    FN.CL.ACTIVITY = "F.CL.ACTIVITY"
    F.CL.ACTIVITY = ""
    EB.DataAccess.Opf(FN.CL.ACTIVITY,F.CL.ACTIVITY)

    F.CL.COLLECTION.ITEM = ""

    RETURN
*** </region>

*** <region name= INFORMATION FROM SS>
*** <desc>Get Information from Standard Selection</desc>

*----------------*
GET.INFO.FROM.ENQ:
*----------------*

* Get the all values which is define in standard selection

    LOCATE "OVERDUE.DAYS" IN EB.Reports.getDFields()<1> SETTING COLL.POS THEN
    E.PD.DAYS = EB.Reports.getDRangeAndValue()<COLL.POS>
    END ELSE
    E.PD.DAYS = ""
    END
    LOCATE "DEST.QUEUE" IN EB.Reports.getDFields()<1> SETTING COLL.POS THEN
    E.QUEUE = EB.Reports.getDRangeAndValue()<COLL.POS>
    END ELSE
    E.QUEUE = ""
    END
    LOCATE "COLLECTOR" IN EB.Reports.getDFields()<1> SETTING COLL.POS THEN
    E.COLL.ID= EB.Reports.getDRangeAndValue()<COLL.POS>
    END ELSE
    E.COLL.ID = ""
    END
    LOCATE "COLLECTOR.TYPE" IN EB.Reports.getDFields()<1> SETTING COLL.POS THEN
    E.COLL.TYPE.ID= EB.Reports.getDRangeAndValue()<COLL.POS>
    END ELSE
    E.COLL.TYPE.ID = ""
    END
    LOCATE "FROM.DATE" IN EB.Reports.getDFields()<1> SETTING COLL.POS THEN
    E.FROM.DATE= EB.Reports.getDRangeAndValue()<COLL.POS>
    END ELSE
    E.FROM.DATE = ""
    END
    LOCATE "TO.DATE" IN EB.Reports.getDFields()<1> SETTING COLL.POS THEN
    E.TO.DATE = EB.Reports.getDRangeAndValue()<COLL.POS>
    END ELSE
    E.TO.DATE = ""
    END
    RETURN

*** </region>

*** <region name= PROCESS>
*** <desc>Main Process for Form array and Return Array</desc>

*------*
PROCESS:
*------*

    GOSUB FORM.CRITERIA

    IF ALL.CMD EQ "" THEN
        SEL.CMD = "SELECT ":FN.CL.ACTIVITY:" BY OUTCOME.CODE"
    END ELSE
        SEL.CMD = "SELECT ":FN.CL.ACTIVITY:" WITH ":ALL.CMD:" BY OUTCOME.CODE"
    END
    SEL.LIST = ""
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,"",NO.OF.ACTS,SEL.ERR)

    IF NOT(NO.OF.ACTS) THEN
        ENQ.LIST.FINAL = ''
        RETURN
    END

    LOOP
        REMOVE ACT.ID FROM SEL.LIST SETTING MORE
    WHILE ACT.ID:MORE
        R.CL.ACTIVITY = ""
        ACT.READ.ERR = ""
        R.CL.ACTIVITY = CL.Contract.Activity.Read(ACT.ID, ACT.READ.ERR)
        GOSUB GET.INFO.FROM.ACT

        R.CL.COLLECTION.ITEM = ""
        COLL.ITEM.READ.ERR = ""
        * Read the collection item's which is present in Activity table.

        R.CL.COLLECTION.ITEM = CL.Contract.CollectionItem.Read(COLL.ITEM.ID, COLL.ITEM.READ.ERR)
        PD.DAYS = R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitNoOfDaysPd>

        IF E.PD.DAYS NE "" THEN
            IF PD.DAYS EQ E.PD.DAYS THEN
                ACT.ARRAY = OUTCOME.CODE:"*":OUTCOME.DUE.AMT:"*":TOT.MINUTES.DIFF
                ENQ.LIST<-1> = ACT.ARRAY
            END
        END ELSE
            ACT.ARRAY = OUTCOME.CODE:"*":OUTCOME.DUE.AMT:"*":TOT.MINUTES.DIFF
            ENQ.LIST<-1> = ACT.ARRAY
        END
    REPEAT

    OUTCOME.CNT = 0
    OLD.OUTCOME = ""
    TOT.LIST = 0
* Special Process

    LOOP
        REMOVE SAVE.ITEM FROM ENQ.LIST SETTING MORE
    WHILE SAVE.ITEM:MORE
        SAVE.OUTCOME = FIELD(SAVE.ITEM,"*",1)
        SAVE.AMOUNT = FIELD(SAVE.ITEM,"*",2)
        SAVE.TIME = FIELD(SAVE.ITEM,"*",3)

        TOT.LIST + = 1
        CUR.OUTCOME = SAVE.OUTCOME

        DIV.VAL = "60"

        IF CUR.OUTCOME EQ OLD.OUTCOME THEN
            OUTCOME.CNT += 1
            TOT.AMOUNT += SAVE.AMOUNT
            TOT.TIME += SAVE.TIME

        END ELSE
            IF OLD.OUTCOME NE "" THEN
                GOSUB GET.AVERAGE.TIME
                IF TIME.HOURS OR TIME.MINS OR TIME.SECONDS THEN
                    CURR.HH.MM.SS = TIME.HOURS : ":" : TIME.MINS : ":" : TIME.SECONDS
                END

                SAVE.ARRAY = OLD.OUTCOME:"*":OUTCOME.CNT:"*":TOT.AMOUNT:"*": CURR.HH.MM.SS
                FORM.ARRAY<-1> = SAVE.ARRAY
            END
            OUTCOME.CNT = 1
            TOT.AMOUNT = SAVE.AMOUNT
            TOT.TIME = SAVE.TIME
            OLD.OUTCOME = CUR.OUTCOME
        END
    REPEAT

    GOSUB GET.AVERAGE.TIME

    IF TIME.HOURS OR TIME.MINS OR TIME.SECONDS THEN
        CURR.HH.MM.SS = TIME.HOURS : ":" : TIME.MINS : ":" : TIME.SECONDS
    END

    SAVE.ARRAY = OLD.OUTCOME:"*":OUTCOME.CNT:"*":TOT.AMOUNT:"*": CURR.HH.MM.SS

* Form the final Array to get result.

    IF Y.HOURS OR Y.MINS OR Y.SECS THEN
        FINAL.TIME = FMT(Y.HOURS, "R%2") : ":" : FMT(Y.MINS, "R%2") : ":" : FMT(Y.SECS, "L%2")
    END

    ENQ.LIST.FINAL<-1> = FORM.ARRAY
    DATE.TIME = 0   ;* For future use
    ENQ.LIST.FINAL<-1> = SAVE.ARRAY : "*" : FINAL.TIME : "*": DATE.TIME


    RETURN

*** </region>

*** <region name= CRITERIA>
*** <desc>Form the Critera to select the CL Activity</desc>
*------------*
FORM.CRITERIA:
*------------*

* Form the selection depends on Selection fields

    ALL.CMD = ""
    IF E.COLL.ID NE "" THEN
        ALL.CMD := " COLLECTOR EQ ":E.COLL.ID
    END
    IF E.QUEUE NE "" THEN
        ALL.CMD := " AND DEST.QUEUE EQ ":E.QUEUE
    END

    IF E.FROM.DATE NE "" THEN
        ALL.CMD := " AND ACTION.DATE GE ":E.FROM.DATE
    END
    IF E.TO.DATE NE "" THEN
        ALL.CMD := " AND ACTION.DATE LE ":E.TO.DATE
    END
*
    RETURN
*** </region>

*** <region name= FROM ACCOUNT>
*** <desc>Get Inoformation from CL Actity</desc>
*----------------*
GET.INFO.FROM.ACT:
*----------------*

* Get the information from Activity.

    OUTCOME.CODE = R.CL.ACTIVITY<CL.Contract.Activity.ActivOutcomeCode>
    OUTCOME.DUE.AMT = R.CL.ACTIVITY<CL.Contract.Activity.ActivOutcomeDueAmt>
    START.TIME = R.CL.ACTIVITY<CL.Contract.Activity.ActivStartTime>
    END.TIME = R.CL.ACTIVITY<CL.Contract.Activity.ActivEndTime>

    HOUR.DIFF = FIELD(END.TIME,":",1) - FIELD(START.TIME,":",1)

    END.TIME.MINUTES = FIELD(END.TIME,":",2)
    START.TIME.MINUTES = FIELD(START.TIME,":",2)

    MINUTES.DIFF = ABS (END.TIME.MINUTES-START.TIME.MINUTES)

    DIFF = (HOUR.DIFF * 60) + MINUTES.DIFF
    TOT.MINUTES.DIFF = DIFF
    OVERALL.TOTAL.MIN + = DIFF

    COLL.ITEM.ID = R.CL.ACTIVITY<CL.Contract.Activity.ActivCustomer>
    RETURN
*** </region>

GET.AVERAGE.TIME:
*----------------

    TOT.TIME = TOT.TIME/OUTCOME.CNT
    TIME.HOURS = ABS(TOT.TIME / DIV.VAL)
    TIME.HOURS = FIELD(TIME.HOURS, '.', 1)
    TIME.HOURS = FMT(TIME.HOURS,"R%2")
    TIME.MIN  = MOD(TOT.TIME,DIV.VAL)
    TIME.MINS = FIELD(TIME.MIN, '.', 1)
    TIME.MINS = FMT(TIME.MINS, "R%2")
    TIME.SECONDS = FIELD(TIME.MIN, '.', 2) * DIV.VAL
    TIME.SECONDS = FMT(TIME.SECONDS, "L%2")

    Y.HOURS + = TIME.HOURS
    Y.MINS + = TIME.MINS
    Y.SECS + = TIME.SECONDS

    RETURN
    END
