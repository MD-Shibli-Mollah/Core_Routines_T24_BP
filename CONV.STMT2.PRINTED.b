* @ValidationCode : MjotNTkxNjc2ODM2OkNwMTI1MjoxNTY0NTY3NDA0MzY0OnNyYXZpa3VtYXI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDYxMi0wMzIxOi0xOi0x
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

* Version n dd/mm/yy  GLOBUS Release No. 200510 29/09/05
*-----------------------------------------------------------------------------
* <Rating>-55</Rating>
$PACKAGE AC.AccountStatement
SUBROUTINE CONV.STMT2.PRINTED(ACCT.STMT2.ID)
*
** This subroutine will move all entries from ACCT.STMT2.ENTRY onto STMT.PRINTED for
** the next statement date and then clear ACCT.STMT.ENTRY
*
*------------------------------------------------------------------------------------
* 11/07/05 - EN_10002592
*            Online Update of Statement concat files
*
* 06/06/06 - BG_100011082 / REF: HD0606787
*            Conversion made as a COB process.Performance Changes also
*            done for Trade dated system
*
* 27/07/06 - CI_10042977
*          - If there exists ACCT.ENT.TODAY for an account, then after
*          - upgrade, the output of STMT.ENT.BOOK dont sync with the
*          - account balances. This will happen even for accounts which
*          - have both ACCT.STMT2.ENTRY & ACCT.ENT.BOOK
*
* 08/08/06 - CI_10043184 /REF: HD0611256
*            Removal of seperate processing for Trade dated and Value dated system.
*
* 12/12/08 - BG_100021277
*            Changed F.READ, F.WRITE, F.DELETE and F.RELEASE to READ, WRITE, DELETE
*            and RELEASE respectively
*
* 30/07/19 - Enhancement 3181538 / Task 3181750
*            TI Changes - Component moved from ST to AC.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DATES
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
    FQU = ACCT.STMT2.ID[".",2,1]
    IF FQU = '' THEN
        FQU = 2
    END
    ACCT.ID = ACCT.STMT2.ID[".",1,1]

    STMT.FIELD = AC.STA.STMT.FQU.2
    SPECIAL.STMT.FIELD = AC.STA.SPL.STMT.FQU2

    R.ACCT.STMT = ""
    R.ACCT.STMT2.ENTRY = ""
    R.ACCT.STMT2.PRINT = ""
    R.STMT2.PRINTED = ''
    NEXT.DATE = ""
    NEXT.DATES = ""
    STMT.DATES = ""
    STMT.BALS = ""
    STMT2.PRINTED.ID = ""
    LAST.BAL = ""
    FREQ1.LAST.BAL = ""

RETURN

*-----------------------------------------------------------------------------
PROCESS:
***
    READ R.ACCT.STMT FROM F.ACCOUNT.STATEMENT, ACCT.ID ELSE
        R.ACCT.STMT = ""
    END

    LOCATE FQU IN R.ACCT.STMT<AC.STA.FREQ.NO,1> SETTING FQU.IDX ELSE
        FQU.IDX = ''
    END

    IF R.ACCT.STMT<AC.STA.FREQ.NO,FQU.IDX> NE 2 THEN
        ASP.ID = ACCT.ID:".":R.ACCT.STMT<AC.STA.FREQ.NO,FQU.IDX>
    END ELSE
        ASP.ID = ACCT.ID
    END

    GOSUB FIND.NEXT.DATE

    STMT2.PRINTED.ID = ASP.ID:"-":NEXT.DATE
*
    READ R.ACCT.STMT2.ENTRY FROM F.ACCT.STMT2.ENTRY, ACCT.STMT2.ID ELSE
        R.ACCT.STMT2.ENTRY = ""
    END

    READ R.STMT2.PRINTED FROM F.STMT2.PRINTED, STMT2.PRINTED.ID ELSE
        R.STMT2.PRINTED = ""
    END
    IF R.STMT2.PRINTED THEN
        R.ACCT.STMT2.ENTRY<-1> = R.STMT2.PRINTED
    END

    WRITE R.ACCT.STMT2.ENTRY TO F.STMT2.PRINTED, STMT2.PRINTED.ID
