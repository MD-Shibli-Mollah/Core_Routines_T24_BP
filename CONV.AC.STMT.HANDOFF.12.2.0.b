* @ValidationCode : MjotMjA1MDY2MjE2NzpDcDEyNTI6MTU2NDU2NzQwNDAyOTpzcmF2aWt1bWFyOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDcuMjAxOTA2MTItMDMyMTotMTotMQ==
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
* <Rating>357</Rating>
*-----------------------------------------------------------------------------
* Version 5 15/05/01  GLOBUS Release No. 200511 31/10/05

$PACKAGE AC.AccountStatement
SUBROUTINE CONV.AC.STMT.HANDOFF.12.2.0
*
* 17.11.93 - GB9300826
*            Change SELECT statement when F.COMPANY is selected to
*            select only Processing Companies (CONSOLIDATION.MARK = "N")
*
* 02/09/94 - GB9400980
*            Amended to correct errors from when upgrading Fuji from
*            release 10.4 to 14.1.4
*            Amended to cater for a maximum of 50 companies, instead of
*            10
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT().
*
* 30/07/19 - Enhancement 3181538 / Task 3181750
*            TI Changes - Component moved from ST to AC.
*
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.AC.STMT.HANDOFF
*
*************************************************************************
*
    YFILE.CONTROL = "F.FILE.CONTROL" ; YLASTFIELDNO = '' ; YNEWFIELDNO = ''
    Y.FC.WRITE = ''
    Y.FIRST.DELETE = 1
*

*
    F.COMPANY = ''
    FILE.COMPANY = "F.COMPANY"
    CALL OPF(FILE.COMPANY,F.COMPANY)

    ORIGINAL.COMPANY = ID.COMPANY
    Y1ST.FIELD.CANCEL = "" ; YLAST.FIELD.CANCEL = ""
    DIM YFILES.LIST(25)
    MAT YFILES.LIST = ''
    Z = 0
    Z += 1 ; YFILES.LIST(Z) = 'AC.STMT.HANDOFF'
*
    TEXT = "" ; YFILE.SAVE = YFILE ; YFILE.ADD = "" ; YLOOP = "Y"
    FOR YF = 1 TO Z UNTIL YLOOP <> 'Y'
        GOSUB MODIFY.FILE.START
    NEXT YF
*     END
RETURN
*
*************************************************************************
*
MODIFY.FILE.START:
*
    Y.FC.WRITE = ''
    YFILE = YFILES.LIST(YF)
    CALL SF.CLEAR.STANDARD
    CALL SF.CLEAR(1,5,"FILE RUNNING:  ":YFILE)
*
    READ Y.FILE.CONTROL FROM F.FILE.CONTROL, YFILE
    ELSE
        YTXT = 'FILE ':YFILE:' MISSING IN ':YFILE.CONTROL
        GOTO FATAL.ERROR:
    END
    Y.FILE.CONTROL<3> = "$HIS"         ; * $NAU not there for source file
*
    OPEN "","F.AC.STMT.HANDOFF" TO F.TEST ELSE   ; * Check if already run
*      IF Y.FILE.CONTROL<6> = 'FIN' THEN
*** Conversion already done....
        TEXT = "CONVERSION ALREADY DONE"
        CALL OVE
        YLOOP = TEXT
        RETURN
    END
*
    LOCATE Y.FILE.CONTROL<2> IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING YPOS
    ELSE
        TEXT = Y.FILE.CONTROL<2>:" MODULE NOT INSTALLED"
        CALL OVE
        YLOOP = TEXT
        RETURN
    END
*
*Get all company IDs
*
    COMPANY.ARRAY = ''
    CALL HUSHIT(1)
    EXECUTE "SELECT F.COMPANY WITH CONSOLIDATION.MARK EQ 'N'"
    CALL HUSHIT(0)
    EOF = ''
    LOOP
        READNEXT ID ELSE EOF = 1
    UNTIL EOF
        COMPANY.ARRAY := @FM:ID
    REPEAT
*
*Create new file control record
*
    Y.OLD.TYPE = Y.FILE.CONTROL<6>
    Y.FILE.CONTROL<6> = 'FIN'
    WRITE Y.FILE.CONTROL TO F.FILE.CONTROL, YFILE
    Y.FC.WRITE = 1
