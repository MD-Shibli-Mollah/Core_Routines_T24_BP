* @ValidationCode : MjotODcyODE5NjA3OkNwMTI1MjoxNTk1MzQ5ODY5MzgyOmhhcnNoYXNhaXA6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNi4yMDIwMDUyNy0wNDM1OjExMzE6MjEz
* @ValidationInfo : Timestamp         : 21 Jul 2020 22:14:29
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harshasaip
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 213/1131 (18.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


* Version 45 16/03/01  GLOBUS Release No. G11.2.00 28/03/01
*-----------------------------------------------------------------------------
* <Rating>35808</Rating>
*-----------------------------------------------------------------------------
$PACKAGE DE.Config
SUBROUTINE DE.FORMAT.PRINT
*
* DE.FORMAT.PRINT - Contains the formatting instructions for printing
* messages, i.e. which fields are to be printed where and whether any
* special processing is to be done
*
* 05/03/93 - GB9300322/GB920142
*            Add a new CONVERSION to allow data to extracted from another
*            file if the files are resident according to DE.PARM.
*
* 18/05/93 - GB9300894
*            Allow FD as a valid application in the application format
*
* 13/07/92 - GB9300902
*            Allow conversion CCY*ccy field to format amounts correctly
*            Allow masking to be Right or Left justified
*
    !
    !  10/11/94  -  GB9401245
    !   Include Syndicated Loans as a valid application.
    !
* 23/02/95 - GB9500306
*            Conversion of input statements to calls to TXTINP to allow
*            GUI compatibility with user interaction requests
*
* 20/03/95 - GB9500381
*            Allow a new CONVERSION option of WORDSCCY*xxx, which will
*            translate an amount into words according to the language,
*            and also give the correct currency description
*
* 30/4/97 - GB9700533
*           Change field length of CONVERSION from 31 to 45 characters.
*
* 21/10/97 - GB9701217
*            Calling SOTRE.END.ERROR instead of STORE.END.ERROR, if
*            dependent on and dependent condition are both present, but
*            dependent condition is not.
*
* 12/02/98 - GB9800125 & GB9801181
*            Add new FIXnnn conversions for the Euro
*
* 03/04/00 - GB0000680
*            Allow entry of customer-created CONVERSION routines, of type
*            @ROUTINE where ROUTINE must exist as a type 'S' PGM.FILE
*            record.
*
* 13/09/01 -BG_100000061
*            CO.CODE is missing from the REPORT.CONTROL record created
*
* 01/06/01 - GLOBUS_EN_10000101
*            Add CQ as a valid application
*
* 29/11/01 - CI-10000502
*            Problem with transferring REPORT.CONTROL records with
*            DL.DEFINE
*
* 20/02/02 - GLOBUS_EN_10000352
*            Add BL as a valid application
*
* 24/09/02 - GLOBUS_EN_10001221
*          Conversion Of all Error Messages to Error Codes
*
* 26/09/02 - GLOBUS_EN_10001244
*            To handle the USER defined fields in Message and Mapping.
*            When validating field name, extra validation is made to check
*            whether the field exists in the User fields on the
*            message record and get the corresponding data.
*
* 08/07/2003 - CI_10010568
*        When the input to the field PRT.MASK is 0.00 , the system
*              picks it up as a numeric value and the if condition fails. Hence
*              the system fails to do the mask validation
*
* 17/03/04 - EN_10002211
*            Creating new Report control rec is in after aut write para.
*            This part is moved before calling AUTH.RECORD.WRITE so that
*            Journal Update can be removed from WRITE.RC para.
*
* 30/11/05 - BG_100009761
*            When we Authorise the DE.FORMAT.PRINT record it gives a misleading
*            Override(DO YOU WANT A SAMPLE LAYOUT (Y/NO))in Browser.
*
* 16/01/06 - EN_10002771
*            Date display format for japanese market. Changes required to DE.FORMAT.PRINT.
*
*
* 22/09/15 - Enhancement 1265068/Task 1448651
*          - Routine incorporated
*
* 22/12/16 - Defect-1921923/ Task-1963638
*            Get correctly the enrichment for the id(warning Var LNGG uninitialised)
*
* 12/01/18 - Defect 2413893/ Task 2414089
*            DE.FORMAT.PRINT not allowing to define Alpha Numeric MESSAGE.TYPE as part of id
*
* 18/03/20 - Defect 3613636 / Task 3644661
*            Length of id is increased to 35
*
* 07/07/20 -  Enhancement 3793141 / Task 3843696
*             To enable the L3 Hook implementation for the CONVERSION field in the DE.FORMAT.PRINT.
*             changes are made to validation for the customised conversion subroutine to accept a valid entry of EB.API of source type METHOD
***********************************************************************
    !
    !
*
REM "DE.FORMAT.PRINT",840822-001,"MAINPGM"
    $USING DE.Config
    $USING EB.SystemTables
    $USING DE.Reports
    $USING EB.Reports
    $USING EB.Interface
    $USING EB.Display
    $USING EB.TransactionControl
    $USING EB.ErrorProcessing
    $USING DE.API
    $USING EB.Desktop
    $USING EB.API

*************************************************************************
REM "DEFINE PGM NAME (BY USING 'C/DE.FORMAT.PRINT/.../G9999')
*========================================================================
    DIM R.MSG(20), R.TYPE(30)
    EB.SystemTables.clearF() ; EB.SystemTables.clearN() ; EB.SystemTables.clearT() ; EB.SystemTables.setIdT("")
    EB.SystemTables.clearCheckfile() ; EB.SystemTables.clearConcatfile()
    EB.SystemTables.setIdCheckfile(""); EB.SystemTables.setIdConcatfile("")
*========================================================================
REM "DEFINE PARAMETERS - SEE 'I_RULES'-DESCRIPTION:
*
    
    EB.SystemTables.setIdF('ID')
    EB.SystemTables.setIdN('35.7')
    tmp=EB.SystemTables.getIdT(); tmp< 1 >='A'; EB.SystemTables.setIdT(tmp)
    EB.SystemTables.setIdCheckfile('')
    EB.SystemTables.setIdConcatfile('AR')
*
    EB.SystemTables.setF(1, 'XX.LL.DESCRIPTION'); EB.SystemTables.setN(1, '35.3')
    EB.SystemTables.setF(2, 'FORM TYPE'); EB.SystemTables.setN(2, '7..C')
    EB.SystemTables.setF(3, 'XX<LINE(S)'); EB.SystemTables.setN(3, '7.1.C')
    EB.SystemTables.setF(4, 'XX-INDENT'); EB.SystemTables.setN(4, '3.1.C')
    EB.SystemTables.setF(5, 'XX-HEADING'); EB.SystemTables.setN(5, '1')
    EB.SystemTables.setF(6, 'XX-MULTI'); EB.SystemTables.setN(6, '1')
    EB.SystemTables.setF(7, 'XX-COMPLETE'); EB.SystemTables.setN(7, '2..C')
    EB.SystemTables.setF(8, 'XX-FIELD/"TEXT"'); EB.SystemTables.setN(8, ' 35.1.C')
    EB.SystemTables.setF(9, 'XX-CONVERSION'); EB.SystemTables.setN(9, '45..C')
    EB.SystemTables.setF(10, 'XX-MASK'); EB.SystemTables.setN(10, '25..C')
    EB.SystemTables.setF(11, 'XX-CALCULATION'); EB.SystemTables.setN(11, '9..C')
    EB.SystemTables.setF(12, 'XX-DEPENDENT ON'); EB.SystemTables.setN(12, '19..C')
    EB.SystemTables.setF(13, 'XX-DEPEND.OPERAND'); EB.SystemTables.setN(13, '2..C')
    EB.SystemTables.setF(14, 'XX-DEPEND.COND.'); EB.SystemTables.setN(14, '30..C')
    EB.SystemTables.setF(15, 'XX>PAGE OVERFLOW'); EB.SystemTables.setN(15, '2..C')
*
    EB.SystemTables.setV(24);* number of fields
*
*
    tmp=EB.SystemTables.getT(1); tmp< 1 >='A'; EB.SystemTables.setT(1, tmp)
    tmp=EB.SystemTables.getT(2); tmp< 1 >='A'; EB.SystemTables.setT(2, tmp)
    tmp=EB.SystemTables.getT(3); tmp< 1 >='A'; EB.SystemTables.setT(3, tmp)
    tmp=EB.SystemTables.getT(4); tmp< 1 >='A'; EB.SystemTables.setT(4, tmp)
    tmp=EB.SystemTables.getT(5); tmp< 1 >=''; EB.SystemTables.setT(5, tmp); tmp=EB.SystemTables.getT(5); tmp< 2 >='S_B'; EB.SystemTables.setT(5, tmp)
    tmp=EB.SystemTables.getT(6); tmp< 1 >=''; EB.SystemTables.setT(6, tmp); tmp=EB.SystemTables.getT(6); tmp< 2 >='M_S'; EB.SystemTables.setT(6, tmp)
    tmp=EB.SystemTables.getT(7); tmp< 1 >=''; EB.SystemTables.setT(7, tmp); tmp=EB.SystemTables.getT(7); tmp< 2 >='Y_NO'; EB.SystemTables.setT(7, tmp)
    tmp=EB.SystemTables.getT(8); tmp< 1 >='A';  EB.SystemTables.setT(8, tmp)
    EB.SystemTables.setT(9,"HOOKOTHER") ;tmp=EB.SystemTables.getT(9); tmp<6,1> = "DE.FORMAT.PRINT.CONVERSION.HOOK" ; tmp<6,2> = "ANY" ; tmp<6,3>="YES" ;EB.SystemTables.setT(9, tmp)
    tmp=EB.SystemTables.getT(10); tmp< 1 >='A'; EB.SystemTables.setT(10, tmp)
    tmp=EB.SystemTables.getT(11); tmp< 1 >='A'; EB.SystemTables.setT(11, tmp)
    tmp=EB.SystemTables.getT(12); tmp< 1 >='A'; EB.SystemTables.setT(12, tmp)
    tmp=EB.SystemTables.getT(13); tmp< 1 >=''; EB.SystemTables.setT(13, tmp); tmp=EB.SystemTables.getT(13); tmp< 2 >='EQ_NE_GT_GE_LT_LE'; EB.SystemTables.setT(13, tmp)
    tmp=EB.SystemTables.getT(14); tmp< 1 >='A'; EB.SystemTables.setT(14, tmp)
    tmp=EB.SystemTables.getT(15); tmp< 1 >=''; EB.SystemTables.setT(15, tmp); tmp=EB.SystemTables.getT(15); tmp< 2 >='Y_NO'; EB.SystemTables.setT(15, tmp)
*
    EB.SystemTables.setCheckfile(2, "DE.FORM.TYPE" : @FM : DE.Reports.FormType.TypDescription : @FM : 'L.A')
*
*========================================================================
    V$FUNCTION.VAL = EB.SystemTables.getVFunction()
    IF LEN(V$FUNCTION.VAL) > 1 THEN RETURN
*     RETURN when pgm used to get parameters only
*------------------------------------------------------------------------
    EB.Display.MatrixUpdate()
*
* Open files
*
    R.PARM = ""
    R.PARM = DE.Config.Parm.CacheRead("SYSTEM.STATUS", "")
*
* Setup valid conversion codes, mask characters and key words
*
    CONV = ''
    CONV < 1 > = 'DATE'
    CONV < 2 > = 'DATE/F'
    CONV < 3 > = 'DATE/S'
    CONV < 4 > = 'DATE//US'
    CONV < 5 > = 'DATE/F/US'
    CONV < 6 > = 'DATE/S/US'
    CONV < 7 > = 'COPY'
    CONV < 8 > = 'WORDS'
    CONV < 9 > = 'DUP'
    CONV < 10 > = 'DUPLICATE'
    CONV < 11 > = 'DATE/U'    ;* EN_10002771 S/E
*
    MASK.CHARS = ''
    MASK.CHARS < 1 > = '%'
    MASK.CHARS < 2 > = '*'
    MASK.CHARS < 3 > = 'C'
    MASK.CHARS < 4 > = 'D'
    MASK.CHARS < 5 > = '-'
    MASK.CHARS < 6 > = ','
    MASK.CHARS < 7 > = '.'
    MASK.CHARS < 8 > = 'B'
    MASK.CHARS < 9 > = 'Z'
    MASK.CHARS < 10 > = 'A'
*
    KEY.WORDS = ''
    KEY.WORDS < 1 > = 'DATE'
    KEY.WORDS < 2 > = 'PAGE.NO'
    KEY.WORDS < 3 > = 'TIME'
    KEY.WORDS < 4 > = 'TO.ADDRESS'
    KEY.WORDS < 5 > = 'DELIVERY.REF'
*
    CUS.KEYWORDS = ''
    CUS.KEYWORDS < 1 > = 'FULL'
    CUS.KEYWORDS < 2 > = 'SHORT.NAME'
    CUS.KEYWORDS < 3 > = 'NAME.1'
    CUS.KEYWORDS < 4 > = 'NAME.2'
    CUS.KEYWORDS < 5 > = 'STREET.ADDRESS'
    CUS.KEYWORDS < 6 > = 'TOWN.COUNTY'
    CUS.KEYWORDS < 7 > = 'POST.CODE'
    CUS.KEYWORDS < 8 > = 'COUNTRY'
*-----------------------------------------------------------------------
ID.INPUT:
    EB.TransactionControl.RecordidInput()
    IF EB.SystemTables.getMessage() = "RET" THEN RETURN
*     return to PGM.SELECTION
    IF EB.SystemTables.getMessage() = "NEW FUNCTION" THEN
*=======================================================================
REM "CHECK FUNCTION:
        IF EB.SystemTables.getVFunction() = "V" THEN
            EB.SystemTables.setE("DE.DFP.INVALID.FUNT.PGM")
ID.ERROR:
            EB.ErrorProcessing.Err() ; GOTO ID.INPUT
        END
*========================================================================
        IF EB.SystemTables.getVFunction() = "E" OR EB.SystemTables.getVFunction() = "L" THEN
            EB.Display.FunctionDisplay() ; EB.SystemTables.setVFunction("")
        END
        GOTO ID.INPUT
    END
*========================================================================
REM "CHECK ID OR CHANGE STANDARD ID:
*========================================================================
*
* VALIDATE KEY
*
* Must be message-type.application-format.format.language
*
    COMI.VAL = EB.SystemTables.getComi()
    DOT1 = INDEX(COMI.VAL, '.' , 1)
    DOT2 = INDEX(COMI.VAL, '.' , 2)
    DOT3 = INDEX(COMI.VAL, '.' , 3)
*
    IF DOT1 = 0 OR DOT2 = 0 OR DOT3 = 0 THEN
        EB.SystemTables.setE('DE.DFP.ENT.MSGTYPE.APPFORMAT.FORMAT.LANGUAGE')
        GOTO ID.ERROR
    END
*
* Message type, application.format, format and lanuage must all be
* entered
*
    MSG.TYPE = EB.SystemTables.getComi()[1, DOT1 - 1]
    APP.FORMAT = EB.SystemTables.getComi()[DOT1 + 1, DOT2 - DOT1 - 1]
    FORMAT = EB.SystemTables.getComi()[DOT2 + 1, DOT3 - DOT2 - 1]
    LANG = EB.SystemTables.getComi()[DOT3 + 1, 99]
*
    IF MSG.TYPE = '' OR APP.FORMAT = '' OR FORMAT = '' OR LANG = '' THEN
        EB.SystemTables.setE('DE.DFP.ENT.MSGTYPE.APPFORMAT.FORMAT.LANGUAGE')
        GOTO ID.ERROR
    END
    
*Get the length of DE.MESSAGE

    OBJECT.ID="DE.MESSAGE" ; MAX.LEN=""

    EB.API.GetObjectLength(OBJECT.ID,MAX.LEN)

* If the value of MAX.LEN is null then it is default set to 10
    IF MAX.LEN = "" THEN
        MAX.LEN = 10
    END

* Message type must not be more than MAX.LEN
*
    IF LEN(MSG.TYPE) > MAX.LEN THEN
        EB.SystemTables.setE("DE.DFP.MESSAGE.TYPE.LENGTH.INCORRECT")
        GOTO ID.ERROR
    END
*
* If application format code is not numeric, first two characters must be
* application code and then the rest must be numeric
*
    IF NOT(NUM(APP.FORMAT)) THEN
        IF APP.FORMAT[1, 2] MATCHES "FX" : @VM : "FT" : @VM : "MM" : @VM : "BD" : @VM : "LD" : @VM : "AC" : @VM : "EF" : @VM : 'LC' : @VM : 'SC' : @VM : 'DC' : @VM : 'FR' : @VM : 'FD' : @VM : 'MD' : @VM : "SL" : @VM : "CQ" : @VM : "BL" THEN          ;* EN_10000101 ; EN_10000352
            IF NOT(NUM(APP.FORMAT[3, 4])) THEN
                EB.SystemTables.setE('DE.DFP.INVALID.APP.FORMAT')
                GOTO ID.ERROR
            END
        END ELSE
            EB.SystemTables.setE('DE.DFP.INVALID.APP.FORMAT')
            GOTO ID.ERROR
        END
    END ELSE
*
* Application format code must not be longer than 4 characters if all
* numeric
*
        IF LEN(APP.FORMAT) > 4 THEN
            EB.SystemTables.setE("DE.DFP.APP.FORMAT.CODE.LENGTH.INCORRECT")
            GOTO ID.ERROR
        END
    END
*
* Format code must be numeric
*
    IF NOT(NUM(FORMAT)) THEN
        EB.SystemTables.setE("DE.DFP.FORMAT.CODE.NUMERIC")
        GOTO ID.ERROR
    END
*
* Format code must not be longer than 4 characters
*
    IF LEN(FORMAT) > 4 THEN
        EB.SystemTables.setE("DE.DFP.FORMAT.CODE.LENGTH.INCORRECT")
        GOTO ID.ERROR
    END
*
* Language code must be alpha
*
    IF NUM(LANG) THEN
        EB.SystemTables.setE("DE.DFP.LANGUAGE.CODE.ALPHA")
        GOTO ID.ERROR
    END
*
* Check message type exists on message file
*
    ENRIX = '' ; ENRIMSG = ''
    ER = ''
    R.REC = ''
    R.REC = DE.Config.Message.Read(MSG.TYPE, ER)
    LNGG.POS = EB.SystemTables.getLngg()
    ENRIMSG = R.REC<DE.Config.Message.MsgDescription,LNGG.POS>
    IF NOT(ENRIMSG) THEN
        ENRIMSG = R.REC<DE.Config.Message.MsgDescription,1>
    END
    EB.SystemTables.setEtext(ER)
    IF EB.SystemTables.getEtext()<> '' THEN
        EB.SystemTables.setE(EB.SystemTables.getEtext())
        GOTO ID.ERROR
    END
*
* Get message record from message file
*
    MAT R.MSG = ''
    ER = ''
    R.REC = ''
    R.REC = DE.Config.Message.Read(MSG.TYPE, ER)
    MATPARSE R.MSG FROM R.REC
*
* Check language code exists on language file
*

    LOCATE LANG IN EB.SystemTables.getTLanguage()< 1 > SETTING IND
    ELSE EB.SystemTables.setE('DE.DFP.INVALID.LANGUAGE.CODE'); GOTO ID.ERROR
    R.REC = ''
    ER = ''
    R.REC = EB.SystemTables.Language.Read(IND, ER)
    LNGG.POS = EB.SystemTables.getLngg()
    ENRIX = R.REC<EB.SystemTables.Language.LanDescription,LNGG.POS>
    IF NOT(ENRIX) THEN
        ENRIX = R.REC<EB.SystemTables.Language.LanDescription,1>
    END
    EB.SystemTables.setIdEnri(ENRIMSG)
    V$KEY = MSG.TYPE : '.' : APP.FORMAT : '.' : FORMAT : '.' : LANG
    EB.SystemTables.setIdNew(V$KEY)
    EB.SystemTables.setComi(V$KEY)
    EB.TransactionControl.RecordRead()
    IF EB.SystemTables.getMessage() = "REPEAT" THEN GOTO ID.INPUT
    EB.Display.MatrixAlter()
*========================================================================
REM "SPECIAL CHECKS OR CHANGE FIELDS AFTER READING RECORD(S):
*========================================================================
FIELD.DISPLAY.OR.INPUT:
    BEGIN CASE
        CASE EB.SystemTables.getScreenMode() = "MULTI"
            IF EB.SystemTables.getFileType() = "I" THEN
                EB.Display.FieldMultiInput()
            END ELSE
                EB.Display.FieldMultiDisplay()
            END
        CASE EB.SystemTables.getFileType() = "I" ; EB.Display.FieldInput()
        CASE 1 ; EB.Display.FieldDisplay()
    END CASE
*------------------------------------------------------------------------
HANDLE.MESSAGE:
    BEGIN CASE
        CASE EB.SystemTables.getMessage() = "REPEAT" ; NULL
        CASE EB.SystemTables.getMessage() = "VAL"
            EB.SystemTables.setMessage("")
            IF EB.SystemTables.getVFunction() = "D" OR EB.SystemTables.getVFunction() = "R" THEN
*========================================================================
REM "HANDLING REVERSAL:
*========================================================================
                NULL
            END ELSE
*========================================================================
REM "HANDLING 'VAL'-CHECKS:
*
* Get form type record
*
                EB.SystemTables.setAf(DE.Config.FormatPrint.PrtFormType)
                IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFormType) THEN
                    R.REC = ''
                    ER = ''
                    FORM.ID = EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFormType)
                    R.REC = DE.Reports.FormType.Read(FORM.ID, ER)
                    MATPARSE R.TYPE FROM R.REC
                    IF ER THEN
                        MAT R.TYPE = ''
                        R.TYPE(DE.Reports.FormType.TypDescription) = ''
                        EB.SystemTables.setEtext('DE.DFP.FORM.TYPE.NOT.ON.FILE')
                        EB.ErrorProcessing.StoreEndError()
                    END
                END ELSE
                    R.REC = ''
                    ER = ''
                    FORM.ID = 'DEFAULT'
                    R.REC = DE.Reports.FormType.Read(FORM.ID, ER)
                    MATPARSE R.TYPE FROM R.REC
                    IF ER THEN
                        MAT R.TYPE = ''
                        R.TYPE(DE.Reports.FormType.TypDescription) = ''
                        EB.SystemTables.setEtext('DE.DFP.DEFAULT.FORM.TYPE.NOT.ON.FILE')
                        EB.ErrorProcessing.StoreEndError()
                    END
                END
