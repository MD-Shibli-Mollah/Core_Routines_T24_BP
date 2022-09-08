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
* <Rating>310</Rating>
*-----------------------------------------------------------------------------
* Version 4 02/06/00  GLOBUS Release No. 200508 30/06/05
*
******************************************************************************
*
    $PACKAGE PM.Config
    SUBROUTINE CONV.PM.12.1.0
*
******************************************************************************
*
* This program will convert the PM.AC.PARAM file.
*
* 08/04/11 - Defect - 186035 / Task - 188585
*            PRINT statements has been changed to avoid browser Incompatibility
*
* 11/04/11 - Defect - 189543 / Task - 189616
*            Reverts the code changes done for the defect 186035
*
******************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
******************************************************************************
*
    GOSUB VERIFY

    IF CONT THEN

        FILE.NAME = 'F.PM.AC.PARAM'
        CMP.FLD = 31

        GOSUB DO.FILES

    END

    RETURN
*
******************************************************************************
*
VERIFY:
*
    PRINT @(10,7):'This program will convert PM.AC.PARAM file'
    PRINT @(10,8):'Warning this must be run prior to the end of day'
    PRINT @(10,9):'No online PM movements can be raised after this point'
    PRINT @(15,10):' Continue Y/N : ':

    INPUT CONT

    IF CONT NE 'Y' THEN
        CONT = ''
    END

    RETURN
*
******************************************************************************
*
DO.FILES:
*
    EXT = '' ; NO.MORE = '' ; TEXT = ''

    LOOP UNTIL NO.MORE OR TEXT EQ 'NO'
        GOSUB MODIFY.FILE
        BEGIN CASE
            CASE EXT EQ '' ; EXT = '$NAU'
            CASE EXT EQ '$NAU' ; EXT = '$HIS'
            CASE EXT EQ '$HIS' ; NO.MORE = 1
        END CASE
    REPEAT

    RETURN
*
******************************************************************************
*
MODIFY.FILE:
*
    FILE = FILE.NAME:EXT ; F.FILE = ''
    CALL OPF(FILE:FM:'NO.FATAL.ERROR',F.FILE)

    IF NOT(ETEXT) THEN

        SELECT F.FILE

        LOOP
            READNEXT ID ELSE ID = ''
            WHILE ID

                READ REC FROM F.FILE, ID ELSE NULL
                    IF REC<CMP.FLD> NE ID.COMPANY THEN

                        GOSUB CHANGE.RECORD

                        WRITE REC TO F.FILE,ID
                    END
                REPEAT

            END

            RETURN
            *
******************************************************************************
            *
CHANGE.RECORD:
            *
            REC = INSERT(REC,3,0,0,'')
            REC = INSERT(REC,4,0,0,'')
            REC = INSERT(REC,8,0,0,'')
            REC = INSERT(REC,9,0,0,'')
            REC = INSERT(REC,10,0,0,'')

            REC = INSERT(REC,12,0,0,'')
            REC = INSERT(REC,13,0,0,'')
            REC = INSERT(REC,14,0,0,'')

            REC = INSERT(REC,22,0,0,'')
            REC = INSERT(REC,23,0,0,'')
            REC = INSERT(REC,24,0,0,'')
            REC = INSERT(REC,25,0,0,'')

            NO.OF.CATEG = DCOUNT(REC<5>,VM)

            SIGNS = REC<15> ; REC<15> = ''
            PERDS = REC<16> ; REC<16> = ''
            PCNTS = REC<17> ; REC<17> = ''
            PRDIT = REC<18> ; REC<18> = ''
            FLTIT = REC<19> ; REC<19> = ''

            NO.OF.SIGN.AV = DCOUNT(PERDS,VM)
            FOR I = 1 TO NO.OF.SIGN.AV
                NO.OF.SIGN.SV = DCOUNT(PERDS<1,I>,SM)
                FOR J = 1 TO NO.OF.SIGN.SV
                    IF SIGNS<1,I,J> EQ '' THEN SIGNS<1,I,J> = 'BOTH'
                NEXT J
            NEXT I

            X = 0

            FOR I = 1 TO NO.OF.CATEG

                REC<12,I,1> = 'DEFAULT'
                REC<13,I,1> = I
                REC<14,I,1> = I


                TYPE = 'DEBIT'
                Y = 0
                GOSUB UPD.SIGNS

                TYPE = 'CREDIT'
                Y = 0
                GOSUB UPD.SIGNS

                TYPE = 'BOTH'
                Y = 0
                GOSUB UPD.SIGNS

            NEXT I

            RETURN
            *
******************************************************************************
            *
UPD.SIGNS:
            *
            NOT.FOUND = ''
            FST.TIME = 1
            DSTART = 1

            LOOP
                LOCATE TYPE IN SIGNS<1,I,DSTART> SETTING POS ELSE NOT.FOUND = 1
                UNTIL NOT.FOUND
                    DSTART = POS + 1
                    IF FST.TIME THEN
                        X += 1
                        REC<15,X> = I:'.':TYPE
                        FST.TIME = ''
                    END
                    Y += 1
                    REC<16,X,Y> = PERDS<1,I,POS>
                    REC<17,X,Y> = PCNTS<1,I,POS>
                    REC<18,X,Y> = PRDIT<1,I,POS>
                    REC<19,X,Y> = FLTIT<1,I,POS>
                REPEAT

                RETURN
                *
******************************************************************************
                *
            END
