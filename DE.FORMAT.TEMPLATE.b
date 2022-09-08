* @ValidationCode : MjoyMDIwMzcyNzU3OkNwMTI1MjoxNTg0NTE0NTU2NzYxOnNoYXNoaWRoYXJyZWRkeXM6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMy4yMDIwMDIxMi0wNjQ2OjEwMDc6MTMw
* @ValidationInfo : Timestamp         : 18 Mar 2020 12:25:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : shashidharreddys
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 130/1007 (12.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.20200212-0646
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


* Version 9 16/03/01  GLOBUS Release No. 200511 21/10/05
*-----------------------------------------------------------------------------
* <Rating>25108</Rating>
*-----------------------------------------------------------------------------
$PACKAGE DE.Config
SUBROUTINE DE.FORMAT.TEMPLATE
*
*-----------------------------------------------------------------------------------------
* DE.FORMAT.TEMPLATE - Contains the formatting instructions for printing
* messages, i.e. which fields are to be printed where and whether any
* special processing is to be done
*
* 10/03/98 - GB9800125
*            Add new FIXxxx Euro conversions
*
* 27/06/00 - GB0001630
*            Allow entry of customer-created CONVERSION Routines, of type
*            @ROUTINE where ROUTINE must exist as a type 'S' PGM.FILE
*            record.
*
* 13/09/01 -BG_100000061
*            CO.CODE is missing from the REPORT.CONTROL record created
*
* 01/06/01 - GLOBUS_EN_10000101
*            Add CQ as a valid Application
*
* 29/11/01 - CI-10000502
*            Problem with transferring REPORT.CONTROL records with
*            DL.DEFINE
*
* 20/02/02 - GLOBUS_EN_10000352
*            Add BL as a valid application
*
* 17/03/04 - EN_10002211
*            Creating new Report control rec is in after aut write para.
*            This part is moved before calling AUTH.RECORD.WRITE so that
*            Journal Update can be removed from WRITE.RC para.
*
* 21/07/10 - Task 69432
*            Needs to check the availability of DEPENDENT.ON field name in
*            USER.FIELD.NAME of DE.MESSAGE also.
*
* 11/08/10 - Task 75849
*            Defect 75308
*            To handle the USER defined fields in Message and Mapping.
*            When validating field name, extra validation is made to check
*            whether the field exists in the User fields on the
*            message record and get the corresponding data.
*
* 08/04/11 - 188299
*            Variable has been assigned properly.
*
* 22/09/15 - Enhancement 1265068/Task 1448651
*          - Routine incorporated
*
*06/05/16 - Enhancement 1687033/ Task 1701255
*         - New values in DE.MESSAGE (V,ML,VL) should be
*         - treated as M
*
* 09/08/18 - Defect 2712896/ Task 2413893
*            DE.FORMAT.TEMPLATE not allowing to define Alpha Numeric MESSAGE.TYPE as part of id
*
* 18/03/20 - Defect 3613636 / Task 3644661
*            Length of id is increased to 35 and length of message type is changed based on eb.object of de.message
*
*-----------------------------------------------------------------------------------------
*
    $USING DE.Config
    $USING EB.SystemTables
    $USING DE.Reports
    $USING EB.Reports
    $USING EB.Display
    $USING EB.TransactionControl
    $USING EB.ErrorProcessing
    $USING DE.API
    $USING EB.Desktop
    $USING EB.API

*************************************************************************
REM "DEFINE PGM NAME (BY USING 'C/DE.FORMAT.TEMPLATE/.../G9999')
*========================================================================
    DIM R.MSG(DE.Config.Message.MsgAuditDateTime), R.TYPE(DE.Reports.FormType.TypAuditDateTime)
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
    EB.SystemTables.setF(2, 'DE.MESSAGE.POPN'); 
   
    MAX.LEN = ''
    OBJECT.ID = 'DE.MESSAGE'
    EB.API.GetObjectLength(OBJECT.ID,MAX.LEN)
    IF MAX.LEN EQ "" THEN
        EB.SystemTables.setN(2, '4..C');* MESSAGE.TYPE field length is fetched based on the EB.OBJECT>DE.MESSAGE
    END ELSE
        EB.SystemTables.setN(2, MAX.LEN:'..C')
    END

    EB.SystemTables.setF(3, 'PRINT.POPN'); EB.SystemTables.setN(3, '20..C')
    EB.SystemTables.setF(4, 'FORM.TYPE'); EB.SystemTables.setN(4, '7..C')
    EB.SystemTables.setF(5, 'TEMPLATE'); EB.SystemTables.setN(5, '12')
    EB.SystemTables.setF(6, 'XX<FIELD.NAME'); EB.SystemTables.setN(6, ' 35..C')
    EB.SystemTables.setF(7, 'XX-TEXT'); EB.SystemTables.setN(7, ' 50..C')
    EB.SystemTables.setF(8, 'XX-MULTI'); EB.SystemTables.setN(8, '1')
    EB.SystemTables.setF(9, 'XX-XX.CONVERSION'); EB.SystemTables.setN(9, '45..C')
    EB.SystemTables.setF(10, 'XX-MASK'); EB.SystemTables.setN(10, '25..C')
    EB.SystemTables.setF(11, 'XX-CALCULATION'); EB.SystemTables.setN(11, '9..C')
    EB.SystemTables.setF(12, 'XX-DEPENDENT.ON'); EB.SystemTables.setN(12, '19..C')
    EB.SystemTables.setF(13, 'XX-DEPEND.OPERAND'); EB.SystemTables.setN(13, '2..C')
    EB.SystemTables.setF(14, 'XX-DEPEND.COND'); EB.SystemTables.setN(14, '30..C')
    EB.SystemTables.setF(15, 'XX-DATA.NAME'); EB.SystemTables.setN(15, '35..C')
    EB.SystemTables.setF(16, 'XX-RESERVED.10'); EB.SystemTables.setN(16, '30..C')
    EB.SystemTables.setF(17, 'XX-RESERVED.9'); EB.SystemTables.setN(17, '30..C')
    EB.SystemTables.setF(18, 'XX>RESERVED.8'); EB.SystemTables.setN(18, '30..C')
    Z = 18
    FOR X = 7 TO 1 STEP -1
        Z+=1 ; EB.SystemTables.setF(Z, "RESERVED.":X); EB.SystemTables.setN(Z, "9"); EB.SystemTables.setT(Z, ""); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
    NEXT X
*
    EB.SystemTables.setV(Z + 9); * number of fields
*
*
    tmp=EB.SystemTables.getT(1); tmp< 1 >='A'; EB.SystemTables.setT(1, tmp)
    tmp=EB.SystemTables.getT(2); tmp< 1 >='A'; EB.SystemTables.setT(2, tmp)
    tmp=EB.SystemTables.getT(3); tmp< 1 >='A'; EB.SystemTables.setT(3, tmp)
    tmp=EB.SystemTables.getT(4); tmp< 1 >='A'; EB.SystemTables.setT(4, tmp)
    tmp=EB.SystemTables.getT(5); tmp< 1 >='A'; EB.SystemTables.setT(5, tmp)
    tmp=EB.SystemTables.getT(6); tmp< 1 >='A'; EB.SystemTables.setT(6, tmp)
    tmp=EB.SystemTables.getT(7); tmp< 1 >='ANY'; EB.SystemTables.setT(7, tmp)
    tmp=EB.SystemTables.getT(8); tmp< 1 >=''; EB.SystemTables.setT(8, tmp); tmp=EB.SystemTables.getT(8); tmp< 2 >='M_S'; EB.SystemTables.setT(8, tmp)
    tmp=EB.SystemTables.getT(9); tmp< 1 >='A'; EB.SystemTables.setT(9, tmp)
    tmp=EB.SystemTables.getT(10); tmp< 1 >='A'; EB.SystemTables.setT(10, tmp)
    tmp=EB.SystemTables.getT(11); tmp< 1 >='A'; EB.SystemTables.setT(11, tmp)
    tmp=EB.SystemTables.getT(12); tmp< 1 >='A'; EB.SystemTables.setT(12, tmp)
    tmp=EB.SystemTables.getT(13); tmp< 1 >=''; EB.SystemTables.setT(13, tmp); tmp=EB.SystemTables.getT(13); tmp< 2 >='EQ_NE_GT_GE_LT_LE'; EB.SystemTables.setT(13, tmp)
    tmp=EB.SystemTables.getT(14); tmp< 1 >='A'; EB.SystemTables.setT(14, tmp)
    tmp=EB.SystemTables.getT(15); tmp< 1 >='A'; EB.SystemTables.setT(15, tmp)
    tmp=EB.SystemTables.getT(16); tmp<3>="NOINPUT"; EB.SystemTables.setT(16, tmp)
    tmp=EB.SystemTables.getT(17); tmp<3>="NOINPUT"; EB.SystemTables.setT(17, tmp)
    tmp=EB.SystemTables.getT(18); tmp<3>="NOINPUT"; EB.SystemTables.setT(18, tmp)
*
    EB.SystemTables.setCheckfile(2, "DE.MESSAGE" : @FM : DE.Config.Message.MsgDescription : @FM : 'L.A')
    EB.SystemTables.setCheckfile(3, "DE.FORMAT.PRINT" : @FM : DE.Config.FormatPrint.PrtDescription : @FM : 'L.A')
    EB.SystemTables.setCheckfile(4, "DE.FORM.TYPE" : @FM : DE.Reports.FormType.TypDescription : @FM : 'L.A')
*
*========================================================================
    V$FUNCTION.VAL= EB.SystemTables.getVFunction()
    IF LEN(V$FUNCTION.VAL) > 1 THEN RETURN
*     RETURN when pgm used to get parameters only
*------------------------------------------------------------------------
    EB.Display.MatrixUpdate()
*
* Open files
    R.PARM = ""
    R.PARM = DE.Config.Parm.CacheRead("SYSTEM.STATUS", "")
*
* Setup valid conversion codes, mask characters and key words
*
    CONV = ''
    CONV<1> = 'DATE'
    CONV<-1> = 'DATE/F'
    CONV<-1> = 'DATE/S'
    CONV<-1> = 'DATE//US'
    CONV<-1> = 'DATE/F/US'
    CONV<-1> = 'DATE/S/US'
    CONV<-1> = 'COPY'
    CONV<-1> = 'WORDS'
    CONV<-1> = 'DUP'
    CONV<-1> = 'DUPLICATE'
    CONV<-1> = 'UPCASE'
    CONV<-1> = 'DOWNCASE'
    CONV<-1> = 'TITLECASE'
    CONV<-1> = 'SENTENCECASE'
    CONV<-1> = 'TRIMB'
    CONV<-1> = 'TRIMF'
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
*
    TEXT.COUNT = 1
    DATA.COUNT = 1
*-----------------------------------------------------------------------
ID.INPUT:
    EB.TransactionControl.RecordidInput()
    IF EB.SystemTables.getMessage() = "RET" THEN RETURN
*     return to PGM.SELECTION
    IF EB.SystemTables.getMessage() = "NEW FUNCTION" THEN
*=======================================================================
REM "CHECK FUNCTION:
        IF EB.SystemTables.getVFunction() = "V" THEN
            EB.SystemTables.setE("INVALID FUNCTION FOR THIS PGM")
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
        EB.SystemTables.setE('ENTER MSG-TYPE.APP-FORMAT.FORMAT.LANGUAGE')
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
        EB.SystemTables.setE('ENTER MSG-TYPE.APP-FORMAT.FORMAT.LANGUAGE')
        GOTO ID.ERROR
    END
*
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
        EB.SystemTables.setE("MESSAGE TYPE LENGTH INCORRECT")
        GOTO ID.ERROR
    END
    
*
* If application format code is not numeric, first two characters must be
* application code and then the rest must be numeric
*
    IF NOT(NUM(APP.FORMAT)) THEN
        IF APP.FORMAT[1, 2] MATCHES "FX" : @VM : "FT" : @VM : "MM" : @VM : "BD" : @VM : "LD" : @VM : "AC" : @VM : "EF" : @VM : 'LC' : @VM : 'SC' : @VM : 'DC' : @VM : 'FR' : @VM : 'FD' : @VM : 'MD' : @VM : "SL" : @VM : "CQ" : @VM : "BL" THEN          ; * EN_10000101   ; * EN_10000352
            IF NOT(NUM(APP.FORMAT[3, 4])) THEN
                EB.SystemTables.setE('INVALID APPLICATION FORMAT')
                GOTO ID.ERROR
            END
        END ELSE
            EB.SystemTables.setE('INVALID APPLICATION FORMAT')
            GOTO ID.ERROR
        END
    END ELSE
*
* Application format code must not be longer than 4 characters if all
* numeric
*
        IF LEN(APP.FORMAT) > 4 THEN
            EB.SystemTables.setE("APPLICATION FORMAT CODE LENGTH INCORRECT")
            GOTO ID.ERROR
        END
    END
*
* Format code must be numeric
*
    IF NOT(NUM(FORMAT)) THEN
        EB.SystemTables.setE("FORMAT CODE MUST BE NUMERIC")
        GOTO ID.ERROR
    END
*
* Format code must not be longer than 4 characters
*
    IF LEN(FORMAT) > 4 THEN
        EB.SystemTables.setE("FORMAT CODE LENGTH INCORRECT")
        GOTO ID.ERROR
    END
*
* Language code must be alpha
*
    IF NUM(LANG) THEN
        EB.SystemTables.setE("LANGUAGE CODE MUST BE ALPHA")
        GOTO ID.ERROR
    END
*
* Check message type exists on message file
*
    ENRIX = '' ; ENRIMSG = ''
    R.REC = ''
    ER = ''
    LNGG.POS = EB.SystemTables.getLngg()
    R.REC = DE.Config.Message.Read(MSG.TYPE, ER)
    EB.SystemTables.setEtext(ER)
    ENRIMSG = R.REC<DE.Config.Message.MsgDescription,LNGG.POS>
    IF NOT(ENRIMSG) THEN
        ENRIMSG = R.REC<DE.Config.Message.MsgDescription,1>
    END
    IF EB.SystemTables.getEtext()<> '' THEN
        EB.SystemTables.setE(EB.SystemTables.getEtext())
        GOTO ID.ERROR
    END
*
* Get message record from message file
    R.REC = ''
    ER = ''
    MAT R.MSG = ''
    R.REC = DE.Config.Message.Read(MSG.TYPE, ER)
    MATPARSE R.MSG FROM R.REC
*
* Check language code exists on language file
*
    LOCATE LANG IN EB.SystemTables.getTLanguage()< 1 > SETTING IND
    ELSE EB.SystemTables.setE('INVALID LANGUAGE CODE'); GOTO ID.ERROR
    R.REC = ''
    ER = ''
    R.REC = EB.SystemTables.Language.Read(IND, ER)
    LNGG.POS = EB.SystemTables.getLngg()
    ENRIX = R.REC<EB.SystemTables.Language.LanDescription,LNGG.POS>
    IF NOT(ENRIX) THEN
        ENRIX = R.REC<EB.SystemTables.Language.LanDescription,1>
    END
    R.REC = ''
    ER = ''
    LNGG.POS = EB.SystemTables.getLngg()
    IND = EB.SystemTables.Language.Read(R.REC, ER)
    EB.SystemTables.setEtext(ER)
    ENRIX = R.REC<EB.SystemTables.Language.LanDescription,LNGG.POS>
    IF NOT(ENRIMSG) THEN
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
                EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpFormType)
                IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFormType) THEN
                    R.REC = ''
                    ER = ''
                    FORM.ID = EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFormType)
                    R.REC = DE.Reports.FormType.Read(FORM.ID, ER)
                    MATPARSE R.TYPE FROM R.REC
                    IF ER THEN
                        EB.SystemTables.setEtext('FORM TYPE NOT ON FILE')
                        EB.ErrorProcessing.StoreEndError()
                    END
                END ELSE
                    R.REC = ''
                    ER = ''
                    FORM.ID = 'DEFAULT'
                    R.REC = DE.Reports.FormType.Read(FORM.ID, ER)
                    MATPARSE R.TYPE FROM R.REC
                    IF ER THEN
                        EB.SystemTables.setEtext('DEFAULT FORM TYPE NOT ON FILE')
                        EB.ErrorProcessing.StoreEndError()
                    END
                END
