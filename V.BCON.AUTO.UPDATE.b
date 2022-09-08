* @ValidationCode : Mjo4MzAyMDk2OTpDcDEyNTI6MTU1MDQ3ODc2MjEwNDpwbWFoYTotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxODExLjIwMTgxMDIyLTE0MDY6LTE6LTE=
* @ValidationInfo : Timestamp         : 18 Feb 2019 14:02:42
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

*-----------------------------------------------------------------------------
* <Rating>24</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.Updates
SUBROUTINE V.BCON.AUTO.UPDATE
*
* Subroutine Type : VERSION
* Attached to     : VERSION.CONTROL - SYSTEM record.
* Attached as     : AUTH.ROUTINE
* Primary Purpose : To Update the fields WS.FILE.NAME & WS.RECORD.NAME
*                   in the respective BUILD.CONTROL record.
*
* Incoming:
* ---------
* NONE
*
* Outgoing:
* ---------
* NONE
*
* Error Variables:
* ----------------
* E - Any errors encountered.
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* 07/003/2006 - Naveen U.M.
*               BUILD.CONTROL Enhancement Phase II.
*
* 26 OCT 2006 - KK
*               1. No need for this dummy prompt when the application is not required for packaging
*               2. Include the 'C'opy function.
*
* 08/01/19 - Enhancement 2822523 / Task 2925633
*            Incorporation of EB_Updates component
*-----------------------------------------------------------------------------------
    $INSERT I_COMMON

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    GOSUB CHECK.PRELIM.CONDITIONS

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*
    GOSUB APPEND.QUIT.TO.BCON.ID.LIST
    IF FINAL.BCON.IDS THEN
        GOSUB CHOOSE.FROM.BCON.ID.LIST
        IF NOT(E) AND PROCESS.GOAHEAD THEN
            GOSUB CHECK.BCON.RECORD
            IF NOT(UPDATED) THEN
                GOSUB UPDATE.BCON.RECORD
                GOSUB CREATE.BCON.RECORD
            END
        END
    END
RETURN
*-----------------------------------------------------------------------------------
APPEND.QUIT.TO.BCON.ID.LIST:
*
* 26 OCT 2006 - KK/s
*    IF NOT(FINAL.BCON.IDS) THEN
    IF (FINAL.BCON.IDS) THEN
* No need for this dummy prompt when the application is not required for packaging
*        FINAL.BCON.IDS = 'QUIT'

*    END ELSE
* 26 OCT 2006 - KK/e
        FINAL.BCON.IDS :=@VM:'QUIT'
    END

RETURN
*-----------------------------------------------------------------------------------
CHOOSE.FROM.BCON.ID.LIST:
*
    INP.MSG = "CHOOSE THE BUILD.CONTROL TO WHICH YOU WANT TO INCLUDE THIS RECORD OR QUIT"
    N1 = '75.1.C'
    CONVERT @VM TO '_' IN FINAL.BCON.IDS
    T1 = '':@FM:FINAL.BCON.IDS
    EB.Updates.BconComplementTxtinp(INP.MSG,8,22,N1,T1)
    IF ETEXT THEN
        PROCESS.GOAHEAD = 0   ;* If the User enters a BUILD.CONTROL ID which is not part of the list provided.
        E = ETEXT
    END ELSE
        BEGIN CASE
            CASE COMI EQ 'QUIT'
                PROCESS.GOAHEAD = 0         ;* Don't process further & return from the routine.
            CASE 1
                ID.BCON = COMI    ;* This BUILD.CONTROL id is used in WRITE statement.
                GOSUB READ.BCON.RECORD
        END CASE
    END
*-----------------------------------------------------------------------------------
READ.BCON.RECORD:
*
    R.BCON = '' ; ERR.BCON = ''
    CALL F.READ(FN.BCON,ID.BCON,R.BCON,F.BCON,ERR.BCON)
    IF ERR.BCON THEN
        PROCESS.GOAHEAD = 0
        E = 'EB-BCON.REC.MISS.FILE'
        E<2,1> = ID.BCON
        E<2,2> = FN.BCON
        EB.Updates.RadEtxt(E)
    END

