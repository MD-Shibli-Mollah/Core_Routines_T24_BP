* @ValidationCode : MjotMTAyNDk5NzUyMzpjcDEyNTI6MTYwMTE4NTQ3OTQzNTpzYWlrdW1hci5tYWtrZW5hOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOi0xOi0x
* @ValidationInfo : Timestamp         : 27 Sep 2020 11:14:39
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
* <Rating>-86</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE AI.LAST.N.TXNS.CONVERSION.RTN
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
* 13/09/2013 -  Defect 764177 / Task 781918
*            -  �The Closing Balance of the enquiry AI.LAST.N.TXNS.LIST is showing wrong
*            -   whereas the Enquiry STMT.ENT.BOOK shows correct closing balance.
*
* 14/09/20 - Enhancement 3934727 / Task 3940554
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*-----------------------------------------------------------------------------------

    $USING AC.EntryCreation
    $USING AC.SoftAccounting
    $USING BF.ConBalanceUpdates
    $USING RE.ConBalanceUpdates
    $USING AC.API
    $USING EB.Reports



    GOSUB INITIALISE

    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:

    ACCOUNT.NUMBER = EB.Reports.getOData()
    ACCOUNT.BALANCE = 0
    ERR.MSG = ""
    BALANCE.TYPE = EB.Reports.getRRecord()<AC.EntryCreation.StmtEntry.SteBalanceType>
    IF BALANCE.TYPE THEN
        GOSUB CHECK.BALANCE.TYPE  ;*AA accounts
    END ELSE
        ACCOUNT.BALANCE = '' ; ERR.MSG = '' ;*normal accounts
        AC.API.EbGetAcctBalance(ACCOUNT.NUMBER,"","",BALANCE.DATE,"",ACCOUNT.BALANCE,"","",ERR.MSG)
    END
    IF ERR.MSG THEN
        EB.Reports.setEnqError(ERR.MSG)
    END ELSE
        EB.Reports.setOData(ACCOUNT.BALANCE)
    END

RETURN          ;* from PROCESS

*----------------------------------------------------------------------------------
CHECK.BALANCE.TYPE:
*----------------------------------------------------------------------------------
*This gosub is introduced to fetch the closing balance of AA accounts only. By Reading EB.CONTRACT.BALANCES and fetching the
*BAL.TYPE if the BAL.TYPE is set as STMT then the closing balance for AA account is calculated.

    R.EB.CONTRACT.BALANCES = '' ; ECB.ERR = ''
    R.EB.CONTRACT.BALANCES = BF.ConBalanceUpdates.EbContractBalances.Read(ACCOUNT.NUMBER, ECB.ERR)
    ECB.BALANCE.TYPES = R.EB.CONTRACT.BALANCES<BF.ConBalanceUpdates.EbContractBalances.EcbBalType>

    LOOP
        REMOVE BALANCE.TYPE FROM ECB.BALANCE.TYPES SETTING ECB.BAL.POS

    WHILE BALANCE.TYPE:ECB.BAL.POS

        R.AC.BALANCE.TYPE = '' ; BAL.TYPE.ERR = ''
        R.AC.BALANCE.TYPE = AC.SoftAccounting.BalanceType.CacheRead(BALANCE.TYPE, BAL.TYPE.ERR)

        IF R.AC.BALANCE.TYPE<AC.SoftAccounting.BalanceType.BtEntryType> EQ 'STMT' THEN
            GOSUB GET.AA.ACCOUNT.BALANCE
            ACCOUNT.BALANCE+=BALANCE
        END


    REPEAT
RETURN
*---------------------------------------------------------------------------------
GET.AA.ACCOUNT.BALANCE:
*------------------------------------------------------------------------------
    AA.ACCOUNT.ID = ACCOUNT.NUMBER:'.':BALANCE.TYPE

    BALANCE = '' ; ERR = ''
    SYS.BALANCE.TYPE = ''
    AC.API.EbGetAcctBalance(AA.ACCOUNT.ID, R.ACCOUNT, SYS.BALANCE.TYPE, BALANCE.DATE, SYSTEM.DATE, BALANCE, CR.MVMT, DR.MVMT, ERR)

RETURN
*-----------------------------------------------------------------------------------
* <New Subroutines>

* </New Subroutines>
*-----------------------------------------------------------------------------------*
*//////////////////////////////////////////////////////////////////////////////////*
*////////////////P R E  P R O C E S S  S U B R O U T I N E S //////////////////////*
*//////////////////////////////////////////////////////////////////////////////////*
INITIALISE:

    END.POS = ''
    LOCATE "IN.END.DATE" IN EB.Reports.getDFields()<1> SETTING END.POS THEN  ;*date for which balance is to be arrived
        BALANCE.DATE = EB.Reports.getDRangeAndValue()<END.POS>
    END

    PROCESS.GOAHEAD = 1
RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------
OPEN.FILES:


    F.EB.CONTRACT.BALANCES.LOC = ''

    F.AC.BALANCE.TYPE = ""

RETURN          ;* From OPEN.FILES


*-----------------------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
*
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
END
