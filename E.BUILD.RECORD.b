* @ValidationCode : MjoyMTE5NDUxMDY3OkNwMTI1MjoxNTMzMTkyNDkyNzk2OnBzdmlqaTotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxODA4LjIwMTgwNzIxLTEwMjY6LTE6LTE=
* @ValidationInfo : Timestamp         : 02 Aug 2018 12:18:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : psviji
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201808.20180721-1026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.ModelBank
    
    SUBROUTINE E.BUILD.RECORD
*=======================================================================
* Routine to construct a GLOBUS 'See' display of an application record
* Reconstructs R.RECORD as four multivalue fields in the format
* Prompt Data Enrichment Next
* Where next is the next enquiry to 'chain' down to when this 'field' is
* selected.
* Passed in O.DATA is Application,Version. If a version record is
* specified then only those fields displayed on the version will be
* loaded into R.RECORD.
*
* 03/10/94 - GB9401102
*            Only ADD.COMMON.FIELDS when the file is a HUW
*
* 15/12/94 - GB9401347
*            Save FUNCTION as well as F, T etc
*
* 06/02/95 - GB9500197
*            Removal of Print Statements from previous Debug Sessions.
*
* 18/04/95 - GB9500505
*            Use a 'temporary' variable for the CALL @ as this will
*            corrupt a real variable.
*
* 29/09/95 - GB9501074
*            Field numbers are now stored on the VERSION record as field
*            names.  Convert the names to numbers after reading in the
*            the version record
*
* 08/05/96 - GB9600523
*            The routine has been amended when calling
*            STATIC.FIELD.TEXT to request translation
*            from the F array.
*
* 17/10/97 - GB9701196
*            Read record from unau,live and history files repesctively.
*            Enquiry changed to NOFILE.DRILLDOWN otherwise only live
*            records were displayed.
*
* 01/03/99 - GB9900305
*            Add functionality to drilldown to the $ARC file.
*
* 03/03/99 - GB9900335
*            Remove PRINT statement
* 29/03/99 - GB9900550
*            Just read the record from the history file - don't call EB.READ.HISTORY.REC
*
* 02/06/99 - GB9900782
*            Check whether Id contains a history nuber if not call
*            EB.READ.HISTORY.REC other wise use new process for direct
*            read from history file
*
* 23/07/99 - GB9900988
*            The translation of ID.F is held in the dynamic array returned from
*            STATIC.FIELD.TEXT and not from the F array. This is especially
*            important because the LD file now has 200 fields, and 200+1 gives
*            an array index out of bounds error.....
*
* 16/12/99 - GB9901796
*            Change the Dimensioned arrays from being dimensioned in
*            a unhealthy mixture of 200 and 500 to using a equated
*            value (C$SYSDIM)
*
* 11/09/01 - CI-101034
*            ACCT.STMT.PRINT not possible to view an account thats
*            closed.
*
* 25/09/01 - CI-10000311
*            This Pif is created as a correction pif for the above Pif
*            CI-101034 as the Program gave a Warning while Compilation
*            in JBASE installed area.
*
* 06-05-02 - GLOBUS_BG_100000975
*            In Desktop enquiry, then Local ref field no is not getting
*            displayed properly.  Ref.  HD :  JB0200005
*
* 08-05-02 - GLOBUS_BG_100001742
*            The USER encrypted password appears in the view mode of the
*            record.  Ref. IN0201927
*
* 26-09-02 - GLOBUS_CI_10003845
*            The Override Message is not displayed properly in View
*            record, when variable message is used. Ref. IN0202383.
*            For Override fields, when Variable message is present
*            ( using {, } ), then make the T()<1> = "T", so that
*            S.MASK recognises it.
*
* 05-10-02 - GLOBUS_CI_10004013
*            In the view record mode in Desktop, the field names
*            are not being translated as given in DYNAMIC.TEXT.
*            Ref. GE0200742.
*
* 25/10/02 - GLOBUS_CI_10004355
*            While running an enquiry for viewing the archive files it
*            was not displaying the record pertaining to the
*            corresponding ID, but instead it was displaying blank
*            fields or the records that are not of Archive Files.
*
* 26/04/03 - EN_10001710
*            Call TEMPLATE.D for dynamic templates.
*
* 05/01/05 - CI_10026105
*            Changes done to handle language field with definitions
*            XX.XX.LL.<FIELD> i.e. handling subvalue language fields.
*
* 10/08/07 - CI_10050559
*            Ref: HD0710320
*            Unable to View Record when Drill Down in STMT.ENT.BOOK
*
* 17/07/07 - CI_10050920
*            Unable to view the archive record in the enquiry using drilldown enquiry
*            DEFAULT.ARCHIVE.VIEW.Changes are made in INITIALISATION.
*
* 11/04/07 - CI_10052769
*            Changes done to display LIVE,HIS and ARC records properly during
*            drill down.
*            Ref: HD0805298
*
* 15/01/09 - CI_10060053
*            Archive records without History number in ID can not be viewed
*            REF : HD0900760
* 18/03/09 - CI_10061408
*            Field names greater than 18 characters overlaps with data
*            when record is seen in VIEW mode from a enquiry.
*            Fix done to restrict the Field names to 18 characters.
*
* 10/04/09 - CI_10062063(HD0912082)
*            As '{' is restricted in UTF8, Run time error occurs when viewing an
*            Exception record esp. when OVERRIDE field name is translated to a User language.
*
* 29/05/09 - CI_10063245(HD0919651)
*            Subvalues present in associated multivalue set are displayed
*            properly, when viewing record from Enquiry.
*
* 28/10/16 - Defect 1904467 / Task 1906750
*          - Fix for the ID and record retrieved using DEFAULT.ARCHIVE.VIEW enquiry does not match for archived record.
*
* 04/01/17 - Defect 1944169 / Task 1973263
*          - The search with CURR.No then sequence must be check first $HIS, $ARC, 
*            if absent in both should ID then be trimmed and searched in LIVE. 
*
* 19/01/17 - Task : 2013559
*            Physical order arrays returned from template and V = AUDIT.DATE.TIME
*            Table.endOfRecord can be used to identify record end position.
*
* 15/07/18 - Task 2664975
*            Saving and restoring of neighbour common variables required for executing application
*
*=======================================================================
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.LOCAL.TABLE
    $INSERT I_F.LOCAL.REF.TABLE
    $INSERT I_F.VERSION
    $INSERT I_F.PGM.FILE
    $INSERT I_Table