*
                IF R.TYPE(DE.Reports.FormType.TypDescription) THEN
                    MAX.VALUES = COUNT(EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtLine), @VM) + 1
                    PREVIOUS.START.LINE = 1
                    PREVIOUS.END.LINE = ''
                    FOR AV1 = 1 TO MAX.VALUES
                        EB.SystemTables.setAv(AV1)
* Start line and end line (if entered) must not be greater than maximum
* line number from form type
*
                        EB.SystemTables.setAf(DE.Config.FormatPrint.PrtLine)
                        START.LINE = FIELD(EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtLine)< 1, AV1 > , '-' , 1)
                        END.LINE = FIELD(EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtLine)< 1, AV1 > , '-' , 2)
                        IF START.LINE[1, 1] <> '+' THEN
                            IF START.LINE > R.TYPE(DE.Reports.FormType.TypFormDepth) THEN
                                EB.SystemTables.setEtext('DE.DFP.LINE.NO.NOT.G': @FM : R.TYPE(DE.Reports.FormType.TypFormDepth))
                                EB.ErrorProcessing.StoreEndError()
                            END
                        END
                        IF END.LINE[1, 1] <> '+' THEN
                            IF END.LINE THEN
                                IF END.LINE > R.TYPE(DE.Reports.FormType.TypFormDepth) THEN
                                    EB.SystemTables.setEtext('DE.DFP.LINE.NOT.G': @FM : R.TYPE(DE.Reports.FormType.TypFormDepth))
                                    EB.ErrorProcessing.StoreEndError()
                                END
                            END
                        END