*
    GOSUB UPDATE.ACCT.STMT2.PRINT
*
    DELETE F.ACCT.STMT2.ENTRY, ACCT.STMT2.ID      ;* Remove the record
*
RETURN

*-----------------------------------------------------------------------------
FIND.NEXT.DATE:
*** Find the Date to be updated in STMT2.PRINTED from FQU. of ACCOUNT.STATEMENT

    FQU.CNT = DCOUNT(R.ACCT.STMT<STMT.FIELD,FQU.IDX>,SM)
    FOR FQU.ID = 1 TO FQU.CNT
        NEXT.STMT.DATE.FQU = R.ACCT.STMT<STMT.FIELD,FQU.IDX,FQU.ID>
        NEXT.DATES<-1> = NEXT.STMT.DATE.FQU[1,8]
    NEXT FQU.ID
    NEXT.DATE = MINIMUM(NEXT.DATES)
*
* If Special stmt freq is also set , then get the eariest stmt date.
*
    IF SPECIAL.STMT.FIELD THEN
        IF R.ACCT.STMT<SPECIAL.STMT.FIELD,FQU.IDX,1> THEN
            IF R.ACCT.STMT<SPECIAL.STMT.FIELD,FQU.IDX,1>  LT NEXT.DATE THEN
                NEXT.DATE = R.ACCT.STMT<SPECIAL.STMT.FIELD,FQU.IDX,1>
            END
        END
    END
*
    GOSUB GET.CORRECT.STMT.DATE

RETURN
*-----------------------------------------------------------------------------
GET.CORRECT.STMT.DATE:
*** Check the stmt.date is falling on holiday, if so take preious
*** working day from stmt.date as new stmt.date.</desc>

    Y.PREV.DATE = NEXT.DATE
    CALL CDT("", Y.PREV.DATE, "-01W")
    Y.NEXT.DATE = Y.PREV.DATE
    CALL CDT("", Y.NEXT.DATE, "+01W")
    IF Y.NEXT.DATE NE NEXT.DATE THEN
        NEXT.DATE = Y.PREV.DATE
    END

RETURN

*-----------------------------------------------------------------------------
UPDATE.ACCT.STMT2.PRINT:
***
    FREQ1.LAST.BAL = R.ACCT.STMT<AC.STA.FQU1.LAST.BALANCE>
    IF FREQ1.LAST.BAL = '' THEN
        FREQ1.LAST.BAL = 0
    END
    LAST.BAL = R.ACCT.STMT<AC.STA.FQU2.LAST.BAL, FQU.IDX>
    IF LAST.BAL EQ "" THEN
        LAST.BAL = FREQ1.LAST.BAL
    END
    READU R.ACCT.STMT2.PRINT FROM F.ACCT.STMT2.PRINT, ASP.ID ELSE
        R.ACCT.STMT2.PRINT = ""
    END
    STMT.DATES = FIELDS(R.ACCT.STMT2.PRINT,"/",1,1)
    STMT.BALS = FIELDS(R.ACCT.STMT2.PRINT,"/",2,1)
    LOCATE NEXT.DATE IN STMT.DATES<1> BY "AR" SETTING DATE.POS THEN
        RELEASE F.ACCT.STMT2.PRINT, ASP.ID
    END ELSE
        INS NEXT.DATE BEFORE STMT.DATES<DATE.POS>
        INS LAST.BAL BEFORE STMT.BALS<DATE.POS>
        R.ACCT.STMT2.PRINT = SPLICE(STMT.DATES, "/", STMT.BALS)
        WRITE R.ACCT.STMT2.PRINT TO F.ACCT.STMT2.PRINT, ASP.ID
    END

RETURN

*-----------------------------------------------------------------------------
END
*
