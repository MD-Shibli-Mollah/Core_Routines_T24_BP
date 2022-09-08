* @ValidationCode : MjotMTU4MzcxNjI4MjpDcDEyNTI6MTU0MzU3MjI3MzU0Mjp5Z3JhamFzaHJlZToyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxODExLjIwMTgxMDIyLTE0MDY6Mjg0OjQ3
* @ValidationInfo : Timestamp         : 30 Nov 2018 15:34:33
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ygrajashree
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 47/284 (16.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* Version 7 16/03/01  GLOBUS Release No. G11.2.00 28/03/01
*-----------------------------------------------------------------------------
* <Rating>-307</Rating>



$PACKAGE DE.Clearing
SUBROUTINE DE.FORMAT.SIC
    $USING DE.Config
    $USING DE.Clearing
    $USING FT.Clearing
    $USING EB.Display
    $USING EB.TransactionControl
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING EB.API

*
* 26/07/93 - GB9301233
*            Allow conversion ADDRESS*SHORT, PTT*SHORT , SWIFT*SHORT
*
* 24/09/02 - GLOBUS_EN_10001221
*          Conversion Of all Error Messages to Error Codes
*
* 05/03/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 20/03/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE and generating .component
*
* 20/08/15 - Enhancement 1265068/ Task 1464647
*          - Routine incorporated
*
* 07/11/18 - Enhancement 2838570 / Task 2786448
*            Application is blocked if FT product is not installed
*************************************************************************

    GOSUB DEFINE.PARAMETERS

    IF LEN(EB.SystemTables.getVFunction()) GT 1 THEN
        RETURN      ;* BG_100013037 - S / E
    END

    EB.Display.MatrixUpdate()

    GOSUB INITIALISE          ;* Special Initialising

*************************************************************************

* Main Program Loop

    LOOP
        
        EB.TransactionControl.RecordidInput()
        
    UNTIL EB.SystemTables.getMessage() = 'RET' DO

        V$ERROR = ''

        IF EB.SystemTables.getMessage() = 'NEW FUNCTION' THEN

            GOSUB CHECK.FUNCTION        ;* Special Editing of Function

            IF EB.SystemTables.getVFunction() EQ 'E' OR EB.SystemTables.getVFunction() EQ 'L' THEN
                EB.Display.FunctionDisplay()
                EB.SystemTables.setVFunction('')
            END

        END ELSE

            GOSUB CHECK.ID    ;* Special Editing of ID
            GOSUB CHECK.REPEAT          ;* BG_100013037 - S / E
        END
    REPEAT
RETURN          ;* From main program


*************************************************************************
*                      S u b r o u t i n e s                            *
*************************************************************************
* BG_100013037 - S
*=============
CHECK.REPEAT:
*=============
    IF NOT(V$ERROR) THEN

        EB.TransactionControl.RecordRead()

        IF EB.SystemTables.getMessage() NE 'REPEAT' THEN


            EB.Display.MatrixAlter()

            GOSUB CHECK.RECORD          ;* Special Editing of Record
            IF NOT(V$ERROR) THEN

REM >       GOSUB PROCESS.DISPLAY           ;* For Display applications
                GOSUB LOOP.PROCESS
            END
        END
    END
RETURN
*************************************************************************
*============
LOOP.PROCESS:
*============

    LOOP
        GOSUB PROCESS.FIELDS  ;* ) For Input
        GOSUB PROCESS.MESSAGE ;* ) Applications
    WHILE EB.SystemTables.getMessage() = 'ERROR' DO REPEAT


RETURN          ;* BG_100013037 - E

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

    UNTIL EB.SystemTables.getMessage()<> "" DO

        GOSUB CHECK.FIELDS    ;* Special Field Editing

        IF EB.SystemTables.getTSequ() NE '' THEN
            tmp=EB.SystemTables.getTSequ(); tmp<-1>=EB.SystemTables.getA() + 1; EB.SystemTables.setTSequ(tmp);* BG_100013037 - S
        END         ;* BG_100013037 - E

    REPEAT

RETURN

*************************************************************************

PROCESS.MESSAGE:

* Processing after exiting from field input (PF5)

    IF EB.SystemTables.getMessage() = 'VAL' THEN
        EB.SystemTables.setMessage('')
        BEGIN CASE
            CASE EB.SystemTables.getVFunction() EQ 'D'
REM >          GOSUB CHECK.DELETE              ;* Special Deletion checks
            CASE EB.SystemTables.getVFunction() EQ 'R'
REM >          GOSUB CHECK.REVERSAL            ;* Special Reversal checks
            CASE 1
                GOSUB CROSS.VALIDATION      ;* Special Cross Validation
        END CASE
REM >    IF NOT(ERROR) THEN
REM >       GOSUB BEFORE.UNAU.WRITE         ;* Special Processing before write
REM >    END
        IF NOT(V$ERROR) THEN
            EB.TransactionControl.UnauthRecordWrite()
REM >       IF MESSAGE <> "ERROR" THEN
REM >          GOSUB AFTER.UNAU.WRITE          ;* Special Processing after write
REM >       END
        END

    END

    IF EB.SystemTables.getMessage() = 'AUT' THEN
REM >    GOSUB AUTH.CROSS.VALIDATION          ;* Special Cross Validation
        IF NOT(V$ERROR) THEN
            GOSUB BEFORE.AUTH.WRITE     ;* Special Processing before write
        END

        IF NOT(V$ERROR) THEN

            EB.TransactionControl.AuthRecordWrite()

REM >       IF MESSAGE <> "ERROR" THEN
REM >          GOSUB AFTER.AUTH.WRITE          ;* Special Processing after write
REM >       END
        END

    END

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
*************************************************************************

CHECK.ID:

* Validation and changes of the ID entered.  Set ERROR to 1 if in error.
* Message can be A10, A11, B10, B11, C10, C11, C15, H70, H71
* Sub products of messages can be input providing the main message
* has been defined. In this case the sub message must exist on FT.LOCAL
* .CLEARING in the diversion fields.

    tmp.ID.NEW = EB.SystemTables.getIdNew()
    MESSAGE.TYPE = FIELD(tmp.ID.NEW,"-",1)  ;* Extract field
    SUB.TYPE = FIELD(tmp.ID.NEW,"-",2)      ;* Sub message type
*
    IF NOT(INDEX(VALID.SIC.MESSAGES,MESSAGE.TYPE,1)) THEN
        EB.SystemTables.setE("DE.DEFS.INVALID.MESSAGE.CODE")
        EB.ErrorProcessing.Err()
        V$ERROR = 1
        RETURN
    END
*
    MAT MAIN.REC = ""         ;* Main record eg A10
    IF SUB.TYPE THEN
        YENRI = ""
        ER = ''
        R.REC = DE.Config.Message.Read(SUB.TYPE, ER)
        LNGG.POS = EB.SystemTables.getLngg()
        EB.SystemTables.setEtext(ER)
        YENRI = R.REC<DE.Config.Message.MsgDescription,LNGG.POS>
        IF NOT(YENRI) THEN
            YENRI = R.REC<DE.Config.Message.MsgDescription,1>
        END
        IF EB.SystemTables.getEtext() THEN
            EB.SystemTables.setE("DE.DEFS.INVALID.SUB.TYPE")
            EB.ErrorProcessing.Err() ; V$ERROR = 1
            RETURN
        END ELSE
            EB.SystemTables.setIdEnri(MESSAGE.TYPE:" ":YENRI)
        END
*
        ER = ''
        R.MAIN.REC = DE.Clearing.FormatSic.Read(MESSAGE.TYPE, ER)
        MATPARSE MAIN.REC FROM R.MAIN.REC
        IF ER THEN
            EB.SystemTables.setE("DE.DEFS.MAIN.MESSAGE.NOT.SET.UP":@FM:MESSAGE.TYPE)
            EB.ErrorProcessing.Err()
            V$ERROR = 1
        END
    END ELSE
        tmp.ID.NEW = EB.SystemTables.getIdNew()
        IF LEN(tmp.ID.NEW) NE 3 THEN
            EB.SystemTables.setE("DE.DEFS.X99.OR.X99999.FORMAT")
            V$ERROR = 1 ; EB.ErrorProcessing.Err()
        END
    END

