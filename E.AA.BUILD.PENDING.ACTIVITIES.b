* @ValidationCode : MjoxMzgyMjU3Nzg3OkNwMTI1MjoxNjA1NjE4MTY1MzIwOnNtaXRoYWJoYXQ6ODowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNi4wOjE0MToxMzA=
* @ValidationInfo : Timestamp         : 17 Nov 2020 18:32:45
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smithabhat
* @ValidationInfo : Nb tests success  : 8
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 130/141 (92.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-38</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.BUILD.PENDING.ACTIVITIES(RET.VAL)
************************************
* Modification History
*
* 02/05/08 - BG_10003652
*            List only user activities that are pending
*
* 21/04/09 - CI_10062322
*            Unauth Status restricted only to
*            UNAUTH, REVERSE & UNAUTH-CHG.
*
* 05/05/09 - CI_10062772
*            Select command modified in compatible with unix server. The argument need to be given
*            within quotes.
*
* 29/09/09 - CI_10066433
*            Ref : HD0935849
*            Transaction activities other than FT and TT are displayed in pending activities list
*
* 23/03/11 - Defect : 173246
*            Transaction activities should be displayed in the pending activity list.
*
* 28/03/11 - Task-179786/Defect-177466
*            Ref :HD1048584
*            Replace select command with DAS to display activities in IHLD status from
*            AA.ARRANGEMENT.ACTIVITY$NAU.
*
* 20/04/11 - Task - 195422
*            Defect : 195418
*            Insert file I_DAS.AA.ARRANGEMENT.ACTIVITY included for resolving the warning message.
*
* 20/06/11 - Defect : 227750
*            Task : 229927
*            Check the TT & FT Product is installed or not before doing the OPF for TELLER and FUNDS.TRANSFER.
*
* 27/01/14 - Defect : 872285
*            Task: 898022
*            Only reverse master activity to be shown for authorisation while reverse and replay.
*
* 29/10/13 - Defect : 811644
*            Task   : 821478
*            Looping process has been started from the last one to solve the drilldown problem in enquiry(Authorise/ Delete)
*
* 14/03/14 - Defect: 936199
*            Task: 941231
*            Unable to authorise FT from arrangement overview screen
*
* 29/04/14 - Task : 984171
*            Defect : 979782
*            Display the LC transaction activity in the pending activity list
*
* 18/11/14 - Task - 1171853
*            Defect - 1169324
*            LD,PD,PAYMENT.STOP process has been included in to this routine
*
* 02/01/15 - Task - 1213895
*            Defect - 1213815
*            MD.DEAL process has been included in to this routine
*
* 20/03/15 - Task - 1288108
*            Defect - 1287561
*            Pending activities which is in AA.ACTIVITY.HISTORY.HIST also be listed
*
* 12/05/15 - Task   - 1343944
*            Defect - 1341800
*            System is not listing the transactions under the pending activities tab of the arrangement overview
*            screen,if we reverse a transaction of the automatic loan settlement happened during cob.
*
* 25/01/16 - Task : 1605438
*            Defect ID : 1593519
*            Compilation Warnings - Retail for TAFC compatibility on DEV area.
*
* 12/05/16 - Task - 1728351
*            Defect - 1725749
*            AC.CHARGE.REQUEST process has been included in this routine
*
* 16/06/16 - Task : 1767451
*            Defect : 1763137
*            Applypayment activities created by AC.CASH.POOL, AC.ACCOUNT.LINK records has been reversed from the overview, but not approved,
*            The same is not shown in pending activity list, since we have listed only USER, TRANSACTION intitiation type activities,
*            AC.ACCOUNT.LINK and AC.CASH.POOL transaction will create initiation type as PAY*EOD
*
* 24/06/16 - Task   : 1775288
*            Defect : 1769112
*            When pending activity in arrangement overview screen is accessed, corresponding application (FT,LD,MD,etc) must be opened
*            and not corresponding AAA activity.
*
* 10/03/17 - Task: 2020813
*            Enhancement: 2020817
*            Stop direct direct read of activity history record for HVT account and
*            call AC.HVT.MERGE to get the merged activity history record.
*
* 10/03/17 - Task: 3238148
*            Defect: 3214368
*            Unable to reverse activity posted by AC.CASH.POOL since initiation type is set as "SCHEDULED*SOD"
*
* 23/08/19 - Enhancement : 3309199
*            Task        : 3309206
*            Product Installation Check for CQ.
*
* 08/10/19 - Task 3375978
*            Removal ST references which has been moved to CQ
*
*   22/01/20 - Enhancement : 3503807
*              Task : 3548870
*              To return give the version name / application name for an external financial arrangement
*
* 17/11/20 - Task   : 4084918
*            Defect : 3933674
*            Changes made check if unauth CHEQUE.COLLECTION record exists and return Cheque.collection id for Teller transaction.
*
************************************************************************************************************************************************

    $USING AA.Framework
    $USING EB.DataAccess
    $USING EB.Delivery
    $USING FT.Contract
    $USING TT.Contract
    $USING LC.Contract
    $USING CQ.ChqPaymentStop
    $USING LD.Contract
    $USING PD.Contract
    $USING MD.Contract
    $USING EB.Reports
    $USING FT.AdhocChargeRequests

    $INSERT I_DAS.AA.ARRANGEMENT.ACTIVITY
*
    COMMON/AAHIST/RET.ARR
*****

    GOSUB INITIALISE
    GOSUB GET.DETAILS
*
RETURN
**************************
INITIALISE:
 
    RET.VAL = ''
    RET.ARR = ''
    HOLD.REQD = ''
*
    LOCATE 'ARR.ID' IN EB.Reports.getEnqSelection()<2,1> SETTING ARR.POS THEN
        ARR.ID = EB.Reports.getEnqSelection()<4,ARR.POS>
    END
*
    FV.AA.ACT.HIST = ''
*
    R.AA.ACT.HIST = ''
    AA.Framework.ReadActivityHistory(ARR.ID, '', '', R.AA.ACT.HIST)   ;* Get the activity history record.
*
    F.AA.ACTIVITY.HISTORY.HIST = ""

    FV.AAA = ''

    LOCATE 'INCLUDE.HOLD' IN EB.Reports.getEnqSelection()<2,1> SETTING HOLD.POS THEN      ;* Point the include.hold value for getting IHLD activities
        HOLD.REQD = EB.Reports.getEnqSelection()<4,HOLD.POS>
    END

    IF HOLD.REQD THEN
        TABLE.NAME = "AA.ARRANGEMENT.ACTIVITY"
        THE.LIST = DAS$STATUS.HOLD
        THE.ARGS = ARR.ID
        TABLE.SUFFIX = '$NAU'

        EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)

        ID.LIST = ''
        NO.REC = ''

        ID.LIST = THE.LIST
    END

    NO.REC = DCOUNT(ID.LIST,@FM)

