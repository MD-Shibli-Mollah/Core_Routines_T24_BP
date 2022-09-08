* @ValidationCode : MjotMTEwNzYxNTM3NjpDcDEyNTI6MTUwNzk4MTAzNTU5MTpuYXZhbmVldGhhYmFidTotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzExLjIwMTcwOTMwLTAwMTM6LTE6LTE=
* @ValidationInfo : Timestamp         : 14 Oct 2017 17:07:15
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : navaneethababu
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201711.20170930-0013
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*
*-----------------------------------------------------------------------------
* <Rating>9513</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.SystemTables
SUBROUTINE EBS.CREATE.FILE(FILE.TO.CREATE,DATA.OR.DICT,ERROR.MSG)
*
*************************************************************************
*
* Routine to create files in the main data account. The data account
* pathname is taken from the SYSTEM record in the F.SPF file. If the
* current account is not the main data account, then the file will be 
* created locally, copied to the main data account and the local file
* deleted.
*
*
*************************************************************************
*
*
*
*   MODIFICATIONS
*   -------------
*
* 27/02/07 - CI_100474
*            Special files are getting created even though they already exists.
*            Ref: TTS0753198
*
* 27/06/07 - CI_10050036(HD0710833)
*            Create RGS files as J4 files in OGLOBUS
*
*   17/10/07 - BG_100015462
*              Option of specifying file path has been removed from EBS.CREATE.FILES.
*              So re-introducing it back.
*              Ref: TTS0707135
*
* 26/03/08 - CI_10054374
*             When a directory is created using CREATE.FILES from T24 application prompt, dict file should be
*             created in bnk.dict as a j4 file.
*             Ref: HD0804394
*
* 08/08/08 - CI_10057221
*            For RGS type of file, data file is created as J4 where as
*            the dict is created in MSSQL.
*
* 12/08/08 - CI_10057295
*            File name containing '-' not converted properly during
*            data migration to oracle area.
*
* 29/08/08 - CI_10057526
*            Same dict getting created in two session as there is no lock.
*
* 16/09/08 - CI_10057757
*            RGS type files are created with same physical file name
*            in OGLOBUS area.
*
* 25/08/08 - BG_100019666
*            EBS.CREATE.FILE should  allow to create a file without prefix
*            and also should accept the modulo passed to it.
*
* 06/02/09 - CI_10059524
*            PGM.FILE created for dynamic templates is not recognised when there is direct read on PGM.FILE.
*            As the READ fails, files are created as "BLOB" type in oracle environment.
*            READ on PGM.FILE is changed to F.READ
*
* 27/02/09 - CI_10061002
*            Archive files not getting created in proper path.
*
* 03/03/09 - CI_10061044
*            In stub file architecture, Table name is not prefixed with product if
*            file name has less than 22 characters.
*            REF : HD0905460
*
* 16/04/09 - CI_10061236
*            Illegal or missing modulo error when trying to create
*            ARC files.
*
* 27/04/09 - BG_100023406
*            Unitialised variable error during file Creation in JBASE environment
*            REF : TTS0907118
*
* 22/04/09 - CI_10062347
*            Files to be created as BLOB type when PGM.FILE
*            ADDITIONAL.INFO field is set as .BLB
*            Ref:HD0902803
*
* 20/05/09 -  CI_10062984
*             RGS file to be created as XMLORACLE file in oracle environment
*             instead of J4.
*             Ref:HD0917736
*
* 23/09/09 - EN_10004355
*            Replace Globus.BP with T24.BP in T24 Server Code
*
* 14/09/09 - BG_100025511
*            Changes done to work with the new framework driver
*
* 18/11/09 - CI_10067632
*            In oracle area, when new files are released through GLOBUS.RELEASE,
*            they always created with BLOB type
*            Ref : HD0943165
*
*25/11/2009 - BG_100025913
*             Soft code the folder named T24.BP
*
* 12/12/09 - BG_100026173
*            Create file if the Data path of the VOC is null
*            TTS Ref : TTS0910805
*
* 19/01/10 - Defect - 11672
*            In oracle environment, creating files with J4 type for TV product
*
* 26/03/2010 - Defect-20991 / Task-34329
*            Duplication on file creation when the file sequence exceeds 999
*            if the length of file greater than the maximum limit.
*            Fix done to avoid the duplication on file creation
*
* 04/05/10 - Defect:43453/Task:50660
*            Illegal or missing modulo error when trying to create
*            ARC files for the file which is distributed.
*
* 02/09/10 - Task : 82573 / Defect : 80390
*            Error thrown during file creation in Stub-less oracle area if the length of file name
*            exceeds 25 characters. In a stubless architecture, the existence of table name should
*            be checked in STUBVIEW.
*            Fix in CI_10057757 revisited
*            REF : HD1034182 / Defect : 80390
*
* 12/10/10 - Defect 89596 - task 97005
*            Do a direct READ on PGM.FILE in spite of doing F.READ on PGM.FILE, to make sure files are
*            created in XML format.
*            This case should not get hit often but just in case cache variable is already loaded
*            with "Record not found" error but subsequently there is any direct WRITE happening.
*            Example:- Creating new templates via EB.DEV.HELPER.
*
* 17/02/11 - Defect : 149471 / Task : 149483
*            Changes done for the jRFS type file creation.
*
* 22/7/2011 - Defect : 247088 / Task : 248893
*            In Oracle environment, existing STUBVIEW file not updated with latest format leads to
*            the problem in file creation during upgrade.
*
* 09/12/11 - Task : 321482 / Ref Defect : 315168
*            The file name ending with ".LIST" should be trimmed, only when the pgm record
*            is not loaded in the first F.READ.
*
* 28/08/12 - Enhancement - 371776 , Task - 452007
*            Deleted item history (SAMBA)
*            $DEL file need to be created.
*
* 24/04/13 - Task - 587575 / Defect - 579556
*            Locking is maintained only at exact dict and data file name level before creating it.
*
* 14/02/14 - Defect - 907386 / Task 914398
*            File sequence number has been increased to 4 digits to create the file with sequence number upto 9999
*
* 21/02/14 - Defect - 776259 / Task - 922265
*            When the dict/data file is already available, retry for next (unique) dict/data file name
*
* 14/04/14 - Defect - 970624 / Task - 970805
*            When the dict/data file is already available, dont try to create a dict/data file name again
*
* 25/09/14 - Defect 1124371 / Task - 1124376
*            Changed to refer insert file JBC properly
*
* 10/09/14 - Task:1080465 / Defect:1079107
*            FILE CREATION handling in TAFJ
*
* 09/03/15 - Task : 1276460 / Defect : 1159857
*            Locking is done before deleting the dict stub file
*
* 01/07/16 - Task : 1779988 / Defect : 1704678
*            Generate dict and data file for UD type of files without truncating upto 9 characters.
*
* 30/09/16 - Defect : 1784572 / Task : 1845695
*            The Dict file deletion is skipped for archival process to prevent FATAL error in VOC read in case
*            multiple agents.
*
* 03/11/16 - Task:1913479 / Defect:1896746
*            CREATE.FILES not able to create DATA files for products with long product codes
*
* 21/09/17 - Task 2280739
*            Use schema passed in 7th position of FILE.TO.CREATE to create files
*
*------------------------------------------------------------------------
*
    EQUATE RDBMS.MAX.TABLENAME TO (30-5)          ;* Take off 5 for LOBI_ tablename extension

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SPF
    $INSERT I_F.FILE.CONTROL
    $INSERT I_F.COMPANY
    $INSERT I_F.PGM.FILE
    $INSERT I_F.COMPANY.CHECK
    $INSERT JBC.h

*
*------------------------------------------------------------------------
*

    ERROR.MSG = ""

    useCompanySchema = 0 ;    ;* Use the Company name for RDBMS Schema names
    useCompanyTableSpace = 0; ;* Use tablespaces specified by the Company name
    checkXSDSchema = 0 ;      ;* Check for XSD Schemas for RDBMS file creation

    GOSUB INITIALISATION
    GOSUB CHECK.FILE.CONTROL
    GOSUB DETERMINE.PRODUCT.DIRECTORY

    OPEN 'F.LOCKING' TO F.LOCKING.FILE ELSE
        ERROR.MSG = "Unable to open 'F.LOCKING'"
        GOTO PROGRAM.ERROR
    END

*Product level locking on F.LOCKING is removed and exact dict and data level locking is maintained.

    GOSUB CREATE.FILES.AND.DICTIONARY


    CLOSE F.LOCKING.FILE

