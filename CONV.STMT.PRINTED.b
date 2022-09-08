* @ValidationCode : MjoxNDIwMTg0NTk4OkNwMTI1MjoxNTY0NTY3NDA0MjM0OnNyYXZpa3VtYXI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDYxMi0wMzIxOi0xOi0x
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
$PACKAGE AC.AccountStatement
SUBROUTINE CONV.STMT.PRINTED(ACCT.STMT.ID)
*-----------------------------------------------------------------------------
* <Rating>-56</Rating>
*
** This subroutine will move all entries from ACCT.STMT.ENTRY onto STMT.PRINTED for
** the next statement date and then clear ACCT.STMT.ENTRY
*
*------------------------------------------------------------------------------------
* 11/07/05 - EN_10002592
*            Online Update of Statement concat files
* 24/10/05 - BG_100009578
*            Conversion made a service
* 06/06/06 - BG_100011082 / REF: HD0606787
*            Conversion made as a COB process.Performance Changes also
*            done for Trade dated system
* 18/07/06 - CI_10042696 / REF: HD0608555
*            Changes done to process the PASSBOOK accounts.
*
* 27/07/06 - CI_10042977
*          - If there exists ACCT.ENT.TODAY for an account, then after
*          - upgrade, the output of STMT.ENT.BOOK dont sync with the
*          - account balances. This will happen even for accounts which
*          - have both ACCT.STMT2.ENTRY & ACCT.ENT.BOOK
*
* 08/08/06 - CI_10043185 /REF: HD0611256
*            Removal of seperate processing for Trade dated and Value dated system.
*
* 12/12/08 - BG_100021277
*            F.READ, F.WRITE, F.DELETE and F.RELEASE are changed to READ, WRITE,
*            DELETE and RELEASE respectively.
*
* 30/07/19 - Enhancement 3181538 / Task 3181750
*            TI Changes - Component moved from ST to AC.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DATES
    $INSERT I_F.ACCOUNT
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.ACCOUNT.STATEMENT
    $INSERT I_EOD.AC.CONV.ENTRY.COMMON
*-----------------------------------------------------------------------------
*
    GOSUB INITIALISE
*
    GOSUB PROCESS
*
RETURN

*-----------------------------------------------------------------------------
INITIALISE:
***
    R.ACCT.STMT = ""
    R.ACCOUNT = ""
    R.ACCT.STMT.ENTRY = ""
    R.ACCT.STMT.PRINT = ""
    R.STMT.PRINTED = ''
    NEXT.DATE = ""
    NEXT.DATES = ""
    STMT.DATES = ""
    STMT.BALS = ""
    STMT.PRINTED.ID = ""
    STMT.FIELD = AC.STA.STMT.FQU.1

RETURN

*-----------------------------------------------------------------------------
PROCESS:
***
    READ R.ACCT.STMT FROM F.ACCOUNT.STATEMENT, ACCT.STMT.ID ELSE
        R.ACCT.STMT = ""
    END
*
    READ R.ACCOUNT FROM F.ACCOUNT, ACCT.STMT.ID THEN
        GOSUB FIND.NEXT.DATE
*
        STMT.PRINTED.ID = ACCT.STMT.ID:"-":NEXT.DATE
        READ R.ACCT.STMT.ENTRY FROM F.ACCT.STMT.ENTRY, ACCT.STMT.ID ELSE
            R.ACCT.STMT.ENTRY = ""
        END

        READ R.STMT.PRINTED FROM F.STMT.PRINTED, STMT.PRINTED.ID ELSE
            R.STMT.PRINTED = ""
        END
        IF R.STMT.PRINTED THEN
            R.ACCT.STMT.ENTRY<-1> = R.STMT.PRINTED
        END

        WRITE R.ACCT.STMT.ENTRY TO F.STMT.PRINTED, STMT.PRINTED.ID
*
        GOSUB UPDATE.ACCT.STMT.PRINT
*
        DELETE F.ACCT.STMT.ENTRY, ACCT.STMT.ID    ;* Remove the record
*
    END

RETURN

*-----------------------------------------------------------------------------
FIND.NEXT.DATE:
*** Find the Date to be updated in STMT.PRINTED from FQU.1 of ACCOUNT.STATEMENT

    BEGIN CASE

        CASE R.ACCOUNT<AC.PASSBOOK> = 'Y'   ;* passboook ac
            NEXT.DATE = "PASSBOOK"

        CASE 1

            FQU.CNT = DCOUNT(R.ACCT.STMT<STMT.FIELD>,VM)
            FOR FQU.ID = 1 TO FQU.CNT
                NEXT.DATES<-1> = R.ACCT.STMT<STMT.FIELD,FQU.ID>[1,8]
            NEXT FQU.ID
            NEXT.DATE = MINIMUM(NEXT.DATES)
*
* If Special stmt freq is also set , then get the eariest stmt date.
*
            SPECIAL.STMT.DATE = R.ACCT.STMT<AC.STA.SPECIAL.STATEMENT>
            IF SPECIAL.STMT.DATE THEN
                IF SPECIAL.STMT.DATE LT NEXT.DATE THEN
                    NEXT.DATE = SPECIAL.STMT.DATE
                END
            END
*
            GOSUB GET.CORRECT.STMT.DATE
*
    END CASE

RETURN

*-----------------------------------------------------------------------------
GET.CORRECT.STMT.DATE:
*** Check the stmt.date is falling on holiday, if so take preious
***       working day from stmt.date as new stmt.date.
    Y.PREV.DATE = NEXT.DATE
    CALL CDT("", Y.PREV.DATE, "-01W")
    Y.NEXT.DATE = Y.PREV.DATE
    CALL CDT("", Y.NEXT.DATE, "+01W")
    IF Y.NEXT.DATE NE NEXT.DATE THEN
        NEXT.DATE = Y.PREV.DATE
    END

RETURN

*-----------------------------------------------------------------------------
UPDATE.ACCT.STMT.PRINT:
***
    LAST.BAL = R.ACCT.STMT<AC.STA.FQU1.LAST.BALANCE>
    IF LAST.BAL = '' THEN
        LAST.BAL = 0
    END

    READU R.ACCT.STMT.PRINT FROM F.ACCT.STMT.PRINT, ACCT.STMT.ID ELSE
        R.ACCT.STMT.PRINT = ""
    END
    STMT.DATES = FIELDS(R.ACCT.STMT.PRINT,"/",1,1)
    STMT.BALS = FIELDS(R.ACCT.STMT.PRINT,"/",2,1)

    LOCATE NEXT.DATE IN STMT.DATES<1> BY "AR" SETTING DATE.POS THEN
        RELEASE F.ACCT.STMT.PRINT, ACCT.STMT.ID
    END ELSE
        INS NEXT.DATE BEFORE STMT.DATES<DATE.POS>
        INS LAST.BAL BEFORE STMT.BALS<DATE.POS>
        R.ACCT.STMT.PRINT = SPLICE(STMT.DATES, "/", STMT.BALS)
        WRITE R.ACCT.STMT.PRINT TO F.ACCT.STMT.PRINT, ACCT.STMT.ID
    END

RETURN

*-----------------------------------------------------------------------------
END
