* @ValidationCode : MjotMTEzMjg4NjQwNzpDcDEyNTI6MTU2MTk4NTY5MzQyODpzbWl0aGFiaGF0Oi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDUzMS0wMzE0Oi0xOi0x
* @ValidationInfo : Timestamp         : 01 Jul 2019 18:24:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smithabhat
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190531-0314
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-99</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CL.ModelReport
SUBROUTINE E.CL.EXP.PAYMENT.ALERT(ENQ.LIST)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
* This Enquiry used to display the collection item's which available in "BPTP" or "PPTP".
*** <doc>
*
* @author johnson@temenos.com
* @stereotype template
* @uses NOFILE.CL.EXP.PAYMENT.ALERT
* @package retaillending.CL
*
*** </doc>
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
*  ENQ.LIST - Return the collection item's Details.
*
*** </region>
*** </region>
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History :
*-----------------------------------------------------------------------------
* 11/04/14 -  ENHANCEMENT - 908020 /Task - 988392
*          -  Loan Collection Process
*
* 30/04/19 -  Task        : 3109898
*             Enhancement : 2886910
*             Changes made to get CL.PARAMETER fields from Config Component since Table Definition is moved from Contract to Config component
*
* ----------------------------------------------------------------------------
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING AA.Framework
    $USING CL.Contract
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING ST.CompanyCreation
    $USING CL.Config

*** </region>
*** <region name= Main section>
*** <desc>main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

*** </region>

*** <region name= INITIALISE>
*** <desc>File variables and local variables</desc>

*----------*
INITIALISE:
*----------*

    FN.CL.COLLECTOR = "F.CL.COLLECTOR"
    F.CL.COLLECTOR = ""
    EB.DataAccess.Opf(FN.CL.COLLECTOR,F.CL.COLLECTOR)

    F.AA.ARRANGEMENT = ''

    F.USER = ''

    F.CL.QUEUE = ""

    FN.CL.COLLECTION.ITEM = "F.CL.COLLECTION.ITEM"
    F.CL.COLLECTION.ITEM = ""
    EB.DataAccess.Opf(FN.CL.COLLECTION.ITEM,F.CL.COLLECTION.ITEM)

    F.CL.COLLECTOR.USER = ''

    F.CL.PARAMETER = ''

    R.APPL.PARM.ID = ''
    ER.PARAM = ''
    ST.CompanyCreation.EbReadParameter('F.CL.PARAMETER','N',"",R.CL.PARAMETER,R.APPL.PARM.ID,F.CL.PARAMETER,ER.PARAM)
    IF R.CL.PARAMETER THEN

        PTP.CODE = R.CL.PARAMETER<CL.Config.Parameter.ParamPtpCode>
        KPTP.CODE = R.CL.PARAMETER<CL.Config.Parameter.ParamKptpCode>
        APAY.CODE = R.CL.PARAMETER<CL.Config.Parameter.ParamApayCode>
    END

    ENQ.LIST = ""
    PREV.SELECTED = ""
    NOW.PROCESSED = ""
    DUP = ""

RETURN

*** </region>

*** <region name= PROCESS>
*** <desc>Main Process</desc>

*------*
PROCESS:
*------*

* Get the collector ID from the Enquiry input.

    GOSUB USERID

    IF NOT(NO.OF.RECS) THEN
        EB.Reports.setEnqError('Current user does not belong to collector')
        RETURN
    END
    LOCATE "COLLECTOR.ID" IN EB.Reports.getDFields()<1> SETTING COLL.POS THEN
        COLL.ID = EB.Reports.getDRangeAndValue()<COLL.POS>
    END ELSE
        COLL.ID = ""
    END

    R.CL.COLLECTOR = ""
    COLL.READ.ERR = ""
    R.CL.COLLECTOR = CL.Contract.Collector.Read(COLL.ID, COLL.READ.ERR)
    IF COLL.READ.ERR NE '' AND COLL.ID NE "" THEN
        EB.Reports.setEnqError('Invalid Colletcor ID')
        RETURN
    END

* Get the all Queues assigned to this collector.

    ENQ.LIST = ""
    QUEUES.LIST = R.CL.COLLECTOR<CL.Contract.Collector.CollAssignedQueues>
    NO.OF.QUEUES = DCOUNT(QUEUES.LIST,@VM)

* This Para tries to get all the COLLECTION.ITEMs with QUEUE
* that are equal to the ASSIGNED to this collector.

    GOSUB GET.COLL.ITEM.PROCESS.ONE

RETURN
*** </region>

*** <region name= Selection Process>
*** <desc>Take Collection Item one by one to process</desc>

