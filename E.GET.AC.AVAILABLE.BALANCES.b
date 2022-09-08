* @ValidationCode : MjotMTg4MjQ0NTY2OTpjcDEyNTI6MTU5OTY3NzQ0MzY3MzpzYWlrdW1hci5tYWtrZW5hOjU6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTo0NTo0NA==
* @ValidationInfo : Timestamp         : 10 Sep 2020 00:20:43
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 44/45 (97.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.GET.AC.AVAILABLE.BALANCES(ENQ.DATA)
*-----------------------------------------------------------------------------
*
* NOFILE build routine which gets the account ID and
* returns the Balance
*
* CURRENCY*OPEN.AVAILABLE.BAL*AVAILABLE.DATE*AV.AUTH.DB.MVMT*AV.NAU.DB.MVMT*
* AV.AUTH.CR.MVMT*AV.NAU.CR.MVMT*AVAILABLE.BAL*FORWARD.MVMTS*FIRST.AF.DATE*NEXT.AF.DATE
*
********************************************************************
*          MODIFICATION HISTORY
********************************************************************
*
* 08/12/2011 - DEFECT 318296 / TASK 321307
*              New routine which returns the Available balance ladder details
*
* 29/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 28/06/17 - Enhancement 2117750 / Task 2160811
*            Added support for multi-currency accounts.
*
* 09/09/20 - Enhancement 3932648 / Task 3952625
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
********************************************************************
    $USING EB.Reports
    $USING BF.ConBalanceUpdates
    $USING AC.HighVolume
    $USING AC.API
    $USING AC.AccountOpening

    ACCOUNT.ID = EB.Reports.getDRangeAndValue()
    GOSUB ReadAcctDetails ; *Read the Account details.
    R.EB.CONTRACT.BALANCES = ''
    ECB.CACHE.FLAG = 'NO'
    MERGE.DATE = ''
    IF MULTI.CCY EQ 'YES' THEN
        AC.API.AcEcbCcyMerge(ACCOUNT.ID, '', ECB.CACHE.FLAG, MERGE.DATE, R.EB.CONTRACT.BALANCES, '')
    END ELSE
        AC.HighVolume.EbReadHvt('EB.CONTRACT.BALANCES',ACCOUNT.ID,R.EB.CONTRACT.BALANCES,'')
    END

    IF NOT(R.EB.CONTRACT.BALANCES) THEN
        RETURN
    END

    OPEN.AVAILABLE.BAL = R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbOpenAvailableBal>
    FIRST.AF.DATE = R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbFirstAfDate>
    NEXT.AF.DATE = R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbNextAfDate>
    AVAILABLE.DATE = RAISE(R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbAvailableDate>)
    AV.AUTH.DB.MVMT = RAISE(R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbAvAuthDbMvmt>)
    AV.NAU.DB.MVMT = RAISE(R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbAvNauDbMvmt>)
    AV.AUTH.CR.MVMT = RAISE(R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbAvAuthCrMvmt>)
    AV.NAU.CR.MVMT = RAISE(R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbAvNauCrMvmt>)
    AVAILABLE.BAL = RAISE(R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbAvailableBal>)
    FORWARD.MVMTS = RAISE(R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbForwardMvmts>)
    AVAIL.POS = 0
    LOOP
        AVAIL.POS +=1
    WHILE AVAILABLE.DATE<AVAIL.POS>
        ENQ.DATA<-1> = R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbCurrency>:'*':OPEN.AVAILABLE.BAL:'*':AVAILABLE.DATE<AVAIL.POS>:'*':AV.AUTH.DB.MVMT<AVAIL.POS>:'*':AV.NAU.DB.MVMT<AVAIL.POS>:'*':AV.AUTH.CR.MVMT<AVAIL.POS>:'*':AV.NAU.CR.MVMT<AVAIL.POS>:'*':AVAILABLE.BAL<AVAIL.POS>:'*':FORWARD.MVMTS<AVAIL.POS>:'*':FIRST.AF.DATE:'*':NEXT.AF.DATE
    REPEAT

RETURN
*-----------------------------------------------------------------------------

*** <region name= ReadAcctDetails>
ReadAcctDetails:
*** <desc>Read the Account details. </desc>

    YACCT.ID = ''
    BEGIN CASE
        CASE INDEX(ACCOUNT.ID, '*', '1') GT '0'
            YACCT.ID = FIELD(ACCOUNT.ID, '*', '1')
        CASE INDEX(ACCOUNT.ID, '.', '1') GT '0'
            YACCT.ID = FIELD(ACCOUNT.ID, '.', '1')
        CASE INDEX(ACCOUNT.ID, '-', '1') GT '0'
            YACCT.ID = FIELD(ACCOUNT.ID, '-', '1')
        CASE '1'
            YACCT.ID = ACCOUNT.ID
    END CASE
    ERR = ''
    ACCOUNT.REC = AC.AccountOpening.Account.Read(YACCT.ID, ERR)
    MULTI.CCY = ACCOUNT.REC<AC.AccountOpening.Account.MultiCurrency>

RETURN
*** </region>

END