RETURN
*-----------------------------------------------------------------------------------
CHECK.BCON.RECORD:
*
* Before updating the BUILD.CONTROL record with the FILE.NAME & the RECORD.NAME, check
* whether they are already updated earlier. If not, then only they are to be updated.
*
    ALL.FILE.NAMES = R.BCON<EB.Updates.BuildControl.BconWsFileName>
    ALL.RECORD.NAMES = R.BCON<EB.Updates.BuildControl.BconWsRecordName>
    TOT.ALL.FILE.NAMES = DCOUNT(ALL.FILE.NAMES,@VM)

    IF TOT.ALL.FILE.NAMES THEN
        LOOP.CNT = 0
        LOOP
            LOOP.CNT += 1
        WHILE LOOP.CNT LE TOT.ALL.FILE.NAMES DO
            REC.POS = ''
            LOCATE RECORD.NAME IN ALL.RECORD.NAMES<1,1> SETTING REC.POS THEN
                IF ALL.FILE.NAMES<1,REC.POS> EQ FILE.NAME THEN
* Do not Update the BUILD.CONTROL record, coz File Name & Record Name already exists.
                    UPDATED = 1
                END ELSE
                    UPDATED = 0
                    DEL ALL.FILE.NAMES<1,REC.POS>
                    DEL ALL.RECORD.NAMES<1,REC.POS>
                END
            END
        REPEAT
    END

RETURN
*-----------------------------------------------------------------------------------
UPDATE.BCON.RECORD:
*
    IF R.BCON<EB.Updates.BuildControl.BconWsFileName> AND R.BCON<EB.Updates.BuildControl.BconWsRecordName> THEN
        R.BCON<EB.Updates.BuildControl.BconWsFileName> :=@VM: FILE.NAME
        R.BCON<EB.Updates.BuildControl.BconWsRecordName> :=@VM: RECORD.NAME
    END ELSE
        R.BCON<EB.Updates.BuildControl.BconWsFileName> = FILE.NAME
        R.BCON<EB.Updates.BuildControl.BconWsRecordName> = RECORD.NAME
    END

RETURN
*-----------------------------------------------------------------------------------
CREATE.BCON.RECORD:
*
    WRITE R.BCON TO F.BCON,ID.BCON ON ERROR
        TEXT = 'UNABLE TO WRITE TO FILE ':FN.BCON
        CALL FATAL.ERROR(SYSTEM(40))
    END

RETURN
*-----------------------------------------------------------------------------------
*//////////////////////////////////////////////////////////////////////////////////*
*////////////////P R E  P R O C E S S  S U B R O U T I N E S //////////////////////*
*//////////////////////////////////////////////////////////////////////////////////*
INITIALISE:
*
    PROCESS.GOAHEAD = 1 ; UPDATED = 0
    FILE.NAME = APPLICATION ; RECORD.NAME = ID.NEW
    FINAL.BCON.IDS = ''

RETURN
*-----------------------------------------------------------------------------------
OPEN.FILES:
*
    FN.BCON = 'F.BUILD.CONTROL'
    FN.BCON<2> = 'NO.FATAL.ERROR'
    F.BCON = ''
    CALL OPF(FN.BCON,F.BCON)

    FN.BCON.PROD = 'F.BUILD.CONTROL.PRODUCT'
    FN.BCON.PROD<2> = 'NO.FATAL.ERROR'
    F.BCON.PROD = ''
    CALL OPF(FN.BCON.PROD,F.BCON.PROD)

    FN.BCON.CONCAT = 'F.BUILD.CONTROL.USER.CONCAT'
    FN.BCON.CONCAT<2> = 'NO.FATAL.ERROR'
    F.BCON.CONCAT = ''
    CALL OPF(FN.BCON.CONCAT,F.BCON.CONCAT)

RETURN
*-----------------------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
*
    LOOP.CNT = 1 ; MAX.LOOPS = 5
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO
        BEGIN CASE
            CASE LOOP.CNT EQ 1
                IF ETEXT THEN     ;* If any errors encountered during OPF.
                    E = ETEXT
                    PROCESS.GOAHEAD = 0
                END

            CASE LOOP.CNT EQ 2
                IF FILE.NAME EQ 'BUILD.CONTROL' THEN PROCESS.GOAHEAD = 0  ;* If the USER is inputing the BUILD.CONTROL record then donot process further.

            CASE LOOP.CNT EQ 3
* 26 OCT 2006 - KK/s
* Include 'C'opy function
*            IF NOT(V$FUNCTION MATCHES 'I':VM:'A') THEN      ;* Coz, only the records that are Input & Authorised should be updated to Build Control.
                IF NOT(V$FUNCTION MATCHES 'I':@VM:'A':@VM:'C') THEN         ;* Coz, only the records that are Input & Authorised should be updated to Build Control.