RETURN
*
*------------------------------------------------------------------------
*
INITIALISATION:

* Miscallenous indicator to preserve stub file rather than delete

    IF RUNNING.IN.TAFJ THEN
        FILE.TO.CREATE<6> = "J"
    END

    verbose = 0
    DB.SCHEMA.NAME = ""
    DIM R.FILE.CONTROL(10)
    SCRN.FULL.PROMPT = @(0,0) ;* Turn off screen full prompt
    ERROR.MSG = ''  ;*   Null error msg
    ARCHIVE = 0 ; HELPTEXT = 0
    useDbSchema = 0			;* assume no DB schema
    useCompanyTableSpace = 0
    JRFS = 0        ;* Falg to indicate the file type is JRFS or other files
    
    IF FILE.TO.CREATE<7> THEN       ;* if the schema name passed
        useDbSchema = 1        ;* set the flag to use schema
        DB.SCHEMA.NAME = FILE.TO.CREATE<7>  ;* get the schema name
    END

    IF GetProperty("jrfs", "IPAddress") THEN      ;* For JRFS type of files to be created
        JRFS = 1    ;* Set the flag
        DB.TYPE = "JRFS"      ;* For data file
        DICTIONARY.DB.TYPE = "JRFS"     ;* For dict
    END
*
    dbTypeIn = FILE.TO.CREATE<6>        ;* Get database type if forced from calling routine
*
    IF JRFS <> 1 THEN         ;* If not JRFS
        IF dbTypeIn[1,1] EQ 'J' THEN    ;* if database type is already passed to create file as J4/JR type
            DB.TYPE = dbTypeIn          ;* Get database type used for creating files
            DICTIONARY.DB.TYPE = 'J4'   ;* Set dictionary database type as J4
        END ELSE
            fnSpf= 'F.SPF'
            fvSpf = ''
            CALL OPF(fnSpf,fvSpf)
            STATUS rSpfStatus FROM fvSpf ELSE rSpfStatus = ''
            DB.TYPE = rSpfStatus<21>

            dictFnSpf= 'DICT F.SPF'
            dictFvSpf = ''
            CALL OPF(dictFnSpf,dictFvSpf)
            STATUS dictStatus FROM dictFvSpf ELSE dictStatus = ''
            DICTIONARY.DB.TYPE = dictStatus<21>
        END
    END
*
    preserveOption = ""
    IF GETENV("RDBMS_PRESERVE_STUBS",preserveOption) ELSE preserveOption = ""

* Miscallenous remote file indicators

    remoteHostOption = ""
    IF GETENV("RDBMS_REMOTE_HOSTNAME",remoteHostOption) ELSE remoteHostOption = ""

    remoteAccountOption = ""
    IF GETENV("RDBMS_REMOTE_ACCOUNT",remoteAccountOption) ELSE remoteAccountOption = ""

    remoteStubsOnly = ""
    IF GETENV("RDBMS_REMOTE_STUBSONLY",remoteStubsOnly) ELSE remoteStubsOnly = ""

    DIM R.FILE.CONTROL(10)
    SCRN.FULL.PROMPT = @(0,0) ;* Turn off screen full prompt
    ERROR.MSG = ''  ;*   Null error msg
    ARCHIVE = 0 ; HELPTEXT = 0

*
* Strip out fields 2, 3 and 4 of FILE.TO.CREATE
* as these could be the pathname, type and modulo for an archive file
*
    ARC.PATHNAME = FILE.TO.CREATE<2>
    ARC.TYPE = FILE.TO.CREATE<3>
    ARC.MODULO = FILE.TO.CREATE<4>

    FILE.CREATE.OPTION = FILE.TO.CREATE<5>
* Determine if the file is an archive file  the archive pathname or in xxx.arc

    IF FILE.TO.CREATE<1>[4] = '$ARC' THEN         ;*Set the archive flag
        ARCHIVE = 1
    END

    IF FILE.CREATE.OPTION AND ARCHIVE THEN        ;* if both the options are set
        FILE.CREATE.OPTION = ''         ;* better go to the archive mode
    END

    IF FILE.CREATE.OPTION AND (ARC.PATHNAME = '' OR ARC.MODULO = '' )  THEN     ;* either if path name or modulo is not specified then
        FILE.CREATE.OPTION = ''         ;* set the file creation option flag to false
    END

*
    FILE.TO.CREATE = FILE.TO.CREATE<1>

    OPEN 'VOC' TO F.VOC ELSE
        ERROR.MSG = 'Unable to open VOC '
        GOTO PROGRAM.ERROR
    END

    READ invalidTableNames FROM F.VOC,"INVALIDTABLENAMES" ELSE invalidTableNames = ""
    invalidTableNames<-1> = "SYNONYM"   ;* Append known reserved words

    READ vocRecord FROM F.VOC,'F.SPF' ELSE vocRecord = ""

    IF vocRecord<1>[1,1] NE "F" THEN
        vocTableIdentifier = vocRecord<1>         ;* Using STUB or TABLE voc identifiers not F pointers
        createTableEntry = 1  ;* Flag to create table entries in voc from stub files
        useRealFiles = 0      ;* Not using real files or stub files but table entries
        vocDataField = vocRecord<4>     ;* Pick up data field from F pointer
    END ELSE
        vocTableIdentifier = ""         ;* Not using STUB or TABLE voc identifiers but F pointers
        useRealFiles = 1
        vocDataField = vocRecord<2>     ;* Pick up data field from F pointer
        createTableEntry = 0  ;* Flag NOT to skip table entries in voc from stub files
    END

    IF INDEX(vocDataField,"F_SPF",1) THEN
        useVocName = 1        ;* Flag to use Voc Name for Path and Table naming whereever possible
    END ELSE
        useVocName = 0        ;* Default to use eld naming convention
    END

*
* Attempt to determine if using Company Schema
* and Real or Stub files from FBNK.ACCOUNT
*

    useVocName = 1  ;* Using voc id as basis for table names

* Open Schema file

    OPEN 'F.SCHEMA' TO F.SCHEMA.FILE THEN

        checkXSDSchema = 1    ;* Schema file exists so check for schemas

    END ELSE

        checkXSDSchema = 0

    END

* Open F.SPF and read SYSTEM record

* Open F.PGM.FILE for file type check

    OPEN 'F.PGM.FILE' TO F.PGM.FILE ELSE
        ERROR.MSG = "Unable to open 'F.PGM.FILE'"
        GOTO PROGRAM.ERROR
    END

*
* Open dictionary path specified in F.SPF, SYSTEM to determine dictionary path
*
    IF NOT(RUNNING.IN.TAFJ) THEN
        DICTIONARY.DIRECTORY = TRIM(R.SPF.SYSTEM<SPF.DICT.ACC.NAME>)

        OPEN DICTIONARY.DIRECTORY TO DICTIONARY.DIRECTORY.FILE ELSE
            ERROR.MSG = "Unable to open dictionary directory path ":DICTIONARY.DIRECTORY
            GOTO PROGRAM.ERROR
        END
    END
*
* Check whether the file is a special file.  If it is, it will be created in the top level directory (e.g. BNK).
* For special files, allow name to be F., as this is how it is currently done in PERFORM.GLOBUS.RELEASE.
* However, if the file is created through CREATE.FILES, it must be without the F. prefix.
*
    SPECIAL.FILES = 'C.PROGS':@FM:'CPL.PROGS':@FM:'F.PROGS':@FM:'F.PGM.DATA.CONTROL':@FM:'F.RELEASE.DATA':@FM
    SPECIAL.FILES := 'F.DL.DATA':@FM:'PGM.DATA.CONTROL':@FM:'RELEASE.DATA':@FM:'DL.DATA':@FM:'DL.BP':@FM:'DL.BP.O':@FM
    SPECIAL.FILES := T24$BP:@FM:'PATCH.BP':@FM:'PATCH.BP.O':@FM:'DIM.TEMP'

    SPECIAL.FULL.NAMES = 'C.PROGS':@FM:'CPL.PROGS':@FM:'F.PROGS':@FM:'F.PGM.DATA.CONTROL':@FM:'F.RELEASE.DATA'
    SPECIAL.FULL.NAMES:= @FM:'F.F.DL.DATA':@FM:'F.PGM.DATA.CONTROL':@FM:'F.RELEASE.DATA':@FM:'F.DL.DATA':@FM:'DL.BP'
    SPECIAL.FULL.NAMES:= @FM:'DL.BP.O':@FM:T24$BP:@FM:'PATCH.BP':@FM:'PATCH.BP.O':@FM:'DIM.TEMP'


    IF FILE.CREATE.OPTION  THEN         ;*when FILE.CREATE.OPTION is set treat the file as special files
        SPECIAL.FILES := @FM:FILE.TO.CREATE
        SPECIAL.FULL.NAMES:= @FM:FILE.TO.CREATE
    END

    SPECIAL = 0
    LOCATE FILE.TO.CREATE IN SPECIAL.FILES<1> SETTING SPECIAL THEN

        SPECIAL.FILE.NAME = SPECIAL.FULL.NAMES<SPECIAL>

        IF FILE.TO.CREATE[1,2] = 'F.' THEN
            FILE.NAME = FILE.TO.CREATE[3,99]      ;* Remove "F." prefix for reading of file.control file
        END ELSE
            FILE.NAME = FILE.TO.CREATE
        END

        PRODUCT.DIRECTORY = '..'

    END ELSE

        FILE.NAME = FILE.TO.CREATE      ;* Copied from argument - it could be changed.
        SPECIAL = 0

    END