*
                TEXT.COUNT = 1
                DATA.COUNT = 1
*
                MAX.VALUES = COUNT(EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName), @VM) + 1
                FOR AV1 = 1 TO MAX.VALUES
                    AV = AV1
*
* Check that conversion, masking and calculation are not entered if
* field is text or a printer attribute
*
                    IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)<1,AV1> = '' THEN
                        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpConversion)< 1, AV1 > AND EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpConversion)< 1, AV1 > <> 'COPY' AND EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpConversion)< 1, AV1 > [1, 3] <> 'DUP' THEN
                            EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpConversion)
                            EB.SystemTables.setEtext('CONVERSION INVALID FOR TEXT')
                            EB.ErrorProcessing.StoreEndError()
                        END
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpMask)< 1, AV1 > THEN
                            EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpMask)
                            EB.SystemTables.setEtext('MASKING INVALID FOR TEXT')
                            EB.ErrorProcessing.StoreEndError()
                        END
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpCalculation)< 1, AV1 > THEN
                            EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpCalculation)
                            EB.SystemTables.setEtext('CALCULATION INVALID FOR TEXT')
                            EB.ErrorProcessing.StoreEndError()
                        END
*
                    END ELSE
*
* If a field name has been entered, check that it exists on the message
* file, or in the formatted message file (R.NEW) or is a keyword
*
**                     LOCATE R.NEW(DE.TMP.FIELD.NAME) < 1, AV > IN R.MSG(DE.MSG.FIELD.NAME) < 1, 1 > SETTING IND ELSE
                        LOC.FIELD.NAME = EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)<1,AV1>
                        GOSUB LOCATE.FIELD.NAME
                        IF NOT(LOC.POS) THEN
                            LOCATE EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)< 1, AV1 > IN KEY.WORDS < 1 > SETTING IND ELSE
                                IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)< 1, AV1 > [1, 6] <> 'TOTAL.' THEN
                                    LOCATE EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)<1,AV1> IN EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDataName)<1,1> SETTING IND ELSE IND = 999
                                    IF IND GE AV1 THEN