*
* Start line must not be less than previous start line
*
                        IF EB.SystemTables.getAv() > 1 THEN
                            IF START.LINE[1, 1] <> '+' THEN
                                IF START.LINE < PREVIOUS.START.LINE THEN
                                    EB.SystemTables.setEtext('DE.DFP.LINES.NOT.SEQUENCE')
                                    EB.ErrorProcessing.StoreEndError()
                                END
                            END
                        END
*
* If current start line is '+00', then previous end line must be equal
* to current end line
*
                        IF START.LINE = '+00' THEN
                            IF PREVIOUS.END.LINE <> END.LINE THEN
                                EB.SystemTables.setEtext('DE.DFP.INVALID.MULTIPLE.LINES.COMBINATION')
                                EB.ErrorProcessing.StoreEndError()
                            END
                        END
                        IF START.LINE[1, 1] <> '+' THEN PREVIOUS.START.LINE = START.LINE
                        PREVIOUS.END.LINE = END.LINE
*
* Validate indentation - must not be greater than maximum width from form
* type
*
                        EB.SystemTables.setAf(DE.Config.FormatPrint.PrtIndent)
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtIndent)< 1, AV1 > > R.TYPE(DE.Reports.FormType.TypFormWidth) THEN
                            EB.SystemTables.setEtext('DE.DFP.MAX.INDENTATION.': @FM : R.TYPE(DE.Reports.FormType.TypFormWidth))
                            EB.ErrorProcessing.StoreEndError()
                        END
*
* If complete is "Y", multi must be "S"
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtComplete)< 1, AV1 > = 'Y' THEN
                            IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtMulti)< 1, AV1 > <> 'S' THEN
                                EB.SystemTables.setAf(DE.Config.FormatPrint.PrtComplete)
                                EB.SystemTables.setEtext('DE.DFP.MULTI.S')
                                EB.ErrorProcessing.StoreEndError()
                            END
                        END
*
* Check that conversion, masking and calculation are not entered if
* field is text or a printer attribute
*
                        QTS = COUNT(EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, AV1 > , '"' )
                        IF NOT(QTS) THEN QTS = INDEX(EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, AV1 > , "&" , 1)
                        IF QTS THEN
                            IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtConversion)< 1, AV1 > THEN
                                IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtConversion)< 1, AV1 > <> 'COPY' AND EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtConversion)< 1, AV1 > [1, 3] <> 'DUP' THEN
                                    EB.SystemTables.setAf(DE.Config.FormatPrint.PrtConversion)
                                    EB.SystemTables.setEtext('DE.DFP.CONVERSION.INVALID.TEXT')
                                    EB.ErrorProcessing.StoreEndError()
                                END
                            END
*
                            IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtMask)< 1, AV1 > THEN
                                EB.SystemTables.setAf(DE.Config.FormatPrint.PrtMask)
                                EB.SystemTables.setEtext('DE.DFP.MASKING.INVALID.TEXT')
                                EB.ErrorProcessing.StoreEndError()
                            END
*
                            IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtCalculation)< 1, AV1 > THEN
                                EB.SystemTables.setAf(DE.Config.FormatPrint.PrtCalculation)
                                EB.SystemTables.setEtext('DE.DFP.CALCULATION.INVALID.TEXT')
                                EB.ErrorProcessing.StoreEndError()
                            END
*
                        END ELSE
*
* If a field name has been entered, check that it exists on the message
* file
*
* EN_10001244 - S
****                        LOCATE R.NEW(DE.PRT.FIELD.TEXT) < 1, AV > IN R.MSG(DE.MSG.FIELD.NAME) < 1, 1 > SETTING IND ELSE
                            LOC.FIELD.NAME = EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, AV1 >
                            GOSUB LOCATE.FIELD.NAME
                            IF NOT(LOC.POS) THEN
* EN_10001244 -E
                                LOCATE EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, AV1 > IN KEY.WORDS < 1 > SETTING IND ELSE
                                    IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, AV1 > [1, 6] <> 'TOTAL.' THEN
*
* If entry was not a message field or a keyword or total check that it
* does not begin with &ATT defining a recognised printer attribute.
*
                                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, AV1 > [1, 4] <> "&ATT" THEN
                                            EB.SystemTables.setAf(DE.Config.FormatPrint.PrtFieldText)
                                            EB.SystemTables.setEtext('DE.DFP.FLD.NAME.OR.KEYWORD.MISS')
                                            EB.ErrorProcessing.StoreEndError()
                                        END
                                    END
                                END
                            END
*
* If conversion is 'WORDS', masking is invalid
*
                            IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtMask)< 1, AV1 > THEN
                                IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtConversion)< 1, AV1 > = 'WORDS' THEN
                                    EB.SystemTables.setAf(DE.Config.FormatPrint.PrtMask)
                                    EB.SystemTables.setEtext('DE.DFP.MASKING.INVALID.WITH.WORDS.CONV')
                                    EB.ErrorProcessing.StoreEndError()
                                END
* GB9500381 - start
*
* If conversion is 'WORDSCCY*xxx', masking is invalid
*
                                IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtConversion)< 1, AV1 >[1,8] = 'WORDSCCY' THEN
                                    EB.SystemTables.setAf(DE.Config.FormatPrint.PrtMask)
                                    EB.SystemTables.setEtext('DE.DFP.MASKING.INVALID.WITH.WORDSCCY*XXX.CONV')
                                    EB.ErrorProcessing.StoreEndError()
                                END
* GB9500381 - stop
                            END

*
* If field is TOTAL.n, conversion is not allowed
*
                            IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtConversion)< 1, AV1 > THEN
                                IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, AV1 > [1, 6] = 'TOTAL.' THEN
                                    IF NOT(EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtConversion)<1,AV1>[1,3] MATCHES "CCY":@VM:"FIX") THEN
                                        EB.SystemTables.setAf(DE.Config.FormatPrint.PrtConversion)
                                        EB.SystemTables.setEtext('DE.DFP.CONVERSION.NOT.ALLOWED.TOTAL.N')
                                        EB.ErrorProcessing.StoreEndError()
                                    END
                                END
                            END
*
* If mask is in the format 000/00/000, check that the number of spaces is
* equal to the field length from the message file
*
                            IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtMask)< 1, AV1 > THEN
                                MAX = COUNT(EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtMask)< 1, AV1 > , " " )
                                IF MAX = 0 THEN
                                    LOCATE EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtMask)< 1, AV1 > [1, 1] IN MASK.CHARS < 1 > SETTING IND ELSE
* EN_10001244 - S
****                              LOCATE R.NEW(DE.PRT.FIELD.TEXT) < 1, AV > IN R.MSG(DE.MSG.FIELD.NAME) < 1, 1 > SETTING IND ELSE IND = 0
                                        LOC.FIELD.NAME = EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, AV1 >
                                        GOSUB LOCATE.FIELD.NAME
                                        IF LOC.POS THEN
                                            FIELD.LENGTH = COUNT(EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtMask)< 1, AV1 > , "0" )
                                            IF FIELD.LENGTH <> R.MSG(LOC.MSG.LENGTH) < 1, LOC.POS > THEN
                                                EB.SystemTables.setAf(DE.Config.FormatPrint.PrtMask)
                                                EB.SystemTables.setEtext("DE.DFP.INVALID.MASK.LENGTH")
                                                EB.ErrorProcessing.StoreEndError()
                                            END
                                        END
                                    END
* EN_10001244 - E
                                END
                            END
                        END
