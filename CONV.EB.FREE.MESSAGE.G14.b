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
* <Rating>784</Rating>
*-----------------------------------------------------------------------------
* Version 1 29/05/03  GLOBUS Release No. G14.0.00
*
    $PACKAGE EB.Delivery
    SUBROUTINE CONV.EB.FREE.MESSAGE.G14
*-----------------------------------------------------------------------
* DATE    : 28/05/2003
* Purpose :
*    The FILE.CONTROLs of the files, EB.FREE.MESSAGE and
*    EB.SCHEDULE.TRACER has been changed from INT to FIN.
*    This conversion routine is written to copy the records from the
*    existing EB.FREE.MESSAGE and EB.SCHEDULE.TRACER files to the new
*    files, according to the Company.Code present in the existing files.
*-----------------------------------------------------------------------
* Modification History:
*
* 10/05/03 - BG_100004429
*            The EB.TXN.TRACER & EB.SCHEDULE.TRACER files will be updated
*            only when the STATUS of the EB.FREE.MESSAGE is 'SCHED'.
*
* 23/12/03 - CI_10016080
*            Cache exceeding problem during journal update.
*
*-----------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    EQU SUFFIXES TO 3
    EQU FILE.CONTROL.CLASS TO 6

    SAVE.ID.COMPANY = ID.COMPANY

    GOSUB INITIALISATION

    GOSUB GET.FILE.CLASSIFICATION       ;* get file classification

    LOOP
        REMOVE K.COMPANY FROM COMPANIES SETTING MORE.COMPANIES
    WHILE K.COMPANY:MORE.COMPANIES

        IF K.COMPANY NE ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END

        GOSUB COMPANY.INITIALISATION    ;* COMPANY specific initialisation

        F.FILENAME.OLD = 'F.EB.FREE.MESSAGE'
        NAU.HIS.PROC = 0
        GOSUB PROCESS.FILE
* Updation of $HIS and $NAU files of EB.SCHEDULE.TRACER & EB.TXN.TRACER
* need not done. Hence set NAU.HIS.PROC flag.
        NAU.HIS.PROC = 1

        IF UNAUTH.REQD THEN
            F.FILENAME.OLD = 'F.EB.FREE.MESSAGE$NAU'
            F.FILENAME = F.FILENAME$NAU ; FN.FILENAME = FN.FILENAME.NAU
            GOSUB PROCESS.FILE
        END

        IF HIST.REQD THEN
            F.FILENAME.OLD = 'F.EB.FREE.MESSAGE$HIS'
            F.FILENAME = F.FILENAME$HIS ; FN.FILENAME = FN.FILENAME.HIS
            GOSUB PROCESS.FILE
        END

    REPEAT

    F.FILENAME.OLD = 'F.EB.FREE.MESSAGE' ; GOSUB CLEAR.OLD.FILES
    F.FILENAME.OLD = 'F.EB.FREE.MESSAGE$NAU' ; GOSUB CLEAR.OLD.FILES
    F.FILENAME.OLD = 'F.EB.FREE.MESSAGE$HIS' ; GOSUB CLEAR.OLD.FILES
    F.FILENAME.OLD = 'F.EB.SCHEDULE.TRACER' ; GOSUB CLEAR.OLD.FILES
    F.FILENAME.OLD = 'F.EB.SCHEDULE.TRACER$NAU' ; GOSUB CLEAR.OLD.FILES
    F.FILENAME.OLD = 'F.EB.SCHEDULE.TRACER$HIS' ; GOSUB CLEAR.OLD.FILES
    F.FILENAME.OLD = 'F.EB.TXN.TRACER' ; GOSUB CLEAR.OLD.FILES
    F.FILENAME.OLD = 'F.EB.TXN.TRACER$NAU' ; GOSUB CLEAR.OLD.FILES
    F.FILENAME.OLD = 'F.EB.TXN.TRACER$HIS' ; GOSUB CLEAR.OLD.FILES

    IF ID.COMPANY NE SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    RETURN

*-----------------------------------------------------------------------------
PROCESS.FILE:
*------------
    SEL.CMD = '' ; SEL.LIST = '' ; NO.OF.IDS = ''
    EST.ERR = '' ; ETT.ERR = ''
    OPEN '',F.FILENAME.OLD TO REC.PATH ELSE RETURN

    SEL.CMD = 'SELECT ':F.FILENAME.OLD:' WITH CO.CODE EQ ':ID.COMPANY
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.IDS,'')

    LOOP
        REMOVE K.ID FROM SEL.LIST SETTING ID.POS
    WHILE K.ID:ID.POS
        READ R.REC FROM REC.PATH,K.ID THEN
            WRITE R.REC TO F.FILENAME, K.ID       ;* CI_16080
            IF NOT(NAU.HIS.PROC) THEN