*
                                        EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpFieldName)
                                        EB.SystemTables.setEtext('FIELD NAME OR KEYWORD MISSING')
                                        EB.ErrorProcessing.StoreEndError()
                                    END
                                END
                            END
                        END
*
* If conversion is 'WORDS', masking is invalid
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpMask)< 1, AV1 > THEN
                            IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpConversion)< 1, AV1 > = 'WORDS' THEN
                                EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpMask)
                                EB.SystemTables.setEtext('MASKING INVALID WITH WORDS CONV.')
                                EB.ErrorProcessing.StoreEndError()
                            END
*
* If conversion is 'WORDSCCY*xxx', masking is invalid
*
                            IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpConversion)< 1, AV1 >[1,8] = 'WORDSCCY' THEN
                                EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpMask)
                                EB.SystemTables.setEtext('MASKING INVALID WITH WORDSCCY*xxx CONV.')
                                EB.ErrorProcessing.StoreEndError()
                            END
                        END

*
* If field is TOTAL.n, conversion is not allowed
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpConversion)< 1, AV1 > AND EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)< 1, AV1 > [1, 6] = 'TOTAL.' AND EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpConversion)<1,AV1>[1,3] NE "CCY" THEN
                            EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpConversion)
                            EB.SystemTables.setEtext('CONVERSION NOT ALLOWED FOR TOTAL.n')
                            EB.ErrorProcessing.StoreEndError()
                        END
*
* If mask is in the format 000/00/000, check that the number of spaces is
* equal to the field length from the message file
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpMask)< 1, AV1 > THEN
                            MAX = COUNT(EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpMask)< 1, AV1 > , " " )
                            IF MAX = 0 THEN
                                LOCATE EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpMask)< 1, AV1 > [1, 1] IN MASK.CHARS < 1 > SETTING IND ELSE
**                              LOCATE R.NEW(DE.TMP.FIELD.NAME) < 1, AV > IN R.MSG(DE.MSG.FIELD.NAME) < 1, 1 > SETTING IND ELSE IND = 0
                                    LOC.FIELD.NAME = EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)<1, AV1 >
                                    GOSUB LOCATE.FIELD.NAME
                                    IF LOC.POS THEN
                                        FIELD.LENGTH = COUNT(EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpMask)< 1, AV1 > , "0" )
                                        IF FIELD.LENGTH <> R.MSG(DE.Config.Message.MsgLength) < 1, LOC.POS > THEN
                                            EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpMask)
                                            EB.SystemTables.setEtext("INVALID MASK LENGTH")
                                            EB.ErrorProcessing.StoreEndError()
                                        END
                                    END
                                END
                            END
                        END
                    END
*
* If calculation is entered, check that the field is numeric on the
* message file
*
                    IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpCalculation)< 1, AV1 > THEN
**                     LOCATE R.NEW(DE.TMP.FIELD.NAME) < 1, AV > IN R.MSG(DE.MSG.FIELD.NAME) < 1, 1 > SETTING IND ELSE IND = 0
                        LOC.FIELD.NAME = EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)< 1, AV1 >
                        GOSUB LOCATE.FIELD.NAME
                        IF LOC.POS THEN
                            IF R.MSG(DE.Config.Message.MsgPrintType) < 1, LOC.POS > <> 'N' THEN
                                EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpCalculation)
                                EB.SystemTables.setEtext('FIELD MUST BE NUMERIC')
                                EB.ErrorProcessing.StoreEndError()
                            END
                        END
                    END
