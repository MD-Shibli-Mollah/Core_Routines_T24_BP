* @ValidationCode : MjotMTg3MDY3OTU2OkNwMTI1MjoxNTQyOTc3MzIxODgyOnBtYWhhOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTEuMjAxODEwMjItMTQwNjotMTotMQ==
* @ValidationInfo : Timestamp         : 23 Nov 2018 18:18:41
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : pmaha
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 30/08/00  GLOBUS Release No. G14.1.01 11/12/03
*-----------------------------------------------------------------------------
* <Rating>1402</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.API
SUBROUTINE SUB.NAMES.CHECK(IN.PRG.NAME,REC,ERROR.FLAG)
********************************************************************
* Program used to change or correct the routine name in th program
* eg. The VOC entry of the routine is CALC.DATE
* But in the routine  it isued as
*      SUBROUTINE CALC.DATE.1
* SUB.NAMES.CHECK will check and change such improper naming.
*
* Changes made.
*
* 28/06/00 - GB0001642
*            The record release part uses a different variable name
*            Also the no. of write fails shown is actually the no of read fails
*            Correct this to show the actual write failures.
*            Also the display of program names is duplicating - fixed
*            it by removing 'PRINT PROGS' in the case stmt for write.
*
* 21/08/00 - GB0002100
*            Changes made to make JBASE.CONVERSION as the main program.
*            The read/write operations are now shifted to JBASE.CONVERSION
*
* 22/08/00 - GB0002124
*            SUB.NAMES.CHECK does not insert routine name if the
*            routine is a PROGRAM and routine name is not used.
*
* 09/06/03 - CI_10009738
*            Jbase conversion of a function routine inserts the
*            keyword 'SUBROUTINE' in the first line.
*            Changes done to fix this.
*            CSS Ref No. HD0306086
*
* 25/11/03 - CI_10015199
*            Jbase Conversion of a FUNCTION routine does not correct
*            wrong FUNCTION names. Also does not insert FUNCTION name
*            if the FUNCTION name is not used.
*            CSS Ref No. HD0314877
*
* 20/11/18 - Enhancement 2822523 / Task 2843458
*            Incorporation of EB_API component
*
********************************************************************

    ARRAY1 = ''
    ARRAY2 = ''
    ARRAY3 = ''
    YTEXT = ''
    PROGS = IN.PRG.NAME                ; * GB0002100
*
*-----------------------------------------------------------------
*

* If item is an insert then skip it

    IF PROGS[1,2] = 'I_' THEN
        RETURN
    END

    FLAG = 0
    GOSUB SCAN.PROG
    CHANGE.PROG = 0

    BEGIN CASE
        CASE FLAG = 0
            SUBROUTINE.LINE = 'SUBROUTINE ':PROGS
            INS SUBROUTINE.LINE BEFORE REC<1>
            CHANGE.PROG = 1
        CASE FLAG = 2
            PRINT 'Routine is a PROGRAM. Please check and change manually'       ; * GB0002100
        CASE FLAG = 3
            CHANGE.PROG = 1
    END CASE

    ERROR.FLAG = CHANGE.PROG

RETURN                             ; * GB0002100


SCAN.PROG:

    NO.OF.LINES = DCOUNT(REC,@FM)
    FOR I = 1 TO NO.OF.LINES
        TRIM.LINE = TRIM(REC<I>)
        IF TRIM.LINE[1,1] = '*' OR TRIM.LINE[1,3] = 'REM' OR TRIM.LINE[1,1] = '!' OR TRIM.LINE = '' THEN
            CONTINUE
        END

*----------------------------------------------------------------------

*EXCLUSIVE CONDITION CHECK.

*----------------------------------------------------------------------

        IF TRIM.LINE[1,3] = 'SUB' THEN
            IF TRIM.LINE[4,7] = 'ROUTINE' THEN
                NAME.REST1 = TRIM.LINE[11,LEN(TRIM.LINE)-10]
                NAME.REST1 = TRIM(NAME.REST1)
            END ELSE
                NAME.REST1 = TRIM.LINE[4,LEN(TRIM.LINE)-3]
                NAME.REST1 = TRIM(NAME.REST1)
            END

            BEGIN CASE
                CASE NAME.REST1[1,1] = '('
                    REC<I> = 'SUBROUTINE ':PROGS:NAME.REST1
                    TRIM.LINE = TRIM(REC<I>)
                    FLAG = 3
                    EXIT
                CASE NAME.REST1[1,1] = '=' OR NAME.REST1 = ':'
                    EXIT
            END CASE

        END

        IF TRIM.LINE[1,4] = 'PROG' THEN
            IF TRIM.LINE[5,3] = 'RAM' THEN
                NAME.REST1 = TRIM(TRIM.LINE[8,LEN(TRIM.LINE)-7])
            END ELSE
                NAME.REST1 = TRIM(TRIM.LINE[5,LEN(TRIM.LINE)-4])
            END
            IF NAME.REST1[1,1] = '=' OR NAME.REST1[1,1] = ':' THEN
                EXIT
            END
        END

        IF TRIM.LINE[1,8] = 'FUNCTION' THEN       ; * CI_10015199 starts

            NAME.REST1 = TRIM.LINE[9,LEN(TRIM.LINE)-8]
            NAME.REST1 = TRIM(NAME.REST1)

            BEGIN CASE
                CASE NAME.REST1[1,1] = '('
                    REC<I> = 'FUNCTION ':PROGS:NAME.REST1
                    TRIM.LINE = TRIM(REC<I>)
                    FLAG = 3
                    EXIT
                CASE NAME.REST1[1,1] = '=' OR NAME.REST1 = ':'
                    EXIT
            END CASE
        END                             ; * CI_10015199 ends


