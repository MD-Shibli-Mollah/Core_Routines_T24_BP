* @ValidationCode : MjotNDA5NTI0MjEyOkNwMTI1MjoxNjExNTU4NDEwODk4OnZzbmVoYTo0OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAyLjIwMjEwMTIxLTEzMTY6NDQzOjI2OA==
* @ValidationInfo : Timestamp         : 25 Jan 2021 12:36:50
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vsneha
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 268/443 (60.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202102.20210121-1316
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE EB.Upgrade
SUBROUTINE EBS.SOFTWARE.RELEASE(releaseNumber,fromAccount)
 
* Program: Ebs.software.release         Date: 20/08/87
*-------------------------------------------------------------------
*     Amended 23/11/87 to write data records to the file F.RELEASE.RECORDS
*
*     F.RELEASE.RECORDS
*     -------------
*     Record ALL.FILES contains a list of the data files to be released.
*     For each filename listed on ALL.FILES a record with an id of
*     'filename' contains a list of all the records to be released in
*     that file. Each data record is stored as filename/recordname
*
* 15/07/91 - HY9100132
*            Remove tests for .RUN account. Hence if the master account
*            is specified as DEV.RUN then THATS where the programs will
*            be copied to AND NOT to the non-existent account DEV.
*
* 01/03/94 - GB9400218
*            Copy inserts required by REPGEN.SOURCE into RG.BP at release
*            time to pick up the correct inserts
*
* 15/07/94 - GB9400882
*            Ensure that F.PGM.FILE and F.BATCH.NEW.COMPANY records are
*            released before other data items.  This is because the
*            records on F.PGM.FILE are required by CREATE.INAU.RECORDS
*            when records are released from F.CONVERSION.PGMS and the
*            records on F.BATCH.NEW.COMPANY are required by F.BATCH.
*            This change has been achieved by ensuring that F.PGM.FILE
*            and F.BATCH.NEW.COMPANY are put at the beginning of the
*            record ALL.FILES on F.RELEASE.RECORDS.
*
* 03/08/94 - GB9400926
*            TEMP.RELEASE is now split into seperate sub-directories for
*            each release.  e.g. In TEMP.RELEASE, there could be sub-
*            directories G5.1.00, G6.1.00 and G7.1.00.  The releases are
*            not merged as before, but multiple releases can still be
*            done.  Source will be copied directly from the sub-
*            directories into the master account, starting with the
*            oldest release and finishing with the latest release, using
*            the overwriting option.  Data records are written to
*            F.RELEASE.DATA which is in the master account, from
*            F.RELEASE.RECORDS, again starting with the oldest release
*            and finishing with the latest release, using the overwriting
*            option.  All programs and data items are released, but the
*            merged select list will only contain items for the
*            applications on the SPF.  This select list is then the
*            driving force to determine which programs to compile and
*            which records should be released to data files.
*            A paragraph is no longer created - copies are done from
*            within this program.
*
* 25/05/95 - GB9500642
*            Read in the merged list of releases to install from the
*            account being upgraded, rather than temp.release
*
* 08/06/95 - GB9500723
*            Ensure that required inserts are released to RG.BP
*
* 13/07/95 - GB9500840
*            Do not try to open the VOC in the master account, unless
*            the master account is different from the current account
*
* 19/09/95 - GB9501058
*            If a record does not exist on F.PGM.DATA.CONTROL for a
*            data item which is being released, ensure that
*            F.PGM.DATA.CONTROL is check correctly for the corresponding
*            file control record
*
* 05/03/96 - GB9600253
*            If I_EQUATE.ON is being released and extended precision is
*            on, copy I_EQUATE.ON to I_EQUATE in BP1, BP2 and RG.BP
*
* 21/03/96 - GB9600337
*            Release release programs, even if they are in RELEASE.BP,
*            as the version in RELEASE.BP may not compile correctly, due
*            to not having the latest updates.  Although warning messages
*            may be produced in GLOBUS.RELEASE, the programs will be
*            recompiled before being run
*
* 15/07/96 - GB9600956
*            If G7.0.06 is being installed, do not copy records to
*            F.RELEASE.DATA for earlier releases, since the whole file
*            is copied as at G7.0.06
*
* 15/07/96 - GB9600966
*            If F.NEW.RELEASE.DATA is present in the release, copy all
*            the records from F.NEW.RELEASE.DATA to F.RELEASE.DATA (these
*            are records which have been converted by conversion
*            programs)
*
* 22/07/96 - GB9600979
*            The new method of specifying conversion routines means that
*            any CONVERSION.DETAILS records need to be released before
*            other data items (in a similar fashion to the PGM.FILE and
*            BATCH.NEW.COMPANY records) and should be released regardless
*            of product.
*
* 26/07/96 - GB9601051
*            Make sure that the records in NEW.RELEASE.DATA are correctly
*            copied over to the RELEASE.DATA file.
*
* 19/08/96 - GB9601117
*            When copying all the records over from the
*            F.PGM.DATA.CONTROL file in TEMP.RELEASE to the local copy,
*            if the TEMP.RELEASE file is on a different machine, remove
*            the machine id from the Unix pathname before doing the copy.
*
* 04/09/96 - GB9601235
*            Only rebuild the Helptext index file if helptext records
*            have been released.
*
* 09/09/96 - GB9501239
*            Amend program so that it works with ATB releases
*
* 24/02/97 - GB9700213
*            Do not release F.PGM.FILE and F.CONVERSION.DETAILS records
*            if the product is OB - obsolete
*
* 12/05/97 - GB9700440
*            Amend program to allow for object code release -
*            When going through G8.0.01, build GLOBUS.BP.O from BP1.O and
*            BP2.O;
*            Copy object over, rather than source;
*            Do not compile programs, just re-catalog;
*            Also still allow for source code releases (e.g. in case
*            of object incompatability, if using extended precision,
*            internally, etc)
*
* 22/07/97 - GB9700839
*            Remove machine id when copying files from temp.release
*            (the machine id is stored in the UNIX pathname, e.g.
*            ibm560!:/globus.pif.... - causes a problem on the Lightning
*            at Temenos)
*
* 30/07/97 - GB9700883
*            Program not copying source over correctly
*
* 17/09/97 - GB9701067
*            Records are not being copied over from F.NEW.RELEASE.DATA,
*            into F.RELEASE.DATA.  This results in records which should
*            have been converted by a conversion program remaining
*            unconverted in F.RELEASE.DATA.  Thus, if a client then
*            installs a new product, unconverted data may be released
*            (e.g. records from F.DE.MAPPING)
*
* 16/12/97 - GB9701462
*            Amend release procedures so that TEMP.RELEASE no longer
*            contains sub-directories for each release; instead it will
*            contain all programs and data items for the current release.
*
* 10/06/98 - GB9800663
*            When doing a product release, programs are not being
*            released if the product begins A-F.  This is because the
*            release number was being compared against G8.0.01 - if the
*            release number was before this (e.g. EU), programs were not
*            released!  The check was there because, as at G8.0.01, all
*            programs were released. Remove G8.0.01 check.
*
* 30/09/98 - GB9801196 (TSP0255)
*            Amend program to cater for the patch release concept.
*            Patch releases will follow the same basic patch as ATB
*            releases, but programs (object code) will be released to
*            PATCH.BP and cataloged there.
*
* 16/11/98 - GB9801358 (TSP0255)
*            Remove all references to MASTER.ACCOUNT (general tidying up
*            of redundant code).
*
* 05/01/99 - GB9900009 (AIB0103)
*            If this is a GAC linked entity, do not release any records
*            to any GAC file
*
* 19/04/01 - GB0101104
*            If the product of the item is TS, install it regardless of
*            whether the product is installed.  This is required for the
*            installation of the Dimensions utilities.  It shouldn't
*            cause any problems, as TS items are not released as part of
*            standard GLOBUS releases, so if we do release them (in a
*            patch for example), it is a conscious decision we have
*            taken.
*
* 15/10/01 -  GLOBUS_EN_10000249
*             When saving non-program entries to the VOC, ignore "GLOBUS"
*             VOCs if running in jBASE
*
* 28/05/03 - GLOBUS_BG_100004305
*            Bug(qualified release number) fixes for Service Pack installation.
*            While installing the service pack, the service pack name should be
*            formed by stripping the qualified rel no. 07 from SPG130072003050.
*
* 13/06/03 - BG_100004481
*            Removed the SP name modifications done in the previous fix (BG_100004305)
*
* 31/05/04 - GLOBUS_BG_100006614
*            Code Review changes to core routines
*
* 15/09/08 - BG_100019944
*            To release only required records for Model Bank during Upgrade
*
* 19/09/08 - BG_100020033
*            Compilation does not happen after taking DIM.TEST.CDS
*
* 10/12/08 - BG_100021252
*            Assign the variable MBCLIENT with the value of the field MB.CLIENT
*            in SPF indicating whether model bank client or not.
*            Depending upon this value, the data records will be released accordingly.
*
* 02/03/08 - BG_100022358
*            Removed the field MB.CLIENT in SPF since model bank query is not raised
*            while upgrading from lower release.
*            So, MBCLIENT is assigned with the value read from the record MB.CLIENT
*            in F.LOCKING file
*
* 23/09/09 - EN_10004355
*            Replace Globus.BP with T24.BP in T24 Server Code
*
* 07/01/2013 - Task : 539398 / Story : 539393
*              Install updates in TAFJ platform
*
* 02/04/13 - Task : 563701 / Ref Story : 557203
*            Release config data records for the model bank client during Upgrade and product installation.
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT().
*
* 12/12/15 - Defect 1554192 / Task: 1567095
*            packageDataInstaller will release all the data records.
*
* 21/12/15 - Defect 1554192 / Task: 1575967
*            Refactoring the Code to make it compatible in TAFC
*
* 01/02/16 - Defect:1512636 / Task: 1517716
*            Install Features with 6 digit product code
*
* 14/03/16- Task: 1664391/ Defect: 1639922
*           The data records  should also be released for NON MODEL BANK area
*
* 07/05/16- Task : 1724477 / Defect 1724476
*           Reversing the code done by the task 1639922
*
* 14/11/16 - Defect : 1845372 / Task : 1860661
*            packageDataInstaller releases all the data reords irrespective of products
*            installed if it is ran through DSpackage installer.
*
* 09/03/18 - Task 2493574
*            Primary data list should be updated to REL.release.Primary.XXX files.
*            Remaining data can get updated to REL.release.XXX files as usual.
*            No need to release CONVERSION.DETAILS, and CONVERSION.PGMS.
*
* 20/03/2018 - Enhancement : 2473496 / Task : 2551009
*              Handle the FILE.CONTROL release via DS Packager server deployment.
*
* 03/08/2018 - Task 2707590
*            ETP fix correction.
*            Upgrade services always need to refer temp release &SAVEDLISTS& to release data to DB.
*            And COPY command replaced to READ and WRITE to avoid performance degrade.
*
* 26/09/2018 - Task 2781023
*              TSA.WORKLOAD.PROFILE also included as part of primary data release service for online upgrade.
*
* 09/01/19  - Enhancement 2879893 / Task 2921959
*           - Multi Product Dependency for Data Records.
*
* 04/02/19  - Defect 2967691 / Task 2974792
*             When install product, to avoid to install other than the given product in the batch record.
*
* 06/02/19 - Enhancement 2822523 / Task 2909926
*            Incorporation of EB_Upgrade component
*
* 04/02/19  - Defect 3000803 / Task 3000829
*             To Skip the Multi Product Dependency for LRT.
*
* 25/02/19 - Enhancement 2822523 / Task 3007049
*            Incorporation of EB_Upgrade component
*
* 25/02/19 - Task 2970305
*            Module installation as part of online upgrade.
*
*
* 26/03/19 - Task 3055230 / Defect 3047311
*            AA.CLASS.TYPE records should be loaded to live file during Upgrade process
*
* 24/04/19 - Defect: 3099257 / Task: 3099157
*            Data records without PDC must be released when they come via a package and not skipped
*
* 02/08/19 - Defect 3267721 / Task 3267765
*          - Include T24.FULL.UPGRADE also as an upgrade service.
*
* 12/12/19 - Defect 3456498 / Task 3475034
*          - Wrong temp release path is referred while installing updates using a temp.release pack during TAFJ upgrade.
*
* 25/01/20 - Enh 3455993 / Task 3555284
*            Selective Inheritance of data artefacts based on EB.INHERIT.REQUEST definitions.
*
* 11/02/2020 - Task 3582036
*            changes to release AA configuration table for online upgrade
* 12/02/2020 - Enhancement : 3523195 / Task : 3564346
*              Convert the JSON content into DataArray format.
*
* 19/03/20 - Task 3649572 / Enhancement 3636658
*            If not a sysgen process only then set a flag not to release the data record
*
* 13/04/20 - Task: 3689848
*            Do not apply selective inheritance for a particular license code
*
* 13/04/20 - Task 3689848
*            Reversing the selective inheritance changes done based on license code
*
* 14/04/20 - Task 3691788
*            Do not apply Selective Inheritance rules in Base Bank
*
* 01/07/20 - Defect 3626861 / Task 3832596
*            Handling SYSTEM.VARIABLES in @ID of the application through json.
*
* 26/08/20 - Task 3933167
*            Allow the release of ModelConfig records for SAAS client
*
* 24/11/20 - Defect 4096073 / Task 4098188
*            '\' has been replaced by SLASH variable based on OS
*
* 20/01/21 - Task 4024187 / Enhancement 3915996
*            File type is INT and product is already present in main company then dont reattempt to release data.
*
*-------------------------------------------------------------------------------------
*
* Objective :-
*
* To run as part of the EBS release process.
* This program is called from PERFORM.GLOBUS.RELEASE
* It is used for releasing software from the software release staging
* area (TEMP.RELEASE) to either in-house or client's sites working
* environments.

* Functionality :-
*
* Copies records directly to files for BPs, C.PROGS, F.PROGS, CPL.PROGS
* and F. RELEASE.DATA.  If a program is being released, the program
* is then added to a select list so that it can be cataloged by
* EBS.PROGRAMS.INSTALL (called from PERFORM.GLOBUS.RELEASE).(The object
* has previously been copied over by PERFORM.GLOBUS.RELEASE). Data
* records are added to a select list and released by CREATE.INAU.RECORDS
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SPF
    $INSERT I_F.PGM.DATA.CONTROL
    $INSERT I_GAC.FILES
    $INSERT I_EB.RELEASE.ESON.DS.IF
    $INSERT I_BATCH.FILES
    $INSERT I_F.TSA.SERVICE
    $INSERT I_TSA.COMMON
    $INSERT I_F.FILE.CONTROL
    $INSERT I_F.COMPANY

*========================================================================
*
*    I N I T I A L I S A T I O N   S E C T I O N
*
*========================================================================

*
* Constants
*
    tmp = ''
    PROMPT ''
    DUMMY = @(0,0)
    EQUATE TRUE TO 1
    EQUATE FALSE TO 0
*
* Special data files are files which must be processed first by
* CREATE.INAU.RECORDS. GB9600979 CONVERSION.DETAILS added to the list.
*
    OS.NAME = SYSTEM(1017)    ;* Operating System Information
*
    BEGIN CASE
        CASE OS.NAME = 'UNIX'     ;* Unix
            SLASH = '/' ;* set the slash accordingly
        CASE OS.NAME = 'WINNT' OR OS.NAME = 'WIN95'   ;* Windoes
            SLASH = '\'
        CASE 1          ;* ?
            SLASH = '/'
    END CASE
    
    IF R.SPF.SYSTEM<SPF.ONLINE.UPGRADE> THEN              ;* online upgrade workflow has restructuring process based on T24.TABLE.RESTRUCTURE before starting upgrade service and not CONVERSION.DETAILS after upgrade service
        PRIMARY.APPLICATION.LIST = 'F.PGM.FILE':@VM:'F.FILE.CONTROL':@VM:'F.AA.CLASS.TYPE':@VM:'F.AA.STANDARD.FIELDS.CHANGE':@VM:'F.STANDARD.SELECTION':@VM:'F.BATCH.NEW.COMPANY':@VM:'F.BATCH':@VM:'F.TSA.WORKLOAD.PROFILE':@VM:'F.TSA.SERVICE':@VM:'BP':@VM:'F.EB.API':@VM:'F.EB.COMPONENT':@VM:'F.EB.PRODUCT'         ;* some more identified applications as primary can be added here
        IGNORE.LIST = 'F.CONVERSION.DETAILS':@VM:'F.CONVERSION.PGMS'
        SPECIAL.DATA = 'F.BATCH.NEW.COMPANY':@FM:'F.PGM.FILE'
    END ELSE
        SPECIAL.DATA = 'F.BATCH.NEW.COMPANY':@FM:'F.PGM.FILE' : @FM : 'F.CONVERSION.DETAILS'
    END
    COPY.FILES = 'BP':@FM:'C.PROGS':@FM:'F.PROGS':@FM:'CPL.PROGS':@FM:'F.RELEASE.RECORDS'
*
* Variables
*
    LINE.INDEX = 0
    PGM.FILE.LIST = ''
    FILE.CONTROL.LIST = ''
    PROGRAM.LIST = ''
    DATA.LIST = ''
    SPECIAL.DATA.LIST = ''
    HELPTEXT = ''
    DELETE.VOC = ''
    SQ = "'"
*
* Check that the release number, from account and master account which
* have been passed as variables are not null
*
    IF releaseNumber = '' THEN
        E ='EB.RTN.RELEASE.NO.NOT.ENT'
        GOTO FATAL.ERROR
    END
*
* Check if the release number is an application or PATCH release
*
    IF LEN(releaseNumber) = 2 OR LEN(releaseNumber) = 6 THEN APPLICATION.RELEASE = 1    ;* Inceresed the length for the product ACHFRM
    ELSE APPLICATION.RELEASE = 0
*
    PATCH.RELEASE = 0
    IF releaseNumber[1,3] = 'ATB' THEN PATCH.RELEASE = 1
    IF releaseNumber[1,5] = 'PATCH' THEN PATCH.RELEASE = 1
*
    IF fromAccount = '' THEN
        E ='EB.RTN.FROM.AC.NAME.NOT.ENT'
        GOTO FATAL.ERROR
    END
*
    CURRENT.ACCOUNT = UPCASE(@WHO)
*
* Open files
*
    OPEN '','VOC' TO VOC ELSE
        E ='EB.RTN.UNABLE.OPEN.VOC.FILE'
        GO FATAL.ERROR:
    END
*
    OPEN '','&SAVEDLISTS&' TO SAVEDLISTS ELSE
        E ='EB.RTN.UNABLE.OPEN.&SAVEDLISTS.FILE'
        GO FATAL.ERROR:
    END
    EB.Upgrade.setSavedlists(SAVEDLISTS)
*
    OPEN '','&TEMP&' TO F.TEMP ELSE
        EXECUTE 'CREATE.FILE &TEMP& 2 17'
        OPEN '','&TEMP&' TO F.TEMP ELSE
            E ='EB.RTN.UNABLE.OPEN.&TEMP.FILE'
            GO FATAL.ERROR:
        END
    END
*
    OPEN '','F.PGM.DATA.CONTROL' TO F.PGM.DATA.CONTROL ELSE
        E ='EB.RTN.UNABLE.OPEN.F.PGM.DATA.CONTROL'
        GOTO FATAL.ERROR
    END
    EB.Upgrade.setFPgmDataControl(F.PGM.DATA.CONTROL)
*
    OPEN '','F.RELEASE.DATA' TO F.RELEASE.DATA ELSE
        E ='EB.RTN.UNABLE.OPEN.F.RELEASE.DATA'
        GOTO FATAL.ERROR
    END
    EB.Upgrade.setFReleaseData(F.RELEASE.DATA)
    
    OPEN '', 'F.FILE.CONTROL' TO F.FILE.CONTROL ELSE
        E ='EB.RTN.UNABLE.OPEN.F.FILE.CONTROL'
        GOTO FATAL.ERROR
    END
      
    IF DeployInServer THEN
        TOTAL.DATA.COUNT = DCOUNT(DataPackageList, @FM) ;* Obtain the total number of data record
        FOR DATA.COUNT = 1 TO TOTAL.DATA.COUNT
            IF INDEX(DataPackageList<DATA.COUNT>, 'F.FILE.CONTROL', 1) THEN ;* If the datalist contains FILE.CONTROL
                FULL.ID = FIELD(DataPackageList<DATA.COUNT>, '#', 2)    ;* Obtain the ID filename>recid
                FILE.CONTROL.ID = FIELD(FULL.ID, '>', 2)    ;* fetch the file control ID
                
                READ R.FILE.CONTROL FROM F.RELEASE.DATA, FULL.ID THEN   ;* Read the record from F.RELEASE.DATA
                    WRITE R.FILE.CONTROL TO F.FILE.CONTROL, FILE.CONTROL.ID ;* Write the FILE.CONTROL record
                END
            END
        NEXT DATA.COUNT
        RETURN  ;* Return since the savedlists processing is not required for server deployment
    END
*
* setup voc pointer for &SAVEDLISTS& file in the "from" account
*
    CURRENT.SERVICE = ''
    IF RUNNING.UNDER.BATCH THEN                    ;* only required for upgrade services , need to refer savedlists from temp release directory path
	    IF INDEX(BATCH.INFO<1>,'/',1) THEN
	        CURRENT.SERVICE = FIELD(BATCH.INFO<1>, '/', 2)          ;* get current service name without mnemeonic
	    END ELSE
            CURRENT.SERVICE = BATCH.INFO<1>
	    END
    END
    isUpgradeService = 0
    IF CURRENT.SERVICE MATCHES 'T24.UPGRADE':@VM:'T24.UPGRADE.PRIMARY':@VM:'T24.FULL.UPGRADE' THEN         ;* Upgrade services always should refer temp release &SAVEDLISTS& to release data into DB
        isUpgradeService = 1
    END
     
    IF RUNNING.IN.TAFJ THEN   ;* For the process running in TAFJ platform
        STATUS STAT FROM SAVEDLISTS ELSE STAT =""               ;* Read status from F.FILE
        fileTypeStat = INDEX(STAT<21>, 'XML', 1)            ;* Store the index of XML and UD in fileTypeStat and udFileType
        udFileType = INDEX(STAT<21>, 'UD', 1)
        IF (NOT(fileTypeStat) AND udFileType) OR isUpgradeService THEN             ;* isUpgradeService - tells upgrade service always require &SAVEDLISTS& from temp release directory path in this stage
            K.VOC = fromAccount:SLASH:'&SAVEDLISTS&'    ;* Assign the &SAVEDLISTS& path to TAFJ platform
        END ELSE
            K.VOC = '&SAVEDLISTS&'
        END
    END ELSE
        K.VOC = fromAccount:'/&SAVEDLISTS&'
        DELETE.VOC<-1> = K.VOC
        R.VOC = 'Q'
        R.VOC<2> = fromAccount
        R.VOC<3> = '&SAVEDLISTS&'
        WRITE R.VOC ON VOC,K.VOC
    END
*
* now open the &SAVEDLISTS& file in the "from" account
*
    OPEN '',K.VOC TO F.FROM.SAVEDLISTS ELSE
        IF NOT(APPLICATION.RELEASE) THEN
            IF NOT(PATCH.RELEASE) THEN
                E = 'EB.RTN.UNABLE.OPEN.FILE.2':@FM:K.VOC
                GO FATAL.ERROR:
            END ELSE OPEN '','&SAVEDLISTS&' TO F.FROM.SAVEDLISTS ELSE NULL      ;* Will not be used if atb release
        END ELSE OPEN '','&SAVEDLISTS&' TO F.FROM.SAVEDLISTS ELSE NULL          ;* Will not be used if application release
    END
    
  
              

*
* Determine if running in a GAC linked account
*
    GAC.LINKED.AC = 0
    IF R.SPF.SYSTEM<SPF.GAC.ACCOUNT> THEN
        LOCATE 'GA' IN R.SPF.SYSTEM<SPF.PRODUCTS,1> SETTING POS ELSE GAC.LINKED.AC = 1
    END
*
    READ MBCLIENT FROM F.LOCKING,"MB.CLIENT" ELSE ;* read locking file record MB.CLIENT to check for model bank client
        MBCLIENT = ''
    END
*
* Determine whether the routine is being invoked from packageDataInstaller
    fromDsInstaller = 0 ;*flag Used to determine if it is installing a DSPackage
    IF EB.Upgrade.getFnT24UpdateRelease() EQ 'F.T24.MODEL.PACKAGES' THEN
        fromDsInstaller = 1;* it is DSpackage dataInstaller.
    END

    isSaasClient = 0    ;*flag to determine SAAS client
    CALL Product.isInSystem('SS', isSaasClient)     ;*check if SS is installed
    
*========================================================================
*
*    M A I N   S E C T I O N
*
*========================================================================

    PRINT
    PRINT SPACE(12):'T24 SOFTWARE UPGRADE  ':TIMEDATE()
    PRINT SPACE(12):STR('*',45)
    PRINT
    PRINT
*
* Read in merged list of release numbers to install
*
	RELEASE.LIST = ''
    READ RELEASE.LIST FROM SAVEDLISTS,'MERGED.':releaseNumber ELSE
        READ RELEASE.LIST FROM F.FROM.SAVEDLISTS,'MERGED.':releaseNumber ELSE RELEASE.LIST = releaseNumber
    END
     
    saveReleaseList = ''
    IF R.SPF.SYSTEM<SPF.ONLINE.UPGRADE> AND isUpgradeService AND NOT(INDEX(releaseNumber,'_',1)) THEN           ;* for module installation only and not for updates installation
        saveReleaseList = RELEASE.LIST              ;* save RELEASE.LIST common variable value which has list of releases involved in this upgrade i.e for example 201812....201904 etc FM delimited
        tsaServiceId = BATCH.INFO<1>
        READ rTsaService FROM F.TSA.SERVICE,tsaServiceId THEN
            attributeTypes = rTsaService<TS.TSM.ATTRIBUTE.TYPE>          ;* get List of attribute types from TSM record
            attributeValues = rTsaService<TS.TSM.ATTRIBUTE.VALUE>        ;* products defined with space delimited so that it can be fetched easily as ATTRIBUTE.TYPE holds other attributes values also for online upgrade
        END
        
        attrTotal = DCOUNT(attributeTypes,@VM)
        FOR attrCnt = 1 TO attrTotal
            IF attributeTypes<1,attrCnt> = 'MODULES' THEN
                RELEASE.LIST<-1> = attributeValues<1,attrCnt>                ;* update RELEASE.LIST with list of modules being installed as part of this online upgrade at last.
            END
        NEXT attrCnt
    END
    
    EB.Upgrade.setReleaseList(RELEASE.LIST)
    
    MASTER.RELEASE.NO = releaseNumber
    MAX.REL.NO = COUNT(EB.Upgrade.getReleaseList(),@FM) + (EB.Upgrade.getReleaseList() <> '')

*========================================================================
*
*   PROCESSING EACH RELEASE SELECT LIST IN TURN
*
*========================================================================

    PRINT SPACE(8):'Building release lists ............'
*
    FOR REL.COUNT = 1 TO MAX.REL.NO
        releaseNumber = EB.Upgrade.getReleaseList()<REL.COUNT>
*
* Read in the select list.  If it does not exist in the current account,
* read it from the "from" account. (PATCH release lists are in current
* account, all others are in the release account)
*
        READ R.SAVED FROM F.FROM.SAVEDLISTS,'REL.':releaseNumber ELSE
            READ R.SAVED FROM SAVEDLISTS,'REL.':releaseNumber ELSE
                TEMP.RELEASE.PATH  = ''			;* Initialise
                EB.Upgrade.GetTempReleaseJbase(TEMP.RELEASE.PATH, E)        ;* In case of temp.release pack with updates during TAFJ upgrade.
                IF TEMP.RELEASE.PATH THEN               ;* If the path is available
                    TEMP.RELEASE.PATH = TEMP.RELEASE.PATH:SLASH:SAVEDLISTS      ;*SLASH variable uses based on the OS
                	OPEN '',TEMP.RELEASE.PATH TO UPDATE.SAVEDLISTS THEN        ;* Open the path
                        READ R.SAVED FROM UPDATE.SAVEDLISTS,'REL.':releaseNumber ELSE       ;* Read the saved lists record
                            E ='EB.RTN.UNABLE.READ.SELECT.LIST':@FM:releaseNumber           ;* Raise an error
                            GO FATAL.ERROR:
                        END
                    END ELSE            ;* If open fails, report the error
                        E ='EB.RTN.UNABLE.READ.SELECT.LIST':@FM:releaseNumber
                        GO FATAL.ERROR:
                    END
                END ELSE        ;* If path is not found , report error
                    E ='EB.RTN.UNABLE.READ.SELECT.LIST':@FM:releaseNumber
                    GO FATAL.ERROR:
                
                END
                
            END
        END

*========================================================================
*
* USE CURRENT RELEASE SELECT LIST TO UPDATE MERGED SELECT LISTS FOR
* PROGRAMS, INSERTS AND OTHER ITEMS BEING RELEASED
*
*========================================================================
        COMPANY.CREATE = ''  ;* intialise before usage
        isProductReleased = '' ;*
        READ R.COMPANY.CREATE.LOCKING FROM F.LOCKING,'COMPANY.CREATE' THEN   ;* Read the locking record COMPANY.CREATE
            COMPANY.CREATE = 1          ;* To indicate company creation mode
        END
    
        IF COMPANY.CREATE THEN  ;* Company creation mode
            LOCATE releaseNumber IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING X THEN    ;* Locate releasenumber in BNK company record
                isProductReleased = 1    ;* product is already present
            END
        END
        isOnlineUpgrPrimaryData = 0
        TOTAL.COUNT = DCOUNT(R.SAVED,@FM)
        PREV.FILE.NAME = ''
        PRINT
        PRINT
        FOR LINE.INDEX = 1 TO TOTAL.COUNT
            ID = R.SAVED<LINE.INDEX>
            
            FILE.NAME = FIELD(ID,'>',1)
            REC.NAME = FIELD(ID,'>',2)
        
            CLASSIFICATION =''
            IF FILE.NAME NE 'BP' AND isProductReleased THEN   ;* file name is not BP and product is present in BNK company
                IF FILE.NAME EQ 'F.FILE.CONTROL' OR FILE.NAME EQ 'F.PGM.FILE' THEN  ;* file name is FILE.CONTROL or PGM.FILE
                    READ R.FILE.CONTROL FROM F.FILE.CONTROL, REC.NAME THEN     ;* get FILE.CONTROL record
                        CLASSIFICATION=R.FILE.CONTROL<EB.FILE.CONTROL.CLASS>   ;* classification of the application
                        IF CLASSIFICATION EQ 'INT' THEN    ;* classification is INT
                            CONTINUE    ;* just continue
                        END
                    END
                END ELSE
                    REC.ID = FIELD (FILE.NAME , '.' , 2,99)   ;* for other file names get the application
                    READ R.FILE.CONTROL FROM F.FILE.CONTROL, REC.ID THEN   ;* get FILE.CONTROL record
                        CLASSIFICATION=R.FILE.CONTROL<EB.FILE.CONTROL.CLASS>   ;* classification of the application
                        IF CLASSIFICATION EQ 'INT' THEN     ;* classification is INT
                            CONTINUE    ;* just continue
                        END
                    END
                END
            END
    
            IF R.SPF.SYSTEM<SPF.ONLINE.UPGRADE> THEN
                IF BATCH.DETAILS<3> = 'PRIMARY' THEN        ;* T24.UPGRADE.PRIMARY service to release only primary application list (very minimal data items when system offline)
                    IF (FILE.NAME MATCHES PRIMARY.APPLICATION.LIST) THEN
                        isOnlineUpgrPrimaryData = 1             ;* REL file naming decided based on this flag for storage
                    END ELSE                   ;* current application not matches with primary application list
                        CONTINUE               ;* skip current record release if it is not part of primary application list and check for next
                    END
                END ELSE                       ;* normal T24.UPGRADE service to release remaining file records when system online
                    IF (FILE.NAME MATCHES PRIMARY.APPLICATION.LIST) OR (FILE.NAME MATCHES IGNORE.LIST) THEN                ;* primary list and conversion tables to be ignored during T24.UPGRADE
                        CONTINUE              ;* skip current record release as it is already released via T24.UPGRADE.PRIMARY
                    END
                END
            END
*
* If the file is BP, then create a list of all programs to be compiled.
* For each program to be compiled, if a VOC entry exists for it
* already and it is not a VOC entry for the program, write the VOC entry
* to &TEMP&, displaying a message.
*
            IF FILE.NAME = 'BP' THEN
                R.PROG = ''
                IF REC.NAME[1,2] <> 'I_' THEN
                    READ R.PROG FROM VOC,REC.NAME ELSE R.PROG = ''
                END
                IF R.PROG THEN
                    IF R.PROG<1> NE 'V' AND R.PROG<3> NE 'B' THEN
                        IF R.PROG<1> NE 'GLOBUS' THEN
                            WRITE R.PROG TO F.TEMP,REC.NAME
                            DELETE VOC,REC.NAME
                            PRINT '** Voc pointer already existed and not program type so - '
                            PRINT '** ':REC.NAME:' was written to &TEMP& file and deleted from VOC file **'
                        END
                    END
                END ;* GLOBUS_EN_10000249
            END
*
* Check application of item has been purchased by customer
*
            READ R.PGM.DATA.CONTROL FROM F.PGM.DATA.CONTROL,R.SAVED<LINE.INDEX> ELSE
                IF FILE.NAME = 'BP' THEN R.PGM.DATA.CONTROL = '' ELSE
                    TEMP.FILE.NAME = FIELD(FILE.NAME,'.',2,999)
                    READ R.PGM.DATA.CONTROL FROM F.PGM.DATA.CONTROL,'F.FILE.CONTROL>':TEMP.FILE.NAME ELSE
                        R.PGM.DATA.CONTROL = ''
                    END
                END
            END

* Release the records when SOURCE.REQ = 'NO' only for Model Bank

            MB.REL.REC = 1    ;* initially set release flag

            IF FILE.NAME NE "BP" AND R.PGM.DATA.CONTROL<PDC.SOURCE.REQ>[1,1] = 'N' AND MBCLIENT[1,1] NE 'Y' THEN
                MB.REL.REC = 0          ;* dont release if it is not a model bank
            END

            READ R.SYSGEN.LOCKING FROM F.LOCKING,'SYSGEN' ELSE
                R.SYSGEN.LOCKING = ''                        ;* this is not a sysgen process
            END
            
            IF R.PGM.DATA.CONTROL<PDC.SOURCE.REQ>[1,1] = 'C' AND FILE.NAME NE "BP" AND NOT(R.SYSGEN.LOCKING) THEN    ;* For a config data record alone, not the routine
                IF NOT(fromDsInstaller) AND NOT(isSaasClient) THEN    ;* release all the data if it is from DSpackage and Saas client
                    IF NOT(MBCLIENT[1,1] = 'Y' AND R.SPF.SYSTEM<SPF.LICENSE.CODE>[6,4] EQ 'TMNS') THEN   ;* Config data record should be released to the internal model bank client
                        MB.REL.REC = 0   ;* Flag sets not to release the data record
                    END
                END
            END

            IF R.PGM.DATA.CONTROL<PDC.PRODUCT> = 'OB' THEN INSTALLED = 0
            ELSE INSTALLED = 1

            Multi.Product = 0
            
*  The Condition to check the Product installtion
            PROD.COUNT = DCOUNT(EB.Upgrade.getProductList(),@FM)
            IF PROD.COUNT AND (EB.Upgrade.getProductList() NE "T24.UPDATES") AND (EB.Upgrade.getProductList() NE "T24.MODEL.PACKAGE") AND (FILE.NAME NE 'F.LOCAL.REF.TABLE') AND NOT(fromDsInstaller) THEN ;* do not check for PDC if we come from DS package installer
                PRD.DETAILS = R.PGM.DATA.CONTROL<PDC.PRODUCT>
                CONVERT '!' TO @VM IN PRD.DETAILS
                IF releaseNumber MATCHES  PRD.DETAILS ELSE
                    CONTINUE
                END
            END
            
            IF R.PGM.DATA.CONTROL<PDC.PRODUCT> THEN
                IF INDEX(R.PGM.DATA.CONTROL<PDC.PRODUCT>,'!',1) THEN    ;*  Check more than one product is given
                    Multi.Product = 1                                   ;*  Set the flag for multi product dependency
                    PRD.DETAILS = R.PGM.DATA.CONTROL<PDC.PRODUCT>       ;*  Get the product details
                    CONVERT '!' TO @FM IN PRD.DETAILS                    ;*  Convert to @FM
                    TOTAL.PROD = DCOUNT(PRD.DETAILS,@FM)
                    FOR PROD.CNT = 1 TO TOTAL.PROD
                        LOCATE PRD.DETAILS<PROD.CNT> IN R.SPF.SYSTEM<SPF.PRODUCTS,1> SETTING POS THEN   ;*  Check the Product has defined in the SPF
                            INSTALLED = 1                                                               ;*  The Product is avaiable then to set the flag is 1
                        END ELSE
                            INSTALLED = 0
                            PROD.CNT = TOTAL.PROD + 1
                        END
                    NEXT PROD.CNT
                END ELSE
                    LOCATE R.PGM.DATA.CONTROL<PDC.PRODUCT> IN R.SPF.SYSTEM<SPF.PRODUCTS,1> SETTING INSTALLED ELSE INSTALLED = 0
                END
            END
                                    
            IF fromDsInstaller AND NOT(Multi.Product) THEN ;*   The data records released through DSInstaller will be used at application level and hence the product check at SPF can be skipped for DSPackageInstaller.
                INSTALLED = 1
            END
                                    
*
* If the product is TS, install the item regardless of whether the
* product has been installed
*
            IF R.PGM.DATA.CONTROL<PDC.PRODUCT> = 'TS' THEN INSTALLED = 1        ;* GB0101104
*
* If the item is a PGM.FILE record for a conversion program, release it
* regardless of product (unless it is obsolete), so that the
* CONVERSION.PGM can find it
*
            IF R.SAVED<LINE.INDEX>[1,16] = 'F.PGM.FILE>CONV.' THEN
                IF R.PGM.DATA.CONTROL<PDC.PRODUCT> <> 'OB' THEN INSTALLED = 1
            END
*
* If running in a GAC linked entity, do not install records for GAC
* files
*
            IF GAC.LINKED.AC THEN
                LOCATE FILE.NAME IN FILE.LIST<1> SETTING POS THEN INSTALLED = 0
            END
*
* GB9600979 If the item is a CONVERSION.DETAILS record, release it
* regardless of product (unless it is obsolete), so that the conversion
* routine can find it.
*
            IF R.SAVED<LINE.INDEX>[1,21] = 'F.CONVERSION.DETAILS>' THEN
                IF R.PGM.DATA.CONTROL<PDC.PRODUCT> <> 'OB' THEN INSTALLED = 1
            END
*
            IF (R.SPF.SYSTEM<SPF.LICENSE.CODE> EQ 'EURGBTMNS111') AND (R.SPF.SYSTEM<SPF.SITE.NAME> EQ 'BASE BANK') ELSE
                GOSUB applySelectiveInheritance     ;* Do not apply Selective Inheritance rules for base bank
            END
           
            IF INSTALLED AND MB.REL.REC THEN      ;* check for model bank while releasing the records
*
* Store list of records to be released by CREATE.INAU.RECORDS
*
                LOCATE FILE.NAME IN COPY.FILES<1> SETTING POS ELSE
                    IF FILE.NAME <> 'F.FILE.CONTROL' THEN
                        LOCATE FILE.NAME IN SPECIAL.DATA<1> SETTING SPECIAL ELSE SPECIAL = 0
                        IF SPECIAL THEN
                            LOCATE ID IN SPECIAL.DATA.LIST<1> BY 'AL' SETTING POS ELSE INS ID BEFORE SPECIAL.DATA.LIST<POS>
                        END ELSE
                            LOCATE ID IN DATA.LIST<1> BY 'AL' SETTING POS ELSE INS ID BEFORE DATA.LIST<POS>
                        END
                    END
                END
*
* Store lists of all programs, PGM.FILE records and F.FILE.CONTROL records
* being released.  These need to be stored as merged lists for all
* releases, so that programs are compiled once only, CREATE.INAU.RECORDS
* is run once only and TYPE.PROG.REBUILD is run once only.
*
                BEGIN CASE
                    CASE FILE.NAME = 'F.PGM.FILE'
                        LOCATE REC.NAME IN PGM.FILE.LIST<1> BY 'AL' SETTING POS ELSE INS REC.NAME BEFORE PGM.FILE.LIST<POS>
                        LOCATE ID IN SPECIAL.DATA.LIST<1> BY 'AL' SETTING POS ELSE INS ID BEFORE SPECIAL.DATA.LIST<POS>
*
                    CASE FILE.NAME = 'F.FILE.CONTROL'
                        LOCATE REC.NAME IN FILE.CONTROL.LIST<1> BY 'AL' SETTING POS ELSE INS REC.NAME BEFORE FILE.CONTROL.LIST<POS>
*
                    CASE FILE.NAME = 'BP'
*
                        IF REC.NAME[1,2] <> 'I_' THEN
                            LOCATE REC.NAME IN PROGRAM.LIST<1> BY 'AL' SETTING POS ELSE INS REC.NAME BEFORE PROGRAM.LIST<POS>
                        END
*
                    CASE FILE.NAME = 'F.HELPTEXT'
                        HELPTEXT = 'HELPTEXT RELEASED'
*
                END CASE
            END
            PREV.FILE.NAME = FILE.NAME
        NEXT LINE.INDEX
    NEXT REL.COUNT
    IF saveReleaseList THEN
        EB.Upgrade.setReleaseList(saveReleaseList)           ;* restore with release numbers itself as product list not required to be part of ReleaseList common after this juncture.
    END
*========================================================================
*
*   PROCESSING MERGED RELEASES
*
*========================================================================

    releaseNumber = MASTER.RELEASE.NO
*
* Write out select lists for FILE.CONTROL, PGM.FILE and HELPTEXT so that
* GLOBUS.RELEASE can determine whether any FILE.CONTROL, PGM.FILE and
* HELPTEXT records have been released and therefore run CREATE.FILES,
* TYPE.PROG.REBUILD and REBUILD.HELPTEXT.INDEX accordingly
*
    relHelptextid = ''
    IF isOnlineUpgrPrimaryData THEN                  ;* primary data release service as T24.UPGRADE
        relFilesId = 'REL.':releaseNumber:'.Primary.FILES'
        relPgmFilesId = 'REL.':releaseNumber:'.Primary.PGM.FILE'
        relProgramsId = 'REL.':releaseNumber:'.Primary.PROGRAMS'
        relDataId = 'REL.':releaseNumber:'.Primary.DATA'
    END ELSE                          ;* T24.UPGRADE as normal data release service
        relFilesId = 'REL.':releaseNumber:'.FILES'
        relPgmFilesId = 'REL.':releaseNumber:'.PGM.FILE'
        relProgramsId = 'REL.':releaseNumber:'.PROGRAMS'
        relDataId = 'REL.':releaseNumber:'.DATA'
        relHelptextid = 'REL.':releaseNumber:'.HELPTEXT'
    END
    
    DELETE SAVEDLISTS,relFilesId
    DELETE SAVEDLISTS,relPgmFilesId
    DELETE SAVEDLISTS,relProgramsId
    DELETE SAVEDLISTS,relDataId
    IF relHelptextid THEN
        DELETE SAVEDLISTS,relHelptextid
    END
*
    IF PGM.FILE.LIST THEN WRITE PGM.FILE.LIST ON SAVEDLISTS,relPgmFilesId
    IF FILE.CONTROL.LIST THEN WRITE FILE.CONTROL.LIST ON SAVEDLISTS,relFilesId
    IF PROGRAM.LIST THEN WRITE PROGRAM.LIST ON SAVEDLISTS,relProgramsId
*
    FULL.DATA.LIST = ''
    IF SPECIAL.DATA.LIST THEN FULL.DATA.LIST = SPECIAL.DATA.LIST
    IF DATA.LIST THEN FULL.DATA.LIST<-1> = DATA.LIST
    IF FULL.DATA.LIST THEN WRITE FULL.DATA.LIST ON SAVEDLISTS,relDataId
    IF HELPTEXT AND relHelptextid THEN WRITE HELPTEXT ON SAVEDLISTS,relHelptextid
*
* Copy all file control records from F.RELEASE.DATA to F.FILE.CONTROL
*
    IF FILE.CONTROL.LIST THEN
        MAX.RECS = COUNT(FILE.CONTROL.LIST,@FM) + (FILE.CONTROL.LIST <> '')
        FOR REC.COUNT = 1 TO MAX.RECS
            ID = FILE.CONTROL.LIST<REC.COUNT>
            FULL.ID = 'F.FILE.CONTROL>':ID
            PRINT '** Releasing ':ID:' to F.FILE.CONTROL'
            READ rFileControlRelData FROM F.RELEASE.DATA, FULL.ID THEN
                IF rFileControlRelData[1,1] EQ '{' THEN
                    JsonString = rFileControlRelData     ;* Get the json record
                    OperationMode = 'dataRecord'         ;* Initialise operationMode to dataRecord
                    HeaderDetails = ''                   ;* Initialise before usage
                    DataArray = ''                       ;* Initialise before usage
                    OfsRequest = ''                      ;* Initialise before usage
                    ErrMsg = ''                          ;* Initialise before usage
                    CALL EB.PARSE.JSON.STRING(JsonString, OperationMode, HeaderDetails, DataArray, OfsRequest, ErrMsg)      ;* call api to parse the json into dataArray format
                    rFileControlRelData = DataArray
                    IF HeaderDetails<2> AND (HeaderDetails<2> NE ID) THEN
                        ID = HeaderDetails<2>            ;* restore the recordId after parsing json record
                    END
                END
                WRITE rFileControlRelData TO F.FILE.CONTROL, ID
            END
        NEXT REC.COUNT
    END
*
* Delete temporary VOC pointers
*
    MAX.VOCS = COUNT(DELETE.VOC,@FM) + (DELETE.VOC <> '')
    FOR V$COUNT = 1 TO MAX.VOCS
        DELETE VOC,DELETE.VOC<V$COUNT>
    NEXT V$COUNT

* terminate section

    PRINT
    PRINT SPACE(8):'**...Program complete...**  ':TIMEDATE()
    PRINT
RETURN
*
*
*************************************************************************
*
* FATAL.ERROR - fatal error routine
*
FATAL.ERROR:
*
* Error messages are printed by PERFORM.GLOBUS.RELEASE
*
RETURN
*------------------------------------------------------------------------------------------------------

*** <region name = applySelectiveInheritance>
applySelectiveInheritance:
*** <desc>Control the release of record based on definition in PDC>INHERIT.INST.DET </desc>
    IF FILE.NAME NE 'BP' AND R.PGM.DATA.CONTROL<PDC.INHERIT.INST.DET> THEN      ;*check if value is present in INHERIT.INST.DET
        noOfInst = DCOUNT(R.PGM.DATA.CONTROL<PDC.INHERIT.INST.DET>,@VM)         ;*total count of inherit instructions
        FOR inst = 1 TO noOfInst        ;*loop through each instruction
            dependentPdt = FIELD(R.PGM.DATA.CONTROL<PDC.INHERIT.INST.DET,inst>,'*',1)       ;*get the dependent product (Ex: SS from SS*Y)
            LOCATE dependentPdt IN R.SPF.SYSTEM<SPF.PRODUCTS,1> SETTING found THEN          ;*Check if it is installed in system
                inheritInst = FIELD(R.PGM.DATA.CONTROL<PDC.INHERIT.INST.DET,inst>,'*',2)    ;*get the release instruction
                IF inheritInst EQ 'N' THEN
                    MB.REL.REC = 0      ;*if any one of the instruction holds 'N', then don't release the record
                    BREAK               ;*break the loop without proceeding as one of the instruction is 'N'
                END ELSE
                    MB.REL.REC = 1      ;*overwrite the release flag when instruction is 'Y' because INHERIT.INST.DET holds priority over SOURCE.REQ
                END
            END
        NEXT inst
    END
RETURN
*** </region>

*------------------------------------------------------------------------------------------------------

* physical end of program
END