*
* Zero only valid for total fields
*
                    IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpCalculation)< 1, AV1 > = 'ZERO' THEN
                        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)< 1, AV1 > [1, 6] <> 'TOTAL.' THEN
                            EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpCalculation)
                            EB.SystemTables.setEtext('ZERO ONLY VALID FOR TOTAL FIELDS')
                            EB.ErrorProcessing.StoreEndError()
                        END
                    END
*
* If conversion is 'WORDS', calculation must be blank
*
                    IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpCalculation)< 1, AV1 > THEN
                        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpConversion)< 1, AV1 > = 'WORDS' THEN
                            EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpCalculation)
                            EB.SystemTables.setEtext('CALC. INVALID WITH WORDS CONVERSION')
                            EB.ErrorProcessing.StoreEndError()
                        END
*
* If conversion is 'WORDSCCY*xxx', calculation is invalid
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpConversion)< 1, AV1 >[1,8] = 'WORDSCCY' THEN
                            EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpCalculation)
                            EB.SystemTables.setEtext('CALC. INVALID WITH WORDSCCY*xxx CONVERSION')
                            EB.ErrorProcessing.StoreEndError()
                        END
                    END
*
* If dependent upon operand is specified, dependent upon field must be
* present
*
                    IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDependOperand)< 1, AV1 > THEN
                        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDependentOn)< 1, AV1 > = '' THEN
                            EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpDependOperand)
                            EB.SystemTables.setEtext('DEPENDENT ON MUST BE PRESENT')
                            EB.ErrorProcessing.StoreEndError()
                        END
                    END
*
* If dependent upon condition is specifed, dependent upon field and
* dependent upon operand must be present
*
                    IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDependCond)< 1, AV1 > THEN
                        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDependentOn)< 1, AV1 > = '' THEN
                            EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpDependCond)
                            EB.SystemTables.setEtext('DEPENDENT ON MUST BE PRESENT')
                            EB.ErrorProcessing.StoreEndError()
                        END ELSE
                            IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDependOperand)< 1, AV1 > = '' THEN
                                EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpDependCond)
                                EB.SystemTables.setEtext('DEPENDENT ON OPERAND MUST BE PRESENT')
                                EB.ErrorProcessing.StoreEndError()
                            END
                        END
                    END
*
* If dependent on has been entered, check that the field exists in
* field/text if dependent on begins "*", otherwise dependent on must
* exist on the message file or be 'TOTAL.n'
*
                    IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDependentOn)< 1, AV1 > THEN
                        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDependentOn)< 1, AV1 > MATCHES "'TOTAL.'1N" ELSE
                            IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDependentOn)< 1, AV1 > [1, 1] = "*" THEN
                                LOCATE EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDependentOn)< 1, AV1 > [2, 99] IN EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)< 1, 1 > SETTING IND ELSE
                                    EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpDependentOn)
                                    EB.SystemTables.setEtext('FIELD NAME NOT IN FORMAT')
                                    EB.ErrorProcessing.StoreEndError()
                                END
                            END ELSE
**                           LOCATE R.NEW(DE.TMP.DEPENDENT.ON) < 1, AV > IN R.MSG(DE.MSG.FIELD.NAME) < 1, 1 > SETTING IND ELSE
                                LOC.FIELD.NAME = EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDependentOn)< 1, AV1 >
                                GOSUB LOCATE.FIELD.NAME
                                IF NOT(LOC.POS) THEN
                                    EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpDependentOn)
                                    EB.SystemTables.setEtext('FIELD NAME NOT ON MESSAGE FILE')
                                    EB.ErrorProcessing.StoreEndError()
                                END
                            END
                        END
                    END
*
* If data name has been entered, check that it is not duplicated
*
                    IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDataName)<1,AV1> THEN
*
                        LOCATE EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDataName)<1,AV1> IN EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDataName)<1,1> SETTING POS THEN
                            IF POS < AV1 THEN
                                EB.SystemTables.setAf(DE.Config.FormatTemplate.TmpDataName)
                                EB.SystemTables.setEtext('DUPLICATE DATA NAME')
                                EB.ErrorProcessing.StoreEndError()
                            END
                        END
                    END ELSE
*
* If data name is null, default it
*
                        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)<1,AV1> THEN
*
* Field name entered - default data name to the field name if this has
* not already been used; otherwise default to DATAnn
*
                            LOCATE EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)<1,AV1> IN EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDataName)<1,1> SETTING POS ELSE tmp=EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDataName); tmp<1,AV1>=EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)<1,AV1>; EB.SystemTables.setRNew(DE.Config.FormatTemplate.TmpDataName, tmp)
                            IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDataName)<1,AV1> = '' THEN
                                LOOP
                                    TEMP.DATA.NAME = 'FIELD':DATA.COUNT
                                    LOCATE TEMP.DATA.NAME IN EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDataName)<1,1> SETTING POS ELSE POS = ''
                                WHILE POS
                                    DATA.COUNT += 1
                                REPEAT
                                tmp=EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDataName); tmp<1,AV1>=TEMP.DATA.NAME; EB.SystemTables.setRNew(DE.Config.FormatTemplate.TmpDataName, tmp)
                            END
                        END ELSE
*
* Text entered - default data name to TEXTnn
*
                            LOOP
                                TEMP.DATA.NAME = 'TEXT':TEXT.COUNT
                                LOCATE TEMP.DATA.NAME IN EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDataName)<1,1> SETTING POS ELSE POS = ''
                            WHILE POS
                                TEXT.COUNT += 1
                            REPEAT
                            tmp=EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDataName); tmp<1,AV1>=TEMP.DATA.NAME; EB.SystemTables.setRNew(DE.Config.FormatTemplate.TmpDataName, tmp)
                        END
                    END
*
                NEXT AV1
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
            RC.ID = '$':EB.SystemTables.getIdNew()
            R.REC = ''
            ER = ''
            R.REC = EB.Reports.ReportControl.ReadNau(RC.ID, ER)
            IF R.REC THEN
                EB.SystemTables.setE("Cannot authorise, UNAU REPORT.CONTROL exists")
                EB.SystemTables.setL(24)
                EB.ErrorProcessing.Err()
                EB.SystemTables.setMessage("ERROR")
                GOTO FIELD.DISPLAY.OR.INPUT         ; * Back to field display
            END
*
* Check to see if the form type or template has changed, If so and a
* $NAU record does not exist then change the corresponding report
* control record accordingly.
*
            IF (EB.SystemTables.getROld(DE.Config.FormatTemplate.TmpFormType) NE EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFormType)) OR (EB.SystemTables.getROld(DE.Config.FormatTemplate.TmpTemplate) NE EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpTemplate)) THEN
                IF EB.SystemTables.getROld(DE.Config.FormatTemplate.TmpInputter) THEN
                    R.REC = ''
                    ER = ''
                    R.REC = EB.Reports.ReportControl.ReadNau(RC.ID, ER)
                    IF ER THEN
*
                        ER = ''
                        DIM RC.REC(EB.Reports.ReportControl.RcfAuditDateTime)
                        MAT RC.REC = ''
                        ER = ''
                        R.RC.REC = ''
                        EB.Reports.ReportControlLock(RC.ID,R.RC.REC,ER,'P','')
                        MATPARSE RC.REC FROM R.RC.REC
                        IF NOT(ER) THEN
                            IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFormType) THEN
                                RC.REC(EB.Reports.ReportControl.RcfFormName) = EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFormType)
                            END ELSE
                                RC.REC(EB.Reports.ReportControl.RcfFormName) = 'DEFAULT'
                            END
                            RC.REC(EB.Reports.ReportControl.RcfTemplate) = EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpTemplate)