*------------------------------------------------------------------------


        FIRSTWORD = FIELD(TRIM.LINE," ",1)
        IF FIRSTWORD = 'SUBROUTINE' OR FIRSTWORD = 'PROGRAM' OR FIRSTWORD = 'SUB' OR FIRSTWORD = 'PROG' OR FIRSTWORD = 'FUNCTION' THEN      ; * CI_10009738 - S/E
            FLAG = 1

            BEGIN CASE
                CASE FIRSTWORD[1,4] = 'PROG'
                    NAME.REST = FIELD(TRIM.LINE," ",2)
                    POS1 = INDEX(NAME.REST,'(',1)
                    IF POS1 THEN
                        PROG.NAME = TRIM(FIELD(NAME.REST,'(',1))
                    END ELSE
                        PROG.NAME = TRIM(NAME.REST)
                    END

                    IF PROG.NAME <> PROGS THEN
                        FLAG = 3
                        IF PROG.NAME THEN   ; * GB0002124
                            REC<I> = CHANGE(REC<I>,PROG.NAME,PROGS,1)
                        END ELSE            ; * GB0002124
                            REC<I> = REC<I>:' ':PROGS  ; * GB0002124
                        END                 ; * GB0002124
                    END

                CASE FIRSTWORD[1,3] = 'SUB'
                    NAME.REST = FIELD(TRIM.LINE," ",2)
                    POS1 = INDEX(NAME.REST,'(',1)
                    IF POS1 THEN
                        PROG.NAME = TRIM(FIELD(NAME.REST,'(',1))
                        IF NOT(PROG.NAME) THEN
*** In some strange cases we have SUBROUTINE (ABC,DEF).
* This IF statement will handle that.
                            INS.POS = INDEX(REC<I>,'(',1)
                            REC<I> = REC<I>[1,INS.POS-1]:PROGS:REC<I>[INS.POS,99999]
                            PROG.NAME = PROGS          ; * So that it will not add the name again.
                            FLAG = 3
                        END
                    END ELSE
                        PROG.NAME = TRIM(NAME.REST)
                    END
                    IF PROG.NAME <> PROGS THEN
                        FLAG = 3
                        IF PROG.NAME THEN
                            REC<I> = CHANGE(REC<I>,PROG.NAME,PROGS,1)
                        END ELSE
                            REC<I> = REC<I>:' ':PROGS
                        END
                    END

                CASE FIRSTWORD[1,8] = 'FUNCTION'    ; * CI_10015199 starts
                    NAME.REST = FIELD(TRIM.LINE," ",2)
                    POS1 = INDEX(NAME.REST,'(',1)
                    IF POS1 THEN
                        PROG.NAME = TRIM(FIELD(NAME.REST,'(',1))
                        IF NOT(PROG.NAME) THEN
*** In some strange cases we have FUNCTION (ABC,DEF).
* This IF statement will handle that.
                            INS.POS = INDEX(REC<I>,'(',1)
                            REC<I> = REC<I>[1,INS.POS-1]:PROGS:REC<I>[INS.POS,99999]
                            PROG.NAME = PROGS          ; * So that it will not add the name again.
                            FLAG = 3
                        END
                    END ELSE
                        PROG.NAME = TRIM(NAME.REST)
                    END
                    IF PROG.NAME <> PROGS THEN
                        FLAG = 3
                        IF PROG.NAME THEN
                            REC<I> = CHANGE(REC<I>,PROG.NAME,PROGS,1)
                        END ELSE
                            REC<I> = REC<I>:' ':PROGS
                        END
                    END                    ; * CI_10015199 ends
            END CASE

            EXIT
        END ELSE
            EXIT
        END
    NEXT I

RETURN


END

*****************************************************************************