*
* Determine if the file is a helptext file, create in xxxx.help

*
    IF FILE.TO.CREATE[1,8] = 'HELPTEXT' OR FILE.TO.CREATE = 'F.HELPTEXT' THEN HELPTEXT = 1
*
*
    GOSUB CREATE.PSUEDO.STUBFILE        ;* Generate STUBVIEW if required
*
    IS.RGS = 0      ;* RGS file will be created as XMLORACLE file in oracle environment

RETURN
*
*------------------------------------------------------------------------
*
CHECK.FILE.CONTROL:
*
* Input to this routine is FILE.NAME
* Output variables for data files are CREATE.NAME and CREATE.OPTIONS
* Output variables for dictionary file is FILE.NAME
*
* The file name passed should reference a record on F.FILE.CONTROL.
* If not, the file name be the file name used to create the file
*
    OPEN 'F.FILE.CONTROL' TO F.FILE.CONTROL.FILE ELSE
        ERROR.MSG = "Uable to open 'F.FILE.CONTROL' "
        GOTO PROGRAM.ERROR
    END

    RECORD.EXISTS = 1
    FN.FILE.CONTROL = 'F.FILE.CONTROL'
    CALL F.MATREAD(FN.FILE.CONTROL,FILE.NAME, MAT R.FILE.CONTROL,F.FILE.CONTROL,EB.FILE.AUDIT.DATE.TIME,ERR)  ;* Do F.MATREAD instead of direct READ.  Probably, we are from FILE.CONTROL template to create files and we need the latest R.NEW

    IF ERR THEN     ;* if record not found
        MATREAD R.FILE.CONTROL FROM F.FILE.CONTROL.FILE,FILE.NAME ELSE          ;* Do a direct READ
            RECORD.EXISTS = 0 ; MAT R.FILE.CONTROL = ''     ;* record not found
        END
    END

    IF RECORD.EXISTS THEN
        FILE.DESCRIPTION = R.FILE.CONTROL(EB.FILE.CONTROL.DESC)
        PRODUCT = OCONV(R.FILE.CONTROL(EB.FILE.CONTROL.APPLICATION),'MCL')      ;* Lower case for directory name
        IF R.FILE.CONTROL(EB.FILE.CONTROL.APPLICATION) = "" THEN
            PRODUCT = 'zz'
        END ELSE
            IF (INDEX(R.COMPANY(EB.COM.APPLICATIONS),R.FILE.CONTROL(EB.FILE.CONTROL.APPLICATION),1)) = 0 THEN
                IF R.COMPANY(EB.COM.CONSOLIDATION.MARK) # "R" THEN
                    ERROR.MSG = 'APPLICATION NOT ON COMPANY FOR ':FILE.NAME
                    GOTO PROGRAM.ERROR
                END
            END
        END
        FILE.CLASSIFICATION = R.FILE.CONTROL(EB.FILE.CONTROL.CLASS)

        Y.FILE.NAME = FILE.NAME
        $INSERT I_MNEMONIC.CALCULATION
        IF NOT(CLASS.OK) THEN
            ERROR.MSG = "Classification error from MNEMONIC.CALCULATION ":FILE.NAME
            GOTO PROGRAM.ERROR
        END

*
        IF C$MULTI.BOOK THEN
            IF MNEMONIC AND MNEMONIC <> R.COMPANY(EB.COM.FINANCIAL.MNE) AND FILE.CLASSIFICATION <> 'FRP' THEN
                GOTO PROGRAM.ABORT
            END
        END ELSE
            IF MNEMONIC AND MNEMONIC # R.COMPANY(EB.COM.MNEMONIC) THEN
                GOTO PROGRAM.ABORT      ;* Get out of here - no error
            END
        END
*
        CREATE.NAME = "F": MNEMONIC: ".": FILE.NAME
*
    END ELSE

        FILE.DESCRIPTION = ''
        PRODUCT = 'zz'        ;* Default directory when not a GLOBUS file.
        IF FILE.NAME MATCHES T24$BP:VM:'PATCH.BP':VM:'PATCH.BP.O' THEN          ;* File control record does not exist (not copied over yet)
            R.FILE.CONTROL(EB.FILE.CONTROL.TYPE) = 19
            R.FILE.CONTROL(EB.FILE.CONTROL.MODULO) = ''
        END ELSE
            R.FILE.CONTROL(EB.FILE.CONTROL.TYPE) = 2        ;* Default type
            R.FILE.CONTROL(EB.FILE.CONTROL.MODULO) = 13     ;* & Modulo. PIF GB9100055
        END
        CREATE.NAME = FILE.NAME         ;* The name that was passed
        IF FILE.NAME[1,4]= "F":R.COMPANY(EB.COM.MNEMONIC) THEN
            FILE.NAME = FILE.NAME[6,99] ;* Remove FXXX. for dictionary creation.
        END ELSE
* Extra check insert onsite to check for whethe F. passed or not 11-02-92
            IF FILE.NAME[1,2]= "F." THEN
                FILE.NAME = FILE.NAME[3,99]       ;* Remove F. prefix for dictionary creation
            END ELSE
                CREATE.NAME = "F": R.COMPANY(EB.COM.MNEMONIC):".":FILE.NAME
            END
        END
    END
*
    IF SPECIAL THEN CREATE.NAME = SPECIAL.FILE.NAME
*
    CREATE.OPTIONS = R.FILE.CONTROL(EB.FILE.CONTROL.TYPE):" ":R.FILE.CONTROL(EB.FILE.CONTROL.MODULO)

    CLOSE F.FILE.CONTROL.FILE ;* Close Control file
*
    controlType = R.FILE.CONTROL(EB.FILE.CONTROL.TYPE)      ;* file type as in FILE.CONTROL
    IF controlType = '1' OR controlType = '19' OR controlType = "UD" THEN       ;* if any of these
        controlType = "UD"    ;* then set it to UD
    END
*
RETURN
*
*************************************************************************
*
CREATE.FILES.AND.DICTIONARY:
*
* Check the dictionary exist .. always F.FILE.NAME - create if necessary
*
    IF SPECIAL THEN DICT.FILE.NAME = SPECIAL.FILE.NAME ELSE DICT.FILE.NAME = "F.": FILE.NAME        ;* Always F.aaaaaaaa

    Dict.Updated = 0          ;*Shek

*
    OPEN 'DICT', DICT.FILE.NAME TO F.DICT.FILE.NAME THEN
        UNIX.DICT.NAME = DICT.FILE.NAME:']D'      ;* Set unix name for dict
    END  ELSE
        IF controlType NE "UD" OR NOT(RUNNING.IN.TAFJ) THEN ;*  No need to create a DICT file, at the time of UD creation
            GOSUB CREATE.DICTIONARY         ;* UNIX.DICT.NAME also appened with ]D on return
        END
    END

*
    IF controlType NE "UD" OR NOT(RUNNING.IN.TAFJ) THEN
        READ R.DICT.VOC FROM F.VOC, DICT.FILE.NAME ELSE
            ERROR.MSG = "Unable to read voc entry for dictionary ":FILE.NAME
            GOTO PROGRAM.ERROR
        END
        UNIX.DICTIONARY = R.DICT.VOC<3>     ;* Dictionary path or table definition
    END

*

