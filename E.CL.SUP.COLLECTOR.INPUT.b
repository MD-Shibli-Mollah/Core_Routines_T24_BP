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
* <Rating>-114</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CL.ModelReport
    SUBROUTINE E.CL.SUP.COLLECTOR.INPUT(ENQ.LIST)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*** <doc>
* Routine Type : NO-FILE routine
*  This routine used to supervisor Monitor the all collector information
* @author johnson@temenos.com
* @stereotype template
* @uses ENQUIRY>CL.SUP.COLLECTOR.INPUT
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
*          - Loan Collection process
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
* ENQ.LIST = It return final result
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING CL.Contract
    $USING EB.Reports
    $USING EB.DataAccess


*** </region>
*-----------------------------------------------------------------------------
*** <region name= MAIN PROCESS>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise local variables and file variables</desc>

*---*
INITIALISE:
*---*

* Intialise all the variables and open required files.

    F.CL.COLLECTOR = ""

    F.CL.QUEUE = ""

    FN.CL.COLLECTOR.ITEM = "F.CL.COLLECTION.ITEM"
    F.CL.COLLECTOR.ITEM = ""
    EB.DataAccess.Opf(FN.CL.COLLECTOR.ITEM,F.CL.COLLECTOR.ITEM)

    F.CL.COLLECTOR.USER = ''

    FN.AA.OVERDUE.STATS = 'F.AA.OVERDUE.STATS'
    F.AA.OVERDUE.STATS =''
    EB.DataAccess.Opf(FN.AA.OVERDUE.STATS,F.AA.OVERDUE.STATS)


    COLL.ID = ''
    QUEUES.LIST = ''
    NO.OF.QUEUES = ''
    ALL.CMD = ''
    COLL.ITEM.ID = ''
    CI.ARRAY = ''
    ENQ.LIST = ''
    CURRENT.QUEUE = ''
    PREV.QUEUE = ''
    RA.FLAG = ''
    FORM.ARRAY = ''
    RETURN

*** </region>
*** <region name= PROCESS>
*** <desc>Main proces to form the Array and retun to Enquiry</desc>

*------*
PROCESS:
*------*
* 1. If enter collector ID then system form the array based on assign Queue
* 2. if No selection then system return all Collection without any specific criteria


* Get the collector ID from the Enquiry input.
    LOCATE "COLLECTOR.ID" IN EB.Reports.getDFields()<1> SETTING COLL.POS THEN
    COLL.ID = EB.Reports.getDRangeAndValue()<COLL.POS>
    END ELSE
    COLL.ID = ""
    END
    IF COLL.ID THEN
        GOSUB CHECK.COLLECTOR.CL.COLLECTION.ITEM
    END ELSE
        GOSUB CHECK.ALL.COLL.ITEM
    END

    ENQ.LIST<-1>  = FORM.ARRAY

    RETURN
*** </region>

*** <region name= CHECK COLLECTOR COLLECTION ITEM>
*** <desc>Check Collector Id is valid if yes then proceed further process</desc>

*-------------------*
CHECK.COLLECTOR.CL.COLLECTION.ITEM:
*--------------------*

    R.CL.COLLECTOR = ""
    COLL.READ.ERR = ""
    R.CL.COLLECTOR = CL.Contract.Collector.Read(COLL.ID, COLL.READ.ERR)
    IF R.CL.COLLECTOR EQ '' THEN
        EB.Reports.setEnqError('Invalid Colletcor ID')
        RETURN
    END ELSE
        * Get the all Queues assigned to this collector.
        ENQ.LIST = ""
        QUEUES.LIST = R.CL.COLLECTOR<CL.Contract.Collector.CollAssignedQueues>
        NO.OF.QUEUES = DCOUNT(QUEUES.LIST,@VM)
        * This Para tries to get all the COLLECTION.ITEMs with QUEUE
        * that are equal to the ASSIGNED to this collector.
        GOSUB GET.COLL.ITEM.PROCESS.ONE
    END
    RETURN
*** </region>

*** <region name= CHECK ALL COLLECTION ITEM>
*** <desc>Select all the collection item's</desc>

*------------------------*
CHECK.ALL.COLL.ITEM:
*-----------------------*

    SEL.CMD = "SELECT ":FN.CL.COLLECTOR.ITEM:" BY.DSND WEIGHT"
    SEL.LIST = ""
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,"",NO.OF.RECS,SEL.ERR)

    LOOP
        REMOVE COLL.ITEM.ID FROM SEL.LIST SETTING MORE
    WHILE COLL.ITEM.ID:MORE
        GOSUB FORM.ARRAY
    REPEAT

    RETURN

