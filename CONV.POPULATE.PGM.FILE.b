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

* Version 3 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>606</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.SystemTables
    SUBROUTINE CONV.POPULATE.PGM.FILE
*
* CONV.POPULATE.PGM.FILE - Add in product and sub-product to the pgm.file
**************************************************************************
* MODIFICATION:
* 28/02/07 - EN_10003192
*            DAS Implementation
**************************************************************************
    $INSERT I_F.PGM.FILE
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_SCREEN.VARIABLES
    $INSERT I_DAS.COMMON      ;*EN_10003192 S
    $INSERT I_DAS.PGM.FILE    ;*EN_10003192 E
*
    FOR LINE.NO = 4 TO 19
        CRT @(0,LINE.NO):S.CLEAR.EOL:
    NEXT LINE.NO
*
    CRT @(10,5):'UPDATING F.PGM.FILE & F.PGM.FILE$NAU WITH PRODUCT CODES'
*
    CRT @(10,8):'Enter account name where TEMP.PROGRAM.CONTROL resides  :  '
    PRINT @(10,9):
    INPUT UFD.NAME
*
    IF UFD.NAME THEN
*
        OPEN '','VOC' TO VOC ELSE
            CRT @(10,15):'CANNOT OPEN VOC  PRESS <RETURN>  ':S.BELL:
            RETURN
        END
*
        R.VOC = ''
        R.VOC<1> = 'Q'
        R.VOC<2> = UFD.NAME
        R.VOC<3> = 'TEMP.PROGRAM.CONTROL'
        WRITE R.VOC TO VOC,'TEMP.PROGRAM.CONTROL'
    END
*
* Open TEMP.PROGRAM.CONTROL file
*
    OPEN '','TEMP.PROGRAM.CONTROL' TO TEMP.PROGRAM.CONTROL ELSE
        CRT @(10,15):'CANNOT OPEN TEMP PROGRAM CONTROL  PRESS <RETURN>  ':S.BELL:
        INPUT XX
        RETURN
    END
*
* Open F.PGM.FILE
*
    OPEN '','F.PGM.FILE' TO F.PGM.FILE ELSE
        CRT @(10,15):'CANNOT OPEN F.PGM.FILE  PRESS <RETURN>  ':S.BELL:
        INPUT XX
        RETURN
    END
*
* Open F.PGM.FILE$NAU
*
    OPEN '','F.PGM.FILE$NAU' TO F.PGM.FILE$NAU ELSE
        CRT @(10,15):'CANNOT OPEN F.PGM.FILE$NAU  PRESS <RETURN>  ':S.BELL:
        INPUT XX
        RETURN
    END
*
* Open &SAVEDLISTS&
*
    OPEN '','&SAVEDLISTS&' TO SAVEDLISTS ELSE
        CRT @(10,15):'CANNOT OPEN SAVEDLISTS  PRESS <RETURN>  ':S.BELL:
        RETURN
    END
*
    DIFFERENCES = ''
*
* Select all records on the pgm.file and update with the product and
* sub-product from temp program control
*
    CRT @(10,11):'UPDATING F.PGM.FILE ':S.CLEAR.EOL:
    THE.LIST = dasAllIds      ;*EN_10003192 S
    THE.ARGS = ""
    TABLE.SUFFIX = ""
    CALL DAS("PGM.FILE",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    ID.LIST = THE.LIST        ;*EN_10003192 E
    LOOP
        REMOVE  ID FROM ID.LIST SETTING POS
    WHILE ID:POS
*
        READ R.PGM.FILE FROM F.PGM.FILE,ID ELSE R.PGM.FILE = ''
        IF R.PGM.FILE THEN
            CRT @(31):ID:S.CLEAR.EOL:
            READ R.TEMP.PROGRAM.CONTROL FROM TEMP.PROGRAM.CONTROL,ID ELSE
*
* If pgm.file is for a batch job, check each program in the batch field
* to get its product, reporting any where there are differences in
* products or sub-products
*
                IF R.PGM.FILE<EB.PGM.BATCH.JOB> THEN
                    MAX.BATCHES = COUNT(R.PGM.FILE<EB.PGM.BATCH.JOB>,@VM) + (R.PGM.FILE<EB.PGM.BATCH.JOB> <> '')
                    SAVED.PRODUCT = ''
                    SAVED.SUB.PRODUCT = ''
                    FOR BATCH.NO = 1 TO MAX.BATCHES
                        BATCH.NAME = R.PGM.FILE<EB.PGM.BATCH.JOB,BATCH.NO>
                        IF BATCH.NAME[1,1] = '@' THEN
                            BATCH.NAME = BATCH.NAME[2,99]
                            READ R.TEMP.PROGRAM.CONTROL FROM TEMP.PROGRAM.CONTROL,BATCH.NAME ELSE R.TEMP.PROGRAM.CONTROL = ''
                            IF BATCH.NO > 1 THEN
                                IF R.TEMP.PROGRAM.CONTROL<1> <> SAVED.PRODUCT OR R.TEMP.PROGRAM.CONTROL<2> <> SAVED.SUB.PRODUCT THEN
                                    DIFFERENCES<-1> = ID
                                END
                            END
                            SAVED.PRODUCT = R.TEMP.PROGRAM.CONTROL<1>
                            SAVED.SUB.PRODUCT = R.TEMP.PROGRAM.CONTROL<2>
                        END
                    NEXT BATCH.NO
                END ELSE
                    R.TEMP.PROGRAM.CONTROL = ''
                END
            END
            R.PGM.FILE<EB.PGM.PRODUCT> = R.TEMP.PROGRAM.CONTROL<1>
            R.PGM.FILE<EB.PGM.SUB.PRODUCT> = R.TEMP.PROGRAM.CONTROL<2>
            WRITE R.PGM.FILE TO F.PGM.FILE,ID
        END
    REPEAT
*
* Select all records on the pgm.file$nau and update with the product and
* sub-product from temp program control
*
    CRT @(10,11):'UPDATING F.PGM.FILE$NAU ':S.CLEAR.EOL:
    THE.LIST = dasAllIds      ;*EN_10003192 S
    THE.ARGS = ""
    TABLE.SUFFIX = "$NAU"
    CALL DAS("PGM.FILE",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    ID.LIST = THE.LIST        ;*EN_10003192 E
    LOOP
        REMOVE ID FROM ID.LIST SETTING POS
    WHILE ID:POS
*
        READ R.PGM.FILE FROM F.PGM.FILE$NAU,ID ELSE R.PGM.FILE = ''
        IF R.PGM.FILE THEN
            CRT @(35):ID:S.CLEAR.EOL:
            READ R.TEMP.PROGRAM.CONTROL FROM TEMP.PROGRAM.CONTROL,ID ELSE R.TEMP.PROGRAM.CONTROL = ''
            R.PGM.FILE<EB.PGM.PRODUCT> = R.TEMP.PROGRAM.CONTROL<1>
            R.PGM.FILE<EB.PGM.SUB.PRODUCT> = R.TEMP.PROGRAM.CONTROL<2>
            WRITE R.PGM.FILE TO F.PGM.FILE$NAU,ID
        END
    REPEAT
*
    IF DIFFERENCES THEN
        CRT
        CRT
*         CRT '    Please check select list PGM.FILE.DIFFERENCES for discrepancies'
        CRT
*         INPUT XX
        WRITE DIFFERENCES TO SAVEDLISTS,'PGM.FILE.DIFFERENCES000'
    END
    RETURN
END
