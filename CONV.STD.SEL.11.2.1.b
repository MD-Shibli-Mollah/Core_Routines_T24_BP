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
* <Rating>548</Rating>
*-----------------------------------------------------------------------------
* Version 9 07/06/01  GLOBUS Release No. G12.0.00 29/06/01
*
****************************************************************************
*
    $PACKAGE EB.SystemTables
    SUBROUTINE CONV.STD.SEL.11.2.1
*
****************************************************************************
*
* This program converts the standard selection file by adding two new
* fields 'SYS.REL.FILE' and 'USR.REL.FILE'.  It will also populate these
* new fiels with the correct values.  The values contained in these fields
* can be found from the applications checkfile for each field defined
* in standard selection for any particular appliaction.  This will involve
* calling the applications in order to setup the CHECKFILE array.
*
****************************************************************************
* 02/11/07 - CI_10052164
*            The files ORDER.BY.SECURITY need to be marked as obsolete
*
* 07/05/14 - Defect 476850/Task 962338
*            EXIST are C routines that is not supported from TAFJ.  Hence, commenting the code for now.
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT(). 
*
****************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STANDARD.SELECTION
    $INSERT I_F.PGM.FILE
    $INSERT I_F.USER
****************************************************************************
*
    GOSUB VERIFY

    IF V$CONTINUE THEN

        GOSUB INITIALISE

        PRINT @(10,9):'Processing Live File':
        F.STANDARD.SELECTION.NAME = 'F.STANDARD.SELECTION'
        F.STANDARD.SELECTION = ''
        CALL OPF(F.STANDARD.SELECTION.NAME,F.STANDARD.SELECTION)
        SUFFIX = "" ;* Live file

        GOSUB PROCESS
*
* Now repeat for this unauthorised file
*
        PRINT @(10,9):'Processing Unauthorised File':
        F.STANDARD.SELECTION.NAME = 'F.STANDARD.SELECTION$NAU'
        F.STANDARD.SELECTION = ''
        CALL OPF(F.STANDARD.SELECTION.NAME,F.STANDARD.SELECTION)
        SUFFIX = "$NAU"       ;* Nau file

        GOSUB PROCESS

    END

    RETURN
*
****************************************************************************
*
VERIFY:
*
    PRINT @(10,6):'This application will convert the STANDARD.SELECTION'
    PRINT @(10,7):'file.  Do you wish to continue (Y/N) :':

    INPUT ANS:

    IF ANS EQ 'Y' OR ANS EQ 'y' THEN
        V$CONTINUE = 1
    END ELSE
        V$CONTINUE = ''
    END

    RETURN
*
****************************************************************************
*
INITIALISE:
*
* Files
*
    F.PGM.FILE.NAME = 'F.PGM.FILE' ; F.PGM.FILE = ''
    CALL OPF(F.PGM.FILE.NAME,F.PGM.FILE)

    F.COMPANY.NAME = 'F.COMPANY' ; F.COMPANY = ''
    CALL OPF(F.COMPANY.NAME,F.COMPANY)

    F.VOC = ''
    OPEN 'VOC' TO F.VOC ELSE
        TEXT = 'CANNOT OPEN THE VOC FILE'
        GOTO FATAL.ERROR
    END
*
* Variables
*
    DIM CHECKFILE(200)

    V$FUNCTION = 'CONV.STD.SEL.11.2.1'
*
* Setup list of company's
*
    COMP.LIST = ''
    SELECT F.COMPANY
    LOOP
        READNEXT C.ID ELSE C.ID = ''
    UNTIL C.ID EQ ''
        COMP.LIST<1,-1> = C.ID
    REPEAT
*
* Set up hardcoded list of programs not to call
*
    DONT.CALL.LIST = 'JOURNAL.POSITIONS'
    DONT.CALL.LIST := ' TRN.CON.TRADE.DATE TRN.CON.VALUE.DATE'
    CONVERT ' ' TO FM IN DONT.CALL.LIST

    RETURN
*
****************************************************************************
*
PROCESS:
*
    GOSUB SELECT.SS

    PRINT @(15,13):'Processes  0          ':

    CNT = 0

    LOOP
        REMOVE ID FROM SS.LIST SETTING DELIM
    WHILE ID:DELIM

        CNT += 1

        IF MOD(CNT,200) EQ 0 THEN
            PRINT @(15,13):'Processed ':CNT:'      ':
        END

        GOSUB UPDATE.SS.REC

    REPEAT

    RETURN
*
****************************************************************************
*
SELECT.SS:
*
    EX.CMD = 'SSELECT ':F.STANDARD.SELECTION.NAME
    SS.LIST = ''

    CALL EB.READLIST(EX.CMD,SS.LIST,'',NO.SEL,RET)

    IF RET LT 0 THEN
        TEXT = 'FATAL ERROR IN SELECT STATEMENT ':EX.CMD
        GOTO FATAL.ERROR
    END

    PRINT @(10,11):'No of ss records selected ':NO.SEL:'         '

    RETURN
*
****************************************************************************
*
UPDATE.SS.REC:
*
    GOSUB READ.SS.REC