*------------------------*
GET.COLL.ITEM.PROCESS.ONE:
*------------------------*

    ALL.CMD = ""
    FOR QUEUE.CNT = 1 TO NO.OF.QUEUES
        QUEUE.ID = QUEUES.LIST<1,QUEUE.CNT>
        IF QUEUE.CNT NE NO.OF.QUEUES THEN
            ALL.CMD := " QUEUE EQ ":"'":QUEUE.ID:"'":" OR"
        END ELSE
            ALL.CMD := " QUEUE EQ ":"'":QUEUE.ID:"'"
        END
    NEXT QUEUE.CNT

* Sort using WEIGHT.

    IF ALL.CMD NE "" THEN
        SEL.CMD = "SELECT ":FN.CL.COLLECTION.ITEM:" WITH":ALL.CMD:" BY.DSND WEIGHT"
    END ELSE

        SEL.CMD = "SELECT ":FN.CL.COLLECTION.ITEM:" BY.DSND WEIGHT"

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

*** <region name= Array Form>
*** <desc>Form the Datas to Display</desc>


*---------*
FORM.ARRAY:
*---------*

    R.CL.COLLECTION.ITEM = ""
    COLL.ITEM.READ.ERR = ""
    R.CL.COLLECTION.ITEM = CL.Contract.CollectionItem.Read(COLL.ITEM.ID, COLL.ITEM.READ.ERR)

    CURRENT.QUEUE = R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitQueue>
    PREV.QUEUE = R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitPreviousQueue>
    OUTCOME.CODE = R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitOutcomeCode>
    ACTION.CODE = R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitActionCode>

    IF CURRENT.QUEUE NE PREV.QUEUE AND PREV.QUEUE NE "" THEN
        RA.FLAG = "YES"
    END ELSE
        RA.FLAG = "NO"
    END

    OUTCOME.CODE.LIST = PTP.CODE:@VM:APAY.CODE:@VM:KPTP.CODE

    IF NOT(OUTCOME.CODE MATCHES OUTCOME.CODE.LIST) AND (ACTION.CODE NE '') THEN

        NO.OF.PDS = DCOUNT(R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitUlContractRef>,@VM)
        FOR PD.CNT = 1 TO NO.OF.PDS
            IF PD.CNT EQ 1 THEN
                GOSUB ARRNG
                CI.ARRAY = COLL.ITEM.ID:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitTotOverdueAmt>:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitTotOutstdingAmt>:"*"
                CI.ARRAY := R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitNoOfDaysPd>:"*":ACTION.CODE:"*"
                CI.ARRAY := R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitActionDate>:"*":OUTCOME.CODE:"*"
                CI.ARRAY := R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitCollector>:"*":CURRENT.QUEUE:"*":RA.FLAG:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitUlContractRef,PD.CNT>:"*":COLL.ID:"*"
                CI.ARRAY := CONTRACT.ID:"*":ACCOUNT.NO:"*":PRODUCT.CODE:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitOdStartDate,PD.CNT>:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitOdAmount,PD.CNT>
            END ELSE
                GOSUB ARRNG
                CI.ARRAY = "**********":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitUlContractRef,PD.CNT>:"*":COLL.ID:"*"
                CI.ARRAY := CONTRACT.ID:"*":ACCOUNT.NO:"*":PRODUCT.CODE:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitOdStartDate,PD.CNT>:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitOdAmount,PD.CNT>
            END
            ENQ.LIST<-1> = CI.ARRAY
        NEXT PD.CNT
    END

RETURN

*** </region>

*** <region name= Arrangement Record>
*** <desc>Take Arrangement Details</desc>

ARRNG:
******

    CONTRACT.ID = R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitUlContractRef,PD.CNT>
    R.AA.ARRANGEMENT = AA.Framework.Arrangement.Read(CONTRACT.ID, AA.ERR)
    IF R.AA.ARRANGEMENT THEN
        ACCOUNT.NO = R.AA.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId>
        PRODUCT.CODE = R.AA.ARRANGEMENT<AA.Framework.Arrangement.ArrProduct>
    END
RETURN

*** </region>

*** <region name= Check Current Operator>
*** <desc>Check current operation is relevant to collector user</desc>

USERID:
*******

    SEL.CMD = "SELECT ":FN.CL.COLLECTOR:" WITH COLLECTOR.USER EQ ":'"':EB.SystemTables.getOperator():'"'
    SEL.LIST = ""
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,"",NO.OF.RECS,SEL.ERR)
    IF NO.OF.RECS EQ '' THEN
        RETURN
    END
RETURN
*** </region>
END