*
                            CURR.NUMB = RC.REC(EB.Reports.ReportControl.RcfCurrNo) + 1
                            GOSUB WRITE.RC
*
                        END
                    END
*
                END
            END
*
            GOSUB CREATE.RC.REC          ; * EN_10002211 - S/E
*
            EB.TransactionControl.AuthRecordWrite()
*
            IF LAYOUT.REQ THEN
*
* Produce sample report layout
*
                PRINT.REPLY = "DO YOU WANT A SAMPLE LAYOUT (Y/NO) "
                EB.Display.Txtinp(PRINT.REPLY,8,22,2,@FM:'Y_NO')
                PRINT.REPLY = EB.SystemTables.getComi()
                PRINT @(1, 23) : EB.Desktop.getSClearEol() :
                IF PRINT.REPLY = 'Y' THEN
                    PRINT @(19, 23) : EB.Desktop.getSClearEol() : @(19, 23) : FMT( 'PRODUCING SAMPLE REPORT LAYOUT' , '60R' ) :
                    EB.SystemTables.setInputBuffer(EB.SystemTables.getIdNew())
                    DE.API.MmTemplateLayout()
                    EB.SystemTables.setInputBuffer('')
                END
            END
            IF EB.SystemTables.getMessage() = "ERROR" THEN GOTO FIELD.DISPLAY.OR.INPUT
        CASE 1
*========================================================================
REM "DEFINE SPECIAL FIELD CHECKS:
*========================================================================
            EB.SystemTables.setE(""); EB.SystemTables.setEtext("")
            BEGIN CASE
*
* If an id is entered in MESSAGE.POPULATION, populate the fields with
* the details of the DE.MESSAGE record
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatTemplate.TmpDeMessagePopn
                    IF EB.SystemTables.getComi() THEN
                        YERROR = ''
                        COMI.VAL = EB.SystemTables.getComi()
                        R.NEW.REC = EB.SystemTables.getDynArrayFromRNew()
                        DE.Config.CopyTemplate('DE.MESSAGE',COMI.VAL,R.NEW.REC,YERROR)
                        EB.SystemTables.setDynArrayToRNew(R.NEW.REC)
                        IF YERROR THEN
                            EB.SystemTables.setE(EB.SystemTables.getEtext())
                            GOTO FIELD.ERROR
                        END
*
                        EB.Display.RebuildScreen()
*
                    END
*
* If an id is entered in DE.FORMAT.PRINT.POPULATION, populate the fields with
* the details of the DE.DE.FORMAT.PRINT record
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatTemplate.TmpPrintPopn
                    IF EB.SystemTables.getComi() THEN
                        YERROR = ''
                        COMI.VAL = EB.SystemTables.getComi()
                        R.NEW.REC = EB.SystemTables.getDynArrayFromRNew()
                        DE.Config.CopyTemplate('DE.FORMAT.PRINT',COMI.VAL,R.NEW.REC,YERROR)
                        EB.SystemTables.setDynArrayToRNew(R.NEW.REC)
                        IF YERROR THEN
                            EB.SystemTables.setE(EB.SystemTables.getEtext())
                            GOTO FIELD.ERROR
                        END
*
                        EB.Display.RebuildScreen()
*
                    END
*
* If form type is blank, pick up default form type
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatTemplate.TmpFormType
                    IF EB.SystemTables.getComi() = "" THEN
                        R.REC = '' ; ER = ''
                        LNGG.POS = EB.SystemTables.getLngg()
                        R.REC = DE.Reports.FormType.Read('DEFAULT', ER)
                        EB.SystemTables.setEtext(ER)
                        ENRIX = R.REC<DE.Reports.FormType.TypDescription,LNGG.POS>
                        IF NOT(ENRIX) THEN
                            ENRIX = R.REC<DE.Reports.FormType.TypDescription,1>
                        END
                        IF EB.SystemTables.getEtext() THEN
                            EB.SystemTables.setE('DEFAULT FORM TYPE NOT ON FILE')
                            GOTO FIELD.ERROR
                        END
                    END
*
* Validate field name - must contain a field name which exists on
* the message file or a valid key word
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatTemplate.TmpFieldName
                    GOSUB CHECK.FIELD.NAME
*
* Validate conversion code - must begin with TAB, TRANS, CUS, COPY,
* DUP, WORDS or DATE
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatTemplate.TmpConversion
                    GOSUB CHECK.CONVERSION
*
* Validate mask - must contain mask characters as defined in MASK.CHARS
* seperated by spaces
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatTemplate.TmpMask
                    GOSUB CHECK.MASK
*
* Validate calculation
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatTemplate.TmpCalculation
                    GOSUB CHECK.CALCULATION
*
* If dependent upon operand is specified, dependent upon field must be
* present
                CASE EB.SystemTables.getAf() = DE.Config.FormatTemplate.TmpDependOperand
                    IF EB.SystemTables.getComi() THEN
                        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDependentOn)< 1, EB.SystemTables.getAv() > = '' THEN
                            EB.SystemTables.setE('DEPENDENT ON MUST BE PRESENT')
                            GOTO FIELD.ERROR
                        END
                    END
*
* If dependent upon condition is specified, dependent upon field and
* dependent upon operand must be present
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatTemplate.TmpDependCond
                    IF EB.SystemTables.getComi() THEN
                        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDependentOn)< 1, EB.SystemTables.getAv() > = '' THEN
                            EB.SystemTables.setE('DEPENDENT ON MUST BE PRESENT')
                            GOTO FIELD.ERROR
                        END ELSE
                            IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDependOperand)< 1, EB.SystemTables.getAv() > = '' THEN
                                EB.SystemTables.setE('DEPENDENT ON OPERAND MUST BE PRESENT')
                                GOTO FIELD.ERROR
                            END
                        END
                    END
*
* If dependent on is entered, it must contain a field name which exists
* on the message file (ignoring the first character if it is "*") or be
* 'TOTAL.n'
*
                CASE EB.SystemTables.getAf() = DE.Config.FormatTemplate.TmpDependentOn
                    GOSUB CHECK.DEPENDENT.ON

                CASE EB.SystemTables.getAf() = DE.Config.FormatTemplate.TmpDataName
                    GOSUB CHECK.DATA.NAME

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
    R.REC = ''
    ER = ''
    R.REC = EB.Reports.ReportControl.Read(RC.ID, ER)
    IF ER THEN
        DIM RC.REC(EB.Reports.ReportControl.RcfAuditDateTime)
        MAT RC.REC = ''
        RC.REC(EB.Reports.ReportControl.RcfDesc) = EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDescription)
        RC.REC(EB.Reports.ReportControl.RcfShortDesc) = EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDescription)
*
        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFormType) THEN
            RC.REC(EB.Reports.ReportControl.RcfFormName) = EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFormType)
        END ELSE
            RC.REC(EB.Reports.ReportControl.RcfFormName) = 'DEFAULT'
        END
