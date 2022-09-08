* @ValidationCode : MjotMTYxNjI1MzI2MDpjcDEyNTI6MTU2ODc5MzY3OTA1Nzpka2FzdGh1cmk6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkxMC4yMDE5MDkwNS0xMDU0Oi0xOi0x
* @ValidationInfo : Timestamp         : 18 Sep 2019 13:31:19
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : dkasthuri
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190905-1054
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 22 07/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>1460</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.SystemTables
SUBROUTINE CREATE.FILES
************************************************************************
*
* Routine to create files with company mnemonics.
* All files in f.file.control can be created or just the specified ones
* or a select list can be given.  File names entered or given in a select
* list must be the name of the file as it is on F.FILE.CONTROL
*
*------------------------------------------------------------------------
*
* Modifications
* -------------
*
* 06/07/87 - EBS87333
*            Dictionaries for filenames like F.XXXXX were not being
*            created, although the voc record was updated with the
*            dictionary name (D_F.XXXXX).
*            Changed routine CREATE.FILE so that a check is
*            made on fld 3 (dictionary name) of the voc record for the
*            file, and if it is null then the dictionary is created.
*
* 30/11/87 - CI8700952   (AST)
*            Routine CREATE.FILE was changed so that any F.datafile
*            voc record referencing a dictionary only (field 2 is
*            null) is deleted from the voc after the file has been
*            created.
*
* 01/12/87 - EB8701099
*            Remove hardcoded CREATE.FILE routine and replace with
*            insert I_CREATE.FILE.
*
* 14/06/88 - EB8800639
*            Put the intelligence of which files ($NAU, $HIS, company
*            mnemonic, etc.) into EBS.CREATE.FILE.
*
* 20/09/94 - GB9400926
*            If the select list is in the format REL.nn.nn.n.FILES, do
*            not switch on a COMO and then spool it as a report, as this
*            then closes the COMO for the release, so that from this
*            point on in the release there is no history.
*
* 24/07/00 - GB0001909
*            Add warning if no list or individual file name entered
*            before trying to create all files in F.FILE.CONTROL
*
* 23/08/02 - GLOBUS_EN_10001028
*          Conversion Of all Error Messages to Error Codes
* 26/12/02 - CI_10005835
*       The printer channnel used is 0 instead of 1.
* 11/07/03 - GLOBUS_CI_10010730
*            Changed DELETE COMO to EXECUTE 'COMO DELETE ' for
*            jBASE compatibility
*
* 25/05/04 - BG_100006673
*            Changes done to stop the .list files of m/t EOD jobs from
*            getting created during the GLOBUS.RELEASE
*
* 14/02/07 - GLOBUS_BG_100012999
*            extend field length for list name to all for sar references
*            use in dim.test.cds
*
* 12/03/07 - EN_10003192
*            DAS Implementation
*
* 21/06/07 - BG_100014340
*            Changes done to populate the fields FINANCIAL.MNE, FINIANCIAL.COM
*            in R.COMPANY common variable, when it is null. This will solve
*            the crash while doing GLOBUS.RELEASE in upgrading from lower release
*            to higher release, before running the actual converison to
*            populate FINANCIAL.MNE/COM in COMPANY record.
*
* 26/06/07 - BG_100014420
*            Remove redundant infinite loop
*
* 20/02/08 - BG_100017190
*            MATREADU single threads the upgrade service.Hence changing
*            to MATREAD for multi threading to work when upgrade service is run.
*
* 26/12/08 - BG_100021444
*            Input LIST NAME can also have the special character
*
* 28/05/09 - CI_10063206
*            If this routine is called from T24.UPGRADE, the list name is of the form:REL.<RELEASE.NO>.FILES<SESSION.NO>
*            When the last five characters of list name is matched against "FILES", it fails and starts its own COMO.
*            Hence COMO is not updated properly while running the service T24.UPGRADE.
*            REF : HD0919994
*
*
* 18/12/09 - BG_100026275
*            T24 Session number used instead of port number
*
* 17/07/12 - Task 444986 / Defect 440909
*            Maximum lenght of LIST NAME is increased from 40 to 55.
*
* 05/09/13 - Task:775790 / Defect:770049
*            Maximum lenght of FILE.NAME is increased to 40.
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT().
*
* 10/08/15 - Task 1422796 / Enhancement 1276655
*            Errors/warnings can be routed to TAF log.
*
* 19/02/16 - Task 1637119 / Defect 1629734
*            Checking TAFJ runtime path instead of &COMO&.
*
* 21/09/17 - Task 2280739
*            Call EB.DETERMINE.SCHEMA to get the schema under which files to be created
*
* 17/07/19 - Task 3233211 / Enhancement 3218630
*            Load the sub modules list in the company variable if the product code present in the company record
*
* 18/09/2019 - Task 3343202
*             Changes to ignore invalid file creation.
*             If the Company does not have product then file is not created for that product.
************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.FILE.CONTROL
    $INSERT I_F.SPF
    $INSERT I_SCREEN.VARIABLES

    $INSERT I_F.PGM.FILE
    $INSERT I_DAS.COMMON
    $INSERT I_DAS.FILE.CONTROL
    $INSERT JBC.h
    $USING EB.Upgrade
