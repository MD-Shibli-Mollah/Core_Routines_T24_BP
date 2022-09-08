* @ValidationCode : Mjo4MDk0NDkwNzA6Q3AxMjUyOjE1NDI3MTIyODA5MTc6cmF2aW5hc2g6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgxMS4yMDE4MTAyMi0xNDA2Oi0xOi0x
* @ValidationInfo : Timestamp         : 20 Nov 2018 16:41:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ravinash
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 26 07/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>1912</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.Upgrade
SUBROUTINE GLOBUS.RELEASE
*==============================================================================
* This is the first program in the release procedures and is used both
* internally at Temenos for releases to ATB and BNK and also externally
* at client sites.
*
* This is a new version of GLOBUS.RELEASE which replaces
* RECOMP.RELEASE.PROGS by compiling and cataloging all the release
* programs, then calls PERFORM.GLOBUS.RELEASE, which was originally
* called GLOBUS.RELEASE
*
* All the programs used by the release procedures will reside in
* BP in TEMP.RELEASE, as well as in the BPs of any release in
* which they have been amended. EBS.SOFTWARE.HANDOVER will automatically
* update this BP.  To identify a program as a release program it must be
* on the select list, RELEASE.PROGS in TEMP.RELEASE. Therefore, if any
* new programs are created, they must be added to the select list
*==============================================================================
*
* 07/07/95  GB9500812
*           Copy over inserts in the select list RELEASE.PROGS if they
*           do not already exist (this is so that CREATE.INAU.RECORDS
*           can pick up inserts for new files)
*           Also enable a new option (XX) to be entered so that programs
*           being released (rather than the programs used by the
*           release procedures) are not compiled and cataloged.  This is
*           useful if the release has previously fallen over after
*           successfully compiling and cataloging all programs.
*
* 05/10/95  GB9501137
*           Check that the savedlists exists in TEMP.RELEASE only if
*           the user wishes to recopy and recompile the release programs.
*           This means that if a user wishes to do a product release, it
*           does not matter if the temp.release area does not exist.
*
* 15/05/97  GB9700440
*           Amend program to cater for object releases.  Source code
*           releases (and compilations) will only be done if the
*           SOURCE.RELEASE flag on the SPF is set or if extended
*           precision is on.
*           Also BP1 and BP2 will be replaced by GLOBUS.BP. This
*           program needs to work with both GLOBUS.BP and BP1 and BP2,
*           as the new version of this program could be run before the
*           BPs have been converted (if the release has been stopped
*           and restarted)
*
* 23/06/97  GB9700745
*           Allow another reply to the "Do you wish to continue" prompt,
*           of "YS", to stop source code being deleted (required for the
*           internal upgrade to BNK)
*
* 25/07/97  GB9700869
*           Remove the machine id from the UNIX pathname when copying
*           files across the network (really only a problem at Temenos)
*
* 16/12/97  GB9701462
*           Amend release procedures so that TEMP.RELEASE no longer
*           contains sub-directories for each release; instead it will
*           contain all programs and data items for the current release.
*           This means that the need for BP (containing the
*           latest version of all the release programs) no longer exists.
*           Release programs can be copied from BP.
*
* 20/04/98  GB9800387
*           Do not give a fatal error if temp.release does not exist -
*           this is OK if doing a product release.
*
* 05/06/98 - GB9800613
*            Make all operating system calls via central routine
*
*
* 05/11/98 - GB9801399
*            Remove all references to MASTER.ACCOUNT (general tidying up
*            up redundant code).  Have to keep source code release for
*            GLOBUS.RELEASE (not PERFORM.GLOBUS.RELEASE) as cannot
*            release object code to BP1.O (type 1 file) for clients
*            currently on releases prior to G8. This can be removed when
*            all clients are up to G8!
*
* 07/06/00 - GB0001410
*            Call INITIALISE.MAIN.COMMON to ensure COMMON is set up
*            when going from unlabelled to labelled main common
*
* 09/01/01 - GB100053
*            When the program runs under jBASE it does not need to do any
*            compiling or cataloging actions since this would have already been
*            done and the resulting lib & bin structures will be present in the
*            new temp.release, so just skip to the call to PERFORM.GLOBUS.RELEASE
*
* 23/09/09 - EN_10004355
*            Replace Globus.BP with T24.BP in T24 Server Code
*
* 25/11/2009 - BG_100025913
*              Soft code the folder named T24.BP
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT().
*
* 24/10/18 - Enhancement 2822523 / Task 2826344
*          - Incorporation of EB_Upgrade component
*==============================================================================
    $INSERT I_COMMON
    $INSERT I_SCREEN.VARIABLES
*==============================================================================
*
    E = ''
    CONT = ''
