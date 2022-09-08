* @ValidationCode : MjotMTQ3Nzk4MDEwNjpjcDEyNTI6MTU5OTY3NzQ0MzE5ODpzYWlrdW1hci5tYWtrZW5hOjU6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MToyNzoyNw==
* @ValidationInfo : Timestamp         : 10 Sep 2020 00:20:43
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : 5
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 27/27 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.GET.AC.WORKING.BALANCE
*-----------------------------------------------------------------------------
*
* Consversion routine which gets the account ID in O.DATA and
* returns the Balance
*
*******************************************************************************\
*           MODIFICATION HISTORY
*******************************************************************************
*
* 09/06/2011 - EN-182574 / TASK 255332
*              Introduced new conversion routine for enquiry
*
* 29/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 28/06/17 - Enhancement 2117750 / Task 2160811
*            Added support for multi-currency accounts.
*
* 09/09/20 - Enhancement 3932648 / Task 3952625
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*******************************************************************************
*
    $USING EB.Reports
    $USING BF.ConBalanceUpdates
    $USING AC.HighVolume
    $USING AC.API
    $USING AC.AccountOpening

    ACCOUNT.ID = EB.Reports.getOData()
    GOSUB ReadAcctDetails ; *Read the Account details.
    ECB.RECORD = ''
    ECB.CACHE.FLAG = 'NO'
    MERGE.DATE = ''
    IF MULTI.CCY EQ 'YES' THEN
        AC.API.AcEcbCcyMerge(ACCOUNT.ID, '', ECB.CACHE.FLAG, MERGE.DATE, ECB.RECORD, '')
    END ELSE
        AC.HighVolume.EbReadHvt('EB.CONTRACT.BALANCES',ACCOUNT.ID,ECB.RECORD,'')
    END

    EB.Reports.setOData(ECB.RECORD<BF.ConBalanceUpdates.EbContractBalances.EcbWorkingBalance>)


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