* Update the concat files only when the status of the EFM is 'SCHED'.
                TRACER.STAT = 11        ;* BG_100004429 +
                IF R.REC<TRACER.STAT> EQ 'SCHED' THEN
* Updation of EB.SCHEDULE.TRACER file.
                    TRACER.DT = 12
                    IF R.REC<TRACER.DT> NE '' THEN
                        SCH.DATE = R.REC<TRACER.DT>         ;* BG_100004429 -
                        Y.POS = ''
                        READ R.EST FROM F.FILENAME.EST, SCH.DATE THEN ;* CI_16080
                            LOCATE K.ID IN R.EST<1> SETTING Y.POS ELSE Y.POS = ''
                        END
                        IF Y.POS = '' THEN
                            R.EST<-1> = K.ID
                            WRITE R.EST TO F.FILENAME.EST, SCH.DATE   ;* CI_16080
                        END
                    END
* Updation of EB.TXN.TRACER file.
                    OUR.REFERENCE = 6   ;* BG_100004429 +
                    IF R.REC<OUR.REFERENCE> NE '' THEN
                        OUR.REF = R.REC<OUR.REFERENCE>      ;* BG_100004429 -
                        Y.POS = ''
                        READ R.ETT FROM F.FILENAME.ETT, OUR.REF THEN  ;* CI_16080
                            LOCATE K.ID IN R.ETT<1> SETTING Y.POS ELSE Y.POS = ''
                        END
                        IF Y.POS = '' THEN
                            R.ETT<-1> = K.ID
                            WRITE R.ETT TO F.FILENAME.ETT, OUR.REF    ;* CI_16080
                        END
                    END
                END ;* BG_100004429
            END
        END
    REPEAT
    RETURN

*-----------------------------------------------------------------------------
COMPANY.INITIALISATION:
* COMPANY specific initialisation
* open files and read records specific to each company

    UNAUTH.REQD = 0
    HIST.REQD = 0
    FN.FILENAME = 'F.EB.FREE.MESSAGE'
    FN.FILENAME.NAU = 'F.EB.FREE.MESSAGE$NAU'
    FN.FILENAME.HIS = 'F.EB.FREE.MESSAGE$HIS'
    FN.FILENAME.EST = 'F.EB.SCHEDULE.TRACER'
    FN.FILENAME.ETT = 'F.EB.TXN.TRACER'
    REC.PATH = ''
    NAU.HIS.PROC = ''
    F.FILENAME = '' ; F.FILENAME.EST = '' ; F.FILENAME.ETT = ''
    CALL OPF(FN.FILENAME,F.FILENAME)
    CALL OPF(FN.FILENAME.EST,F.FILENAME.EST)
    CALL OPF(FN.FILENAME.ETT,F.FILENAME.ETT)

    LOCATE "$NAU" IN R.FILE.CONTROL<SUFFIXES,1> SETTING YPOS THEN
        UNAUTH.REQD = 1
        F.FILENAME$NAU = ''
        CALL OPF(FN.FILENAME.NAU,F.FILENAME$NAU)
    END

    LOCATE "$HIS" IN R.FILE.CONTROL<SUFFIXES,1> SETTING YPOS THEN
        HIST.REQD = 1
        F.FILENAME$HIS = ''
        CALL OPF(FN.FILENAME.HIS,F.FILENAME$HIS)
    END

    RETURN

*-----------------------------------------------------------------------------
GET.FILE.CLASSIFICATION:
* Read from FILE.CONTROL and get list of companies to be converted.

    R.FILE.CONTROL = ''
    READ R.FILE.CONTROL FROM F.FILE.CONTROL,PGM.NAME ELSE
        CALL FATAL.ERROR('CONV.EB.FREE.MESSAGE.G14')
    END

    CLASSIFICATION = R.FILE.CONTROL<FILE.CONTROL.CLASS>
    CALL GET.CONVERSION.COMPANIES(CLASSIFICATION,PGM.NAME,COMPANIES)

    RETURN

*-----------------------------------------------------------------------------
INITIALISATION:

    PGM.NAME = 'EB.FREE.MESSAGE'

    RETURN

*-----------------------------------------------------------------------------
CLEAR.OLD.FILES:

    REC.PATH = ''
    OPEN '',F.FILENAME.OLD TO REC.PATH ELSE RETURN
    CLEARFILE REC.PATH
    RETURN

END