*
* Check that the common is setup correctly - in case we're upgrading to use the new
* named main common - this also obviates the need to check if
* you running in globus

    CALL INITIALISE.MAIN.COMMON

    PRINT @(1,5)
*
    EXECUTE 'COMO ON GLOBUS.RELEASE'
*
    PRINT
    PRINT SPACE(30):'GLOBUS.RELEASE'
    PRINT SPACE(30):'=============='
    PRINT
*
* Current account must be the run account
*
    CURRENT.ACCOUNT = UPCASE(@WHO)
*
* We might consider calling a jBASE specific routine
* to copy over the latest versions on the release programs,
* but this would require another directory, and additions to the
* search paths for the bins and libs. Seeing as this shouldn't need
* to be done very often, we might  even be able to use the patch release
* mechanism
*
    IF (RUNNING.IN.JBASE) THEN         ; * GB0100053
        GOTO PERFORM.RELEASE
    END                                ; * GB0100053

    IF CURRENT.ACCOUNT[4] <> '.RUN' THEN
        E ='EB.RTN.GLOBUS.RELEASE.RUN.RUN.AC'
        GOTO FATAL.ERROR
    END
*
* Open the VOC
*
    OPEN '','VOC' TO VOC ELSE
        E ='EB.RTN.CANT.OPEN.VOC'
        GOTO FATAL.ERROR
    END
*
* Setup a VOC pointer to BP in TEMP.RELEASE
*
    R.VOC = 'Q'
    R.VOC<2> = 'TEMP.RELEASE'
    R.VOC<3> = 'BP'
    WRITE R.VOC TO VOC,'TEMP.RELEASE/BP'
*
* Setup a VOC pointer to BP.O in TEMP.RELEASE
*
    R.VOC = 'Q'
    R.VOC<2> = 'TEMP.RELEASE'
    R.VOC<3> = 'BP.O'
    WRITE R.VOC TO VOC,'TEMP.RELEASE/BP.O'
*
* Open the file to make sure it exists - if it doesn't, don't try to copy
* over release programs - assume a product release
*
    OPEN '','TEMP.RELEASE/BP.O' TO TEMP.FILE ELSE
        GOTO PERFORM.RELEASE
    END
*
* Get the UNIX pathname
*
    STATUS STAT FROM TEMP.FILE THEN FROM.UNIX.PATH = STAT<20> ELSE
        GOTO PERFORM.RELEASE
    END
    REMOTE.IDX = INDEX(FROM.UNIX.PATH,'!',1)
    IF REMOTE.IDX THEN FROM.UNIX.PATH = FROM.UNIX.PATH[REMOTE.IDX+1,999]
*
* Open SAVEDLISTS in local account
*
    OPEN '','&SAVEDLISTS&' TO SAVEDLISTS ELSE
        E ='EB.RTN.CANT.OPEN.&SAVEDLISTS'
        GOTO FATAL.ERROR
    END
*
* See if GLOBUS.BP.O exists.  If it exists, get the UNIX pathname
*
* If it doesn't exist, must do source release (as the object code may
* not be able to be copied, if BPn.O is a type 1 file)
    OPEN '','GLOBUS.BP.O' TO GLOBUS.BP.O THEN
        STATUS STAT FROM GLOBUS.BP.O THEN
            UNIX.PATH = STAT<20>
            GLOBUS.BP.EXISTS = 1
        END ELSE GLOBUS.BP.EXISTS = 0
    END ELSE
        GLOBUS.BP.EXISTS = 0
    END
*
    PRINT '**** Compiling and cataloging latest versions of release programs'
    PRINT
    PRINT 'Do you wish to continue? (Y/N)  ':
    INPUT CONT
    PRINT
*
    IF NOT(UPCASE(CONT) MATCHES 'Y':@VM:'X':@VM:'XX':@VM:'YS') THEN
        E ='EB.RTN.USER.REQUESTED.TERMINATION.RELEASE'
        GOTO FATAL.ERROR
    END
*
* If user replied "X" (really only for Temenos staff), release programs
* will not be copied, compiled and cataloged
* If user replied "YS", source code will not be deleted - only for
* Temenos upgrade to BNK
*
    IF UPCASE(CONT)[1] = 'X' THEN GOTO PERFORM.RELEASE
*
* Setup a VOC pointer to the &SAVEDLISTS& in TEMP.RELEASE
*
    R.VOC = 'Q'
    R.VOC<2> = 'TEMP.RELEASE'
    R.VOC<3> = '&SAVEDLISTS&'
    K.VOC = 'TEMP.RELEASE/&SAVEDLISTS&'
    WRITE R.VOC TO VOC,K.VOC