*
* Now create the file(s) live, hist & nau- Take care FT has file control
* entries with $HIS in the ID - not in the suffix list.
*
    SUFFIX = ""     ;* Live file first
    SUFFIX.LIST = TRIMF(R.FILE.CONTROL(EB.FILE.CONTROL.SUFFIXES))     ;* List of files to open
    LIVE.NAME = CREATE.NAME   ;* Fmmm.XXXXX without $HIS/$NAU
*
    LOOP
        CREATE.NAME = LIVE.NAME: SUFFIX ;* + $HIS or $NAU

        DATA.FILE.EXISTS = 0  ;* a Variable to flag if the file exits or not. Initialise to NULL assuming the file does not exist
        OPEN '',CREATE.NAME TO F.DUM.FILE THEN    ;* Try opening the file
            READ R.DATA.VOC FROM F.VOC, CREATE.NAME THEN    ;* Try reading the VOC of the same
                IF R.DATA.VOC<2> NE '' THEN       ;* If the VOC has the DATA path for the file
                    DATA.FILE.EXISTS = 1          ;* Set the flag that the data file already exists
                END
            END
        END

        IF NOT(DATA.FILE.EXISTS) THEN   ;* If the Data file does not actually exists, try creating
            IF NOT(RUNNING.IN.TAFJ) THEN
                DELETE F.VOC, CREATE.NAME   ;* Remove voc entry - if present
            END
            GOSUB CREATE.DATA.FILE
            IF NOT(RUNNING.IN.TAFJ) THEN
                GOSUB UPDATE.VOC
            END
        END

        IF NOT(RUNNING.IN.TAFJ) THEN
            READ R.DATA.VOC FROM F.VOC, CREATE.NAME THEN
                IF R.DATA.VOC<3> NE R.DICT.VOC<3> THEN          ;* Ensure the dictionary pointer is correct
                    R.DATA.VOC<3> = R.DICT.VOC<3>     ;* even if we can open the file the dictionary
                    WRITE R.DATA.VOC TO F.VOC, CREATE.NAME      ;* may have had to be recreated.
                END
            END
        END
        SUFFIX = REMOVE(SUFFIX.LIST,D)

    UNTIL SUFFIX = ""

    REPEAT
*
RETURN
*
*------------------------------------------------------------------------
*
UPDATE.VOC:
*
* Update the voc with the pointers to the data file & dict file.
* and check that the new file & dictionary can be opened.
* The JRFS type files also using below 3 line VOC format.

    R.VOC = ''
    R.VOC<1> = "F ":FILE.DESCRIPTION
    R.VOC<2> = DATA.PATH
    R.VOC<3> = UNIX.DICTIONARY
*
    WRITE R.VOC TO F.VOC, CREATE.NAME
*
* Try opening the new data file.
*
    ERROR.MSG = ""
*
    OPEN '',CREATE.NAME TO F.DATA.TEST ELSE
        ERROR.MSG = "Unable to open the file: ":CREATE.NAME:" [":R.VOC<2>:"]   "
        DELETE F.VOC, CREATE.NAME       ;* No point remove VOC entry for data file
        GOTO PROGRAM.ERROR    ;* Tell them
    END

*
* If using external database and STUBLESS Voc entries then create
* a 'STUB/TABLE' entry in the VOC in place of the F Pointer
*
    IF createTableEntry THEN


*
* Check status of the dictionary for being XML type before reading stub
*
        IF NOT(Dict.Updated) THEN       ;* Shek
            STATUS dictStatus FROM F.DICT.FILE.NAME ELSE dictStatus = ""
            CLOSE F.DICT.FILE.NAME      ;* Close dict file handle to allow deletion below
            DICT.DB.TYPE = dictStatus<21>
            Dict.Updated = 1  ;* Shek
            IF DICT.DB.TYPE[1,1] EQ "X" THEN

                READ stubDictRecord FROM DICTIONARY.DIRECTORY.FILE,UNIX.DICT.NAME THEN

                    stubDictRecord = CHANGE(TRIM(stubDictRecord)," ",@AM)
                    DEL stubDictRecord<1>         ;* Lose JBC__SOB

                    dictFunction = stubDictRecord<1>        ;* Save driver initialisation Function
                    DEL stubDictRecord<1>         ;* Remove driver function

                    dictInfo = CHANGE(stubDictRecord,@AM," ")         ;* Rest of info is the required dict table arguments

                    IF NOT(useRealFiles) AND preserveOption EQ "" AND NOT(ARCHIVE) THEN  ;* Deleting the dict if it is not an archival process
                        READU dummy FROM DICTIONARY.DIRECTORY.FILE,UNIX.DICT.NAME THEN    ;* Obtain lock before deleteing the dict stub file
                            DELETE DICTIONARY.DIRECTORY.FILE,UNIX.DICT.NAME         ;*Delete the dict stub file
                        END ELSE
                            RELEASE DICTIONARY.DIRECTORY.FILE,UNIX.DICT.NAME    ;* Release the dict stub file
                        END

                    END
*
* Rewrite dictionary voc entry as a voc TABLE entry
*

                    R.DICT.VOC<1> = vocTableIdentifier      ;* Set voc table identifier as STUB or TABLE
                    R.DICT.VOC<2> = dictFunction  ;* Driver initialisation function
                    R.DICT.VOC<3> = dictInfo      ;* Dict table driver arguments
                    R.DICT.VOC<4> = ""  ;* No data for VOC dict entry
                    WRITE R.DICT.VOC TO F.VOC,DICT.FILE.NAME          ;* Update DICT VOC entry as TABLE entry

                END ELSE
                    READ R.DICT.VOC FROM F.VOC, DICT.FILE.NAME THEN
                        dictInfo = R.DICT.VOC<3>  ;* Pick dict info from dictionary voc entry
                    END ELSE
                        dictInfo =  UNIX.DICTIONARY         ;* Default to unix path for dictionary
                    END
                END

            END ELSE
                dictInfo =  UNIX.DICTIONARY       ;* Default to unix path for dictionary if not a table
            END

        END         ;*Shek

*
* Check status of data for being XML type before reading stub

        STATUS dataStatus FROM F.DATA.TEST ELSE dataStatus = ""
        CLOSE F.DATA.TEST     ;* Ensure data file now closed
        DATA.DB.TYPE = dataStatus<21>

        IF DATA.DB.TYPE[1,1] EQ "X" THEN

            READ stubDataRecord FROM F.PRODUCT.DIRECTORY,UNIX.DATA.NAME  THEN

                stubDataRecord = CHANGE(TRIM(stubDataRecord)," ",@AM)
                DEL stubDataRecord<1>   ;* Lose JBC__SOB

                dataFunction = stubDataRecord<1>  ;* Save driver initialisation Function
                DEL stubDataRecord<1>   ;* Remove driver function

                dataInfo = CHANGE(stubDataRecord,@AM," ")   ;* Rest of info is the required data table arguments

                IF NOT(useRealFiles) AND preserveOption EQ "" THEN
                    DELETE F.PRODUCT.DIRECTORY,UNIX.DATA.NAME         ;*Delete the data stub file
                END

            END ELSE
                dataInfo = "" ;* Appears to be no data file ?
            END

            R.VOC<1> = vocTableIdentifier         ;* Set voc table identifier as STUB or TABLE
            R.VOC<2> = dataFunction     ;* Driver initialisation function
            R.VOC<3> = dictInfo         ;* Dict table driver arguments
            R.VOC<4> = dataInfo         ;* Data table driver arguments
            WRITE R.VOC TO F.VOC,CREATE.NAME      ;*Update VOC as TABLE entry

        END
    END

*
* Recheck can open both the dict and data voc entries for the new file
*
    ERROR.MSG = ""

    OPEN 'DICT',CREATE.NAME TO F.DICT.TEST ELSE
        ERROR.MSG = "Unable to open the file: ":CREATE.NAME:" [":R.VOC<3>:"]   "
        R.VOC<3> = ""         ;* Clear out voc pointer
        WRITE R.VOC ON F.VOC, CREATE.NAME
    END

    OPEN 'DATA',CREATE.NAME TO F.DATA.TEST ELSE
        IF R.VOC<1>[1,1] EQ "F" THEN
            ERROR.MSG = "Unable to open the file: ":CREATE.NAME:" [":R.VOC<2>:"]   "
        END ELSE
            ERROR.MSG = "Unable to open the file: ":CREATE.NAME:" [":R.VOC<4>:"]   "
        END
        DELETE F.VOC, CREATE.NAME       ;* No point remove VOC entry for data file
    END

    IF ERROR.MSG THEN         ;* Open errors
        GOTO PROGRAM.ERROR    ;* Tell them
    END