*
        RC.REC(EB.Reports.ReportControl.RcfTemplate) = EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpTemplate)
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
    RC.REC(EB.Reports.ReportControl.RcfInputter) = "SY_DE.FORMAT.TEMPLATE"
    RC.REC(EB.Reports.ReportControl.RcfDateTime) = EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDateTime)
    RC.REC(EB.Reports.ReportControl.RcfAuthoriser) = "SY_DE.FORMAT.TEMPLATE"       ; * CI-10000502 S/E
    RC.REC(EB.Reports.ReportControl.RcfDeptCode) =EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDeptCode)
    RC.REC(EB.Reports.ReportControl.RcfAuditorCode) =EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpAuditorCode)
    RC.REC(EB.Reports.ReportControl.RcfAuditDateTime) =EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpAuditDateTime)
    RC.REC(EB.Reports.ReportControl.RcfCoCode) = EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpCoCode)  ; * BG_100000061
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
    SS.REC = ""                        ; *Standard selection
    EB.SystemTables.setEtext(""); ER = ''
    SS.REC = EB.SystemTables.StandardSelection.Read(YFILE, ER)
    EB.SystemTables.setEtext(ER)
    IF ER THEN
        EB.SystemTables.setE("NO STANDARD SELECTION RECORD")
    END ELSE
        FIELD.NAMES = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName>:@VM:SS.REC<EB.SystemTables.StandardSelection.SslUsrFieldName>
        FIELD.NOS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo>:@VM:SS.REC<EB.SystemTables.StandardSelection.SslUsrFieldNo>
        FIELD.TYPES = SS.REC<EB.SystemTables.StandardSelection.SslSysType>:@VM:SS.REC<EB.SystemTables.StandardSelection.SslUsrType>
        FIELD.MULTI = SS.REC<EB.SystemTables.StandardSelection.SslSysSingleMult>:@VM:SS.REC<EB.SystemTables.StandardSelection.SslUsrSingleMult>
    END
RETURN
*----------------------------------------------------------------------------------------------
*** <region name= CHECK.FIELD.NAME>
*** <desc>Check for Field Name </desc>
CHECK.FIELD.NAME:
*
    IF EB.SystemTables.getComi() THEN

* Field name or keyword entered
**        LOCATE COMI IN R.MSG(DE.MSG.FIELD.NAME) < 1, 1 > SETTING IND ELSE
        LOC.FIELD.NAME = EB.SystemTables.getComi()
        GOSUB LOCATE.FIELD.NAME
        IF NOT(LOC.POS) THEN
            LOCATE EB.SystemTables.getComi() IN KEY.WORDS < 1 > SETTING IND ELSE
                BEGIN CASE
                    CASE EB.SystemTables.getComi()[1, 6] = 'TOTAL.'
                        COMI.VAL = EB.SystemTables.getComi()
                        IF NOT(NUM(COMI.VAL[7, 2])) THEN
                            EB.SystemTables.setE('INVALID KEYWORD')
                            GOTO FIELD.ERROR
                        END
                    CASE EB.SystemTables.getComi()[1, 1] = "&"

* Entry begins with & and may be a printer attribute keyword

                        IF EB.SystemTables.getComi()[1, 5] <> "&ATTI" AND EB.SystemTables.getComi()[1, 5] <> "&ATTR" THEN
                            EB.SystemTables.setE("INVALID ATTRIBUTE KEYWORD")
                            GOTO FIELD.ERROR
                        END
                        COMI.VAL = EB.SystemTables.getComi()
                        IF NOT(INDEX(COMI.VAL, "&" , 2)) THEN EB.SystemTables.setComi(EB.SystemTables.getComi() : "&")
                    CASE 1

* Check whether the field exists in the formatted message record
                        LOCATE EB.SystemTables.getComi() IN EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDataName)<1,1> SETTING IND ELSE
                            IND = 999
                        END
                        IF IND GE EB.SystemTables.getAv() THEN
                            EB.SystemTables.setE('FIELD NAME OR KEYWORD MISSING')
                            GOTO FIELD.ERROR
                        END
                END CASE
            END
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------------------------
*** <region name= CHECK.CONVERSION>
*** <desc>Check for Conversion </desc>
CHECK.CONVERSION:
    IF EB.SystemTables.getComi() THEN
*
* Conversion invalid for text fields (except "COPY and DUPLICATE")
*
        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)<1,EB.SystemTables.getAv()> = '' THEN
            IF EB.SystemTables.getComi()<> 'COPY' AND EB.SystemTables.getComi()<> 'DUP' AND EB.SystemTables.getComi()<> 'DUPLICATE' THEN
                EB.SystemTables.setE('CONVERSION INVALID FOR TEXT')
                GOTO FIELD.ERROR
            END
        END
*
* Conversion not allowed for TOTAL.n fields
*
        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)< 1, EB.SystemTables.getAv() > [1, 6] = 'TOTAL.' THEN
            IF EB.SystemTables.getComi()[1,3] NE "CCY" THEN
                EB.SystemTables.setE('CONVERSION NOT ALLOWED FOR TOTAL.n')
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
                            EB.SystemTables.setE('INVALID CONVERSION')
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
                            EB.SystemTables.setE('CUSTOMER KEYWORD INVALID')
                            GOTO FIELD.ERROR
                        END
                    END ELSE
                        EB.SystemTables.setE('CUSTOMER KEYWORD MUST BE ENTERED')
                        GOTO FIELD.ERROR
                    END
*
                CASE EB.SystemTables.getComi()[1,4] MATCHES "LINK"
                    IF R.PARM<DE.Config.Parm.ParInstallation> NE "R" THEN
                        EB.SystemTables.setE("INVALID CONVERSION, FILES NOT RESIDENT")
                    END ELSE
                        COMI.VAL = EB.SystemTables.getComi()
                        YFILE = FIELD(COMI.VAL,"*",2)[">",1,1]
                        FIELD.SPEC = EB.SystemTables.getComi()[">",2,99]   ;* Field def
                        YTYPE = ""
                        R.REC = '' ; ER = ''
                        R.REC = EB.SystemTables.PgmFile.Read(YFILE, ER)
                        EB.SystemTables.setEtext(ER)
                        YTYPE = R.REC<EB.SystemTables.PgmFile.PgmType>
                        IF EB.SystemTables.getEtext() OR NOT(INDEX("HULWT",YTYPE,1)) THEN
                            EB.SystemTables.setE("INVALID FILE NAME/TYPE")
                        END ELSE
                            GOSUB GET.LINK.FILE
