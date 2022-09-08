* @ValidationCode : MjotMjgyNjEzNzgzOmNwMTI1MjoxNjAxMTg4OTUyMjUzOnNhaWt1bWFyLm1ha2tlbmE6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjg5Ojgy
* @ValidationInfo : Timestamp         : 27 Sep 2020 12:12:32
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 82/89 (92.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-104</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.COLLATERAL.RIGHT.IDS(ENQ.DATA)
*
* Subroutine Type : ENQUIRY
* Attached to     : AA.DETAILS.COLLATERAL.ACCOUNT
* Attached as     : BUILD.ROUTINE
* Primary Purpose : Get the arrangement ID passed in Selection Criteria, fetch
*                   the Collateral Right IDs and pass it back in the Selection
*                   Criteria for the field COLLATERAL.RIGHT which is a C Type
*                   I-Desc in COLLATERAL table.
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
* 13 Apr 2015 - Defect: 1310419
*               Task: 1314533
*               All Collateral details displayed in the Loan overview screen
*
* 05 Jul 2018 - Defect: 2643941
*               Task: 2662960
*               Display collateral details even when LIM.REF is not present
*
* 19 Nov 2019 - Defect: 3436216
*               Task: 3443053
*               Null value returned in the return array when Collateral rights taken from limit hence all the collateral details displayed in the enquiry.
*
* 14/09/20 - Enhancement 3934727 / Task 3940554
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*-----------------------------------------------------------------------------------

    $USING AL.ModelBank
    $USING AA.Framework
    $USING BF.ConBalanceUpdates
    $USING RE.ConBalanceUpdates
    $USING AC.API
    $USING CO.Contract
    $USING LI.Config
    $USING AA.ModelBank

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

    IF ARR.COLL.RIGHT.ID.LIST THEN
        COLL.RIGHT.ID.LIST = ARR.COLL.RIGHT.ID.LIST
    END

    GOSUB GET.COLLATERAL.RIGHTS.FROM.LIMIT

    IF LIM.COLL.RIGHT.ID.LIST THEN
        IF COLL.RIGHT.ID.LIST THEN
            COLL.RIGHT.ID.LIST :=  @VM: LIM.COLL.RIGHT.ID.LIST
        END ELSE
            COLL.RIGHT.ID.LIST = LIM.COLL.RIGHT.ID.LIST
        END
    END

    COLL.RIGHT.ID.LIST = SORT(COLL.RIGHT.ID.LIST)
    CONVERT @FM TO " " IN COLL.RIGHT.ID.LIST

    IF COLL.RIGHT.ID.LIST THEN
        ENQ.DATA<4,COLL.RIGHT.IN.SELECTION.POS> = COLL.RIGHT.ID.LIST
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
GET.COLLATERAL.RIGHTS.FROM.LIMIT:

    LIMIT.ID = "" ; R.LIMIT = "" ; RETURN.ERROR = ""
    AA.ModelBank.EAaGetLimit(ARRANGEMENT.ID, LIMIT.ID, R.LIMIT, RETURN.ERROR)

    R.LI.COLLATERAL.RIGHT = ""  ; ERR.REC = ""
    R.LI.COLLATERAL.RIGHT = CO.Contract.LiCollateralRight.Read(LIMIT.ID, ERR.REC)
    
    TotCollRightCnt = ''
    CollRightCnt = ''
    TotCollRightCnt = DCOUNT(R.LIMIT<LI.Config.Limit.CollatRight>,@VM)
    ValidCollRight = ''
    FOR CollRightCnt = 1 TO TotCollRightCnt
        IF R.LIMIT<LI.Config.Limit.CollatRight,CollRightCnt> THEN
            IF ValidCollRight THEN
                ValidCollRight<1,-1> = R.LIMIT<LI.Config.Limit.CollatRight,CollRightCnt>
            END ELSE
                ValidCollRight = R.LIMIT<LI.Config.Limit.CollatRight,CollRightCnt>
            END
        END
    NEXT CollRightCnt
    
    IF R.LI.COLLATERAL.RIGHT THEN
        LIM.COLL.RIGHT.ID.LIST = R.LI.COLLATERAL.RIGHT
    END ELSE                ;  ;* If LI.COLLATERAL.RIGHT is empty , then take it from COLLATERAL.RIGHT
        LIM.COLL.RIGHT.ID.LIST =RAISE(ValidCollRight)
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
    COLL.RIGHT.IN.SELECTION.POS = ""
    ARR.COLL.RIGHT.ID.LIST = ""
    LIM.COLL.RIGHT.ID.LIST = ""
    COLL.RIGHT.ID.LIST = ""

    F.LI.COLLATERAL.RIGHT = ''

RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------
OPEN.FILES:

    F.AA.ARRANGEMENT = ""
RETURN          ;* From OPEN.FILES
*-----------------------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
*
* Check for any Pre requisite conditions - like the existence of a record/parameter etc
* if not, set PROCESS.GOAHEAD to 0

    LOOP.CNT = 1 ; MAX.LOOPS = 1
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO

        BEGIN CASE
            CASE LOOP.CNT EQ 1
                GOSUB GET.ARRANGEMENT.ID
                IF NOT(ARRANGEMENT.ID) THEN
                    PROCESS.GOAHEAD = 0
                END
            CASE LOOP.CNT EQ 2

        END CASE
        LOOP.CNT += 1
    REPEAT

RETURN          ;* From CHECK.PRELIM.CONDITIONS
*-----------------------------------------------------------------------------------
GET.ARRANGEMENT.ID:

    ARRANGEMENT.ID = ""
    LOCATE "COLLATERAL.RIGHT" IN ENQ.DATA<2,1> SETTING ARR.POS THEN
        ARRANGEMENT.ID = ENQ.DATA<4,ARR.POS>
        GOSUB GET.ARRANGEMENT.RECORD
        IF R.ARRANGEMENT THEN
            COLL.RIGHT.IN.SELECTION.POS = ARR.POS
        END ELSE
            ARRANGEMENT.ID = ""
        END
    END

RETURN
*-----------------------------------------------------------------------------------
GET.ARRANGEMENT.RECORD:

    R.ARRANGEMENT = AA.Framework.Arrangement.Read(ARRANGEMENT.ID, ERR.ARRANGEMENT)
RETURN
*-----------------------------------------------------------------------------------
END
