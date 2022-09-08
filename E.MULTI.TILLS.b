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
* <Rating>327</Rating>
*-----------------------------------------------------------------------------
* Version n dd/mm/yy  GLOBUS Release No. 200510 29/09/05
*
    $PACKAGE TT.ModelBank
    SUBROUTINE E.MULTI.TILLS(ENQ.DATA)
*
*=======================================================================
* Modification History:
* ---------------------
* 20/08/03 EN_GLOBUS_10001964
*  New routine for Multi Tills enquiry.
*
* 25/05/11 - Enhancement - 182581 / Task- 191536
*            Moving Balances to ECB from Account Balance Fields.
*
*=======================================================================

    $USING TT.Config
    $USING TT.Contract
    $USING AC.AccountOpening
    $USING ST.Config
    $USING AC.BalanceUpdates
    $USING EB.Reports
    $USING EB.DataAccess

*
    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS.USER


    RETURN
*=======================================================================
*==============
PROCESS.USER:
*==============

    LOCATE 'USER.ID' IN EB.Reports.getDFields()<1> SETTING USR.POS ELSE USR.POS = ''
    IF USR.POS THEN
        * To give error if more than one account is entered in the selection
        tmp.D.RANGE.AND.VALUE = EB.Reports.getDRangeAndValue()
        SEL.CNT = DCOUNT(tmp.D.RANGE.AND.VALUE,@FM)
        EB.Reports.setDRangeAndValue(tmp.D.RANGE.AND.VALUE)
        IF SEL.CNT > '1' THEN
            EB.Reports.setEnqError('ONLY ONE USER ID SHOULD BE ENTERED FOR THE SELECTION')
            GOTO V$ERROR
        END
    END
*
    USER.ID = EB.Reports.getDRangeAndValue()
    TT.USER.REC = TT.Contract.TellerUser.Read(USER.ID, READ.FAILED)
    IF READ.FAILED THEN
        EB.Reports.setEnqError('TILL DOES NOT EXIST FOR THE USER')
        GOTO V$ERROR
    END
*
    GOSUB GET.CATEG.ACCTS
*
    LOOP
        REMOVE TILL.ID FROM TT.USER.REC SETTING TILL.POS
    WHILE TILL.ID:TILL.POS
        EB.DataAccess.Dbr("TELLER.ID":@FM:TT.Contract.TellerId.TidStatus, TILL.ID, TILL.STATUS)
        GOSUB GET.ACCT.LIST
        LOOP
            REMOVE ACCT.ID FROM TT.ACCT.REC SETTING ACC.POS
        WHILE ACCT.ID:ACC.POS
            ACCT.REC = AC.AccountOpening.Account.Read(ACCT.ID, READ.ERROR)
            EB.DataAccess.Dbr("CATEGORY":@FM:ST.Config.Category.EbCatShortName, ACCT.REC<AC.AccountOpening.Account.Category>, AC.DESC)
            AC.CCY = ACCT.REC<AC.AccountOpening.Account.Currency>
            *
            *get Online actual balance using service routine.
            accountKey = ACCT.ID
            response.Details = ''
            onlineActualBal = ''
            AC.BalanceUpdates.AccountserviceGetonlineactualbalance(accountKey,onlineActualBal,response.Details)
            *
            AC.BAL = onlineActualBal<AC.BalanceUpdates.BalanceOnlineactualbal>
            IF AC.BAL = 0 THEN
                AC.BAL = 0.00
            END
            ENQ.DATA<-1> = TILL.ID:'*':TILL.STATUS:'*':AC.DESC:'*':AC.CCY:'*':AC.BAL
        REPEAT
    REPEAT
    CNT = DCOUNT(ENQ.DATA, @FM)
    IF CNT THEN ENQ.DATA<CNT> := '*':USER.ID
*
    RETURN
*
*=================
GET.CATEG.ACCTS:
*=================
*  Get the list of category's from Teller.Parameter and the corresponding
*  internal category accounts from account file.
*
    EB.DataAccess.Dbr("TELLER.PARAMETER":@FM:TT.Config.TellerParameter.ParTranCategory, 'SYSTEM', CATEG.LIST)
*
    LOOP
        REMOVE CATEG.ID FROM CATEG.LIST SETTING CATEG.POS
    WHILE CATEG.ID:CATEG.POS
        CATEG.ACCT.REC = AC.AccountOpening.CategIntAcct.Read(CATEG.ID, READ.ERROR)
        LOOP
            REMOVE CATEG.ACCT FROM CATEG.ACCT.REC SETTING CPOS
        WHILE CATEG.ACCT:CPOS
            CATEG.ACCT.LIST<-1> = CATEG.ACCT
        REPEAT
    REPEAT

    RETURN
*
*================
GET.ACCT.LIST:
*================
* A list of categ accounts for each till is formed from the list of
* internal categ accounts.
*
    TILL.ACCT = ''
    TT.ACCT.REC = ''
* Assign list of the category internal accounts to Till.Acct.List
* to select the list of Till accounts belonging to a Till.
    TILL.ACCT.LIST = CATEG.ACCT.LIST
    LOOP
        REMOVE TILL.ACCT FROM TILL.ACCT.LIST SETTING ACCT.POS
    WHILE TILL.ACCT:ACCT.POS
        IF TILL.ID = TILL.ACCT[4] THEN
            TT.ACCT.REC<-1> = TILL.ACCT
        END
    REPEAT

    RETURN
*
*============
OPEN.FILES:
*============
    F.TELLER.ID = ''

    F.TELLER.USER = ''

    F.CATEG.INT.ACCT = ''

    F.ACCOUNT = ''

    RETURN
*
*============
INITIALISE:
*============
    AC.CCY = ''
    AC.BAL = ''
    AC.DESC = ''
    USER.ID = ''
    ACCT.REC = ''
    CATEG.LIST = ''
    TILL.STATUS = ''
    TT.USER.REC = ''
    TT.ACCT.REC = ''
    CATEG.ACCT.REC = ''
    CATEG.ACCT.LIST = ''
*
    RETURN
*
*=========
V$ERROR:
*=========
    RETURN TO V$ERROR
    RETURN
*
*=======================================================================
    END
