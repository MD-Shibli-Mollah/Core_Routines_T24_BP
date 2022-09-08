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
* <Rating>669</Rating>
*-----------------------------------------------------------------------------
* Version 1 19/06/00  GLOBUS Release No. G10.2.02

    $PACKAGE PC.Contract
    SUBROUTINE PC.UPDATE.REQUEST
* 21/09/02 - EN_10001196
*            Conversion of error messages to error codes.
*
* 20/02/03 - GLOBUS_BG_100003483
*            Converted '$' to '_' in routine name.
*
* 04/06/03 - GLOBUS_BG_100004358
*            Conversion "$" & "_"  to "."  in routine name.
*            (overwrite/ignore the previous conversion of  "$" to "_").
*            This is to ensure that routines will compile and work in
*            jBASE 4.1 and on non ASCII platforms.
*
* 24/06/05 - EN_10002593
*            Changes done to stop verifing a NULL record.
*            Ref: SAR-2005-05-06-0014
*
* 05/03/07 - EN_10003242
*            Modified to call DAS to select data.
*************************************************************************
    $USING PC.Contract
    $USING EB.Display
    $USING EB.TransactionControl
    $USING EB.ErrorProcessing
    $USING EB.OverrideProcessing
    $USING EB.Template
    $USING EB.SystemTables
    $USING EB.API
    $USING EB.DataAccess

*************************************************************************

* Call $RUN Routine and Exit if running as Phantom *

    IF EB.SystemTables.getPhno() THEN
        PC.Contract.UpdateRequestRun()
        GOTO V$EXIT
    END

    GOSUB DEFINE.PARAMETERS

    IF LEN(EB.SystemTables.getVFunction()) GT 1 THEN
        GOTO V$EXIT
    END

    EB.Display.MatrixUpdate()

    GOSUB INITIALISE                   ; * Special Initialising

*************************************************************************

* Main Program Loop

    LOOP

        EB.TransactionControl.RecordidInput()

    UNTIL (EB.SystemTables.getMessage() EQ 'RET')

        V$ERROR = ''

        IF EB.SystemTables.getMessage() EQ 'NEW FUNCTION' THEN

            GOSUB CHECK.FUNCTION         ; * Special Editing of Function

            IF EB.SystemTables.getVFunction() EQ 'E' OR EB.SystemTables.getVFunction() EQ 'L' THEN
                EB.Display.FunctionDisplay()
                EB.SystemTables.setVFunction('')
            END
            IF EB.SystemTables.getVFunction() EQ 'V' THEN
                EB.SystemTables.setFileType("I")
            END

        END ELSE

            GOSUB CHECK.ID               ; * Special Editing of ID
            IF V$ERROR THEN
                EB.ErrorProcessing.Err()
                GOTO MAIN.REPEAT
            END

            EB.TransactionControl.RecordRead()

            IF EB.SystemTables.getMessage() EQ 'REPEAT' THEN
                GOTO MAIN.REPEAT
            END

            EB.Display.MatrixAlter()

            REM >       GOSUB CHECK.RECORD              ;* Special Editing of Record
            REM >       IF ERROR THEN GOTO MAIN.REPEAT

            REM >       GOSUB PROCESS.DISPLAY           ;* For Display applications

            LOOP
                GOSUB PROCESS.FIELDS      ; * ) For Input
                GOSUB PROCESS.MESSAGE     ; * ) Applications
            WHILE (EB.SystemTables.getMessage() EQ 'ERROR') REPEAT

        END

MAIN.REPEAT:
    REPEAT

V$EXIT:
    RETURN                             ; * From main program

*************************************************************************
*                      S u b r o u t i n e s                            *
*************************************************************************

PROCESS.FIELDS:

* Input or display the record fields.

    LOOP
        IF EB.SystemTables.getScreenMode() EQ 'MULTI' THEN
            IF EB.SystemTables.getFileType() EQ 'I' THEN
                EB.Display.FieldMultiInput()
            END ELSE
                EB.Display.FieldMultiDisplay()
            END
        END ELSE
            IF EB.SystemTables.getFileType() EQ 'I' THEN
                EB.Display.FieldInput()
            END ELSE
                EB.Display.FieldDisplay()
            END
        END

    WHILE NOT(EB.SystemTables.getMessage())

        GOSUB CHECK.FIELDS              ; * Special Field Editing

        IF EB.SystemTables.getTSequ() NE '' THEN
            tmp=EB.SystemTables.getTSequ(); tmp<-1>=EB.SystemTables.getA() + 1; EB.SystemTables.setTSequ(tmp)
        END

    REPEAT

    RETURN

