* @ValidationCode : MjotNjAxMTkxNzI4OkNwMTI1MjoxNTk3MzIxMzk0NDM0Omt2YW5pOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4xOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Aug 2020 17:53:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kvani
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 47 14/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>16261</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.Upgrade
SUBROUTINE PERFORM.GLOBUS.RELEASE(CURRENT.ACCOUNT,NOT.USED)
*-----------------------------------------------------------------------------
* This program was previously called GLOBUS.RELEASE.  The new version
* of GLOBUS.RELEASE replaces RECOMP.RELEASE.PROGS by compiling and
* cataloging all the release programs, then calls PERFORM.GLOBUS.RELEASE
*
* PERFORM.GLOBUS.RELEASE forms the basis of the release procedures and is
* used both internally at Temenos for releases to ATB and BNK and also
* externally at client sites.
*
* This program will release programs, insert modules and data items.
* Programs will be compiled and cataloged and VOC pointers updated where
* appropriate; new files will be created if they do not already exist;
* data items will be released to the unauthorised file if an unauthorised
* file exists or to the live file otherwise.
*
* Variables are set up as follows:
*
* FROM.ACCOUNT    - If called from ATB.RELEASE (only at Temenos), set to
*                   PRD
*                   Otherwise, set to TEMP.RELEASE
*
* CURRENT.ACCOUNT - Set from @WHO, uppercase.  Checked in GLOBUS.RELEASE
*                   that the program is being run in the RUN account, so
*                   CURRENT.ACCOUNT will always be the run account
*
*                   NOTE: CURRENT.ACCOUNT is passed as a parameter from
*                   GLOBUS.RELEASE, to ensure that this programs is only
*                   run from GLOBUS.RELEASE and is never run as a stand-
*                   alone program
*
* MASTER.ACCOUNT  - If called from ATB.RELEASE, set to the current account
*                   Otherwise, set to the master account on the SPF.  For
*                   most setups, the master account on the SPF will be
*                   null, so MASTER.ACCOUNT is set to the current account.
*                   If MASTER.ACCOUNT is the same as the current account,
*                   programs will be compiled and cataloged in the current
*                   account (using the catalog option from the SPF -
*                   default local).  Otherwise, programs will not be
*                   compiled and cataloged, but the VOC pointers for the
*                   programs will be copied from the  MASTER.ACCOUNT.  If
*                   VOC pointers are to be copied from the master account,
*                   programs must be cataloged globally in the master
*                   account.
************************************************************************
*
* Modifications
* =============
*
* 16/04/91 - GB9100087
*            For a multi-company environment, ensure files are
*            created in all companies.
*
* 25/06/91 - GB9100213
*            Do not pass an active select list to EBS.CREATE.FILE
*
* 15/08/91 - HY9100132 & GB9100301
*            Merge select lists if multiple releases are required.
*            Remove tests for .RUN accounts ie allow release to be
*            installed in accounts other than BNK.
*            Update the SPF with the new release number.
*
* 24/10/91 - GB9100413
*            IF statement changed in VALIDATE.RELEASE.NO section.
*            Verification of the release number was incorrect.
*
* 15/05/92 - GB9200442
*            Bypass release list merge if the releasing to ATB.
*
* 17/06/92 - GB9200540 & GB9200541
*            Assign release number when performing ATB release.
*
* 25/06/92 - GB9200569
*            Return ETEXT when user does not continue with release.
*
* 14/07/94 - GB9400882
*            Print ETEXT when user an error occurs
*
* 04/08/94 - GB9400926
*            Enable user to enter the release number they wish to install.
*            All releases between the current release number (from the
*            SPF) and the release number entered will be installed.
*            However, if the release number entered was a patch number,
*            the user is given the option of installing only that patch
*            release.  If he wishes to only install that patch release,
*            the DEPENDENT.ON file in TEMP.RELEASE is checked to see
*            whether the release is dependent on any other patches or
*            major releases being installed.  If it is and they haven't
*            been installed, the user cannot continue. A release number
*            of application code can also be entered and a select list
*            will be built up of all programs/data items to be released,
*            from the PGM.DATA.CONTROL file.  The select list is stored
*            as REL.application-code.
*            Also amended to set the from account to PRD if running from
*            ATB release and to TEMP.RELEASE otherwise.  The master
*            account is set to the current account for ATB releases and
*            to the master account on the SPF otherwise.  If the master
*            master on the SPF is blank, the current account is used.
*
* 25/05/95 - GB9400642
*            Write merged select list to the account being upgraded,
*            rather than to TEMP.RELEASE
*            Do not add "m" to the COMO name
*            Ensure the SPF record is not left locked if the release
*            terminates abnormally
*            Do not give a fatal error if TEMP.RELEASE does not exist
*            (useful for product releases)
*
* 07/07/95 - GB9500813
*            If compile (passed as a parameter) is not set to "Y", then
*            do not compile and catalog programs.  This option is useful
*            if the release has previously fallen over after all programs
*            have been successfully compiled and cataloged.
*
* 13/09/95 - GB9501040
*            Remove null VOC entry if it exists (causes the release to
*            fall over as uniVerse copy and rename doesn't work, which is
*            used for releasing file.control records
*
* 14/09/95 - GB9501042
*            Delete the failed compilation select list so that the
*            release will not fail if the "XX" option is taken
*
* 27/09/95 - GB9501102
*            For application releases, put the application in quotes in
*            the select of F.PGM.DATA.CONTROL (otherwise, GT does not
*            work as GT is a reserved VOC entry)
*
* 09/10/95 - GB9501148
*            Do not check if TEMP.RELEASE exists if doing an application
*            release
*
* 13/02/96 - GB9600179
*            If going through G6.1.06, copy all records from
*            F.STANDARD.FILE in temp.release to F.RELEASE.DATA.  This
*            file contains standard enquiries, versions, menus and
*            repgens which will be used when installing new products
*
* 08/05/96 - GB9600580
*            Rebuild HELPTEXT concat files, by calling
*            REBUILD.HELPTEXT.INDEX
*
* 12/07/96 - GB9600956
*            If going through G7.0.06, overwrite F.RELEASE.DATA with
*            F.RELEASE.DATA.G7.0.06.  This file has been updated to
*            ensure that all records on it are in the latest format.
*            Also, if going through G7.0.06, do not copy any records to
*            F.RELEASE.DATA from releases prior to G7.0.06 (as these
*            would then overwrite the converted records).
*
* 04/09/96 - GB9601235
*            Only rebuild the Helptext index file if helptext records
*            have been released
*
* 05/09/96 - GB9501239
*            Amend program so that it works with ATB releases.
*
* 14/11/96 - GB961587
*            Ensure that the SPF file is read for ATB releases (it is
*            already read for ordinary releases).  This is because of a
*            "bug" in Batch Control whereby R.SPF.SYSTEM is not updated.
*
* 03/02/97 - GB9700111
*            Copy units over from the data library (F.DL.DATA) in
*            TEMP.RELEASE to the account being upgraded
*
* 13/05/97 - GB9700440
*            Amend program to cater for object releases.  Source code
*            releases (and compilations) will only be done if the
*            SOURCE.RELEASE flag on the SPF is set or if extended
*            precision is on.
*            Also BP1 and BP2 will be replaced by GLOBUS.BP.
*
* 01/06/97 - GB9501247
*            Call SPF.CONV.G8 to add NO.OF.USERS field to SPF, encrypted
*            field to SPF.CHECK, recalculating the checkdigit and add
*            the SIGN.ON.CHECK record to F.LOCKING
*
* 23/06/97 - GB9700745
*            Allow another reply to the "Do you wish to continue" prompt,
*            of "YS", to stop source code being deleted (required for the
*            internal upgrade to BNK)
*
* 09/10/97 - GB9701155
*            If the release completed successfully, display a message
*            advising the user to logout of uniVerse before continuing
*
* 16/12/97 - GB9701462
*            Amend release procedures so that TEMP.RELEASE no longer
*            contains sub-directories for each release; instead it will
*            contain all programs and data items for the current release.
*            Also remove the prompt whereby the user can choose which
*            release they install - now they can only install the current
*            release or a new product
*
* 20/04/98 - GB9800387
*            If temp.release does not exist when checking for which
*            releases to install, change message to "No releases to
*            install - TEMP.RELEASE does not exist".
*
* 06/05/98 - GB9800613
*            Make all operating system calls via central routine
*
* 15/06/98 - GB9800708
*            Call DISPLAY.MESSAGE early on, to overcome the fact that
*            in G9.0.00 S.COMMON was changed, causing a common mismatch
*            error.
*
* 30/09/98 - GB9801196 (TSP0255)
*            Amend program to cater for the patch release concept.
*            Patch releases will follow the same basic patch as ATB
*            releases, but programs (object code) will be released to
*            PATCH.BP and cataloged there.
*
* 19/11/98 - GB9801423
*            The name of the patches.installed field was changed at
*            G9.1.02.  This caused a problem, because if extended
*            precision is on, the release programs are copied, compiled
*            and cataloged by GLOBUS.RELEASE, but the new insert for
*            I_F.SPF is not copied, thus the variable is undefined and
*            a null field is inserted at the beginning of the SPF record
*            causing corruption.  If this field is null, use the field
*            number.
*
* 20/11/98 - GB9801358 (TSP0255)
*            Amend program to cater for the patch release concept.
*            If patch releases are required, copy patch release from
*            temp.release to F.PATCH.RELEASE; display patches to be
*            installed; install those releases requested.
*
* 05/01/99 - GB9900011 (TSP0255)
*            When format.conving a patch release, add CAPTURING to the
*            command, so that the messages produced by the format.conv
*            command do not mess up the screen.
*
* 06/01/99 - GB9900013 (TSP0255)
*            If running at Temenos and installing patch releases, copy
*            the patches from PATCH.DATA, rather than TEMP.RELEASE.
*
* 19/01/99 - GB9900019 (TSP0255)
*            Use a uniVerse copy programs to PATCH.BP.O, rather than a
*            Basic read/write, as the read/write seems to corrup
*            object code.
*
* 28/01/99 - GB9900098 (TSP0255)
*            The patch units will be written to TEMP.RELEASE as
*            uvbackup files (so that they can be sent easily by email,
*            added to the website, etc).  Therefore, this program needs
*            to uvrestore them (into the current account) and remove
*            them when completed.
*
* 21/12/98 - GB9801499
*            As NT doesn't like using XCOPY or RMDIR for files add a
*            flag to make the decision whether the COPY or RMDIR is for
*            a file or directory. Under NT files that are open need to
*            be closed to be deleted correctly by NT.
*
* 29/03/99 - GB9900546
*            In the NT changes done in GB9801499, the file F.RELEASE.DATA
*            was closed so that the copy of it could be done.  However,
*            it wasn't being opened for PATCH releases, and therefore
*            patch releases would not work for releases containing data
*            items.
*
* 06/05/99 - GB9900666
*            Allow for two digit years in the release number (e.g. G10)
*
* 23/09/99 - GB9901333
*            Restoring patches from TEMP.RELEASE on a remotely mounted
*            disk does not work, due to machine id being present in the
*            pathname. If the machine id is present, strip it out.
*            This is probably only a problem at Temenos
*
* 12/05/00 - GB0001233
*            Use the variable S.BELL rather than equating BELL to CHAR(X)
*            as this causes a catch 22 situation in the G11 upgrade
*
* 02/06/00 - GB0001395
*            Remove Helptext rebuild.  This is no longer required and
*            often causes problems when I_COMMON changes.
*
* 07/06/00 - GB0001410
*            Call INITIALISE.MAIN.COMMON to ensure COMMON is set up
*            when going from unlabelled to labelled main common
*
* 09/01/01 - GB0100053
*            Make this work in jBASE!
*
* 18/04/01 - GB0101085
*            If the program has been invoked from one of the Temenos
*            internal procedures (e.g. from Dimensions), terminate the
*            program at the end, without asking the user.
*
* 14/06/01 - GB0101785
*            For patches on Universe, do not add the dict
*            definition to the VOC creation as this causes the
*            DELETE.FILE to hang - and we don't select this on Universe
*            so it is not needed
*
* 25/09/01 - GLOBUS_EN_10000188
*            Changes to skip UV specific code in the
*            PERFORM.GLOBUS.RELEASE. There are some references
*            to GLOBUS.BP.O, which are not required in jGLOBUS
*            The SPECIAL.FILES for jGLOBUS should include
*            GLOBUS.BP. Otherwise the new INSERTS will not be
*            copied.
*
* 26/09/01 - GLOBUS_EN_10000190
*            Upgrade in jGLOBUS is not working because
*            when you copy the new globuslib and globusbin the
*            libraries for old globuslib and globusbin are
*            not removed from the memory. Hence system is not
*            able to find the programs even though they exist
*            To avoid this, first copy the globuslib and
*            globusbin and then start upgrading using
*            GLOBUS.RELEASE.
*            In this program remove the CALL to EB.COPY.GLOBUS.JBASE
*
* 12/10/01 - GLOBUS_EN_10000249
*            Enable ATB releases to be run in jBASE (i.e. to enable
*            development to be done in jBASE at Temenos)
*            Switch off existing COMO, before turning on release COMO
*            (otherwise doesn't work in jBASE)
*            Remove redundant code:
*            .  Source required
*            .  G5 processing
*            .  G8 processing
*
* 14/11/01 - GLOBUS_BG_100000229
*            For jBASE, always use BP from TEMP.RELEASE to update
*            GLOBUS.BP, regardless of the extended precision setting,
*            as this is not required by jBASE and the extended precision
*            version of I_EQUATE will cause problems in jBASE.
*
* 13/12/01 - GLOBUS_CI_10000500
*            Ensure that the PRE.RELEASE.PROGS.O file exists.
*            Transfer items from GLOBUS.BP.O into PRE.RELEASE.PROGS.O
*            for a successful GLOBUS.RELEASE session
*            Ensure that this transfer only happens once.
*
* 21/12/01 - GLOBUS_BG_100000326
*            Changes for installing multiple patches on jBASE
*
* 23/07/02 - GLOBUS_BG_100001659
*            Changes made to make patch installation jBASE on NT
*            compactible.Also chages made to install multiple
*            patches which contains both data as well as programs
*
* 31/07/02 - GLOBUS_CI_10002829
*            Changes made to make patch installation on Universe
*            on NT machine possible.
*
* 15/08/02 - GLOBUS_BG_100001836
*            Retain unix specific commands if the operating system is
*            UNIX.This was changed to call to SYSTEM.CALL under
*            the CD GLOBUS_BG_100001659
*
* 28/08/02 - GLOBUS_EN_10001043
*            Conversion Of all Error Messages to Error Codes
*
* 20/02/03 - GLOBUS_BG_100003483
*            Converted '$' to '_' in routine name.
*
* 21/03/03 - GLOBUS_BG_100003862
*            SELECT with 4 dots was failing in jBASE 4.1. Changes
*            to replace 4 dots with .0X
*
* 30/04/03 - GLOBUS_CI_10008689
*            Changes to install GRID patches
*
* 29/05/03 - BG_100004305
*            Changes done to facilitate service pack installation
*
* 04/06/03 - EN_10001835
*            Multi-book processing. To add Standard Selection in the
*            inserts to be copied to RG.BP
*
* 04/06/03 - GLOBUS_BG_100004358
*            Conversion "$" & "_"  to "."  in routine name.
*            (overwrite/ignore the previous conversion of  "$" to "_").
*            This is to ensure that routines will compile and work in
*            jBASE 4.1 and on non ASCII platforms.
*
* 10/06/03 - GLOBUS_BG_100004433
*            Changes made under GLOBUS_CI_10008689 was corrupting
*            the SPF record since FM were not converted to VM
*            in GLOBUS.PATCH.IDS
*
* 04/08/03 - GLOBUS_CI_10011435
*            Dictionaries for the patches were not getting deleted.
*
* 08/12/03 - GLOBUS_BG_100005775
*            Remove any references to the old PIF system
*
* 11/05/04 - GLOBUS_CI_10019721
*            Changes in the SELECT statement for AS400 compatibility
*            as the display of the release to be installed was improper.
*
* 21/01/05 - GLOBUS_BG_100007925
*            Added Support to include upgrades to Project Builds (yyyymm)
*            and Releases of the form Rx.
*
* 28/01/05 - GLOBUS_BG_100007982
*            Fix for Upgrading from one subsequent Gx release to Project Build.
*
* 23/02/05 - BG_100008140
*            Added Support to upgrade from Rxx to a project Build.
*            The information to relate Build and GA release is contained
*            in Savedlist of temp.release with the id RELEASE-TO-BUILD.
*            Value within it should be RxxFMyyyymm or RxxFMGxx.x.xx
*
* 17/03/05 - BG_100008379
*            After upgrading to a GA service pack, when running
*            GLOBUS.RELEASE, the release to be installed are still
*            being displayed.
*
* 29/03/05 - BG_100008451
*            Changes made to enable installation of R05 and Build patches
*            and also update the SPF when these patches are installed
*
* 06/07/05 - BG_100009040
*            While Trying to Upgrade from 200507.001 to 200508 the
*            release to be installed where not being displayed
*
* 14/07/05 - BG_100009086
*            Bug Fix for BG_100009086
*
* 26/04/07 - CI_10048670
*            SEAT RESULT integration.
*
* 20/06/07 - CI_10049866 
*            Incorrect arguments to routine FATAL.ERROR
*
* 16/07/07 - CI_10050343
*            REF:HD0711941
*            'Universe revision level unknown' error is eliminated while running GLOBUS.RELEASE
*
* 03/03/08 - BG_100017419(TTS0800769)
*            Copy I_F.DATES alos in RG.BP
*
* 06/01/09 - BG_100021517
*            Call to RESET.GLOBUS.RELEASE removed since it is made obsolete.
*
* 13/02/09 - BG_100022115
*            Clear the T24.UPDATES field in SPF during the upgrade process
*
* 04/04/09 - BG_100022470
*            GLOBUS.RELEASE to be used only for product installation.
*            Rest should be done via T24.UPGRADE service.
*
* 23/09/09 - EN_10004355
*            Replace Globus.BP with T24.BP in T24 Server Code
*
* 25/11/2009- BG_100025913
*             Soft code the folder named T24.BP
*
* 15/12/09 - BG_100026218
*            Product installation via GLOBUS.RELEASE needs to be blocked
*
* 19/12/18 - Enhancement 2822523 / Task 2909926
*            Incorporation of EB_Upgrade component
*
* 13/08/20 - TI Enhancement 3864778
*          - Task 3909539
*          - Removal of obsolete file PATCH.BP and PATCH.BP.O
*
************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_SCREEN.VARIABLES
    $INSERT I_F.SPF

*
* Perform initialisation
*
    GOSUB INITIALISATION
*
*=======================================================================
*
*  M A I N   P R O C E S S I N G   L O O P
*
* If called from PIF.TEST.RELEASE then CURRENT.ACCOUNT is set to "ATB,"
* from account, atb release number (e.g. ATB,G7PRD,ATB1234).
* Bypass merge processing.
* Otherwise :-
* Prompt user to enter his current release number - If one is not present
* on his SPF record (pre 11.0.0 support)
*
    CALL STANDARD.DISPLAY
*
    IF CURRENT.ACCOUNT[1,4] = "ATB," THEN
        INTERNAL.RELEASE = 1
        PATCH = 1
        FROM.ACCOUNT = FIELD(CURRENT.ACCOUNT,',',2)
        RELEASE.NO = FIELD(CURRENT.ACCOUNT,',',3)
        SOURCE.RELEASE = FIELD(CURRENT.ACCOUNT,',',4)
        CURRENT.ACCOUNT = UPCASE(@WHO)
        READ R.SPF.SYSTEM FROM F.SPF,'SYSTEM' ELSE NULL
* If T24.BP does not exist, fatal.error
*
        OPEN '', T24$BP TO T24.BP ELSE
            E ='EB.RTN.CANT.OPEN.GLOBUS.BP'
            GOTO FATAL.ERROR
        END
*
    END ELSE

        PATCH = 0
        FROM.ACCOUNT = 'TEMP.RELEASE'
        READU R.SPF.SYSTEM FROM F.SPF, "SYSTEM" LOCKED
            E ="EB.RTN.SPF.SYSTEM.REC.LOCKED"
            GOTO FATAL.ERROR
        END ELSE
            E ="EB.RTN.SPF.SYSTEM.REC.MISS"
            GOTO FATAL.ERROR
        END
        RELEASE.NO = R.SPF.SYSTEM<SPF.CURRENT.RELEASE>
* As of now, CURRENT.RELEASE should be capable of holding all three formats Gx, Rx 20yymm etc.
        SAVED.SPF.PRODUCTS = R.SPF.SYSTEM<SPF.PRODUCTS>
*
        IF RELEASE.NO = "" THEN
            E ='EB.RTN.RELEASE.NO.NOT.ON.F.SPF'
            GOTO FATAL.ERROR
        END

    END
*
    PRINT @(1,2):RVON:'Release to ':CURRENT.ACCOUNT:' ':RVOFF:
*
    IF PATCH THEN
        DISPLAY.LIST = RELEASE.NO
        RELEASE.LIST = RELEASE.NO       ;* Only one release number
*
        LINE.POS = 5
        GOSUB DISPLAY.RELEASES
*
        APPLICATION.RELEASE = 0
*
    END ELSE
*
        GOSUB VALIDATE.RELEASE.NO       ;* Determines release numbers to be installed
*
        LINE.POS = 5
        GOSUB DISPLAY.RELEASES
*
        IF RELEASE.LIST THEN
*
            EB.Upgrade.CheckAvailability('GLOBUS.RELEASE',TO.ALLOW)     ;*upgrade to be done only via T24.UPGRADE service
            IF NOT(TO.ALLOW) THEN
                TEXT = "Please use the service T24.UPGRADE"
                CALL REM
                RETURN
            END
            YTEXT = "Install release? Y/N"
            CALL TXTINP(YTEXT,8,22,1,@FM:'Y_N')
            PRINT @(19,22):S.CLEAR.EOL:
        END ELSE    ;* BG_100004305 S
            COMI = 'N'
            CALL INP('Press <RETURN>',8,22,'70','A')
        END         ;* BG_100004305 E
*
        IF COMI = F1 THEN GOTO V$EXIT
*
        APPLICATION.RELEASE = 0
        COMI = UPCASE(COMI)
*
        IF COMI <> 'Y' THEN
            SP.RELEASE = 1    ;* BG_100004305 S
            GOSUB VALIDATE.RELEASE.NO   ;* Determine service packs to be installed
*
            LINE.POS = 5
            GOSUB DISPLAY.RELEASES
*
            IF RELEASE.LIST THEN
*
                EB.Upgrade.CheckAvailability('SERVICE.PACK',TO.ALLOW)   ;*service pack to be installed only via T24 Updates
                IF NOT(TO.ALLOW) THEN
                    TEXT = "Please use T24 Updates."
                    CALL REM
                    RETURN
                END
                YTEXT = "Install service pack? Y/N"
                CALL TXTINP(YTEXT,8,22,1,@FM:'Y_N')
                PRINT @(19,22):S.CLEAR.EOL:
            END ELSE
                COMI = 'N'
                CALL INP('Press <RETURN>',8,22,'70','A')
            END
*
            IF COMI = F1 THEN GOTO V$EXIT
*
            APPLICATION.RELEASE = 0
            COMI = UPCASE(COMI)
*
            IF COMI <> 'Y' THEN         ;* BG_100004305 E
*
                GOSUB VALIDATE.PRODUCT
*
                IF RELEASE.LIST = '' THEN
                    GOTO V$EXIT
                END
*
* Ask user if he wishes to continue
*
                YTEXT = 'Release(s) to be installed.  Continue Y/N'
                CALL TXTINP(YTEXT,8,22,1,@FM:'Y_N')
                IF COMI <> 'Y' AND COMI NE F5 THEN
                    ETEXT ='EB.RTN.RELEASE.ABORTED'
                    GOTO V$EXIT
                END
*
* If patch release, transfer programs to PATCH.BP.O and data items to
* F.RELEASE.DATA
*
                IF PATCH THEN
                    GOSUB TRANSFER.PATCH.ITEMS
                END
            END
        END         ;* BG_100004305 S/E
    END
*
    MAX.RELS = COUNT(RELEASE.LIST,@FM) + (RELEASE.LIST <> '')
    RELEASE.NO = RELEASE.LIST<MAX.RELS>
    NEW.RELEASE.NO = RELEASE.NO
    IF MAX.RELS > 1 THEN      ;* Multiple releases
        PRINT @(1,15): S.CLEAR.EOL: "MERGING LISTS"
        PRINT @(1,16): S.CLEAR.EOL
*
* Write a list of all the releases to be installed as MERGED.release-no.
* This is used by EBS.SOFTWARE.RELEASE.
*
        RELEASE.NO := 'm'
        WRITE RELEASE.LIST TO SAVEDLISTS,'MERGED.':RELEASE.NO

    END
*
* Setup como filename
*
    PRINT S.CLEAR.SCREEN
    PRINT @(0,2):
    IF SP.RELEASE THEN        ;* BG_100004305 S
        COMO.NAME = 'REL.':LEFT(NEW.RELEASE.NO,6):RIGHT(NEW.RELEASE.NO,8)
    END ELSE        ;* BG_100004305 E
        COMO.NAME = 'REL.':NEW.RELEASE.NO
    END   ;* BG_100004305 S/E
    EXECUTE 'COMO OFF '       ;* In jBASE, you must switch off existing COMO first
    EXECUTE 'COMO ON ':COMO.NAME
*
    GOSUB PERFORM.RELEASE
*
    IF ETEXT THEN
        E = 'EB.RTN.TRANSFER.ABORTED':@FM:ETEXT
        CALL ERR
        CALL INP('PRESS RETURN',8,22,'70','A')
        EXECUTE 'COMO OFF'
    END ELSE
*
* Update SPF with release and patches installed as appropriate (for
* PATCH releases, update previous release no. field)
*
        IF NOT(APPLICATION.RELEASE) THEN
*
            BEGIN CASE        ;* BG_100004305 S
                CASE PATCH        ;* BG_100004305 E
*
* Update patch records with restored history
*
                    GOSUB UPDATE.PATCH.RECS
*
                    CONVERT @FM TO @VM IN PATCH.RELEASE.IDS
                    CONVERT @FM TO @VM IN GLOBUS.PATCH.IDS        ;* GLOBUS_BG_100004433 S/E
                    IF GLOBUS.PATCH.IDS NE '' THEN
* GLOBUS_CI_10008689 S , SPF should be updated only with GLOBUS patches and not with GRID patches

                        IF SPF.PATCHES.INSTLD = '' THEN
* Necessary for releases upgrading from prior to G9.1.02 and extended precision, when this field didn't exist
                            R.SPF.SYSTEM<31,-1> = GLOBUS.PATCH.IDS
                        END ELSE
                            R.SPF.SYSTEM<SPF.PATCHES.INSTLD,-1> = GLOBUS.PATCH.IDS
                        END       ;* GLOBUS_CI_10008689 E
                    END

                CASE SP.RELEASE   ;* BG_100004305 S

                    R.SPF.SYSTEM<SPF.SERVICE.PCK.INSTLD> = LEFT(NEW.RELEASE.NO,6):RIGHT(NEW.RELEASE.NO,8)         ;* NEW.RELEASE.NO[7,2] holds qualified rel no.
                    IF SPF.PATCHES.INSTLD = '' THEN
* Necessary for releases upgrading from prior to G9.1.02 and extended precision, when this field didn't exist
                        R.SPF.SYSTEM<31> = ''
                    END ELSE
                        R.SPF.SYSTEM<SPF.PATCHES.INSTLD> = ''
                    END
*
                CASE 1    ;* BG_100004305 E
*
                    R.SPF.SYSTEM<SPF.PREVIOUS.RELEASE> = R.SPF.SYSTEM<SPF.CURRENT.RELEASE>
                    R.SPF.SYSTEM<SPF.CURRENT.RELEASE> = NEW.RELEASE.NO
                    R.SPF.SYSTEM<SPF.PRODUCTS> = SAVED.SPF.PRODUCTS
                    IF SPF.PATCHES.INSTLD = '' THEN
* Necessary for releases upgrading from prior to G9.1.02 and extended precision, when this field didn't exist
                        R.SPF.SYSTEM<31> = ''
                    END ELSE
                        R.SPF.SYSTEM<SPF.PATCHES.INSTLD> = ''
                    END
                    R.SPF.SYSTEM<SPF.T24.UPDATES> = ''          ;* Clear the updates list
                    R.SPF.SYSTEM<SPF.SERVICE.PCK.INSTLD> = ''   ;* BG_100004305 S
                    CALL EB.COPY.SEAT.RESULTS         ;*CI_10048670 S/E
            END CASE          ;* BG_100004305 E
*
            WRITE R.SPF.SYSTEM TO F.SPF, "SYSTEM"
        END
        CALL STANDARD.DISPLAY
*
        PRINT @(21,9):'GLOBUS UPGRADE COMPLETED SUCCESSFULLY':
        PRINT @(9,12):'YOU SHOULD LOG OFF NOW TO ENSURE THE INTEGRITY OF THE SYSTEM':
        PRINT @(27,15):'ENTER "NO" TO STAY ON-LINE':
*
        CALL HUSHIT(1)
        EXECUTE 'COMO OFF'
        CALL HUSHIT(0)
*
* Only prompt the user to sign off if the program is not being run
* internally at Temenos (i.e. not called from Temenos internal procedure,
* e.g. Dimensions)
*
        IF NOT(INTERNAL.RELEASE) THEN   ;* GB0101085
            PRINT @(8,22):
            INPUT REPLY
            IF UPCASE(REPLY) <> 'NO' THEN CALL SIGN.OFF
        END
    END
*
    RELEASE.SUCCESS = 1       ;* GB0001518
    GOTO V$EXIT
*
*========================================================================
PERFORM.RELEASE:
* Display release details
*
    PRINT
    PRINT
    PRINT SPACE(30):'GLOBUS.RELEASE'
    PRINT SPACE(30):'=============='
    PRINT
    PRINT
    PRINT SPACE(10): "Current Release        ": R.SPF.SYSTEM<SPF.CURRENT.RELEASE>
    PRINT SPACE(10): "Installing Release(s) ":
    COL.POS = 33
    MAX.RELS = COUNT(DISPLAY.LIST,@FM) + (DISPLAY.LIST <> '')
    FOR REL.COUNT = 1 TO MAX.RELS
        IF SP.RELEASE THEN    ;* BG_100004305 S
            DISPLAY.FIELD = LEFT(DISPLAY.LIST<REL.COUNT>,6):RIGHT(DISPLAY.LIST<REL.COUNT>,8)
        END ELSE    ;* BG_100004305 E
            DISPLAY.FIELD = DISPLAY.LIST<REL.COUNT>
        END         ;* CI_10004305 S/E
        DISPLAY.FIELD := ' '
        FIELD.LEN = LEN(DISPLAY.FIELD)
        IF (FIELD.LEN + COL.POS) > 79 THEN
            COL.POS = 33
            PRINT
        END
        PRINT @(COL.POS):DISPLAY.FIELD:
        COL.POS = COL.POS + FIELD.LEN + 1
        IF COL.POS > 79 THEN
            COL.POS = 33
        END
    NEXT REL.COUNT
    IF COL.POS = 33 THEN PRINT
    PRINT
    PRINT
    PRINT SPACE(10):'Releasing programs/data items from ':FROM.ACCOUNT
    PRINT SPACE(40):'to   ':CURRENT.ACCOUNT
    PRINT
    PRINT

    PRINT SPACE(10):'Programs will be compiled and cataloged locally'
    PRINT
    PRINT
*
* Populate release files - T24.BP, GLOBUS.BP.O, F.PGM.DATA.CONTROL,
* F.RELEASE.DATA
*
    IF NOT(PATCH) THEN
        IF NOT(APPLICATION.RELEASE) THEN
            GOSUB POPULATE.FILES
        END
    END
*
* Call EBS.SOFTWARE.RELEASE to setup selectlists to copy and compile
* programs.
*
    E = ''
    EB.Upgrade.EbsSoftwareRelease(RELEASE.NO,FROM.ACCOUNT)
    IF E THEN GOTO FATAL.ERROR

    IF RUNNING.IN.JBASE THEN
        FAILED.KEY = 'EB.COMPILE.ERROR.':@USER.NO
    END ELSE
        FAILED.KEY = 'CEL.REL.':RELEASE.NO:'.PROGRAMS.':USER.NO
    END
*
    DELETE SAVEDLISTS,FAILED.KEY
*
    READ PROGS.TO.COMPILE FROM SAVEDLISTS,'REL.':RELEASE.NO:'.PROGRAMS' ELSE PROGS.TO.COMPILE = ''
*
* Installing patches
*
    IF PATCH = 'PATCH' THEN
        IF RUNNING.IN.JBASE THEN
*
* When running on the jBASE platform we just need to copy over the globus
* bin and libs and do some tidying. This is done in a separate routine.
* Move the jBASE bin and libs here:
*
* GLOBUS_BG_100001659  S/E , Changes to install multiple patches which contains both data as well as programs

            RELEASE.NUM = PATCH.RELEASE.IDS       ;* GLOBUS_BG_100000326   S/E , GLOBUS_BG_100001659 S
            EB.Upgrade.CatalogPatchJbase(RELEASE.NUM)        ;* GLOBUS_BG_100001659  E
        END ELSE
            GOSUB PATCH.CATALOG
        END
    END ELSE
*
* If running in jBASE and source required is set (i.e ATB release), then
* compile & catalog programs using EB.COMPILE.  This will set the
* bin & libs correctly
*
        IF RUNNING.IN.JBASE THEN
            IF SOURCE.RELEASE = 'Y' THEN
                IF PROGS.TO.COMPILE THEN
                    EXECUTE 'GET.LIST REL.':RELEASE.NO:'.PROGRAMS'
* EXECUTE 'EB.COMPILE ':T24$BP
                END
            END

        END ELSE
*
* UniVerse release.  Run EBS.PROGRAMS.INSTALL.
* If source release is required (option 5 on PCS), programs will
* be compiled and cataloged; otherwise programs will just be cataloged.
*
            IF PROGS.TO.COMPILE THEN
                INPUT.BUFFER = 'REL.':RELEASE.NO:'.PROGRAMS '
                IF SOURCE.RELEASE = 'Y' THEN
                    INPUT.BUFFER := '3'
                END ELSE INPUT.BUFFER := '2'
*
                EB.Upgrade.EbsProgramsInstall()
                IF E THEN GOTO FATAL.ERROR
            END
        END
    END
*
* Check whether programs have compiled OK
*
    READ FAILED.LIST FROM SAVEDLISTS,FAILED.KEY ELSE FAILED.LIST = ''
    IF FAILED.LIST THEN
*
        CALL STANDARD.DISPLAY
        PRINT @(21,5):RVON:'PROGRAMS FAILED COMPILATION':RVOFF:
        MAX.FAILED = COUNT(FAILED.LIST,@FM) + (FAILED.LIST <> '')
        FOR FAILED.NO = 1 TO MAX.FAILED
            PRINT @(25,6 + FAILED.NO):FAILED.LIST<FAILED.NO>:
        NEXT FAILED.NO
*
        PRINT @(17,17):RVON:'CORRECT ERRORS AND RERUN THE RELEASE':RVOFF:
        PRINT @(25,19):'Como is ':COMO.NAME:
        PRINT ERROR.TEXT:FMT('PRESS <RETURN> TO CONTINUE','60R'):
        PRINT @(8,22):
        INPUT XX
        PRINT @(0,18):
        CALL HUSHIT(1)
        EXECUTE 'COMO OFF'
        CALL HUSHIT(0)
        GOTO V$EXIT
    END
*
* Run CREATE.FILES to create and new files
*
    READV FILES.TO.CREATE FROM SAVEDLISTS,'REL.':RELEASE.NO:'.FILES',1 ELSE FILES.TO.CREATE = 0
    IF FILES.TO.CREATE THEN
*
* Create files for all companies
*
        COMPANY.LIST = ""
        SELECT F.COMPANY
        LOOP
        READNEXT COMPANY ELSE COMPANY = "" UNTIL COMPANY = ""
            COMPANY.LIST<-1> = COMPANY
        REPEAT
*
        LOOP REMOVE COMPANY FROM COMPANY.LIST SETTING D UNTIL COMPANY = ""
            CALL STANDARD.DISPLAY
            PRINT @(25,0):RVON:'CREATE FILES':RVOFF:S.CLEAR.EOL:
            PRINT @(0,4):
            INPUT.BUFFER = COMPANY:' REL.':RELEASE.NO:'.FILES Y'
            CALL CREATE.FILES
            IF E THEN GOTO FATAL.ERROR
        REPEAT
*
    END
*
* Run CREATE.INAU.RECORDS to copy records to correct files
*
    READV ALL.DATA FROM SAVEDLISTS,'REL.':RELEASE.NO:'.DATA',1 ELSE ALL.DATA = 0
    IF ALL.DATA THEN
        CALL STANDARD.DISPLAY
        PRINT @(25,0):RVON:'RELEASE DATA RECORDS':RVOFF:S.CLEAR.EOL:
        PRINT @(0,4):
        INPUT.BUFFER = RELEASE.NO:' REL.':RELEASE.NO:'.DATA  Y'
        EB.Upgrade.CreateInauRecords()
        IF E THEN GOTO FATAL.ERROR
    END
*
* Rebuild F.TYPE.PROG file (F.PGM.FILE concat file)
*
    PRINT @(0,4):
*
    READV NEW.PGMS FROM SAVEDLISTS,'REL.':RELEASE.NO:'.PGM.FILE',1 ELSE NEW.PGMS = 0
    IF NEW.PGMS THEN
        CALL STANDARD.DISPLAY
        PRINT @(25,0):RVON:'REBUILD PGM.FILE CONCAT FILE':RVOFF:S.CLEAR.EOL:
        PRINT @(0,4):
        EB.Upgrade.TypeProgRebuild()
    END
*
* Update F.DL.DATA with units from the data library in TEMP.RELEASE
*
    IF NOT(PATCH) THEN
        IF NOT(APPLICATION.RELEASE) THEN
*
            R.VOC = 'Q'
            R.VOC<2> = 'TEMP.RELEASE'
            R.VOC<3> = 'F.DL.DATA'
            WRITE R.VOC TO F.VOC,'F.DL.FROM.DATA'
*
            F.DL.FROM.DATA = ''
            OPEN '','F.DL.FROM.DATA' TO F.DL.FROM.DATA THEN
*
                F.DL.DATA = ''
                OPEN '','F.DL.DATA' TO F.DL.DATA THEN
*
                    CALL STANDARD.DISPLAY
                    PRINT @(25,0):RVON:'POPULATE DATA LIBRARY FROM TEMP.RELEASE':RVOFF:S.CLEAR.EOL:
                    PRINT @(0,4):
                    EB.Upgrade.DlParameterRun('R','','L','')
                    CALL STANDARD.DISPLAY
*
                END
            END
        END
    END
*
    INPUT.BUFFER = ''
*
RETURN
*
************************************************************************
*
* S U B R O U T I N E S
*
************************************************************************
INITIALISATION:
    RELEASE.SUCCESS = 0       ;* GB0001518
*
* Perform intialisation
*
    CALL INITIALISE.MAIN.COMMON
*
* Initialise variables
*
    CALL DISPLAY.MESSAGE(' ','')        ;* Dummy call to DISPLAY.MESSAGES to avoid common mismatch problem with S.COMMON
    USER.NO = @USERNO
    COMO.NAME = ''
    R.VOC = ''
    E = ''
    COMI = ''
    ECOMI = ''
    PROMPT ''
    SAVED.SPF.PRODUCTS = ''
    SOURCE.RELEASE = 'N'
    T.CONTROLWORD = C.U:@FM:C.B:@FM:C.E:@FM:C.F:@FM:C.V
    SQ = "'"
    DQ = '"'
    PATCH.RELEASE.IDS = ''
    INTERNAL.RELEASE = 0
    SP.RELEASE = '' ;* BG_100004305 S/E
    GLOBUS.PATCH.IDS = '' ; GRID.FLAG = 0 ; CR.RESULT = ''  ;* GLOBUS_CI_10008689 S/E
*
    EQUATE TRUE TO 1
    EQUATE FALSE TO 0
    F1 = C.U        ;* Had problems equating these
    F5 = C.V
    ERROR.TEXT = S.BELL:@(19,23):S.CLEAR.EOL:@(19,23)
    CLEAR.TEXT = @(19,23):S.CLEAR.EOL:@(19,23)
    RVON = S.REVERSE.VIDEO.ON
    RVOFF = S.REVERSE.VIDEO.OFF
    DUMMY = @(0,0)
    FINAL.COPY = 1  ;* GLOBUS_CI_10000500
*
* Clear EBS screen
*
    FOR LINE = 4 TO 19
        PRINT @(0,LINE):S.CLEAR.EOL:
    NEXT LINE
*
*   O P E N   F I L E S
*
* Open voc file in current account
*
    OPEN '','VOC' TO F.VOC ELSE
        E ='EB.RTN.UNABLE.OPEN.VOC.1'
        GOTO FATAL.ERROR
    END
*
* Delete null voc entry if it exists
*
    ID = ''
    DELETE F.VOC,ID
*
* Open savedlists
*
    OPEN '','&SAVEDLISTS&' TO SAVEDLISTS ELSE
        E ='EB.RTN.CANT.OPEN.&SAVEDLISTS'
        GOTO FATAL.ERROR
    END
*
    F.COMPANY = ''
    CALL OPF('F.COMPANY',F.COMPANY)
*
* Check PGM.DATA.CONTROL file exists first
*
    OPEN '','F.PGM.DATA.CONTROL' TO F.PGM.DATA.CONTROL ELSE
        E ='EB.RTN.UNABLE.OPEN.F.PGM.DATA.CONTROL.1':@FM:FROM.ACCOUNT
        GOTO FATAL.ERROR
    END
*
* Open all source files and F.RELEASE.DATA, creating them if they do not
* already exist
*
*
* SPECIAL.FILES are created if they do not already exist, then later
* populated with the equivalent file in TEMP.RELEASE
* CREATE.FILE.LIST are only created if they do not already exist (they
* do not need to be populated from TEMP.RELEASE)
*
    SPECIAL.FILES = 'F.PGM.DATA.CONTROL':@FM:T24$BP:@FM:'C.PROGS':@FM:'CPL.PROGS':@FM:'F.PROGS':@FM:'F.RELEASE.DATA'

    CREATE.FILE.LIST = 'F.PATCH.RELEASE'
    CREATE.FILE.LIST<-1> = SPECIAL.FILES
*
* Where we are running under jBASE there are none of the source files to worry about
* we also do not have any of the c / fortran or anything else to worry about
* The create file list is populated with the files below just to be on the safe side.
*
    IF RUNNING.IN.JBASE THEN
        SPECIAL.FILES = 'F.PGM.DATA.CONTROL':@FM:'F.RELEASE.DATA':@FM:T24$BP    ;* GLOBUS_EN_10000188 S/E
        CREATE.FILE.LIST = SPECIAL.FILES
    END
*
    MAX.FILES = DCOUNT(CREATE.FILE.LIST,@FM)
*
    FOR FILE.COUNT = 1 TO MAX.FILES
*
        FILE.NAME = CREATE.FILE.LIST<FILE.COUNT>
*
* Create the file if it does not already exist
*
        OPEN '',FILE.NAME TO TEMP.FILE ELSE
            CALL EBS.CREATE.FILE(FILE.NAME,'',ERROR.MSG)
            IF ERROR.MSG THEN
                E = ERROR.MSG
                GOTO FATAL.ERROR
            END
            OPEN '',FILE.NAME TO TEMP.FILE ELSE
                E ='EB.RTN.CANT.OPEN.4':@FM:FILE.NAME
                GOTO FATAL.ERROR
            END
        END
*
* Create the dictionary if it does not already exist
*
        OPEN 'DICT',FILE.NAME TO TEMP.FILE ELSE
            CALL EBS.CREATE.FILE(FILE.NAME,'',ERROR.MSG)
            IF ERROR.MSG THEN
                E = ERROR.MSG
                GOTO FATAL.ERROR
            END
        END

    NEXT FILE.COUNT
*
* Open F.RELEASE.DATA
*
    OPEN '','F.RELEASE.DATA' TO F.RELEASE.DATA ELSE
        E ='EB.RTN.CANT.OPEN.F.RELEASE.DATA'
        GOTO FATAL.ERROR
    END
*
* Open F.PATCH.RELEASE
*
    OPEN '','F.PATCH.RELEASE' TO F.PATCH.RELEASE ELSE
        TEXT ='CANNOT OPEN PATCH.RELEASE'
        CALL FATAL.ERROR('PERFORM.GLOBUS.RELEASE')          ;* Fatals as the file PATCH.RELEASE could not be opened
    END
*
* Get the path name of TEMP.RELEASE (required for patch releases)
*
    TEMP.RELEASE.PATH = ''
    IF RUNNING.IN.JBASE THEN
        E = ''
        EB.Upgrade.GetTempReleaseJbase(TEMP.RELEASE.PATH, E)
        R.VOC = 'F'
        R.VOC<2> = TEMP.RELEASE.PATH
        WRITE R.VOC TO F.VOC,'TEMP.RELEASE.UFD'
        OPEN '','TEMP.RELEASE.UFD' TO TEMP.RELEASE.UFD ELSE
            TEMP.RELEASE.UFD = ''
        END

    END ELSE
        R.VOC = 'Q'
        R.VOC<2> = 'TEMP.RELEASE'
        R.VOC<3> = '&UFD&'
        WRITE R.VOC TO F.VOC,'TEMP.RELEASE.UFD'
*
        OPEN '','TEMP.RELEASE.UFD' TO TEMP.RELEASE.UFD THEN
*
            STATUS STAT FROM TEMP.RELEASE.UFD THEN
                TEMP.RELEASE.PATH = STAT<20>
            END
        END
    END
*
* Open PATCH.BP
*
*!!! Check if not jbase here as could cause problems!
    IF NOT(RUNNING.IN.JBASE) THEN
* GLOBUS_CI_10008689 S
* open two directories GRID.BP and GRID.BP.O if not present then create the directories
        OPEN '','GRID.BP' TO GRID.BP ELSE
            EXECUTE 'CREATE.FILE GRID.BP 19' CAPTURING CR.RESULT
            OPEN '','GRID.BP' TO GRID.BP ELSE
                TEXT ='CANNOT OPEN GRID.BP'
                CALL FATAL.ERROR('PERFORM.GLOBUS.RELEASE')  ;* Fatals as the file GRID.BP could not be opened
            END
        END

        OPEN '','GRID.BP.O' TO GRID.BP.O ELSE
            EXECUTE 'CREATE.FILE GRID.BP.O 19' CAPTURING CR.RESULT
            OPEN '','GRID.BP.O' TO GRID.BP.O ELSE
                TEXT ='CANNOT OPEN GRID.BP.O'
                CALL FATAL.ERROR('PERFORM.GLOBUS.RELEASE')  ;* Fatals as the file GRID.BP.O could not be opened
            END
        END
* GLOBUS_CI_10008689 E
    END
* GB9801499s
* Need to close files under NT or it won't be deleted.
    CLOSE F.PGM.DATA.CONTROL
    CLOSE F.RELEASE.DATA
* GB9801499e
*
RETURN
*
*---------------------------------------------------------------------
VALIDATE.RELEASE.NO:
*
    R.VOC = "Q"
    R.VOC<2> = FROM.ACCOUNT
    R.VOC<3> = "&SAVEDLISTS&"
    WRITE R.VOC TO F.VOC, "%F.SL"
*
* If the savedlists do not exist in temp.release (probably because
* temp.release does not exist), do not give a fatal error.  Instead, set
* the list of releases to install to null as the client is probably doing
* a product release
*
    OPEN "","%F.SL" TO F.SL ELSE
        RELEASE.LIST = ''
        DISPLAY.LIST = 'No releases to be installed - TEMP.RELEASE does not exist'
        RETURN
    END
*
* Open voc file in the "from" account
*
    R.VOC = 'Q'
    R.VOC<2> = FROM.ACCOUNT
    R.VOC<3> = 'VOC'
    WRITE R.VOC TO F.VOC,'%FROM.ACCOUNT.VOC'
*
    OPEN '','%FROM.ACCOUNT.VOC' TO F.FROM.ACCOUNT.VOC ELSE
        E ='EB.RTN.UNABLE.OPEN.VOC.2':@FM:FROM.ACCOUNT
        GOTO FATAL.ERROR
    END
*
    IF SP.RELEASE THEN
*
        MAJOR = RELEASE.NO[".",1,1]     ;* BG_100004305 S
        MINOR = RELEASE.NO[".",2,1]
        DOT = RELEASE.NO[".",3,1]
        RELEASE.LIST = ""
        SERVICE.PACK.INS = R.SPF.SYSTEM<SPF.SERVICE.PCK.INSTLD>
        COMMAND = "HUSH ON"
        COMMAND<-1> = "SELECT %F.SL LIKE REL.SP..."
        COMMAND<-1> = "HUSH OFF"
        EXECUTE COMMAND
        LOOP READNEXT ID ELSE ID = "" UNTIL ID = ""
            ID = ID[".",2,1]
            IF ID[3,4] EQ MAJOR:MINOR AND (RIGHT(ID,8) GT RIGHT(SERVICE.PACK.INS,8) OR SERVICE.PACK.INS EQ '') THEN
                IF DOT LT ID[7,2] THEN  ;* ID[7,2] holds the qualified release no.
                    SP.RELEASE = ''
                    DISPLAY.LIST = 'Current release is not a qualified release for installing service packs'
                    RETURN
                END
                LOCATE ID IN RELEASE.LIST<1> BY "AR" SETTING D ELSE
                    RELEASE.LIST<-1> = ID
                END
            END
        REPEAT
        DISPLAY.LIST = RELEASE.LIST
        IF DISPLAY.LIST = '' THEN
            SP.RELEASE = ''
            DISPLAY.LIST = 'No service packs to be installed'
        END
    END ELSE        ;* BG_100004305 E
*
*
        MAJOR = RELEASE.NO[".",1,1]
        CHK.RELEASE.NO = ''
        G.REL = 0;
        REL.INF.CHK = ''      ;* contains all valid format of Releases.
        REL.INF.CHK = "G":@FM:"20":@FM:"R"
        R.BUILD.REL.INFO = '' ;* Contains all Builds-Release Information
        BEGIN CASE
            CASE MAJOR[1,1] = REL.INF.CHK<1>
                MINOR = RELEASE.NO[".",2,1]
                DOT = RELEASE.NO[".",3,1]
                G.REL = 1
*
* Pad major with zero is necessary (G9 becomes G09)
*
                IF MAJOR MATCHES 'G1N' THEN
                    MAJOR = 'G0':MAJOR[1]
                END
            CASE MAJOR[1,2] = REL.INF.CHK<2>          ;* Project builds starting with 20
                G.REL = 2
                CHK.RELEASE.NO = RELEASE.NO

            CASE MAJOR[1,1] = REL.INF.CHK<3>          ;* Rn Releases
                G.REL = 3;
                READ R.BUILD.REL.INFO FROM F.SL,"RELEASE-TO-BUILD" ELSE R.BUILD.REL.INFO = ''
                CHK.RELEASE.NO = RELEASE.NO
        END CASE
        GOSUB BUILD.RELEASE.LIST
        IF DISPLAY.LIST = '' THEN DISPLAY.LIST = 'No releases to be installed'
    END   ;* BG_100004305 S/E
RETURN
*
*---------------------------------------------------------------------
BUILD.RELEASE.LIST:
*
    COMMAND = "HUSH ON"
    COMMAND<-1> = "SELECT %F.SL LIKE REL... AND UNLIKE ...LIST..."
* ID may contain the following now REL.Gnn.n.nn, REL.yyyymm, REL.Rnn.GA.nnn
    COMMAND<-1> = "HUSH OFF"
    EXECUTE COMMAND

    RELEASE.LIST = "" ; PB.RELEASE.LIST = ""; RN.RELEASE.LIST = ""
    LOOP READNEXT ID ELSE ID = "" UNTIL ID = ""
        IF ID[1,4] = 'REL.' AND NOT(INDEX(ID,".INFO",1)) THEN         ;* SELECT is different now. contains REL*
            GSAV.REL = 0
            REL.NO = ID[".",2,3]        ;* Extract nn.nn.nn from REL.nn.nn.nn
            BEGIN CASE
                CASE REL.NO[1,1] = "G"
                    IF (ID['.',5,1] = '' AND REL.NO[".",3,1] <> "" AND REL.NO[1] # "m") THEN
                        GSAV.REL = 1        ;* Gnn.n.nn Releases
                    END

                CASE (REL.NO MATCHES "'20'4N":@VM:"'20'4N.3N")
                    GSAV.REL = 2  ;* 20yymm or 20yymm.nnn builds In future the format might be changed.

                CASE REL.NO MATCHES "'R'2N.3N"
                    GSAV.REL = 3  ;*R-type release
            END CASE
            IF GSAV.REL > 0 THEN
                GOSUB ADD.RELEASE.TO.LIST
            END
        END         ;* for ID = REL.
    REPEAT
*
    IF G.REL = 1 THEN         ;* If the current. release is Gxx then;
        IF RELEASE.NO MATCHES 'G1N' THEN
            PADDED.RELEASE.NO = 'G0':RELEASE.NO[2,99]       ;* Put in leaading zero (G9 becomes G09)
        END ELSE PADDED.RELEASE.NO = RELEASE.NO
*
        LOCATE PADDED.RELEASE.NO IN RELEASE.LIST<1> BY "AR" SETTING D ELSE
            D -= 1  ;* Current release not in TEMP.RELEASE
        END
*
        RELEASE.LIST = RELEASE.LIST[@FM,D+1,99]   ;* Release FROM RELEASE.NO
*
* Remove leading zeros (otherwise won't be able to find the select lists)
*
        MAX.RELS = DCOUNT(RELEASE.LIST,@FM)
        FOR V$COUNT = 1 TO MAX.RELS     ;* MAX.RELS will hold only maximum Gnn values
            IF RELEASE.LIST<V$COUNT>[1,2] = 'G0' THEN
                RELEASE.LIST<V$COUNT> = 'G':RELEASE.LIST<V$COUNT>[3,99]
            END
        NEXT V$COUNT

        IF MAX.RELS > 0 THEN
            IF PB.RELEASE.LIST THEN RELEASE.LIST<-1> =  PB.RELEASE.LIST
        END ELSE
            IF PB.RELEASE.LIST THEN RELEASE.LIST = PB.RELEASE.LIST
        END
        IF RN.RELEASE.LIST THEN RELEASE.LIST<-1> = RN.RELEASE.LIST

    END ELSE        ;* for Rx and PByyyymm
        IF PB.RELEASE.LIST THEN RELEASE.LIST<-1> = PB.RELEASE.LIST
        IF RN.RELEASE.LIST THEN RELEASE.LIST<-1> = RN.RELEASE.LIST
        IF R.BUILD.REL.INFO THEN        ;* will contain information only when installing from RXX

* contains the following syntax RxxFMyyyymm i.e. R05FM200501
            CONVERT ";" TO @VM IN R.BUILD.REL.INFO
            FPART = FIELD(RELEASE.NO,".",1)
            T.INLIST = DCOUNT(RELEASE.LIST,@FM)
            UPGR.REL = RELEASE.LIST<T.INLIST>
*Check RELEASE.LIST to find out what we are upgrading to.
            FP.UPGR.REL = FIELD(UPGR.REL,".",1)
            IF FPART NE FP.UPGR.REL THEN
* Change CHK.RELEASE.NO only when we are installing from Rxx.nnn to
* a project build or to another Rxx release. dont change When we upgrade to a
* service pack.(i.e. from R05.000 to R05.002 etc)
                LOCATE FPART IN R.BUILD.REL.INFO<1,1> SETTING DPOS THEN
                    CHK.RELEASE.NO = R.BUILD.REL.INFO<2,DPOS>
                END
            END
        END ELSE    ;* BG_100009040   S
            IF INDEX(CHK.RELEASE.NO,".",1) THEN
* We are installing from a SP build like 2005.001 /. 002
                FPART = FIELD(RELEASE.NO,".",1)
                T.INLIST = DCOUNT(RELEASE.LIST,@FM)
                UPGR.REL = RELEASE.LIST<T.INLIST> ;* Might be R06.000 or 200509 Or 200508.001
                FP.UPGR.REL = FIELD(UPGR.REL,".",1)

                IF FPART NE FP.UPGR.REL THEN      ;* BG_100009086
                    CHK.RELEASE.NO = FPART
                END
            END
        END         ;* BG_100009040 E

        LOCATE CHK.RELEASE.NO IN RELEASE.LIST<1> SETTING D ELSE
            D - = 1
        END

        RELEASE.LIST = RELEASE.LIST[@FM,D+1,99]

    END
    TOT.IN.LIST = DCOUNT(RELEASE.LIST,@FM)
    DISPLAY.LIST = RELEASE.LIST<TOT.IN.LIST>
* While displaying always display the release the client is upgrading to, no display of intermediate releases.
* Write these intermediate values to SAVEDLISTS(Code already present to do this).
RETURN
*---------------------------------------------------------------------
ADD.RELEASE.TO.LIST:
    BEGIN CASE
        CASE GSAV.REL = 1
            IF G.REL = 1 THEN     ;*Add to the release list, only if current release is Gnn.n.nn otherwise not necessary.

                N1 = REL.NO[".",1,1]
                N2 = REL.NO[".",2,1]
                N3 = REL.NO[".",3,1]
*
* If the release number has only one year digit (e.g. G9.n.nn), put in
* the leading zero (e.g. G09.n.nn)
*
                IF N1 MATCHES 'G1N' THEN
                    N1 = 'G0':N1[1]
                    REL.NO = 'G0':REL.NO[2,99]
                END
*
                CHECK.MMD =  (N1 GE MAJOR AND N2 GE MINOR AND N3 GE DOT)
                IF (N1 GT MAJOR) OR (N1 GE MAJOR AND N2 GT MINOR) OR CHECK.MMD THEN
                    LOCATE REL.NO IN RELEASE.LIST<1> BY "AR" SETTING D ELSE
                        INS REL.NO BEFORE RELEASE.LIST<D>
                    END
                END
            END ELSE
* For PB and RX start with G15...

                IF REL.NO MATCHES "'G15'.0X" THEN

                    LOCATE REL.NO IN RELEASE.LIST<1> BY "AR" SETTING D ELSE
                        INS REL.NO BEFORE RELEASE.LIST<D>
                    END
                END
            END
        CASE GSAV.REL =2          ;* Project Builds
*Either 200405 or 200505.001...


            LOCATE REL.NO IN PB.RELEASE.LIST<1> BY "AR" SETTING D.PB ELSE
                INS REL.NO BEFORE PB.RELEASE.LIST<D.PB>
            END

        CASE GSAV.REL =3          ;* R-type Releases
* R05 ; R06.GA ; R06.001 ; R06.GA.001
            LOCATE REL.NO IN RN.RELEASE.LIST<1> BY "AR" SETTING D.RN ELSE
                INS REL.NO BEFORE RN.RELEASE.LIST<D.RN>
            END


    END CASE
RETURN
*
*---------------------------------------------------------------------
VALIDATE.PRODUCT:
*
    DISPLAY.LIST = ''
    RELEASE.LIST = ''
    GOSUB DISPLAY.RELEASES
*
INPUT.PRODUCT:
*
    YTEXT = 'Enter product required or <RETURN> for patch releases'
    CALL TXTINP(YTEXT,8,22,50,'A')
    PRINT @(19,22):S.CLEAR.EOL:
*
    IF COMI = 'N' OR COMI = F1 THEN GOTO END.PRODUCT
*
    IF COMI THEN
*
* A product has been entered
*
        EB.Upgrade.CheckAvailability('PRODUCT',TO.ALLOW)      ;*Products to be installed only via T24.UPGRADE service
        IF NOT(TO.ALLOW) THEN
            TEXT = "Please use the service T24.UPGRADE"
            CALL REM
            RETURN
        END
        CALL CHECK.APPLICATION
*
        IF E THEN
            E = ''
            PRINT @(19,22):FMT('Invalid product entered','60R'):S.BELL:
            GOTO INPUT.PRODUCT
        END
*
        GOSUB BUILD.PRODUCT.LIST
*
        IF RELEASE.LIST THEN
*
* Display product to be installed
*
            LINE.POS = 5
            GOSUB DISPLAY.RELEASES
*
            FOR LINE.NO = LINE.POS+1 TO 19
                PRINT @(1,LINE.NO):S.CLEAR.EOL:
            NEXT LINE.NO
        END
*
    END ELSE
* If TEMP.RELEASE does not exist, patch releases are not possible
*
        IF TEMP.RELEASE.PATH = '' THEN
            E ='EB.RTN.TEMP.RELEASE.DOES.NOT.EXIST'
            GOTO FATAL.ERROR
        END
*
        CALL HUSHIT(1)
        EXECUTE 'COMO OFF'
        CALL HUSHIT(0)
*
* Check uniVerse revision is rev 9 or later (to enable uniVerse copies
* of object code)
*
*
* Transfer any patches in temp.release to PATCH.RELEASE
*
        GOSUB TRANSFER.PATCHES
*
* If no patches to be installed, display this before exiting
*
        IF SELECTED.ITEMS = '' THEN
            DISPLAY.LIST = 'No patches to be installed'
            GOSUB DISPLAY.RELEASES
            CALL INP('Press <RETURN>',8,22,'70','A')
        END ELSE
*
* Display list of patch releases
*
            EB.Upgrade.CheckAvailability('PATCH',TO.ALLOW)    ;*Patches to be installed only via T24 Updates
            IF NOT(TO.ALLOW) THEN
                TEXT = "Please use T24 Updates."
                CALL REM
                RETURN
            END
            LOOP
            UNTIL SELECTED.ITEMS = DISPLAY.LIST
                GOSUB SELECT.PATCHES
            REPEAT
*
* Clear middle screen
*
            FOR LINE.NO = 4 TO 19
                PRINT @(1,LINE.NO):S.CLEAR.EOL:
            NEXT LINE.NO
*
            LINE.POS = 5
*
            GOSUB DISPLAY.RELEASES
*
            PATCH = 'PATCH'
        END
    END
*
END.PRODUCT:
*
RETURN
*
*---------------------------------------------------------------------
DISPLAY.RELEASES:
* Displays release numbers
*
    COL.POS = 1
    PRINT @(1,LINE.POS):@(-4):
    MAX.RELS = COUNT(DISPLAY.LIST,@FM) + (DISPLAY.LIST <> '')
    FOR REL.COUNT = 1 TO MAX.RELS
        IF SP.RELEASE THEN    ;* BG_100004305 S
            DISPLAY.FIELD = LEFT(DISPLAY.LIST<REL.COUNT>,6):RIGHT(DISPLAY.LIST<REL.COUNT>,8)
        END ELSE    ;* BG_100004305 E
            DISPLAY.FIELD = DISPLAY.LIST<REL.COUNT>
        END         ;* BG_100004305 S/E
        DISPLAY.FIELD := ' '
        FIELD.LEN = LEN(DISPLAY.FIELD)
        IF (FIELD.LEN + COL.POS) > 79 THEN
            COL.POS = 1
            LINE.POS += 1
            PRINT @(1,LINE.POS):@(-4):
        END
        PRINT @(COL.POS,LINE.POS):DISPLAY.FIELD:
        COL.POS = COL.POS + FIELD.LEN + 1
        IF COL.POS > 79 THEN
            COL.POS = 1
            LINE.POS += 1
        END
    NEXT REL.COUNT
    IF COL.POS = 1 THEN PRINT @(1,LINE.POS):@(-4):
RETURN
*
*---------------------------------------------------------------------
TRANSFER.PATCHES:
* Transfer any patches in temp.release to F.PATCH.RELEASE
*
* Select &UFD& in TEMP.RELEASE to get a list of all patches
*
    SELECTED.ITEMS = ''
    DISPLAY.LIST = ''
    PATCHES.TO.DELETE = ''
*
    SSELECT TEMP.RELEASE.UFD
    LOOP
        READNEXT ID ELSE ID = ''
    WHILE ID
* jBASE changes here. For now we are assuming a .tar but this may change
* when we more platforms...
        IS.PATCH = ''
        RESULT = "" ;* CI_10002829S
        RETURN.CODE = ""      ;* CI_10002829E
        IF RUNNING.IN.JBASE THEN
* GLOBUS_BG_100001836 S
* Changes made under the CD GLOBUS_BG_100001659 has been changed back to
* unix specific commands if the operating system is UNIX.
            TEMP = R.SPF.SYSTEM<SPF.RUN.ACC.NAME>
            TEMP.OS = R.SPF.SYSTEM<SPF.OPERATING.SYSTEM>
            IF TEMP.OS EQ 'UNIX' THEN
                IF (ID MATCHES 'G0N.tar') OR (ID MATCHES 'g0N.tar') OR (ID MATCHES 'R0N.tar') OR (ID MATCHES 'B0N.tar') THEN      ;* GLOBUS_CI_10008689 S/E BG_100008451 S/E
                    IS.PATCH = 1
                    TAR.ID = ID
                    ID = FIELD(ID,'.tar',1)
* Un tar it into the run dir
                    EXECUTE.CMD = 'tar -xf ':TEMP.RELEASE.PATH :'/':TAR.ID
                    EXECUTE EXECUTE.CMD
                END
            END ELSE
                IF (ID MATCHES 'G0N') OR (ID MATCHES 'g0N') OR (ID MATCHES 'R0N') OR (ID MATCHES 'B0N') THEN  ;* GLOBUS_CI_10008689 S/E  BG_100008451 S/E
                    IS.PATCH = 1
                    COMMAND = TEMP.RELEASE.PATH:'/':ID:@FM:TEMP:'/':ID
                    SH.COPY = "COPY_R"
                    CALL SYSTEM.CALL(SH.COPY,"",COMMAND,RESULT,RETURN.CODE)
                END
            END
* GLOBUS_BG_100001659 E
* GLOBUS_BG_100001836 E
        END ELSE
            IF (ID MATCHES 'G0NUB') OR (ID MATCHES 'R0NUB') OR (ID MATCHES 'B0NUB') THEN  ;* GLOBUS_CI_10008689 S/E  BG_100008451 S/E
                IS.PATCH = 1
                ID = FIELD(ID,'UB',1)
*
* UVRESTORE the patch file to create a patch unit. Note: the patch unit
* is created locally, then deleted.  If the patch is to be installed,
* it is deleted again).  This is because, if the patch unit was
* restored into TEMP.RELEASE, there could be problems with access rights.
*
                REMOTE.IDX = INDEX(TEMP.RELEASE.PATH,'!',1)
                IF REMOTE.IDX THEN TEMP.RELEASE.PATH = TEMP.RELEASE.PATH[REMOTE.IDX+1,999]
* CI_10002829S
* UVRESTORE and format.conv is  done by SYSTEM.CALL routine.
*
                COMMAND = TEMP.RELEASE.PATH:'/':ID
                CALL SYSTEM.CALL("UVRESTORE","",COMMAND,RESULT,RETURN.CODE)
* CI_10002829E
            END
        END
        IF IS.PATCH THEN
*
* Open the patch unit
*
            R.VOC = 'F'
            R.VOC<2> = ID
* GLOBUS_CI_10011435 S/E
* Removed the dictionary  creation part
            WRITE R.VOC TO F.VOC,ID
*
            OPEN '',ID TO PATCH.UNIT THEN
*
                READ R.NEW.PATCH FROM PATCH.UNIT,ID THEN
*
* Write out or update F.PATCH.RELEASE record
*
                    READ R.PATCH.RELEASE FROM F.PATCH.RELEASE,ID ELSE R.PATCH.RELEASE = ''
                    FOR AF = EB.Upgrade.PatchRelease.PatRestoredUser TO EB.Upgrade.PatchRelease.PatRestdTime
                        R.NEW.PATCH<AF> = R.PATCH.RELEASE<AF>
                    NEXT AF
                    WRITE R.NEW.PATCH TO F.PATCH.RELEASE,ID
                    THIS.DISPLAY = FMT(ID,'9L'):FMT(R.NEW.PATCH<EB.Upgrade.PatchRelease.PatShortDescrptn>[1,50],'52L')
                    CONVERT @VM TO ' ' IN THIS.DISPLAY
                    SELECTED.ITEMS<-1> = THIS.DISPLAY
                END
                PATCHES.TO.DELETE<-1> = ID
            END
        END
    REPEAT
*
    MAX.PATCHES = DCOUNT(PATCHES.TO.DELETE,@FM)
    FOR PATCH.COUNT = 1 TO MAX.PATCHES
        ID = PATCHES.TO.DELETE<PATCH.COUNT>
*
* jBASE doesn't see theses as "files" so we need to do a rm -r, or the equivalent
*
        IF RUNNING.IN.JBASE THEN
            COMMAND = ID
            RESULT = ""
            SH.REMOVE = "REMOVE_R"
            RETURN.CODE = ""
            CALL SYSTEM.CALL(SH.REMOVE,"",COMMAND,RESULT,RETURN.CODE)
        END ELSE
            CALL HUSHIT(1)
            EXECUTE 'DELETE.FILE ':ID   ;* Delete local patch unit
            CALL HUSHIT(0)
        END
    NEXT PATCH.COUNT
RETURN
*
*---------------------------------------------------------------------
SELECT.PATCHES:
* Display list of all patches and allow user to choose which patches to
* install
*
    DISPLAY.LIST = SELECTED.ITEMS
    SELECTED.ITEMS = ''
    INPUT.PROMPT = "F5 for ALL items, 'C'hoose item nn { nn ..}  OR  'E'xclude item nn { nn ..}"
    CURRENT.PAGE = 1
    ALLOWED.INPUT = ''
    LINE.NUMBERING = 1
    VALID.RESPONSE = FALSE
    PROCESS.INVALID = FALSE
    FUNCTION.KEYS = 1
*
    ALL.CHOSEN = 0  ;* flag set when User positively selects whole list
    CHOOSE = 0      ;* flag set if item chosen from list
    EXCLUDE = 0     ;* flag set if item deleted from list
*
    LOOP
        RESPONSE = ''
        CALL EB.DISPLAY.LIST(DISPLAY.LIST,INPUT.PROMPT,CURRENT.PAGE,
        ALLOWED.INPUT,LINE.NUMBERING,VALID.RESPONSE,
        PROCESS.INVALID,FUNCTION.KEYS,RESPONSE)
        IF RESPONSE EQ C.U THEN
            SELECTED.ITEMS = ''
            DISPLAY.LIST = ''
            RELEASE.LIST = ''
            GOTO END.SELECTION
        END
        IF RESPONSE EQ C.V THEN
            RELEASE.LIST = ''
            PTR = 1
            LOOP
                THIS.DISPLAY = DISPLAY.LIST<PTR>
            UNTIL THIS.DISPLAY EQ '' DO
                THIS.DISPLAY = FIELD(THIS.DISPLAY,' ',1)
                RELEASE.LIST<PTR> = THIS.DISPLAY
                PTR += 1
            REPEAT  ;* for next display item
            ALL.CHOSEN = 1
        END
    UNTIL ALL.CHOSEN OR (RESPONSE EQ '' AND CHOOSE) DO
        RESPONSE = TRIM(RESPONSE)
        CONVERT C.U:C.V TO '' IN RESPONSE
        CONVERT ' ' TO @FM IN RESPONSE
        BEGIN CASE
            CASE RESPONSE<1> EQ 'C' AND NOT(EXCLUDE)  ;* selectively choose from list
                DEL RESPONSE<1>
                LOOP
                    ITEM = RESPONSE<1>
                UNTIL ITEM EQ '' DO
                    DEL RESPONSE<1>
                    THIS.DISPLAY = DISPLAY.LIST<ITEM>
                    IF NOT(INDEX(THIS.DISPLAY,'chosen',1)) THEN
                        FND = 1
                        LOCATE THIS.DISPLAY IN SELECTED.ITEMS<1> BY 'AL' SETTING POS ELSE FND = 0
                        IF NOT(FND) THEN
                            INS THIS.DISPLAY BEFORE SELECTED.ITEMS<POS>
                            THIS.DISPLAY = FMT(THIS.DISPLAY,'76L')
                            THIS.DISPLAY[70,6] = 'chosen'
                            DISPLAY.LIST<ITEM> = THIS.DISPLAY
                            CHOOSE = 1
                        END
                    END
                REPEAT
            CASE RESPONSE<1> EQ 'E' AND NOT(CHOOSE)   ;* selectively exclude from list
                DEL RESPONSE<1>
                DEL.ITEMS = ''    ;* sort by.dsnd the attributes to be deleted
                LOOP
                    ITEM = RESPONSE<1>
                UNTIL ITEM EQ '' DO
                    DEL RESPONSE<1>
                    FND = 1
                    LOCATE ITEM IN DEL.ITEMS<1> BY 'AR' SETTING POS ELSE FND = 0
                    IF NOT(FND) THEN
                        INS ITEM BEFORE DEL.ITEMS<POS>
                    END
                REPEAT
                NBR.ATTS = COUNT(DEL.ITEMS,@FM) + (DEL.ITEMS<>'')
                FOR X = NBR.ATTS TO 1 STEP -1
                    ITEM = DEL.ITEMS<X>
                    DEL DISPLAY.LIST<ITEM>
                    EXCLUDE = 1
                NEXT X
            CASE RESPONSE<1> EQ 'E' AND CHOOSE
                E ='EB.RTN.ITEMS.ALREADY.CHOSEN.PRESS.RETURN.SEE.NEW.LIST'
                CALL ERR
        END CASE
    REPEAT
*
    IF NOT(CHOOSE) THEN SELECTED.ITEMS = DISPLAY.LIST
    NBR.SELECTED.ITEMS = COUNT(SELECTED.ITEMS,@FM) + (SELECTED.ITEMS<>'')
*
END.SELECTION:
*
RETURN
*
*---------------------------------------------------------------------
BUILD.PRODUCT.LIST:
* Build release list for installing a new product
*
* Open GLOBUS.BP.O
*
    IF NOT(RUNNING.IN.JBASE) THEN       ;* GLOBUS_EN_10000188 S
        OPEN '','GLOBUS.BP.O' TO GLOBUS.BP.O ELSE
            E ='EB.RTN.UNABLE.OPEN.GLOBUS.BP.O'
            GOTO FATAL.ERROR
        END
    END   ;* GLOBUS_EN_10000188 E
*
* GB9801499s
    OPEN '','F.RELEASE.DATA' TO F.RELEASE.DATA ELSE
        E ='EB.RTN.CANT.OPEN.F.RELEASE.DATA'
        GOTO FATAL.ERROR
    END
* GB9801499e
*
* Check that the application is on the SPF
*
    LOCATE COMI IN R.SPF.SYSTEM<SPF.PRODUCTS,1> SETTING X ELSE
        E ='EB.RTN.APP.NOT.ON.SPF'
        GOTO FATAL.ERROR
    END
*
* Application has been entered.  Build a select list of items to be
* released from PGM.DATA.CONTROL
*
    PRINT @(1,5):'Creating release list for ':COMI:@(-4):
    CALL HUSHIT(1)
    EXECUTE 'SSELECT F.PGM.DATA.CONTROL WITH F1 EQ "':COMI:'"'
    EXECUTE "SAVE.LIST REL.":COMI
    CALL HUSHIT(0)
*
* Check that all the items to be released actually exist
*
    READ APP.LIST FROM SAVEDLISTS,'REL.':COMI ELSE APP.LIST = ''
    NEW.LIST = ''
    MAX.ITEMS = COUNT(APP.LIST,@FM) + (APP.LIST <> '')
    FOR ITEM.COUNT = 1 TO MAX.ITEMS
        ITEM = APP.LIST<ITEM.COUNT>
        RECORD.EXISTS = 1
        IF ITEM[1,3] = 'BP>' THEN
            ITEM = ITEM[4,99]
            IF NOT(RUNNING.IN.JBASE) THEN         ;* GLOBUS_EN_10000188 S
                READV TEMP FROM GLOBUS.BP.O,ITEM,0 ELSE RECORD.EXISTS = 0
            END     ;* GLOBUS_EN_10000188 E
        END ELSE
            READV TEMP FROM F.RELEASE.DATA,ITEM,0 ELSE RECORD.EXISTS = 0
        END
        IF RECORD.EXISTS THEN NEW.LIST<-1> = APP.LIST<ITEM.COUNT>
    NEXT ITEM.COUNT
    WRITE NEW.LIST TO SAVEDLISTS,'REL.':COMI
*
    DISPLAY.LIST = COMI
    RELEASE.LIST = COMI
    APPLICATION.RELEASE = 1
RETURN
*
*---------------------------------------------------------------------
TRANSFER.PATCH.ITEMS:
* Patch release - transfer programs to PATCH.BP.O and data items to
* F.RELEASE.DATA
*
* Open F.RELEASE.DATA (closed at the end of the INIT subroutine)
*
    OPEN '','F.RELEASE.DATA' TO F.RELEASE.DATA ELSE
        E ='EB.RTN.CANT.OPEN.F.RELEASE.DATA'
        GOTO FATAL.ERROR
    END
*
    NEW.RELEASE.LIST = ''
    PATCH.RELEASE.IDS = RELEASE.LIST    ;* Used for updating PATCH.RELEASE records
*
    FOR REL.COUNT = 1 TO DCOUNT(RELEASE.LIST,@FM)
        RELEASE.NO = RELEASE.LIST<REL.COUNT>
        RESULT = '' ;* CI_10002829S
        RETURN.CODE = ''      ;* CI_10002829E
        IF RUNNING.IN.JBASE THEN
            IF TEMP.OS EQ 'UNIX' THEN   ;*  GLOBUS_BG_100001836 S
* Changes made under the CD GLOBUS_BG_100001659 has been changed back to
* unix specific commands if the operating system is UNIX.
                EXECUTE.CMD = 'tar -xvf ' : TEMP.RELEASE.PATH : '/' :RELEASE.NO: '.tar'
                EXECUTE EXECUTE.CMD
            END ELSE
                COMMAND = TEMP.RELEASE.PATH:'/':RELEASE.NO:@FM:TEMP:'/':RELEASE.NO
                SH.COPY = "COPY_R"
                CALL SYSTEM.CALL(SH.COPY,"",COMMAND,RESULT,RETURN.CODE)
            END
* GLOBUS_BG_100001659 E
* GLOBUS_BG_100001836 E
        END ELSE
* CI_10002829S
* UVRESTORE and format.conv  is done at SYSTEM.CALL routine
            COMMAND = TEMP.RELEASE.PATH:'/':RELEASE.NO
            CALL SYSTEM.CALL("UVRESTORE","",COMMAND,RESULT,RETURN.CODE)
* CI_10002829E
        END
*
* Open the patch unit
*
        R.VOC = 'F'
        R.VOC<2> = RELEASE.NO
        IF RUNNING.IN.JBASE THEN
            R.VOC<3> = RELEASE.NO:']D'  ;* GLOBUS_CI_10008689 S/E
        END
        WRITE R.VOC TO F.VOC,RELEASE.NO
*
        PATCH.UNIT = ''
        OPEN '',RELEASE.NO TO PATCH.UNIT ELSE
            E ='EB.RTN.CANT.OPEN.PATCH.RELEASE':@FM:RELEASE.NO
            GOTO FATAL.ERROR
        END
*
* Read the definition record from F.PATCH.RELEASE
*
        READ R.PATCH.RELEASE FROM F.PATCH.RELEASE,RELEASE.NO ELSE
            E = 'EB.RTN.CANT.READ.F.PATCH.RELEASE':@FM:RELEASE.NO
            GOTO FATAL.ERROR
        END
*
* Process each record in turn
*
        MAX.RECS = DCOUNT(R.PATCH.RELEASE<EB.Upgrade.PatchRelease.PatSvRecordName>,@VM)
        FOR REC.COUNT = 1 TO MAX.RECS
            FILE.NAME = R.PATCH.RELEASE<EB.Upgrade.PatchRelease.PatSvFileName,REC.COUNT>
            REC.NAME = R.PATCH.RELEASE<EB.Upgrade.PatchRelease.PatSvRecordName,REC.COUNT>
            REC.ID = 'REC':FMT(REC.COUNT,"3'0'R")
            TEMP.ID = FILE.NAME:'>':REC.NAME
            READ R.REC FROM PATCH.UNIT,REC.ID THEN
*
* For object code, do a uniVerse copy (since the Basic read/write seems
* to corrupt the object code)
*
                IF FILE.NAME MATCHES 'BP.O':@VM:'BP1.O':@VM:'BP2.O' THEN
*
* There is no object code to move around for a jBASE patch, but we need to copy the bin
* and lib directory to the correct location, i.e. under globuspatch/patchno
*
                    IF NOT(RUNNING.IN.JBASE) THEN
                        IF (RELEASE.NO MATCHES 'R0N') THEN  ;* GLOBUS_CI_10008689 S
                            GRID.FLAG = 1
                            EXECUTE.CMD = 'COPY FROM ':RELEASE.NO:' TO GRID.BP.O ':REC.ID:',':REC.NAME:' OVERWRITING'
                        END ELSE
                            EXECUTE.CMD = 'COPY FROM ':RELEASE.NO:' TO PATCH.BP.O ':REC.ID:',':REC.NAME:' OVERWRITING'
                        END   ;* GLOBUS_CI_10008689 E
                        CALL HUSHIT(1)
                        EXECUTE EXECUTE.CMD
                        CALL HUSHIT(0)
                        TEMP.ID = 'BP>':REC.NAME
                    END
                END ELSE
*
* If BP file (not BP.O file), e.g. an insert, copy just to PATCH.BP
*
                    IF FILE.NAME MATCHES 'BP':@VM:'BP1':@VM:'BP2':@VM:T24$BP THEN
                        IF (RELEASE.NO MATCHES 'R0N') THEN  ;* GLOBUS_CI_10008689 S
                            WRITE R.REC TO GRID.BP,REC.NAME
                        END ELSE
*                            WRITE R.REC TO PATCH.BP,REC.NAME
                        END   ;* GLOBUS_CI_10008689 E
                        TEMP.ID = 'BP>':REC.NAME
                    END ELSE
*
* Data record.  Copy to F.RELEASE.DATA
*
                        WRITE R.REC TO F.RELEASE.DATA,TEMP.ID
                    END
                END
                LOCATE TEMP.ID IN NEW.RELEASE.LIST<1> BY 'AL' SETTING POS ELSE
                    INS TEMP.ID BEFORE NEW.RELEASE.LIST<POS>
                END
            END ELSE
                IF RUNNING.IN.JBASE THEN
*!!! Need to check that it is a data item that is missing
                END ELSE
                    E = 'EB.RTN.G.MISS.PATCH':@FM:FILE.NAME:@VM:REC.NAME:@SM:RELEASE.NO
                    GOTO FATAL.ERROR
                END
            END
*
*
        NEXT REC.COUNT
*
    NEXT REL.COUNT
    WRITE NEW.RELEASE.LIST TO SAVEDLISTS,'REL.':RELEASE.LIST<1>
    RELEASE.LIST = RELEASE.LIST<1>      ;* Otherwise it will try to merge the lists
*
RETURN
*
*---------------------------------------------------------------------
UPDATE.PATCH.RECS:
* Update patch records with restored history
*
    TEMP.DATE = OCONV(DATE(),'D-')
    TEMP.TODAY = TEMP.DATE[7,4]:TEMP.DATE[1,2]:TEMP.DATE[4,2]
*
    FOR REL.COUNT = 1 TO DCOUNT(PATCH.RELEASE.IDS,@FM)
        TEMP.REL.NO = PATCH.RELEASE.IDS<REL.COUNT>
* GLOBUS_CI_10008689 S
*      IF TEMP.REL.NO MATCHES 'G0N' THEN    /BG_100008451 S
        GLOBUS.PATCH.IDS<-1> = TEMP.REL.NO
*       END         ;* GLOBUS_CI_10008689 E    /BG_100008451 E
        READ R.PATCH.RELEASE FROM F.PATCH.RELEASE,TEMP.REL.NO THEN
            IF R.PATCH.RELEASE<EB.Upgrade.PatchRelease.PatRestdDate,1> THEN
                FOR TEMP.AF = EB.Upgrade.PatchRelease.PatRestoredUser TO EB.Upgrade.PatchRelease.PatRestdTime
                    INS '' BEFORE R.PATCH.RELEASE<TEMP.AF,1>
                NEXT TEMP.AF
            END
*
            R.PATCH.RELEASE<EB.Upgrade.PatchRelease.PatRestoredUser,1> = TNO:'_':OPERATOR
            R.PATCH.RELEASE<EB.Upgrade.PatchRelease.PatRestdRelease,1> = R.SPF.SYSTEM<SPF.CURRENT.RELEASE>
            R.PATCH.RELEASE<EB.Upgrade.PatchRelease.PatRestdDate,1> = TEMP.TODAY
            R.PATCH.RELEASE<EB.Upgrade.PatchRelease.PatRestdTime,1> = OCONV(TIME(),'MTS')
*
            WRITE R.PATCH.RELEASE TO F.PATCH.RELEASE,TEMP.REL.NO
        END
*
    NEXT REL.COUNT
*
RETURN
*
*
*---------------------------------------------------------------------
POPULATE.FILES:
* Populate files (T24.BP, GLOBUS.BP.O, C.PROGS, CPL.PROGS, F.PROGS,
* F.RELEASE.DATA and F.PGM.DATA.CONTROL)
*
    MAX.FILES = DCOUNT(SPECIAL.FILES,@FM)
*
    FOR FILE.COUNT = 1 TO MAX.FILES
*
* GB9801499s
        FILE.FLAG = ''
* GB9801499e
        TEMP.FILE = SPECIAL.FILES<FILE.COUNT>

        BEGIN CASE

            CASE TEMP.FILE = 'F.RELEASE.DATA'
* GB9801499s
                FILE.FLAG = 1
* GB9801499e
                TEMP.FROM.FILE = 'F.RELEASE.RECORDS'

            CASE TEMP.FILE = 'F.PGM.DATA.CONTROL'
* GB9801499s
                FILE.FLAG = 1
* GB9801499e
                TEMP.FROM.FILE = 'F.PGM.DATA.CONTROL'

            CASE TEMP.FILE = T24$BP
                IF RUNNING.IN.JBASE THEN    ;* GLOBUS_BG_100000229 S
                    TEMP.FROM.FILE = 'BP'   ;* Regardless of precision setting, not required for jBASE
                END ELSE          ;* GLOBUS_BG_100000229 E
                    IF R.SPF.SYSTEM<SPF.EXTENDED.PREC> = 'Y' THEN
                        TEMP.FROM.FILE = 'EP'
                    END ELSE
                        TEMP.FROM.FILE = 'BP'
                    END
                END     ;* GLOBUS_BG_100000229 S/E

            CASE TEMP.FILE = 'GLOBUS.BP.O'
                IF R.SPF.SYSTEM<SPF.EXTENDED.PREC> = 'Y' THEN
                    TEMP.FROM.FILE = 'EP.O'
                END ELSE
                    TEMP.FROM.FILE = 'BP.O'
                END

            CASE 1
                TEMP.FROM.FILE = TEMP.FILE
        END CASE
*
        GOSUB CREATE.AND.POPULATE
*
    NEXT FILE.COUNT
*
* Copy inserts from T24.BP to RG.BP
*
    IF SP.RELEASE THEN CALL HUSHIT(1)  ;* BG_100004305 S/E
    PRINT
    PRINT 'Updating inserts in RG.BP'
    RG.INSERTS = "I_COMMON I_EQUATE I_RC.COMMON I_SCREEN.VARIABLES I_F.COMPANY I_F.LANGUAGE I_F.USER I_F.STANDARD.SELECTION I_F.DATES"      ;* Include I_F.DATES also
    EXECUTE 'COPY FROM ':T24$BP:' TO RG.BP ':RG.INSERTS:' OVERWRITING'
    PRINT 'AFTER RG.BP'
    IF SP.RELEASE THEN CALL HUSHIT(0)  ;* BG_100004305 S/E
*
RETURN
*
*---------------------------------------------------------------------
CREATE.AND.POPULATE:
* Copy the files from TEMP.RELEASE
*
    IF SP.RELEASE THEN CALL HUSHIT(1)  ;* BG_100004305 S/E
    PRINT
    PRINT 'Populating ':TEMP.FILE
    R.VOC = 'Q'
    R.VOC<2> = 'TEMP.RELEASE'
    R.VOC<3> = TEMP.FROM.FILE
    K.VOC = '%':TEMP.FILE
    WRITE R.VOC TO F.VOC,K.VOC
*
    OPEN '',K.VOC TO FROM.FILE ELSE
        E = 'EB.RTN.UNABLE.OPEN.TEMP.RELEASE':@FM:TEMP.FROM.FILE
        GOTO FATAL.ERROR
    END
*
    STATUS STAT FROM FROM.FILE THEN UNIX.FROM.PATH = STAT<20> ELSE
        E ='EB.RTN.UNABLE.GET.PATHNAME':@FM:TEMP.FROM.FILE
        GOTO FATAL.ERROR
    END
*
    REMOTE.IDX = INDEX(UNIX.FROM.PATH,'!',1)
    IF REMOTE.IDX THEN UNIX.FROM.PATH = UNIX.FROM.PATH[REMOTE.IDX+1,999]
*
* Check whether the file already exists.  If it does, delete it, as the
* whole file/directory will be copied over from TEMP.RELEASE
*
    UNIX.TO.PATH = '../':TEMP.FILE
    OPEN '',TEMP.FILE TO F.TEMP.FILE THEN
        STATUS STAT FROM F.TEMP.FILE THEN
            UNIX.TO.PATH = STAT<20>
            PRINT 'Deleting ':TEMP.FILE:'.  Started at ':OCONV(TIME(),'MTS'):
* GB9800613 s
            COMMAND = UNIX.TO.PATH
* GB9801499s
            IF FILE.FLAG THEN
                CLOSE F.TEMP.FILE
                SH.REMOVE = "REMOVE"
            END ELSE
* GB9801499e
                SH.REMOVE = "REMOVE_R"
* GB9801499s
            END
* GB9801499e
            RESULT = ""
            RETURN.CODE = ""
            CALL SYSTEM.CALL(SH.REMOVE,"",COMMAND,RESULT,RETURN.CODE)
* GB9800613 e
            PRINT '  Finished at ':OCONV(TIME(),'MTS')
        END
    END
*
* Copy the file/directory over
*
    PRINT 'Populating ':TEMP.FILE:'.  Started at ':OCONV(TIME(),'MTS'):
* GB9800613 s
    COMMAND = ""
    COMMAND<1> = UNIX.FROM.PATH
    COMMAND<2> = UNIX.TO.PATH
* GB9801499s
    IF FILE.FLAG THEN
        SH.COPY = "COPY"
    END ELSE
* GB9801499e
        SH.COPY = "COPY_R"
* GB9801499s
    END
* GB9801499e
    RESULT = ""
    RETURN.CODE = ""
    CALL SYSTEM.CALL(SH.COPY,"",COMMAND,RESULT,RETURN.CODE)
* GB9800613 e
    PRINT '  Finished at ':OCONV(TIME(),'MTS')
    IF SP.RELEASE THEN CALL HUSHIT(0)  ;* BG_100004305 S/E
*
    DELETE F.VOC,K.VOC
*
RETURN
*
*---------------------------------------------------------------------
PATCH.CATALOG:
* Recatalog programs in PATCH.BP
*
    MAX.PROGS = DCOUNT(PROGS.TO.COMPILE,@FM)
    FOR PROG.COUNT = 1 TO MAX.PROGS
        PGM.ID = PROGS.TO.COMPILE<PROG.COUNT>
* GLOBUS_CI_10008689 S
        IF GRID.FLAG THEN
            EXECUTE 'CATALOG GRID.BP ':PGM.ID:' LOCAL'
        END ELSE
            EXECUTE 'CATALOG PATCH.BP ':PGM.ID:' LOCAL'
        END         ;* GLOBUS_CI_10008689 E
    NEXT PROG.COUNT
*
RETURN
*
*---------------------------------------------------------------------
FATAL.ERROR:
* Routine to deal with an unrecoverable error such as unopenable file
*
    CALL STANDARD.DISPLAY
    PRINT @(40-(INT(LEN(E)/2)),5):RVON:E:RVOFF:
    IF COMO.NAME THEN PRINT @(25,19):'COMO IS ':COMO.NAME:
    PRINT ERROR.TEXT:FMT('PRESS <RETURN> TO CONTINUE','60R'):
    PRINT @(8,22):
    INPUT XX
    PRINT @(0,18):
    CALL HUSHIT(1)
    EXECUTE 'COMO OFF'
    CALL HUSHIT(0)
    ETEXT = E
    INPUT.BUFFER = ''
*
V$EXIT:
*
    IF RELEASE.SUCCESS THEN   ;*removed the call to RESET.GLOBUS.RELEASE
        IF NOT(RUNNING.IN.JBASE) THEN
            IF NOT(PATCH) THEN
                IF FINAL.COPY > 0 THEN
                    E = ""
                    GOSUB UPDATE.PRE.RELEASE.PROGS.O
                    IF E THEN GOTO FATAL.ERROR
                END
            END
        END
    END
* GLOBUS_CI_10000500 /E
    RELEASE F.SPF,'SYSTEM'
RETURN TO V$EXIT          ;* Clear GOSUB stack

*-----------------------------------------------------------------------------
* GLOBUS_CI_10000500 /S
UPDATE.PRE.RELEASE.PROGS.O:
*  Using the RELEASE.PROGS SELECT-LIST defined in the TEMP.RELEASE area
*  transfer all programs in list from GLOBUS.BP.O into PRE.RELEASE.PROGS.O
*  area.

    READ R.LIST FROM F.SL,"RELEASE.PROGS" ELSE
        E ="EB.RTN.RELEASE.PROGS.SAVEDLISTS.NOT.FOUND.TEMP.RELEASE"
        RETURN
    END
*
** Ensure that the PRE.RELEASE.PROGS file exists.
*
    OPEN "","PRE.RELEASE.PROGS.O" TO F.PRPO ELSE
        EXECUTE "CREATE.FILE PRE.RELEASE.PROGS.O 19"
        OPEN "","PRE.RELEASE.PROGS.O" TO F.PRPO ELSE
            E ="EB.RTN.CANT.OPEN.PRE.RELEASE.PROGS.O"
            RETURN
        END
    END

    MORE = 0
    LOOP
        REMOVE PROG.NAME FROM R.LIST SETTING MORE
    UNTIL NOT(MORE : PROG.NAME) DO
        CMD = "COPY FROM GLOBUS.BP.O TO PRE.RELEASE.PROGS.O "
        CMD := PROG.NAME : " OVERWRITING"
        EXECUTE CMD
    REPEAT

    FINAL.COPY = 0
RETURN
* GLOBUS_CI_10000500 /E
END
