* @ValidationCode : MjotNzc2MDg0OTc1OmNwMTI1MjoxNjAxMTg4OTUzMDE4OnNhaWt1bWFyLm1ha2tlbmE6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjcxOjY1
* @ValidationInfo : Timestamp         : 27 Sep 2020 12:12:33
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 65/71 (91.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-105</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.DETERMINE.LIMIT.DISPLAY(ENQ.DATA)
*
* Subroutine Type : ENQUIRY
* Attached to     : AA.OVERVIEW-SUBHEADING.LIMIT.COLLATERAL
* Attached as     : BUILD.ROUTINE
* Primary Purpose : The enquiry is a header enquiry running on SPF for name-sake.
*                   Get the Arrangement ID passed in Selection Criteria, check if
*                   there is Collateral Attached to the account or a limit attached
*                   to the account. If either or both satisfy, then change the
*                   Selection data to be 'SYSTEM'. If both are false, then leave
*                   the Selection data to be the Arrangement ID which would mean
*                   it returns no data and will be suppressed from being displayed
*                   in the Composite Screen.
*
*
* Incoming:
* ---------
*
*
* Outgoing:
* ---------
*
*
* Error Variables:
* ----------------
*
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* 15 Nov 2013 - Sathish PS
*               New Development
*
* 06/05/2020 - Task        : 3729564
*              Defect      : 3680741
*              Fix for missing Limit Enquiry in the Deal Overview Screen.
*
* 21/05/2020 - Task        : 3758304
*              Defect      : 3680741
*              Reversal Task
*
* 21/05/2020 - Task        : 3758694
*              Defect      : 3680741
*              Fix for missing Limit Enquiry in the Deal Overview Screen.
*
* 14/09/20 - Enhancement 3934727 / Task 3940554
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*-----------------------------------------------------------------------------------
    $USING AA.ModelBank
    $USING EB.Reports
    $USING AA.Framework
    $USING BF.ConBalanceUpdates
    $USING RE.ConBalanceUpdates
    $USING AC.API
    $USING AA.Limit


    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:

    GOSUB GET.COLLATERAL.RIGHTS.FROM.ARRANGEMENT
    GOSUB GET.LIMIT.ATTACHED.TO.ARRANGEMENT

;* For deal, there will be no limit ref and serial, only validation limit will be there

    IF ARR.COLL.RIGHT.ID.LIST OR LIMIT.REF OR VALIDATION.LIMIT THEN
        ENQ.DATA<4,ARR.ID.IN.SELECTION.POS> = "SYSTEM"
    END

RETURN          ;* from PROCESS
*-----------------------------------------------------------------------------------
GET.COLLATERAL.RIGHTS.FROM.ARRANGEMENT:

    ACCOUNT.NO = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId>
    R.EB.CONTRACT.BALANCES = ""

    AC.API.EbReadContractBalances(ACCOUNT.NO,R.EB.CONTRACT.BALANCES,YERR ,RECORD.LOCK)
    ARR.COLL.RIGHT.ID.LIST = R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbCollatRight>

RETURN
*-----------------------------------------------------------------------------------
GET.LIMIT.ATTACHED.TO.ARRANGEMENT:

    AA.ModelBank.EAaGetLimitRef(ARRANGEMENT.ID, LIMIT.REF, LIMIT.SERIAL, RETURN.ERROR)
    IF RETURN.ERROR THEN
        PROCESS.GOAHEAD = 0
    END

RETURN
*-----------------------------------------------------------------------------------
* <New Subroutines>

* </New Subroutines>
*-----------------------------------------------------------------------------------*
*//////////////////////////////////////////////////////////////////////////////////*
*////////////////P R E  P R O C E S S  S U B R O U T I N E S //////////////////////*
*//////////////////////////////////////////////////////////////////////////////////*
INITIALISE:

    PROCESS.GOAHEAD = 1
    ARR.ID.IN.SELECTION.POS = ""
    ARR.COLL.RIGHT.ID.LIST = ""
    LIMIT.REF = ""
    LIMIT.ID.LIST = ""
    GROUP.LEVEL = ''
    VALIDATION.LIMIT = ''

RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------
OPEN.FILES:

    F.AA.ARRANGEMENT = ""
    FN.ACCOUNT.LOC = "F.ACCOUNT"; F.ACCOUNT.LOC = ""

RETURN          ;* From OPEN.FILES
*-----------------------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
*
* Check for any Pre requisite conditions - like the existence of a record/parameter etc
* if not, set PROCESS.GOAHEAD to 0

    LOOP.CNT = 1 ; MAX.LOOPS = 2
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO

        BEGIN CASE
            CASE LOOP.CNT EQ 1
                IF EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFileName> NE 'SPF' THEN
                    EB.Reports.setEnqError('EB-FILE.NAME.NOT.SPF')
                    PROCESS.GOAHEAD = 0
                END

            CASE LOOP.CNT EQ 2
                GOSUB GET.ARRANGEMENT.ID
                IF NOT(ARRANGEMENT.ID) THEN
                    PROCESS.GOAHEAD = 0
                END

        END CASE
        LOOP.CNT += 1
    REPEAT

RETURN          ;* From CHECK.PRELIM.CONDITIONS
*-----------------------------------------------------------------------------------
GET.ARRANGEMENT.ID:

    ARRANGEMENT.ID = ""
    LOCATE "@ID" IN ENQ.DATA<2,1> SETTING ARR.POS THEN
        ARRANGEMENT.ID = ENQ.DATA<4,ARR.POS>
        GOSUB GET.ARRANGEMENT.RECORD
        IF R.ARRANGEMENT THEN
            ARR.ID.IN.SELECTION.POS = ARR.POS
        END ELSE
            ARRANGEMENT.ID = ""
        END
    END

RETURN
*-----------------------------------------------------------------------------------
GET.ARRANGEMENT.RECORD:

    R.ARRANGEMENT = AA.Framework.Arrangement.Read(ARRANGEMENT.ID, ERR.ARRANGEMENT)
    GROUP.LEVEL = R.ARRANGEMENT<AA.Framework.Arrangement.ArrGroupLevel>
    IF GROUP.LEVEL EQ "DEAL" THEN
        AA.Framework.GetArrangementConditions(ARRANGEMENT.ID, "LIMIT", '', '', '', Returnconditions, '')
        Returnconditions =RAISE(Returnconditions)
        VALIDATION.LIMIT = Returnconditions<AA.Limit.Limit.LimValidationLimit>
    END
RETURN
*-----------------------------------------------------------------------------------
END