*
RETURN

*************************************************************************

CHECK.RECORD:
*
* If a Sub product has been entered then take the main record and copy
* into R.NEW. Set the base.message type to the sub product so that the
* data can be extracted from the correct message
*
    IF SUB.TYPE THEN
        EB.SystemTables.setRNew(DE.Clearing.FormatSic.SicfBaseMessage, SUB.TYPE)
    END
*
* If the base message is present get the list of field names
*
    IF EB.SystemTables.getRNew(DE.Clearing.FormatSic.SicfBaseMessage) THEN
        BASE.MESSAGE = EB.SystemTables.getRNew(DE.Clearing.FormatSic.SicfBaseMessage)
        REC.ID = EB.SystemTables.getRNew(DE.Clearing.FormatSic.SicfBaseMessage)
        ER = ''
        R.REC = DE.Config.Message.Read(REC.ID, ER)
        MESSAGE.FIELDS = R.REC<DE.Config.Message.MsgFieldName>
        NO.FIELD.DEFS = COUNT(EB.SystemTables.getRNew(DE.Clearing.FormatSic.SicfFieldLoc),@VM) + (EB.SystemTables.getRNew(DE.Clearing.FormatSic.SicfFieldLoc) NE "")
        COMI.SAVE = EB.SystemTables.getComi()
        FOR YAV = 1 TO NO.FIELD.DEFS    ;* Enrich the field locations
            YAF = DE.Clearing.FormatSic.SicfFieldLoc:".":YAV
            EB.SystemTables.setComi(EB.SystemTables.getRNew(DE.Clearing.FormatSic.SicfFieldLoc)<1,YAV>)
            GOSUB LOAD.ENRICHMENT
        NEXT YAV
        EB.SystemTables.setComi(COMI.SAVE)
    END


RETURN

*************************************************************************

CHECK.FIELDS:

    BEGIN CASE
        CASE EB.SystemTables.getAf() = DE.Clearing.FormatSic.SicfBaseMessage
*
            IF EB.SystemTables.getComi() THEN
                IF SUB.TYPE AND EB.SystemTables.getComi() NE SUB.TYPE THEN
                    EB.SystemTables.setE("DE.DEFS.CANT.CHANGE.TYPE.SUB.TYPE")
                END ELSE
                    MESSAGE.FIELDS = ""
                    BASE.MESSAGE = EB.SystemTables.getComi()
                    ER = ''
                    R.REC = DE.Config.Message.Read(BASE.MESSAGE, ER)
                    MESSAGE.FIELDS = R.REC<DE.Config.Message.MsgFieldName>
                END
            END
*
        CASE EB.SystemTables.getAf() = DE.Clearing.FormatSic.SicfSicField
*
            IF EB.SystemTables.getComi() THEN
                GOSUB CHECK.FIELD.SIC.FIELD ;* BG_100013037 - S / E
            END ELSE
                EB.SystemTables.setE("DE.DEFS.FLD.NO.INP")
            END

*
        CASE EB.SystemTables.getAf() = DE.Clearing.FormatSic.SicfFieldLoc         ;* Any multi sub value
*

            GOSUB CHECK.FIELD.FIELD.LOC     ;* BG_100013037 - S / E

*
* Get the enrichment if no error
*
            IF EB.SystemTables.getE() = "" THEN
                YAF = EB.SystemTables.getAf():".":EB.SystemTables.getAv():".1"
                GOSUB LOAD.ENRICHMENT
            END
*
    END CASE
*
    IF EB.SystemTables.getE() THEN
        EB.SystemTables.setTSequ("IFLD")
        EB.ErrorProcessing.Err()
    END

RETURN

*************************************************************************

CROSS.VALIDATION:

