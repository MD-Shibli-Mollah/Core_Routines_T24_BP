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

* Version 5 07/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>6</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.SystemTables
    SUBROUTINE CONVERT.HELPTEXT
*=======================================================================
* Routine to convert helptext into ONE file F.HELPTEXT.
*
* Conversion of F.HELPTEXT.APPLICATION & F.HELPTEXT.FIELD
*
*=======================================================================
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.HELPTEXT.APPLICATION
    $INSERT I_F.HELPTEXT.FIELD
    $INSERT I_F.HELPTEXT.FUNCTION
    $INSERT I_F.HELPTEXT
    $INSERT I_F.HELPTEXT.TITLE
    $INSERT I_F.STANDARD.SELECTION
    $INSERT I_DAS.COMMON      ;* EN_10003192 S
    $INSERT I_DAS.HELPTEXT.APPLICATION
    $INSERT I_DAS.HELPTEXT.FIELD
    $INSERT I_DAS.HELPTEXT.FUNCTION     ;* EN_10003192 E
*=======================================================================
*             MAIN PROCEDURE
*=======================================================================
*
    GOSUB INITIALISATION
    GOSUB CONVERT.APPLICATION
    GOSUB CONVERT.FIELD
    GOSUB CONVERT.FUNCTION
*       CALL BUILD.HELP.INDEX              ; * And build index
*
    RETURN
*=======================================================================
INITIALISATION:
*
    CALL OPF("F.HELPTEXT.FIELD",F.HELPTEXT.FIELD)
    CALL OPF("F.HELPTEXT.FUNCTION",F.HELPTEXT.FUNCTION)
    CALL OPF("F.HELPTEXT.APPLICATION",F.HELPTEXT.APPLICATION)
    CALL OPF("F.HELPTEXT",F.HELPTEXT)
    CALL OPF("F.HELPTEXT.TITLE",F.HELPTEXT.TITLE)
    CALL OPF("F.STANDARD.SELECTION",F.STANDARD.SELECTION)
*
    END.SENTENCE = " ": @VM: @FM
    CONTROL.CHARACTERS = ""
    FOR I = 1 TO 31
        CONTROL.CHARACTERS := CHARX(I)
    NEXT I
*
    VALID.FUNCTIONS = "A C D H I P Q R S V"
    CONVERT " " TO @FM IN VALID.FUNCTIONS
*
    HLP.SEP = "*"   ;* Use in the key topic*subtopic-GB
*
    VRULE.TYPES = "(I0X)0X (V0X)0X ('X'0X)0X I0X)0X V0X)0X 'X'0X)0X"
    CONVERT " " TO @VM IN VRULE.TYPES
*
    RETURN