*************************************************************************

PROCESS.MESSAGE:

* Processing after exiting from field input (PF5)

    IF EB.SystemTables.getMessage() = 'VAL' OR EB.SystemTables.getMessage() EQ 'VER' THEN
        EB.SystemTables.setMessage('')
        BEGIN CASE
            CASE EB.SystemTables.getVFunction() EQ 'R'
                EB.SystemTables.setEndError("")
                GOSUB CHECK.REVERSAL      ; * Special Reversal checks
            CASE EB.SystemTables.getVFunction() EQ 'V'
                GOSUB CHECK.CHANGES       ; * look for changed field
                IF YWRITE EQ 0 AND NOT(EB.SystemTables.getEndError()) THEN
                    GOSUB CALL.$RUN        ; * update using $RUN
                    GOTO PROCESS.MESSAGE.EXIT        ; * and return to Id
                END
            CASE 1
                GOSUB CROSS.VALIDATION      ;* Special Cross Validation
        END CASE

        IF EB.SystemTables.getEndError() THEN
            GOSUB POINT.TO.ERROR         ; * position on error field
            GOTO PROCESS.MESSAGE.EXIT    ; * return to field input
        END

        IF NOT(V$ERROR) THEN
            GOSUB BEFORE.AUTH.WRITE      ; * Special Processing before write
        END

        IF NOT(V$ERROR) THEN
            EB.TransactionControl.AuthRecordWrite()

            IF EB.SystemTables.getMessage() <> "ERROR" THEN
                GOSUB AFTER.AUTH.WRITE    ; * Special Processing after write

                IF EB.SystemTables.getVFunction() EQ 'V' THEN
                    GOSUB CALL.$RUN
                END

            END

        END

    END

PROCESS.MESSAGE.EXIT:

    RETURN

*************************************************************************

PROCESS.DISPLAY:

* Display the record fields.

    IF EB.SystemTables.getScreenMode() EQ 'MULTI' THEN
        EB.Display.FieldMultiDisplay()
    END ELSE
        EB.Display.FieldDisplay()
    END

    RETURN

*************************************************************************
*                      Special Tailored Subroutines                     *

CHECK.CHANGES:

    EB.SystemTables.setA(1)
    GOSUB CROSS.VALIDATION
    YWRITE = 0
    IF EB.SystemTables.getEndError() EQ '' THEN
        EB.SystemTables.setA(1)
        LOOP UNTIL EB.SystemTables.getA() GT EB.SystemTables.getV() OR YWRITE DO
            IF EB.SystemTables.getRNew(EB.SystemTables.getA()) NE EB.SystemTables.getROld(EB.SystemTables.getA()) THEN YWRITE = 1 ELSE EB.SystemTables.setA(EB.SystemTables.getA()+1)
        REPEAT
    END

    RETURN

POINT.TO.ERROR:

    IF EB.SystemTables.getEndError() EQ 'Y' THEN
        EB.SystemTables.setP(0); EB.SystemTables.setA(1)
        LOOP UNTIL EB.SystemTables.getTEtext()<EB.SystemTables.getA()> NE '' DO
            EB.SystemTables.setA(EB.SystemTables.getA()+ 1)
        REPEAT
        EB.SystemTables.setTSequ(EB.SystemTables.getA())
        IF EB.SystemTables.getScreenMode() EQ 'SINGLE' THEN
            tmp.C.F = EB.API.getCF()
            IF EB.SystemTables.getInputBuffer()[1,LEN(tmp.C.F)] EQ EB.API.getCF() THEN
                tmp.C.F = EB.API.getCF()
                EB.SystemTables.setInputBuffer(EB.SystemTables.getInputBuffer()[LEN(tmp.C.F) + 2,99])
                ; * cancel C.F function after C.W usage
                ; * (+2 for space separator)
            END
        END ELSE
            EB.SystemTables.setE(EB.SystemTables.getTEtext()<EB.SystemTables.getA()>)
            EB.ErrorProcessing.Err()
        END
    END ELSE
        EB.SystemTables.setTSequ('ACTION'); EB.SystemTables.setE(EB.SystemTables.getEndError()); EB.SystemTables.setL(22)
        EB.ErrorProcessing.Err()
    END

    EB.OverrideProcessing.DisplayMessage("", "1")      ; * Clear the VALIDATED message
    EB.SystemTables.setValText("")
    EB.SystemTables.setMessage('ERROR')

    RETURN

