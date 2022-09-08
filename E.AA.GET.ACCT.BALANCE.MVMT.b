* @ValidationCode : MjotMTAxMzcxMjQ5NzpjcDEyNTI6MTYwMTE4NTQ4MDAyOTpzYWlrdW1hci5tYWtrZW5hOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOi0xOi0x
* @ValidationInfo : Timestamp         : 27 Sep 2020 11:14:40
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-85</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.ACCT.BALANCE.MVMT(ACTIVITY.MVMT)

* For the given arrangement id and balance type, returns the balance movements by reading ACCT.BALANCE.ACTIVITY

* Parameters
* Out - ACTIVITY.MVMT - Returns the Movements in arrangement
*
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History
*
* 12/01/11 - Task - 129174
*			 New routine to fetch movements of specific balance type of a arrangement.
*
* 18/03/20 - Task 3646291
*            Defect 3640392
*            Uninitialized variable error
*
* 14/09/20 - Enhancement 3934727 / Task 3940554
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts

    $USING AA.Framework
    $USING AC.BalanceUpdates
    $USING BF.ConBalanceUpdates
    $USING RE.ConBalanceUpdates
    $USING AC.API
    $USING EB.SystemTables
    $USING EB.Reports




*** </region>
*---------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inilialise>
*** <desc>Initialise variables</desc>

INITIALISE:

    ACTIVITY.IDS = ''

    F.EB.CONTRACT.BALANCES.LOC = ''

    START.YRMTH = ''
    END.YRMTH = ''
    ACCOUNT.NO = ''


RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>Process validation</desc>
PROCESS:

    LOCATE "ARRANGEMENT.ID" IN EB.Reports.getDFields()<1> SETTING ARR.POS ELSE
        RETURN
    END

    LOCATE "BALANCE.TYPE" IN EB.Reports.getDFields()<1> SETTING BAL.POS ELSE
        RETURN
    END

    ACCT.YR = ''
    LOCATE "START.YEAR.MONTH" IN EB.Reports.getDFields()<1> SETTING START.POS THEN
        START.YRMTH = EB.Reports.getDRangeAndValue()<START.POS>
    END

    ACCT.MTH = ''
    LOCATE "END.YEAR.MONTH" IN EB.Reports.getDFields()<1> SETTING END.POS THEN
        END.YRMTH = EB.Reports.getDRangeAndValue()<END.POS>
    END

    BEGIN CASE
        CASE START.YRMTH AND NOT(END.YRMTH)
            END.YRMTH = START.YRMTH

        CASE NOT(START.YRMTH) AND END.YRMTH
            START.YRMTH = END.YRMTH

        CASE NOT(START.YRMTH) AND NOT(END.YRMTH)
            START.YRMTH = EB.SystemTables.getToday()[1,6]
            END.YRMTH = EB.SystemTables.getToday()[1,6]
    END CASE

    ARR.ID = EB.Reports.getDRangeAndValue()<ARR.POS>
    BAL.TYPE = EB.Reports.getDRangeAndValue()<BAL.POS>

    AA.Framework.GetArrangement(ARR.ID, R.ARR, ARR.ERR)

* Get the account number
    LOCATE "ACCOUNT" IN R.ARR<AA.Framework.Arrangement.ArrLinkedAppl,1> SETTING POS THEN
        ACCOUNT.NO = R.ARR<AA.Framework.Arrangement.ArrLinkedApplId,POS>
    END

    GOSUB READ.BALANCES

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Read Balances>
*** <desc> Read Balance of given balance type</desc>
READ.BALANCES:

    ACCT.ACTIVITY.REC = ''
    ACCT.ID = ACCOUNT.NO:'.':BAL.TYPE

    VALUE.OR.TRADE = "VALUE"

    GOSUB READ.ECB

    ACCT.IDX = 1
    LOOP
        ACTIVITY.ID = ACTIVITY.IDS<ACCT.IDX>
    WHILE ACTIVITY.ID
        AC.API.EbGetAcctActivity(ACCT.ID, "", ACTIVITY.ID, VALUE.OR.TRADE, "", ACCT.ACTIVITY.REC)

* Loop the each day in acct.activity to form dates
        PARSE.DATES = DCOUNT(ACCT.ACTIVITY.REC<1>,@VM)
        FOR ADD.DATE = 1 TO PARSE.DATES
            ACCT.DATE = ACTIVITY.ID:ACCT.ACTIVITY.REC<1,ADD.DATE>
            GOSUB GET.BALANCES
        NEXT ADD.DATE

        ACCT.IDX += 1
    REPEAT

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get the activity record>
*** <desc>Get the activity movements</desc>
GET.BALANCES:

    REQUEST.TYPE = ''
    REQUEST.TYPE<2> = 'ALL'
    AA.Framework.GetPeriodBalances(ACCOUNT.NO, BAL.TYPE, REQUEST.TYPE, ACCT.DATE, "", "", BAL.DETAILS, "")

    IF BAL.DETAILS THEN
        ACTIVITY.MVMT<-1> = BAL.DETAILS<AC.BalanceUpdates.AcctActivity.IcActDayNo>:"*":BAL.DETAILS<AC.BalanceUpdates.AcctActivity.IcActTurnoverCredit>:"*":BAL.DETAILS<AC.BalanceUpdates.AcctActivity.IcActTurnoverDebit>:"*":BAL.DETAILS<AC.BalanceUpdates.AcctActivity.IcActBalance>
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Read EB.CONTRACT.BALANCES>
*** <desc>Read ECB to fetch the activity ids for given period</desc>
READ.ECB:

    R.ECB = BF.ConBalanceUpdates.EbContractBalances.Read(ACCOUNT.NO, ECB.ERR)
    LOCATE BAL.TYPE IN R.ECB<BF.ConBalanceUpdates.EbContractBalances.EcbBalType,1> SETTING BT.POS THEN
        LOCATE START.YRMTH IN R.ECB<BF.ConBalanceUpdates.EbContractBalances.EcbBtActMonths, BT.POS, 1> BY "AR" SETTING START.ACCT.POS ELSE
            IF START.ACCT.POS NE 1 THEN
                START.ACCT.POS -= 1
            END
        END
        LOCATE END.YRMTH IN R.ECB<BF.ConBalanceUpdates.EbContractBalances.EcbBtActMonths, BT.POS, 1> BY "AR" SETTING END.ACCT.POS ELSE
            END.ACCT.POS -= 1
        END
        IF START.ACCT.POS AND END.ACCT.POS THEN
            GOSUB FORM.ACTIVITY.DATES
        END
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Activity Ids>
*** <desc>Get the Activity ids for given period</desc>
FORM.ACTIVITY.DATES:

    FOR IDX = START.ACCT.POS TO END.ACCT.POS
        ACTIVITY.IDS<-1> = R.ECB<BF.ConBalanceUpdates.EbContractBalances.EcbBtActMonths, BT.POS, IDX>
    NEXT IDX

RETURN

*** </region>
*-----------------------------------------------------------------------------
END