*  
    DIM SAVE.R.NEW(C$SYSDIM)
    DIM SAVE.F(C$SYSDIM), SAVE.N(C$SYSDIM), SAVE.T(C$SYSDIM), SAVE.CHECKFILE(C$SYSDIM), SAVE.CONCATFILE(C$SYSDIM)
*=======================================================================
*             MAIN PROCEDURE
*=======================================================================
*
    GOSUB SAVE.VARIABLES
    GOSUB INITIALISATION      ;* Translate field names, read version
*
    GOSUB LOAD.ID   ;* Put id details into the first value
    IDX = 1
    LOOP UNTIL IDX > endOfRecord
*
        IF APPLICATION = "USER" THEN
            IF INDEX(F(IDX), "XX.PASSWORD", 1) THEN
                IDX += 1
                CONTINUE
            END
        END
*  
        GOSUB DETERMINE.MVL   ;* Number & end of set
        FOR MVL.IDX = 1 TO MVL.COUNT
            IDX = MASSOC.START
            LOOP
                GOSUB DETERMINE.SVL     ;* Number & end of set
                FOR SVL.IDX = 1 TO SVL.COUNT
                    IDX = SASSOC.START
                    SASSOC = IDX
                    LOOP
                        GOSUB BUILD.FIELD
                        IDX +=1 UNTIL IDX > SASSOC.END
                    REPEAT
                NEXT SVL.IDX
            UNTIL IDX > MASSOC.END
            REPEAT
        NEXT MVL.IDX
    REPEAT
