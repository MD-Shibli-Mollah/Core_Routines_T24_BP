* @ValidationCode : MjotOTI4NTk1OTk5OkNwMTI1MjoxNTcyNDI3NjA3NDc3OmthamFheXNoZXJlZW46LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwOS4yMDE5MDgyMy0wMzA1Oi0xOi0x
* @ValidationInfo : Timestamp         : 30 Oct 2019 14:56:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kajaayshereen
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201909.20190823-0305
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>2107</Rating>
*-----------------------------------------------------------------------------
* Version 4 02/06/00  GLOBUS Release No. 200508 30/06/05
* Version 9.1.0A released on 29/09/89
*
$PACKAGE AC.AccountStatement
SUBROUTINE CONVERT.ACCT.STMT.PRINT
*
* This routine will convert ACCT.STMT.PRINT and ACCT.STMT2.PRINT to hold
* the opening balance as well as the date that the statement was produced
*
* 10/02/03 - BG_100003426
*          - FREQU.RELATIONSHIP fld was deleted and its functionality
*          - handled by STMT.FQU.2 fld and FQU2.LAST.BALANCE field
*          - was changed to FQU2.LAST.BAL in an ACCT.STMT enchancement.
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT().
*
* 30/07/19 - Enhancement 3181538 / Task 3181750
*            TI Changes - Component moved from ST to AC.
*
* 30/10/19 - Enhancement 2822520 / Task 3411399
*            Strict compiler changes
*
* ----------------------------------------------------------------------
    $USING AC.AccountStatement
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STMT.ENTRY
*
*
* OPEN FILES
*
*
    F.ACCT.STMT.PRINT = ''
    CALL OPF('F.ACCT.STMT.PRINT',F.ACCT.STMT.PRINT)
    F.ACCOUNT.STMT = ''
    CALL OPF('F.ACCOUNT.STATEMENT',F.ACCOUNT.STMT)
    F.STMT.ENTRY = ''
    CALL OPF('F.STMT.ENTRY',F.STMT.ENTRY)
    F.STMT.PRINTED = ''
    CALL OPF('F.STMT.PRINTED',F.STMT.PRINTED)
    F.ACCT.STMT2.PRINT = ""
    CALL OPF("F.ACCT.STMT2.PRINT",F.ACCT.STMT2.PRINT)
    F.STMT2.PRINTED = ""
    CALL OPF("F.STMT2.PRINTED",F.STMT2.PRINTED)
    F.ACCOUNT.FILE ="F.ACCOUNT"
    F.ACCOUNT = ""
    CALL OPF(F.ACCOUNT.FILE,F.ACCOUNT)
*
*
* Select the ACCOUNT file
*
*
    CALL HUSHIT(1)
    EXECUTE 'SSELECT ':F.ACCOUNT.FILE
    YNO.RECORDS = @SYSTEM.RETURN.CODE
    CALL HUSHIT(0)
*
* Converted records are held in array as follows:
*     POSITION 1 - the account number
*     POSITION 2 - the converted ACCT.STMT.PRINT for the account
*     POSITION 3 - the converted ACCT.STMT2.PRINT for the account
*
    IF YNO.RECORDS = 0 THEN YNO.RECORDS =1
    DIM YRECORD.STORE(YNO.RECORDS,3)
    MAT YRECORD.STORE = ""
    YREC.NO = 1 ; YEXIT.PROG = 0
    CALL SF.CLEAR.STANDARD
    CALL SF.CLEAR(1,5,"FILES.RUNNING:  F.ACCT.STMT.PRINT, F.ACCT.STMT2.PRINT")
    LOOP
        READNEXT YACCT.ID ELSE YACCT.ID = 'END'
    UNTIL YACCT.ID = 'END'
        READ YR.ACCT.STMT.REC FROM F.ACCOUNT.STMT, YACCT.ID ELSE YR.ACCT.STMT.REC = ''
        IF YR.ACCT.STMT.REC<AC.AccountStatement.AccountStatement.AcStaCurrency> = LCCY THEN
            YAMOUNT.POS = AC.STE.AMOUNT.LCY
        END ELSE
            YAMOUNT.POS = AC.STE.AMOUNT.FCY
        END
        YOPEN.BAL = 0
        YCOUNT = 1
        YRECORD.STORE(YREC.NO,1) = YACCT.ID
        CALL SF.CLEAR(1,7,"RECORD RUNNING:   ":YRECORD.STORE(YREC.NO,1))