*
    NO.FIELDS = DCOUNT(STD.REC,FM)
    CONVERT.RECORD = ""       ;* Set if conversion required
    BEGIN CASE
    CASE STD.REC<39> MATCHES COMP.LIST  ;* Already done
*
    CASE INDEX(STD.REC<36>,"_",1) AND INDEX(STD.REC<38>,"_",1)        ;* Already done
*
    CASE NO.FIELDS >= 41      ;* Already done
*
    CASE SUFFIX = "$NAU"
        IF INDEX(STD.REC<34>,"_",1) THEN          ;* Old inputter
            CONVERT.RECORD = 1
        END
*
    CASE NO.FIELDS = 38       ;* May be done
        IF INDEX(STD.REC<36>,"_",1) AND INDEX(STD.REC<38>,"_",1) THEN ;* Done
            NULL
        END ELSE CONVERT.RECORD = 1
*
    CASE 1
        CONVERT.RECORD = 1    ;* Okay convert
    END CASE
*
    IF NOT(CONVERT.RECORD) THEN
        RELEASE F.STANDARD.SELECTION, ID
    END ELSE
        GOSUB INSERT.FIELDS
        GOSUB CHECK.DONT.CALL.LIST
        IF V$CONTINUE THEN
            GOSUB SETUP.FILE.FIELDS
        END
        WRITE STD.REC ON F.STANDARD.SELECTION, ID
    END

    RETURN
*
****************************************************************************
*
READ.SS.REC:
*
LOCKED.REC:
*
    ER = ''
    STD.REC = ''

    READU STD.REC FROM F.STANDARD.SELECTION, ID LOCKED
        PRINT @(10,17):ID:' RECORD LOCKED':
        GOTO LOCKED.REC
    END ELSE
        TEXT = ID:' MISSING FROM STANDARD.SELECTION'
        GOTO FATAL.ERROR
    END

    RETURN
*
****************************************************************************
*
INSERT.FIELDS:
** Inser the new fields REL.FILE at 14 and 27. Ensure that the number of
** value marks added is correct
*
    AVC = COUNT(STD.REC<1>,VM)          ;* No of VMs
    INS.STR = STR(VM,AVC)
    STD.REC = INSERT(STD.REC,14,0,0,INS.STR)
*
    AVC = COUNT(STD.REC<15>,VM)
    INS.STR = STR(VM,AVC)
    STD.REC = INSERT(STD.REC,27,0,0,INS.STR)
*
    STD.REC<39> = ID.COMPANY  ;* Ensure company code is added
    STD.REC<40> = R.USER<EB.USE.DEPARTMENT.CODE>

    RETURN
*
****************************************************************************
*
CHECK.DONT.CALL.LIST:
*
    V$CONTINUE = 1

    LOCATE ID IN DONT.CALL.LIST<1> SETTING P THEN
        V$CONTINUE = ''
        RETURN
    END

    PGM.REC = ''

    READ PGM.REC FROM F.PGM.FILE, ID ELSE
        V$CONTINUE = ''
        RETURN
    END

    IF INDEX('HLTUW',PGM.REC<EB.PGM.TYPE>[1,1],1) EQ 0 THEN
        V$CONTINUE = ''
        RETURN
    END

    READ VOC.ENTRY FROM F.VOC , ID ELSE
        V$CONTINUE = ''
        RETURN
    END

    EXISTS = ''
*    CALL !EXIST(VOC.ENTRY<2>,EXISTS)
*    IF NOT(EXISTS) THEN
*        V$CONTINUE = ''
*        RETURN
*    END

    F.ID.NAME = 'F.':ID:FM:'NO.FATAL.ERROR'
    F.ID = ''
    ETEXT = ''
    CALL HUSHIT(1)
    CALL OPF(F.ID.NAME,F.ID)
    CALL HUSHIT(0)
    IF ETEXT THEN
        V$CONTINUE = ''
        RETURN
    END

    RETURN
*
****************************************************************************
*
SETUP.FILE.FIELDS:
*
    MAT CHECKFILE = ''

    PRINT @(5,18):
    ROUTINE = ID
    CALL @ROUTINE

    FOR I = 1 TO V
        IF CHECKFILE(I) THEN
            X = 1
            FINISHED = ''
*
* Check SYS fields
*
            LOOP
                LOCATE I IN STD.REC<3,X> SETTING POS THEN   ;* Field Name
                    X = POS + 1
                    STD.REC<14,POS,-1> = CHECKFILE(I)<1>    ;* Related file
                END ELSE
                    FINISHED = 1
                END
            UNTIL FINISHED
            REPEAT
*
* Check USR fields
*
            X = 1
            FINISHED = ''

            LOOP
                LOCATE I IN STD.REC<17,X> SETTING POS THEN  ;* USR fld no
                    X = POS + 1
                    STD.REC<27,POS,-1> = CHECKFILE(I)<1>
                END ELSE
                    FINISHED = 1
                END
            UNTIL FINISHED
            REPEAT

        END

    NEXT I

    RETURN
*
****************************************************************************
*
FATAL.ERROR:
*
    CALL FATAL.ERROR('CONV.STD.SEL.11.2.1')
*
****************************************************************************
*
END
