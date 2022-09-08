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

* Version 3 02/06/00  GLOBUS Release No. G14.1.01 04/12/03
*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScfConfig
    SUBROUTINE CONV.SC.FEE.GROUP.G15.0.FILE
*-----------------------------------------------------------------------------
* Conversion file routine to move all the records from the old INT level file
* to the FIN level file.
*-----------------------------------------------------------------------------
* Modification History :
*
* 10/05/04 - GLOBUS_EN_10002262
*            New program
*
* 27/05/04 - GLOBUS_BG_100006699
*            RUN.CONVERSION.PGMS records false errors as $HIS file does
*            not exist.
*
* 20/04/06 - GLOBUS_CI_10040613
*            Records were not copied from INT to FIN file during the conv
*            because the EB.READLIST calls OPF which fails to open the
*            INT level file due to the incorrect path. In addition this routine
*            is made multicompany compatible.
*
* 05/10/07 - GLOBUS_CI_10051707
*            System fatals out due to missing SEC.ACC.MASTER file in the
*            company where SC product is not installed.
*
* 09/12/08 - GLOBUS_CI_10059339
*            Conversion fails while running RUN.CONVERSION.PGMS
*
* 26/04/11 - DEFECT -195091 TASK -198342
*            Records in INT level SC.FEE.GROUP/SC.FEE.GROUP.HIST file not removed after conversion to FIN
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
*-----------------------------------------------------------------------------

    SAVE.ID.COMPANY = ID.COMPANY
*
* Loop through each company
*
* Not for Conslidation and Reporting companies

    COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COMPANY.LIST = ''
    CALL EB.READLIST(COMMAND, COMPANY.LIST, '','','')

    LOOP
        REMOVE K.COMPANY FROM COMPANY.LIST SETTING MORE.COMP
    WHILE K.COMPANY:MORE.COMP
        *
        IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END

        SC.INSTALLED = ''
        LOCATE 'SC' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING SC.INSTALLED ELSE
            CONTINUE          ;* Process the next Company from the list
        END

        GOSUB INITIALISE

        SUFFIX = '' ;* live file
        GOSUB MOVE.INT.TO.FIN

        SUFFIX = '$NAU'       ;* unauthorised file
        GOSUB MOVE.INT.TO.FIN

        * Processing for this company now complete.
    REPEAT
    GOSUB CLEAR.OLD.FILE
* Processing now complete for all companies.
* Change back to the original company if we have changed.
*
    IF ID.COMPANY <> SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    RETURN

*--------------
CLEAR.OLD.FILE:
*--------------
    F.SC.FEE.GROUP = ''
    OPEN 'F.SC.FEE.GROUP' TO F.SC.FEE.GROUP ELSE
        ETEXT = 'CANNOT OPEN FILE F.SC.FEE.GROUP'
    END

    CLEARFILE F.SC.FEE.GROUP
    F.SC.FEE.GROUP = ''
    OPEN 'F.SC.FEE.GROUP$NAU' TO F.SC.FEE.GROUP ELSE
        ETEXT = 'CANNOT OPEN FILE F.SC.FEE.GROUP$NAU'
    END
    CLEARFILE F.SC.FEE.GROUP

    RETURN
*
*-----------------------------------------------------------------------------
INITIALISE:

    FN.SEC.ACC.MASTER = 'F.SEC.ACC.MASTER'
    F.SEC.ACC.MASTER = ''
    CALL OPF(FN.SEC.ACC.MASTER,F.SEC.ACC.MASTER)

    FILE.TO.CONVERT = 'SC.FEE.GROUP'
    SAM.FIELD = 0

    RETURN
*
*-----------------------------------------------------------------------------
MOVE.INT.TO.FIN:
* open the files, both source and destination, if opened ok then move the
* records depending on the SAM record.

    FN.INT.FILE = 'F.':FILE.TO.CONVERT:SUFFIX
    OPEN FN.INT.FILE TO F.INT.FILE ELSE
        ETEXT = 'CANNOT OPEN ':FN.INT.FILE
    END

    IF ETEXT = '' THEN
        FN.FIN.FILE = 'F.':FILE.TO.CONVERT:SUFFIX
        F.FIN.FILE = ''
        CALL OPF(FN.FIN.FILE:FM:'NO.FATAL.ERROR',F.FIN.FILE)
    END

    IF ETEXT = '' THEN
        GOSUB DO.THE.MOVE
    END

    RETURN

*-----------------------------------------------------------------------------
DO.THE.MOVE:
* select the source file and do the move,
* use direct SELECT, as EB.READLIST inturn calls OPF where it tries to open FBNK...

    EXECUTE ' SELECT ':FN.INT.FILE

    LOOP
        READNEXT ID
        ELSE
        ID = ''
    END
    WHILE ID <> ''
    SOURCE.ID = ID
    YERR = ''
    READ R.SOURCE FROM F.INT.FILE,SOURCE.ID ELSE
        * use READ as F.READ doesn't work, it tries to read from FBNK...
        YERR = 'RECORD NOT FOUND'
    END
    IF YERR = '' THEN
        * Check that the record did exist!
        SEC.ACC.MASTER.ID = SOURCE.ID
        SAM.ERR = ''
        CALL F.READ(FN.SEC.ACC.MASTER,SEC.ACC.MASTER.ID,R.SEC.ACC.MASTER,F.SEC.ACC.MASTER,SAM.ERR)
        IF SAM.ERR = '' THEN
            * SAM record exists in this company,
            FIN.ERR = ''
            CALL F.READ(FN.FIN.FILE,SOURCE.ID,R.DESTINATION,F.FIN.FILE,FIN.ERR)
            IF FIN.ERR NE '' THEN
                * only do the write if the record doesn't already exist (perhaps the conversion crashed?!)
                CALL F.WRITE(FN.FIN.FILE,SOURCE.ID,R.SOURCE)
                CALL JOURNAL.UPDATE(SOURCE.ID)
            END
        END
    END
    REPEAT

    RETURN

    END