*
* For "SWIFT" conversion the field must be defined as numeric. The A or S
* will be appended to the field depending on the address used.
*
    EB.SystemTables.setAf(DE.Clearing.FormatSic.SicfConversion)
    NO.VALS = COUNT(EB.SystemTables.getRNew(DE.Clearing.FormatSic.SicfConversion),@VM) + (EB.SystemTables.getRNew(DE.Clearing.FormatSic.SicfConversion) NE "")
    FOR AV.CNT = 1 TO NO.VALS
        EB.SystemTables.setAv(AV.CNT)
        BEGIN CASE
            CASE EB.SystemTables.getRNew(DE.Clearing.FormatSic.SicfConversion)<1,AV.CNT>[1,5] = "SWIFT"
                IF EB.SystemTables.getRNew(DE.Clearing.FormatSic.SicfSicField)<1,AV.CNT> MATCHES "2N1A" THEN
                    EB.SystemTables.setEtext("DE.DEFS.SIC.FLD.NUMERIC.SWIFT")
                    EB.ErrorProcessing.StoreEndError()
                END
            CASE 1
        END CASE
    NEXT AV.CNT

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


RETURN

*************************************************************************

AFTER.UNAU.WRITE:


RETURN

*************************************************************************

AFTER.AUTH.WRITE:


RETURN

*************************************************************************

BEFORE.AUTH.WRITE:


RETURN

*************************************************************************

CHECK.FUNCTION:

* Validation of function entered.  Set FUNCTION to null if in error.

    tmp.V$FUNCTION = EB.SystemTables.getVFunction()
    IF INDEX('V',tmp.V$FUNCTION,1) THEN
        EB.SystemTables.setE('DE.DEFS.FUNT.NOT.ALLOWED.APP')
        EB.ErrorProcessing.Err()
        EB.SystemTables.setVFunction('')
    END

* Check if FT product is installed
    isFtInstalled = ''
    EB.API.ProductIsInCompany("FT", isFtInstalled)

* Block the application if FT is not installed
    IF NOT(isFtInstalled) THEN
        EB.SystemTables.setE("EB-PRODUCT.NOT.INSTALLED":@FM:"FT")
        EB.ErrorProcessing.Err()
        RETURN
    END
    
RETURN

*************************************************************************

INITIALISE:

    DIM MAIN.REC(DE.Clearing.FormatSic.SicfAuditDateTime)
    VALID.SIC.MESSAGES = "A10_A11_B10_B11_C10_C11_C15_H70_H71"
*
    VALID.SIC.FIELDS = "02_03_04_05_11_12_13_16_17A_17C_17D_18_19_31A_32A_32C_32S_32S_33_33A_"
    VALID.SIC.FIELDS := "35A_36A_36S_41_41A_41B_41C_42_42A_42S_45A_45B_46A_46B"
    VALID.SIC.FIELDS := "45C_45D_49D_42C_46C_51C_51D_49A_51A_52_53_58_59_83_86_90_92A_92C_98"
    MESSAGE.FIELDS = ""       ;* Store of message field names
    BASE.MESSAGE = ""         ;* Base message

RETURN

************************************************************************
LOAD.ENRICHMENT:
*
* Loads the enrichment of the field
*
    COMI.VAL = EB.SystemTables.getComi()
    IF COMI.VAL THEN
        EB.SystemTables.setComiEnri(MESSAGE.FIELDS<1,FIELD(COMI.VAL,".",1)>)
        LOCATE YAF IN EB.SystemTables.getTFieldno()<1> SETTING ENRI.POS THEN
            T.ENRI.VAL<ENRI.POS> = EB.SystemTables.getComiEnri()
            EB.SystemTables.setTEnri(T.ENRI.VAL)
        END ELSE
            NULL    ;* BG_100013037 - S
        END         ;*  BG_100013037 - E
    END
*
RETURN
*************************************************************************

DEFINE.PARAMETERS:

