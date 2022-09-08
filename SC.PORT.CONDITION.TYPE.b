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

* Version 3 07/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>222</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScvConfig
    SUBROUTINE SC.PORT.CONDITION.TYPE
************************************************************************
* Description                                                          *
* ===========                                                          *
*                                                                      *
************************************************************************
* Modification                                                         *
* ============                                                         *
*                                                                      *
* 23/07/99 - GB9900890
*                                                                      *
* 24/09/02 - EN_10001219
*            Conversion of error messages to error codes.
*                                                                      *
* 24/05/06 - BG_100011333
*            Remove BY from select statement to make DAS changes
*            easier. Get rid of goto where possible.
*
* 22/02/07 - EN_10003206
*            Securities DAS Phase II (Product: SC)
* 12-01-16 - 1596222
*            Incorporation of Components
*
************************************************************************
    $INSERT I_DAS.SC.PORT.CONDITION.TYPE

    $USING SC.ScvConfig
    $USING EB.SystemTables
    $USING EB.Display
    $USING EB.TransactionControl
    $USING EB.API
    $USING EB.ErrorProcessing
    $USING EB.Template
    $USING EB.DataAccess

    GOSUB DEFINE.PARAMETERS

    tmp.V$FUNCTION = EB.SystemTables.getVFunction()
    IF LEN(tmp.V$FUNCTION) GT 1 THEN
        GOTO V$EXIT
    END

    EB.Display.MatrixUpdate()

    GOSUB INITIALISE                   ; * Special Initialising

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

        END ELSE

            REM >   GOSUB CHECK.ID
            IF V$ERROR THEN
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

************************************************************************
*                     S u b r o u t i n e s                            *
************************************************************************
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

        tmp.MESSAGE = EB.SystemTables.getMessage()
    WHILE NOT(tmp.MESSAGE)

        GOSUB CHECK.FIELDS              ; * Special Field Editing

        IF EB.SystemTables.getTSequ() NE '' THEN
            tmp=EB.SystemTables.getTSequ(); tmp<-1>=EB.SystemTables.getA() + 1; EB.SystemTables.setTSequ(tmp)
        END

    REPEAT

    RETURN

************************************************************************
PROCESS.MESSAGE:
* Processing after exiting from field input (PF5)

    IF EB.SystemTables.getMessage() EQ 'VAL' THEN
        EB.SystemTables.setMessage('')
        BEGIN CASE
            CASE EB.SystemTables.getVFunction() EQ 'D'
                REM >          GOSUB CHECK.DELETE              ;* Special Deletion checks
            CASE EB.SystemTables.getVFunction() EQ 'R'
                REM >          GOSUB CHECK.REVERSAL            ;* Special Reversal checks
            CASE 1
                GOSUB CROSS.VALIDATION    ; * Special Cross Validation
        END CASE
        REM >    IF NOT(ERROR) THEN
        REM >       GOSUB BEFORE.UNAU.WRITE         ;* Special Processing before write
        REM >    END
        IF NOT(V$ERROR) THEN
            EB.TransactionControl.UnauthRecordWrite()
            REM >       IF MESSAGE NE "ERROR" THEN
            REM >          GOSUB AFTER.UNAU.WRITE          ;* Special Processing after write
            REM >       END
        END

    END

    IF EB.SystemTables.getMessage() EQ 'AUT' THEN
        REM >    GOSUB AUTH.CROSS.VALIDATION          ;* Special Cross Validation
        REM >    IF NOT(ERROR) THEN
        GOSUB BEFORE.AUTH.WRITE         ; * Special Processing before write
        REM >    END

        IF NOT(V$ERROR) THEN

            EB.TransactionControl.AuthRecordWrite()

            REM >       IF MESSAGE NE "ERROR" THEN
            REM >          GOSUB AFTER.AUTH.WRITE          ;* Special Processing after write
            REM >       END
        END

    END

    RETURN

************************************************************************
PROCESS.DISPLAY:
* Display the record fields.

    IF EB.SystemTables.getScreenMode() EQ 'MULTI' THEN
        EB.Display.FieldMultiDisplay()
    END ELSE
        EB.Display.FieldDisplay()
    END

    RETURN