*
* If calculation is entered, check that the field is numeric on the
* message file
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtCalculation)< 1, AV1 > THEN
* EN_10001244 - S
****                        LOCATE R.NEW(DE.PRT.FIELD.TEXT) < 1, AV > IN R.MSG(DE.MSG.FIELD.NAME) < 1, 1 > SETTING IND ELSE IND = 0
                            LOC.FIELD.NAME = EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, AV1 >
                            GOSUB LOCATE.FIELD.NAME
                            IF LOC.POS THEN
                                IF R.MSG(LOC.MSG.PRINT.TYPE) < 1, LOC.POS > <> 'N' THEN
                                    EB.SystemTables.setAf(DE.Config.FormatPrint.PrtCalculation)
                                    EB.SystemTables.setEtext('DE.DFP.FLD.NUMERIC')
                                    EB.ErrorProcessing.StoreEndError()
                                END
                            END
* EN_10001244 - E
                        END
*
* Zero only valid for total fields
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtCalculation)< 1, AV1 > = 'ZERO' THEN
                            IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, AV1 > [1, 6] <> 'TOTAL.' THEN
                                EB.SystemTables.setAf(DE.Config.FormatPrint.PrtCalculation)
                                EB.SystemTables.setEtext('DE.DFP.ZERO.ONLY.VALID.TOTAL.FIELDS')
                                EB.ErrorProcessing.StoreEndError()
                            END
                        END
*
* If conversion is 'WORDS', calculation must be blank
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtCalculation)< 1, AV1 > THEN
                            IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtConversion)< 1, AV1 > = 'WORDS' THEN
                                EB.SystemTables.setAf(DE.Config.FormatPrint.PrtCalculation)
                                EB.SystemTables.setEtext('DE.DFP.CALC.INVALID.WITH.WORDS.CONVERSION')
                                EB.ErrorProcessing.StoreEndError()
                            END
* GB9500381 - start
*
* If conversion is 'WORDSCCY*xxx', calculation is invalid
*
                            IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtConversion)< 1, AV1 >[1,8] = 'WORDSCCY' THEN
                                EB.SystemTables.setAf(DE.Config.FormatPrint.PrtCalculation)
                                EB.SystemTables.setEtext('DE.DFP.CALC.INVALID.WITH.WORDSCCY*XXX.CONVERSION')
                                EB.ErrorProcessing.StoreEndError()
                            END
* GB9500381 - stop
                        END
*
* If complete is blank, default to 'NO'
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtComplete)< 1, AV1 > = '' THEN tmp=EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtComplete); tmp< 1, AV1 >='NO'; EB.SystemTables.setRNew(DE.Config.FormatPrint.PrtComplete, tmp)
*
* If page overflow is blank, default to 'NO'
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtPage)< 1, AV1 > = '' THEN tmp=EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtPage); tmp< 1, AV1 >='NO'; EB.SystemTables.setRNew(DE.Config.FormatPrint.PrtPage, tmp)
*
* If dependent upon operand is specified, dependent upon field must be
* present
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtDepOp)< 1, AV1 > THEN
                            IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtDependentOn)< 1, AV1 > = '' THEN
                                EB.SystemTables.setAf(DE.Config.FormatPrint.PrtDepOp)
                                EB.SystemTables.setEtext('DE.DFP.DEPENDENT.ON.PRESENT')
                                EB.ErrorProcessing.StoreEndError()
                            END
                        END
*
* If dependent upon condition is specifed, dependent upon field and
* dependent upon operand must be present
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtDepCond)< 1, AV1 > THEN
                            IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtDependentOn)< 1, AV1 > = '' THEN
                                EB.SystemTables.setAf(DE.Config.FormatPrint.PrtDepCond)
                                EB.SystemTables.setEtext('DE.DFP.DEPENDENT.ON.PRESENT')
                                EB.ErrorProcessing.StoreEndError()
                            END ELSE
                                IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtDepOp)< 1, AV1 > = '' THEN
                                    EB.SystemTables.setAf(DE.Config.FormatPrint.PrtDepCond)
                                    EB.SystemTables.setEtext('DE.DFP.DEPENDENT.ON.OPERAND.PRESENT')
                                    EB.ErrorProcessing.StoreEndError()
                                END
                            END
                        END
*
* If dependent on has been entered, check that the field exists in
* field/text if dependent on begins "*", otherwise dependent on must
* exist on the message file or be 'TOTAL.n'
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtDependentOn)< 1, AV1 > THEN
                            IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtDependentOn)< 1, AV1 > MATCHES "'TOTAL.'1N" THEN NULL ELSE
                                IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtDependentOn)< 1, AV1 > [1, 1] = "*" THEN
                                    LOCATE EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtDependentOn)< 1, AV1 > [2, 99] IN EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, 1 > SETTING IND ELSE
                                        EB.SystemTables.setAf(DE.Config.FormatPrint.PrtDependentOn)
                                        EB.SystemTables.setEtext('DE.DFP.FLD.NAME.NOT.FORMAT')
                                        EB.ErrorProcessing.StoreEndError()
                                    END
                                END ELSE
* EN_10001244- S
*****                              LOCATE R.NEW(DE.PRT.DEPENDENT.ON) < 1, AV > IN R.MSG(DE.MSG.FIELD.NAME) < 1, 1 > SETTING IND ELSE
                                    LOC.FIELD.NAME = EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtDependentOn)< 1, AV1 >
                                    GOSUB LOCATE.FIELD.NAME
                                    IF NOT(LOC.POS) THEN
                                        EB.SystemTables.setAf(DE.Config.FormatPrint.PrtDependentOn)
                                        EB.SystemTables.setEtext('DE.DFP.FLD.NAME.NOT.ON.MESSAGE.FILE')
                                        EB.ErrorProcessing.StoreEndError()
                                    END
* EN_10001244 - E
                                END
                            END
                        END
*
                    NEXT AV1
                END
*========================================================================
REM "HANDLE AUTOM. CALCULATED FIELDS (BEGINNING WITH OVERRIDE):
*========================================================================
REM "HANDLING UPDATE SPECIAL FILES:
*========================================================================
            END
            EB.TransactionControl.UnauthRecordWrite()
            IF EB.SystemTables.getMessage() = "ERROR" THEN GOTO FIELD.DISPLAY.OR.INPUT
            IF EB.SystemTables.getMessage() = "AUT" THEN GOTO HANDLE.MESSAGE
        CASE EB.SystemTables.getMessage() = "AUT"
*========================================================================
REM "DEFINE FINAL CHECKS BEFORE STORING AUTHORISED LIFE FILE RECORD:
*========================================================================
*      IF R.NEW(V-8)[1,1] = "R" THEN
*        E = "REVERSAL NOT ALLOWED"; GOTO ID.ERROR
*     reversal normally only after special checks
*     e.g. you can't reverse CUSTOMER record before ACCOUNT record
*      END
            V.VAL = EB.SystemTables.getV()
            IF EB.SystemTables.getRNew(V.VAL - 8) = 'RNAU' THEN LAYOUT.REQ = 0 ELSE LAYOUT.REQ = 1
            IF EB.SystemTables.getRNew(V.VAL - 8) = 'INAU' AND EB.SystemTables.getAuthNo() = 2 THEN LAYOUT.REQ = 0
*
            RC.ID = '%':EB.SystemTables.getIdNew()
            R.REC = EB.Reports.ReportControl.ReadNau(RC.ID, ER)
            IF R.REC THEN
                EB.SystemTables.setE("DE.DFP.CANT.AUTHORISE,UNAU.REPORT.CONTROL.EXISTS")
                EB.SystemTables.setL(24)
                EB.ErrorProcessing.Err()
                EB.SystemTables.setMessage("ERROR")
                GOTO FIELD.DISPLAY.OR.INPUT ;* Back to field display
            END
*
* Check to see if the form type has changed, If so and a $NAU record
* does not exist then change the corresponding report control record
* accordingly.
*
            IF (EB.SystemTables.getROld(DE.Config.FormatPrint.PrtFormType) NE EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFormType)) AND EB.SystemTables.getROld(DE.Config.FormatPrint.PrtInputter) THEN
                R.REC = EB.Reports.ReportControl.ReadNau(RC.ID, ER)
                IF ER THEN
*
                    ER = ''
                    DIM RC.REC(EB.Reports.ReportControl.RcfAuditDateTime)
                    MAT RC.REC = ''
                    EB.Reports.ReportControlLock(RC.ID,R.RC.REC,ER,'P','')
                    MATPARSE RC.REC FROM R.RC.REC
                    IF NOT(ER) THEN
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFormType) THEN
                            RC.REC(EB.Reports.ReportControl.RcfFormName) = EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFormType)
                        END ELSE
                            RC.REC(EB.Reports.ReportControl.RcfFormName) = 'DEFAULT'
                        END
*
                        CURR.NUMB = RC.REC(EB.Reports.ReportControl.RcfCurrNo) + 1
                        GOSUB WRITE.RC
*
                    END
                END
*
            END
*
            GOSUB CREATE.RC.REC   ;* EN_10002211 - S/E

            EB.TransactionControl.AuthRecordWrite()
*

            IF EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcSourceType> NE 'SESSION' THEN      ;* BG_100009761 S/E
                IF LAYOUT.REQ THEN
*
* Produce sample report layout
*
*               PRINT @(1, 23) : 'DO YOU WANT SAMPLE LAYOUT  (Y/NO)  ' :
*               INPUT PRINT.REPLY :
                    PRINT.REPLY = "DO YOU WANT A SAMPLE LAYOUT (Y/NO) "
                    EB.Display.Txtinp(PRINT.REPLY,8,22,2,@FM:'Y_NO')
                    PRINT.REPLY = EB.SystemTables.getComi()
                    PRINT @(1, 23) : EB.Desktop.getSClearEol() :
                    IF PRINT.REPLY = 'Y' THEN
                        PRINT @(19, 23) : EB.Desktop.getSClearEol() : @(19, 23) : FMT( 'PRODUCING SAMPLE REPORT LAYOUT' , '60R' ) :
                        EB.SystemTables.setInputBuffer(EB.SystemTables.getIdNew())
                        DE.API.MmLayout()
                        EB.SystemTables.setInputBuffer('')
                    END
                END
            END         ;* BG_100009761 S/E
            IF EB.SystemTables.getMessage() = "ERROR" THEN GOTO FIELD.DISPLAY.OR.INPUT
        CASE 1
*========================================================================
REM "DEFINE SPECIAL FIELD CHECKS:
*========================================================================
            EB.SystemTables.setE(""); EB.SystemTables.setEtext("")
            BEGIN CASE
