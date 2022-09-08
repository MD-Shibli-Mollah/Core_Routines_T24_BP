* @ValidationCode : Mjo0NjIwMzI5MjM6Y3AxMjUyOjE2MDExODg5NTIzNjI6c2Fpa3VtYXIubWFra2VuYToyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6MjU6MjI=
* @ValidationInfo : Timestamp         : 27 Sep 2020 12:12:32
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : saikumar.makkena
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 22/25 (88.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-128</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.LAST.TRANSACTION.DATE
*
*--------------------------------------------------------------------------------
*** <region name= Program Description>
***
*  This enquiry routine will get the latest transaction time happend on the customer account.
*
*** </region>
*--------------------------------------------------------------------------------

*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* Output
*
*** </region>
*--------------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Change descriptions</desc>
* Modification History :
*
* 03/11/2016 - Task : 1902891
*              Enhancement : 1864620
*              Get the last transaction date and time from statement entry record.
*
* 18/04/2017 - Task : 2092409
*              Defect : 2092383
*              Operand should be passsed as numeric value to the routine AC.GET.ACCT.ENTRIES.
*
* 09/09/19 - Enhancement 3308396 / Task 3308399
*            TI Changes - Component moved from ST to AC.
*
* 14/09/20 - Enhancement 3934727 / Task 3940554
*            Reference of EB.CONTRACT.BALANCES is changed from RE to BF
*** </region>
*--------------------------------------------------------------------------------
*
*** <region name= Inserts>
*** <desc>Inserts used in the sub-routine</desc>

    $USING EB.Reports
    $USING BF.ConBalanceUpdates
    $USING RE.ConBalanceUpdates
    $USING AC.AccountStatement
    $USING AC.EntryCreation
    $USING AC.API

*** </region>
*--------------------------------------------------------------------------------
*
*** <region name= Main Program block>
*** <desc>Main processing logic</desc>

    GOSUB GET.ACCOUNT.OS.BALANCE

RETURN
*** </region>
*--------------------------------------------------------------------------------

*** <region name= Get Account Os Balance>
*** <desc>Get account outstanding balance</desc>
GET.ACCOUNT.OS.BALANCE:

    ACCOUNT.NO =  EB.Reports.getOData()

** Get the last transaction input date from the ECB record
    EbContractBalRec = ""
    AC.API.EbReadContractBalances(ACCOUNT.NO, EbContractBalRec, "", "")
    FROM.DATE = EbContractBalRec<BF.ConBalanceUpdates.EbContractBalances.EcbLastAcBalUpd>
    END.DATE = FROM.DATE

** STMT.PRINTED is the table will hold all the entries rasied for account for particulor day

** Here is the logic to get the last transaction date & time
*** 1. Read the STMT.PRINTED record by using EB.ACCT.ENTRY.LIST routine
*** 2. Get the last stmt number
*** 3. Read the STMT.ENTRY record by using this number. If record exist then take the date and time from the record
*** 4. If the record is not exist then read the STMT.ENTRY.DETAIL record and take the date and time from that record.

** This routine will give the list of statement entries in between start date and end date

    OPERAND = '1'
    AC.AccountStatement.AcGetAcctEntries(ACCOUNT.NO, OPERAND, FROM.DATE, FROM.DATE, STMT.ENTRY.LIST)

** Sort the all statement entries and take the last transaction date and time from the latest statement entry record.

    IF STMT.ENTRY.LIST THEN
        NO.ENTRIES = DCOUNT(STMT.ENTRY.LIST, @FM)

        LATEST.STMT.NO = STMT.ENTRY.LIST<NO.ENTRIES>           ;* Get the latest entry from the list.

        STMT.ENTRY.REC = AC.EntryCreation.StmtEntry.Read(LATEST.STMT.NO, RET.ERROR)       ;* Read the statement entry record

        IF STMT.ENTRY.REC THEN
            LAST.TRANSACTION.DATE = STMT.ENTRY.REC<AC.EntryCreation.StmtEntry.SteDateTime>
        END ELSE
            STMT.ENTRY.REC = AC.EntryCreation.StmtEntryDetail.Read(LATEST.STMT.NO, RET.ERROR)       ;* Read the statement entry detail record
            LAST.TRANSACTION.DATE = STMT.ENTRY.REC<AC.EntryCreation.StmtEntry.SteDateTime>
        END

        EB.Reports.setOData(LAST.TRANSACTION.DATE)

    END ELSE
        LAST.TRANSACTION.DATE = ''            ;* There is no statement entries.  So let display last transaction date as Null
        EB.Reports.setOData(LAST.TRANSACTION.DATE)
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