*
    GOSUB RESTORE.VARIABLES
    VM.COUNT = DCOUNT(R.RECORD<5>,@VM)  ;* Number of 'lines'
    RETURN
*=======================================================================
*             SUBROUTINES
*=======================================================================
INITIALISATION:
*
    CALL OPF("F.VERSION",F.VERSION)
    CALL OPF("F.LOCAL.TABLE",F.LOCAL.TABLE)
    CALL OPF("F.LOCAL.REF.TABLE",F.LOCAL.REF.TABLE)
    CALL OPF("F.PGM.FILE",F.PGM.FILE)
*
    FILE.NAME = O.DATA[",",1,1]         ;* Application
    FILE.NAME = FILE.NAME["$",1,1]      ;* Without the $HIS
    IF FILE.NAME = "" THEN
        V = 0       ;* No fields to process
        RETURN      ;* Do nothing
    END
*
*
    READ R.PGM.FILE FROM F.PGM.FILE, FILE.NAME ELSE
        R.PGM.FILE = ""       ;* No type
    END
*
* Open the main files
    NOFAT = @FM:"NO.FATAL.ERROR"
    CALL OPF("F.":FILE.NAME:NOFAT,F.LIVE)
    CALL OPF("F.":FILE.NAME:"$NAU":NOFAT,F.NAU)
    CALL OPF("F.":FILE.NAME:"$HIS":NOFAT,F.HIS)
*
* See if there is a $ARC file
*
    FN.ARC = "F.":FILE.NAME:"$ARC":NOFAT
    CALL OPF(FN.ARC,F.ARC)
    OPEN FN.ARC TO TEST.FLAG THEN
        ALLOW.ARC = 1
    END ELSE
        ALLOW.ARC = 0
    END
    APPLICATION = FILE.NAME
*
    IF R.PGM.FILE<EB.PGM.TYPE>[1,1] = 'T' THEN
        FV.APP = ''
        FN.APP = 'F.':APPLICATION
        CALL OPF(FN.APP,FV.APP)
        CALL F.READ(FN.APP,ID,R.APP,FV.APP,APP.ERR)
        V = DCOUNT(R.APP,@FM)
    END
* Read the record
*
    NO.RECS = "No records were found that matched the selection criteria"
    CR = CHARX(13)

    GOSUB GET.RECORD
    GOSUB VERSION.VIEW

    RETURN
*=======================================================================

GET.RECORD:
***********
    MAT R.NEW = ''

    IF INDEX("HU",R.PGM.FILE<EB.PGM.TYPE>[1,1],1) THEN      ;*  Record to be found in $NAU or $LIVE files
        MATREAD R.NEW FROM F.NAU, ID THEN         ;* Read NAU file
            RETURN
        END
    END

    MATREAD R.NEW FROM F.LIVE, ID THEN  ;* Try to read from LIVE
        RETURN
    END

    IF INDEX("H",R.PGM.FILE<EB.PGM.TYPE>[1,1],1) THEN       ;* History Record is also present
        F.FPTR = F.HIS
        GOSUB READ.HIST       ;* Try to read from Hist
        IF RECORD.FOUND = 1 THEN
            RETURN
        END
    END

    GOSUB READ.ARC  ;* Try Reading from $ARC file

    IF RECORD.FOUND = 0 THEN  ;* Record is not available / Invalid Selection
        ETEXT = NO.RECS :CR
        E = ETEXT   ;* Display Message to the User
        CALL ERR
        RETURN
    END

    RETURN

*=====================================================================================

READ.ARC:
*********

    F.FPTR = F.ARC
    IF ALLOW.ARC = 1 THEN     ;*Records exist in Archive
        GOSUB READ.HIST
    END
    RETURN

*=====================================================================================