CALL.$RUN:

* Process the 'Work' file using the $Run Routine *

    EB.SystemTables.setVFunction(FUNCTION.SAVE)

    PC.Contract.UpdateRequestRun()

    IF EB.SystemTables.getVFunction() EQ 'B' THEN
        EB.SystemTables.setVFunction('V')
    END

    RETURN

OPEN.PERIOD.FILE:


    PER.REC = '' ; PER.ID = EB.SystemTables.getIdNew() ; ERTXT = ''
    PER.REC = PC.Contract.Period.Read(PER.ID, ERTXT)
    RETURN

*************************************************************************

CHECK.ID:

* Check if this database exists . If not , no point in going on

    MESS = 'Checking DBase'
    EB.OverrideProcessing.DisplayMessage(MESS,4)

    VLIST        = EB.SystemTables.dasVocIdlk
    THE.ARGS     = '...PC' : EB.SystemTables.getIdNew() : '...'
    TABLE.SUFFIX = ''
    EB.DataAccess.Das('VOC',VLIST, THE.ARGS, TABLE.SUFFIX)

    IF NOT(VLIST) THEN
        EB.SystemTables.setE('PC.PUR.PC.DATABASE.NOT.CREATED.YET':@FM:OCONV(ICONV(EB.SystemTables.getIdNew(),'D'),'D'))
    END ELSE

        GOSUB OPEN.PERIOD.FILE
        IF PER.REC<PC.Contract.Period.PerPeriodStatus> = 'CLOSED' THEN
            EB.SystemTables.setE('PC.PUR.PERIOD.CLOSED.PROCESSING')
        END ELSE
            WHAT = 'OPEN'
            LOCATE WHAT IN PER.REC<PC.Contract.Period.PerCompStatus,1> SETTING FF ELSE
            EB.SystemTables.setE('PC.PUR.THERE.NO.OPEN.COMPANIES.PERIOD':@FM:EB.SystemTables.getIdNew())
        END
    END
    END

    IF EB.SystemTables.getE() THEN V$ERROR = 1

    RETURN

*************************************************************************

CHECK.RECORD:

* Validation and changes of the Record.  Set ERROR to 1 if in error.

    RETURN

*************************************************************************

CHECK.FIELDS:

    BEGIN CASE
        CASE EB.SystemTables.getAf() = PC.Contract.UpdateRequest.ReqAllComp
            IF EB.SystemTables.getComi() EQ 'Y' THEN
                IF EB.SystemTables.getRNew(PC.Contract.UpdateRequest.ReqCompany) THEN
                    EB.SystemTables.setE('PC.PUR.YOU.HAVE.ENT.SPECIFIC.COMP.ALRDY')
                END
            END ELSE
                IF NOT(EB.SystemTables.getRNew(PC.Contract.UpdateRequest.ReqCompany)) THEN
                    EB.SystemTables.setE('PC.PUR.NO.COMPANY,SO.FLD.MAND')
                END
            END

        CASE EB.SystemTables.getAf() = PC.Contract.UpdateRequest.ReqCompany
            IF NOT(ERTXT) AND EB.SystemTables.getComi() <> '' THEN
                LOCATE EB.SystemTables.getComi() IN PER.REC<PC.Contract.Period.PerCompany,1> SETTING YUP THEN
                IF PER.REC<PC.Contract.Period.PerCompStatus,YUP> = 'CLOSED' THEN
                    EB.SystemTables.setE('PC.PUR.COMP.CLOSED.PROCESSING':@FM:EB.SystemTables.getComi())
                END
            END ELSE
                EB.SystemTables.setE('PC.PUR.NO.PC.PERIOD.SPECIFIED':@FM:EB.SystemTables.getComi())
            END
        END
    END CASE

    IF EB.SystemTables.getE() THEN
        EB.SystemTables.setTSequ("IFLD")
        EB.ErrorProcessing.Err()
    END

    RETURN

