* @ValidationCode : MjoxMTU3NDA3MDY0OkNwMTI1MjoxNTY0NTY3NDA0MTQ3OnNyYXZpa3VtYXI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDYxMi0wMzIxOi0xOi0x
* @ValidationInfo : Timestamp         : 31 Jul 2019 15:33:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190612-0321
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-118</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.AccountStatement
SUBROUTINE CONV.STMT.PRINTED.R09(ASP.ID,FREQ.NO)

***This conversion routine is called from the Batch EOD.AC.CONV.ENTRY.
*The ID of STMT.PRINTED/ STMT2.PRINTED which are all not yet printed are changed
*to have ACCOUNT.STATEMENT frequency instead of previous working day.
*
***EOD.AC.CONV.ENTRY.SELECT selects all the record from ACCT.STMT.PRINT/
*ACCT.STMT2.PRINT. From each account selected, this conversion routine fetches
*the dates equal to today and greater than today.
*
***Using these dates forms the ID of STMT.PRINTED/ STMT2.PRINTED and deletes them.
*Also the corresponding date in ACCT.STMT.PRINT/ ACCT.STMT2.PRINT are deleted.
*This conversion routine calls the AC.UPDATE.STMT.PRINTED to form the new record in
*STMT.PRINTED/ STMT2.PRINTED with ACCOUNT.STATEMENT frequency  for the account
*
*------------------------------------------------------------------------------
*Modification History:
*---------------------
*
* 03/10/08 - EN_10003871
*            New conversion routine to convert the STMT.PRINTED/ STMT2.PRINTED ID
*            formed with previous working day to ACCOUNT.STATEMENT frequency
*
* 12/12/08 - BG_100021277
*            F.READ, F.WRITE, F.DELETE are replaced with READ, WRITE, DELETE
*            respectively.
*
* 06/11/09 - CI_10067376
*            COB hangs in the job EOD.AC.CONV.ENTRY in the process of finding statement date
*            for a closed account (there will not be any account statement record) and hence
*            goes for an infinite loop in the routine AC.UPDATE.STMT.PRINTED
*
* 30/07/19 - Enhancement 3181538 / Task 3181750
*            TI Changes - Component moved from ST to AC.
*
*-------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.ACCOUNT.STATEMENT
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.DATES
    $INSERT I_EOD.AC.CONV.ENTRY.COMMON
*-------------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB MAIN.PARA

RETURN
*--------------------------------------------------------------------------------
INITIALISE:
***********
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''

    R.ACCT.STMT = ''
    R.ACCT.STMT.PRINT = ''
    R.ACCT.STMT2.PRINT = ''

    Y.TODAY = TODAY
    Y.CNT = ''
    ACCT.ID = ''
    ENTRIES = ''
    ENTRIES.LIST = ''
*
RETURN
*
*------------------------------------------------------------------------------
*
OPEN.FILES:
**********
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
RETURN
*
*------------------------------------------------------------------------------
*
MAIN.PARA:
**********
    ACCT.ID = FIELD(ASP.ID,'.',1)

    GOSUB READ.ACCT

    IF R.ACCT<AC.PASSBOOK> EQ 'Y' THEN  ;*No need to run conversion for passbook accounts
        RETURN
    END

    GOSUB READ.ACCT.STMT

    BEGIN CASE
        CASE R.ACCT = "" AND R.ACCT.STMT = ""
            RETURN
        CASE R.ACCT  = "" AND R.ACCT.STMT
            IF R.ACCT.STMT<AC.STA.STMT.FQU.1> EQ "" THEN
                RETURN
            END
    END CASE
    IF FREQ.NO EQ 1 THEN      ;*normal frequency
        GOSUB PROCESS.STMT1.PRINTED
    END ELSE
        FREQ.NO = FIELD(ASP.ID,'.',2)
        IF FREQ.NO EQ '' THEN
            FREQ.NO = 2
        END
        GOSUB PROCESS.STMT2.PRINTED
    END
RETURN
*
*---------------------------------------------------------------------------------
*
READ.ACCT:
**********
    READ R.ACCT FROM F.ACCOUNT, ACCT.ID ELSE
        R.ACCT = ""
    END
RETURN
*
*---------------------------------------------------------------------------------
*
READ.ACCT.STMT:
***************
    READ R.ACCT.STMT FROM F.ACCOUNT.STATEMENT, ACCT.ID ELSE
        R.ACCT.STMT = ""
    END
RETURN
*----------------------------------------------------------------------------------
*
PROCESS.STMT1.PRINTED:
**********************
    READ R.ACCT.STMT.PRINT FROM F.ACCT.STMT.PRINT, ASP.ID ELSE        ;*read from ACCT.STMT.PRINT
        R.ACCT.STMT.PRINT = ""
    END
    IF R.ACCT.STMT.PRINT NE '' THEN
        STMT.DATES = FIELDS(R.ACCT.STMT.PRINT,"/",1,1)
        STMT.BALS = FIELDS(R.ACCT.STMT.PRINT,"/",2,1)
        TOT.DATES = DCOUNT(STMT.DATES,FM)
        LOCATE Y.TODAY IN STMT.DATES BY "AR" SETTING POS THEN
            NULL
        END
        LOOP
        UNTIL TOT.DATES LT POS
            DEL R.ACCT.STMT.PRINT<TOT.DATES>
            STMT.PRINTED.ID = ASP.ID:'-':STMT.DATES<TOT.DATES>
            TOT.DATES=TOT.DATES-1
            READ ENTRIES FROM F.STMT.PRINTED, STMT.PRINTED.ID ELSE
                ENTRIES = ""
            END
            DELETE F.STMT.PRINTED, STMT.PRINTED.ID