READ.HIST:
**********
* TO read record from $HIS, $LIVE OR $ARC based on the file pointer passed in
    READ.FROM = ''
    RECORD.FOUND = 0
    IF INDEX(ID,";",1) THEN   ;*Check for ";" in ID
        MATREAD R.NEW FROM F.FPTR,ID THEN         ;* Directly read the record.  File pointer can be either of $HIS or $ARC fil
            RECORD.FOUND = 1
            RETURN
        END ELSE

        IF ALLOW.ARC AND F.FPTR = F.HIS THEN ;* when F.FPTR pointer is set $HIS, then skip to read live
            RETURN
        END
* It is actually on the live file but with a history id...

            CURR.ID = FIELD(ID, ";", 1)
            MATREAD R.NEW FROM F.LIVE,CURR.ID THEN
                RECORD.FOUND = 1
                READ.FROM = 'LIVE'
                RETURN
            END
        END
    END ELSE
        CURR.ID = ID:";1"     ;* First try to find if there is record with curr.no 1 (eg: SEC.TRADE,DELIVERY etc doesnt contain ";" for HIST records)
        MATREAD R.NEW FROM F.FPTR,CURR.ID THEN    ;* Read record with ID;1
            CALL EB.READ.HISTORY.REC(F.FPTR,ID,CURR.REC,YERROR)       ;* Read subsequent History Record pertaining to the Id
            IF CURR.REC <> "" AND NOT(YERROR) THEN
                MATPARSE R.NEW FROM CURR.REC, @FM
                RECORD.FOUND = 1
                RETURN
            END
        END ELSE
            CURR.ID = ID
            MATREAD R.NEW FROM F.FPTR,CURR.ID THEN          ;* Read record without CURR.NO
                RECORD.FOUND = 1
                RETURN
            END
        END
    END
    RETURN

*=====================================================================================

VERSION.VIEW:
*************

*
    VERSION.ID = O.DATA[",",2,1]        ;* Version
    LOCAL.REF.DETAILS = ""    ;* F,N,T & Checkfile for local refs
    NXT = 0         ;* Count of fields
*
    VERSION.RECORD = ""
    IF VERSION.ID THEN        ;* Read in version record
        READ VERSION.RECORD FROM F.VERSION, FILE.NAME:",":VERSION.ID ELSE
            VERSION.RECORD = ""
        END
    END
    TEXT = VERSION.RECORD
*
* Translate field names to numbers
*
    DIM DIM.VERSION.RECORD(C$SYSDIM)
    ERR.MSG = ''
    MATPARSE DIM.VERSION.RECORD FROM VERSION.RECORD
    CALL VERSION.NAMES.TO.NUMBERS(APPLICATION,MAT DIM.VERSION.RECORD,EB.VER.AUDIT.DATE.TIME,ERR.MSG)
*      VERSION.RECORD = ''
    VERSION.FIELDS = DIM.VERSION.RECORD(EB.VER.FIELD.NO)
*
    
    V$FUNCTION = "ENQUIRY"
    ROUTINE = FILE.NAME       ;* To be called
* Call TEMPLATE.D for dynamic templates
	Table.endOfRecord = ''
    Table.getPhysicalArray = 1                  ;* need field definition common arrays in physical order so that SS can update with physical fld number
    CALL EB.EXECUTE.APPLICATION(ROUTINE)
	Table.getPhysicalArray = 0                  ;* clear it, not require after this juncture because array retrieved in common variables F,N,T,CHECKFILE etc
	
    IF R.PGM.FILE AND INDEX("HUW",R.PGM.FILE<EB.PGM.TYPE>[1,1],1) THEN
        CALL ADD.COMMON.FIELDS          ;* Inputter etc
    END