*=======================================================================
CONVERT.APPLICATION:
*
    CALL DISPLAY.MESSAGE("Converting application helptext",3)
    THE.LIST = dasAllIds
    THE.ARGS=""
    TABLE.SUFFIX=""
    CALL DAS("HELPTEXT.APPLICATION",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    ID.LIST = THE.LIST
    TOTAL.SELECTED = DCOUNT(ID.LIST,FM)
*
    CNT = 0
    LOOP REMOVE ID FROM ID.LIST SETTING D WHILE ID:D
        CNT +=1
        MSG = FMT(CNT:" of ":TOTAL.SELECTED,"15R")
        CALL DISPLAY.MESSAGE(MSG,2)
        READ R.HELPTEXT.APPLICATION FROM F.HELPTEXT.APPLICATION, ID THEN
            GOSUB BUILD.APPLICATION.HELPTEXT
            WRITE R.HELPTEXT TO F.HELPTEXT, NEW.ID
            WRITE R.HELPTEXT.TITLE TO F.HELPTEXT.TITLE, NEW.ID
        END
    REPEAT
*
    RETURN
*=======================================================================
BUILD.APPLICATION.HELPTEXT:
* Convert from F.HELPTEXT.APPLICATION
*
    CONVERT CONTROL.CHARACTERS TO "" IN ID
    CONVERT CONTROL.CHARACTERS TO "" IN R.HELPTEXT.APPLICATION
    DOTS = DCOUNT(ID,".")
    APP = ID[".",1,DOTS-1]    ;* Just the application
    LNG = ID[".",DOTS,1]      ;* Just the language
*
    IF LNG THEN
        LCODE = T.LANGUAGE<LNG>         ;* FR, GB etc
    END ELSE
        LCODE = "GB"          ;* Default
    END
*
    NEW.ID = APP: "-" :LCODE  ;* Application.GB
*
    TEXT = R.HELPTEXT.APPLICATION<EB.HAP.HELP.LINES>        ;* Text
    GOSUB CONVERT.EBS         ;* Change EBS to GLOBUS
    GOSUB FIND.TITLE
*
    R.HELPTEXT = ""
    R.HELPTEXT.TITLE = ""
    R.HELPTEXT.TITLE<EB.HTL.TITLE> = TITLE
    R.HELPTEXT<EB.HLP.DETAIL> = TEXT
*
    RETURN
*=======================================================================
CONVERT.FIELD:
* Convert field text
*
    CALL DISPLAY.MESSAGE("Converting field helptext",3)
    THE.LIST = dasHelptextField$SORT    ;*EN_10003192 S
    EXECUTE "GET.LIST HTEMP"
    THE.ARGS=""
    TABLE.SUFFIX=""
    CALL DAS("HELPTEXT.FIELD",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    ID.LIST = THE.LIST
    TOTAL.SELECTED = DCOUNT(ID.LIST,FM) ;* EN_10003192 E
*
    CNT = 0
    LAST.APP = ""
    LOOP REMOVE ID FROM ID.LIST SETTING D WHILE ID:D
        CNT +=1
        MSG = FMT(CNT:" of ":TOTAL.SELECTED,"15R")
        CALL DISPLAY.MESSAGE(MSG,2)
        READ R.HELPTEXT.FIELD FROM F.HELPTEXT.FIELD, ID THEN
            GOSUB BUILD.FIELD.TEXT
            IF NEW.ID THEN    ;* Ok to write
                WRITE R.HELPTEXT TO F.HELPTEXT, NEW.ID
                WRITE R.HELPTEXT.TITLE TO F.HELPTEXT.TITLE, NEW.ID
            END
        END
    REPEAT
*
    RETURN
*
*=======================================================================
BUILD.FIELD.TEXT:
* Convert old field help text to new
*
    DETAIL = ""
    VRULES = ""
*
    CONVERT CONTROL.CHARACTERS TO "" IN ID
    CONVERT CONTROL.CHARACTERS TO "" IN R.HELPTEXT.FIELD
    DOTS = DCOUNT(ID,".")
    APP = ID[".",1,DOTS-2]    ;* Just the application
    FLD = ID[".",DOTS-1,1]    ;* Field number
    LNG = ID[".",DOTS,1]      ;* Just the language
    GOSUB CONVERT.FIELD.NUMBER          ;* To field name
*
    IF NUM(FLD) THEN          ;* Still numeric
        NEW.ID = "" ;* Ignore this one
        RETURN      ;* Straight back
    END
*
    LNGG.CODE = T.LANGUAGE<LNG>         ;* FR GB etc
*
    NEW.ID = APP:HLP.SEP:FLD:"-":LNGG.CODE        ;* FOREX>COUNTERPARTY-GB
*
* Now wade through the text
    STATUS.WORD = 0 ;* Flag for Summary:, Format: etc
    LAST.STATUS.WORD = 0
    VRULE.IDX = 0
*
    HELP.LINES = R.HELPTEXT.FIELD<EB.HFD.HELP.LINES>
    LOOP REMOVE LINE FROM HELP.LINES SETTING D WHILE LINE:D
        GOSUB DETERMINE.STATUS.WORD
        GOSUB FORMAT.LINE     ;* Load in DETAILS or VRULES
    REPEAT
*
    TEXT = DETAIL
    GOSUB CONVERT.EBS         ;* Change EBS to GLOBUS
    GOSUB FIND.TITLE
    R.HELPTEXT = ""
    R.HELPTEXT.TITLE = ""
    R.HELPTEXT.TITLE<EB.HTL.TITLE> = TITLE
    R.HELPTEXT<EB.HLP.DETAIL> = TEXT
*
    TEXT = VRULES
    GOSUB CONVERT.EBS
    R.HELPTEXT<EB.HLP.RULE> = TEXT
*
    RETURN
*
*=======================================================================
CONVERT.FUNCTION:
* Convert function text
*
    CALL DISPLAY.MESSAGE("Converting function helptext",3)
    THE.LIST = dasAllIds$ID   ;*EN_10003192 S
    THE.ARGS=""
    TABLE.SUFFIX=""
    CALL DAS("HELPTEXT.FUNCTION",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    ID.LIST = THE.LIST
    TOTAL.SELECTED = DCOUNT(ID.LIST,FM) ;*EN_10003192 E
*
    CNT = 0
    LAST.APP = ""
    LOOP REMOVE ID FROM ID.LIST SETTING D WHILE ID:D
        CNT +=1
        MSG = FMT(CNT:" of ":TOTAL.SELECTED,"15R")
        CALL DISPLAY.MESSAGE(MSG,2)
        READ R.HELPTEXT.FUNCTION FROM F.HELPTEXT.FUNCTION, ID THEN
            GOSUB BUILD.FUNCTION.TEXT
            IF NEW.ID THEN    ;* Ok to write
                IF ID[1,3] # "';'" THEN ;* ';' suppoted by GUI
                    LOCATE ID[1,1] IN VALID.FUNCTIONS<1> SETTING POS ELSE       ;* Highlight text based functions
                        R.HELPTEXT<EB.HLP.DETAIL,-1> = @VM:"        **** NOT AVAILABLE UNDER GUI ****"
                    END
                END
                WRITE R.HELPTEXT TO F.HELPTEXT, NEW.ID
                WRITE R.HELPTEXT.TITLE TO F.HELPTEXT.TITLE, NEW.ID
            END
        END
    REPEAT
*
    RETURN
*
*=======================================================================
BUILD.FUNCTION.TEXT:
* Convert old function help text to new
*
    DETAIL = ""
*
    CONVERT CONTROL.CHARACTERS TO "" IN ID
    CONVERT CONTROL.CHARACTERS TO "" IN R.HELPTEXT.FUNCTION
*
    CONVERT "-" TO "." IN ID  ;* Can't have imbedded -'s
    DOTS = DCOUNT(ID,".")
    FUN = ID[".",1,DOTS-1]    ;* Just the function
    LNG = ID[".",DOTS,1]      ;* Just the language
*
    LNGG.CODE = T.LANGUAGE<LNG>         ;* FR GB etc
*
    NEW.ID = "FUNCTION":HLP.SEP:FUN:"-":LNGG.CODE ;* FUNCTION>DELETE-GB
*
* Now wade through the text
    STATUS.WORD = 3 ;* Flag for Summary:, Format: etc
    LAST.STATUS.WORD = 0
    VRULE.IDX = 0
*
    HELP.LINES = R.HELPTEXT.FUNCTION<EB.HFN.HELP.LINES>
    LOOP REMOVE LINE FROM HELP.LINES SETTING D WHILE LINE:D
        GOSUB DETERMINE.STATUS.WORD
        GOSUB FORMAT.LINE     ;* Load in DETAILS or VRULES
    REPEAT
*
    TEXT = DETAIL
    GOSUB CONVERT.EBS         ;* Change EBS to GLOBUS
    GOSUB FIND.TITLE
    R.HELPTEXT = ""
    R.HELPTEXT.TITLE = ""
    R.HELPTEXT.TITLE<EB.HTL.TITLE> = TITLE
    R.HELPTEXT<EB.HLP.DETAIL> = TEXT
*
    RETURN
*
*=======================================================================
CONVERT.FIELD.NUMBER:
* Turn field number into name
*
    IF APP # LAST.APP THEN
        READ R.STANDARD.SELECTION FROM F.STANDARD.SELECTION, APP ELSE
            R.STANDARD.SELECTION = ""
        END
        LAST.APP = APP
    END
*
    IF FLD > 1 THEN FLD = FLD + 1
    LOCATE FLD IN R.STANDARD.SELECTION<SSL.SYS.FIELD.NO,2> SETTING POS THEN
        FLD = R.STANDARD.SELECTION<SSL.SYS.FIELD.NAME,POS>
        IF FLD[1,2] = "K." THEN
            FLD = FLD[3,99]   ;* Remove keyword
        END
    END
*
    RETURN
*=======================================================================
DETERMINE.STATUS.WORD:
* Are we in summary, format, details or valiation rules
*
    LINE.TYPE = UPCASE(LINE[1,20])      ;* First twenty characters should say
    CONVERT " " TO ":" IN LINE.TYPE     ;* Turn "Rules " into "Rules:"
*
    BEGIN CASE
    CASE LINE.TYPE[1,8] = "SUMMARY:"
        STATUS.WORD = 1
        LINE = LINE[9,999]
    CASE LINE.TYPE[1,7] = "FORMAT:"
        STATUS.WORD = 2
        LINE = LINE[8,999]
    CASE LINE.TYPE[1,8] = "DETAILS:"
        LINE = TRIMF(LINE[9,999])
        STATUS.WORD = 3
    CASE LINE.TYPE[1,7] = "DETAIL:"
        LINE = TRIMF(LINE[8,999])
        STATUS.WORD = 3
    CASE LINE.TYPE[1,10] = "VALIDATION"
        STATUS.WORD = 4
        LINE = ""
    CASE LINE.TYPE[1,6] = "RULES:"
        STATUS.WORD = 4
        LINE = LINE[7,999]
    CASE LINE.TYPE[1,5] = "RULE:"
        STATUS.WORD = 4
        LINE = LINE[6,999]
    CASE LINE.TYPE[1,8] = "EXAMPLE:"
*            LINE = TRIMF(LINE[10,999])
        STATUS.WORD = 3
    CASE LINE.TYPE[1,6] = "NOTES:"
*            LINE = TRIMF(LINE[7,999])
        STATUS.WORD = 3
    CASE LINE.TYPE[1,5] = "NOTE:"
*            LINE = TRIMF(LINE[6,999])
        STATUS.WORD = 3
    END CASE
*
    RETURN
*
*======================================================================
FORMAT.LINE:
* Format according to STATUS.WORD
*
    IF STATUS.WORD = 3 AND LAST.STATUS.WORD # 3 THEN
        DETAIL := @VM         ;* Separate detail from summary
    END
    LAST.STATUS.WORD = STATUS.WORD
*
    BEGIN CASE
    CASE STATUS.WORD = 1      ;* Summary
        LINE = TRIMF(TRIMB(LINE))
        IF LINE THEN
            IF DETAIL THEN
                DETAIL := @VM: LINE
            END ELSE
                DETAIL = LINE
            END
        END
    CASE STATUS.WORD = 2      ;* Format
        LINE = TRIMF(TRIMB(LINE))
        IF LINE THEN
            VRULES<1,1,-1> = LINE       ;* First validation rule
            VRULE.IDX = 1     ;* At least one now
        END
    CASE STATUS.WORD = 3      ;* Details
        DETAIL := @VM: TRIMB(LINE)
    CASE STATUS.WORD = 4      ;* Rules
        LINE = TRIMB(TRIMF(LINE))
        IF LINE THEN
            IF UPCASE(LINE[1,6]) MATCHES VRULE.TYPES THEN   ;* New rule
                VRULE.IDX +=1
                LINE = TRIMF(LINE[")",2,999])     ;* Drop (i)
            END
            VRULES<1,VRULE.IDX,-1> = LINE
        END
    END CASE
*
*=======================================================================
FIND.TITLE:
* Locate first sentence in TEXT
*
    SPOS = 1        ;* Starting position for search
    TITLE.FOUND = 0 ;* Scan for first sentence
    LOOP UNTIL TITLE.FOUND
        POS = INDEX(TEXT,".",SPOS)
        NEXT.CHAR = TEXT[POS+1,1]
        BEGIN CASE
        CASE POS = 0 OR NEXT.CHAR = ""  ;* Nowhere or end of text
            TITLE.FOUND = 1   ;* End search
            EPOS = LEN(TEXT)  ;* All of text
        CASE INDEX(END.SENTENCE, NEXT.CHAR,1)     ;* End of sentence
            EPOS = POS
            TITLE.FOUND = 1
        CASE OTHERWISE        ;* Just a dot
            SPOS +=1
        END CASE
    REPEAT
    TITLE = TEXT[1,EPOS]      ;* Title
    CONVERT @VM TO " " IN TITLE
    TITLE = TRIMF(TITLE)
*
    RETURN
*=======================================================================
CONVERT.EBS:
* Remove references to EBS and replace with GLOBUS.
*
    EBS.TEXT = " EBS "
    EBS.TEXT<2> = " E.B.S. "
    EBS.TEXT<3> = " C.O.S. "
    EBS.TEXT<4> = " COS "
*
    IDX = 0
    LOOP IDX +=1 UNTIL EBS.TEXT<IDX> = ""         ;* For each EBS text
        LOOP PEBS = INDEX(TEXT,EBS.TEXT<IDX>,1) UNTIL PEBS = 0        ;* For all occurences
            LEBS = LEN(EBS.TEXT<IDX>)   ;* How long is it now
            IF PEBS = 1 THEN
                TEXT = " GLOBUS ": TEXT[LEBS+1,LEN(TEXT)]   ;* Plug in at start
            END ELSE
                TEXT = TEXT[1,PEBS-1]: " GLOBUS ": TEXT[PEBS+LEBS,LEN(TEXT)]    ;* Plug in the middle
            END
        REPEAT
    REPEAT
*
    RETURN
*=======================================================================
END