*
* If form type is blank, pick up default form type
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatPrint.PrtFormType
                    IF EB.SystemTables.getComi() = "" THEN
                        CHECKFILE2 = 'DE.FORM.TYPE' : @FM : DE.Reports.FormType.TypDescription : @FM : 'L.A'
                        ER = ''
                        R.REC = ''
                        LNGG.POS = EB.SystemTables.getLngg()
                        R.REC = DE.Reports.FormType.Read('DEFAULT', ER)
                        EB.SystemTables.setEtext(ER)
                        ENRIX = R.REC<DE.Reports.FormType.TypDescription,LNGG.POS>
                        IF NOT(ENRIX) THEN
                            ENRIX = R.REC<DE.Reports.FormType.TypDescription,1>
                        END
                        IF EB.SystemTables.getEtext() THEN
                            EB.SystemTables.setE('DE.DFP.DEFAULT.FORM.TYPE.NOT.ON.FILE')
                            GOTO FIELD.ERROR
                        END
                    END
*
* Validate lines sequence
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatPrint.PrtLine
                    COMI.VAL = EB.SystemTables.getComi()
                    MAX = LEN(COMI.VAL)
                    SEP = INDEX(COMI.VAL, '-' , 1)
                    IF SEP = 0 THEN
                        START.LINE = EB.SystemTables.getComi()
                        END.LINE = ''
                    END ELSE
                        START.LINE = EB.SystemTables.getComi()[1, SEP - 1]
                        END.LINE = EB.SystemTables.getComi()[SEP + 1, 5]
                        CONVERT ' ' TO '' IN START.LINE
                        CONVERT ' ' TO '' IN END.LINE
                    END
*
* Get form type record
*
                    IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFormType) THEN
                        R.REC = ''
                        ER = ''
                        FORM.ID = EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFormType)
                        R.REC = DE.Reports.FormType.Read(FORM.ID, ER)
                        MATPARSE R.TYPE FROM R.REC
                        IF ER THEN
                            MAT R.TYPE = ''
                            EB.SystemTables.setE('DE.DFP.FORM.TYPE.NOT.ON.FILE')
                            GOTO FIELD.ERROR
                        END
                    END ELSE
                        R.REC = ''
                        ER = ''
                        FORM.ID = 'DEFAULT'
                        R.REC = DE.Reports.FormType.Read(FORM.ID, ER)
                        MATPARSE R.TYPE FROM R.REC
                        IF ER THEN
                            MAT R.TYPE = ''
                            EB.SystemTables.setE('DE.DFP.DEFAULT.FORM.TYPE.NOT.ON.FILE')
                            GOTO FIELD.ERROR
                        END
                    END
*
* Validate start line - must be numeric and between 1 and maximum line
* number from form type
*
                    IF START.LINE[1, 1] = '+' THEN
                        TEST.FIELD = START.LINE[2, 4]
                        BEGIN CASE
                            CASE NOT(NUM(TEST.FIELD))
                                EB.SystemTables.setE('DE.DFP.START.LINE.NUMERIC.AFTER.S.SIGN')
                                GOTO FIELD.ERROR
                            CASE TEST.FIELD < 0
                                EB.SystemTables.setE('DE.DFP.NOT.NEGATIVE')
                                GOTO FIELD.ERROR
                            CASE TEST.FIELD > R.TYPE(DE.Reports.FormType.TypFormDepth)
                                EB.SystemTables.setE('DE.DFP.NOT.G': @FM : R.TYPE(DE.Reports.FormType.TypFormDepth))
                                GOTO FIELD.ERROR
                        END CASE
                    END ELSE
                        BEGIN CASE
                            CASE NOT(NUM(START.LINE))
                                EB.SystemTables.setE("DE.DFP.NUMERIC")
                                GOTO FIELD.ERROR
                            CASE START.LINE < 1
                                EB.SystemTables.setE('DE.DFP.LINE.NO.G.0')
                                GOTO FIELD.ERROR
                            CASE START.LINE > R.TYPE(DE.Reports.FormType.TypFormDepth)
                                EB.SystemTables.setE('DE.DFP.LINE.NO.NOT.G': @FM : R.TYPE(DE.Reports.FormType.TypFormDepth))
                                GOTO FIELD.ERROR
                        END CASE
                    END
*
* Validate end line if range  entered - must be numeric, greater than
* start line and not greater than maximum line number from form type
* and must not be in the form +nn if start line is a fixed line number
*
                    IF SEP THEN
                        IF END.LINE[1, 1] = '+' THEN
                            IF START.LINE[1, 1] <> '+' THEN
                                EB.SystemTables.setE('DE.DFP.END.LINE.FIXED.LINE')
                                GOTO FIELD.ERROR
                            END
                            TEST.FIELD = END.LINE[2, 4]
                            BEGIN CASE
                                CASE NOT(NUM(TEST.FIELD))
                                    EB.SystemTables.setE('DE.DFP.END.LINE.NUMERIC.AFTER.S.SIGN')
                                    GOTO FIELD.ERROR
                                CASE TEST.FIELD < 1
                                    EB.SystemTables.setE('DE.DFP.RELATIVE.END.LINE.G.0')
                                    GOTO FIELD.ERROR
                                CASE TEST.FIELD > R.TYPE(DE.Reports.FormType.TypFormDepth)
                                    EB.SystemTables.setE('DE.DFP.NOT.G': @FM : R.TYPE(DE.Reports.FormType.TypFormDepth))
                                    GOTO FIELD.ERROR
                            END CASE
                        END ELSE
                            BEGIN CASE
                                CASE NOT(NUM(END.LINE))
                                    EB.SystemTables.setE('DE.DFP.END.LINE.NUMERIC')
                                    GOTO FIELD.ERROR
                                CASE END.LINE <= START.LINE
                                    EB.SystemTables.setE('DE.DFP.END.LINE.G.START.LINE')
                                    GOTO FIELD.ERROR
                                CASE END.LINE > R.TYPE(DE.Reports.FormType.TypFormDepth)
                                    EB.SystemTables.setE('DE.DFP.LINE.NOT.G': @FM : R.TYPE(DE.Reports.FormType.TypFormDepth))
                                    GOTO FIELD.ERROR
                            END CASE
                        END
                    END
*
* Start line must not be less than previous start line
*
                    AF1 = EB.SystemTables.getAf()
                    PREVIOUS.START.LINE = FIELD(EB.SystemTables.getRNew(AF1)< 1, EB.SystemTables.getAv() - 1 > , '-' , 1)
                    IF PREVIOUS.START.LINE[1, 1] <> '+' THEN
                        IF START.LINE[1, 1] <> '+' THEN
                            IF EB.SystemTables.getAv() > 1 THEN
                                IF START.LINE < EB.SystemTables.getRNew(AF1)< 1, EB.SystemTables.getAv() - 1 > [1, 2] THEN
                                    EB.SystemTables.setE('DE.DFP.LINES.NOT.SEQUENCE')
                                    GOTO FIELD.ERROR
                                END
                            END
                        END
                    END
*
* If range given, make start line and end line each two digits long
*
                    IF SEP THEN
                        IF START.LINE[1, 1] = "+" THEN
                            IF LEN(START.LINE) = 2 THEN START.LINE = '+0' : START.LINE[2, 1]
                        END ELSE IF LEN(START.LINE) = 1 THEN START.LINE = "0" : START.LINE
                        IF END.LINE[1, 1] = '+' THEN
                            IF LEN(END.LINE) = 2 THEN END.LINE = '+0' : END.LINE[2, 1]
                        END ELSE IF LEN(END.LINE) = 1 THEN END.LINE = "0" : END.LINE
                        EB.SystemTables.setComi(START.LINE : "-" : END.LINE)
                    END ELSE
                        IF START.LINE[1, 1] = '+' THEN
                            IF LEN(START.LINE) = 2 THEN START.LINE = '+0' : START.LINE[2, 1]
                        END ELSE IF LEN(START.LINE) = 1 THEN START.LINE = '0' : START.LINE
                        EB.SystemTables.setComi(START.LINE)
                    END
*
* If AV = 1, then start line must not begin +
*
                    IF EB.SystemTables.getAv() = 1 THEN
                        IF START.LINE[1, 1] = '+' THEN
                            EB.SystemTables.setE('DE.DFP.FIRST.LINE.FIXED.LINE')
                            GOTO FIELD.ERROR
                        END
                    END
*
* If start line is '+00', previous end line must be equal to current end
* line
*
                    IF START.LINE = '+00' THEN
                        AF1 = EB.SystemTables.getAf()
                        PREVIOUS.END.LINE = FIELD(EB.SystemTables.getRNew(AF1)< 1, EB.SystemTables.getAv() - 1 > , '-' , 2)
                        IF PREVIOUS.END.LINE <> END.LINE THEN
                            EB.SystemTables.setE('DE.DFP.INVALID.MULTIPLE.LINES.COMBINATION')
                            GOTO FIELD.ERROR
                        END
                    END
*
* Validate indentation - must be numeric between 1 and maximum width
* from form type
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatPrint.PrtIndent
                    COMI.VAL = EB.SystemTables.getComi()
                    IF NOT(NUM(COMI.VAL)) THEN
                        EB.SystemTables.setE('DE.DFP.NUMERIC')
                        GOTO FIELD.ERROR
                    END
*
* Get form type record
*
                    IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFormType) THEN
                        R.REC = ''
                        ER = ''
                        FORM.ID = EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFormType)
                        R.REC = DE.Reports.FormType.Read(FORM.ID, ER)
                        MATPARSE R.TYPE FROM R.REC
                        IF ER THEN
                            MAT R.TYPE = ''
                            EB.SystemTables.setE('DE.DFP.FORM.TYPE.NOT.ON.FILE')
                            GOTO FIELD.ERROR
                        END
                    END ELSE
                        R.REC = ''
                        ER = ''
                        FORM.ID = 'DEFAULT'
                        R.REC = DE.Reports.FormType.Read(FORM.ID, ER)
                        MATPARSE R.TYPE FROM R.REC
                        IF ER THEN
                            MAT R.TYPE = ''
                            EB.SystemTables.setE('DE.DFP.DEFAULT.FORM.TYPE.NOT.ON.FILE')
                            GOTO FIELD.ERROR
                        END
                    END
                    IF EB.SystemTables.getComi()< 1 OR EB.SystemTables.getComi() > R.TYPE(DE.Reports.FormType.TypFormWidth) THEN
                        EB.SystemTables.setE('DE.DFP.MAX.INDENTATION.': @FM : R.TYPE(DE.Reports.FormType.TypFormWidth))
                        GOTO FIELD.ERROR
                    END
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatPrint.PrtComplete
*
* If complete is 'Y', multi must be 'S'
*
                    IF EB.SystemTables.getComi() = 'Y' THEN
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtMulti)< 1, EB.SystemTables.getAv() > <> 'S' THEN
                            EB.SystemTables.setE('DE.DFP.MULTI.S')
                            GOTO FIELD.ERROR
                        END
*
* If complete is blank, default to 'NO'
*
                    END ELSE EB.SystemTables.setComi('NO')