*
    IF Table.endOfRecord THEN              ;* neighbour field added
        endOfRecord = Table.endOfRecord             ;* assign end of record and V always assigned for AUDIT.DATE.TIME from template
    	Table.endOfRecord = ''
    END ELSE                               ;* no neighbour field added
        endOfRecord = V
    END
    LOCAL.REF.FIELD.NUMBER = ""
    FOR X = 1 TO endOfRecord
        IF F(X) = "XX.LOCAL.REF" THEN
            LOCAL.REF.FIELD.NUMBER = X  ;* Save it
            GOSUB BUILD.LOCAL.REF       ;* Get F,N etc details
        END
    NEXT X
*
    FILE.ARRAY = FILE.NAME:@FM:"1"
    CALL STATIC.FIELD.TEXT(FILE.ARRAY)  ;* Translate field names
    IF FILE.ARRAY<endOfRecord+1> THEN            ;* Translated ID prompt, STATIC.FIELD.TEXT returns ID part after total field count
        ID.F = FILE.ARRAY<endOfRecord+1>          ;* ID prompt
    END
    R.RECORD = ""   ;* For return
*
    RETURN
*=======================================================================


LOAD.ID:
* Store ID prompt, data & enrichment
*
    R.RECORD = ID.F ;* Prompt
*
    COMI = ID[";",1,1]        ;* without the history number
    N1 = ID.N
    T1 = ID.T
    CALL S.MASK(N1,T1)
    IF V$DISPLAY THEN
        R.RECORD<2> = V$DISPLAY
    END ELSE
        R.RECORD<2> = COMI    ;* UNmasked
    END
*
    IF ID[";",2,1] AND READ.FROM NE 'LIVE' THEN
        R.RECORD<2> := ";": ID[";",2,1] ;* Put back the history number
    END
*
    IF ID.CHECKFILE THEN
        CALL DBR(ID.CHECKFILE,COMI,ENRICH)
        R.RECORD<3> = ENRICH
    END
*
    R.RECORD<4> = "QUIT S ": COMI       ;* Pick
*
    RETURN
*=======================================================================
DETERMINE.MVL:
* Determine the number of multivalues and the last one in the set.
*
    MVL.COUNT = COUNT(R.NEW(IDX),@VM) + 1
*
    MASSOC.START = IDX        ;* Default only one in set
    MASSOC.END = IDX          ;* Default only one in set
*
    IF F(MASSOC.START)[1,3] = "XX<" THEN          ;* Its multivalued
        LOOP UNTIL F(MASSOC.END)[3,1] = ">" OR MASSOC.END > endOfRecord
            MASSOC.END +=1    ;* Next one in set
        REPEAT
    END
*
    RETURN
*=======================================================================
DETERMINE.SVL:
* Determine the number of subvalues and the last one in the set.
*
    SVL.COUNT = COUNT(R.NEW(IDX)<1,MVL.IDX>,@SM) + 1        ;* Number of subs in multivalue
*
    SASSOC.START = IDX        ;* Default only one in set
    SASSOC.END = IDX          ;* Default only one in set
*
    IF F(SASSOC.START)[4,3] = "XX<" THEN          ;* Its multivalued,extract 3 chars and check out for "XX<".
        LOOP UNTIL F(SASSOC.END)[6,1] = ">" OR SASSOC.END > endOfRecord
            SASSOC.END +=1    ;* Next one in set
        REPEAT
    END
*
    RETURN
*=======================================================================
BUILD.FIELD:
* Put field into multi value    - ensure it's defined in version record
*
    IF VERSION.FIELDS THEN    ;* Don't display all
        LOCATE IDX IN VERSION.FIELDS<1,1> SETTING BUILD.OK ELSE
            LOCATE IDX:".":MVL.IDX IN VERSION.FIELDS<1,1> SETTING BUILD.OK ELSE
                LOCATE IDX:".":MVL.IDX:".":SVL.IDX IN VERSION.FIELDS<1,1> SETTING BUILD.OK ELSE
                    RETURN    ;* Do nothing
                END
            END
        END
    END