*** </region>
*** <region name= GET COLLECTION ITEM PROCESS ONE>
*** <desc>Form the Selection and select the Collection items</desc>

*------------------------*
GET.COLL.ITEM.PROCESS.ONE:
*------------------------*

    ALL.CMD = ""
    FOR QUEUE.CNT = 1 TO NO.OF.QUEUES
        QUEUE.ID = QUEUES.LIST<1,QUEUE.CNT>

        BEGIN CASE
            CASE QUEUE.CNT EQ '1' AND QUEUE.CNT NE NO.OF.QUEUES
                ALL.CMD := " (QUEUE EQ ":"'":QUEUE.ID:"'"
            CASE NO.OF.QUEUES EQ '1'
                ALL.CMD := " (QUEUE EQ ":"'":QUEUE.ID:"'": " AND COLLECTOR EQ ":"'":COLL.ID:"'":")"
            CASE QUEUE.CNT NE NO.OF.QUEUES AND QUEUE.CNT GT '1'
                ALL.CMD := " OR QUEUE EQ ":"'":QUEUE.ID:"'"
            CASE QUEUE.CNT EQ NO.OF.QUEUES
                ALL.CMD := ") AND COLLECTOR EQ ":"'":COLL.ID:"'"
        END CASE
    NEXT QUEUE.CNT

* Sort using WEIGHT.

    IF ALL.CMD NE "" THEN
        SEL.CMD = "SELECT ":FN.CL.COLLECTOR.ITEM:" WITH":ALL.CMD:" BY.DSND WEIGHT"
    END ELSE
        IF COLL.ID NE "" THEN
            SEL.CMD = "SELECT ":FN.CL.COLLECTOR.ITEM:" BY.DSND WEIGHT"
        END
    END
    SEL.LIST = ""
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,"",NO.OF.RECS,SEL.ERR)
    LOOP
        REMOVE COLL.ITEM.ID FROM SEL.LIST SETTING MORE
    WHILE COLL.ITEM.ID:MORE
        GOSUB FORM.ARRAY
    REPEAT
    RETURN

*** </region>
*** <region name= FORM ARRAY>
*** <desc>Form Array</desc>

*---------*
FORM.ARRAY:
*---------*

    R.CL.COLLECTION.ITEM = ""
    COLL.ITEM.READ.ERR = ""
    R.CL.COLLECTION.ITEM = CL.Contract.CollectionItem.Read(COLL.ITEM.ID, COLL.ITEM.READ.ERR)

    CURRENT.QUEUE = R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitQueue>
    PREV.QUEUE = R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitPreviousQueue>
    IF CURRENT.QUEUE NE PREV.QUEUE AND PREV.QUEUE NE "" THEN
        RA.FLAG = "YES"
    END ELSE
        RA.FLAG = "NO"
    END
    NO.OF.PDS = DCOUNT(R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitDueReference>,@VM)
    FOR PD.CNT = 1 TO NO.OF.PDS
        CI.ARRAY = ''

        OVERDUE.ID = R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitUlContractRef,PD.CNT>
        IF OVERDUE.ID[1,2] EQ 'AA' THEN
            GOSUB GET.AA.OVERDUE.STATS.ID
        END ELSE
            OVERDUE.LIST = R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitDueReference,PD.CNT>
        END

        IF PD.CNT EQ 1 THEN
            CI.ARRAY = COLL.ITEM.ID:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitTotOverdueAmt>:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitTotOutstdingAmt>:"*"
            CI.ARRAY := R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitNoOfDaysPd>:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitActionCode>:"*"
            CI.ARRAY := R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitActionDate>:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitOutcomeCode>:"*"
            CI.ARRAY := R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitCollector>:"*":CURRENT.QUEUE:"*":RA.FLAG:"*":OVERDUE.LIST:"*":OVERDUE.ID
        END ELSE
            CI.ARRAY = "**********":OVERDUE.LIST:"*":OVERDUE.ID
        END
        FORM.ARRAY<-1> = CI.ARRAY
    NEXT PD.CNT
    RETURN

GET.AA.OVERDUE.STATS.ID:
************************

    OVERDUE.ID.LIST = SQUOTE(OVERDUE.ID):"..."

    SEL.CMD.AA = "SELECT ":FN.AA.OVERDUE.STATS:" WITH @ID LIKE ":DQUOTE(OVERDUE.ID.LIST)
    EB.DataAccess.Readlist(SEL.CMD.AA,SEL.LIST.AA,'',NO.OF.REC,ERR.REC)
    OVERDUE.LIST = SEL.LIST.AA
    CHANGE @FM TO @VM IN OVERDUE.LIST
    RETURN


*** </region>
    END
