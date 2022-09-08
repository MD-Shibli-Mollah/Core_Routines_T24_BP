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
* <Rating>-52</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.RMB1.GET.ACCT.BALANCE
*-----------------------------------------------------------------------------
*
* Subroutine Type : ENQUIRY API
* Attached to     : ENQUIRY
* Attached as     : Conversion Routine
* Primary Purpose : Triggered only for the first entry - it will get the VALUE.DATE
*                   of the entry and return the Account Balance as of that day
*
* Incoming:
* ---------
* O.DATA         :  Account Number
*
* Outgoing:
* ---------
* O.DATA         :  Account Balance
*
* Error Variables:
* ----------------
*
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* 10 NOV 2010 - Sathish PS
*               Development for SI RMB1
*
* 04/05/11 -   Task 203358 / Defect 154512
*              RMB1.LAST.N.TXNS.AA enquiry is not working for AA accounts
*
* 13/12/11  -  Defect 319668 / Task 320322
*              Balnaces need to be fetched for today's booking date for RMB1.LAST.N.TXNS.AA.
*
* 04/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-----------------------------------------------------------------------------------
    $USING EB.Reports
    $USING AA.Accounting
    $USING AC.API
    $USING AC.AccountOpening
    $USING AC.EntryCreation
*-----------------------------------------------------------------------------------
    GOSUB INITIALISE
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

    RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
INITIALISE:
**********
    PROCESS.GOAHEAD = 1
    ACCOUNT.NUMBER = EB.Reports.getOData()
    ARRANGEMENT.ID = FIELD(ACCOUNT.NUMBER, '*', 2)          ;*Incoming account number will be appended with the arrangement id
    ACCOUNT.NUMBER = FIELD(ACCOUNT.NUMBER, '*', 1)
    ACCOUNT.BALANCE = ''
    ERR.MSG = ''

    RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
***********************
    LOOP.CNT = 1 ; MAX.LOOPS = 0
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO

        BEGIN CASE
            CASE LOOP.CNT EQ 1

            CASE LOOP.CNT EQ 2

        END CASE

        LOOP.CNT += 1

    REPEAT

    RETURN          ;* From CHECK.PRELIM.CONDITIONS
*-----------------------------------------------------------------------------------
PROCESS:
********
    IF ARRANGEMENT.ID THEN
        R.ACCOUNT = AC.AccountOpening.tableAccount(ACCOUNT.NUMBER, ACC.ERR)
        AA.Accounting.GetAcctBalance(ACCOUNT.NUMBER, R.ACCOUNT, "BOOKING", "TODAY",'',ACCOUNT.BALANCE, '', '',ERR.MSG)
    END ELSE
        BALANCE.DATE = EB.Reports.getRRecord()<AC.EntryCreation.StmtEntry.SteValueDate>
        AC.API.EbGetAcctBalance(ACCOUNT.NUMBER,"","BOOKING",BALANCE.DATA,"",ACCOUNT.BALANCE,"","",ERR.MSG)
    END

    IF ERR.MSG THEN
        EB.Reports.setEnqError(ERR.MSG)
    END ELSE
        EB.Reports.setOData(ACCOUNT.BALANCE)
    END

    RETURN          ;* from PROCESS
*-----------------------------------------------------------------------------------

    END