************************************************************************
*                     Special Tailored Subroutines                     *
************************************************************************
CHECK.ID:
* Validation and changes of the ID entered.  Set ERROR to 1 if in error.


    RETURN

************************************************************************
CHECK.RECORD:
* Validation and changes of the Record.  Set ERROR to 1 if in error.


    RETURN

************************************************************************
CHECK.FIELDS:
*
    BEGIN CASE
            *
        CASE EB.SystemTables.getAf() = SC.ScvConfig.ScPortConditionType.ScSpcFieldName
            IF EB.SystemTables.getComi() NE '' THEN
                tmp.COMI = EB.SystemTables.getComi()
                FIELD.NAME = FIELD(tmp.COMI,'>',1)
                tmp.COMI = EB.SystemTables.getComi()
                FILE.NAME = FIELD(tmp.COMI,'>',2)
                tmp.COMI = EB.SystemTables.getComi()
                TARGET.FIELD = FIELD(tmp.COMI,'>',3)
                R.SC.POS.ASSET = ''
                R.STANDARD.SELECTION = ''
                FIELD.POS = ''
                V$ERROR = ''
                EB.API.GetStandardSelectionDets('SC.POS.ASSET', R.SC.POS.ASSET)
                *
                LOCATE FIELD.NAME IN R.SC.POS.ASSET<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING FIELD.POS ELSE
                FIELD.POS = 0
            END
            *
            IF FIELD.POS = 0 THEN
                EB.SystemTables.setE('SC.SPCT.FLD.DOES.NOT.EXIST.ON.SC.POS.ASSET.FILE')
            END ELSE ; * BG_100011333
                IF FILE.NAME OR TARGET.FIELD THEN
                    V$ERROR = ''
                    EB.API.GetStandardSelectionDets(FILE.NAME, R.STANDARD.SELECTION)
                    *
                    IF V$ERROR # '' THEN
                        EB.SystemTables.setE('SC.SPCT.FILE.DOES.NOT.EXIST')
                    END ELSE ; * BG_100011333
                        FIELD.POS = 0
                        LOCATE TARGET.FIELD IN R.STANDARD.SELECTION<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING FIELD.POS ELSE
                        FIELD.POS = 0
                    END
                    IF FIELD.POS = 0 THEN
                        EB.SystemTables.setE('SC.SPCT.FLD.DOES.NOT.EXIST.ON.FILE.SPECIFIED')
                    END
                END   ; * BG_100011333
            END
        END   ; * BG_100011333
    END
*
    END CASE

    IF EB.SystemTables.getE() THEN
        EB.SystemTables.setTSequ("IFLD")
        EB.ErrorProcessing.Err()
    END
*
    RETURN

************************************************************************
CROSS.VALIDATION:
*
    V$ERROR = ''
    EB.SystemTables.setEtext('')
    EB.SystemTables.setText('')
*
REM > CALL XX.CROSS.VALIDATION
*
    EB.SystemTables.setAf(SC.ScvConfig.ScPortConditionType.ScSpcFieldName)
    EB.Template.FtNullsChk()
*
    tmp.AF = EB.SystemTables.getAf()
    AVC = DCOUNT(EB.SystemTables.getRNew(tmp.AF),@VM)
    FOR AV = 1 TO AVC
        EB.SystemTables.setAv(AV)
        tmp.AF = EB.SystemTables.getAf()
        IF EB.SystemTables.getRNew(tmp.AF)<1,EB.SystemTables.getAv()> AND EB.SystemTables.getRNew(SC.ScvConfig.ScPortConditionType.ScSpcOperand) = '' THEN
            EB.SystemTables.setEtext('SC.SPCT.OPERAND.NOT.SPECIFIED')
            EB.ErrorProcessing.StoreEndError()
        END
    NEXT AV
    EB.SystemTables.setAf(SC.ScvConfig.ScPortConditionType.ScSpcCombineCond)
    EB.Template.Dup()
    EB.Template.FtNullsChk()