*
* Validate field name/text - must contain a field name which exists on
* the message file, text in quotes or a valid key word
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatPrint.PrtFieldText
*
                    COMI.VAL = EB.SystemTables.getComi()
                    QTS = COUNT(COMI.VAL, '"' )
                    IF QTS = 0 THEN
*
* Field name or keyword entered
*
* EN_10001244 - S
***                     LOCATE COMI IN R.MSG(DE.MSG.FIELD.NAME) < 1, 1 > SETTING IND ELSE
                        LOC.FIELD.NAME = EB.SystemTables.getComi()
                        GOSUB LOCATE.FIELD.NAME
                        IF NOT(LOC.POS) THEN
* EN_10001244 - E
                            LOCATE EB.SystemTables.getComi() IN KEY.WORDS < 1 > SETTING IND ELSE
                                BEGIN CASE
                                    CASE EB.SystemTables.getComi()[1, 6] = 'TOTAL.'
                                        IF NOT(NUM(COMI.VAL[7, 2])) THEN
                                            EB.SystemTables.setE('DE.DFP.INVALID.KEYWORD')
                                            GOTO FIELD.ERROR
                                        END
                                    CASE EB.SystemTables.getComi()[1, 1] = "&"
*
* Entry begins with & and may be a printer attribute keyword
*
                                        IF EB.SystemTables.getComi()[1, 5] <> "&ATTI" AND EB.SystemTables.getComi()[1, 5] <> "&ATTR" THEN
                                            EB.SystemTables.setE("DE.DFP.INVALID.ATTRIBUTE.KEYWORD")
                                            GOTO FIELD.ERROR
                                        END
                                        IF NOT(INDEX(COMI.VAL, "&" , 2)) THEN EB.SystemTables.setComi(EB.SystemTables.getComi() : "&")
                                    CASE 1
                                        EB.SystemTables.setE('DE.DFP.FLD.NAME.OR.KEYWORD.MISS')
                                        GOTO FIELD.ERROR
                                END CASE
                            END
                        END
                    END ELSE
*
* Text entered - make sure quotation marks match
*
                        IF QTS <> 2 THEN
                            EB.SystemTables.setE('DE.DFP.INVALID.TEXT.FORMAT')
                            GOTO FIELD.ERROR
                        END
                        COMI.VAL = EB.SystemTables.getComi()
                        IF FIELD(COMI.VAL, '"' , 1) <> '' OR FIELD(COMI.VAL, '"' , 3) <> '' THEN
                            EB.SystemTables.setE('DE.DFP.INVALID.TEXT.FORMAT')
                            GOTO FIELD.ERROR
                        END
                        IF FIELD(COMI.VAL, '"' , 2) = '' THEN
                            EB.SystemTables.setE('DE.DFP.TEXT.MISS')
                            GOTO FIELD.ERROR
                        END
                    END
*
* Validate conversion code - must begin with TAB, TRANS, CUS, COPY,
* DUP, WORDS or DATE
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatPrint.PrtConversion
                    IF EB.SystemTables.getComi() THEN
*
* Conversion invalid for text fields (except "COPY and DUPLICATE")
*
                        QTS = COUNT(EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, EB.SystemTables.getAv() > , '"' )
                        IF NOT(QTS) THEN QTS = INDEX(EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, EB.SystemTables.getAv() > , "&" , 1)
                        IF QTS THEN
                            IF EB.SystemTables.getComi()<> 'COPY' AND EB.SystemTables.getComi()<> 'DUP' AND EB.SystemTables.getComi()<> 'DUPLICATE' THEN
                                EB.SystemTables.setE('DE.DFP.CONVERSION.INVALID.TEXT')
                                GOTO FIELD.ERROR
                            END
                        END
*
* Conversion not allowed for TOTAL.n fields
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, EB.SystemTables.getAv() > [1, 6] = 'TOTAL.' THEN
                            COMI.VAL = EB.SystemTables.getComi()
                            IF NOT(COMI.VAL[1,3] MATCHES "CCY":@VM:"FIX") THEN
                                EB.SystemTables.setE('DE.DFP.CONVERSION.NOT.ALLOWED.TOTAL.N')
                                GOTO FIELD.ERROR
                            END
                        END
*
* Validate conversion
*
                        LOCATE EB.SystemTables.getComi() IN CONV < 1 > SETTING IND ELSE
                            BEGIN CASE
                                CASE EB.SystemTables.getComi()[1, 5] = 'TRANS'
                                    NULL
                                CASE EB.SystemTables.getComi()[1, 5] = 'TABLE'
                                    IF EB.SystemTables.getComi()[6, 1] THEN
                                        IF EB.SystemTables.getComi()[6, 1] <> ' ' THEN
                                            EB.SystemTables.setE('DE.DFP.INVALID.CONVERSION')
                                            GOTO FIELD.ERROR
                                        END
                                    END
                                CASE EB.SystemTables.getComi()[1, 3] = 'CUS'
*
* If keyword is customer, it must be followed by an * then a customer
* keyword, e.g. NAME 1
*
                                    COMI.VAL = EB.SystemTables.getComi()
                                    POS = INDEX(COMI.VAL, '*' , 1)
                                    IF POS THEN
                                        CUS.WORD = EB.SystemTables.getComi()[POS + 1, 20]
                                        LOCATE CUS.WORD IN CUS.KEYWORDS < 1 > SETTING IND ELSE
                                            EB.SystemTables.setE('DE.DFP.CU.KEYWORD.INVALID')
                                            GOTO FIELD.ERROR
                                        END
                                    END ELSE
                                        EB.SystemTables.setE('DE.DFP.CU.KEYWORD.ENT')
                                        GOTO FIELD.ERROR
                                    END
*
                                CASE EB.SystemTables.getComi()[1,4] MATCHES "LINK"
                                    IF R.PARM<DE.Config.Parm.ParInstallation> NE "R" THEN
                                        EB.SystemTables.setE("DE.DFP.INVALID.CONVERSION,FILES.NOT.RESIDENT")
                                    END ELSE
                                        COMI.VAL = EB.SystemTables.getComi()
                                        YFILE = FIELD(COMI.VAL,"*",2)[">",1,1]
                                        FIELD.SPEC = EB.SystemTables.getComi()[">",2,99]     ;* Field def
                                        YTYPE = ""
                                        R.REC = ''
                                        ER = ''
                                        R.REC = EB.SystemTables.PgmFile.Read(YFILE, ER)
                                        YTYPE = R.REC<EB.SystemTables.PgmFile.PgmType>
                                        EB.SystemTables.setEtext(ER)
                                        IF EB.SystemTables.getEtext() OR NOT(INDEX("HULWT",YTYPE,1)) THEN
                                            EB.SystemTables.setE("DE.DFP.INVALID.FILE.NAME/TYPE")
                                        END ELSE
                                            GOSUB GET.LINK.FILE
*
** Get the field name and validate it. If a number is entered
** get the corresponding name.
*
                                            FM.NO = FIELD.SPEC[">",1,1]
                                            IF FM.NO MATCHES "1N0N" THEN          ;* Enrich
                                                LOCATE FM.NO IN FIELD.NOS<1,1> SETTING POS THEN
                                                    FIELD.NAME = FIELD.NAMES<1,POS>
                                                END ELSE
                                                    EB.SystemTables.setE("DE.DFP.INVALID.FLD.NO")
                                                END
                                            END ELSE
                                                LOCATE FM.NO IN FIELD.NAMES<1,1> SETTING POS THEN
                                                    FM.NO = FIELD.NOS<1,POS>
                                                    FIELD.NAME = FIELD.NAMES<1,POS>
                                                END ELSE
                                                    EB.SystemTables.setE("DE.DFP.INVALID.FLD.NAME")
                                                END
                                            END
*
                                            E.VAL = EB.SystemTables.getE()
                                            IF NOT(E.VAL) THEN
                                                VM.NO = FIELD.SPEC[">",2,1]
                                                SM.NO = FIELD.SPEC[">",3,1]
                                                OTHER.BIT = FIELD.SPEC[">",4,99]
                                                LAST.PART = ""
                                                IF VM.NO THEN LAST.PART = ">":VM.NO
                                                IF SM.NO THEN LAST.PART := ">":SM.NO
*
                                                BEGIN CASE
                                                    CASE NOT(INDEX("DI",FIELD.TYPES<1,POS>,1))  ;* Invalid type
                                                        EB.SystemTables.setE("DE.DFP.INVALID.FLD.TYPE")
                                                    CASE FIELD.MULTI<1,POS> = "S" AND VM.NO:SM.NO
                                                        EB.SystemTables.setE("DE.DFP.FLD.ONLY.SINGLE.VALUED")
                                                    CASE NOT(VM.NO MATCHES "1N0N":@VM:"L":@VM:"")
                                                        EB.SystemTables.setE("DE.DFP.INVALID.MULTI.FLD.DEFINEITION")
                                                    CASE NOT(SM.NO MATCHES "1N0N":@VM:"L":@VM:"")
                                                        EB.SystemTables.setE("DE.DFP.INVALID.SUB.FLD.DEFINTION")
                                                    CASE OTHER.BIT
                                                        EB.SystemTables.setE("DE.DFP.INVALID.FLD.SPEC")
                                                END CASE
                                            END
                                        END
                                    END
                                    IF EB.SystemTables.getE() THEN
                                        GOTO FIELD.ERROR
                                    END ELSE
                                        EB.SystemTables.setComi("LINK*":YFILE:">":FIELD.NAME:LAST.PART)
                                    END
*
* GB9500381 - start
*
                                CASE EB.SystemTables.getComi()[1,8] = "WORDSCCY"   ;* Translate an amount into words according to the language and currency
                                    WORDSCCY.FLD = EB.SystemTables.getComi()["*",2,1]

                                    BEGIN CASE
                                        CASE WORDSCCY.FLD = ""
                                            EB.SystemTables.setE("DE.DFP.WORDSCCY*CURRENCY.LOCATION")
                                            GOTO FIELD.ERROR
                                        CASE 1
* EN_10001244 - S
****                                    LOCATE WORDSCCY.FLD IN R.MSG(DE.MSG.FIELD.NAME)<1,1> SETTING YY THEN YY = "OK! CCY exist" ELSE
                                            LOC.FIELD.NAME = WORDSCCY.FLD
                                            GOSUB LOCATE.FIELD.NAME
                                            IF NOT(LOC.POS) THEN
                                                EB.SystemTables.setE("DE.DFP.INVALID.FLD.MESSAGE")
                                                GOTO FIELD.ERROR
                                            END
* EN_10001244 - E
                                    END CASE