*
    IF IDX = LOCAL.REF.FIELD.NUMBER THEN          ;* Extract local ref details
        FN = LOCAL.REF.DETAILS<MVL.IDX,1>
        N1 = LOCAL.REF.DETAILS<MVL.IDX,2>
        T1 = LOCAL.REF.DETAILS<MVL.IDX,3>
        C1 = LOCAL.REF.DETAILS<MVL.IDX,4>
        SUBASSOC = LOCAL.REF.DETAILS<MVL.IDX,5>
        MVL.C = "XX."
        CONVERT "_" TO @FM IN C1        ;* File @FM Field

        IF TRIM(SUBASSOC) THEN
            FLD.DETAILS = MVL.C:SUBASSOC:FN
        END ELSE
            FLD.DETAILS = MVL.C:FN
        END
        FN =''
        FN = FLD.DETAILS
        FLD.DETAILS = ''
    END ELSE
        FN = F(IDX)
        N1 = N(IDX)
        T1 = T(IDX)
        C1 = CHECKFILE(IDX)
    END
*
    D.PROMPT = FN
    FLD.NUMBER = IDX
    SV.LNG.FLD = 0
    IF D.PROMPT[1,2] = "XX" THEN
        FLD.NUMBER := ".":MVL.IDX
        D.PROMPT = D.PROMPT[4,99]       ;* Drop it
        IF D.PROMPT[1,2] = "XX" THEN    ;* Subvalue
            FLD.NUMBER := ".":SVL.IDX
            D.PROMPT = D.PROMPT[4,99]   ;* Drop it
            SV.LNG.FLD = 1
        END
    END
    TEMP.PROMPT = D.PROMPT    ;*store the actual field name
* Prefix with language code
    IF D.PROMPT[1,3] ="LL." THEN        ;* Language field
        IF SV.LNG.FLD THEN
            D.PROMPT = T.LANGUAGE<SVL.IDX>:" ":D.PROMPT[3,99]
        END ELSE D.PROMPT = T.LANGUAGE<MVL.IDX>:" ":D.PROMPT[3,99]
    END
*
    GEN.TXT = APPLICATION : "*" : D.PROMPT
    CALL TXT(GEN.TXT)         ;*Translate if any Dynamic Text is given.
    D.PROMPT = FIELD(GEN.TXT, '*', 2)
*
    D.PROMPT = FLD.NUMBER:" ":D.PROMPT  ;* 33.2.1 Field

    D.PROMPT = D.PROMPT[1,18] ;*Field names restricted to 18 characters

    COMI = R.NEW(IDX)<1,MVL.IDX,SVL.IDX>          ;* Extract field
*
    IF INDEX(TEMP.PROMPT, "OVERRIDE", 1) THEN     ;*check if its OVERRIDE field, chk with actual field name and not with translated fields.
        IF INDEX(COMI, "{", 1) OR INDEX(COMI, "}", 1) THEN
            T1<1> = "T"
        END
    END
*
    CALL S.MASK(N1,T1)        ;* Mask if necessary
    IF V$DISPLAY THEN
        D.DATA = V$DISPLAY
    END ELSE
        D.DATA = COMI
    END
*
    D.ENRICHMENT = ""
    IF C1<1> THEN   ;* Got a checkfile
        CALL DBR(C1,COMI,D.ENRICHMENT)
    END
*
    D.NEXT = ""
    IF C1<1> THEN
        D.NEXT = C1<1>:" S ":COMI       ;* Next enquiry
    END
*
    IF D.DATA # "" THEN       ;* Show only populated fields
        NXT = NXT + 1         ;* Load into R.RECORD
        R.RECORD<5,NXT> = D.PROMPT
        R.RECORD<6,NXT> = D.DATA
        R.RECORD<7,NXT> = D.ENRICHMENT
        R.RECORD<8,NXT> = D.NEXT
    END
*
    RETURN