*
* If STMT1 and STMT2 are combined entries will appear only on 1 of the
* files, so a sorted list of the dates from ACCT.STMT.PRINT and
* ACCT.STMT".PRINT must be created, then processed.
*
        IF YR.ACCT.STMT.REC<AC.AccountStatement.AccountStatement.AcStaStmtFquTwo> THEN         ; * BG_100003426s/e
            GOSUB MAKE.LISTS
            LOOP
                YPRINTED.ID = YACCT.ID:'.':YACCT.STMT.DATES<YCOUNT>
            UNTIL YACCT.STMT.DATES<YCOUNT> = ''
                YACCT.STMT.DATES<YCOUNT> = YACCT.STMT.DATES<YCOUNT>:"/":YOPEN.BAL
                GOSUB READ.ENTRY.IDS
                GOSUB EXTRACT.ENTRIES
                YRECORD.STORE(YREC.NO,YACCT.STMT.TYPE<YCOUNT> + 1)<-1> = YACCT.STMT.DATES<YCOUNT>
                YCOUNT += 1
            REPEAT
        END ELSE
            READ YACCT.STMT.DATES FROM F.ACCT.STMT.PRINT,YACCT.ID ELSE YACCT.STMT.DATES = ''
            IF INDEX(YACCT.STMT.DATES,"/",1) NE 0 THEN
                GOSUB GET.OVERRIDE
            END ELSE
                LOOP
                    YPRINTED.ID = YACCT.ID:'.':YACCT.STMT.DATES<YCOUNT>
                UNTIL YACCT.STMT.DATES<YCOUNT> = ''
                    YACCT.STMT.DATES<YCOUNT> = YACCT.STMT.DATES<YCOUNT>:"/":YOPEN.BAL
                    READ YR.STMT.PRINTED.REC FROM F.STMT.PRINTED, YPRINTED.ID ELSE YR.STMT.PRINTED.REC = ''
                    GOSUB EXTRACT.ENTRIES
                    YCOUNT += 1
                REPEAT
                YRECORD.STORE(YREC.NO,2) = YACCT.STMT.DATES
                YOPEN.BAL = 0
                YCOUNT = 1
                READ YACCT.STMT.DATES FROM F.ACCT.STMT2.PRINT,YACCT.ID ELSE YACCT.STMT.DATES = ''
                IF INDEX(YACCT.STMT.DATES,"/",1) NE 0 THEN
                    GOSUB GET.OVERRIDE
                END ELSE
                    LOOP
                        YPRINTED.ID = YACCT.ID:'.':YACCT.STMT.DATES<YCOUNT>
                    UNTIL YACCT.STMT.DATES<YCOUNT> = ''
                        YACCT.STMT.DATES<YCOUNT> = YACCT.STMT.DATES<YCOUNT>:"/":YOPEN.BAL
                        READ YR.STMT.PRINTED.REC FROM F.STMT2.PRINTED, YPRINTED.ID ELSE YR.STMT.PRINTED.REC = ''
                        GOSUB EXTRACT.ENTRIES
                        YCOUNT += 1
                    REPEAT
                    YRECORD.STORE(YREC.NO,3) = YACCT.STMT.DATES
                END
            END
        END
        YREC.NO +=1
        IF YEXIT.PROG =1 THEN
            CLEARSELECT
            RETURN
        END
    REPEAT
    CALL SF.CLEAR(1,9,"WRITING AWAY CONVERTED RECORDS")
    FOR I = 1 TO YNO.RECORDS
        IF YRECORD.STORE(I,1) NE '' THEN
            IF YRECORD.STORE(I,2) NE "" THEN
                WRITE YRECORD.STORE(I,2) TO F.ACCT.STMT.PRINT,YRECORD.STORE(I,1)
            END
            IF YRECORD.STORE(I,3) NE '' THEN
                WRITE YRECORD.STORE(I,3) TO F.ACCT.STMT2.PRINT,YRECORD.STORE(I,1)
            END
        END
    NEXT
