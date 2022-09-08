* @ValidationCode : Mjo0NTA4NjQ5ODU6Y3AxMjUyOjE1OTk2Nzc0NDQ0MTQ6c2Fpa3VtYXIubWFra2VuYToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6Mjk6MjE=
* @ValidationInfo : Timestamp         : 10 Sep 2020 00:20:44
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 21/29 (72.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank
SUBROUTINE E.GET.AC.TDGL.BALANCE
*-----------------------------------------------------------------------------
*
* Consversion routine which gets the account ID in O.DATA and
* returns the TDGL Balance
*
*******************************************************************************\
*           MODIFICATION HISTORY
*******************************************************************************
*
* 29/03/18 - Task 2160811
*            Conversion Routine to Return TDGL Balance
*
* 09/09/20 - Enhancement 3932648 / Task 3952625
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*******************************************************************************
*
    $USING EB.Reports
    $USING BF.ConBalanceUpdates
    $USING AC.HighVolume
    $USING AC.API
    $USING AC.ModelBank
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

    TDGL.BALANCE = ''
    TDGL.BALANCE = ECB.RECORD<BF.ConBalanceUpdates.EbContractBalances.EcbAuthPayMvmt> + ECB.RECORD<BF.ConBalanceUpdates.EbContractBalances.EcbAuthReceiveMvmt>
    EB.Reports.setOData(TDGL.BALANCE)


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