*
    OPEN '',K.VOC TO RELEASE.SAVEDLISTS ELSE
        E ='EB.RTN.CANT.OPEN.&SAVEDLISTS.TEMP.RELEASE'
        GOTO FATAL.ERROR
    END
*
* Process select list
*
    READ R.LIST FROM RELEASE.SAVEDLISTS,'RELEASE.PROGS' ELSE
        E = 'CANNOT READ RELEASE.PROGS':' FROM &SAVEDLISTS& IN TEMP.RELEASE'
        GOTO FATAL.ERROR
    END
*
    MAX.PROGS = COUNT(R.LIST,@FM) + (R.LIST <> '')
    NEW.LIST = ''
    FOR PGM.COUNT = 1 TO MAX.PROGS
        PGM.NAME = R.LIST<PGM.COUNT>
*
* Copy the program over, to either BP1, BP2 or T24.BP
*
        IF PGM.NAME[1,1] >= 'G' THEN BP.NO = 2 ELSE BP.NO = 1
        IF PGM.NAME[1,2] = 'I_' THEN
            CALL HUSHIT(1)
            IF GLOBUS.BP.EXISTS = 0 THEN
                EXECUTE 'COPY FROM TEMP.RELEASE/BP TO BP1 ':PGM.NAME
                EXECUTE 'COPY FROM TEMP.RELEASE/BP TO BP2 ':PGM.NAME
            END
            CALL HUSHIT(0)
        END ELSE
*
* Copy the object over to GLOBUS.BP.O (OR BP1.O if prior to G8)
*
            CALL HUSHIT(1)
            IF GLOBUS.BP.EXISTS THEN
                EXECUTE 'COPY FROM TEMP.RELEASE/BP TO ' :T24$BP:' ':PGM.NAME:' OVERWRITING'
* GB9800613 s
                COMMAND = ""
                COMMAND<1> = FROM.UNIX.PATH:'/':PGM.NAME
                COMMAND<2> = UNIX.PATH
                SH.COPY = "COPY"
                RESULT = ""
                RETURN.CODE = ""
                CALL SYSTEM.CALL(SH.COPY,"",COMMAND,RESULT,RETURN.CODE)
* GB9800613 e
            END ELSE
                EXECUTE 'COPY FROM TEMP.RELEASE/BP TO BP':BP.NO:' ':PGM.NAME:' OVERWRITING'
            END
            CALL HUSHIT(0)
        END
*
* Copy select list for release programs from TEMP.RELEASE to the
* current account, removing inserts, as these will not compile
* Select list will be used by EBS.PROGRAMS.INSTALL
*
        IF PGM.NAME[1,2] <> 'I_' THEN NEW.LIST<-1> = PGM.NAME
    NEXT PGM.COUNT
    WRITE NEW.LIST TO SAVEDLISTS,'RELEASE.PROGS'
*
* Compile and catalog the programs.  Compile and catalog
* EBS.PROGRAMS.INSTALL before it is used
*
    FOR LINE.NO = 19 TO 23
        PRINT @(1,LINE.NO):S.CLEAR.EOL:
    NEXT LINE.NO
    PRINT @(1,15):
*
    IF GLOBUS.BP.EXISTS THEN
        EXECUTE 'CATALOG ':T24$BP:' EBS.PROGRAMS.INSTALL LOCAL'
    END ELSE
        EXECUTE 'BASIC BP1 EBS.PROGRAMS.INSTALL'
        EXECUTE 'CATALOG BP1 EBS.PROGRAMS.INSTALL LOCAL'
    END
    PRINT
    PRINT
*
* If T24.BP exists, catalog the programs.  Otherwise compile and
* catalog them
*
    IF GLOBUS.BP.EXISTS THEN
        INPUT.BUFFER = 'RELEASE.PROGS 2'
    END ELSE INPUT.BUFFER = 'RELEASE.PROGS 3'

    EB.Upgrade.EbsProgramsInstall()
    IF E THEN GOTO FATAL.ERROR
*
PERFORM.RELEASE:
*
    PRINT '**** Calling PERFORM.RELEASE to actually run the upgrade'
    PRINT
*
    COMPILE = 'Y'
    IF UPCASE(CONT) = 'YS' THEN COMPILE = 'YS'
*
    CALL STANDARD.DISPLAY
    EB.Upgrade.PerformGlobusRelease(CURRENT.ACCOUNT,COMPILE)
*
* NOTE: The como GLOBUS.RELEASE is not switched off by this program.
* It will be switched off when PERFORM.GLOBUS.RELEASE determines the
* release to be installed and the switches on the como REL.n.nn.n
*
RETURN
*
*************************************************************************
*
FATAL.ERROR:
*
    PRINT
    PRINT E
    PRINT 'Press <RETURN>':
    INPUT XX
    EXECUTE 'COMO OFF'
RETURN
END