* SEE 'I_RULES' FOR DESCRIPTIONS *;* BG_100013037 - S / E


    EB.SystemTables.clearF() ; EB.SystemTables.clearN() ; EB.SystemTables.clearT()
    EB.SystemTables.clearCheckfile() ; EB.SystemTables.clearConcatfile()
    EB.SystemTables.setIdCheckfile(""); EB.SystemTables.setIdConcatfile("")

    EB.SystemTables.setIdF("SIC.MESSAGE"); EB.SystemTables.setIdN("8.3.C"); EB.SystemTables.setIdT("A")
    EB.SystemTables.setF(1, "XX.LL.DESCRIPTION"); EB.SystemTables.setN(1, "25.3"); EB.SystemTables.setT(1, "A")
    EB.SystemTables.setF(2, "BASE.MESSAGE"); EB.SystemTables.setN(2, "4.1.C"); EB.SystemTables.setT(2, "")
    EB.SystemTables.setF(3, "XX<SIC.FIELD"); EB.SystemTables.setN(3, "3.2.C"); EB.SystemTables.setT(3, "A")
    EB.SystemTables.setF(4, "XX-MANDATORY"); EB.SystemTables.setN(4, "2.1"); EB.SystemTables.setT(4, ""); tmp=EB.SystemTables.getT(4); tmp<2>="Y_NO"; EB.SystemTables.setT(4, tmp)
    EB.SystemTables.setF(5, "XX-CONVERSION"); EB.SystemTables.setN(5, "13"); tmp=EB.SystemTables.getT(5); tmp<2>="DATE_AMOUNT_MULTI_SWIFT_PTT_ADDRESS_VESR_SWIFT*SHORT_PTT*SHORT_ADDRESS*SHORT"; EB.SystemTables.setT(5, tmp)
    EB.SystemTables.setF(6, "XX>FIELD.LOC"); EB.SystemTables.setN(6, "18..C"); EB.SystemTables.setT(6, "A")
*
    EB.SystemTables.setCheckfile(2, "DE.MESSAGE":@FM:DE.Config.Message.MsgDescription:@FM:"L")

    EB.SystemTables.setV(15)

RETURN

*************************************************************************
* BG_100013037 - S
*===========================
CHECK.FIELD.SIC.FIELD:
*===========================
    tmp.COMI = EB.SystemTables.getComi()
    IF NOT(INDEX(VALID.SIC.FIELDS,tmp.COMI,1)) THEN
        EB.SystemTables.setE("DE.DEFS.INVALID.SIC.FLD")
    END ELSE
        IF SUB.TYPE THEN
            LOCATE EB.SystemTables.getComi() IN MAIN.REC(DE.Clearing.FormatSic.SicfSicField)<1,1> SETTING X ELSE
                EB.SystemTables.setE("DE.DEFS.NOT.DEFINED.MESSAGE":@FM:MESSAGE.TYPE)
            END
        END
    END
RETURN
**************************************************************************************************************
*=====================
CHECK.FIELD.FIELD.LOC:
*=====================
    COMI.VAL = EB.SystemTables.getComi()
    BEGIN CASE
        CASE MESSAGE.FIELDS = ""
            EB.SystemTables.setE("DE.DEFS.BASE.MESSAGE.NOT.SET.UP")
        CASE COMI.VAL = ""
            IF SUB.TYPE AND EB.SystemTables.getRNew(DE.Clearing.FormatSic.SicfSicField)<1,EB.SystemTables.getAv()> MATCHES "02":@VM:"18":@VM:"83" THEN
                NULL
            END ELSE
                EB.SystemTables.setE("DE.DEFS.LOCATION.INP")
            END
        CASE COMI.VAL MATCHES "1N0N"
            NULL        ;* Single field input
        CASE COMI.VAL MATCHES "1N0N'.'1N0N"
            NULL        ;* Multi values
        CASE COMI.VAL MATCHES "1N0N'.'1N0N'.'1N0N"
            NULL        ;* Sub value
        CASE COMI.VAL MATCHES "1X0X"
*
* Input of the field name is allowed - this will be converted to the
* position in the message record
*
            CHK.COMI = COMI.VAL
            LOCATE CHK.COMI IN MESSAGE.FIELDS<1,1> SETTING CHK.POS THEN
                EB.SystemTables.setComi(CHK.POS);* Return only the field position multi and sub values must be input
            END ELSE
                EB.SystemTables.setE("DE.DEFS.NOT.DEFINED.DE.MESSAGE":@FM:BASE.MESSAGE)
            END
        CASE 1          ;* Invalid format
            EB.SystemTables.setE("DE.DEFS.INVALID.INP")
    END CASE
RETURN          ;* BG_100013037 - E
**************************************************************************************************************
END
