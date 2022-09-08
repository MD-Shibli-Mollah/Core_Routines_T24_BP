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
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.FMT.ACCT
*-----------------------------------------------------------------------------

*This is a conversion routine which is used to fecth the account description
*for the counter party account pertaining to the standaing ordering transaction
*-----------------------------------------------------------------------------
*
* 30/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-----------------------------------------------------------------------------

    $USING EB.Reports
    $USING AC.AccountOpening

    GOSUB INIT
    GOSUB PROCESS
    RETURN

INIT:
    ACCT.ID = EB.Reports.getOData()
    RETURN

PROCESS:
    R.ACCOUNT = AC.AccountOpening.tableAccount(ACCT.ID,ERR)
    ACCT.TITLE = R.ACCOUNT< AC.AccountOpening.Account.AccountTitleOne>

    EB.Reports.setOData(ACCT.TITLE)

    RETURN