RETURN
*
*------------------------------------------------------------------------
*
CREATE.DATA.FILE:

* Input is CREATE.NAME and CREATE.OPTIONS

    DATA.FILE.NAME = CREATE.NAME
    GOSUB DETERMINE.DATA.PATH ;* Return DATA.PATH and UNIX.DATA.NAME
    IF verbose THEN
        CRT "Creating data for ": DATA.FILE.NAME
        CRT "Using file path         ": DATA.PATH
        CRT "Using database type     ": DB.TYPE
        IF DB.TYPE[1,1] = "X" THEN
            CRT "Using tablename         ": DB.TABLE.NAME
            IF DB.SCHEMA.NAME NE "" THEN
                CRT "Using schema            ": DB.SCHEMA.NAME
            END
        END
    END

    GOSUB GET.PGM.DETAILS     ;* Read PGM.FILE and return PGM record

    DB.XSDSCHEMA.NAME = pgmId:".xsd"    ;* Configure for XSD Schema look up

    BEGIN CASE
        CASE controlType = "UD"
            CREATE.COMMAND = 'CREATE.FILE DATA ':DATA.PATH:" TYPE=UD"

        CASE DB.TYPE[1,1] = "X" AND NOT(IS.RGS) AND NOT(FILE.CREATE.OPTION )        ;*Special file

            IF pgmType NE "" AND INDEX('HULWD', pgmType, 1) AND NOT(INDEX(pgmInfo,".BLB",1)) THEN       ;* file should be created as BLOB type when set as .BLB

* Create table of XML type
                CREATE.COMMAND = 'CREATE.FILE DATA ':DATA.PATH:" TYPE=":DB.TYPE:" TABLE=":DB.TABLE.NAME

* Append Company Schema if configured

                IF DB.SCHEMA.NAME NE "" THEN
                    CREATE.COMMAND := " SCHEMA=":DB.SCHEMA.NAME
                    IF useCompanyTableSpace THEN
                        CREATE.COMMAND := " DATATABLESPACE=":DB.SCHEMA.NAME:"DATA"
                        CREATE.COMMAND := " INDEXTABLESPACE=":DB.SCHEMA.NAME:"INDEX"
                    END
                END