*
* GB9500381 - stop
*
                                CASE EB.SystemTables.getComi()[1,3] = "CCY"        ;* Format according to CCY
                                    CCY.FLD = EB.SystemTables.getComi()["*",2,1]
                                    BEGIN CASE
                                        CASE CCY.FLD = ""
                                            EB.SystemTables.setE("DE.DFP.CCY*CURRENCY.LOCATION")
                                            GOTO FIELD.ERROR
                                        CASE 1          ;* Must be single valued
* EN_10001244 - S
****                                    LOCATE CCY.FLD IN R.MSG(DE.MSG.FIELD.NAME)<1,1> SETTING YY THEN
                                            LOC.FIELD.NAME = CCY.FLD
                                            GOSUB LOCATE.FIELD.NAME
                                            IF LOC.POS THEN
                                                IF R.MSG(LOC.MSG.SINGLE.MULTI)<1,LOC.POS> = "M" THEN
                                                    EB.SystemTables.setE("DE.DFP.NOT.ALLOWED.MULTI.VALUE.FLD")
                                                    GOTO FIELD.ERROR
                                                END
                                            END ELSE
                                                EB.SystemTables.setE("DE.DFP.INVALID.FLD.MESSAGE")
                                                GOTO FIELD.ERROR
                                            END
* EN_10001244 - E
                                    END CASE
*
                                CASE EB.SystemTables.getComi()[1,3] = 'FIX'        ;* Euro conversions
                                    COMI.VAL = EB.SystemTables.getComi()
                                    IF NOT(COMI.VAL[4,3] MATCHES 'CCY':@VM:'RTE':@VM:'EQU') THEN
                                        EB.SystemTables.setE('DE.DFP.INVALID.CONVERSION')
                                    END ELSE
                                        CCY.FLD = EB.SystemTables.getComi()['*',2,1]
                                        BEGIN CASE
                                            CASE CCY.FLD = ""
                                                EB.SystemTables.setE("DE.DFP.FIXAAA*CURRENCY.LOCATION")
                                                GOTO FIELD.ERROR
                                            CASE 1      ;* Must be single valued
* EN_10001244 - S
****                                       LOCATE CCY.FLD IN R.MSG(DE.MSG.FIELD.NAME)<1,1> SETTING YY ELSE
                                                LOC.FIELD.NAME = CCY.FLD
                                                GOSUB LOCATE.FIELD.NAME
                                                IF NOT(LOC.POS) THEN
                                                    EB.SystemTables.setE("DE.DFP.INVALID.FLD.MESSAGE")
                                                    GOTO FIELD.ERROR
                                                END
* EN_10001244 - E
                                        END CASE
                                    END
*
                                CASE EB.SystemTables.getComi()[1,1] = '@'          ;* GB0000680 - Customers own conversions
                                    COMI.VAL = EB.SystemTables.getComi()
                                    ROUTINE.ID = EB.SystemTables.getComi()[2,LEN(COMI.VAL)-1]
                                    
                                    ROUTINE.TYPE = ""
                                    R.REC = ''
                                    ER = ''
                                    
                                    EBAPI.REC = '' ;*initialisation for the EB.API record read.
                                    SRC.TYPE=''
                                    API.ERR=''
                                    
                                    EBAPI.REC = EB.SystemTables.Api.Read(ROUTINE.ID, API.ERR) ;* To read the EB.API record with ROUTINE.ID and retrieve the SOURCE.TYPE
                                    IF NOT(API.ERR) THEN
                                        SRC.TYPE = EBAPI.REC<EB.SystemTables.Api.ApiSourceType>
                                    END
                                    IF SRC.TYPE NE "METHOD" THEN   ;* To validate if the source type is of method for the ebapi record or check if PGM.FILE entry of type 'S' is present for the routine id.
                                        R.REC = EB.SystemTables.PgmFile.Read(ROUTINE.ID, ER)
                                        ROUTINE.TYPE = R.REC<EB.SystemTables.PgmFile.PgmType>
                                        EB.SystemTables.setEtext(ER)
                                        IF EB.SystemTables.getEtext() OR (ROUTINE.TYPE <> "S") THEN
                                            EB.SystemTables.setE("DE.DFP.INVALID.ROUTINE.PGM.FILE.TYPE.S")
                                            GOTO FIELD.ERROR
                                        END
                                    END
*
                                CASE 1
                                    EB.SystemTables.setE('DE.DFP.INVALID.CONVERSION'); GOTO FIELD.ERROR
                            END CASE
                        END
                    END
*
* Validate mask - must contain mask characters as defined in MASK.CHARS
* seperated by spaces
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatPrint.PrtMask
*
                    IF EB.SystemTables.getComi() NE '' THEN          ;* CI_10010568 S/E
*
* Masking invalid for text fields
*
                        QTS = COUNT(EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, EB.SystemTables.getAv() > , '"' )
                        IF NOT(QTS) THEN QTS = INDEX(EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, EB.SystemTables.getAv() > , "&" , 1)
                        IF QTS THEN
                            EB.SystemTables.setE('DE.DFP.MASKING.INVALID.TEXT')
                            GOTO FIELD.ERROR
                        END
*
* If conversion is 'WORDS', masking is invalid
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtConversion)< 1, EB.SystemTables.getAv() > = 'WORDS' THEN
                            EB.SystemTables.setE('DE.DFP.MASKING.INVALID.WITH.WORDS.CONV')
                            GOTO FIELD.ERROR
                        END
*
* GB9500381 - start
*
* If conversion is 'WORDSCCY*xxx', masking is invalid
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtConversion)< 1, EB.SystemTables.getAv() >[1,8] = 'WORDSCCY' THEN
                            EB.SystemTables.setE('DE.DFP.MASKING.INVALID.WITH.WORDSCCY.CONV')
                            GOTO FIELD.ERROR
                        END
*
* GB9500381 - stop
*
                        FILL.CHARS = 0
                        NEGATIVE = 0
                        T.DOUBLE = ''
*
* First and last characters must not be a space
*
                        COMI.VAL = EB.SystemTables.getComi()
                        IF EB.SystemTables.getComi()[LEN(COMI.VAL), 1] = ' ' OR EB.SystemTables.getComi()[1, 1] = ' ' THEN
                            EB.SystemTables.setE('DE.DFP.INVALID.NO.DELIMITERS')
                            GOTO FIELD.ERROR
                        END
                        COMI.VAL = EB.SystemTables.getComi()
                        MAX = COUNT(COMI.VAL, " " ) + 1
                        FOR X = 1 TO MAX
                            MASK = FIELD(COMI.VAL, " " , X)
                            LOCATE MASK[1, 1] IN MASK.CHARS < 1 > SETTING IND ELSE
*
                                IF X = 1 THEN
*
* If field is in the format 000/00/00, number of zeros must equal
* field length from message file
*
* EN_10001244 - S
****                              LOCATE R.NEW(DE.PRT.FIELD.TEXT) < 1, AV > IN R.MSG(DE.MSG.FIELD.NAME) < 1, 1 > SETTING IND ELSE IND = 0
                                    LOC.FIELD.NAME = EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, EB.SystemTables.getAv() >
                                    GOSUB LOCATE.FIELD.NAME
                                    IF LOC.POS THEN
                                        FIELD.LENGTH = COUNT(COMI.VAL, "0" )
                                        IF FIELD.LENGTH <> R.MSG(LOC.MSG.LENGTH) < 1, LOC.POS > THEN
                                            EB.SystemTables.setE("DE.DFP.INVALID.MASK.LENGTH.1")
                                            GOTO FIELD.ERROR
                                        END
                                    END
* EN_10001244 - E
                                    GOTO CHECK.NEXT.PORTION
                                END ELSE EB.SystemTables.setE('DE.DFP.NOT.ON.INP.TABLE'); GOTO FIELD.ERROR
                            END
*
* Fill characters specified
*
                            IF MASK[2, 2] <> '' THEN
*
* Fill characters must not already have been specified
*
                                IF FILL.CHARS THEN
                                    EB.SystemTables.setE('DE.DFP.FILL.CHARACTERS.ENT.MORE.THAN.ONCE')
                                    GOTO FIELD.ERROR
                                END
                                FILL.CHARS = 1
*
* Fill length must be numeric
*
                                IF NOT(NUM(MASK[2, 4])) OR MASK[2, 4] = 0 THEN
                                    EB.SystemTables.setE('DE.DFP.FILL.LENGTH.INVALID')
                                    GOTO FIELD.ERROR
                                END
                            END ELSE
*
* Mask character must not already have been entered
*
                                LOCATE MASK IN T.DOUBLE < 1 > SETTING IND ELSE IND = 0
                                IF IND THEN
                                    EB.SystemTables.setE('DE.DFP.MASK.CHARACTERS.DUPLICATED')
                                END
                                IF T.DOUBLE THEN IND = COUNT(T.DOUBLE, @FM) + 2 ELSE IND = 1
                                T.DOUBLE < IND > = MASK
*
* If mask character is a negative character (-, A, C or D), a negative
* character must not previously have been entered
*
                                IF MASK = 'C' OR MASK = 'D' OR MASK = '-' OR MASK = 'A' THEN
                                    IF NEGATIVE THEN
                                        EB.SystemTables.setE('DE.DFP.INVALID.COMBINATION.MASK.CHARACTERS')
                                        GOTO FIELD.ERROR
                                    END
                                    NEGATIVE = 1
                                END
                            END
CHECK.NEXT.PORTION:
                        NEXT X
                    END
*
* Validate calculation
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatPrint.PrtCalculation
                    IF EB.SystemTables.getComi() THEN
*
* Field on message file must be numeric
*
* EN_10001244 - S
*****                     LOCATE R.NEW(DE.PRT.FIELD.TEXT) < 1, AV > IN R.MSG(DE.MSG.FIELD.NAME) < 1, 1 > SETTING IND ELSE IND = 0
                        LOC.FIELD.NAME = EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, EB.SystemTables.getAv() >
                        GOSUB LOCATE.FIELD.NAME
                        IF LOC.POS THEN
                            IF R.MSG(LOC.MSG.PRINT.TYPE) < 1, LOC.POS > <> 'N' THEN
                                EB.SystemTables.setE('DE.DFP.FLD.NUMERIC')
                                GOTO FIELD.ERROR
                            END
                        END
* EN_10001244 - E
*
* If conversion is 'WORDS', calculation must be blank
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtConversion)< 1, EB.SystemTables.getAv() > = 'WORDS' THEN
                            EB.SystemTables.setE('DE.DFP.CALC.INVALID.WITH.WORDS.CONVERSION')
                            GOTO FIELD.ERROR
                        END
*
* GB9500381 - start
*
* If conversion is 'WORDSCCY', calculation must be blank
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtConversion)< 1, EB.SystemTables.getAv() >[1,8] = 'WORDSCCY' THEN
                            EB.SystemTables.setE('DE.DFP.CALC.INVALID.WITH.WORDSCCY.CONVERSION')
                            GOTO FIELD.ERROR
                        END