* 26 OCT 2006 - KK/e
                    PROCESS.GOAHEAD = 0
                END

            CASE LOOP.CNT EQ 4
                GOSUB READ.BCON.CONCAT.FILE

            CASE LOOP.CNT EQ 5
                GOSUB READ.BUILD.CONTROL.FILE

        END CASE
        LOOP.CNT += 1
    REPEAT

RETURN
*-----------------------------------------------------------------------------------
READ.BCON.CONCAT.FILE:

    R.BCON.CONCAT = '' ; ERR.BCON.CONCAT = ''
    CALL F.READ(FN.BCON.CONCAT,OPERATOR,R.BCON.CONCAT,F.BCON.CONCAT,ERR.BCON.CONCAT)
    IF R.BCON.CONCAT THEN

        ALL.BCON.IDS = ''
        ALL.BCON.IDS = R.BCON.CONCAT<EB.Updates.BuildControlUserConcat.BconUserCBuildControl>
    END ELSE
        PROCESS.GOAHEAD = 0
* Do not throw any error messages, coz it should not affect the USERS who are inputting normal records.
    END

RETURN
*-----------------------------------------------------------------------------------
READ.BUILD.CONTROL.FILE:
    TOT.BCON.IDS = DCOUNT(ALL.BCON.IDS,@VM)
    FOR BCON.ID.CNT = 1 TO TOT.BCON.IDS
        IF NOT(E) AND PROCESS.GOAHEAD THEN
            ID.BCON = ''
            ID.BCON = ALL.BCON.IDS<1,BCON.ID.CNT>
            R.BCON = '' ; ERR.BCON = ''
            CALL F.READ(FN.BCON,ID.BCON,R.BCON,F.BCON,ERR.BCON)

* 27 OCT 2006 - KK/s
* Check for 'CLOSE' before proceeding
            IF R.BCON<EB.Updates.BuildControl.BconAction> NE 'CLOSE' THEN
* 27 OCT 2006 - KK/e

                IF R.BCON THEN
                    ID.BCON.PROD = ''
                    ID.BCON.PROD = R.BCON<EB.Updates.BuildControl.BconBconProduct>
                    GOSUB READ.BCON.PRODUCT.FILE
                END ELSE
                    PROCESS.GOAHEAD = 0
                    E = 'EB-BCON.REC.MISS.FILE'
                    E<2,1> = ID.BCON
                    E<2,2> = FN.BCON
                    EB.Updates.RadEtxt(E)
                END
            END ELSE
                PROCESS.GOAHEAD = 0
            END
        END ELSE
            PROCESS.GOAHEAD = 0
        END
    NEXT BCON.ID.CNT

RETURN
*-----------------------------------------------------------------------------------
READ.BCON.PRODUCT.FILE:

    R.BCON.PROD = '' ; ERR.BCON.PROD = ''
    CALL F.READ(FN.BCON.PROD,ID.BCON.PROD,R.BCON.PROD,F.BCON.PROD,ERR.BCON.PROD)
    IF R.BCON.PROD THEN
        GOSUB APPEND.BUILD.CONTROL.IDS
    END ELSE
        PROCESS.GOAHEAD = 0
        E = 'EB-BCON.REC.MISS.FILE'
        E<2,1> = ID.BCON.PROD
        E<2,2> = FN.BCON.PROD
        EB.Updates.RadEtxt(E)
    END

RETURN
*-----------------------------------------------------------------------------------
APPEND.BUILD.CONTROL.IDS:
*
    ALL.FILE.NAMES = R.BCON.PROD<EB.Updates.BuildControlProduct.BconProdFileNames>
    CONVERT @SM TO @VM IN ALL.FILE.NAMES

* Search the FILE.NAME being input is included in the BUILD.CONTROL.PRODUCT File.
* If so, update the respective BCON ID's in a seperate Array.

    LOCATE FILE.NAME IN ALL.FILE.NAMES<1,1> SETTING FL.POS THEN
        IF FINAL.BCON.IDS THEN
            FINAL.BCON.IDS :=@VM: ID.BCON
        END ELSE
            FINAL.BCON.IDS = ID.BCON
        END
    END

RETURN
*-----------------------------------------------------------------------------------
END