*************************************************************************

CROSS.VALIDATION:

*
    V$ERROR = ''
    EB.SystemTables.setEtext('')
    EB.SystemTables.setText('')
*
    EB.SystemTables.setAf(PC.Contract.UpdateRequest.ReqAllComp)
    IF EB.SystemTables.getRNew(PC.Contract.UpdateRequest.ReqAllComp) EQ 'Y' THEN
        IF EB.SystemTables.getRNew(PC.Contract.UpdateRequest.ReqCompany) THEN
            EB.SystemTables.setEtext('PC.PUR.YOU.HAVE.ENT.SPECIFIC.COMP.ALRDY')
        END
    END ELSE
        IF NOT(EB.SystemTables.getRNew(PC.Contract.UpdateRequest.ReqCompany)) THEN
            EB.SystemTables.setEtext('PC.PUR.NO.COMPANY,SO.FLD.MAND')
        END
    END

    IF EB.SystemTables.getEtext() THEN
        EB.SystemTables.setAv(1); EB.SystemTables.setAs('')
        EB.ErrorProcessing.StoreEndError()
    END

    EB.SystemTables.setAf(PC.Contract.UpdateRequest.ReqCompany); EB.Template.Dup()
    EB.SystemTables.setEtext('')

    NO.OF.MVS = COUNT(EB.SystemTables.getRNew(PC.Contract.UpdateRequest.ReqCompany),@VM)+ (EB.SystemTables.getRNew(PC.Contract.UpdateRequest.ReqCompany) <> '')

    FOR COMP.ID = 1 TO NO.OF.MVS
        COMP = EB.SystemTables.getRNew(PC.Contract.UpdateRequest.ReqCompany)<1,COMP.ID>
        LOCATE COMP IN PER.REC<PC.Contract.Period.PerCompany,1> SETTING YUP THEN
        IF PER.REC<PC.Contract.Period.PerCompStatus,YUP> = 'CLOSED' THEN
            EB.SystemTables.setAv(COMP.ID); EB.SystemTables.setAs('')
            EB.SystemTables.setEtext('PC.PUR.COMP.CLOSED.PROCESSING':@FM:EB.SystemTables.getComi())
            EB.ErrorProcessing.StoreEndError()
        END
    END ELSE
        EB.SystemTables.setAv(COMP.ID); EB.SystemTables.setAs('')
        EB.SystemTables.setEtext('PC.PUR.NO.PC.PERIOD.SPECIFIED':@FM:EB.SystemTables.getComi())
        EB.ErrorProcessing.StoreEndError()
    END
    NEXT COMP.ID

* If END.ERROR has been set then a cross validation error has occurred
*
    IF EB.SystemTables.getEndError() THEN
        EB.SystemTables.setA(1)
        LOOP UNTIL EB.SystemTables.getTEtext()<EB.SystemTables.getA()> <> "" DO EB.SystemTables.setA(EB.SystemTables.getA()+1); REPEAT
        EB.SystemTables.setTSequ('D')
        tmp=EB.SystemTables.getTSequ(); tmp<-1>=EB.SystemTables.getA(); EB.SystemTables.setTSequ(tmp)
        V$ERROR = 1
        EB.SystemTables.setMessage('ERROR')
    END
    RETURN                             ; * Back to field input via UNAUTH.RECORD.WRITE

*************************************************************************

OVERRIDES:
*
*  Overrides should reside here.
*
    V$ERROR = ''
    EB.SystemTables.setEtext('')
    EB.SystemTables.setText('')
REM > CALL XX.OVERRIDE
*

*
    IF EB.SystemTables.getText() = "NO" THEN                ; * Said NO to override
        V$ERROR = 1
        EB.SystemTables.setMessage("ERROR"); * Back to field input

    END
    RETURN

*************************************************************************

AUTH.CROSS.VALIDATION:


    RETURN

*************************************************************************

CHECK.DELETE:


    RETURN

*************************************************************************

CHECK.REVERSAL:


    RETURN