*
    tmp.AF = EB.SystemTables.getAf()
    AVC = DCOUNT(EB.SystemTables.getRNew(tmp.AF),@VM)
    FOR AV = 1 TO AVC
        EB.SystemTables.setAv(AV)
        tmp.AF = EB.SystemTables.getAf()
        IF EB.SystemTables.getRNew(tmp.AF) = EB.SystemTables.getIdNew() THEN
            EB.SystemTables.setEtext('SC.SPCT.CANT.ID.REC')
            EB.ErrorProcessing.StoreEndError()
        END
    NEXT AV
*
    IF EB.SystemTables.getEndError() THEN                  ; * Cross validation error
        RETURN                          ; * Back to field input via UNAUTH.RECORD.WRITE
    END
*
*  Overrides should reside here.
*
REM > CALL XX.OVERRIDE
*
    IF EB.SystemTables.getText() = "NO" THEN                ; * Said NO to override
        V$ERROR = 1
        EB.SystemTables.setMessage("ERROR"); * Back to field input
        RETURN
    END
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

************************************************************************
AUTH.CROSS.VALIDATION:


    RETURN

************************************************************************
CHECK.DELETE:


    RETURN

************************************************************************
CHECK.REVERSAL:


    RETURN

************************************************************************
BEFORE.UNAU.WRITE:


    RETURN

************************************************************************
AFTER.UNAU.WRITE:


    RETURN

************************************************************************
AFTER.AUTH.WRITE:


    RETURN

************************************************************************
BEFORE.AUTH.WRITE:

    tmp.V = EB.SystemTables.getV()
    BEGIN CASE
        CASE EB.SystemTables.getRNew(tmp.V-8)[1,3] = "INA"    ; * Record status
            REM > CALL XX.AUTHORISATION
            tmp.V = EB.SystemTables.getV()
        CASE EB.SystemTables.getRNew(tmp.V-8)[1,3] = "RNA"    ; * Record status
            REM > CALL XX.REVERSAL

    END CASE
*
    IF EB.SystemTables.getIdOld() = '' THEN
        K.COND.TYPE = EB.SystemTables.getIdNew():'.PERC'
        GOSUB GET.NEW.CONDITION.NO ; * BG_100011333
        *
        EB.SystemTables.setRNew(SC.ScvConfig.ScPortConditionType.ScSpcConditionNo, CONDITION.NO + 1)
        *
************************************************************
        *             CREATE I DESCRIPTOR                          *
************************************************************
        *
        FIELD.STMT = 'SUBR("ENQ.TRANS","SC.PORT.MODEL",'
        FIELD.STMT = FIELD.STMT : '@ID'
        FIELD.STMT<1,1,2> = ',"COND.REF.PERC") ; @1<1,':EB.SystemTables.getRNew(SC.ScvConfig.ScPortConditionType.ScSpcConditionNo):'>'
        *
        NEXT.USR.FLD = DCOUNT(R.SEC.ACC.MASTER<EB.SystemTables.StandardSelection.SslUsrFieldName>,@VM)+1
        R.SEC.ACC.MASTER<EB.SystemTables.StandardSelection.SslUsrFieldName,NEXT.USR.FLD> = K.COND.TYPE
        R.SEC.ACC.MASTER<EB.SystemTables.StandardSelection.SslUsrType,NEXT.USR.FLD> = 'I'
        R.SEC.ACC.MASTER<EB.SystemTables.StandardSelection.SslUsrFieldNo,NEXT.USR.FLD> = FIELD.STMT
        R.SEC.ACC.MASTER<EB.SystemTables.StandardSelection.SslUsrDisplayFmt,NEXT.USR.FLD> = '11R'
        R.SEC.ACC.MASTER<EB.SystemTables.StandardSelection.SslUsrSingleMult,NEXT.USR.FLD> = 'S'
        EB.SystemTables.StandardSelectionWrite('SEC.ACC.MASTER', R.SEC.ACC.MASTER,'')
        * Before incorporation : CALL F.WRITE('F.STANDARD.SELECTION','SEC.ACC.MASTER',R.SEC.ACC.MASTER)
        *
        R.IDESCRIPTOR = ''
        R.IDESCRIPTOR<1> = 'I'
        R.IDESCRIPTOR<2> = FIELD.STMT
        R.IDESCRIPTOR<5> = '11R'
        R.IDESCRIPTOR<6> = 'S'
        *
        MATPARSE DIM.SS.REC FROM R.SEC.ACC.MASTER
        YERR = ''
        EB.SystemTables.BuildDictionary(MAT DIM.SS.REC,"F.SEC.ACC.MASTER",F.DICT.FILE,YERR)
    END