RETURN
*
*-----------------------------------------------------------------------
* SUBROUTINES
*-----------------------------------------------------------------------
*
MAKE.LISTS:
*
    READ YR.ACCT.STMT.PRINT FROM F.ACCT.STMT.PRINT,YACCT.ID ELSE YR.ACCT.STMT.PRINT = ''
    READ YR.ACCT.STMT2.PRINT FROM F.ACCT.STMT2.PRINT,YACCT.ID ELSE YR.ACCT.STMT2.PRINT = ''
    IF INDEX(YR.ACCT.STMT.PRINT,"/",1) NE 0 OR INDEX(YR.ACCT.STMT2.PRINT,"/",1) NE 0 THEN
        GOSUB GET.OVERRIDE
    END ELSE
        YACCT.STMT.DATES = "" ; YACCT.STMT.TYPE = ""
        LOOP
        UNTIL YR.ACCT.STMT.PRINT<1> = ''
            YACCT.STMT.DATES<-1> = YR.ACCT.STMT.PRINT<1>
            YACCT.STMT.TYPE<-1> = 1
            DEL YR.ACCT.STMT.PRINT<1>
        REPEAT
        READ YR.ACCT.STMT2.PRINT FROM F.ACCT.STMT2.PRINT,YACCT.ID ELSE YR.ACCT.STMT2.PRINT = ''
        LOOP
        UNTIL YR.ACCT.STMT2.PRINT<1> = ""
            YDATE = YR.ACCT.STMT2.PRINT<1>
            LOCATE YDATE IN YACCT.STMT.DATES<1> BY 'AR' SETTING YPOS ELSE NULL
            IF YDATE NE YACCT.STMT.DATES<YPOS> THEN
                INS YDATE BEFORE YACCT.STMT.DATES<YPOS>
                INS 2 BEFORE YACCT.STMT.TYPE<YPOS>
            END ELSE
                INS YDATE BEFORE YACCT.STMT.DATES<YPOS+1>
                INS 2 BEFORE YACCT.STMT.DATES<YPOS+1>
            END
            DEL YR.ACCT.STMT2.PRINT<1>
        REPEAT
*
    END
*
RETURN
*
*
READ.ENTRY.IDS:
*
    IF YACCT.STMT.TYPE<YCOUNT> = 1 THEN
        READ YR.STMT.PRINTED.REC FROM F.STMT.PRINTED,YPRINTED.ID ELSE YR.STMT.PRINTED.REC = ''
    END ELSE
        READ YR.STMT.PRINTED.REC FROM F.STMT2.PRINTED,YPRINTED.ID ELSE YR.STMT.PRINTED.REC = ''
    END
RETURN
*
*
EXTRACT.ENTRIES:
*
    LOOP
        REMOVE YSTMT.ID FROM YR.STMT.PRINTED.REC SETTING YCODE
    UNTIL YSTMT.ID = ''
        READ YR.STMT.REC FROM F.STMT.ENTRY,YSTMT.ID ELSE YR.STMT.REC = ''
        YOPEN.BAL += YR.STMT.REC<YAMOUNT.POS>
    REPEAT
RETURN
*
GET.OVERRIDE:
*
    TEXT = "CONVERSION ALREADY DONE"
    CALL OVE ; IF TEXT[1,1] = "N" THEN YEXIT.PROG = 1
RETURN
*
*
END
