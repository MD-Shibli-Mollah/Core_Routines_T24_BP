* @ValidationCode : MjoxMjEyNDIyMDc6Q3AxMjUyOjE1NjE5ODU2OTM0NzU6c21pdGhhYmhhdDotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDcuMjAxOTA1MzEtMDMxNDotMTotMQ==
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
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CL.ModelReport
SUBROUTINE E.CL.PENDING.COLLECTION.COLLECTOR(ENQ.LIST)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
* This Enquiry used to display the collection item's which has not taken any action by collector.
*** <doc>
*
* @author johnson@temenos.com
* @stereotype template
* @uses NOFILE.CL.PENDING.COLL.COLLECTOR
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
    $USING AA.ProductManagement
    $USING ST.Config
    $USING PD.Contract
    $USING EB.Security
    $USING CL.Contract
    $USING CL.Config
    $USING EB.Reports
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING ST.CompanyCreation

*** </region>
*** <region name= Main section>
*** <desc>main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*** </region>

*** <region name= INITIALISE>
*** <desc>File variables and local variables</desc>

*---------*
INITIALISE:
*---------*

    FN.CL.COLLECTOR = "F.CL.COLLECTOR"
    F.CL.COLLECTOR = ""
    EB.DataAccess.Opf(FN.CL.COLLECTOR,F.CL.COLLECTOR)

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''

    FN.PD.PAYMENT.DUE = 'F.PD.PAYMENT.DUE'
    F.PD.PAYMENT.DUE = ''

    FN.CL.QUEUE = "F.CL.QUEUE"
    F.CL.QUEUE = ""

    FN.CL.COLLECTION.ITEM = "F.CL.COLLECTION.ITEM"
    F.CL.COLLECTION.ITEM = ""
    EB.DataAccess.Opf(FN.CL.COLLECTION.ITEM,F.CL.COLLECTION.ITEM)

    FN.CL.COLLECTOR.USER = "F.CL.COLLECTOR.USER"
    F.CL.COLLECTOR.USER = ''

    FN.CL.PARAMETER = 'F.CL.PARAMETER'
    F.CL.PARAMETER = ''
    EB.DataAccess.Opf(FN.CL.PARAMETER,F.CL.PARAMETER)

    R.APPL.PARM.ID = ''
    ER.PARAM = ''
    ST.CompanyCreation.EbReadParameter('F.CL.PARAMETER','N',"",R.CL.PARAMETER,R.APPL.PARM.ID,F.CL.PARAMETER,ER.PARAM)
    IF R.CL.PARAMETER THEN

        PTP.CODE = R.CL.PARAMETER<CL.Config.Parameter.ParamPtpCode>
        KPTP.CODE = R.CL.PARAMETER<CL.Config.Parameter.ParamKptpCode>
        BPTP.CODE = R.CL.PARAMETER<CL.Config.Parameter.ParamBptpCode>
        PPTP.CODE = R.CL.PARAMETER<CL.Config.Parameter.ParamPptpCode>

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



    GOSUB USERID
    IF NOT(NO.OF.RECS) THEN
        EB.Reports.setEnqError('Current User doesnt belongs to Collector')
        RETURN
    END

* Get the collector ID from the Enquiry input.

    LOCATE "COLLECTOR.ID" IN EB.Reports.getDFields()<1> SETTING COLL.POS THEN
        COLL.ID= EB.Reports.getDRangeAndValue()<COLL.POS>
    END ELSE
        COLL.ID = ""
    END

    R.CL.COLLECTOR = ""

    COLL.READ.ERR = ""
    IF COLL.ID THEN
        R.CL.COLLECTOR = CL.Contract.Collector.Read(COLL.ID, COLL.READ.ERR)

        IF R.CL.COLLECTOR EQ '' THEN
            EB.Reports.setEnqError('Invalid Colletcor ID')
            RETURN
        END
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

*** <region name= Action Performance>
*** <desc>Main and Other Actions Performance</desc>

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
        SHOW.FLAG = "1"
        GOSUB FORM.ARRAY
    REPEAT
RETURN

*** </region>

*** <region name= FORM.ARRAY>
*** <desc>Main and Other Actions Performance</desc>