*
RETURN
**************************
GET.DETAILS:
*
    NO.OF.DT = DCOUNT(R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhEffectiveDate>,@VM)
    UPD.CNT = 1
    GOSUB BUILD.ACTIVITIES
    GOSUB GET.AA.ACT.HIST.HIST.RECS
*
    IF ID.LIST THEN ;*Build details from AA.ARRANGEMENT.ACTIVITY
        FOR LOOP.CNT = 1 TO NO.REC
            AAA.REC = ''
            AAA.REC = AA.Framework.ArrangementActivity.ReadNau(ID.LIST<LOOP.CNT>, READ.ERR)
            RET.ARR<1,-1> = AAA.REC<AA.Framework.ArrangementActivity.ArrActEffectiveDate>
            RET.ARR<2,-1> = ID.LIST<LOOP.CNT>
            RET.ARR<3,-1> = AAA.REC<AA.Framework.ArrangementActivity.ArrActActivity>
            RET.ARR<4,-1> = ''
            RET.ARR<5,-1> = AAA.REC<AA.Framework.ArrangementActivity.ArrActTxnAmount>
            RET.ARR<6,-1> = AAA.REC<AA.Framework.ArrangementActivity.ArrActRecordStatus>
            RET.ARR<7,-1> = AAA.REC<AA.Framework.ArrangementActivity.ArrActInitiationType>
            RET.ARR<8,-1> = AAA.REC<AA.Framework.ArrangementActivity.ArrActTxnContractId>
            RET.ARR<9,-1> = AAA.REC<AA.Framework.ArrangementActivity.ArrActAlternateId>
            RET.VAL<-1> = UPD.CNT
            UPD.CNT += 1
        NEXT LOOP.CNT
    END