*For each account, accumulate all the entries in one array which are all not yet printed.
*----Then with each entry call AC.UPDATE.STMT.PRINTED

            ENTRIES.LIST<-1> = ENTRIES
        REPEAT

        GOSUB WRITE.ACCT.STMT.PRINT
        GOSUB UPDATE.ENTRIES
    END
RETURN
*
*-------------------------------------------------------------------------------
*
WRITE.ACCT.STMT.PRINT:
**********************
    IF R.ACCT.STMT.PRINT THEN
        WRITE R.ACCT.STMT.PRINT TO F.ACCT.STMT.PRINT, ASP.ID
    END ELSE
        DELETE F.ACCT.STMT.PRINT, ASP.ID
    END
RETURN
*
*-------------------------------------------------------------------------------
*
PROCESS.STMT2.PRINTED:
**********************
*read from STMT.STMT2.PRINT
    READ R.ACCT.STMT2.PRINT FROM F.ACCT.STMT2.PRINT, ASP.ID ELSE
        R.ACCT.STMT2.PRINT = ""
    END

    IF R.ACCT.STMT2.PRINT NE '' THEN
        STMT.DATES = FIELDS(R.ACCT.STMT2.PRINT,"/",1,1)
        STMT.BALS = FIELDS(R.ACCT.STMT2.PRINT,"/",2,1)
        TOT.DATES = DCOUNT(STMT.DATES,FM)

        LOCATE Y.TODAY IN STMT.DATES BY "AR" SETTING POS THEN
            NULL
        END
        LOOP
        UNTIL TOT.DATES LT POS
            DEL R.ACCT.STMT2.PRINT<TOT.DATES>
            STMT2.PRINTED.ID = ASP.ID:'-':STMT.DATES<TOT.DATES>
            TOT.DATES=TOT.DATES-1
            READ ENTRIES FROM F.STMT2.PRINTED, STMT2.PRINTED.ID ELSE
                ENTRIES = ""
            END
            DELETE F.STMT2.PRINTED, STMT2.PRINTED.ID

*For each account and for each frequency, accumulate all the entries in one array which are all not yet printed.
*----Then with each entry call AC.UPDATE.STMT.PRINTED

            ENTRIES.LIST<-1> = ENTRIES
        REPEAT
        GOSUB WRITE.ACCT.STMT2.PRINT
        ASP.ID = ACCT.ID
        GOSUB UPDATE.ENTRIES
    END
RETURN
*
*-------------------------------------------------------------------------------
*
WRITE.ACCT.STMT2.PRINT:
**********************
    IF R.ACCT.STMT2.PRINT THEN
        WRITE R.ACCT.STMT2.PRINT TO F.ACCT.STMT2.PRINT, ASP.ID
    END ELSE
        DELETE F.ACCT.STMT2.PRINT, ASP.ID
    END
RETURN
*
*-------------------------------------------------------------------------------
*
UPDATE.ENTRIES:
***************
    LOOP
        REMOVE ENTRY.ID FROM ENTRIES.LIST SETTING YD
    WHILE ENTRY.ID:YD
        R.ENTRY = ''
        READ R.ENTRY FROM F.STMT.ENTRY, ENTRY.ID ELSE
            R.ENTRY = ""
        END
        GOSUB DETERMINE.PROCESSING.DATE
        YERR = ''
        CALL AC.UPDATE.STMT.PRINTED(PROCESSING.DATE, ENTRY.ID, ASP.ID, R.ACCT.STMT, FREQ.NO, YERR)
    REPEAT
RETURN
*
*-------------------------------------------------------------------------------
*
DETERMINE.PROCESSING.DATE:
**************************

    SYSID = ''
    ANY.VD = ''
    VD.SYS = ''
    ENTRY.IN = R.ENTRY
    CALL AC.VALUE.DATED.ACCTNG(SYSID, ENTRY.IN, '', '', ANY.VD, VD.SYS)

    BEGIN CASE
        CASE R.ENTRY<AC.STE.PROCESSING.DATE>
            PROCESSING.DATE = R.ENTRY<AC.STE.PROCESSING.DATE>
        CASE VD.SYS AND R.ENTRY<AC.STE.VALUE.DATE> > R.DATES(EB.DAT.PERIOD.END) AND R.ENTRY<AC.STE.SUSPENSE.CATEGORY>
            PROCESSING.DATE = R.ENTRY<AC.STE.VALUE.DATE>
        CASE 1
            PROCESSING.DATE = Y.TODAY
    END CASE

RETURN
*
*---------------------------------------------------------------------------------
*
END