*=======================================================================
BUILD.LOCAL.REF:
* Store F,N,T & Checkfile details from LOCAL.REF
*
    READ R.LOCAL.REF.TABLE FROM F.LOCAL.REF.TABLE, FILE.NAME ELSE
        R.LOCAL.REF.TABLE = ""
    END
*
    LOCAL.FIELDS = R.LOCAL.REF.TABLE<EB.LRT.LOCAL.TABLE.NO>
    LOOP REMOVE LF FROM LOCAL.FIELDS SETTING D WHILE LF
        READ R.LOCAL.TABLE FROM F.LOCAL.TABLE, LF THEN
            LD = R.LOCAL.TABLE<EB.LTA.SHORT.NAME,LNGG>
            IF LD = "" THEN
                LD = R.LOCAL.TABLE<EB.LTA.SHORT.NAME,1>
            END
            MXM = R.LOCAL.TABLE<EB.LTA.MAXIMUM.CHAR>
            MNM = R.LOCAL.TABLE<EB.LTA.MINIMUM.CHAR>
            LD<1,2> = MXM:".":MNM       ;* N()
            LD<1,3> = R.LOCAL.TABLE<EB.LTA.CHAR.TYPE>       ;* T()
            LD<1,4> = R.LOCAL.TABLE<EB.LTA.APPLICATION.VET>:"_":R.LOCAL.TABLE<EB.LTA.APPL.ENRICHM.FIELD>
*
            LOCATE LF IN LOCAL.FIELDS<1,1> SETTING POS THEN
                LD <1,5> = R.LOCAL.REF.TABLE<EB.LRT.SUB.ASSOC.CODE,POS>
            END ELSE
                LD <1,5>=''
            END
*
            LOCAL.REF.DETAILS<-1> = LD  ;* Store for later
        END
    REPEAT
*
    RETURN
*=======================================================================
SAVE.VARIABLES:
*
    MAT SAVE.R.NEW = MAT R.NEW
    MAT SAVE.F = MAT F
    MAT SAVE.N = MAT N
    MAT SAVE.T = MAT T
    MAT SAVE.CHECKFILE = MAT CHECKFILE
    MAT SAVE.CONCATFILE = MAT CONCATFILE
    SAVE.APPLICATION = APPLICATION
    SAVE.ID.F = ID.F
    SAVE.ID.T = ID.T
    SAVE.ID.N = ID.N
    SAVE.ID.CHECKFILE = ID.CHECKFILE
    SAVE.ID.CONCATFILE = ID.CONCATFILE
    SAVE.V = V
    SAVE.FUNCTION = V$FUNCTION
    
    save.Table.currentState = Table.currentState ; save.Table.logicalOrder = Table.logicalOrder
    save.Table.physicalOrder = Table.physicalOrder ; save.Table.endOfRecord = Table.endOfRecord
    save.Table.currentFieldPosition = Table.currentFieldPosition 
    
    RETURN
*=======================================================================
RESTORE.VARIABLES:
    APPLICATION = SAVE.APPLICATION
*
    MAT R.NEW = MAT SAVE.R.NEW
    MAT F = MAT SAVE.F
    MAT N = MAT SAVE.N
    MAT T = MAT SAVE.T
    MAT CHECKFILE = MAT SAVE.CHECKFILE
    MAT CONCATFILE = MAT SAVE.CONCATFILE
    ID.F = SAVE.ID.F
    ID.T = SAVE.ID.T
    ID.N = SAVE.ID.N
    ID.CHECKFILE = SAVE.ID.CHECKFILE
    ID.CONCATFILE = SAVE.ID.CONCATFILE
    V = SAVE.V
    V$FUNCTION = SAVE.FUNCTION
    
     Table.currentState = save.Table.currentState ;  Table.logicalOrder = save.Table.logicalOrder
   Table.physicalOrder = save.Table.physicalOrder; Table.endOfRecord = save.Table.endOfRecord
   Table.currentFieldPosition = save.Table.currentFieldPosition
   
    RETURN
*=======================================================================
END