*
* Initialise variables
*
    REPORT.ID = 'NEW.FILES.CREATED'
*      PRT.UNIT = 1
    PRT.UNIT = ''   ;* CI_10005835 S/E
*
    DIM FC.RECORD(10), YR.COMPANY(EB.COM.AUDIT.DATE.TIME), YSAVE.R.COMPANY(EB.COM.AUDIT.DATE.TIME)
    YR.LIST = ''
    RESULT = ''     ;* GLOBUS_CI_10010730 S/E
*
*  OPEN FILES
*
    OPEN '','&SAVEDLISTS&' TO YF.LIST ELSE
        TEXT = 'UNABLE TO OPEN &SAVEDLISTS& FILE'
        GOTO FATAL.ERROR
    END
*
    IF NOT(RUNNING.IN.TAFJ) THEN    ;* Check the condition which is running in tafj or not
        OPEN '','&COMO&' TO COMO.FV ELSE    ;* uniVerse
            OPEN '','&UFD&' TO COMO.FV ELSE ;* Prime
                TEXT = 'UNABLE TO OPEN &COMO& FILE'
                GOTO FATAL.ERROR
            END
        END
    END ELSE
        COMO.PATH = GETENV("temn.tafj.runtime.directory.como")  ;* Get the defined path from tafj .properties file
        OPEN '',COMO.PATH TO COMO.FV ELSE ;* uniVerse
            TEXT = 'UNABLE TO OPEN &COMO& FILE'
            GOTO FATAL.ERROR
        END
    END

*
    OPEN "","F.FILE.CONTROL" TO F.FILE.CONTROL ELSE
        TEXT = "UNABLE TO OPEN F.FILE.CONTROL"
        GOTO FATAL.ERROR
    END
*
    OPEN "","VOC" TO F.VOC ELSE
        TEXT = "ERROR OPENING VOC"
        GOTO FATAL.ERROR
    END
*
    OPEN '','F.RELEASE.DATA' TO F.RELEASE.DATA ELSE
        TEXT ='EB.RTN.CANT.OPEN.F.RELEASE.DATA'
        GOTO FATAL.ERROR
    END
*
    YF.COMPANY = ""
    CALL OPF("F.COMPANY",YF.COMPANY)
*
* Prompt the user to enter the company code
*
INPUT.COMPANY:
    YTEXT = "COMPANY CODE"
    CALL TXTINP(YTEXT,8,22,11,"COM")
    IF COMI = "" THEN RETURN
    YID.COMPANY = COMI
*
* Check that the company code entered exists on the company file
*
    MATREAD YR.COMPANY FROM YF.COMPANY,YID.COMPANY ELSE     ;*MATREADU single threads the upgrade service changed to MATREAD for multi threading to work
        MAT YR.COMPANY = ''
        E ="EB.RTN.INVALID.COMP.CODE"
        CALL ERR
        errMsg = 'INVALID COMPANY CODE'
        Logger('CREATE.FILES',TAFC_LOG_ERROR,errMsg)             ;* has to decide whether to use switch ?
        GOTO INPUT.COMPANY
    END
    modulesSplit = EB.Upgrade.getModulesSplit()             ;* get the modules split details
    IF modulesSplit THEN  ;* load only if present
        GOSUB LOAD.SUB.MODULES           ;* load the sub module in the company record variable
    END
    YCOMPANY.NAME = YR.COMPANY(EB.COM.COMPANY.NAME)<1,LNGG>
    IF YCOMPANY.NAME = "" THEN YCOMPANY.NAME = YR.COMPANY(EB.COM.COMPANY.NAME)<1,1>

    infoMsg = "CREATE FILES FOR ":YCOMPANY.NAME
    PRINT @(10,10):S.CLEAR.EOL:infoMsg
    Logger('CREATE.FILES',TAFC_LOG_INFO,infoMsg)

*
* Prompt the user to enter a select list name containing files to be
* created
*
* Maximum length of LIST NAME increased from 40 to 55
    CALLED.FROM.RELEASE = 0