*
*GET MNEMONICS AND CREATE NEW FILES
*
    COMP.COUNT = 1
    MNEMONIC.ARRAY = ''
    DIM COMP.FILES(50,5)
    MAT COMP.FILES = ''
    LOOP
        COMP.COUNT += 1
        ID = COMPANY.ARRAY<COMP.COUNT>
    WHILE ID
        READV MNEMONIC FROM F.COMPANY,ID,EB.COM.MNEMONIC ELSE
            YTXT = "CANNOT READ COMPANY RECORD ":ID
            GOTO FATAL.ERROR
        END
        MNEMONIC.ARRAY<COMP.COUNT> = MNEMONIC
*
        CALL LOAD.COMPANY(ID)
        Y.NEW.FILE = YFILE
        GOSUB CREATE.NEW.FILE:
        Y.COUNT = COUNT(Y.FILE.CONTROL<3>,VM) + (Y.FILE.CONTROL<3> NE '') + 1
        FOR YI = 1 TO Y.COUNT
            Y.FILE.ADD = Y.FILE.CONTROL<3,YI>
            Y.NEW.FILE = 'F':MNEMONIC:'.':YFILE:Y.FILE.ADD
            FILEVAR = ''
            CALL OPF(Y.NEW.FILE,FILEVAR)
            COMP.FILES(COMP.COUNT,YI) = FILEVAR
        NEXT YI
*
    REPEAT
*
*GO back to Original Company
    CALL LOAD.COMPANY(ORIGINAL.COMPANY)
*
    Y.COUNT = COUNT(Y.FILE.CONTROL<3>,VM) + (Y.FILE.CONTROL<3> NE '') + 1
    FOR YI = 1 TO Y.COUNT
        Y.FILE.ADD = Y.FILE.CONTROL<3,YI>
        Y.OLD.FILE = 'F.':YFILE:Y.FILE.ADD
        FILEVAR = ''
*Cannot use OPF has file control record has changed.
*
        OPEN '',Y.OLD.FILE TO FILEVAR ELSE
            YTXT = "Cannot OPEN ":Y.OLD.FILE
            GOTO FATAL.ERROR
        END
        EOF = ''
        EXECUTE "SELECT ":Y.OLD.FILE
        LOOP
            READNEXT ID ELSE EOF = 1
        UNTIL EOF
            READ REC FROM FILEVAR,ID THEN
                LOCATE REC<AC.STH.COMPANY.CODE> IN COMPANY.ARRAY<1> SETTING POSN THEN
                    FILE.TO.WRITE = COMP.FILES(POSN,YI)
                    WRITE REC TO FILE.TO.WRITE,ID
                END
            END
        REPEAT
    NEXT YI
*
*###      IF Y.FIRST.DELETE THEN
*###         Y.FIRST.DELETE = ''
*###         YSAVE.TEXT = TEXT
*###         TEXT = 'DO YOU WANT TO DELETE THE OLD SOURCE FILES ?'
*###         CALL OVE
*###         IF TEXT = 'Y' THEN Y.DELETE.FILES = 'Y'
*###         ELSE Y.DELETE.FILES = 'N'
*###         TEXT = YSAVE.TEXT
*###      END
*
    TEXT = "CONVERSION COMPLETE - PRESS RETURN TO DELETE OLD SOURCE FILE"
    CALL REM
*
*###      IF Y.DELETE.FILES = 'Y' THEN
    CALL SF.CLEAR(1,8,"DELETING OLD FILE:  ":Y.OLD.FILE)
    EXECUTE 'DELETE.FILE DATA ':Y.OLD.FILE
    Y.SRC = @SYSTEM.RETURN.CODE
*###      END
RETURN
*
*************************************************************************
CREATE.NEW.FILE:
*--------------
*
    CALL SF.CLEAR(1,6,"CREATING NEW FILE:  ":Y.NEW.FILE:" in company ":R.COMPANY(EB.COM.MNEMONIC))
    Y.OUT.FILE = Y.NEW.FILE
    YTXT = ""
*      CALL HUSHIT(1)
    CALL EBS.CREATE.FILE(Y.OUT.FILE,"",YTXT)
*      CALL HUSHIT(0)

    IF YTXT THEN
        GOTO FATAL.ERROR:
    END
*
*
*     IF Y.SRC < 0 THEN
*        YTXT = 'COPY FAILED...'
*        GOTO FATAL.ERROR:
*     END
*
*
RETURN
*************************************************************************
FATAL.ERROR:
*
    IF Y.FC.WRITE THEN
        Y.FILE.CONTROL<6> = Y.OLD.TYPE
        WRITE Y.FILE.CONTROL TO F.FILE.CONTROL, YFILE
    END
    CALL SF.CLEAR(8,22,YTXT)
    CALL PGM.BREAK
*
*************************************************************************
END