*
*    IF RET.ARR ELSE
*        RET.ARR = "NO.RECORD.SELECTED"
*        RET.VAL<-1> = UPD.CNT
*    END
*
RETURN
*-----------------------------------------------------------------------------
*** <region name= BUILD.ACTIVITIES>
*** <desc>Build activites list </desc>
BUILD.ACTIVITIES:

    FOR CNT.DT = 1 TO NO.OF.DT
        EFF.DT = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhEffectiveDate,CNT.DT>
        NO.OF.ACT = DCOUNT(R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivityRef,CNT.DT>,@SM)
        FOR CNT.ACT = 1 TO NO.OF.ACT
            IF R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActStatus,CNT.DT,CNT.ACT> MATCHES 'UNAUTH':@VM:'REVERSE':@VM:'UNAUTH-CHG' THEN
* Checks which activity to display in enquiry when reverse replay happens.
                GOSUB REV.REPLAY.CHK
                IF ALLOW.ACTIVITY.PROC.FLAG THEN
                    RETURN.TXN.ID = ''
                    BEGIN CASE
                        CASE R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhInitiation,CNT.DT,CNT.ACT> EQ "SCHEDULED*SOD"
                            GOSUB GET.TXN.SYS.ID      ;*Get Transaction System Id
                            IF R.AAA<AA.Framework.ArrangementActivity.ArrActTxnSystemId> EQ "ACCP" THEN
                                RETURN.TXN.ID = ""
                                GOSUB BUILD.RET.ARRAY
                            END
                        CASE R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhInitiation,CNT.DT,CNT.ACT> MATCHES "USER":@VM:"PAY*EOD":@VM:"PAY*SOD"
                            GOSUB BUILD.RET.ARRAY     ;*Build Return Array
                        CASE FIELD(R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhInitiation,CNT.DT,CNT.ACT>,'*',1) EQ "TRANSACTION"
                            GOSUB GET.TXN.SYS.ID      ;*Get Transaction System Id
                            GOSUB BUILD.RET.ARRAY
                    END CASE
                END
            END
        NEXT CNT.ACT
    NEXT CNT.DT
RETURN
*-----------------------------------------------------------------------------
*** <region name= GET.AA.ACT.HIST.HIST.RECS>
*** <desc>Get Files from AA.ACTIVITY.HISTORY.HIST </desc>
GET.AA.ACT.HIST.HIST.RECS:

    ARC.IDS = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhArcId>
    NO.OF.ACR.IDS = DCOUNT(ARC.IDS,@VM)

    FOR CNT.ARC.ID = 1 TO NO.OF.ACR.IDS
        ARC.ID = ARC.IDS<1,CNT.ARC.ID>
        R.AA.ACT.HIST = AA.Framework.ActivityHistoryHist.Read(ARC.ID, ERR.AA.ACTIVITY.HISTORY.HIST)
        EFF.DATES = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhEffectiveDate>
        NO.OF.DT = DCOUNT(EFF.DATES,@VM)
        GOSUB BUILD.ACTIVITIES
    NEXT CNT.ARC.ID