*
** Get the field name and validate it. If a number is entered
** get the corresponding name.
*
                            FM.NO = FIELD.SPEC[">",1,1]
                            IF FM.NO MATCHES "1N0N" THEN        ;* Enrich
                                LOCATE FM.NO IN FIELD.NOS<1,1> SETTING POS THEN
                                    FIELD.NAME = FIELD.NAMES<1,POS>
                                END ELSE
                                    EB.SystemTables.setE("INVALID FIELD NUMBER")
                                END
                            END ELSE
                                LOCATE FM.NO IN FIELD.NAMES<1,1> SETTING POS THEN
                                    FM.NO = FIELD.NOS<1,POS>
                                    FIELD.NAME = FIELD.NAMES<1,POS>
                                END ELSE
                                    EB.SystemTables.setE("INVALID FIELD NAME")
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
                                    CASE NOT(INDEX("DI",FIELD.TYPES<1,POS>,1))          ;* Invalid type
                                        EB.SystemTables.setE("INVALID FIELD TYPE")
                                    CASE FIELD.MULTI<1,POS> = "S" AND VM.NO:SM.NO
                                        EB.SystemTables.setE("FIELD IS ONLY SINGLE VALUED")
                                    CASE NOT(VM.NO MATCHES "1N0N":@VM:"L":@VM:"")
                                        EB.SystemTables.setE("INVALID MULTI FIELD DEFINEITION")
                                    CASE NOT(SM.NO MATCHES "1N0N":@VM:"L":@VM:"")
                                        EB.SystemTables.setE("INVALID SUB FIELD DEFINTION")
                                    CASE OTHER.BIT
                                        EB.SystemTables.setE("INVALID FIELD SPEC")
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
*
                CASE EB.SystemTables.getComi()[1,8] = "WORDSCCY" ;* Translate an amount into words according to the language and currency
                    WORDSCCY.FLD = EB.SystemTables.getComi()["*",2,1]

                    BEGIN CASE
                        CASE WORDSCCY.FLD = ""
                            EB.SystemTables.setE("MUST BE 'WORDSCCY*currency location")
                            GOTO FIELD.ERROR
                        CASE 1
**                    LOCATE WORDSCCY.FLD IN R.MSG(DE.MSG.FIELD.NAME)<1,1> SETTING YY THEN YY = "OK! CCY exist" ELSE
                            LOC.FIELD.NAME = WORDSCCY.FLD
                            GOSUB LOCATE.FIELD.NAME
                            IF NOT(LOC.POS) THEN
                                EB.SystemTables.setE("INVALID FIELD FOR MESSAGE")
                                GOTO FIELD.ERROR
                            END
                    END CASE
*
*
                CASE EB.SystemTables.getComi()[1,3] = "CCY"      ;* Format according to CCY
                    CCY.FLD = EB.SystemTables.getComi()["*",2,1]
                    BEGIN CASE
                        CASE CCY.FLD = ""
                            EB.SystemTables.setE("MUST BE 'CCY*currency location")
                            GOTO FIELD.ERROR
                        CASE 1        ;* Must be single valued
**                    LOCATE CCY.FLD IN R.MSG(DE.MSG.FIELD.NAME)<1,1> SETTING YY THEN
                            LOC.FIELD.NAME = CCY.FLD
                            GOSUB LOCATE.FIELD.NAME
                            IF LOC.POS THEN
                                IF R.MSG(DE.Config.Message.MsgSingleMulti)<1,LOC.POS> = "M" OR 'ML' OR 'VL' OR 'V' THEN
                                    EB.SystemTables.setE("NOT ALLOWED FOR MULTI VALUE FIELD")
                                    GOTO FIELD.ERROR
                                END
                            END ELSE
                                EB.SystemTables.setE("INVALID FIELD FOR MESSAGE")
                                GOTO FIELD.ERROR
                            END
                    END CASE
*
                CASE EB.SystemTables.getComi()[1,3] = 'FIX'      ;* Euro conversions
                    COMI.VAL = EB.SystemTables.getComi()
                    IF NOT(COMI.VAL[4,3] MATCHES 'CCY':@VM:'RTE':@VM:'EQU') THEN
                        EB.SystemTables.setE('INVALID CONVERSION')
                    END ELSE
                        CCY.FLD = EB.SystemTables.getComi()['*',2,1]
                        BEGIN CASE
                            CASE CCY.FLD = ""
                                EB.SystemTables.setE("MUST BE 'FIXaaa*currency location")
                                GOTO FIELD.ERROR
                            CASE 1    ;* Must be single valued
**                        LOCATE CCY.FLD IN R.MSG(DE.MSG.FIELD.NAME)<1,1> SETTING YY ELSE
                                LOC.FIELD.NAME = CCY.FLD
                                GOSUB LOCATE.FIELD.NAME
                                IF NOT(LOC.POS) THEN
                                    EB.SystemTables.setE("INVALID FIELD FOR MESSAGE")
                                    GOTO FIELD.ERROR
                                END
                        END CASE
                    END
*
                CASE EB.SystemTables.getComi()[1,1] = '@'        ;* GB0001630 - Customers own conversions
                    COMI.VAL = EB.SystemTables.getComi()
                    ROUTINE.ID = EB.SystemTables.getComi()[2,LEN(COMI.VAL)-1]
                    ROUTINE.TYPE = ""
                    R.REC = '' ; ER = ''
                    R.REC = EB.SystemTables.PgmFile.Read(ROUTINE.ID, ER)
                    EB.SystemTables.setEtext(ER)
                    ROUTINE.TYPE = R.REC<EB.SystemTables.PgmFile.PgmType>
                    IF EB.SystemTables.getEtext() OR (ROUTINE.TYPE <> "S") THEN
                        EB.SystemTables.setE("INVALID ROUTINE - MUST BE PGM.FILE TYPE 'S'")
                        GOTO FIELD.ERROR
                    END

                CASE 1
                    EB.SystemTables.setE('INVALID CONVERSION'); GOTO FIELD.ERROR
            END CASE
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------------------------
*** <region name= CHECK.MASK>
*** <desc>Check for Mask </desc>
CHECK.MASK:

    IF EB.SystemTables.getComi() THEN
*
* Masking invalid for text fields
*
        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)<1,EB.SystemTables.getAv()> = '' THEN
            EB.SystemTables.setE('MASKING INVALID FOR TEXT')
            GOTO FIELD.ERROR
        END
*
* If conversion is 'WORDS', masking is invalid
*
        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpConversion)< 1, EB.SystemTables.getAv() > = 'WORDS' THEN
            EB.SystemTables.setE('MASKING INVALID WITH WORDS CONV.')
            GOTO FIELD.ERROR
        END
*
* GB9500381 - start
*
* If conversion is 'WORDSCCY*xxx', masking is invalid
*
        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpConversion)< 1, EB.SystemTables.getAv() >[1,8] = 'WORDSCCY' THEN
            EB.SystemTables.setE('MASKING INVALID WITH WORDSCCY CONV.')
            GOTO FIELD.ERROR
        END
*
*
        FILL.CHARS = 0
        NEGATIVE = 0
        T.DOUBLE = ''
*
* First and last characters must not be a space
*
        COMI.VAL = EB.SystemTables.getComi()
        IF EB.SystemTables.getComi()[LEN(COMI.VAL), 1] = ' ' OR EB.SystemTables.getComi()[1, 1] = ' ' THEN
            EB.SystemTables.setE('INVALID NUMBER OF DELIMITERS')
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
**                    LOCATE R.NEW(DE.TMP.FIELD.NAME) < 1, AV > IN R.MSG(DE.MSG.FIELD.NAME) < 1, 1 > SETTING IND THEN
                    LOC.FIELD.NAME = EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)< 1, EB.SystemTables.getAv() >
                    GOSUB LOCATE.FIELD.NAME
                    IF LOC.POS THEN
                        FIELD.LENGTH = COUNT(COMI.VAL, "0" )
                        IF FIELD.LENGTH <> R.MSG(DE.Config.Message.MsgLength) < 1, LOC.POS > THEN
                            EB.SystemTables.setE("INVALID MASK.LENGTH")
                            GOTO FIELD.ERROR
                        END
                    END
                    GOTO CHECK.NEXT.PORTION
                END ELSE EB.SystemTables.setE('NOT ON INPUT TABLE'); GOTO FIELD.ERROR
            END