* Append XSD Schema for registeration if configured

                useXSDSchema = 0  ;* Assume not XSD (or at least not enabled
                registerXSDSchema = 0       ;* Asumme not to register XSD schema

                IF checkXSDSchema THEN

* Check if XSD schema configured for this table type

                    READ schemaRecord FROM F.SCHEMA.FILE, DB.XSDSCHEMA.NAME THEN

                        IF INDEX(schemaRecord,'<xsd:hasProperty name="useschema" value="yes"/>',1) THEN
                            useXSDSchema = 1
                        END

                        IF INDEX(schemaRecord,'<xsd:hasProperty name="register" value="yes"/>',1) THEN
                            registerXSDSchema = 1
                        END

                    END
                END

                IF useXSDSchema THEN

                    CREATE.COMMAND := " XSDSCHEMA=":DB.XSDSCHEMA.NAME

* Skip schema registeration unless configured

                    IF NOT(registerXSDSchema) THEN

                        CREATE.COMMAND := " XSDSCHEMAREG=NO"
                    END
                END

            END ELSE

* No xml type (usually BLOB)

                CREATE.COMMAND = 'CREATE.FILE DATA ':DATA.PATH:" TYPE=":DB.TYPE:" TABLE=":DB.TABLE.NAME

                IF INDEX(CHANGE(UNIX.DATA.NAME,'_','.'),"JOB.LIST",1) THEN

* For Job Lists use VARCHAR Binary if supported

                    CREATE.COMMAND := " NOXMLSCHEMA=WORK"

                END ELSE

                    CREATE.COMMAND := " NOXMLSCHEMA=YES"        ;*
                END

* Append Company Schema if configured

                IF DB.SCHEMA.NAME NE "" THEN
                    CREATE.COMMAND := " SCHEMA=":DB.SCHEMA.NAME
                    IF useCompanyTableSpace THEN
                        CREATE.COMMAND := " DATATABLESPACE=":DB.SCHEMA.NAME:"DATA"
                        CREATE.COMMAND := " INDEXTABLESPACE=":DB.SCHEMA.NAME:"INDEX"
                    END
                END

            END

        CASE DB.TYPE = "JRFS"     ;* If JRFS setup database
            JMODULO = CREATE.OPTIONS[" ",2,1]
            CREATE.COMMAND = 'CREATE.FILE DATA ':DATA.PATH:" TYPE=":DB.TYPE:" DATAMOD=":JMODULO

        CASE DB.TYPE[1,1] = "J" OR IS.RGS OR FILE.CREATE.OPTION ;*if J4 database or RGS file ...or create with options specified
            JMODULO = CREATE.OPTIONS[" ",2,1]
            IF DB.TYPE[1,2] NE "JR" THEN
                CREATE.COMMAND = 'CREATE.FILE DATA ':DATA.PATH:" ":JMODULO
            END ELSE
                CREATE.COMMAND = 'CREATE.FILE DATA ':DATA.PATH:" TYPE=":DB.TYPE     ;* No modulo for JR files just type
            END

    END CASE
    IF verbose THEN CRT "Using command ":CREATE.COMMAND
    setInfo = '' ;* To hold the create.file result
    EXECUTE CREATE.COMMAND SETTING setInfo CAPTURING OUTPUT ;* Execute create file

    IF RUNNING.IN.TAFJ THEN
        CRT OUTPUT
    END ELSE
        RELEASE F.LOCKING.FILE, LOCK.ID     ;* release the lock
        IF setInfo<1,1> NE 417 AND SEQ.NUM THEN       ;* If not successful and when current SEQ.NUM already exists
            GOTO CREATE.DATA.FILE    ;* Retry to get next (unique) data file name
        END ELSE
            CRT OUTPUT ;* if file creation is sucessful
        END
    END
*
RETURN
*
*------------------------------------------------------------------------

GET.PGM.DETAILS:

    pgmId = DATA.FILE.NAME['.',2,99]    ;* Lose the FBNK
    pgmId = pgmId['$',1,1]    ;* Lose the $NAU, $ARC, $HIS

    pgmRecord = ""
    READ.ERR = ""
    CALL F.READ("F.PGM.FILE",pgmId,pgmRecord,F.PGM.FILE,READ.ERR)     ;* Read PGM.FILE (not sure if this is read first time in the current txn or already read before)

    IF READ.ERR THEN          ;* On failure
        READ.ERR = ""
        READ pgmRecord FROM F.PGM.FILE,pgmId ELSE ;* Try reading directly from Disk once just in case FWT is already loaded with Record not found error but subsequently there has been a direct WRITE.
            READ.ERR = "RECORD NOT FOUND"         ;* Definitely an Error
        END
    END
*
    IF READ.ERR AND FILE.TO.CREATE NE 'F.RELEASE.DATA' THEN ;* during Upgrade or Product release the files get created before the data records are getting released, so PGM.FILE will be copied only bit later
*
        OPEN '','F.RELEASE.DATA' TO F.RELEASE.DATA ELSE     ;* Open F.RELEASE.DATA to get PGM.FILE
            ERROR.MSG = "Unable to open 'F.RELEASE.DATA'"
            GOTO PROGRAM.ERROR
        END
        releaseRecordId = "F.PGM.FILE>":pgmId     ;* id will be of the format F.PGM.FILE>ACCOUNT, F.PGM.FILE>CUSTOMER etc
        READ pgmRecord FROM F.RELEASE.DATA,releaseRecordId ELSE       ;* read PGM.TYPE record from RELEASE.DATA
            pgmRecord = ""
        END
    END

    IF pgmRecord EQ '' AND pgmId[5] = ".LIST" THEN          ;* still no pgmrecord loaded and file name end with ".LIST"
        pgmId = pgmId[1, LEN(pgmId)-5]  ;* trim the ".LIST" from the file name
        READ pgmRecord FROM F.PGM.FILE,pgmId ELSE ;* read the trimmed file name in PGM record
            pgmRecord = ""    ;* for the file having no pgm entry, pgmRecord should be equal to null
        END
    END
*
    pgmType = pgmRecord<1>
    pgmInfo = pgmRecord<EB.PGM.ADDITIONAL.INFO>   ;*BLOB file creation

RETURN
*
*------------------------------------------------------------------------
*
CREATE.DICTIONARY:

* Input is DICT.FILE.NAME

*
* Create dictionary locally first
*
    GOSUB DETERMINE.DICTIONARY.PATH     ;*  Returns DICTIONARY.PATH and UNIX.DICT.NAME

    IF verbose THEN
        CRT "Creating dictionary for ": DICT.FILE.NAME
        CRT "Using file path         ": DICTIONARY.PATH
        CRT "Using database type     ": DB.TYPE
        IF DICTIONARY.DB.TYPE[1,1] = "X" THEN
            CRT "Using tablename         ": DB.TABLE.NAME
        END
    END

    BEGIN CASE
        CASE DB.TYPE = "JRFS"      ;* If JRFS setup database
            CREATE.COMMAND = 'CREATE.FILE DICT ':DICTIONARY.PATH:" TYPE=":DB.TYPE:" DICTMOD=1"

        CASE FILE.CREATE.OPTION OR IS.RGS OR controlType ="UD" OR DB.TYPE[1,1] = "J" OR DICTIONARY.DB.TYPE[1,1] ="J"        ;* if it's a plain j4 database or filetype 1,19 or UD OR RGS type create it as j4 file or  if F.SPF still hash type
            CREATE.COMMAND = 'CREATE.FILE DICT ':DICTIONARY.PATH:' 1'

        CASE DICTIONARY.DB.TYPE[1,1] = "X"  ;* Only create as XML if dictionary of F.SPF is type 'X'
            CREATE.COMMAND = 'CREATE.FILE DICT ':DICTIONARY.PATH:" TYPE=":DB.TYPE:" TABLE=":DB.TABLE.NAME:" NOXMLSCHEMA=YES"

        CASE DB.TYPE = "UD"
            CREATE.COMMAND = 'CREATE.FILE DICT ':DICTIONARY.PATH:" TYPE=UD"

    END CASE

    IF verbose THEN CRT "Using command ":CREATE.COMMAND
    SetInfo = '' ;* To hold the create.file results
    EXECUTE CREATE.COMMAND SETTING SetInfo  CAPTURING OUTPUT          ;* Execute create file

    IF SetInfo<1,1> NE 417 AND SEQ.NUM AND NOT(RUNNING.IN.TAFJ) THEN       ;* If not successful and when SEQ.NUM already exists
        RELEASE F.LOCKING.FILE, LOCK.ID ;* release the lock
        GOTO CREATE.DICTIONARY   ;* Retry to get next (unique) dict file name
    END ELSE
        CRT OUTPUT  ;* if file creation is sucessful
    END

    IF NOT(RUNNING.IN.TAFJ) THEN

        READ R.VOC FROM F.VOC, DICT.FILE.NAME ELSE    ;* Create a temporary 'Fpointer' voc entry for dictionary
            R.VOC = "F"
        END

        R.VOC<2> = ""
        R.VOC<3> = DICTIONARY.PATH:"]D"
        WRITE R.VOC TO F.VOC, DICT.FILE.NAME
    END
* Remove auto generated Q pointer from created dictionary and add an @ID entry

    OPEN 'DICT',DICT.FILE.NAME TO F.DICT.FILE.NAME THEN
        DELETE F.DICT.FILE.NAME, FIELD(UNIX.DICT.NAME,"]",1)          ;* Remove reflexive Qptr
        R.DICT = "D"          ;* Create @ID entry
        R.DICT<1> = "D"
        R.DICT<2> = 0
        R.DICT<4> = "@ID"
        R.DICT<5> = "10L"
        R.DICT<6> = "S"
        WRITE R.DICT TO F.DICT.FILE.NAME, "@ID"   ;* Write the @ID entry
    END
    IF NOT(RUNNING.IN.TAFJ) THEN
        RELEASE F.LOCKING.FILE, LOCK.ID     ;* release the lock
    END
*
RETURN
*
*------------------------------------------------------------------------
*
DETERMINE.PRODUCT.DIRECTORY:
*
    PRODUCT.DIRECTORY = ""    ;* Final resting place

    DOT.DIRECTORY = R.SPF.SYSTEM<SPF.DATA.ACC.NAME>
    DOTS = COUNT(DOT.DIRECTORY,'.')
    DOTS = INDEX(DOT.DIRECTORY,'.',DOTS)
*
    BEGIN CASE
*
        CASE SPECIAL AND FILE.CREATE.OPTION ;* if it is a spl and if path name and modulo specified in argument (i.e. not taken from FILE.CONTROL)

            FILE.NAME = CREATE.NAME         ;* create the file name without prefix ( not F. or FXXX. )
            PRODUCT.DIRECTORY = ARC.PATHNAME          ;* take the value specified in the argument
            CREATE.OPTIONS = R.FILE.CONTROL(EB.FILE.CONTROL.TYPE):" ":ARC.MODULO    ;*take the modulo specified in the argument
        CASE SPECIAL
*
* Special files should be created in the top level directory, e.g. bnk
* If a special file, reset FILE.NAME to the actual file name
*
            FILE.NAME = CREATE.NAME
            PRODUCT.DIRECTORY = '..'
*
        CASE HELPTEXT

* If file is a helptext file, create it in the helptext directory

            PRODUCT.DIRECTORY = DOT.DIRECTORY[1,DOTS]:'help'

        CASE ARCHIVE

* If file is an archive file, create it in the specified archive
* directory or in xx.arc if that is null

            PRODUCT.DIRECTORY = ARC.PATHNAME
            IF PRODUCT.DIRECTORY EQ "" THEN
                PRODUCT.DIRECTORY = DOT.DIRECTORY[1,DOTS]:'arc'
            END
*
* If the file is an archive file, get the type and modulo from the
* live record (rather than from FILE.CONTROL), unless the required type
* and modulo have been passed from the application
*
            IF ARC.TYPE EQ "" OR ARC.MODULO EQ "" THEN

                LIVE.FILE = FILE.NAME[1,LEN(FILE.NAME)-4]       ;* Live file name is file name without prefix
                LIVE.FILE<2> = 'NO.FATAL.ERROR'       ;*file might not exist don't fatal
                IF LIVE.FILE[1,2] NE 'F.' THEN        ;* add 'F.' if not present
                    LIVE.FILE = 'F.':LIVE.FILE        ;* Add 'F.' to Live file name
                END
                F.LIVE.FILE = ''
                CALL OPF(LIVE.FILE,F.LIVE.FILE)       ;*open the file
                IF ETEXT = '' THEN
                    STATUS LIVE.STATUS FROM F.LIVE.FILE THEN    ;*get the status
                        IF LIVE.STATUS<21> EQ 'DISTRIB'  THEN   ;*distributed file
                            FILE.CTRL.ID = FIELD(LIVE.FILE,'.',2,999)     ;*id without company mnemonic
                            CALL CACHE.READ('F.FILE.CONTROL',FILE.CTRL.ID,R.LIV.FILE.CTRL,FILE.ERR)     ;*read the file control
                            IF NOT(FILE.ERR)  THEN    ;*file control exist
                                CREATE.OPTIONS = R.LIV.FILE.CTRL<EB.FILE.CONTROL.TYPE>:" ":R.LIV.FILE.CTRL<EB.FILE.CONTROL.MODULO>    ;*get the type and modulo from live file's file control
                            END
                        END
                        BEGIN CASE
                            CASE ARC.TYPE       ;* If TYPE is defined in ARCHIVE record
                                IF LIVE.STATUS<21> NE 'DISTRIB' THEN          ;*If the underlying live file is not distributed
                                    ARC.MODULO = LIVE.STATUS<22>    ;* Use the MODULO of live file
                                END ELSE
                                    ARC.MODULO = FIELD(CREATE.OPTIONS,' ',2)  ;*If the underlying live file is distributed
                                END
                            CASE ARC.MODULO     ;* If MODULO is specified in ARCHIVE record
                                IF LIVE.STATUS<21> NE 'DISTRIB' THEN          ;*If the underlying live file is not distributed
                                    ARC.TYPE = LIVE.STATUS<21>      ;* Use the TYPE of live file
                                END ELSE
                                    ARC.TYPE = FIELD(CREATE.OPTIONS,' ',1)    ;*If the underlying live file is distributed
                                END
                            CASE OTHERWISE      ;* If both TYPE and MODULO are not specified in ARCHIVE record
                                IF LIVE.STATUS<21> NE 'DISTRIB' THEN          ;*If the underlying live file is not distributed
                                    ARC.TYPE = LIVE.STATUS<21>      ;* Use the TYPE of live file
                                    ARC.MODULO = LIVE.STATUS<22>    ;* Use the MODULO of live file
                                END ELSE
                                    ARC.TYPE =  FIELD(CREATE.OPTIONS,' ',1)   ;*If the underlying live file is distributed
                                    ARC.MODULO = FIELD(CREATE.OPTIONS,' ',2)  ;*If the underlying live file is distributed
                                END
                        END CASE
                    END
                END ELSE
                    ETEXT = ''    ;*clear it off don't carry forward
                END
            END

            CREATE.OPTIONS = ARC.TYPE:' ':ARC.MODULO
*
        CASE OTHERWISE
*
* If the pathname was passed, use this
*
            PRODUCT.DIRECTORY = ARC.PATHNAME
            IF PRODUCT.DIRECTORY EQ "" THEN

                PRODUCT.ACCOUNT.LIST = R.SPF.SYSTEM<SPF.PRODUCT.ACCOUNT>

                LOOP
                    PATH = REMOVE(PRODUCT.ACCOUNT.LIST,D)
                UNTIL PATH EQ"" OR PRODUCT.DIRECTORY NE "" DO
                    UFD = OCONV(PATH[3],"MLC")        ;* Last bit eg /fx (in lower case)
                    IF UFD = "/":PRODUCT OR UFD = "\":PRODUCT THEN
                        PRODUCT.DIRECTORY = PATH
                    END
                REPEAT
            END
*
            IF PRODUCT.DIRECTORY EQ "" THEN ;* Check if we require individual

                READ R.VOC FROM F.VOC, "F.SPF" ELSE R.VOC = ""
                IF NOT(IS.RGS) AND controlType  NE "UD" AND DB.TYPE[1,1] NE "J" THEN          ;* in all these cases file will be created as J4 - identify J4/JR type area with DB.TYPE only
                    IF CHANGE(R.VOC<2>[9],'_','.') NE "/eb/F.SPF" THEN    ;* product directories
                        PRODUCT.DIRECTORY = R.SPF.SYSTEM<SPF.DATA.ACC.NAME>         ;* Put file in top level directory
                    END
                END ELSE
                    useRealFiles = 1        ;*Build the table list from product directory not from stub view
                END
                IF PRODUCT.DIRECTORY EQ "" THEN       ;* Set up default
                    PRODUCT.DIRECTORY = R.SPF.SYSTEM<SPF.DATA.ACC.NAME>:"/":PRODUCT
                END

            END
    END CASE
*
    OPEN PRODUCT.DIRECTORY TO F.PRODUCT.DIRECTORY ELSE

        IF SPECIAL THEN
            ERROR.MSG = "Unable to open product directory ":PRODUCT.DIRECTORY
            GOTO PROGRAM.ERROR
        END

        EXECUTE "CREATE-FILE DATA ":PRODUCT.DIRECTORY:" TYPE=UD"  CAPTURING VIEW

        OPEN PRODUCT.DIRECTORY TO F.PRODUCT.DIRECTORY ELSE
            ERROR.MSG = "Unable to open product directory ":PRODUCT.DIRECTORY
            GOTO PROGRAM.ERROR
        END
*CLOSE F.PRODUCT.DIRECTORY ;* Leave product directory open for later
    END
*
RETURN
*
*------------------------------------------------------------------------
DETERMINE.DATA.PATH:

    UNIX.DATA.NAME = CREATE.NAME        ;* FBNK.XXXXXX.XXXX.XXX
    DB.TABLE.NAME = ""
    IF RUNNING.IN.TAFJ THEN
        DATA.PATH = UNIX.DATA.NAME
    END ELSE
        DATA.PATH = PRODUCT.DIRECTORY:"/":UNIX.DATA.NAME
    END
    filePrefix = "" ;* filePrefix is initialised to Null
    SEQ.NUM = 0     ;* initialise
    IF DB.TYPE[1,1] = "X" THEN

        filePath = CHANGE(CHANGE(PRODUCT.DIRECTORY,"/",@AM),"\",@AM)
        filePart = DCOUNT(filePath,@AM)
        filePrefix = DOWNCASE(filePath<filePart>) ;* Subdirectory from product directory path downcased
        IF filePrefix[".",2,1] NE "" THEN
            filePrefix = DOWNCASE(filePrefix[".",2,1])      ;* Use help/jnl/arc from bnk.help, bnk.jnl or bnk.arc
        END

        IF useDbSchema THEN

            IF UNIX.DATA.NAME[1,2] = "F." THEN
                checkLen = 24
                DB.TABLE.NAME = UNIX.DATA.NAME    ;* F.ACCOUNT
            END ELSE
                checkLen = RDBMS.MAX.TABLENAME
                UNIX.DATA.NAME = UNIX.DATA.NAME[".",2,99]   ;* Remove FBNK to leave ACCOUNT
                DB.TABLE.NAME = UNIX.DATA.NAME

                FIND DB.TABLE.NAME IN invalidTableNames SETTING invalidTableName THEN
                    DB.TABLE.NAME = filePrefix:DB.TABLE.NAME          ;* Use prefix to avoid reserved table names
                    UNIX.DATA.NAME = DB.TABLE.NAME
                    checkLen = 22
                END
            END

        END ELSE
            DB.TABLE.NAME = filePrefix : UNIX.DATA.NAME     ;* acFBNK.ACCOUNT
            checkLen = 22
        END
    END ELSE
        checkLen = 99         ;* Allow large file name size for J types
    END

    IF NOT(useVocName) THEN checkLen = 12         ;* Force name abstraction limit to 12 chars

    IF RUNNING.IN.TAFJ THEN
* conversion is not required in TaFJ from '-<>.&$' TO '_____#' IN UNIX.DATA.NAME
* also file sequence number will be managed by TAFJ
        DB.TABLE.NAME = UNIX.DATA.NAME
    END ELSE
        FLAG.UD.DATA = 0
        SAVE.UNIX.DATA.NAME = UNIX.DATA.NAME              ;* Save UNIX.DATA.NAME
        SAVE.DB.TABLE.NAME = filePrefix:UNIX.DATA.NAME     ;* Save the table name with product
        IF LEN(UNIX.DATA.NAME) GT checkLen OR ((LEN(SAVE.DB.TABLE.NAME) GT checkLen) AND useRealFiles) THEN  ;* When then length of table/data name exceeds max length truncation is happened
                        
* Work out a truncated name for the dictionary if greater than allowed table name length

            tableList = ""
            IF useRealFiles THEN
                EXECUTE "SELECT ":PRODUCT.DIRECTORY RTNLIST tableList CAPTURING viewInfo      ;* Build list of files in produce directory
            END ELSE
                EXECUTE "SELECT STUBVIEW " RTNLIST tableList CAPTURING viewInfo     ;* Build list of tables from view of stub table
                IF controlType = 'UD' THEN
                    FLAG.UD.DATA = 1
                END
            END

            IF NOT(FLAG.UD.DATA) THEN
                SAVE.UNIX.DATA.NAME = SAVE.UNIX.DATA.NAME[1,9]:"000"          ;* Convert to F.XXXXXXX000
                SEQ.NUM = 0
                LOOP
                    checkName = SAVE.UNIX.DATA.NAME
                    IF NOT(useRealFiles) THEN
                        CONVERT '-<>.&$' TO '_____#' IN checkName   ;* Replace dot's,hypen etc before prepending possible schema
                        IF DB.SCHEMA.NAME NE "" THEN
                            checkName = DB.SCHEMA.NAME:".":SAVE.UNIX.DATA.NAME
                        END
                        checkName = UPCASE(checkName)     ;* Stubfile names return in upper case
                    END
                    FIND checkName IN tableList SETTING itemFound ELSE itemFound = 0
                WHILE itemFound DO
                    SEQ.NUM++         ;* Increment to next sequence
* The file sequence should not exceeds 9999
                    IF SEQ.NUM > '9999' THEN    ;* If sequence exceeds 9999
                        TEXT = "FILE SEQUENCE SHOULD NOT EXCEED '9999' "
                        CALL FATAL.ERROR("EBS.CREATE.FILE")         ;* throw fatal error
                    END
                    IF SEQ.NUM > '999' THEN     ;* If sequence exceeds 999
*Add 4 digit sequence number to first 8 digit of actual file to create 9999 number of files
                        SAVE.UNIX.DATA.NAME = SAVE.UNIX.DATA.NAME[1,8]:FMT(SEQ.NUM,"4'0'R")       ;*file name is the first 8 character of file name with 4 digit sequence number
                    END ELSE
                        SAVE.UNIX.DATA.NAME = SAVE.UNIX.DATA.NAME[1,9]:FMT(SEQ.NUM,"3'0'R")       ;*file name is the first 9 character of file name with 3 digit sequence number
                    END
                REPEAT
            END
        END ELSE
            CONVERT '-<>.&$' TO '_____#' IN SAVE.UNIX.DATA.NAME      ;* Replace dot's,hypen etc to avoid meta characters in path
        END

*   In stub file architecture, always prefix product with Table name
        UNIX.DATA.NAME = SAVE.UNIX.DATA.NAME    ;* Restore the truncated data name
        IF useRealFiles THEN
            DB.TABLE.NAME = filePrefix:UNIX.DATA.NAME ;* Use prefix for real generated names
        END ELSE
            DB.TABLE.NAME = UNIX.DATA.NAME
        END
        CONVERT '-<>.&$' TO '_____#' IN DB.TABLE.NAME ;* Replace dot's,hypen etc
        DATA.PATH = PRODUCT.DIRECTORY:"/":UNIX.DATA.NAME
        LOCK.ID = UNIX.DATA.NAME  ;* Make the exact data file name as lock id
        READU dummy FROM F.LOCKING.FILE,LOCK.ID LOCKED          ;* If same data file is already obtained by someone
            GOTO DETERMINE.DATA.PATH   ;* Retry to get next (unique) data file name
        END ELSE
            NULL        ;* Lock the record
        END
    END

RETURN
*================================================================================
DETERMINE.DICTIONARY.PATH:

    UNIX.DICT.NAME = DICT.FILE.NAME:']D'          ;* Start with the full thing F.XXXX.XXXXX.XXXX]D

    IF NOT(useVocName) THEN checkLen = 14 ELSE checkLen = 99

    IF DICTIONARY.DB.TYPE[1,1] = "X" AND checkLen GT RDBMS.MAX.TABLENAME THEN checkLen = RDBMS.MAX.TABLENAME

    IF RUNNING.IN.TAFJ THEN

        UNIX.DICT.NAME = UNIX.DICT.NAME["]",1,1]      ;* Remove the "]D" for file/table creation and table name
*  conversion is not required in TAFJ from  '-<>.&$' TO '_____#' IN UNIX.DICT.NAME
*  also file sequence number is handled by TAFJ
        DB.TABLE.NAME = UNIX.DICT.NAME            ;* DB.TABLE.NAME is not used in TAFJ but we are keeping this is for future use.
        DICTIONARY.PATH = UNIX.DICT.NAME
        UNIX.DICT.NAME = UNIX.DICT.NAME:"]D"          ;* Reappend ]D


    END ELSE

        SEQ.NUM = 0     ;* initialise
        FLAG.UD.DICT = 0
        IF LEN(UNIX.DICT.NAME) GE checkLen THEN