*---------*
FORM.ARRAY:
*---------*

    R.CL.COLLECTION.ITEM = ""
    COLL.ITEM.READ.ERR = ""
    R.CL.COLLECTION.ITEM = CL.Contract.CollectionItem.Read(COLL.ITEM.ID, COLL.ITEM.READ.ERR)

    CURRENT.QUEUE = R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitQueue>
    PREV.QUEUE = R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitPreviousQueue>

* Reassinging the Queue,

    IF CURRENT.QUEUE NE PREV.QUEUE AND PREV.QUEUE NE "" THEN
        RA.FLAG = "YES"
    END ELSE
        RA.FLAG = "NO"
    END

* Check Collector has taken any actions on the collection items.

    NOT.SHOW.ITEMS = PTP.CODE:@VM:BPTP.CODE:@VM:PPTP.CODE

    BEGIN CASE
        CASE R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitOutcomeCode> MATCHES NOT.SHOW.ITEMS
            SHOW.FLAG = "0"
        CASE R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitOutcomeCode> EQ KPTP.CODE
            IF R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitOutcomeDueAmt> GE R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitTotOverdueAmt> THEN
                SHOW.FLAG = "0"
            END
    END CASE

    IF SHOW.FLAG THEN
        IF R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitActionCode> EQ '' THEN
            NO.OF.PDS = DCOUNT(R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitUlContractRef>,@VM)
            FOR PD.CNT = 1 TO NO.OF.PDS
                IF PD.CNT EQ 1 THEN
                    GOSUB ARRNG
                    CI.ARRAY = COLL.ITEM.ID:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitTotOverdueAmt>:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitTotOutstdingAmt>:"*"
                    CI.ARRAY := R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitNoOfDaysPd>:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitActionCode>:"*"
                    CI.ARRAY := R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitActionDate>:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitOutcomeCode>:"*"
                    CI.ARRAY := R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitCollector>:"*":CURRENT.QUEUE:"*":RA.FLAG:"*":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitUlContractRef,PD.CNT>:"*":COLL.ID:"*"
                    CI.ARRAY := CONTRACT.ID:"*":ACCOUNT.NO:"*":PRODUCT
                END ELSE
                    GOSUB ARRNG
                    CI.ARRAY = "**********":R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitUlContractRef,PD.CNT>:"*":COLL.ID:"*"
                    CI.ARRAY := CONTRACT.ID:"*":ACCOUNT.NO:"*":PRODUCT
                END
                ENQ.LIST<-1> = CI.ARRAY
            NEXT PD.CNT
        END
    END

RETURN

*** </region>

*** <region name= Get Arrangement Details>
*** <desc>Arrangement Details</desc>

ARRNG:


    CONTRACT.ID = R.CL.COLLECTION.ITEM<CL.Contract.CollectionItem.CitUlContractRef,PD.CNT>
    R.AA.ARRANGEMENT = AA.Framework.Arrangement.Read(CONTRACT.ID, AA.ERR)
    IF R.AA.ARRANGEMENT THEN
        ACCOUNT.NO = R.AA.ARRANGEMENT<AA.Framework.ArrangementSim.ArrLinkedApplId>
        PRODUCT = R.AA.ARRANGEMENT<AA.Framework.ArrangementSim.ArrProduct>

        EB.DataAccess.Dbr('AA.PRODUCT':@FM:AA.ProductManagement.Product.PdtDescription,PRODUCT,DESCRIPTION)
        PRODUCT = DESCRIPTION

    END ELSE
        OVERDUE = 'PD':CONTRACT.ID
        R.PD.PAYMENT.DUE = PD.Contract.PaymentDue.Read(OVERDUE, ERR.PD.PAYMENT.DUE)
        IF R.PD.PAYMENT.DUE THEN
            EB.DataAccess.Dbr('CATEGORY':@FM:ST.Config.Category.EbCatDescription,R.PD.PAYMENT.DUE<PD.Contract.PaymentDue.Category>,DESCRIPTION)
            PRODUCT = DESCRIPTION
        END
        ACCOUNT.NO = ''

    END

RETURN
*** </region>
*** <region name= Collector User>
*** <desc>Check collector user Id</desc>

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