* If there are any OVERRIDES a call to EXCEPTION.LOG should be made
*
* IF R.NEW(V-9) THEN
*    EXCEP.CODE = "110" ; EXCEP.MESSAGE = "OVERRIDE CONDITION"
*    GOSUB EXCEPTION.MESSAGE
* END
*

    RETURN

************************************************************************
CHECK.FUNCTION:
* Validation of function entered.  Set FUNCTION to null if in error.

    tmp.V$FUNCTION = EB.SystemTables.getVFunction()
    IF INDEX('V',tmp.V$FUNCTION,1) OR INDEX('R',tmp.V$FUNCTION,1) THEN
        EB.SystemTables.setE('SC.SPCT.FUNT.NOT.ALLOW.APP')
        EB.ErrorProcessing.Err()
        EB.SystemTables.setVFunction('')
    END

    RETURN

************************************************************************
*
EXCEPTION.MESSAGE:
*
    tmp.V = EB.SystemTables.getV()
    tmp.R.NEW.tmp.V7 = EB.SystemTables.getRNew(tmp.V-7)
    tmp.ID.NEW = EB.SystemTables.getIdNew()
    tmp.FULL.FNAME = EB.SystemTables.getFullFname()
    tmp.APPLICATION = EB.SystemTables.getApplication()
    EB.ErrorProcessing.ExceptionLog("U",APP.CODE,tmp.APPLICATION,tmp.APPLICATION,EXCEP.CODE,"",tmp.FULL.FNAME,tmp.ID.NEW,tmp.R.NEW.tmp.V7,EXCEP.MESSAGE,ACCT.OFFICER)
*
    RETURN

************************************************************************
INITIALISE:
*
    DIM DIM.SS.REC(EB.SystemTables.StandardSelection.SslAuditDateTime)
*
    OPEN "DICT","F.SEC.ACC.MASTER" TO F.DICT.FILE ELSE
        EB.SystemTables.setText('CANNOT OPEN DICT F.SEC.ACC.MASTER'); * BG_100011333
        GOSUB FATAL.ERR        ; * BG_100011333
    END
*
*
    V$ERROR = ''
    R.SEC.ACC.MASTER = EB.SystemTables.StandardSelection.Read('SEC.ACC.MASTER', V$ERROR)
* Before incorporation : CALL F.READ('F.STANDARD.SELECTION','SEC.ACC.MASTER',R.SEC.ACC.MASTER,'',V$ERROR)
*
    APP.CODE = ""                      ; * Set to product code ; e.g FT, FX
    ACCT.OFFICER = ""                  ; * Used in call to EXCEPTION. Should be relevant A/O
    EXCEP.CODE = ""

    RETURN

************************************************************************
DEFINE.PARAMETERS:
* SEE 'I_RULES' FOR DESCRIPTIONS *
    DIM F(EB.SystemTables.SysDim)
    DIM N(EB.SystemTables.SysDim)
    DIM T(EB.SystemTables.SysDim)
    DIM CHECKFILE(EB.SystemTables.SysDim)
    DIM CONCATFILE(EB.SystemTables.SysDim)
    V=''

    MAT F = "" ; MAT N = "" ; MAT T = ""
    MAT CHECKFILE = "" ; MAT CONCATFILE = ""
    ID.CHECKFILE = "" ; ID.CONCATFILE = ""

    ID.F = "CONDITION.TYPE" ; ID.N = "10.3" ; ID.T = "A"
*
    Z=0