RETURN
*-----------------------------------------------------------------------------
*** <region name= GET.TXN.SYS.ID>
*** <desc>Get Transaction System Id </desc>
GET.TXN.SYS.ID:

    IF R.AAA<AA.Framework.ArrangementActivity.ArrActTxnSystemId> THEN ;* Check if TXN id of Activity is passed. If present corresponding application would open.
        RETURN.TXN.ID = 1
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BUILD.RET.ARRAY>
BUILD.RET.ARRAY:
*** <desc>Build Return Array </desc>

    RET.ARR<1,-1> = EFF.DT
    RET.ARR<2,-1> = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivityRef,CNT.DT,CNT.ACT>
    RET.ARR<3,-1> = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivity,CNT.DT,CNT.ACT>
    RET.ARR<4,-1> = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhSystemDate,CNT.DT,CNT.ACT>
    RET.ARR<5,-1> = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivityAmt,CNT.DT,CNT.ACT>
    RET.ARR<6,-1> = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActStatus,CNT.DT,CNT.ACT>
    RET.ARR<7,-1> = R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhInitiation,CNT.DT,CNT.ACT>
    IF RETURN.TXN.ID THEN
        TXN.CONTRACT.ID = R.AAA<AA.Framework.ArrangementActivity.ArrActTxnContractId> ;* Get the Transaction Id
        TXN.CONTRACT.ID = TXN.CONTRACT.ID['\',1,1] 
 * If the transaction id is Teller Id then we need to check if unauth CHEQUE.COLLECTION record exists.       
        IF TXN.CONTRACT.ID[1,2] EQ 'TT' THEN 
            GOSUB CHECK.CHEQUE.COLLECTION.REC.EXISTS
        END
        RET.ARR<8,-1> = TXN.CONTRACT.ID ;* Return Transaction Id 
    END ELSE
        RET.ARR<8,-1> = " "
    END

    RET.VAL<-1> = UPD.CNT

    UPD.CNT += 1

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= CHECK.CHEQUE.COLLECTION.REC.EXISTS>
CHECK.CHEQUE.COLLECTION.REC.EXISTS:
*** <desc>Check if unauth CHEQUE.COLLECTION record exists</desc>
    
    R.TELLER = TT.Contract.Teller.Read(TXN.CONTRACT.ID, RET.ERROR) ;* Get the Teller Record
    IF R.TELLER AND NOT(R.TELLER<TT.Contract.Teller.TeRecordStatus>) THEN ;* If Teller Record is authorized check if cheque.collection record exists
        FN.CHEQUE.COLLECTION = "F.CHEQUE.COLLECTION$NAU"
        F.CHEQUE.COLLECTION = ""
        EB.DataAccess.Opf(FN.CHEQUE.COLLECTION, F.CHEQUE.COLLECTION)
        SEL.CMD = "SELECT ":FN.CHEQUE.COLLECTION:' WITH TXN.ID EQ ':TXN.CONTRACT.ID
        CHEQUE.COLLECTION.ID = ''
        EB.DataAccess.Readlist(SEL.CMD, CHEQUE.COLLECTION.ID, '', '', RET.CODE)
        IF CHEQUE.COLLECTION.ID THEN ;* If unauth Cheque.collection record exists, then assign the transaction id with cheque.collection id 
            TXN.CONTRACT.ID = CHEQUE.COLLECTION.ID
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= REV.REPLAY.CHK>
REV.REPLAY.CHK:
*** <desc>While Reverse and Replay check to find activities that should be dislpayed for authorisation. </desc>

    R.AAA = '' ; NEW.OR.MASTER.ACT = '' ; ALLOW.ACTIVITY.PROC.FLAG = ''
    R.AAA = AA.Framework.ArrangementActivity.ReadNau(R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivityRef,CNT.DT,CNT.ACT>, READ.ERR)
    MASTER.ID = R.AAA<AA.Framework.ArrangementActivity.ArrActMasterAaa>
    REV.MASTER.ID = R.AAA<AA.Framework.ArrangementActivity.ArrActRevMasterAaa>
    ACT.REF.ID =  R.AA.ACT.HIST<AA.Framework.ActivityHistory.AhActivityRef,CNT.DT,CNT.ACT>

    IF REV.MASTER.ID NE '' THEN         ;* If reversal has happened
        IF REV.MASTER.ID EQ ACT.REF.ID THEN
            ALLOW.ACTIVITY.PROC.FLAG = '1'
        END
    END ELSE        ;* Other activities that do not involve reverse/replay.
        IF MASTER.ID EQ ACT.REF.ID THEN
            ALLOW.ACTIVITY.PROC.FLAG = '1'
        END
    END

RETURN
END