* Work out a truncated name for the dictionary if greater than allowed table name length

            IF DICTIONARY.DB.TYPE[1,1] NE "X" OR useRealFiles THEN
                EXECUTE "SELECT ":DICTIONARY.DIRECTORY RTNLIST tableList CAPTURING viewInfo   ;* Build list of files in produce directory
            END ELSE
                EXECUTE "SELECT STUBVIEW " RTNLIST tableList CAPTURING viewInfo     ;* Build list of tables from view of stub table
                IF controlType = 'UD' THEN
                    UNIX.DICT.NAME = UNIX.DICT.NAME:"]D"
                    FLAG.UD.DICT = 1
                END
            END
                        
            IF NOT(FLAG.UD.DICT) THEN
                UNIX.DICT.NAME = UNIX.DICT.NAME[1,9]:"000"          ;* Convert to F.XXXXXXX000
                SEQ.NUM = 0
                LOOP
                    checkName = UNIX.DICT.NAME
                    IF NOT(useRealFiles) THEN
                        checkName = "D_":UNIX.DICT.NAME   ;* Convert to D_F.XXXXXX000
                        CONVERT '-<>.&$' TO '_____#' IN checkName   ;* Replace dot's,hypen etc
                    END ELSE
                        checkName = UNIX.DICT.NAME:"]D"
                    END
    
                    FIND checkName IN tableList SETTING itemFound ELSE itemFound = 0
    
                WHILE itemFound DO
                    SEQ.NUM++         ;* Increment to next sequence