*
    Z += 1 ; F(Z) = 'XX<FIELD.NAME' ; N(Z) = '50..C' ; T(Z) = 'A'
    Z += 1 ; F(Z) = 'XX-OPERAND' ; N(Z) = '2' ; T(Z)<2> = 'EQ_NE_LK_UL_RG_NR_GE_LE_LT_GT'
    Z += 1 ; F(Z) = 'XX-FIELD.TYPE' ; N(Z) = '6' ; T(Z)<1> = '' ; T(Z)<2> = 'PERIOD'
    Z += 1 ; F(Z) = 'XX>XX.FIELD.VALUE' ; N(Z) = '50' ; T(Z)<1> = 'A'
    Z += 1 ; F(Z) = "XX.COMBINE.COND" ; N(Z) = '25' ; T(Z) = "A"
    CHECKFILE(Z) = 'SC.PORT.CONDITION.TYPE':@FM:0
    Z += 1 ; F(Z) = "RESERVE5" ; N(Z) = "" ; T(Z) = "" ; T(Z)<3> = 'NOINPUT'
    Z += 1 ; F(Z) = "RESERVE4" ; N(Z) = "" ; T(Z) = "" ; T(Z)<3> = 'NOINPUT'
    Z += 1 ; F(Z) = "RESERVE3" ; N(Z) = "" ; T(Z) = "" ; T(Z)<3> = 'NOINPUT'
    Z += 1 ; F(Z) = "RESERVE2" ; N(Z) = "" ; T(Z) = "" ; T(Z)<3> = 'NOINPUT'
    Z += 1 ; F(Z) = "RESERVE1" ; N(Z) = "" ; T(Z) = "" ; T(Z)<3> = 'NOINPUT'
*
    Z += 1 ; F(Z) = 'CONDITION.NO' ; N(Z) = '3' ; T(Z)<1> = 'N' ; T(Z)<3> = 'NOINPUT'

    V = Z + 9
    EB.SystemTables.SetFieldProperties(MAT F, MAT N, MAT T, MAT CONCATFILE, MAT CHECKFILE, V)
    EB.SystemTables.SetIdProperties(ID.F, ID.N, ID.T, ID.CONCATFILE, ID.CHECKFILE)
*
    RETURN

************************************************************************
GET.NEW.CONDITION.NO:
* get the condition number for this record, it will be the next available
* number given what already exists in the live file.
* BG_10001133 new subroutine,

    CONDITION.NO = ''
    SPC.LIST = ''
    SPC.LIST           = 'ALL.IDS' ; * EN_10003206 S
    THE.ARGS           = ""
    DAS.TABLE.SUFFIX   = ""

    EB.DataAccess.Das('SC.PORT.CONDITION.TYPE', SPC.LIST, THE.ARGS, DAS.TABLE.SUFFIX)
    IF EB.SystemTables.getE() THEN
        SPC.LIST = ""
    END                           ; * EN_10003206 E

    LOOP
        REMOVE K.SCP.TYPE FROM SPC.LIST SETTING SPC.MARK
    WHILE K.SCP.TYPE:SPC.MARK
        R.SC.PORT.CONDITION.TYPE = ''
        YERR = ''
        R.SC.PORT.CONDITION.TYPE = SC.ScvConfig.ScPortConditionType.Read(K.SCP.TYPE, YERR)
        * Before incorporation : CALL F.READ('F.SC.PORT.CONDITION.TYPE',K.SCP.TYPE,R.SC.PORT.CONDITION.TYPE,'',YERR)
        COND.NO = R.SC.PORT.CONDITION.TYPE<SC.ScvConfig.ScPortConditionType.ScSpcConditionNo>
        IF COND.NO > CONDITION.NO THEN
            CONDITION.NO = COND.NO
        END
    REPEAT

    RETURN

*------------------------------------------------------------------------
FATAL.ERR:
* call fatal.error and crash the routine with an unrecoverable error
* BG_100011333 new subr,

    EB.ErrorProcessing.FatalError('SC.PORT.CONDITION.TYPE')

    RETURN

    END