INPUT.LIST:
    YTEXT = 'LIST NAME'
    CALL TXTINP(YTEXT,8,22,55,'ANY')    ;* List name may have special character
    LIST.NAME = COMI

    IF LIST.NAME THEN

*
* Check that the select list name entered exists on &SAVEDLISTS&
*
        READ YR.LIST FROM YF.LIST,LIST.NAME ELSE
            E ='EB.RTN.INVALID.LIST.NAME'
            CALL ERR
            errMsg = 'INVALID LIST NAME'
            Logger('CREATE.FILES',TAFC_LOG_ERROR,errMsg)
            GOTO INPUT.LIST
        END

        infoMsg = 'USING LIST ':LIST.NAME:
        PRINT @(10,12):S.CLEAR.EOL:infoMsg
        Logger('CREATE.FILES',TAFC_LOG_INFO,infoMsg)
*
* Determine if being called from GLOBUS.RELEASE
* If called from T24.UPGRADE, LIST.NAME is of the form : REL.<RELEASE.NO>.FILES<SESSION.NO>
* So, check whether fist 4 chars are "REL." and search for the string "FILES" in LIST.NAME.
*

        IF LIST.NAME[1,4] = 'REL.' THEN ;* If first four characters are "REL." in LIST.NAME
            IF INDEX(LIST.NAME,"FILES",1) THEN    ;* Search for "FILES" in LIST.NAME
                CALLED.FROM.RELEASE = 1
            END
        END
    END ELSE
*
* Prompt the user to enter the names of individual files to be created
*
        LOOP
            YTEXT = 'FILE NAME'
            CALL TXTINP(YTEXT,8,22,40,'A')
        WHILE COMI
*
* Check that the file name entered exists on F.FILE.CONTROL
*
            RECORD.EXISTS = 1
            READ YR.FILE FROM F.FILE.CONTROL,COMI ELSE RECORD.EXISTS = 0
            IF RECORD.EXISTS THEN
                YR.LIST<-1> = COMI
            END ELSE
                E ='EB.RTN.INVALID.FILE.NAME'
                CALL ERR
            END
        REPEAT
        IF YR.LIST THEN
            PRINT @(10,12):S.CLEAR.EOL:'USING FILE NAME(S) INPUT':
        END ELSE
*
* GB0001901 - added warning
*
            PRINT @(10,12):S.CLEAR.EOL:'CREATING *ALL* FILES IN F.FILE.CONTROL':
        END
    END
*
* Prompt the user to see if he wishes to continue
*
    CALL TXTINP("CONTINUE (Y/N)",8,22,1.1,FM:"Y_N")
    IF COMI <> "Y" THEN RETURN
*
* Set the report heading
*
*
    IF NOT(CALLED.FROM.RELEASE) THEN
        COMO.KEY = 'CREATE.FILES':C$T24.SESSION.NO:@TIME    ;*T24 Session number used instead of port number
        CALL HUSHIT(1)
        EXECUTE 'COMO ON ':COMO.KEY
        CALL HUSHIT(0)
    END
*
* If a select list name was not entered and individual file names
* were not entered, select all records on F.FILE.CONTROL
*
    IF YR.LIST = '' AND LIST.NAME = '' THEN
        CLEARSELECT

        THE.LIST = DAS.FILE.CONTROL$SORTED        ;*EN_10003192 S
        THE.ARGS = ""
        TABLE.SUFFIX = ""
        CALL DAS("FILE.CONTROL",THE.LIST,THE.ARGS,TABLE.SUFFIX)
        Y.FILE.LIST = THE.LIST
    END ELSE Y.FILE.LIST = YR.LIST
    MAT YSAVE.R.COMPANY = MAT R.COMPANY
    MAT R.COMPANY = MAT YR.COMPANY
*
    IF R.COMPANY(EB.COM.FINANCIAL.MNE) = "" THEN
        R.COMPANY(EB.COM.FINANCIAL.MNE) = R.COMPANY(EB.COM.MNEMONIC)
        R.COMPANY(EB.COM.FINANCIAL.COM) = YID.COMPANY
    END

    PRINT
    PRINT
*
* Process each file selected in turn
*
    LOOP UNTIL Y.FILE.LIST<1> = "" DO
        Y.FILE.NAME = Y.FILE.LIST<1>
        Y.FILE.LIST = DELETE(Y.FILE.LIST,1,0,0)



        MATREAD FC.RECORD FROM F.FILE.CONTROL,Y.FILE.NAME ELSE
            TEXT = "ERROR PROCESSING F.FILE.CONTROL"
            MAT R.COMPANY = MAT YSAVE.R.COMPANY
            GOTO FATAL.ERROR
        END