*
* GB9500381 - stop
*
                        BEGIN CASE
                            CASE EB.SystemTables.getComi()[3, 5] = 'TOTAL'
*
* Total only allowed for fields or keyword of total
*
                                QTS = COUNT(EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, EB.SystemTables.getAv() > , '"' )
                                IF NOT(QTS) THEN QTS = INDEX(EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, EB.SystemTables.getAv() > , "&" , 1)
                                IF QTS THEN
                                    EB.SystemTables.setE('DE.DFP.TOTAL.INVALID.TEXT')
                                    GOTO FIELD.ERROR
                                END
                                BEGIN CASE
                                    CASE EB.SystemTables.getComi() MATCHES "'-,TOTAL.'1N"
                                        NULL
                                    CASE EB.SystemTables.getComi() MATCHES "'+,TOTAL.'1N"
                                        NULL
                                    CASE EB.SystemTables.getComi() MATCHES "'*,TOTAL.'1N"
                                        NULL
                                    CASE EB.SystemTables.getComi() MATCHES "'/,TOTAL.'1N"
                                        NULL
                                    CASE EB.SystemTables.getComi() = ''
                                        NULL
                                    CASE 1
                                        EB.SystemTables.setE('DE.DFP.INVALID.TOTAL.FORMAT')
                                        GOTO FIELD.ERROR
                                        COMI.VAL = EB.SystemTables.getComi()
                                        POS1 = INDEX(COMI.VAL, "." , 1)
                                        IF POS1 > 0 THEN
                                            IF EB.SystemTables.getComi()[POS1 + 1, 2] < 1 THEN
                                                EB.SystemTables.setE('DE.DFP.INVALID.FLD.NO.')
                                                GOTO FIELD.ERROR
                                            END
                                        END
                                END CASE
                            CASE EB.SystemTables.getComi() = 'ZERO'
*
* If calculation is ZERO, field name must be TOTAL.n
*
                                IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFieldText)< 1, EB.SystemTables.getAv() > [1, 6] <> 'TOTAL.' THEN
                                    EB.SystemTables.setE('DE.DFP.ZERO.ONLY.VALID.TOTAL.FIELDS')
                                    GOTO FIELD.ERROR
                                END
                                NULL
                            CASE 1
                                EB.SystemTables.setE('DE.DFP.INVALID.CALCULATION.PARAMETER')
                                GOTO FIELD.ERROR
                        END CASE
                    END
*
* If dependent upon operand is specified, dependent upon field must be
* present
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatPrint.PrtDepOp
                    IF EB.SystemTables.getComi() THEN
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtDependentOn)< 1, EB.SystemTables.getAv() > = '' THEN
                            EB.SystemTables.setE('DE.DFP.DEPENDENT.ON.PRESENT')
                            GOTO FIELD.ERROR
                        END
                    END
*
* If dependent upon condition is specified, dependent upon field and
* dependent upon operand must be present
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatPrint.PrtDepCond
                    IF EB.SystemTables.getComi() THEN
                        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtDependentOn)< 1, EB.SystemTables.getAv() > = '' THEN
                            EB.SystemTables.setE('DE.DFP.DEPENDENT.ON.PRESENT')
                            GOTO FIELD.ERROR
                        END ELSE
                            IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtDepOp)< 1, EB.SystemTables.getAv() > = '' THEN
                                EB.SystemTables.setE('DE.DFP.DEPENDENT.ON.OPERAND.PRESENT')
                                GOTO FIELD.ERROR
                            END
                        END
                    END
*
* If dependent on is entered, it must contain a field name which exists
* on the message file (ignoring the first character if it is "*") or be
* 'TOTAL.n'
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatPrint.PrtDependentOn
                    IF EB.SystemTables.getComi() THEN

* EN_10001244 - S
                        IF EB.SystemTables.getComi()[1, 1] = '*' THEN LOC.FIELD.NAME = EB.SystemTables.getComi()[2, 99]
                        ELSE LOC.FIELD.NAME = EB.SystemTables.getComi()
                        GOSUB LOCATE.FIELD.NAME
                        IF NOT(LOC.POS) THEN
****                     LOCATE YCOMI IN R.MSG(DE.MSG.FIELD.NAME) < 1, 1 > SETTING IND ELSE

                            IF LOC.FIELD.NAME MATCHES "'TOTAL.'1N" THEN NULL ELSE
                                EB.SystemTables.setE('DE.DFP.FLD.NAME.NOT.ON.MESSAGE.FILE')
                                GOTO FIELD.ERROR
                            END
                        END
* EN_10001244 - E
                    END
*
* If page overflow is blank, default to 'NO'
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatPrint.PrtPage
                    IF EB.SystemTables.getComi() = '' THEN EB.SystemTables.setComi('NO')
            END CASE
            IF EB.SystemTables.getTSequ()<> '' THEN tmp=EB.SystemTables.getTSequ(); tmp< - 1 >=EB.SystemTables.getA() + 1; EB.SystemTables.setTSequ(tmp)
            GOTO FIELD.DISPLAY.OR.INPUT
*------------------------------------------------------------------------
    END CASE
    GOTO ID.INPUT
*========================================================================
REM NEW INPUT FOR LAST FIELD ENTERED IN ERROR
*========================================================================
FIELD.ERROR:
    EB.SystemTables.setTSequ('IFLD')
    EB.ErrorProcessing.Err()
    GOTO FIELD.DISPLAY.OR.INPUT
RETURN
*
*-----------------------------------------------------------------------
* EN_10002211  S/E
CREATE.RC.REC:
*================
** Ensure a corresponding REPORT CONTROL record exists.
*
    ER = ''
    R.REC = EB.Reports.ReportControl.Read(RC.ID, ER)
    IF ER THEN
        DIM RC.REC(EB.Reports.ReportControl.RcfAuditDateTime)
        MAT RC.REC = ''
        RC.REC(EB.Reports.ReportControl.RcfDesc) = EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtDescription)
        RC.REC(EB.Reports.ReportControl.RcfShortDesc) = EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtDescription)
*
        IF EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFormType) THEN
            RC.REC(EB.Reports.ReportControl.RcfFormName) = EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtFormType)
        END ELSE
            RC.REC(EB.Reports.ReportControl.RcfFormName) = 'DEFAULT'
        END
*
        IF EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfMicroficheOutput>[1,1] MATCHES 'D':@VM:'Y' THEN
            RC.REC(EB.Reports.ReportControl.RcfMicroficheOutput) = 'Y'
        END ELSE
            RC.REC(EB.Reports.ReportControl.RcfMicroficheOutput) = 'N'
        END
*
        CURR.NUMB = 1
        GOSUB WRITE.RC
    END
RETURN
*
*-----------------------------------------------------------------------
*
WRITE.RC:
*=======
*
    RC.REC(EB.Reports.ReportControl.RcfCurrNo) = CURR.NUMB
    RC.REC(EB.Reports.ReportControl.RcfInputter) = "SY_DE.FORMAT.PRINT"
    RC.REC(EB.Reports.ReportControl.RcfDateTime) = EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtDateTime)
    RC.REC(EB.Reports.ReportControl.RcfAuthoriser) = "SY_DE.FORMAT.PRINT" ;* CI-10000502 S/E
    RC.REC(EB.Reports.ReportControl.RcfDeptCode) =EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtDeptCode)
    RC.REC(EB.Reports.ReportControl.RcfAuditorCode) =EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtAuditorCode)
    RC.REC(EB.Reports.ReportControl.RcfAuditDateTime) =EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtAuditDateTime)
    RC.REC(EB.Reports.ReportControl.RcfCoCode) = EB.SystemTables.getRNew(DE.Config.FormatPrint.PrtCoCode)   ;* BG_100000061
    MATBUILD R.RC.REC FROM RC.REC
    EB.Reports.ReportControlWrite(RC.ID,R.RC.REC,'')
RETURN
*
*-----------------------------------------------------------------------
GET.LINK.FILE:
*==================
** Read the standard selection record and verify the field
** entered to check the name and the location
*
    SS.REC = ""     ;*Standard selection
    EB.SystemTables.setEtext("")
    ER = ''
    SS.REC = EB.SystemTables.StandardSelection.Read(YFILE, ER)
    IF ER THEN
        EB.SystemTables.setEtext(ER)
        EB.SystemTables.setE("DE.DFP.NO.STANDARD.SELECTION.REC")
    END ELSE
        FIELD.NAMES = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName>:@VM:SS.REC<EB.SystemTables.StandardSelection.SslUsrFieldName>
        FIELD.NOS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo>:@VM:SS.REC<EB.SystemTables.StandardSelection.SslUsrFieldNo>
        FIELD.TYPES = SS.REC<EB.SystemTables.StandardSelection.SslSysType>:@VM:SS.REC<EB.SystemTables.StandardSelection.SslUsrType>
        FIELD.MULTI = SS.REC<EB.SystemTables.StandardSelection.SslSysSingleMult>:@VM:SS.REC<EB.SystemTables.StandardSelection.SslUsrSingleMult>
    END
RETURN
*
*****************************************************
* EN_10001244 - S
* Locate field name in user field and else locate in system
* in system fields and get the data from coresponding position.

LOCATE.FIELD.NAME:
    LOCATE LOC.FIELD.NAME IN R.MSG(DE.Config.Message.MsgUsrFieldName) < 1, 1 > SETTING LOC.POS ELSE LOC.POS = 0
    IF LOC.POS THEN
        LOC.MSG.FIELD.NAME = DE.Config.Message.MsgUsrFieldName
        LOC.MSG.PRINT.TYPE = DE.Config.Message.MsgUsrPrintType
        LOC.MSG.LENGTH = DE.Config.Message.MsgUsrLength
        LOC.MSG.SINGLE.MULTI = DE.Config.Message.MsgUsrSingMult
        LOC.MSG.MANDATORY = DE.Config.Message.MsgUsrMandatory

    END ELSE
        LOCATE LOC.FIELD.NAME IN R.MSG(DE.Config.Message.MsgFieldName) < 1, 1 > SETTING LOC.POS ELSE LOC.POS = 0
        IF LOC.POS THEN
            LOC.MSG.FIELD.NAME = DE.Config.Message.MsgFieldName
            LOC.MSG.PRINT.TYPE = DE.Config.Message.MsgPrintType
            LOC.MSG.LENGTH = DE.Config.Message.MsgLength
            LOC.MSG.SINGLE.MULTI = DE.Config.Message.MsgSingleMulti
            LOC.MSG.MANDATORY = DE.Config.Message.MsgMandatory
        END
    END
RETURN
* EN_10001244 - E
*-----------------------------------------------------------------------------
END
