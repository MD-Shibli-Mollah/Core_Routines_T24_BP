* @ValidationCode : MDowOk4vQToxNjE2NjY2NjIwNTY2OnZlbG11cnVnYW46MDowOjA6MTpmYWxzZTpOL0E6Ti9BOjA6MA==
* @ValidationInfo : Timestamp         : 25 Mar 2021 15:33:40
* @ValidationInfo : Encoding          : N/A
* @ValidationInfo : User Name         : velmurugan
* @ValidationInfo : Nb tests success  : 0
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 0/0 (0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-28</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE VP.Config
    SUBROUTINE  AML.GET.CUSTOMER(AEM.ID,FIELD.INFO)
*-----------------------------------------------------------------------------
*A Sample routine released as part of AML profile that can be attached to
*AML.EXTRACT.MAPPING for STMT.ENTRY to fetch the customer ID corresponding
*to the account number in extracted entry. If the entry corresponds to nostro
*account,customer ID will be made null. This can be customised locally as
*per the client requirement.
*-----------------------------------------------------------------------------
*04/02/15 - Defect 1244830 / Task 1244909
*        - New routine creation
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*_
*-----------------------------------------------------------------------------
    $USING AC.EntryCreation
    $USING AC.AccountOpening
    $USING VP.Config

*
    GOSUB INITIALISE
    GOSUB GET.CUS

    RETURN
*-----------------------------------------------------------------------------
INITIALISE:
*-----------

    R.AML.TXN.ENTRY = VP.Config.AmlTxnEntry.Read(AEM.ID,AEM.ER)

    tmp.AML.REC.COUNT = VP.Config.getAmlRecCount()
    IF UNASSIGNED(tmp.AML.REC.COUNT) OR VP.Config.getAmlRecCount() = 0 THEN
        VP.Config.setAmlRecCount('1')
    END

    RETURN
*-----------------------------------------------------------------------------
GET.CUS:
*---------
* Pass the customer ID only for non nostro account entries

    TOTAL.CONT = DCOUNT(R.AML.TXN.ENTRY,@FM)
    VP.Config.setAmlRecCount(VP.Config.getAmlRecCount() + 1)

    tmp.AML.REC.COUNT = VP.Config.getAmlRecCount()
    STMT.REC = RAISE(R.AML.TXN.ENTRY<tmp.AML.REC.COUNT>)

    ACCOUNT.NO = STMT.REC<AC.EntryCreation.StmtEntry.SteAccountNumber>

    R.ACCOUNT = AC.AccountOpening.Account.Read(ACCOUNT.NO, ACC.ER)

    IF R.ACCOUNT<AC.AccountOpening.Account.Category> GE '5000' AND R.ACCOUNT<AC.AccountOpening.Account.Category> LE '5999' THEN
        FIELD.INFO = ''
    END ELSE
        FIELD.INFO = R.ACCOUNT<AC.AccountOpening.Account.Customer>
    END

    IF VP.Config.getAmlRecCount() GE TOTAL.CONT THEN
        VP.Config.setAmlRecCount(0)
    END

    RETURN
*-----------------------------------------------------------------------------
    END