* The file sequence should not exceeds 9999
                    IF SEQ.NUM > '9999' THEN    ;* If sequence exceeds 9999
                        TEXT = "FILE SEQUENCE SHOULD NOT EXCEED '9999' "
                        CALL FATAL.ERROR("EBS.CREATE.FILE")         ;* throw fatal error
                    END
                    IF SEQ.NUM > '999' THEN     ;* If sequence exceeds 999
* Add 4 digit sequence number to first 8 digit of actual file to create 9999 number of files
                        UNIX.DICT.NAME = UNIX.DICT.NAME[1,8]:FMT(SEQ.NUM,"4'0'R")       ;*file name is the first 8 character of file name with 4 digit sequence number
                    END ELSE
                        UNIX.DICT.NAME = UNIX.DICT.NAME[1,9]:FMT(SEQ.NUM,"3'0'R")       ;*file name is the first 9 character of file name with 3 digit sequence number
                    END
    
                REPEAT
            END

        END ELSE

            CONVERT '-<>.&$' TO '_____#' IN UNIX.DICT.NAME      ;* Replace dot's,hypen to avoid metachars in path

        END

        UNIX.DICT.NAME = UNIX.DICT.NAME["]",1,1]      ;* Remove the "]D" for file/table creation and table name
        DB.TABLE.NAME = UNIX.DICT.NAME
        CONVERT '-<>.&$' TO '_____#' IN DB.TABLE.NAME ;* Replace dot's,hypen etc

        DICTIONARY.PATH = DICTIONARY.DIRECTORY:"/":UNIX.DICT.NAME
        UNIX.DICT.NAME = UNIX.DICT.NAME:"]D"          ;* Reappend ]D
        LOCK.ID = UNIX.DICT.NAME  ;* Make the exact dict file name as lock id

        READU dummy FROM F.LOCKING.FILE, LOCK.ID LOCKED         ;* If same dict name is already obtained by someone
            GOTO DETERMINE.DICTIONARY.PATH  ;* Retry to get next (unique) dict file name
        END ELSE
            NULL        ;* Lock the record
        END
    END

RETURN
*------------------------------------------------------------------------
*
CREATE.PSUEDO.STUBFILE:

* Create psuedo stub file to STUBFILE for testing existing table names

    IF DB.TYPE[1,1] = "X" AND NOT(useRealFiles) THEN

        stubFileName = "STUBVIEW"

* Update STUBVIEW file if it is not exists already or its not having suitable format
* (KEY clause is not supportable by new framework driver from R10 onwards)

        READ stubRecord FROM F.VOC, stubFileName THEN       ;* If file exists
            FINDSTR 'KEY' IN stubRecord<4> SETTING POS THEN ;* Not having correct format
                stubRecord<4> = "V_STUBFILES"     ;* changed to work with the new framework driver
                WRITE stubRecord ON F.VOC, stubFileName
            END
        END ELSE    ;* No stubview file exists already
            stubRecord = "TABLE"
            stubRecord<2> = DB.TYPE:"Init"
            stubRecord<3> = ""
            stubRecord<4> = "V_STUBFILES"         ;* changed to work with the new framework driver
            WRITE stubRecord ON F.VOC, stubFileName
        END

        OPEN stubFileName TO F.STUBFILES ELSE
            ERROR.MSG = "Unable to open ":stubFileName
            GOTO PROGRAM.ERROR
        END

        CLOSE F.STUBFILES
    END

RETURN
*
*------------------------------------------------------------------------
*
PROGRAM.ERROR:
*
    GOTO PROGRAM.ABORT
*
*------------------------------------------------------------------------
*
PROGRAM.ABORT:
*
RETURN TO PROGRAM.ABORT
*
*------------------------------------------------------------------------
*
PROGRAM.END:
*
RETURN
*------------------------------------------------------------------------

END