*
* CHECK THAT THE FILE'S APPLICATION IS ON THE COMPANY RECORD
* IF NOT, WE DROP OUT OF THE LOOP AND PROCESS THE NEXT FILE
*
        IF FC.RECORD(EB.FILE.CONTROL.APPLICATION) = "" THEN
            errMsg = "*************** MISSING APPLICATION FOR ":Y.FILE.NAME
            PRINT SPACE(40):errMsg
            Logger('CREATE.FILES',TAFC_LOG_ERROR,errMsg)
        END ELSE
            isInstalled = ''                                         ;* Initialise
            productId = FC.RECORD(EB.FILE.CONTROL.APPLICATION)           ;* get the product from FILE.CONTROL
            CALL Product.isInCompany(productId, isInstalled)             ;* To validate if the product is availble in the company
            IF isInstalled THEN
                ERROR.MESSAGE = ''

                infoMsg = 'Creating file ':Y.FILE.NAME
                Logger('CREATE.FILES',TAFC_LOG_INFO,infoMsg)
                SCHEMA.NAME = ""
                CALL EB.DETERMINE.SCHEMA(Y.FILE.NAME, YID.COMPANY, SCHEMA.NAME)     ;* get the schema name
                FILE.TO.CREATE = Y.FILE.NAME
                IF SCHEMA.NAME THEN     ;* if schema name is required
                    FILE.TO.CREATE<7> = SCHEMA.NAME     ;* append and pass it for creating files
                END
                CALL EBS.CREATE.FILE(FILE.TO.CREATE,'',ERROR.MESSAGE)
                IF ERROR.MESSAGE THEN
                    PRINT ERROR.MESSAGE
                    Logger('CREATE.FILES',TAFC_LOG_ERROR,ERROR.MESSAGE)
                END
            END
        END

    REPEAT
    MAT R.COMPANY = MAT YSAVE.R.COMPANY
*
    IF NOT(CALLED.FROM.RELEASE) THEN
        CALL HUSHIT(1)
        EXECUTE 'COMO OFF'
        CALL HUSHIT(0)
        READ COMO.REC FROM COMO.FV,COMO.KEY ELSE  ;* uniVerse
            COMO.KEY := '.COMO'         ;* Prime
            READ COMO.REC FROM COMO.FV,COMO.KEY ELSE COMO.REC = ''
        END
        EXECUTE 'COMO DELETE ':COMO.KEY CAPTURING RESULT    ;* GLOBUS_CI_10010730 S/E
        CALL PRINTER.ON(REPORT.ID,PRT.UNIT)
        HEADING ON PRT.UNIT "FILE CREATION FOR COMPANY: ":YID.COMPANY:" ON  ":OCONV(DATE(),'DE'):"         PAGE   'PL'"
        LOOP
            REMOVE LINE FROM COMO.REC SETTING MORE.LINES
            PRINT ON PRT.UNIT LINE
        WHILE MORE.LINES
        REPEAT
        PRINT ON PRT.UNIT
        PRINT ON PRT.UNIT
        PRINT ON PRT.UNIT SPACE(50):'********  END OF REPORT  ********'
        CALL PRINTER.CLOSE(REPORT.ID,PRT.UNIT,'')
    END
RETURN
*************************************************************************
****  Fatal error handling routine                                   ****
*************************************************************************
FATAL.ERROR:
    IF NOT(CALLED.FROM.RELEASE) THEN
        CALL HUSHIT(0)
        EXECUTE 'COMO OFF'
        CALL PRINTER.CLOSE(REPORT.ID,PRT.UNIT,'')
    END
    CALL FATAL.ERROR("CREATE.FILES")
****
****

*-----------------------------------------------------------------------------
LOAD.SUB.MODULES:
* load the sub modules if the parent module is present and the sub module is not present in company record variable
    parentCount = ''   ;* initialise it to null
    prodCheck = ''      ;* initialise it to null
    parentCount = DCOUNT(modulesSplit ,@FM)                 ;* get the count of parent modules
    FOR count = 1 TO parentCount                     ;* for each parent load the sub modules
        prodCheck = FIELD(modulesSplit<count>,"*",1)           ;* get the product alone
        LOCATE prodCheck IN YR.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING appPOS THEN     ;* locate each product in company record application field
            YR.COMPANY(EB.COM.APPLICATIONS)<1,-1> = FIELD(modulesSplit<count>,"*",2)    ;* load the respective sub modules if parent module is located
        END
    NEXT count                   ;* next loop
    
RETURN
*-----------------------------------------------------------------------------

END