*
* Fill characters specified
*
            IF MASK[2, 2] <> '' THEN
*
* Fill characters must not already have been specified
*
                IF FILL.CHARS THEN
                    EB.SystemTables.setE('FILL CHARACTERS ENTERED MORE THAN ONCE')
                    GOTO FIELD.ERROR
                END
                FILL.CHARS = 1
*
* Fill length must be numeric
*
                IF NOT(NUM(MASK[2, 4])) OR MASK[2, 4] = 0 THEN
                    EB.SystemTables.setE('FILL LENGTH INVALID')
                    GOTO FIELD.ERROR
                END
            END ELSE
*
* Mask character must not already have been entered
*
                LOCATE MASK IN T.DOUBLE < 1 > SETTING IND THEN
                    EB.SystemTables.setE('MASK CHARACTERS DUPLICATED')
                END
                IF T.DOUBLE THEN IND = COUNT(T.DOUBLE, @FM) + 2 ELSE IND = 1
                T.DOUBLE < IND > = MASK
*
* If mask character is a negative character (-, A, C or D), a negative
* character must not previously have been entered
*
                IF MASK = 'C' OR MASK = 'D' OR MASK = '-' OR MASK = 'A' THEN
                    IF NEGATIVE THEN
                        EB.SystemTables.setE('INVALID COMBINATION OF MASK CHARACTERS')
                        GOTO FIELD.ERROR
                    END
                    NEGATIVE = 1
                END
            END
CHECK.NEXT.PORTION:
        NEXT X
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------------------------
*** <region name= CHECK.CALCULATION>
*** <desc>Check for Calculation </desc>
CHECK.CALCULATION:
    IF EB.SystemTables.getComi() THEN
*
* Field on message file must be numeric
*
**        LOCATE R.NEW(DE.TMP.FIELD.NAME) < 1, AV > IN R.MSG(DE.MSG.FIELD.NAME) < 1, 1 > SETTING IND THEN
        LOC.FIELD.NAME = EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)< 1, EB.SystemTables.getAv() >
        GOSUB LOCATE.FIELD.NAME
        IF LOC.POS THEN
            IF R.MSG(DE.Config.Message.MsgPrintType) < 1, LOC.POS > <> 'N' THEN
                EB.SystemTables.setE('FIELD MUST BE NUMERIC')
                GOTO FIELD.ERROR
            END
        END
*
* If conversion is 'WORDS', calculation must be blank
*
        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpConversion)< 1, EB.SystemTables.getAv() > = 'WORDS' THEN
            EB.SystemTables.setE('CALC. INVALID WITH WORDS CONVERSION')
            GOTO FIELD.ERROR
        END
*
* If conversion is 'WORDSCCY', calculation must be blank
*
        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpConversion)< 1, EB.SystemTables.getAv() >[1,8] = 'WORDSCCY' THEN
            EB.SystemTables.setE('CALC. INVALID WITH WORDSCCY CONVERSION')
            GOTO FIELD.ERROR
        END
*
        BEGIN CASE
            CASE EB.SystemTables.getComi()[3, 5] = 'TOTAL'
*
* Total only allowed for fields or keyword of total
*
                IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)<1,EB.SystemTables.getAv()> = '' THEN
                    EB.SystemTables.setE('TOTAL INVALID FOR TEXT')
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
                        EB.SystemTables.setE('INVALID TOTAL FORMAT')
                        GOTO FIELD.ERROR
                        COMI.VAL = EB.SystemTables.getComi()
                        POS1 = INDEX(COMI.VAL, "." , 1)
                        IF POS1 > 0 THEN
                            IF EB.SystemTables.getComi()[POS1 + 1, 2] < 1 THEN
                                EB.SystemTables.setE('INVALID FIELD NUMBER (1-9)')
                                GOTO FIELD.ERROR
                            END
                        END
                END CASE
            CASE EB.SystemTables.getComi() = 'ZERO'
*
* If calculation is ZERO, field name must be TOTAL.n
*
                IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)< 1, EB.SystemTables.getAv() > [1, 6] <> 'TOTAL.' THEN
                    EB.SystemTables.setE('ZERO ONLY VALID FOR TOTAL FIELDS')
                    GOTO FIELD.ERROR
                END
                NULL
            CASE 1
                EB.SystemTables.setE('INVALID CALCULATION PARAMETER')
                GOTO FIELD.ERROR
        END CASE
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------------------------
*** <region name= CHECK.DEPENDENT.ON>
*** <desc>Check for Dependent field </desc>
CHECK.DEPENDENT.ON:

    IF EB.SystemTables.getComi() THEN
        IF EB.SystemTables.getComi()[1, 1] = '*' THEN LOC.FIELD.NAME = EB.SystemTables.getComi()[2, 99]
        ELSE LOC.FIELD.NAME = EB.SystemTables.getComi()
        GOSUB LOCATE.FIELD.NAME
        IF NOT(LOC.POS) THEN
**         LOCATE YCOMI IN R.MSG(DE.MSG.FIELD.NAME) < 1, 1 > SETTING IND ELSE
            IF LOC.FIELD.NAME MATCHES "'TOTAL.'1N" THEN NULL ELSE
                EB.SystemTables.setE('FIELD NAME NOT ON MESSAGE FILE')
                GOTO FIELD.ERROR
            END
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------------------------
*** <region name= CHECK.DATA.NAME>
*** <desc>Check for Duplicate Data name </desc>
CHECK.DATA.NAME:
* If data name has been entered, check that it is not duplicated
*
    IF EB.SystemTables.getComi() THEN
*
        LOCATE EB.SystemTables.getComi() IN EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDataName)<1,1> SETTING POS THEN
            IF POS < EB.SystemTables.getAv() THEN
                EB.SystemTables.setE('DUPLICATE DATA NAME')
                GOTO FIELD.ERROR
            END
        END
    END ELSE
*
* If data name is null, default it
*
        IF EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)<1,EB.SystemTables.getAv()> THEN
*
* Field name entered - default data name to the field name if this has
* not already been used; otherwise default to DATAnn
*
            LOCATE EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)<1,EB.SystemTables.getAv()> IN EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDataName)<1,1> SETTING POS ELSE EB.SystemTables.setComi(EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpFieldName)<1,EB.SystemTables.getAv()>)
            IF EB.SystemTables.getComi() = '' THEN
                LOOP
                    TEMP.DATA.NAME = 'FIELD':DATA.COUNT
                    LOCATE TEMP.DATA.NAME IN EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDataName)<1,1> SETTING POS ELSE POS = ''
                WHILE POS
                    DATA.COUNT += 1
                REPEAT
                EB.SystemTables.setComi(TEMP.DATA.NAME)
            END
        END ELSE
*
* Text entered - default data name to TEXTnn
*
            LOOP
                TEMP.DATA.NAME = 'TEXT':TEXT.COUNT
                LOCATE TEMP.DATA.NAME IN EB.SystemTables.getRNew(DE.Config.FormatTemplate.TmpDataName)<1,1> SETTING POS ELSE POS = ''
            WHILE POS
                TEXT.COUNT += 1
            REPEAT
            EB.SystemTables.setComi(TEMP.DATA.NAME)
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------------------------
*** <region name= LOCATE.FIELD.NAME>
*** <desc> </desc>
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

*** </region>
*---------------------------------------------------------------------------------------------

END
