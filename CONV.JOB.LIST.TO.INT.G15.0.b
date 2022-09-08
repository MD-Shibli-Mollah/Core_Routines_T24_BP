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
* <Rating>56</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Service
    SUBROUTINE CONV.JOB.LIST.TO.INT.G15.0

*----------------------------------------------------------------------------*
* Since the generic .LIST files used during COB is going to be of INT        *
* type hereafter, we have to delete all the existing generic JOB.LIST files  *
* of format FXXX.JOB.LIST.0N ( XXX - mnemonic , 0N - Session.no ). Only then *
* new generic JOB.LIST files of type INT (F.JOB.LIST.0N) will get created    *
*----------------------------------------------------------------------------*
* Modifications :
* --------------

* 22/09/04 - BG_100007270
*            Creation
*
* 16/02/05 - CI_10027425
*            Change File Classification of file.control for list files
*            from FIN to INT.
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FILE.CONTROL

    GOSUB GET.LIST
    GOSUB DELETE.FILES
    GOSUB PROCESS.FILE.CONTROL

    RETURN
*------------------------------------------------------------------------------
GET.LIST:
*--------

    OPEN "VOC" TO F.VOC ELSE
        TEXT = "NO VOC FILE FOUND"
        CALL FATAL.ERROR("CONV.JOB.LIST.TO.INT.G15.0")
    END

    SEL = 'SELECT VOC WITH @ID LIKE "F3X.JOB.LIST.0N"'
    IDS.SEL = '' ; NO.OF.SEL = 0 ; SEL.ERR = ''
    CALL EB.READLIST(SEL,IDS.SEL,'',NO.OF.SEL,SEL.ERR)

    RETURN
*------------------------------------------------------------------------------
DELETE.FILES:
*-----------

    LOOP
        REMOVE LIST.FILE.ID FROM IDS.SEL SETTING POS
    WHILE LIST.FILE.ID:POS

        CRT " Deleting the file ":LIST.FILE.ID
        COMMAND = 'DELETE.FILE ':LIST.FILE.ID
        EXECUTE COMMAND
        DELETE F.VOC,LIST.FILE.ID       ;* Removing the VOC entry for the file

    REPEAT
    RETURN
*----------------------------------------------------------------------------
PROCESS.FILE.CONTROL:
    SEL.CMD = "SELECT F.FILE.CONTROL WITH @ID LIKE 'JOB.LIST.0N'"
    IDS.FSEL = '' ; NO.OF.FSEL = 0 ; FSEL.ERR = ''
    CALL EB.READLIST(SEL.CMD,IDS.FSEL,'',NO.OF.FSEL,FSEL.ERR)
    IF NO.OF.FSEL > 1 THEN    ;* there should be more than 1 list file to delete.
        OPEN '','F.FILE.CONTROL' TO F.FC ELSE
            TEXT = "NO FILE.CONTROL FOUND"
            CALL FATAL.ERROR("CONV.JOB.LIST.TO.INT.G15.0")
        END
        GOSUB CHANGE.FIN.TO.INT
    END
    RETURN

*----------------------------------------------------------------------------
CHANGE.FIN.TO.INT:

    LOOP
        REMOVE IDS.FC FROM IDS.FSEL SETTING POS
    WHILE POS:IDS.FC
        READ R.FC.RECORD FROM F.FC,IDS.FC ELSE R.FC.RECORD = ''
        IF R.FC.RECORD<EB.FILE.CONTROL.CLASS> = "FIN" THEN
            R.FC.RECORD<EB.FILE.CONTROL.CLASS> = "INT"
            WRITE R.FC.RECORD TO  F.FC,IDS.FC
        END
    REPEAT

    RETURN
END