*************************************************************************

BEFORE.UNAU.WRITE:
*
*  Contract processing code should reside here.
*
REM > CALL XX.         ;* Accounting, Schedule processing etc etc

    IF EB.SystemTables.getText() = "NO" THEN                ; * Said No to override
        EB.TransactionControl.TransactionAbort()          ; * Cancel current transaction
        V$ERROR = 1
        EB.SystemTables.setMessage("ERROR"); * Back to field input
        RETURN
    END

*
* Additional updates should be performed here
*
REM > CALL XX...



    RETURN

*************************************************************************

AFTER.UNAU.WRITE:

    RETURN

*************************************************************************

AFTER.AUTH.WRITE:

    RETURN

*************************************************************************

BEFORE.AUTH.WRITE:

    BEGIN CASE
        CASE EB.SystemTables.getRNew(EB.SystemTables.getV()-8)[1,3] = "INA"    ; * Record status
            REM > CALL XX.AUTHORISATION
        CASE EB.SystemTables.getRNew(EB.SystemTables.getV()-8)[1,3] = "RNA"    ; * Record status
            REM > CALL XX.REVERSAL

    END CASE
*
* If there are any OVERRIDES a call to EXCEPTION.LOG should be made
*
* IF R.NEW(V-9) THEN
*    EXCEP.CODE = "110" ; EXCEP.MESSAGE = "OVERRIDE CONDITION"
*    GOSUB EXCEPTION.MESSAGE
* END
*

    RETURN

*************************************************************************

CHECK.FUNCTION:

* Validation of function entered.  Set FUNCTION to null if in error.

    FUNCTION.SAVE = EB.SystemTables.getVFunction()
    IF EB.SystemTables.getVFunction() EQ "B" THEN
        EB.SystemTables.setVFunction("V")
        EB.SystemTables.setIdAll("")
    END
    IF INDEX('ADEFQ',EB.SystemTables.getVFunction(),1) THEN
        EB.SystemTables.setE('PC.PUR.FUNT.NOT.ALLOW.APP')
        EB.ErrorProcessing.Err()
        EB.SystemTables.setVFunction('')
    END

    RETURN

*************************************************************************
*
EXCEPTION.MESSAGE:
*
    APPLN = EB.SystemTables.getApplication()
    EXCEP.MESSAGE = ''
    ACCT.OFFICER = ''
    EB.ErrorProcessing.ExceptionLog("U",APP.CODE,APPLN,APPLN,EXCEP.CODE,"",EB.SystemTables.getFullFname(),EB.SystemTables.getIdNew(),EB.SystemTables.getRNew(EB.SystemTables.getV()-7),EXCEP.MESSAGE,ACCT.OFFICER)

*
    RETURN

*************************************************************************

INITIALISE:


    RETURN

*************************************************************************

DEFINE.PARAMETERS:

    EB.SystemTables.clearF()
    EB.SystemTables.clearN()
    EB.SystemTables.clearT()
    EB.SystemTables.setIdT("")
    EB.SystemTables.clearCheckfile()
    EB.SystemTables.clearConcatfile()
    EB.SystemTables.setIdCheckfile("PC.PERIOD"); EB.SystemTables.setIdConcatfile("")
    Z = 0

    EB.SystemTables.setIdF('PERIOD.END'); EB.SystemTables.setIdN('11..C'); tmp=EB.SystemTables.getIdT(); tmp<1>='D'; EB.SystemTables.setIdT(tmp)

    Z += 1 ; EB.SystemTables.setF(Z, "XX.COMPANY"); EB.SystemTables.setN(Z, "10..C"); tmp=EB.SystemTables.getT(Z); tmp<1>="COM"; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, "ALL.COMP"); EB.SystemTables.setN(Z, '3..C'); tmp=EB.SystemTables.getT(Z); tmp<2>='Y'; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, 'RESERVED.1'); EB.SystemTables.setN(Z, ''); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, 'RESERVED.2'); EB.SystemTables.setN(Z, ''); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, 'RESERVED.3'); EB.SystemTables.setN(Z, ''); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)

    EB.SystemTables.setV(Z + 9); EB.SystemTables.setPrefix('PC.REQ')

    RETURN

*************************************************************************

    END
